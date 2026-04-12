class_name VendorShop
extends CanvasLayer
## Post-V1 Epic A #1 — vendor shop UI with buy/sell tabs.
##
## Spawned by an NPC's _start_conversation when the NPC has vendor_stock.
## Shows a two-column layout: left = vendor stock, right = player inventory.
## Each item slot shows name, rarity color, price, and a Buy/Sell button.

signal shop_closed

const RARITY_COLORS: Array[Color] = [
	Color(0.7, 0.7, 0.7),    # Common — grey
	Color(0.3, 0.7, 1.0),    # Uncommon — blue
	Color(0.6, 0.2, 0.9),    # Rare — purple
	Color(1.0, 0.75, 0.1),   # Legendary — gold
]

var _panel: Control = null
var _vendor_items: Array[Dictionary] = []  # [{item_id, price, rarity}]
var _player_ref: Node = null
var _gold_label: Label = null
## Post-V1 A5: last 5 sold items recoverable at same price.
var _buyback_items: Array[Dictionary] = []  # [{item_ref, price}]
const BUYBACK_MAX: int = 5


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	GameManager.set_state(GameManager.GameState.INVENTORY)


func open(vendor_stock: Array[Dictionary], player: Node) -> void:
	_vendor_items = vendor_stock
	_player_ref = player
	_refresh_shop()
	_refresh_gold()


func _build_ui() -> void:
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	# Dark background
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.6)
	_panel.add_child(bg)

	# Main container
	var main_panel: PanelContainer = PanelContainer.new()
	main_panel.set_anchors_preset(Control.PRESET_CENTER)
	main_panel.offset_left = -350
	main_panel.offset_top = -250
	main_panel.offset_right = 350
	main_panel.offset_bottom = 250
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.1, 0.95)
	style.border_color = Color(0.15, 0.45, 0.55, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	main_panel.add_theme_stylebox_override(&"panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 8)

	# Header
	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override(&"separation", 20)
	var title: Label = Label.new()
	title.text = "VENDOR"
	title.add_theme_font_size_override(&"font_size", 24)
	title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	header.add_child(title)
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	_gold_label = Label.new()
	_gold_label.add_theme_font_size_override(&"font_size", 20)
	_gold_label.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2))
	header.add_child(_gold_label)
	var close_btn: Button = Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(_close)
	header.add_child(close_btn)
	vbox.add_child(header)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	# Two columns: vendor stock (left) and player sell (right)
	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override(&"separation", 16)

	# Vendor stock column
	var buy_vbox: VBoxContainer = VBoxContainer.new()
	buy_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var buy_label: Label = Label.new()
	buy_label.text = "Buy"
	buy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	buy_label.add_theme_font_size_override(&"font_size", 18)
	buy_label.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.75))
	buy_vbox.add_child(buy_label)
	var buy_scroll: ScrollContainer = ScrollContainer.new()
	buy_scroll.custom_minimum_size = Vector2(300, 350)
	buy_vbox.add_child(buy_scroll)
	var buy_list: VBoxContainer = VBoxContainer.new()
	buy_list.name = "BuyList"
	buy_list.add_theme_constant_override(&"separation", 4)
	buy_scroll.add_child(buy_list)
	columns.add_child(buy_vbox)

	# Sell column
	var sell_vbox: VBoxContainer = VBoxContainer.new()
	sell_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sell_label: Label = Label.new()
	sell_label.text = "Sell"
	sell_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sell_label.add_theme_font_size_override(&"font_size", 18)
	sell_label.add_theme_color_override(&"font_color", Color(0.85, 0.6, 0.3))
	sell_vbox.add_child(sell_label)
	var sell_scroll: ScrollContainer = ScrollContainer.new()
	sell_scroll.custom_minimum_size = Vector2(300, 350)
	sell_vbox.add_child(sell_scroll)
	var sell_list: VBoxContainer = VBoxContainer.new()
	sell_list.name = "SellList"
	sell_list.add_theme_constant_override(&"separation", 4)
	sell_scroll.add_child(sell_list)
	columns.add_child(sell_vbox)

	vbox.add_child(columns)
	main_panel.add_child(vbox)
	_panel.add_child(main_panel)
	add_child(_panel)


