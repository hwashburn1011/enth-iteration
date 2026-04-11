class_name ClassInfoScreen
extends CanvasLayer

## Class Info Screen (Epic 31 tasks 30, 31, 42).
##
## Three-tab info panel for the active class:
##   - Tab 1: STATS — base stats + bonus deltas vs other classes
##   - Tab 2: ABILITIES — signature, ultimate, passives with cooldowns
##   - Tab 3: LORE — class display name, role, description, lore paragraph
##
## Built entirely from Control nodes — ships with no theme files. Pulls all
## content from ClassSystemDatabase. The portrait image is loaded from the
## Blender-rendered class_<id>_portrait.png file.
##
## Hook:
##   var screen := ClassInfoScreen.new()
##   add_child(screen)
##   screen.show_class(&"daemon")

signal screen_opened(class_id: StringName)
signal tab_changed(tab_index: int)
signal screen_closed

enum Tab { STATS, ABILITIES, LORE }

@export var force_visible: bool = false

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _portrait: TextureRect
var _name_label: Label
var _role_label: Label
var _tab_buttons: Array[Button] = []
var _content_root: Control
var _current_class_id: StringName = &""
var _current_tab: int = 0


func _ready() -> void:
	layer = 80
	_build_ui()
	visible = force_visible


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0, 0, 0, 0.7)
	_root.add_child(_bg_dim)

	_panel = Panel.new()
	_panel.size = Vector2(820, 540)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -410
	_panel.offset_top = -270
	_panel.offset_right = 410
	_panel.offset_bottom = 270
	_root.add_child(_panel)

	# Portrait (left side)
	_portrait = TextureRect.new()
	_portrait.position = Vector2(20, 20)
	_portrait.size = Vector2(300, 400)
	_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_panel.add_child(_portrait)

	_name_label = Label.new()
	_name_label.position = Vector2(20, 425)
	_name_label.size = Vector2(300, 40)
	_name_label.add_theme_font_size_override("font_size", 32)
	_name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_name_label)

	_role_label = Label.new()
	_role_label.position = Vector2(20, 470)
	_role_label.size = Vector2(300, 24)
	_role_label.add_theme_font_size_override("font_size", 16)
	_role_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	_role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_role_label)

	# Tab buttons (top right)
	var tab_names: Array[String] = ["Stats", "Abilities", "Lore"]
	for i in range(3):
		var btn := Button.new()
		btn.text = tab_names[i]
		btn.position = Vector2(340 + i * 140, 20)
		btn.size = Vector2(135, 32)
		btn.pressed.connect(_on_tab_pressed.bind(i))
		_panel.add_child(btn)
		_tab_buttons.append(btn)

	# Content root (right side)
	_content_root = Control.new()
	_content_root.position = Vector2(340, 64)
	_content_root.size = Vector2(460, 430)
	_panel.add_child(_content_root)

	# Close button
	var close := Button.new()
	close.text = "Close [Esc]"
	close.position = Vector2(680, 490)
	close.size = Vector2(120, 36)
	close.pressed.connect(_on_close)
	_panel.add_child(close)


func show_class(class_id: StringName) -> void:
	if not ClassSystemDatabase.is_valid_class(class_id):
		return
	_current_class_id = class_id
	visible = true
	_load_portrait()
	var data: Dictionary = ClassSystemDatabase.get_class(class_id)
	_name_label.text = data.get("display_name", "")
	_role_label.text = data.get("role", "")
	_set_tab(_current_tab)
	screen_opened.emit(class_id)


func _load_portrait() -> void:
	var data: Dictionary = ClassSystemDatabase.get_class(_current_class_id)
	var path: String = data.get("portrait_path", "")
	if path != "" and ResourceLoader.exists(path):
		var tex: Texture2D = load(path) as Texture2D
		if tex != null:
			_portrait.texture = tex


func _on_tab_pressed(tab: int) -> void:
	_set_tab(tab)


func _set_tab(tab: int) -> void:
	_current_tab = tab
	for child in _content_root.get_children():
		child.queue_free()
	match tab:
		Tab.STATS: _build_stats_tab()
		Tab.ABILITIES: _build_abilities_tab()
		Tab.LORE: _build_lore_tab()
	tab_changed.emit(tab)


