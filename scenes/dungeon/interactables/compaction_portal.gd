class_name CompactionPortal
extends Area3D
## Warp portal that sends the player back to town after boss defeat.

const TOWN_SCENE_PATH: String = "res://scenes/town/Town.tscn"
const FLASH_DURATION: float = 0.5

var _player_in_range: bool = false

@onready var _mesh: MeshInstance3D = %PortalMesh
@onready var _label: Label3D = %PortalLabel


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_label.visible = false


func _process(delta: float) -> void:
	# Continuous spin and pulse
	if _mesh:
		_mesh.rotate_y(delta * 2.0)
		var pulse: float = 0.8 + sin(Time.get_ticks_msec() * 0.005) * 0.2
		if _mesh.material_override is StandardMaterial3D:
			(_mesh.material_override as StandardMaterial3D).emission_energy_multiplier = pulse


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed(&"interact"):
		_activate_portal()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_label.visible = false


func _activate_portal() -> void:
	set_process_unhandled_input(false)
	EventBus.portal_used.emit()

	# Signal town to position player at return point and reset stats
	GameManager.set_meta(&"town_entry_type", "portal_return")

	# White flash warp effect via a CanvasLayer on the scene root (survives scene change)
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(1, 1, 1, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)
	get_tree().root.add_child(canvas)

	# Flash to white
	var tween: Tween = canvas.create_tween()
	tween.tween_property(overlay, "color:a", 1.0, FLASH_DURATION)
	await tween.finished

	# Emit returned_to_town BEFORE scene change so GameManager can update state
	EventBus.returned_to_town.emit()

	# Change scene — this frees the portal, but canvas is on root so it persists
	GameManager.change_scene_to(TOWN_SCENE_PATH)

	# Fade out the white overlay from the root canvas (runs on canvas, not portal)
	await canvas.get_tree().create_timer(0.3).timeout
	var tween2: Tween = canvas.create_tween()
	tween2.tween_property(overlay, "color:a", 0.0, FLASH_DURATION)
	await tween2.finished
	canvas.queue_free()
