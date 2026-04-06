class_name RespawnManagerClass
extends Node
## Handles player death → fade → degradation → respawn in town flow.

const TOWN_SCENE_PATH: String = "res://scenes/town/Town.tscn"
const DEATH_WAIT: float = 1.0
const FADE_DURATION: float = 0.5

var _fade_overlay: ColorRect = null


func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	_create_fade_overlay()


func _create_fade_overlay() -> void:
	_fade_overlay = ColorRect.new()
	_fade_overlay.color = Color(0, 0, 0, 0)
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_overlay.anchors_preset = Control.PRESET_FULL_RECT
	# Will be added to scene tree when needed via CanvasLayer
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100  # On top of everything
	canvas.add_child(_fade_overlay)
	add_child(canvas)


func _on_player_died(_position: Vector3) -> void:
	_run_respawn_sequence()


func _run_respawn_sequence() -> void:
	# 1. Wait for death animation
	await get_tree().create_timer(DEATH_WAIT).timeout

	# 2. Fade to black
	await _fade(0.0, 1.0, FADE_DURATION)

	# 3. Trigger item degradation (handled by InventoryComponent in Epic 4)
	EventBus.item_degradation_triggered.emit()

	# 4. Load town scene
	GameManager.change_scene_to(TOWN_SCENE_PATH)
	# Wait a frame for scene to load
	await get_tree().process_frame
	await get_tree().process_frame

	# 5. Find player and respawn point, reset health/compute
	var player: Player = _find_player()
	if player:
		var spawn_point: Marker3D = _find_respawn_point()
		if spawn_point:
			player.global_position = spawn_point.global_position
		player.health_component.reset()
		player.compute_component.reset()
		# Re-enable player systems (DeathState disabled them)
		player.set_physics_process(true)
		player.set_process_unhandled_input(true)
		player.collision_layer = 1
		player.collision_mask = 138
		var idle_state: State = player.state_machine.get_node_or_null("IdleState") as State
		if idle_state:
			player.state_machine.force_transition_to(idle_state)

	GameManager.set_state(GameManager.GameState.PLAYING)

	# 7. Fade back in
	await _fade(1.0, 0.0, FADE_DURATION)


func _fade(from: float, to: float, duration: float) -> void:
	_fade_overlay.color.a = from
	var tween: Tween = create_tween()
	tween.tween_property(_fade_overlay, "color:a", to, duration)
	await tween.finished


func _find_player() -> Player:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		return nodes[0] as Player
	# Fallback: search scene tree
	for node: Node in get_tree().current_scene.get_children():
		if node is Player:
			return node as Player
	return null


func _find_respawn_point() -> Marker3D:
	var markers: Array[Node] = get_tree().get_nodes_in_group(&"respawn_point")
	if markers.size() > 0:
		return markers[0] as Marker3D
	# Fallback: find by name
	return get_tree().current_scene.find_child("RespawnPoint", true, false) as Marker3D
