class_name CraftingUI
extends Control

## Crafting station UI. Shows recipes filtered by station type, ingredient
## availability, output preview, craft button. Bound at runtime to a
## CraftingStation + the player's CraftingComponent.

signal craft_requested(recipe_id: StringName)
signal close_requested

@export var crafting_component_path: NodePath

@onready var _station_label: Label = %StationLabel
@onready var _tier_label: Label = %TierLabel
@onready var _recipe_list: ItemList = %RecipeList
@onready var _filter_input: LineEdit = %FilterInput
@onready var _ingredients_box: VBoxContainer = %IngredientsBox
@onready var _output_label: Label = %OutputLabel
@onready var _craft_button: Button = %CraftButton
@onready var _close_button: Button = %CloseButton
@onready var _favorite_button: Button = %FavoriteButton

var _component: CraftingComponent
var _station_type: StringName = &"forge"
var _current_recipes: Array = []
var _selected_recipe_id: StringName = &""
var _favorites: Array[StringName] = []
var _filter_text: String = ""


func _ready() -> void:
	_component = get_node_or_null(crafting_component_path)
	if _craft_button != null:
		_craft_button.pressed.connect(_on_craft_pressed)
	if _close_button != null:
		_close_button.pressed.connect(_on_close_pressed)
	if _filter_input != null:
		_filter_input.text_changed.connect(_on_filter_changed)
	if _recipe_list != null:
		_recipe_list.item_selected.connect(_on_recipe_selected)
	if _favorite_button != null:
		_favorite_button.pressed.connect(_on_favorite_pressed)


func open_for_station(station_type: StringName, station_name: String, tier: int) -> void:
	_station_type = station_type
	if _station_label != null:
		_station_label.text = station_name
	if _tier_label != null:
		_tier_label.text = "Tier %d" % tier
	visible = true
	_refresh_recipe_list()


func _refresh_recipe_list() -> void:
	if _component == null or _recipe_list == null:
		return
	_recipe_list.clear()
	_current_recipes = _component.get_known_recipes_for_station(_station_type)

	# Sort: favorites first, then alphabetical
	_current_recipes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_fav: bool = _favorites.has(a["id"])
		var b_fav: bool = _favorites.has(b["id"])
		if a_fav != b_fav:
			return a_fav
		return String(a["name"]) < String(b["name"]))

	for r in _current_recipes:
		if not _filter_text.is_empty() and not String(r["name"]).to_lower().contains(_filter_text.to_lower()):
			continue
		var prefix: String = "★ " if _favorites.has(r["id"]) else "  "
		var idx: int = _recipe_list.add_item(prefix + String(r["name"]))
		# Color by rarity
		var rarity: int = r.get("rarity", 0)
		_recipe_list.set_item_custom_fg_color(idx, _rarity_color(rarity))


func _rarity_color(rarity: int) -> Color:
	match rarity:
		0: return Color(0.85, 0.85, 0.85)
		1: return Color(0.40, 0.95, 0.40)
		2: return Color(0.40, 0.55, 0.95)
		3: return Color(0.95, 0.65, 0.20)
	return Color.WHITE


func _on_recipe_selected(idx: int) -> void:
	if idx < 0 or idx >= _current_recipes.size():
		return
	var r: Dictionary = _current_recipes[idx]
	_selected_recipe_id = r["id"]
	_show_recipe_details(r)


func _show_recipe_details(r: Dictionary) -> void:
	if _ingredients_box != null:
		for c in _ingredients_box.get_children():
			c.queue_free()
		var ing: Dictionary = r.get("ing", {})
		for material_id: StringName in ing.keys():
			var hbox: HBoxContainer = HBoxContainer.new()
			var name_lbl: Label = Label.new()
			var mat_data: Dictionary = MaterialDatabase.get_material(material_id)
			name_lbl.text = mat_data.get("name", String(material_id))
			name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var have: int = 0
			if _component != null and _component._inventory != null and _component._inventory.has_method("count_item_by_id"):
				have = _component._inventory.count_item_by_id(String(material_id))
			var count_lbl: Label = Label.new()
			count_lbl.text = "%d / %d" % [have, ing[material_id]]
			if have >= ing[material_id]:
				count_lbl.add_theme_color_override(&"font_color", Color(0.4, 0.95, 0.4))
			else:
				count_lbl.add_theme_color_override(&"font_color", Color(0.95, 0.4, 0.4))
			hbox.add_child(name_lbl)
			hbox.add_child(count_lbl)
			_ingredients_box.add_child(hbox)

	if _output_label != null:
		_output_label.text = "Output: %d × %s" % [r.get("out_n", 1), r.get("out", "")]

	if _craft_button != null:
		_craft_button.disabled = not _component.has_ingredients(_selected_recipe_id)


func _on_craft_pressed() -> void:
	if _selected_recipe_id == &"":
		return
	craft_requested.emit(_selected_recipe_id)
	# Refresh after craft
	call_deferred("_refresh_after_craft")


func _refresh_after_craft() -> void:
	_refresh_recipe_list()
	if _selected_recipe_id != &"":
		var r: Dictionary = RecipeDatabase.get_recipe(_selected_recipe_id)
		if not r.is_empty():
			_show_recipe_details(r)


func _on_close_pressed() -> void:
	visible = false
	close_requested.emit()


func _on_filter_changed(new_text: String) -> void:
	_filter_text = new_text
	_refresh_recipe_list()


func _on_favorite_pressed() -> void:
	if _selected_recipe_id == &"":
		return
	if _favorites.has(_selected_recipe_id):
		_favorites.erase(_selected_recipe_id)
	else:
		_favorites.append(_selected_recipe_id)
	_refresh_recipe_list()