func _build_stats_tab() -> void:
	var data: Dictionary = ClassSystemDatabase.get_class(_current_class_id)
	var stats: Dictionary = data.get("base_stats", {})
	var y: int = 0
	for stat_name in ["hp", "mp", "atk", "def", "speed", "crit"]:
		var label := Label.new()
		label.position = Vector2(0, y)
		label.size = Vector2(220, 28)
		label.text = "%s" % stat_name.to_upper()
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
		_content_root.add_child(label)

		var value := Label.new()
		value.position = Vector2(220, y)
		value.size = Vector2(220, 28)
		var raw = stats.get(stat_name, 0)
		value.text = str(raw)
		value.add_theme_font_size_override("font_size", 18)
		value.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
		_content_root.add_child(value)
		y += 36

	# Damage type bonuses
	var bonuses: Dictionary = data.get("damage_type_bonuses", {})
	if not bonuses.is_empty():
		var header := Label.new()
		header.position = Vector2(0, y + 16)
		header.size = Vector2(440, 24)
		header.text = "Damage Type Bonuses"
		header.add_theme_font_size_override("font_size", 18)
		header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
		_content_root.add_child(header)
		y += 48
		for dt in bonuses.keys():
			var bonus_label := Label.new()
			bonus_label.position = Vector2(0, y)
			bonus_label.size = Vector2(440, 24)
			bonus_label.text = "  %s × %.2f" % [String(dt), float(bonuses[dt])]
			bonus_label.add_theme_font_size_override("font_size", 15)
			bonus_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
			_content_root.add_child(bonus_label)
			y += 26


func _build_abilities_tab() -> void:
	var data: Dictionary = ClassSystemDatabase.get_class(_current_class_id)
	var sig: StringName = data.get("signature_ability", &"")
	var ult: StringName = data.get("ultimate_ability", &"")
	var passives: Array = data.get("passives", [])
	var y: int = 0

	# Signature
	_add_ability_row("Signature: %s" % String(sig).capitalize(),
		"Cooldown: %.1fs" % ClassSystemDatabase.get_cooldown(_current_class_id, sig),
		Color(1.0, 0.85, 0.35), y)
	y += 60

	# Ultimate
	_add_ability_row("Ultimate: %s" % String(ult).capitalize(),
		"Cooldown: %.1fs" % ClassSystemDatabase.get_cooldown(_current_class_id, ult),
		Color(1.0, 0.45, 0.35), y)
	y += 60

	# Passives header
	var passive_header := Label.new()
	passive_header.position = Vector2(0, y)
	passive_header.size = Vector2(440, 24)
	passive_header.text = "Passives"
	passive_header.add_theme_font_size_override("font_size", 18)
	passive_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_content_root.add_child(passive_header)
	y += 32

	for p in passives:
		var p_label := Label.new()
		p_label.position = Vector2(0, y)
		p_label.size = Vector2(440, 38)
		p_label.text = "• %s" % String(p.get("label", ""))
		p_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		p_label.add_theme_font_size_override("font_size", 14)
		p_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		_content_root.add_child(p_label)
		y += 42


func _add_ability_row(title: String, sub: String, color: Color, y: int) -> void:
	var t := Label.new()
	t.position = Vector2(0, y)
	t.size = Vector2(440, 26)
	t.text = title
	t.add_theme_font_size_override("font_size", 18)
	t.add_theme_color_override("font_color", color)
	_content_root.add_child(t)
	var s := Label.new()
	s.position = Vector2(0, y + 26)
	s.size = Vector2(440, 22)
	s.text = sub
	s.add_theme_font_size_override("font_size", 14)
	s.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92))
	_content_root.add_child(s)


func _build_lore_tab() -> void:
	var data: Dictionary = ClassSystemDatabase.get_class(_current_class_id)
	var description := Label.new()
	description.position = Vector2(0, 0)
	description.size = Vector2(440, 60)
	description.text = data.get("description", "")
	description.autowrap_mode = TextServer.AUTOWRAP_WORD
	description.add_theme_font_size_override("font_size", 16)
	description.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_content_root.add_child(description)

	var lore := Label.new()
	lore.position = Vector2(0, 80)
	lore.size = Vector2(440, 340)
	lore.text = data.get("lore", "")
	lore.autowrap_mode = TextServer.AUTOWRAP_WORD
	lore.add_theme_font_size_override("font_size", 14)
	lore.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_content_root.add_child(lore)


func _on_close() -> void:
	visible = false
	screen_closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_close()
