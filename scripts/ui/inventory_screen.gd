class_name InventoryScreen
extends CanvasLayer
## Full inventory and equipment management screen. Pauses game while open.

var _player: CharacterBody3D = null
var _panel: Control = null
var _grid_cells: Array[Control] = []
var _equip_slots: Dictionary = {}  # slot_key -> Control
var _selected_item: Resource = null
var _tooltip: PanelContainer = null

const CELL_SIZE: int = 48
const RARITY_COLORS: Array[Color] = [
	Color(0.7, 0.7, 0.7),  # Common
	Color(0.3, 0.9, 0.3),  # Uncommon
	Color(0.3, 0.5, 1.0),  # Rare
	Color(1.0, 0.85, 0.1),  # Legendary
]


func _ready() -> void:
	layer = 55
	process_mode = Node.PROCESS_MODE_ALWAYS


func open(player: CharacterBody3D) -> void:
	_player = player
	get_tree().paused = true
	GameManager.set_state(GameManager.GameState.INVENTORY)
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if _panel == null:
		return
	if event.is_action_pressed(&"inventory") or event.is_action_pressed(&"pause"):
		close()
		get_viewport().set_input_as_handled()


func close() -> void:
	if _panel:
		_panel.queue_free()
		_panel = null
	if _tooltip:
		_tooltip.queue_free()
		_tooltip = null
	get_tree().paused = false
	GameManager.set_state(GameManager.GameState.PLAYING)
	queue_free()


func _build_ui() -> void:
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	# Background dim
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.02, 0.06, 0.7)
	_panel.add_child(bg)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_CENTER)
	hbox.offset_left = -540.0
	hbox.offset_top = -260.0
	hbox.offset_right = 540.0
	hbox.offset_bottom = 260.0
	hbox.add_theme_constant_override(&"separation", 16)

	# Sci-fi panel style for sections
	var section_style: StyleBoxFlat = StyleBoxFlat.new()
	section_style.bg_color = Color(0.06, 0.07, 0.14, 0.92)
	section_style.border_color = Color(0.15, 0.4, 0.5, 0.7)
	section_style.set_border_width_all(2)
	section_style.set_corner_radius_all(6)
	section_style.set_content_margin_all(12)

	# Left: Equipment
	var equip_panel: PanelContainer = PanelContainer.new()
	equip_panel.add_theme_stylebox_override(&"panel", section_style)
	var equip_vbox: VBoxContainer = VBoxContainer.new()
	var equip_title: Label = Label.new()
	equip_title.text = "Equipment"
	equip_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equip_title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	equip_title.add_theme_font_size_override(&"font_size", 20)
	equip_vbox.add_child(equip_title)
	_build_equipment_slots(equip_vbox)
	equip_panel.add_child(equip_vbox)
	hbox.add_child(equip_panel)

	# Right: Grid inventory
	var inv_panel: PanelContainer = PanelContainer.new()
	inv_panel.add_theme_stylebox_override(&"panel", section_style.duplicate())
	var inv_vbox: VBoxContainer = VBoxContainer.new()
	var inv_title: Label = Label.new()
	inv_title.text = "Inventory"
	inv_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inv_title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	inv_title.add_theme_font_size_override(&"font_size", 20)
	inv_vbox.add_child(inv_title)
	_build_grid(inv_vbox)
	inv_panel.add_child(inv_vbox)
	hbox.add_child(inv_panel)

	# Far right: Stats panel
	var stats_panel: CharacterStatsPanel = CharacterStatsPanel.new()
	stats_panel.custom_minimum_size = Vector2(280, 0)
	stats_panel.populate(_player)
	hbox.add_child(stats_panel)

	_panel.add_child(hbox)
	add_child(_panel)


