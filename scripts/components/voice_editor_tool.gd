class_name VoiceEditorTool
extends CanvasLayer

## Voice Editor Tool (Epic 48 task 36).
##
## In-engine debug tool for tuning voice grunts:
##   - Pick a character + emotion from dropdowns
##   - Adjust pitch_offset, formant_shift, speed_multiplier sliders
##   - Preview button plays the grunt with current settings
##   - Save button writes tuning back to a debug override dict
##
## Toggled via Ctrl+Shift+V in dev builds. Hidden in release.

signal grunt_previewed(character: StringName, emotion: StringName, pitch: float)
signal tuning_saved(character: StringName, tuning: Dictionary)

@export var debug_only: bool = true

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _character_dropdown: OptionButton
var _emotion_dropdown: OptionButton
var _pitch_slider: HSlider
var _pitch_label: Label
var _formant_slider: HSlider
var _formant_label: Label
var _speed_slider: HSlider
var _speed_label: Label
var _preview_button: Button
var _save_button: Button
var _description_label: Label
var _tuning_overrides: Dictionary = {}


func _ready() -> void:
	layer = 90
	_build_ui()
	visible = false
	if debug_only and not OS.has_feature("debug"):
		queue_free()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0, 0, 0, 0.6)
	_root.add_child(_bg_dim)

	_panel = Panel.new()
	_panel.size = Vector2(580, 540)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.offset_left = -290
	_panel.offset_top = -270
	_root.add_child(_panel)

	# Title
	var title := Label.new()
	title.position = Vector2(20, 18)
	title.size = Vector2(540, 32)
	title.text = "VOICE EDITOR (DEBUG)"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	# Character dropdown
	var char_label := Label.new()
	char_label.position = Vector2(20, 70)
	char_label.size = Vector2(140, 28)
	char_label.text = "Character:"
	char_label.add_theme_font_size_override("font_size", 14)
	char_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_panel.add_child(char_label)

	_character_dropdown = OptionButton.new()
	_character_dropdown.position = Vector2(160, 70)
	_character_dropdown.size = Vector2(400, 28)
	for char_id in VoiceGruntsDatabase.CHARACTERS:
		_character_dropdown.add_item(String(char_id).capitalize())
	_character_dropdown.item_selected.connect(_on_character_selected)
	_panel.add_child(_character_dropdown)

	# Emotion dropdown
	var emo_label := Label.new()
	emo_label.position = Vector2(20, 110)
	emo_label.size = Vector2(140, 28)
	emo_label.text = "Emotion:"
	emo_label.add_theme_font_size_override("font_size", 14)
	emo_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_panel.add_child(emo_label)

	_emotion_dropdown = OptionButton.new()
	_emotion_dropdown.position = Vector2(160, 110)
	_emotion_dropdown.size = Vector2(400, 28)
	for emotion in VoiceGruntsDatabase.EMOTIONS:
		_emotion_dropdown.add_item(String(emotion).capitalize())
	_emotion_dropdown.item_selected.connect(_on_emotion_selected)
	_panel.add_child(_emotion_dropdown)

	# Pitch slider
	_pitch_label = Label.new()
	_pitch_label.position = Vector2(20, 160)
	_pitch_label.size = Vector2(540, 24)
	_pitch_label.text = "Pitch offset: 0 semitones"
	_pitch_label.add_theme_font_size_override("font_size", 14)
	_pitch_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_panel.add_child(_pitch_label)

	_pitch_slider = HSlider.new()
	_pitch_slider.position = Vector2(20, 188)
	_pitch_slider.size = Vector2(540, 28)
	_pitch_slider.min_value = -12
	_pitch_slider.max_value = 12
	_pitch_slider.step = 1
	_pitch_slider.value_changed.connect(_on_pitch_changed)
	_panel.add_child(_pitch_slider)

	# Formant slider
	_formant_label = Label.new()
	_formant_label.position = Vector2(20, 226)
	_formant_label.size = Vector2(540, 24)
	_formant_label.text = "Formant shift: 0.00"
	_formant_label.add_theme_font_size_override("font_size", 14)
	_formant_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_panel.add_child(_formant_label)

	_formant_slider = HSlider.new()
	_formant_slider.position = Vector2(20, 254)
	_formant_slider.size = Vector2(540, 28)
	_formant_slider.min_value = -0.5
	_formant_slider.max_value = 0.5
	_formant_slider.step = 0.01
	_formant_slider.value_changed.connect(_on_formant_changed)
	_panel.add_child(_formant_slider)

	# Speed slider
	_speed_label = Label.new()
	_speed_label.position = Vector2(20, 292)
	_speed_label.size = Vector2(540, 24)
	_speed_label.text = "Speed multiplier: 1.00x"
	_speed_label.add_theme_font_size_override("font_size", 14)
	_speed_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_panel.add_child(_speed_label)

	_speed_slider = HSlider.new()
	_speed_slider.position = Vector2(20, 320)
	_speed_slider.size = Vector2(540, 28)
	_speed_slider.min_value = 0.5
	_speed_slider.max_value = 2.0
	_speed_slider.step = 0.05
	_speed_slider.value_changed.connect(_on_speed_changed)
	_panel.add_child(_speed_slider)

	# Description label
	_description_label = Label.new()
	_description_label.position = Vector2(20, 360)
	_description_label.size = Vector2(540, 60)
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_description_label.add_theme_font_size_override("font_size", 13)
	_description_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92))
	_panel.add_child(_description_label)

	# Preview + Save buttons
	_preview_button = Button.new()
	_preview_button.text = "Preview Grunt"
	_preview_button.position = Vector2(80, 440)
	_preview_button.size = Vector2(180, 36)
	_preview_button.pressed.connect(_on_preview_pressed)
	_panel.add_child(_preview_button)

	_save_button = Button.new()
	_save_button.text = "Save Tuning"
	_save_button.position = Vector2(320, 440)
	_save_button.size = Vector2(180, 36)
	_save_button.pressed.connect(_on_save_pressed)
	_panel.add_child(_save_button)

	# Close
	var close := Button.new()
	close.text = "Close"
	close.position = Vector2(440, 490)
	close.size = Vector2(120, 32)
	close.pressed.connect(_on_close)
	_panel.add_child(close)

	# Initial population
	if VoiceGruntsDatabase.CHARACTERS.size() > 0:
		_on_character_selected(0)
		_on_emotion_selected(0)


