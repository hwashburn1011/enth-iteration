class_name DialoguePanel
extends CanvasLayer
## Bottom-screen dialogue panel with typewriter effect. Works while paused.

signal dialogue_finished

const CHARS_PER_SECOND: float = 30.0
const PORTRAIT_CROSSFADE: float = 0.15

var dialogue_data: Array[Resource] = []
## Portrait dictionary from current speaker NPC: expression name -> Texture2D
var speaker_portraits: Dictionary = {}
## NPC id for affinity-based line filtering
var speaker_npc_id: String = ""

var _current_index: int = 0
var _typing: bool = false
var _visible_chars: int = 0
var _full_text: String = ""
var _char_timer: float = 0.0
var _continue_label: Label = null
var _placeholder_label: Label = null

@onready var _panel: PanelContainer = %DialoguePanel
@onready var _portrait_rect: TextureRect = %PortraitRect
@onready var _name_label: Label = %NameLabel
@onready var _dialogue_label: RichTextLabel = %DialogueLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	_panel.visible = false
	_apply_dialogue_theme()


func _apply_dialogue_theme() -> void:
	# Sci-fi styled panel
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.06, 0.12, 0.92)
	panel_style.border_color = Color(0.15, 0.45, 0.55, 0.8)
	panel_style.set_border_width_all(2)
	panel_style.border_width_top = 3
	panel_style.set_corner_radius_all(4)
	panel_style.set_content_margin_all(16)
	_panel.add_theme_stylebox_override(&"panel", panel_style)

	# Name label — accent color
	_name_label.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	_name_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
	_name_label.add_theme_constant_override(&"outline_size", 3)
	_name_label.add_theme_font_size_override(&"font_size", 22)

	# Dialogue text — light color
	_dialogue_label.add_theme_color_override(&"default_color", Color(0.85, 0.87, 0.92))
	_dialogue_label.add_theme_font_size_override(&"normal_font_size", 16)

	# Placeholder portrait: bordered initial letter when no texture is set
	_placeholder_label = Label.new()
	_placeholder_label.name = "PlaceholderInitial"
	_placeholder_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_placeholder_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_placeholder_label.add_theme_font_size_override(&"font_size", 64)
	_placeholder_label.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	_placeholder_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	_placeholder_label.add_theme_constant_override(&"outline_size", 4)
	_placeholder_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_rect.add_child(_placeholder_label)
	# Frame the portrait rect so the initial sits in a styled box
	var portrait_style: StyleBoxFlat = StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.08, 0.12, 0.18, 0.85)
	portrait_style.border_color = Color(0.15, 0.45, 0.55, 0.7)
	portrait_style.set_border_width_all(2)
	portrait_style.set_corner_radius_all(6)
	# TextureRect doesn't accept stylebox; wrap via background ColorRect
	var bg_frame: PanelContainer = PanelContainer.new()
	bg_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_frame.add_theme_stylebox_override(&"panel", portrait_style)
	bg_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_frame.show_behind_parent = true
	_portrait_rect.add_child(bg_frame)

	# Continue indicator — blinks when text is fully typed
	_continue_label = Label.new()
	_continue_label.name = "ContinueHint"
	_continue_label.text = "▼ Press [E] or [LMB] to continue"
	_continue_label.add_theme_font_size_override(&"font_size", 12)
	_continue_label.add_theme_color_override(&"font_color", Color(0.55, 0.85, 0.95))
	_continue_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.6))
	_continue_label.add_theme_constant_override(&"outline_size", 2)
	_continue_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_continue_label.offset_left = -240
	_continue_label.offset_top = -22
	_continue_label.offset_right = -16
	_continue_label.offset_bottom = -4
	_continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_continue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_continue_label.visible = false
	_panel.add_child(_continue_label)


func _process(delta: float) -> void:
	if _typing:
		_char_timer += delta
		var chars_to_show: int = int(_char_timer * CHARS_PER_SECOND)
		if chars_to_show > _visible_chars:
			_visible_chars = chars_to_show
			_dialogue_label.visible_characters = mini(_visible_chars, _full_text.length())
			if _visible_chars >= _full_text.length():
				_typing = false
				_show_continue_hint()
	elif _continue_label and _continue_label.visible:
		# Pulse the continue hint
		var t: float = Time.get_ticks_msec() * 0.004
		_continue_label.modulate.a = 0.55 + 0.45 * (sin(t) * 0.5 + 0.5)