func _refresh_shop() -> void:
	# Clear buy list
	var buy_list: VBoxContainer = _panel.find_child("BuyList", true, false) as VBoxContainer
	if buy_list:
		for child: Node in buy_list.get_children():
			child.queue_free()
		for entry: Dictionary in _vendor_items:
			var row: HBoxContainer = _create_item_row(
				str(entry.get("name", entry.get("item_id", "???"))),
				int(entry.get("rarity", 0)),
				int(entry.get("price", 10)),
				true,
				entry
			)
			buy_list.add_child(row)
		# Post-V1 A5: show buyback items at the bottom of the buy list
		if not _buyback_items.is_empty():
			var sep_label: Label = Label.new()
			sep_label.text = "--- Buy Back ---"
			sep_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			sep_label.add_theme_font_size_override(&"font_size", 12)
			sep_label.add_theme_color_override(&"font_color", Color(0.5, 0.55, 0.6))
			buy_list.add_child(sep_label)
			for bb: Dictionary in _buyback_items:
				var item: Resource = bb.get("item_ref") as Resource
				if item == null:
					continue
				var bb_name: String = str(item.get(&"item_name")) if &"item_name" in item else str(item.get(&"item_id", "item"))
				var bb_rarity: int = int(item.get(&"rarity")) if &"rarity" in item else 0
				var bb_row: HBoxContainer = _create_item_row(bb_name, bb_rarity, int(bb["price"]), true, bb)
				# Override the buy button to call buyback instead
				var btn: Button = bb_row.get_child(bb_row.get_child_count() - 1) as Button
				if btn:
					btn.text = "Back"
					for conn: Dictionary in btn.pressed.get_connections():
						btn.pressed.disconnect(conn["callable"])
					btn.pressed.connect(_on_buyback.bind(bb, int(bb["price"])))
				buy_list.add_child(bb_row)

	# Clear sell list — populate from player inventory
	var sell_list: VBoxContainer = _panel.find_child("SellList", true, false) as VBoxContainer
	if sell_list and _player_ref:
		for child: Node in sell_list.get_children():
			child.queue_free()
		var inv: Node = _player_ref.get_node_or_null("InventoryComponent") as Node
		if inv:
			var seen: Array = []
			for y: int in inv.grid_height:
				for x: int in inv.grid_width:
					var item: Resource = inv.grid[y][x] as Resource
					if item != null and item not in seen:
						seen.append(item)
						var sell_price: int = _get_sell_price(item)
						var rarity: int = int(item.get(&"rarity")) if &"rarity" in item else 0
						var row: HBoxContainer = _create_item_row(
							str(item.get(&"item_name")) if &"item_name" in item else str(item.get(&"item_id", "item")),
							rarity,
							sell_price,
							false,
							{"item_ref": item}
						)
						sell_list.add_child(row)


func _create_item_row(item_name: String, rarity: int, price: int, is_buy: bool, data: Dictionary) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)

	var name_lbl: Label = Label.new()
	name_lbl.text = item_name
	name_lbl.custom_minimum_size = Vector2(160, 0)
	name_lbl.add_theme_font_size_override(&"font_size", 14)
	var color: Color = RARITY_COLORS[clampi(rarity, 0, RARITY_COLORS.size() - 1)]
	name_lbl.add_theme_color_override(&"font_color", color)
	row.add_child(name_lbl)

	var price_lbl: Label = Label.new()
	price_lbl.text = "%d g" % price
	price_lbl.custom_minimum_size = Vector2(50, 0)
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price_lbl.add_theme_font_size_override(&"font_size", 14)
	price_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2))
	row.add_child(price_lbl)

	var btn: Button = Button.new()
	btn.text = "Buy" if is_buy else "Sell"
	btn.custom_minimum_size = Vector2(60, 0)
	btn.add_theme_font_size_override(&"font_size", 13)
	if is_buy:
		btn.pressed.connect(_on_buy.bind(data, price))
	else:
		btn.pressed.connect(_on_sell.bind(data, price))
	row.add_child(btn)

	return row


func _on_buy(data: Dictionary, price: int) -> void:
	if GameManager.player_gold < price:
		return  # Can't afford
	if _player_ref == null:
		return
	var inv: Node = _player_ref.get_node_or_null("InventoryComponent") as Node
	if inv == null:
		return
	var item_id: String = str(data.get("item_id", ""))
	if item_id.is_empty():
		return
	var registry_script: Script = load("res://scripts/items/item_registry.gd") as Script
	if registry_script == null:
		return
	var item: Resource = registry_script.create_item(item_id)
	if item == null:
		return
	if not inv.add_item(item):
		return  # Inventory full
	GameManager.player_gold -= price
	_refresh_gold()
	_refresh_shop()


func _on_sell(data: Dictionary, price: int) -> void:
	if _player_ref == null:
		return
	var inv: Node = _player_ref.get_node_or_null("InventoryComponent") as Node
	if inv == null:
		return
	var item: Resource = data.get("item_ref") as Resource
	if item == null:
		return
	inv.remove_item(item)
	GameManager.player_gold += price
	# Post-V1 A5: push to buy-back buffer
	_buyback_items.push_front({"item_ref": item, "price": price})
	if _buyback_items.size() > BUYBACK_MAX:
		_buyback_items.resize(BUYBACK_MAX)
	_refresh_gold()
	_refresh_shop()


func _on_buyback(data: Dictionary, price: int) -> void:
	## Post-V1 A5: re-purchase a previously sold item at the same price.
	if GameManager.player_gold < price:
		return
	if _player_ref == null:
		return
	var inv: Node = _player_ref.get_node_or_null("InventoryComponent") as Node
	if inv == null:
		return
	var item: Resource = data.get("item_ref") as Resource
	if item == null:
		return
	if not inv.add_item(item):
		return  # Inventory full
	GameManager.player_gold -= price
	_buyback_items.erase(data)
	_refresh_gold()
	_refresh_shop()


func _get_sell_price(item: Resource) -> int:
	## Post-V1 A4: sell price = rarity base + affix bonus.
	## Each affix on the item adds +5g so well-rolled gear sells for more.
	var base: int = 5
	var rarity: int = int(item.get(&"rarity")) if &"rarity" in item else 0
	match rarity:
		1: base = 10
		2: base = 25
		3: base = 75
	# Affix bonus: stat_modifiers dict size approximates affix count
	var affix_count: int = 0
	if &"stat_modifiers" in item:
		var mods: Dictionary = item.get(&"stat_modifiers") as Dictionary
		affix_count = mods.size()
	return base + affix_count * 5


func _refresh_gold() -> void:
	if _gold_label:
		_gold_label.text = "%d Gold" % GameManager.player_gold


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"inventory"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)
	shop_closed.emit()
	queue_free()