func _build_equipment_slots(parent: VBoxContainer) -> void:
	var sections: Array[Array] = [
		["Modules", "module", 4],
		["Core", "core", 1],
		["Chips", "chip", 4],
		["Protocols", "protocol", 3],
	]
	for section: Array in sections:
		var label: Label = Label.new()
		label.text = section[0] as String
		parent.add_child(label)
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override(&"separation", 4)
		var count: int = section[2] as int
		for i: int in count:
			var slot: Button = Button.new()
			slot.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
			var slot_key: String = "%s_%d" % [section[1], i]
			var item: Resource = _get_equipped_item(section[1] as String, i)
			_style_grid_cell(slot, item != null)
			slot.text = ""
			if item:
				_add_item_icon(slot, item)
				slot.tooltip_text = item.item_name
			else:
				slot.tooltip_text = "Empty"
			slot.pressed.connect(_on_equip_slot_clicked.bind(section[1] as String, i))
			hbox.add_child(slot)
			_equip_slots[slot_key] = slot
		parent.add_child(hbox)


func _build_grid(parent: VBoxContainer) -> void:
	_grid_cells.clear()
	var grid_container: GridContainer = GridContainer.new()
	grid_container.columns = _player.inventory_component.grid_width
	grid_container.add_theme_constant_override(&"h_separation", 3)
	grid_container.add_theme_constant_override(&"v_separation", 3)
	for y: int in _player.inventory_component.grid_height:
		for x: int in _player.inventory_component.grid_width:
			var cell: Button = Button.new()
			cell.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
			var item: Resource = _player.inventory_component.get_item_at(Vector2i(x, y))
			cell.text = ""
			_style_grid_cell(cell, item != null)
			if item:
				_add_item_icon(cell, item)
				cell.tooltip_text = item.item_name
			cell.pressed.connect(_on_grid_cell_clicked.bind(x, y))
			grid_container.add_child(cell)
			_grid_cells.append(cell)
	parent.add_child(grid_container)


const ITEM_TYPE_GLYPHS: Dictionary = {
	"chip": "◆",
	"module": "▲",
	"core": "●",
	"protocol": "■",
	"weapon": "✦",
	"prompt": "★",
}


func _add_item_icon(cell: Button, item: Resource) -> void:
	## Center a rarity-colored glyph in the cell to represent the item visually.
	var rarity_col: Color = RARITY_COLORS[clampi(item.rarity, 0, 3)]
	# Background rarity tint behind the icon
	var tint: ColorRect = ColorRect.new()
	tint.color = Color(rarity_col.r, rarity_col.g, rarity_col.b, 0.18)
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint.offset_left = 4
	tint.offset_top = 4
	tint.offset_right = -4
	tint.offset_bottom = -4
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(tint)
	# Glyph icon centered
	var glyph: Label = Label.new()
	var item_type: String = str(item.get(&"item_type")) if item.get(&"item_type") else ""
	glyph.text = ITEM_TYPE_GLYPHS.get(item_type, "◇")
	glyph.add_theme_font_size_override(&"font_size", 28)
	glyph.add_theme_color_override(&"font_color", rarity_col)
	glyph.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
	glyph.add_theme_constant_override(&"outline_size", 3)
	glyph.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(glyph)


func _style_grid_cell(cell: Button, has_item: bool) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.1, 0.16, 0.85) if has_item else Color(0.04, 0.05, 0.1, 0.7)
	normal.border_color = Color(0.2, 0.45, 0.55, 0.6) if has_item else Color(0.1, 0.2, 0.28, 0.4)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = Color(0.12, 0.18, 0.28, 0.95)
	hover.border_color = Color(0.3, 0.7, 0.8, 0.9)
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(3)
	var pressed: StyleBoxFlat = StyleBoxFlat.new()
	pressed.bg_color = Color(0.08, 0.2, 0.3, 1.0)
	pressed.border_color = Color(0.4, 0.85, 0.95, 1.0)
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(3)
	cell.add_theme_stylebox_override(&"normal", normal)
	cell.add_theme_stylebox_override(&"hover", hover)
	cell.add_theme_stylebox_override(&"pressed", pressed)
	cell.add_theme_font_size_override(&"font_size", 14)


func _on_grid_cell_clicked(x: int, y: int) -> void:
	var item: Resource = _player.inventory_component.get_item_at(Vector2i(x, y))
	if item:
		_selected_item = item
		_show_tooltip(item)


func _on_equip_slot_clicked(item_type: String, slot_index: int) -> void:
	var removed: Resource = _player.equipment_component.unequip(item_type, slot_index)
	if removed:
		_player.inventory_component.add_item(removed)
	_rebuild()


