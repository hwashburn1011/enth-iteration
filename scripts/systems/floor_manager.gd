class_name FloorManager
extends Node
## Loads rooms in sequence, handles transitions, and tracks floor progress.

signal floor_completed(floor_number: int)

@export var floor_data: Resource

var current_room_index: int = 0
var current_room: Node3D = null
## Optional callable to configure rooms after instantiation: func(room, index)
var room_configurator: Callable = Callable()

const FADE_DURATION: float = 0.3

var _fade_overlay: ColorRect = null
var _dungeon_root: Node = null


func _ready() -> void:
	_dungeon_root = get_parent()
	_create_fade_overlay()


func load_floor(data: Resource) -> void:
	floor_data = data
	current_room_index = 0
	load_room(0)


func load_room(index: int) -> void:
	if floor_data == null or index >= floor_data.room_sequence.size():
		push_error("FloorManager: invalid room index %d" % index)
		return
	_transition_to_room(index)


func _transition_to_room(index: int) -> void:
	# Fade out
	await _fade(0.0, 1.0, FADE_DURATION)

	# Free current room
	if current_room:
		current_room.queue_free()
		current_room = null
		await get_tree().process_frame

	# Instantiate new room
	var room_scene: PackedScene = floor_data.room_sequence[index]
	current_room = room_scene.instantiate() as Node3D
	_dungeon_root.add_child(current_room)

	# Apply per-floor room configuration if set
	if room_configurator.is_valid():
		room_configurator.call(current_room, index)

	# Move player to entry point
	var player: CharacterBody3D = _find_player()
	if player and current_room.has_method(&"get_entry_point"):
		player.global_position = current_room.get_entry_point()

	# Connect exit signal
	if current_room.has_signal(&"player_at_exit"):
		current_room.player_at_exit.connect(_on_room_exit)

	# Start combat if applicable
	if current_room.has_method(&"start_encounter"):
		current_room.start_encounter()

	current_room_index = index

	# Update HUD room indicator
	_update_room_indicator()

	# Fade in
	await _fade(1.0, 0.0, FADE_DURATION)

	# Show room name briefly
	_show_room_name()
	# Brief environmental light pulse on room entry
	_pulse_environment_light()


func _on_room_exit() -> void:
	var next_index: int = current_room_index + 1
	if next_index < floor_data.room_sequence.size():
		load_room(next_index)
	else:
		# Floor complete
		floor_completed.emit(floor_data.floor_number)
		EventBus.portal_reached.emit(StringName("floor_%d_complete" % floor_data.floor_number))


func _update_room_indicator() -> void:
	if floor_data == null:
		return
	# Find HUD in scene tree and update room indicator
	for node: Node in get_tree().current_scene.get_children():
		if node.has_method(&"update_room_indicator"):
			var floor_name: String = floor_data.floor_name if floor_data.get(&"floor_name") else "Floor %d" % floor_data.floor_number
			node.update_room_indicator(current_room_index, floor_data.room_sequence.size(), floor_name)
			return


func _find_player() -> CharacterBody3D:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		return nodes[0] as CharacterBody3D
	return null


func _create_fade_overlay() -> void:
	_fade_overlay = ColorRect.new()
	_fade_overlay.color = Color(0, 0, 0, 0)
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 99
	canvas.add_child(_fade_overlay)
	add_child(canvas)


func _show_room_name() -> void:
	if current_room == null:
		return
	var room_name: String = ""
	if current_room.get(&"room_name") and not (current_room.room_name as String).is_empty():
		room_name = current_room.room_name
	elif current_room.get(&"room_type"):
		room_name = (current_room.room_type as String).capitalize()
	else:
		return
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 85
	var label: Label = Label.new()
	label.text = room_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	label.offset_left = -200
	label.offset_right = 200
	label.offset_top = 60
	label.offset_bottom = 100
	label.add_theme_font_size_override(&"font_size", 24)
	label.add_theme_color_override(&"font_color", Color(0.3, 0.8, 0.75, 0.0))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	_dungeon_root.add_child(canvas)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "theme_override_colors/font_color:a", 0.8, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(label, "theme_override_colors/font_color:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)


func _pulse_environment_light() -> void:
	## Brief ambient light pulse when entering a new room
	var world_env: WorldEnvironment = null
	for child: Node in _dungeon_root.get_children():
		if child is WorldEnvironment:
			world_env = child as WorldEnvironment
			break
	if world_env == null or world_env.environment == null:
		return
	var env: Environment = world_env.environment
	var original_energy: float = env.ambient_light_energy
	var tween: Tween = create_tween()
	tween.tween_property(env, "ambient_light_energy", original_energy * 1.6, 0.15)
	tween.tween_property(env, "ambient_light_energy", original_energy, 0.4)


func _fade(from: float, to: float, duration: float) -> void:
	_fade_overlay.color.a = from
	var tween: Tween = create_tween()
	tween.tween_property(_fade_overlay, "color:a", to, duration)
	await tween.finished
