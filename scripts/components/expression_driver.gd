class_name ExpressionDriver
extends Node

## Drives Globbler v2 facial expressions via blendshape control on the
## pupil and mouth meshes. Listens to gameplay events from EventBus and
## fades expressions in/out smoothly.
##
## Expected scene structure:
##   - mesh_pupil_R, mesh_pupil_L, mesh_mouth_line as MeshInstance3D nodes
##     somewhere in the scene tree (resolved via @export NodePath)

@export var pupil_r_path: NodePath
@export var pupil_l_path: NodePath
@export var mouth_path: NodePath
@export var fade_speed: float = 6.0  ## Higher = snappier transitions

const EXPRESSIONS: PackedStringArray = [
	&"blink", &"smile", &"frown", &"surprised",
	&"angry", &"sad", &"smirk", &"hurt", &"dead"
]

var _pupil_r: MeshInstance3D
var _pupil_l: MeshInstance3D
var _mouth: MeshInstance3D

var _current_expression: StringName = &""
var _target_weights: Dictionary = {}  ## expression -> 0-1 target
var _live_weights: Dictionary = {}    ## expression -> 0-1 current

var _blink_timer: float = 0.0
var _next_blink_at: float = 4.0

func _ready() -> void:
	_pupil_r = get_node_or_null(pupil_r_path) as MeshInstance3D
	_pupil_l = get_node_or_null(pupil_l_path) as MeshInstance3D
	_mouth = get_node_or_null(mouth_path) as MeshInstance3D

	if _pupil_r == null or _pupil_l == null:
		push_warning("ExpressionDriver: pupil meshes not found at paths %s / %s" % [pupil_r_path, pupil_l_path])

	for expr in EXPRESSIONS:
		_target_weights[expr] = 0.0
		_live_weights[expr] = 0.0

	# Subscribe to EventBus signals if available
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("player_damaged"):
			bus.player_damaged.connect(_on_player_damaged)
		if bus.has_signal("player_died"):
			bus.player_died.connect(_on_player_died)
		if bus.has_signal("player_leveled_up"):
			bus.player_leveled_up.connect(_on_player_leveled_up)
		if bus.has_signal("enemy_killed"):
			bus.enemy_killed.connect(_on_enemy_killed)


func _process(delta: float) -> void:
	# Auto-blink loop
	_blink_timer += delta
	if _blink_timer >= _next_blink_at:
		_blink_timer = 0.0
		_next_blink_at = randf_range(3.0, 6.5)
		_blink_once()

	# Lerp live weights toward target
	for expr in EXPRESSIONS:
		var target: float = _target_weights[expr]
		var current: float = _live_weights[expr]
		_live_weights[expr] = lerp(current, target, delta * fade_speed)

	_apply_weights()


func set_expression(name: StringName, hold_duration: float = 0.0) -> void:
	if not (name in EXPRESSIONS):
		push_warning("ExpressionDriver: unknown expression %s" % name)
		return

	# Reset all targets, set this one
	for expr in EXPRESSIONS:
		_target_weights[expr] = 0.0
	_target_weights[name] = 1.0
	_current_expression = name

	if hold_duration > 0.0:
		await get_tree().create_timer(hold_duration).timeout
		if _current_expression == name:
			_target_weights[name] = 0.0
			_current_expression = &""


func clear_expression() -> void:
	for expr in EXPRESSIONS:
		_target_weights[expr] = 0.0
	_current_expression = &""


func _blink_once() -> void:
	_target_weights[&"blink"] = 1.0
	await get_tree().create_timer(0.08).timeout
	_target_weights[&"blink"] = 0.0


func _apply_weights() -> void:
	# Apply to both pupils
	for mesh: MeshInstance3D in [_pupil_r, _pupil_l]:
		if mesh == null or mesh.mesh == null:
			continue
		for expr in EXPRESSIONS:
			var idx: int = mesh.find_blend_shape_by_name(expr)
			if idx >= 0:
				mesh.set_blend_shape_value(idx, _live_weights[expr])

	# Apply mouth-supported expressions
	if _mouth != null and _mouth.mesh != null:
		for expr in [&"smile", &"frown", &"surprised", &"angry", &"sad", &"hurt", &"dead"]:
			var idx: int = _mouth.find_blend_shape_by_name(expr)
			if idx >= 0:
				_mouth.set_blend_shape_value(idx, _live_weights[expr])


# === EventBus reactions ===

func _on_player_damaged(_amount: float) -> void:
	set_expression(&"hurt", 0.4)


func _on_player_died() -> void:
	set_expression(&"dead", 999.0)


func _on_player_leveled_up(_new_level: int) -> void:
	set_expression(&"surprised", 0.3)
	await get_tree().create_timer(0.3).timeout
	set_expression(&"smile", 1.5)


func _on_enemy_killed(_enemy: Node) -> void:
	set_expression(&"smirk", 0.5)