func _show_tooltip(item: Resource) -> void:
	if _tooltip:
		_tooltip.queue_free()
	_tooltip = PanelContainer.new()
	_tooltip.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_tooltip.offset_left = -260.0
	_tooltip.offset_top = -120.0
	_tooltip.offset_right = -16.0
	_tooltip.offset_bottom = 120.0
	# Sci-fi panel style for tooltip
	var tooltip_style: StyleBoxFlat = StyleBoxFlat.new()
	tooltip_style.bg_color = Color(0.05, 0.06, 0.12, 0.95)
	tooltip_style.border_color = RARITY_COLORS[clampi(item.rarity, 0, 3)]
	tooltip_style.set_border_width_all(2)
	tooltip_style.set_corner_radius_all(5)
	tooltip_style.set_content_margin_all(12)
	_tooltip.add_theme_stylebox_override(&"panel", tooltip_style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 6)
	var name_label: Label = Label.new()
	name_label.text = item.item_name
	name_label.add_theme_color_override(&"font_color", RARITY_COLORS[clampi(item.rarity, 0, 3)])
	name_label.add_theme_font_size_override(&"font_size", 18)
	vbox.add_child(name_label)

	var type_label: Label = Label.new()
	type_label.text = item.item_type.capitalize()
	vbox.add_child(type_label)

	for stat_name: String in item.stat_modifiers:
		var stat_label: Label = Label.new()
		var raw_val: Variant = item.stat_modifiers[stat_name]
		var formatted: String
		if raw_val is float:
			formatted = "%.1f" % (raw_val as float)
		else:
			formatted = str(raw_val)
		stat_label.text = "+ %s %s" % [formatted, stat_name.capitalize()]
		stat_label.modulate = Color(0.3, 0.9, 0.3)
		vbox.add_child(stat_label)

	var dur_label: Label = Label.new()
	dur_label.text = "Durability: %d%%" % (int(item.current_durability / item.max_durability * 100.0) if item.max_durability > 0.0 else 100)
	vbox.add_child(dur_label)

	if not item.description.is_empty():
		var desc: Label = Label.new()
		desc.text = item.description
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(desc)

	# Action buttons
	var btn_hbox: HBoxContainer = HBoxContainer.new()
	if item.item_type in ["chip", "module", "core", "protocol"]:
		var equip_btn: Button = Button.new()
		equip_btn.text = "Equip"
		equip_btn.pressed.connect(_on_equip_item.bind(item))
		btn_hbox.add_child(equip_btn)
	var drop_btn: Button = Button.new()
	drop_btn.text = "Drop"
	drop_btn.pressed.connect(_on_drop_item.bind(item))
	btn_hbox.add_child(drop_btn)
	vbox.add_child(btn_hbox)

	_tooltip.add_child(vbox)
	_panel.add_child(_tooltip)


func _on_equip_item(item: Resource) -> void:
	var previous: Resource = _player.equipment_component.equip(item)
	_player.inventory_component.remove_item(item)
	if previous:
		if not _player.inventory_component.add_item(previous):
			# Inventory full — re-equip the old item and put new one back
			_player.equipment_component.equip(previous)
			_player.inventory_component.add_item(item)
			push_warning("Inventory full — cannot swap equipment")
	_rebuild()


func _on_drop_item(item: Resource) -> void:
	_player.inventory_component.remove_item(item)
	var dropped_scene: PackedScene = load("res://scenes/items/DroppedItem.tscn") as PackedScene
	if dropped_scene:
		var dropped: Node = dropped_scene.instantiate() as Node
		dropped.item = item
		get_tree().current_scene.add_child(dropped)
		dropped.global_position = _player.global_position + Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
	_rebuild()


func _rebuild() -> void:
	if _tooltip:
		_tooltip.queue_free()
		_tooltip = null
	if _panel:
		_panel.queue_free()
	_build_ui()


func _get_equipped_item(item_type: String, index: int) -> Resource:
	match item_type:
		"module":
			return _player.equipment_component.module_slots[index] if index < 4 else null
		"core":
			return _player.equipment_component.core_slot
		"chip":
			return _player.equipment_component.chip_slots[index] if index < 4 else null
		"protocol":
			return _player.equipment_component.protocol_slots[index] if index < 3 else null
	return null
