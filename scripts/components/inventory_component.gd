class_name InventoryComponent
extends Node
## Grid-based inventory that stores items by their grid_size.

signal inventory_changed
signal item_added(item: Resource)
signal item_removed(item: Resource)
signal prompt_used(prompt_type: String, remaining: int)

@export var grid_width: int = 10
@export var grid_height: int = 6

var grid: Array = []  # 2D array: grid[y][x] = ItemBase or null
var prompt_hotbar: Array[Dictionary] = []  # [{item: Resource, quantity: int}, ...]
var active_prompt_index: int = 0


func _ready() -> void:
	_init_grid()


func _init_grid() -> void:
	grid.clear()
	for y: int in grid_height:
		var row: Array = []
		row.resize(grid_width)
		row.fill(null)
		grid.append(row)


func add_item(item: Resource) -> bool:
	# Prompts go to the hotbar stack, not the grid
	if item.get(&"item_type") == "prompt":
		add_prompt(item as Resource)
		item_added.emit(item)
		return true
	var pos: Vector2i = _find_space(item)
	if pos == Vector2i(-1, -1):
		return false
	_place_item(item, pos)
	item_added.emit(item)
	inventory_changed.emit()
	return true


func remove_item(item: Resource) -> void:
	for y: int in grid_height:
		for x: int in grid_width:
			if grid[y][x] == item:
				grid[y][x] = null
	item_removed.emit(item)
	inventory_changed.emit()


func has_space_for(item: Resource) -> bool:
	return _find_space(item) != Vector2i(-1, -1)


func get_items() -> Array[Resource]:
	var items: Array[Resource] = []
	for y: int in grid_height:
		for x: int in grid_width:
			var cell_item: Resource = grid[y][x] as Resource
			if cell_item != null and cell_item not in items:
				items.append(cell_item)
	return items


func get_item_at(grid_pos: Vector2i) -> Resource:
	if grid_pos.x < 0 or grid_pos.x >= grid_width or grid_pos.y < 0 or grid_pos.y >= grid_height:
		return null
	return grid[grid_pos.y][grid_pos.x] as Resource


func _find_space(item: Resource) -> Vector2i:
	for y: int in grid_height - item.grid_size.y + 1:
		for x: int in grid_width - item.grid_size.x + 1:
			if _can_place_at(item, Vector2i(x, y)):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _can_place_at(item: Resource, pos: Vector2i) -> bool:
	for dy: int in item.grid_size.y:
		for dx: int in item.grid_size.x:
			var cx: int = pos.x + dx
			var cy: int = pos.y + dy
			if cx >= grid_width or cy >= grid_height:
				return false
			if grid[cy][cx] != null:
				return false
	return true


func _place_item(item: Resource, pos: Vector2i) -> void:
	for dy: int in item.grid_size.y:
		for dx: int in item.grid_size.x:
			grid[pos.y + dy][pos.x + dx] = item


## Prompt hotbar management

func add_prompt(prompt: Resource) -> void:
	for entry: Dictionary in prompt_hotbar:
		var existing: Resource = entry["item"] as Resource
		if existing.item_id == prompt.item_id:
			entry["quantity"] = int(entry["quantity"]) + 1
			inventory_changed.emit()
			return
	prompt_hotbar.append({"item": prompt, "quantity": 1})
	inventory_changed.emit()


func cycle_active_prompt() -> void:
	if prompt_hotbar.is_empty():
		return
	active_prompt_index = (active_prompt_index + 1) % prompt_hotbar.size()


func get_active_prompt() -> Dictionary:
	if prompt_hotbar.is_empty() or active_prompt_index >= prompt_hotbar.size():
		return {}
	return prompt_hotbar[active_prompt_index]


func consume_active_prompt() -> Resource:
	if prompt_hotbar.is_empty() or active_prompt_index >= prompt_hotbar.size():
		return null
	var entry: Dictionary = prompt_hotbar[active_prompt_index]
	var prompt: Resource = entry["item"] as Resource
	entry["quantity"] = int(entry["quantity"]) - 1
	prompt_used.emit(prompt.prompt_type, int(entry["quantity"]))
	if int(entry["quantity"]) <= 0:
		prompt_hotbar.remove_at(active_prompt_index)
		if active_prompt_index >= prompt_hotbar.size() and prompt_hotbar.size() > 0:
			active_prompt_index = 0
	inventory_changed.emit()
	return prompt
