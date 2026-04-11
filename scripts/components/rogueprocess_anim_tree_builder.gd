class_name RogueProcessAnimTreeBuilder
extends Node

## Programmatically configures an AnimationTree for the RogueProcess rig.
## Parallel of GlitchBugAnimTreeBuilder (Epic 04 task 37) but for the
## RogueProcess's machine-archetype behavior arc.
##
## Walks the parent's AnimationPlayer for the expected animation names
## and builds an AnimationNodeStateMachine with these states + the
## transitions that define the RogueProcess behavior.
##
## State machine layout:
##                ┌────────────┐
##                │ hover_idle │  ←──── default state
##                └─────┬──────┘
##                      │ (player in aggro range)
##                ┌─────▼─────┐
##                │ combat_idle│
##                └──┬─────┬──┘
##              ┌────┘     └────┐
##              │               │
##         ┌────▼─────┐    ┌────▼─────┐
##         │ strafe_R │    │ strafe_L │
##         └────┬─────┘    └────┬─────┘
##              │               │
##              └───┐       ┌───┘
##                  ▼       ▼
##               ┌─────────────┐
##               │ combat_idle │
##               └──┬───────┬──┘
##                  │       │
##         ┌────────▼┐ ┌────▼─────┐
##         │ charge  │ │ melee    │
##         │ ranged  │ │ swipe    │
##         └────┬────┘ └────┬─────┘
##              │           │
##              └─────┬─────┘
##                    ▼
##              ┌─────────────┐
##              │ combat_idle │
##              └─────────────┘
##
## Hit reactions, teleport, and death are all "Any State" interrupts.

signal anim_tree_built(tree: AnimationTree)

@export var animation_player_path: NodePath
@export var build_on_ready: bool = true

const STATE_NAMES: PackedStringArray = PackedStringArray([
	"hover_idle",
	"combat_idle",
	"strafe_R",
	"strafe_L",
	"dash_forward",
	"teleport_in",
	"teleport_out",
	"charge_ranged",
	"fire_ranged",
	"melee_swipe",
	"hit_react",
	"death",
])

const ANIM_NAME_PREFIX: String = "rogueprocess_"

const TRANSITIONS: Array[Array] = [
	# Locomotion + state arc
	["hover_idle", "combat_idle", "should_aggro", 0],
	["combat_idle", "hover_idle", "lost_target", 1],
	["combat_idle", "strafe_R", "should_strafe_R", 0],
	["combat_idle", "strafe_L", "should_strafe_L", 0],
	["strafe_R", "combat_idle", "stop_strafe", 1],
	["strafe_L", "combat_idle", "stop_strafe", 1],
	# Combat actions
	["combat_idle", "charge_ranged", "should_fire", 0],
	["charge_ranged", "fire_ranged", "", 2],  # auto-advance after charge
	["fire_ranged", "combat_idle", "", 2],
	["combat_idle", "melee_swipe", "should_melee", 0],
	["melee_swipe", "combat_idle", "", 2],
	["combat_idle", "dash_forward", "should_dash", 0],
	["dash_forward", "combat_idle", "", 2],
	# Teleport interrupts
	["Any", "teleport_out", "should_teleport", 0],
	["teleport_out", "teleport_in", "", 2],
	["teleport_in", "combat_idle", "", 2],
	# Hit reaction interrupt
	["Any", "hit_react", "got_hit", 0],
	["hit_react", "combat_idle", "", 2],
	# Death interrupt from any state
	["Any", "death", "is_dead", 0],
]


func _ready() -> void:
	if build_on_ready:
		build()


func build() -> AnimationTree:
	var anim_player: AnimationPlayer = get_node_or_null(animation_player_path) as AnimationPlayer
	if anim_player == null:
		var parent: Node = get_parent()
		if parent != null:
			for child: Node in parent.get_children():
				if child is AnimationPlayer:
					anim_player = child
					break
	if anim_player == null:
		push_warning("RogueProcessAnimTreeBuilder: no AnimationPlayer found")
		return null

	var tree: AnimationTree = AnimationTree.new()
	tree.name = "RogueProcessAnimTree"
	tree.anim_player = tree.get_path_to(anim_player)

	var root_sm: AnimationNodeStateMachine = AnimationNodeStateMachine.new()
	tree.tree_root = root_sm

	# Add a state for each known animation that exists in the player
	for state_name: String in STATE_NAMES:
		var anim_name: String = ANIM_NAME_PREFIX + state_name
		if not anim_player.has_animation(anim_name):
			# Skip states whose animation isn't in the player — graceful
			# fallback when only a subset of animations have been authored
			continue
		var anim_node: AnimationNodeAnimation = AnimationNodeAnimation.new()
		anim_node.animation = anim_name
		root_sm.add_node(state_name, anim_node)

	# Set the default starting state
	if root_sm.has_node("hover_idle"):
		root_sm.set_start_node("hover_idle")

	# Add transitions
	for t: Array in TRANSITIONS:
		var from: String = t[0]
		var to: String = t[1]
		var cond: String = t[2]
		var switch_mode: int = t[3]

		if not root_sm.has_node(to):
			continue
		if from != "Any" and not root_sm.has_node(from):
			continue

		var transition: AnimationNodeStateMachineTransition = AnimationNodeStateMachineTransition.new()
		transition.switch_mode = switch_mode
		transition.auto_advance = (cond == "")
		if cond != "":
			transition.advance_condition = cond

		var actual_from: String = "Any State" if from == "Any" else from
		root_sm.add_transition(actual_from, to, transition)

	get_parent().add_child(tree)
	tree.active = true

	anim_tree_built.emit(tree)
	return tree
