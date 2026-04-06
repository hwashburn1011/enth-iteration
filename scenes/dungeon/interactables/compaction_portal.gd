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
	if body is Player:
		_player_in_range = true
		_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_player_in_range = false
		_label.visible = false


func _activate_portal() -> void:
	set_process_unhandled_input(false)
	EventBus.portal_used.emit()

	# White flash warp effect
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(1, 1, 1, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(overlay)
	add_child(canvas)

	# Flash to white
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, FLASH_DURATION)
	await tween.finished

	# Load town
	GameManager.change_scene_to(TOWN_SCENE_PATH)
	await get_tree().process_frame
	await get_tree().process_frame

	# Find player and position at portal return point
	var player: Player = _find_player()
	if player:
		var return_point: Marker3D = _find_return_point()
		if return_point:
			player.global_position = return_point.global_position
		player.health_component.reset()
		player.compute_component.reset()
		GameManager.set_state(GameManager.GameState.PLAYING)

	EventBus.returned_to_town.emit()

	# Fade white out
	var tween2: Tween = create_tween()
	tween2.tween_property(overlay, "color:a", 0.0, FLASH_DURATION)
	await tween2.finished
	canvas.queue_free()


func _find_player() -> Player:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		return nodes[0] as Player
	return null


func _find_return_point() -> Marker3D:
	var markers: Array[Node] = get_tree().get_nodes_in_group(&"portal_return_point")
	if markers.size() > 0:
		return markers[0] as Marker3D
	return get_tree().current_scene.find_child("PortalReturnPoint", true, false) as Marker3D