func _show_continue_hint() -> void:
	if _continue_label:
		_continue_label.visible = true
		_continue_label.modulate.a = 1.0


func _hide_continue_hint() -> void:
	if _continue_label:
		_continue_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"attack_primary"):
		_advance()
		get_viewport().set_input_as_handled()


func start_dialogue(data: Array[Resource]) -> void:
	# Filter lines by affinity requirement
	var affinity: int = GameManager.get_affinity(speaker_npc_id) if not speaker_npc_id.is_empty() else 0
	dialogue_data = []
	for line: Resource in data:
		if line.min_affinity <= affinity:
			dialogue_data.append(line)
	if dialogue_data.is_empty():
		# Fallback: show all lines with min_affinity 0, or first line if none qualify
		for line: Resource in data:
			if line.min_affinity == 0:
				dialogue_data.append(line)
		if dialogue_data.is_empty() and data.size() > 0:
			dialogue_data.append(data[0])
		if dialogue_data.is_empty():
			return
	_current_index = 0
	_panel.visible = true
	# Cinematic camera zoom (before pause — process_mode allows tween during pause)
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		var camera: Camera3D = players[0].get_viewport().get_camera_3d()
		if camera and camera.has_method(&"zoom_to"):
			camera.zoom_to(11.0, 0.5)
	get_tree().paused = true
	GameManager.set_state(GameManager.GameState.DIALOGUE)
	# Emit the actual npc_id rather than &"" so listeners that filter by
	# speaker (story_room recruit gating, T37 QuestManager objective
	# filters keyed on dialogue_started + npc_id) actually receive the
	# right id for NPCBase-derived NPCs that route through this panel.
	EventBus.dialogue_started.emit(StringName(speaker_npc_id))
	_display_line(dialogue_data[0])


func _display_line(line: Resource) -> void:
	_name_label.text = line.speaker_name
	_hide_continue_hint()

	# Portrait lookup: line.portrait > speaker_portraits[expression] > speaker_portraits["default"]
	var new_portrait: Texture2D = null
	if line.portrait:
		new_portrait = line.portrait
	elif speaker_portraits.has(line.expression):
		new_portrait = speaker_portraits[line.expression] as Texture2D
	elif speaker_portraits.has("default"):
		new_portrait = speaker_portraits["default"] as Texture2D

	if new_portrait:
		_crossfade_portrait(new_portrait)
		_portrait_rect.texture = new_portrait
		_portrait_rect.visible = true
		if _placeholder_label:
			_placeholder_label.visible = false
	else:
		# Show placeholder initial of speaker name
		_portrait_rect.visible = true
		_portrait_rect.texture = null
		if _placeholder_label:
			var initial: String = line.speaker_name.substr(0, 1).to_upper() if not line.speaker_name.is_empty() else "?"
			_placeholder_label.text = initial
			_placeholder_label.visible = true

	_full_text = line.text
	_dialogue_label.text = _full_text
	_dialogue_label.visible_characters = 0
	_visible_chars = 0
	_char_timer = 0.0
	_typing = true


func _advance() -> void:
	if _typing:
		_typing = false
		_dialogue_label.visible_characters = -1
		_show_continue_hint()
		return

	_current_index += 1
	if _current_index < dialogue_data.size():
		_display_line(dialogue_data[_current_index])
	else:
		_close()


func _close() -> void:
	_panel.visible = false
	speaker_portraits = {}
	speaker_npc_id = ""
	get_tree().paused = false
	GameManager.set_state(GameManager.GameState.PLAYING)
	# Reset camera zoom
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		var camera: Camera3D = players[0].get_viewport().get_camera_3d()
		if camera and camera.has_method(&"zoom_reset"):
			camera.zoom_reset(0.5)
	EventBus.dialogue_ended.emit()
	dialogue_finished.emit()


func _crossfade_portrait(new_texture: Texture2D) -> void:
	if _portrait_rect.texture == new_texture:
		return
	# Crossfade: fade out, swap, fade in
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_portrait_rect, "modulate:a", 0.0, PORTRAIT_CROSSFADE)
	tween.tween_callback(func() -> void: _portrait_rect.texture = new_texture)
	tween.tween_property(_portrait_rect, "modulate:a", 1.0, PORTRAIT_CROSSFADE)
