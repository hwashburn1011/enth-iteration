class_name TrainingArenaResetLever
extends Area3D

## The wall lever in the training arena. Player walks up, presses
## interact, the lever animates, every TrainingDummy in the arena
## reset()s, the leaderboard plaque records the prior DPS run, and
## a new 20-second measurement window begins.
##
## Required scene shape:
##   TrainingArenaResetLever (Area3D + this script)
##     CollisionShape3D (interact range)
##     LeverPivot (Node3D — pivot for the lever animation)
##     LeverHandle (MeshInstance3D — the visible lever)
##     [optional] AnimationPlayer with "pull" animation
##
## Configure via inspector:
##   leaderboard_path — NodePath to TrainingLeaderboard sibling
##   dummy_root_path  — NodePath to the parent of all TrainingDummy
##                      siblings (the arena scene root)

signal lever_pulled
signal arena_reset

@export var leaderboard_path: NodePath
@export var dummy_root_path: NodePath
@export var pull_anim_duration_s: float = 0.6

@onready var _lever_pivot: Node3D = $LeverPivot if has_node("LeverPivot") else null

var _player_in_range: bool = false
var _animating: bool = false


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false


# === INTERACTION ===

func can_pull() -> bool:
	return _player_in_range and not _animating


func pull() -> bool:
	if not can_pull():
		return false
	_animating = true
	lever_pulled.emit()
	_animate_lever()
	# Snapshot whatever the player has been doing and feed it to the
	# leaderboard before clearing
	_record_to_leaderboard()
	# Reset every dummy under the configured root
	_reset_all_dummies()
	# Sting + sfx
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_lever_clack")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_arena_reset")
	# Open the animation lockout
	var t: SceneTreeTimer = get_tree().create_timer(pull_anim_duration_s)
	t.timeout.connect(func() -> void:
		_animating = false
		arena_reset.emit()
	)
	return true


func _animate_lever() -> void:
	if _lever_pivot == null:
		return
	# Quick rotation pull then return
	var tw: Tween = create_tween()
	tw.tween_property(_lever_pivot, "rotation_degrees", Vector3(45, 0, 0), pull_anim_duration_s * 0.5)
	tw.tween_property(_lever_pivot, "rotation_degrees", Vector3(0, 0, 0), pull_anim_duration_s * 0.5)


# === DUMMY RESET ===

func _reset_all_dummies() -> void:
	var root: Node = get_node_or_null(dummy_root_path)
	if root == null:
		root = get_tree().current_scene
	if root == null:
		return
	var dummies: Array[Node] = []
	_collect_dummies(root, dummies)
	for dummy in dummies:
		if dummy.has_method("reset"):
			dummy.reset()


func _collect_dummies(node: Node, out: Array[Node]) -> void:
	if node is TrainingDummy:
		out.append(node)
	for child in node.get_children():
		_collect_dummies(child, out)


# === LEADERBOARD ===

func _record_to_leaderboard() -> void:
	var lb: Node = get_node_or_null(leaderboard_path)
	if lb == null:
		return
	if not lb.has_method("snapshot_current_run"):
		return
	# Sweep dummies and ask each one for its current dps_log totals,
	# then route everything to the leaderboard for an aggregate record
	var root: Node = get_node_or_null(dummy_root_path)
	if root == null:
		root = get_tree().current_scene
	var dummies: Array[Node] = []
	_collect_dummies(root, dummies)
	var run_total: float = 0.0
	var run_dps: float = 0.0
	var sustain_dummy: Node = null
	for dummy in dummies:
		if dummy.has_method("get_health_percent"):
			# Quick aggregate: sum the damage actually dealt this run
			# (max_health * (1 - get_health_percent()))
			var hp_pct: float = dummy.get_health_percent()
			run_total += (1.0 - hp_pct) * 9999.0  # rough estimate
		# Pull the boss tank's full sustain reading if present
		if dummy.dummy_id == &"dummy_tank_large":
			sustain_dummy = dummy
	# Leaderboard pulls the rest from the dummies' own emission of
	# dps_window_closed signals — this just snapshots the moment
	lb.snapshot_current_run(run_total, run_dps, sustain_dummy)


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
