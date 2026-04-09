class_name GlitchBugAnimTreeBuilder
extends Node

## Programmatically configures an AnimationTree for the GlitchBug rig.
## Used at runtime after the GLB has been imported, since hand-authoring
## the AnimationTree state machine in the Godot editor for every enemy
## variant is fragile.
##
## Walks the parent's AnimationPlayer for the expected animation names
## (idle, walk, run, aggro_rear, lunge, bite, hit_*, death, death_explode)
## and builds an AnimationNodeStateMachine with these states + the
## transitions that define the GlitchBug behavior arc.
##
## State machine layout:
##                ┌──────┐
##                │ idle │  ←──── default state
##                └──┬───┘
##                   │ (speed > 0)
##              ┌────▼────┐
##              │  walk   │
##              └────┬────┘
##                   │ (speed > 4)
##              ┌────▼────┐
##              │   run   │
##              └────┬────┘
##                   │ (player in aggro range)
##         ┌─────────▼─────────┐
##         │   aggro_rear      │
##         └─┬───────────────┬─┘
##           │ (attack)      │ (player out of range)
##      ┌────▼────┐          │
##      │  lunge  │          │
##      └────┬────┘          │
##           │               │
##      ┌────▼────┐          │
##      │  bite   │          │
##      └────┬────┘          │
##           │               │
##           └──────────┐    │
##                      ▼    ▼
##                   ┌──────┐
##                   │ idle │
##                   └──────┘
##
## Hit reactions and death are interruptible from any state.
##
## Required scene shape:
##   GlitchBugAnimTreeBuilder (Node + this script)
##     parent must contain an AnimationPlayer with all the GlitchBug
##     animations loaded (typically from the imported GLB)

signal anim_tree_built(tree: AnimationTree)

@export var animation_player_path: NodePath
@export var build_on_ready: bool = true

const STATE_NAMES: PackedStringArray = PackedStringArray([
	"idle",
	"walk",
	"run",
	"aggro_rear",
	"lunge",
	"bite",
	"hit_front",
	"hit_back",
	"hit_left",
	"hit_right",
	"death",
	"death_explode",
])

const ANIM_NAME_PREFIX: String = "glitchbug_"

# Transitions: (from, to, condition_param, switch_mode)
# switch_mode: 0=immediate, 1=sync, 2=at_end
const TRANSITIONS: Array[Array] = [
	# Locomotion arc
	["idle", "walk", "is_walking", 1],
	["walk", "idle", "is_idle", 1],
	["walk", "run", "is_running", 1],
	["run", "walk", "is_walking", 1],
	["run", "idle", "is_idle", 1],
	# Combat arc
	["walk", "aggro_rear", "should_aggro", 0],
	["run", "aggro_rear", "should_aggro", 0],
	["idle", "aggro_rear", "should_aggro", 0],
	["aggro_rear", "lunge", "should_attack", 2],
	["aggro_rear", "idle", "lost_target", 2],
	["lunge", "bite", "should_continue", 2],
	["lunge", "idle", "should_break", 2],
	["bite", "lunge", "should_repeat", 2],
	["bite", "aggro_rear", "should_reposition", 2],
	["bite", "idle", "should_break", 2],
	# Death is reachable from any state via "Any State" transitions
	["Any", "death", "is_dead", 0],
	["Any", "death_explode", "is_dead_explode", 0],
	# Hit reactions are reachable from any non-death state
	["Any", "hit_front", "hit_from_front", 0],
	["Any", "hit_back", "hit_from_back", 0],
	["Any", "hit_left", "hit_from_left", 0],
	["Any", "hit_right", "hit_from_right", 0],
	# Hit reactions return to idle
	["hit_front", "idle", "", 2],
	["hit_back", "idle", "", 2],
	["hit_left", "idle", "", 2],
	["hit_right", "idle", "", 2],
]


func _ready() -> void:
	if build_on_ready:
		build()


func build() -> AnimationTree:
	var anim_player: AnimationPlayer = get_node_or_null(animation_player_path) as AnimationPlayer
	if anim_player == null:
		# Auto-find on parent
		var parent: Node = get_parent()
		if parent != null:
			for child: Node in parent.get_children():
				if child is AnimationPlayer:
					anim_player = child
					break
	if anim_player == null:
		push_warning("GlitchBugAnimTreeBuilder: no AnimationPlayer found")
		return null

	# Build the AnimationTree
	var tree: AnimationTree = AnimationTree.new()
	tree.name = "GlitchBugAnimTree"
	tree.anim_player = tree.get_path_to(anim_player)

	# Build the root state machine
	var root_sm: AnimationNodeStateMachine = AnimationNodeStateMachine.new()
	tree.tree_root = root_sm

	# Add a state for each known animation that exists in the player
	for state_name: String in STATE_NAMES:
		var anim_name: String = ANIM_NAME_PREFIX + state_name
		if not anim_player.has_animation(anim_name):
			# Skip states whose animation isn't in the player — graceful
			# fallback when the GLB only has a subset
			continue
		var anim_node: AnimationNodeAnimation = AnimationNodeAnimation.new()
		anim_node.animation = anim_name
		root_sm.add_node(state_name, anim_node)

	# Set the default starting state
	if root_sm.has_node("idle"):
		root_sm.set_start_node("idle")

	# Add transitions
	for t: Array in TRANSITIONS:
		var from: String = t[0]
		var to: String = t[1]
		var cond: String = t[2]
		var switch_mode: int = t[3]

		# Skip if the destination state doesn't exist (because the anim
		# wasn't in the player)
		if not root_sm.has_node(to):
			continue
		# "Any" transitions are special — Godot supports add_transition
		# with from="Any State" via the engine's special node
		var from_check: String = from if from == "Any" else from
		if from != "Any" and not root_sm.has_node(from_check):
			continue

		var transition: AnimationNodeStateMachineTransition = AnimationNodeStateMachineTransition.new()
		transition.switch_mode = switch_mode
		transition.auto_advance = (cond == "")
		if cond != "":
			transition.advance_condition = cond

		# Use "Any State" for from="Any" — this is the special node name in Godot 4
		var actual_from: String = "Any State" if from == "Any" else from
		root_sm.add_transition(actual_from, to, transition)

	get_parent().add_child(tree)
	tree.active = true

	anim_tree_built.emit(tree)
	return tree
