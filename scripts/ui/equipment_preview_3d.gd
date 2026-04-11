class_name EquipmentPreview3D
extends SubViewportContainer

## A SubViewport-based 3D rotating preview of the player character with equipment
## changes reflected in real time. Embed in inventory screen for the "spinning
## character preview" common in ARPGs.

@export var auto_rotate: bool = true
@export var rotate_speed_deg_per_sec: float = 25.0
@export var allow_drag_rotate: bool = true

@onready var _viewport: SubViewport = $SubViewport
@onready var _model_holder: Node3D = $SubViewport/ModelHolder
@onready var _camera: Camera3D = $SubViewport/PreviewCamera
@onready var _light_key: DirectionalLight3D = $SubViewport/KeyLight
@onready var _light_fill: DirectionalLight3D = $SubViewport/FillLight

var _yaw: float = 0.0
var _dragging: bool = false
var _drag_start: Vector2
var _drag_start_yaw: float


func _ready() -> void:
	# Default isometric-ish framing
	if _camera != null:
		_camera.position = Vector3(2.4, 1.4, 2.4)
		_camera.look_at(Vector3(0, 0.8, 0), Vector3.UP)


func _process(delta: float) -> void:
	if auto_rotate and not _dragging and _model_holder != null:
		_yaw += deg_to_rad(rotate_speed_deg_per_sec) * delta
		_model_holder.rotation.y = _yaw


func set_preview_model(scene: PackedScene) -> void:
	if _model_holder == null:
		return
	for c in _model_holder.get_children():
		c.queue_free()
	if scene == null:
		return
	var inst: Node = scene.instantiate()
	_model_holder.add_child(inst)


func attach_outfit(slot_name: StringName, outfit_scene: PackedScene) -> void:
	## Same convention as EquipmentVisualizer — finds the slot Node3D in the
	## preview model and parents an instance of outfit_scene to it.
	if _model_holder == null:
		return
	var preview_model: Node = _model_holder.get_child(0) if _model_holder.get_child_count() > 0 else null
	if preview_model == null:
		return
	var slot: Node = _find_descendant_named(preview_model, slot_name)
	if slot is Node3D and outfit_scene != null:
		# Clear existing
		for c in slot.get_children():
			c.queue_free()
		slot.add_child(outfit_scene.instantiate())


func _find_descendant_named(root: Node, target: StringName) -> Node:
	if root.name == target:
		return root
	for c in root.get_children():
		var found: Node = _find_descendant_named(c, target)
		if found != null:
			return found
	return null


func _gui_input(event: InputEvent) -> void:
	if not allow_drag_rotate:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_dragging = mb.pressed
			if _dragging:
				_drag_start = mb.position
				_drag_start_yaw = _yaw
	elif event is InputEventMouseMotion and _dragging:
		var delta_x: float = event.position.x - _drag_start.x
		_yaw = _drag_start_yaw + delta_x * 0.01
		if _model_holder != null:
			_model_holder.rotation.y = _yaw
