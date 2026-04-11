class_name DecorationPlacer
extends Node

## Build mode controller. When activated, the player can place decorations
## with mouse cursor + grid snapping + ghost preview. Hooks into camera
## raycast for ground position.

signal build_mode_entered
signal build_mode_exited
signal placement_made(decoration_id: StringName)
signal placement_invalid

@export var camera_path: NodePath
@export var ghost_holder_path: NodePath
@export var grid_overlay_path: NodePath

var build_mode_active: bool = false
var current_decoration_id: StringName = &""
var current_rotation: int = 0
var current_variant: int = 0
var current_plot: BuildablePlot
var snap_to_grid: bool = true

var _camera: Camera3D
var _ghost: Node3D
var _grid_overlay: Node3D
var _undo_stack: Array[Dictionary] = []


func _ready() -> void:
	_camera = get_node_or_null(camera_path) as Camera3D
	_grid_overlay = get_node_or_null(grid_overlay_path) as Node3D


func _unhandled_input(event: InputEvent) -> void:
	if not build_mode_active:
		if event is InputEventKey and event.pressed and event.keycode == KEY_B:
			enter_build_mode()
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_B:    exit_build_mode()
			KEY_Q:    rotate_left()
			KEY_E:    rotate_right()
			KEY_G:    snap_to_grid = not snap_to_grid
			KEY_Z:
				if event.ctrl_pressed: undo()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				try_place_at_cursor()
			MOUSE_BUTTON_RIGHT:
				cancel_current_decoration()
			MOUSE_BUTTON_WHEEL_UP:
				cycle_variant(+1)
			MOUSE_BUTTON_WHEEL_DOWN:
				cycle_variant(-1)
	if event is InputEventMouseMotion:
		_update_ghost()


func enter_build_mode() -> void:
	build_mode_active = true
	build_mode_entered.emit()
	if _grid_overlay != null:
		_grid_overlay.visible = true


func exit_build_mode() -> void:
	build_mode_active = false
	build_mode_exited.emit()
	if _grid_overlay != null:
		_grid_overlay.visible = false
	_clear_ghost()


func set_decoration(decoration_id: StringName) -> void:
	current_decoration_id = decoration_id
	current_rotation = 0
	current_variant = 0
	_spawn_ghost()


func set_plot(plot: BuildablePlot) -> void:
	current_plot = plot


func rotate_left() -> void:
	current_rotation = (current_rotation + 3) % 4
	_update_ghost()


func rotate_right() -> void:
	current_rotation = (current_rotation + 1) % 4
	_update_ghost()


func cycle_variant(delta: int) -> void:
	current_variant = max(0, current_variant + delta)
	_update_ghost()


func cancel_current_decoration() -> void:
	current_decoration_id = &""
	_clear_ghost()


func try_place_at_cursor() -> bool:
	if current_decoration_id == &"" or current_plot == null:
		return false
	var grid_pos: Vector2i = _get_cursor_grid_pos()
	if not current_plot.can_place_at(current_decoration_id, grid_pos):
		placement_invalid.emit()
		return false
	if current_plot.place(current_decoration_id, grid_pos, current_rotation, current_variant):
		_undo_stack.append({
			"plot": current_plot,
			"id": current_decoration_id,
			"position": grid_pos,
		})
		placement_made.emit(current_decoration_id)
		return true
	return false


func undo() -> bool:
	if _undo_stack.is_empty():
		return false
	var entry: Dictionary = _undo_stack.pop_back()
	var plot: BuildablePlot = entry["plot"]
	if plot != null:
		plot.remove_at(entry["position"])
		return true
	return false


func _get_cursor_grid_pos() -> Vector2i:
	if _camera == null:
		return Vector2i.ZERO
	var mouse_pos: Vector2 = _camera.get_viewport().get_mouse_position()
	var origin: Vector3 = _camera.project_ray_origin(mouse_pos)
	var direction: Vector3 = _camera.project_ray_normal(mouse_pos)
	# Cast against the plot's ground plane (assume Y=plot.position.y)
	var plot_y: float = current_plot.global_position.y if current_plot != null else 0.0
	if abs(direction.y) < 0.001:
		return Vector2i.ZERO
	var t: float = (plot_y - origin.y) / direction.y
	var hit: Vector3 = origin + direction * t
	# Convert to grid coords (assume 1 unit = 1 grid cell)
	var local: Vector3 = hit - (current_plot.global_position if current_plot else Vector3.ZERO)
	return Vector2i(int(floor(local.x)), int(floor(local.z)))


func _spawn_ghost() -> void:
	_clear_ghost()
	# A real ghost would instantiate the decoration scene with a transparent material.
	# Placeholder hook here — UI scene wires up the actual mesh preview.


func _update_ghost() -> void:
	if _ghost == null or current_plot == null:
		return
	var grid_pos: Vector2i = _get_cursor_grid_pos()
	_ghost.global_position = current_plot.global_position + Vector3(grid_pos.x, 0, grid_pos.y)
	_ghost.rotation_degrees.y = current_rotation * 90.0
	# Tint green/red based on validity
	var valid: bool = current_plot.can_place_at(current_decoration_id, grid_pos)
	# Apply tint via material override... (placeholder)


func _clear_ghost() -> void:
	if _ghost != null:
		_ghost.queue_free()
		_ghost = null
