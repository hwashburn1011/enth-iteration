class_name InventoryComponent
extends Node
## Grid-based inventory that stores items by their grid_size.

signal inventory_changed
signal item_added(item: ItemBase)
signal item_removed(item: ItemBase)

@export var grid_width: int = 10
@export var grid_height: int = 6

var grid: Array = []  # 2D array: grid[y][x] = ItemBase or null


func _ready() -> void:
	_init_grid()


func _init_grid() -> void:
	grid.clear()
	for y: int in grid_height:
		var row: Array = []
		row.resize(grid_width)
		row.fill(null)
		grid.append(row)


func add_item(item: ItemBase) -> bool:
	var pos: Vector2i = _find_space(item)
	if pos == Vector2i(-1, -1):
		return false
	_place_item(item, pos)
	item_added.emit(item)
	inventory_changed.emit()
	return true


func remove_item(item: ItemBase) -> void:
	for y: int in grid_height:
		for x: int in grid_width:
			if grid[y][x] == item:
				grid[y][x] = null
	item_removed.emit(item)
	inventory_changed.emit()


func has_space_for(item: ItemBase) -> bool:
	return _find_space(item) != Vector2i(-1, -1)


func get_items() -> Array[ItemBase]:
	var items: Array[ItemBase] = []
	for y: int in grid_height:
		for x: int in grid_width:
			var cell_item: ItemBase = grid[y][x] as ItemBase
			if cell_item != null and cell_item not in items:
				items.append(cell_item)
	return items


func get_item_at(grid_pos: Vector2i) -> ItemBase:
	if grid_pos.x < 0 or grid_pos.x >= grid_width or grid_pos.y < 0 or grid_pos.y >= grid_height:
		return null
	return grid[grid_pos.y][grid_pos.x] as ItemBase


func _find_space(item: ItemBase) -> Vector2i:
	for y: int in grid_height - item.grid_size.y + 1:
		for x: int in grid_width - item.grid_size.x + 1:
			if _can_place_at(item, Vector2i(x, y)):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _can_place_at(item: ItemBase, pos: Vector2i) -> bool:
	for dy: int in item.grid_size.y:
		for dx: int in item.grid_size.x:
			var cx: int = pos.x + dx
			var cy: int = pos.y + dy
			if cx >= grid_width or cy >= grid_height:
				return false
			if grid[cy][cx] != null:
				return false
	return true


func _place_item(item: ItemBase, pos: Vector2i) -> void:
	for dy: int in item.grid_size.y:
		for dx: int in item.grid_size.x:
			grid[pos.y + dy][pos.x + dx] = item
