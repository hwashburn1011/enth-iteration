class_name LevelComponent
extends Node
## Tracks XP, levels, and unspent stat points.
##
## XP curve is quadratic so per-level grind grows with progression instead
## of staying flat:
##     xp_to_next(L) = XP_BASE * L * (L + 1) / 2
##
## At XP_BASE=100 that gives 100/300/600/1000/1500/.../4500 from level 1→10
## (16500 total). MAX_LEVEL caps progression for the 9-iteration story arc.
## On a multi-level XP drop we accumulate stat points but only emit
## leveled_up once at the end so the player UI opens a single allocation
## panel instead of one per level.

signal leveled_up(new_level: int)
signal xp_changed(current_xp: int, xp_to_next: int)

## R3 M22: expanded from 30 to 60 for the full 9-iteration arc.
const MAX_LEVEL: int = 60
const XP_REWARD_GLITCH_BUG: int = 25
const XP_REWARD_MEMORY_LEAK: int = 40
const XP_REWARD_ROGUE_PROCESS: int = 60
const XP_REWARD_DEFAULT: int = 20
## XP reward multiplier added per compaction loop past the first. Mirrors
## ITERATION_HP_MULT_PER_LOOP on enemy_base so leveling speed stays in
## sync with the difficulty curve — enemies at iter 9 have 3.0x HP, this
## constant gives them 3.0x XP too.
const ITERATION_XP_MULT_PER_LOOP: float = 0.25

@export var xp_per_level_base: int = 100
@export var stat_points_per_level: int = 3

var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100
var unspent_stat_points: int = 0


func _ready() -> void:
	xp_to_next_level = _xp_required_for_level(current_level)
	EventBus.enemy_defeated.connect(_on_enemy_defeated)


func _xp_required_for_level(level: int) -> int:
	## XP required to advance from `level` to `level + 1`.
	## Quadratic: base * level * (level + 1) / 2
	@warning_ignore("integer_division")
	return xp_per_level_base * level * (level + 1) / 2


func add_xp(amount: int) -> void:
	if current_level >= MAX_LEVEL:
		# At cap — don't bank XP, don't re-emit.
		current_xp = 0
		xp_changed.emit(current_xp, 0)
		return
	current_xp += amount
	var levels_gained: int = 0
	while current_level < MAX_LEVEL and current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		levels_gained += 1
		unspent_stat_points += stat_points_per_level
		xp_to_next_level = _xp_required_for_level(current_level)
	# At cap, drop any overflow XP so the bar shows 0/0 on the HUD.
	if current_level >= MAX_LEVEL:
		current_xp = 0
	# Single emission per add_xp call — even on multi-level gains the UI
	# only opens one stat allocation panel for the cumulative point pool.
	if levels_gained > 0:
		leveled_up.emit(current_level)
		# Mirror to EventBus so global listeners (audio_manager level_up SFX,
		# voice_manager voice cue, expression_driver facial cue) can react.
		# All three were sitting on defensive has_signal listeners waiting
		# for this signal to exist.
		EventBus.player_leveled_up.emit(current_level)
	xp_changed.emit(current_xp, xp_to_next_level)


func _on_enemy_defeated(enemy_type: StringName, pos: Vector3, _loot: Resource) -> void:
	var xp: int = XP_REWARD_DEFAULT
	match String(enemy_type):
		"glitch_bug":
			xp = XP_REWARD_GLITCH_BUG
		"memory_leak":
			xp = XP_REWARD_MEMORY_LEAK
		"rogue_process":
			xp = XP_REWARD_ROGUE_PROCESS
	xp = int(round(float(xp) * _iteration_xp_multiplier()))
	add_xp(xp)
	# Spawn XP number at enemy position
	if get_parent() and get_parent().is_inside_tree():
		_spawn_xp_number(pos, xp)


func _iteration_xp_multiplier() -> float:
	## Mirror of enemy_base._apply_iteration_scaling. Defensive feature-
	## detect ladder so missing-autoload setups (legacy saves, test
	## harnesses) fall back to 1.0x cleanly instead of crashing.
	if not has_node("/root/IterationManager"):
		return 1.0
	var im: Node = get_node("/root/IterationManager")
	var iter: int = 1
	if im.has_method(&"get_current_iteration"):
		iter = int(im.get_current_iteration())
	elif "current_iteration" in im:
		iter = int(im.current_iteration)
	if iter <= 1:
		return 1.0
	return 1.0 + float(iter - 1) * ITERATION_XP_MULT_PER_LOOP


func _spawn_xp_number(pos: Vector3, xp: int) -> void:
	var label: Label3D = Label3D.new()
	label.text = "+%d XP" % xp
	label.font_size = 18
	label.modulate = Color(0.4, 0.85, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.7)
	label.outline_size = 3
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = pos + Vector3(0, 1.5, 0)
	get_parent().get_tree().current_scene.add_child(label)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "position:y", label.position.y + 1.2, 0.9).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9).set_delay(0.4)
	tween.tween_callback(label.queue_free)