func _on_character_selected(idx: int) -> void:
	var char_id: StringName = VoiceGruntsDatabase.CHARACTERS[idx]
	var profile: Dictionary = VoiceGruntsDatabase.get_character_profile(char_id)
	_pitch_slider.value = float(profile.get("pitch_offset", 0))
	_formant_slider.value = float(profile.get("formant_shift", 0.0))
	_speed_slider.value = float(profile.get("speed_multiplier", 1.0))
	_description_label.text = String(profile.get("description", ""))
	_update_labels()


func _on_emotion_selected(idx: int) -> void:
	# Adjust pitch label by emotion delta
	_update_labels()


func _on_pitch_changed(value: float) -> void:
	_update_labels()


func _on_formant_changed(value: float) -> void:
	_update_labels()


func _on_speed_changed(value: float) -> void:
	_update_labels()


func _update_labels() -> void:
	_pitch_label.text = "Pitch offset: %d semitones" % int(_pitch_slider.value)
	_formant_label.text = "Formant shift: %.2f" % _formant_slider.value
	_speed_label.text = "Speed multiplier: %.2fx" % _speed_slider.value


func _on_preview_pressed() -> void:
	var char_id: StringName = VoiceGruntsDatabase.CHARACTERS[_character_dropdown.selected]
	var emotion: StringName = VoiceGruntsDatabase.EMOTIONS[_emotion_dropdown.selected]
	# Play via AudioManager with override pitch
	if has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		if am.has_method("play_voice_grunt"):
			am.call("play_voice_grunt", char_id, emotion, _pitch_slider.value)
	grunt_previewed.emit(char_id, emotion, _pitch_slider.value)


func _on_save_pressed() -> void:
	var char_id: StringName = VoiceGruntsDatabase.CHARACTERS[_character_dropdown.selected]
	_tuning_overrides[char_id] = {
		"pitch_offset": int(_pitch_slider.value),
		"formant_shift": _formant_slider.value,
		"speed_multiplier": _speed_slider.value,
	}
	tuning_saved.emit(char_id, _tuning_overrides[char_id])
	# Persist to disk for next session
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_data"):
			sm.call("set_data", &"voice_tuning_overrides", _tuning_overrides)


func _on_close() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	# Toggle with Ctrl+Shift+V in dev builds
	if event is InputEventKey:
		if event.pressed and event.ctrl_pressed and event.shift_pressed and event.physical_keycode == KEY_V:
			visible = not visible
		elif visible and event.is_action_pressed("ui_cancel"):
			_on_close()
