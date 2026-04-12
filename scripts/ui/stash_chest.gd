class_name StashChest
extends CanvasLayer
## Post-V1 Epic A #6 — persistent stash chest with grid UI.
##
## Separate from player inventory. Items stored here survive dungeon
## runs and deaths. Grid-based like inventory but independent storage.

signal stash_closed

var _panel: Control = null
var _player_ref: Node = null

## Stash storage — persisted via GameManager meta.
## Each entry: {item_id, rarity, durability, stat_modifiers}
var stash_items: Array[Dictionary] = []
const STASH_CAPACITY: int = 20


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Load stash from GameManager meta
	if GameManager.has_meta(&"stash_items"):
		stash_items = GameManager.get_meta(&"stash_items") as Array[Dictionary]
	_build_ui()
	GameManager.set_state(GameManager.GameState.INVENTORY)


func open(player: Node) -> void:
	_player_ref = player
	_refresh()


func _build_ui() -> void:
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.6)
	_panel.add_child(bg)

	var main: PanelContainer = PanelContainer.new()
	main.set_anchors_preset(Control.PRESET_CENTER)
	main.offset_left = -300
	main.offset_top = -200
	main.offset_right = 300
	main.offset_bottom = 200
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.1, 0.95)
	style.border_color = Color(0.45, 0.35, 0.15, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	main.add_theme_stylebox_override(&"panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 8)

	var header: HBoxContainer = HBoxContainer.new()
	var title: Label = Label.new()
	title.text = "STASH (%d/%d)" % [stash_items.size(), STASH_CAPACITY]
	title.name = "StashTitle"
	title.add_theme_font_size_override(&"font_size", 22)
	title.add_theme_color_override(&"font_color", Color(0.85, 0.7, 0.3))
	header.add_child(title)
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var close_btn: Button = Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(_close)
	header.add_child(close_btn)
	vbox.add_child(header)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	# Two columns: stash (left) and player inventory (right)
	var cols: HBoxContainer = HBoxContainer.new()
	cols.add_theme_constant_override(&"separation", 16)

	# Stash column
	var stash_scroll: ScrollContainer = ScrollContainer.new()
	stash_scroll.custom_minimum_size = Vector2(260, 300)
	var stash_list: VBoxContainer = VBoxContainer.new()
	stash_list.name = "StashList"
	stash_list.add_theme_constant_override(&"separation", 4)
	stash_scroll.add_child(stash_list)
	cols.add_child(stash_scroll)

	# Player column
	var inv_scroll: ScrollContainer = ScrollContainer.new()
	inv_scroll.custom_minimum_size = Vector2(260, 300)
	var inv_list: VBoxContainer = VBoxContainer.new()
	inv_list.name = "InvList"
	inv_list.add_theme_constant_override(&"separation", 4)
	inv_scroll.add_child(inv_list)
	cols.add_child(inv_scroll)

	vbox.add_child(cols)
	main.add_child(vbox)
	_panel.add_child(main)
	add_child(_panel)


func _refresh() -> void:
	# Stash items
	var stash_list: VBoxContainer = _panel.find_child("StashList", true, false) as VBoxContainer
	if stash_list:
		for c: Node in stash_list.get_children():
			c.queue_free()
		var stash_label: Label = Label.new()
		stash_label.text = "Stash"
		stash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stash_label.add_theme_font_size_override(&"font_size", 16)
		stash_label.add_theme_color_override(&"font_color", Color(0.85, 0.7, 0.3))
		stash_list.add_child(stash_label)
		for i: int in stash_items.size():
			var entry: Dictionary = stash_items[i]
			var row: HBoxContainer = HBoxContainer.new()
			var lbl: Label = Label.new()
			lbl.text = str(entry.get("item_id", "item"))
			lbl.custom_minimum_size = Vector2(160, 0)
			lbl.add_theme_font_size_override(&"font_size", 13)
			lbl.add_theme_color_override(&"font_color", Color(0.7, 0.75, 0.8))
			row.add_child(lbl)
			var take_btn: Button = Button.new()
			take_btn.text = "Take"
			take_btn.add_theme_font_size_override(&"font_size", 12)
			take_btn.pressed.connect(_on_take.bind(i))
			row.add_child(take_btn)
			stash_list.add_child(row)

	# Player inventory
	var inv_list: VBoxContainer = _panel.find_child("InvList", true, false) as VBoxContainer
	if inv_list and _player_ref:
		for c: Node in inv_list.get_children():
			c.queue_free()
		var inv_label: Label = Label.new()
		inv_label.text = "Inventory"
		inv_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inv_label.add_theme_font_size_override(&"font_size", 16)
		inv_label.add_theme_color_override(&"font_color", Color(0.3, 0.75, 0.85))
		inv_list.add_child(inv_label)
		var inv: Node = _player_ref.get_node_or_null("InventoryComponent") as Node
		if inv:
			var seen: Array = []
			for y: int in inv.grid_height:
				for x: int in inv.grid_width:
					var item: Resource = inv.grid[y][x] as Resource
					if item != null and item not in seen:
						seen.append(item)
						var row: HBoxContainer = HBoxContainer.new()
						var lbl: Label = Label.new()
						lbl.text = str(item.get(&"item_name")) if &"item_name" in item else str(item.get(&"item_id", "item"))
						lbl.custom_minimum_size = Vector2(160, 0)
						lbl.add_theme_font_size_override(&"font_size", 13)
						lbl.add_theme_color_override(&"font_color", Color(0.7, 0.8, 0.75))
						row.add_child(lbl)
						var store_btn: Button = Button.new()
						store_btn.text = "Store"
						store_btn.add_theme_font_size_override(&"font_size", 12)
						store_btn.pressed.connect(_on_store.bind(item))
						row.add_child(store_btn)
						inv_list.add_child(row)

	# Update title
	var title_node: Label = _panel.find_child("StashTitle", true, false) as Label
	if title_node:
		title_node.text = "STASH (%d/%d)" % [stash_items.size(), STASH_CAPACITY]


func _on_store(item: Resource) -> void:
	if stash_items.size() >= STASH_CAPACITY:
		return
	if _player_ref == null:
		return
	var inv: Node = _player_ref.get_node_or_null("InventoryComponent") as Node
	if inv == null:
		return
	inv.remove_item(item)
	stash_items.append({
		"item_id": str(item.get(&"item_id", "")),
		"rarity": int(item.get(&"rarity")) if &"rarity" in item else 0,
	})
	_save_stash()
	_refresh()


func _on_take(index: int) -> void:
	if index >= stash_items.size():
		return
	if _player_ref == null:
		return
	var inv: Node = _player_ref.get_node_or_null("InventoryComponent") as Node
	if inv == null:
		return
	var entry: Dictionary = stash_items[index]
	var registry: Script = load("res://scripts/items/item_registry.gd") as Script
	if registry == null:
		return
	var item: Resource = registry.create_item(str(entry.get("item_id", "")))
	if item == null:
		return
	if not inv.add_item(item):
		return  # Inventory full
	stash_items.remove_at(index)
	_save_stash()
	_refresh()


func _save_stash() -> void:
	GameManager.set_meta(&"stash_items", stash_items.duplicate())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"inventory"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	_save_stash()
	GameManager.set_state(GameManager.GameState.PLAYING)
	stash_closed.emit()
	queue_free()
