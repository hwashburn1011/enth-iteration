class_name PhotoMode
extends Node

## Free-camera photo mode for capturing screenshots in town. Hides HUD,
## allows free WASD camera movement, time-of-day slider, filter selection,
## and screenshot save to user://photos/.

signal photo_mode_entered
signal photo_mode_exited
signal screenshot_saved(path: String)

@export var camera_path: NodePath
@export var hud_path: NodePath
@export var move_speed: float = 6.0
@export var look_sensitivity: float = 0.003

var active: bool = false
var hud_visible_before: bool = true
var current_filter: int = 0
var aspect_mode: int = 0  ## 0=16:9, 1=1:1, 2=vertical

const FILTERS: PackedStringArray = ["none", "warm", "cool", "noir"]
const ASPECT_RATIOS: Array = [Vector2(16, 9), Vector2(1, 1), Vector2(9, 16)]

var _camera: Camera3D
var _hud: CanvasLayer
var _yaw: float = 0.0
var _pitch: float = 0.0


func _ready() -> void:
	_camera = get_node_or_null(camera_path) as Camera3D
	_hud = get_node_or_null(hud_path) as CanvasLayer
	set_process_unhandled_input(true)
	set_physics_process(false)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F9:
			toggle()
		elif active:
			match event.keycode:
				KEY_F:
					cycle_filter()
				KEY_R:
					cycle_aspect()
				KEY_ENTER:
					save_screenshot()
				KEY_ESCAPE:
					exit_photo_mode()
	if active and event is InputEventMouseMotion:
		_yaw -= event.relative.x * look_sensitivity
		_pitch -= event.relative.y * look_sensitivity
		_pitch = clampf(_pitch, -PI * 0.49, PI * 0.49)
		if _camera != null:
			_camera.rotation = Vector3(_pitch, _yaw, 0)


func _physics_process(delta: float) -> void:
	if not active or _camera == null:
		return
	var input_dir: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.z -= 1.0
	if Input.is_key_pressed(KEY_S): input_dir.z += 1.0
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D): input_dir.x += 1.0
	if Input.is_key_pressed(KEY_Q): input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_E): input_dir.y += 1.0
	var basis: Basis = _camera.global_transform.basis
	var motion: Vector3 = (basis * input_dir).normalized() * move_speed * delta
	_camera.global_position += motion


func toggle() -> void:
	if active:
		exit_photo_mode()
	else:
		enter_photo_mode()


func enter_photo_mode() -> void:
	active = true
	if _hud != null:
		hud_visible_before = _hud.visible
		_hud.visible = false
	get_tree().paused = true
	set_physics_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	photo_mode_entered.emit()


func exit_photo_mode() -> void:
	active = false
	if _hud != null:
		_hud.visible = hud_visible_before
	get_tree().paused = false
	set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	photo_mode_exited.emit()


func cycle_filter() -> void:
	current_filter = (current_filter + 1) % FILTERS.size()
	_apply_filter(FILTERS[current_filter])


func cycle_aspect() -> void:
	aspect_mode = (aspect_mode + 1) % ASPECT_RATIOS.size()
	# Aspect mask handled by the photo mode HUD overlay


func _apply_filter(filter_name: String) -> void:
	# Hook into a CanvasLayer ColorRect with a shader_material
	# to apply the LUT. Placeholder — actual filter shader is in
	# assets/shaders/photo_filter.gdshader (deferred).
	pass


func save_screenshot() -> void:
	var img: Image = get_viewport().get_texture().get_image()
	var time: int = Time.get_unix_time_from_system()
	var path: String = "user://photos/photo_%d.png" % time
	var dir: DirAccess = DirAccess.open("user://")
	if dir != null and not dir.dir_exists("photos"):
		dir.make_dir("photos")
	img.save_png(path)
	screenshot_saved.emit(path)
