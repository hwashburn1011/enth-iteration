class_name BuildablePlot
extends Node3D

## A player-owned plot where decorations can be placed. Tracks the grid,
## placed items, and exposes APIs for the placement system.

signal decoration_placed(plot: BuildablePlot, decoration_id: StringName, position: Vector2i)
signal decoration_removed(plot: BuildablePlot, decoration_id: StringName, position: Vector2i)
signal theme_set_activated(plot: BuildablePlot, theme: StringName)
signal theme_set_deactivated(plot: BuildablePlot, theme: StringName)

@export var plot_id: StringName = &""
@export var display_name: String = ""
@export var grid_size: Vector2i = Vector2i(16, 16)
@export var unlock_iteration: int = 1
@export var max_decorations: int = 60
@export var is_public: bool = false  ## NPCs can see public plots

## Each entry: { item_id: StringName, position: Vector2i, rotation: int (0-3), variant: int }
var placed_items: Array[Dictionary] = []
var active_themes: Array[StringName] = []

@onready var _decoration_holder: Node3D = $DecorationHolder if has_node("DecorationHolder") else null


func _ready() -> void:
	add_to_group(&"buildable_plot")


func is_unlocked() -> bool:
	if Engine.has_singleton("IterationManager") or has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method("get_current_iteration"):
			return im.get_current_iteration() >= unlock_iteration
	return false


func can_place_at(decoration_id: StringName, position: Vector2i) -> bool:
	if not is_unlocked():
		return false
	if placed_items.size() >= max_decorations:
		return false
	var d: Dictionary = DecorationDatabase.get_decoration(decoration_id)
	if d.is_empty():
		return false

	# Bounds check
	var size: Vector2i = d.get("size", Vector2i(1, 1))
	if position.x < 0 or position.y < 0:
		return false
	if position.x + size.x > grid_size.x or position.y + size.y > grid_size.y:
		return false

	# Overlap check
	for entry in placed_items:
		var existing_d: Dictionary = DecorationDatabase.get_decoration(entry["item_id"])
		if existing_d.is_empty():
			continue
		var existing_size: Vector2i = existing_d.get("size", Vector2i(1, 1))
		var existing_pos: Vector2i = entry["position"]
		var existing_rect: Rect2i = Rect2i(existing_pos, existing_size)
		var new_rect: Rect2i = Rect2i(position, size)
		if existing_rect.intersects(new_rect):
			return false

	return true


func place(decoration_id: StringName, position: Vector2i, rotation: int = 0, variant: int = 0) -> bool:
	if not can_place_at(decoration_id, position):
		return false
	var entry: Dictionary = {
		"item_id": decoration_id,
		"position": position,
		"rotation": rotation,
		"variant": variant,
	}
	placed_items.append(entry)
	decoration_placed.emit(self, decoration_id, position)
	_recompute_themes()
	return true


func remove_at(position: Vector2i) -> bool:
	for i in placed_items.size():
		var entry: Dictionary = placed_items[i]
		var existing_d: Dictionary = DecorationDatabase.get_decoration(entry["item_id"])
		var existing_size: Vector2i = existing_d.get("size", Vector2i(1, 1))
		var existing_rect: Rect2i = Rect2i(entry["position"], existing_size)
		if existing_rect.has_point(position):
			var removed_id: StringName = entry["item_id"]
			placed_items.remove_at(i)
			decoration_removed.emit(self, removed_id, position)
			_recompute_themes()
			return true
	return false


func move_decoration(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	for entry in placed_items:
		var existing_d: Dictionary = DecorationDatabase.get_decoration(entry["item_id"])
		var existing_size: Vector2i = existing_d.get("size", Vector2i(1, 1))
		var existing_rect: Rect2i = Rect2i(entry["position"], existing_size)
		if existing_rect.has_point(from_pos):
			# Try to place at new position
			var saved_pos: Vector2i = entry["position"]
			entry["position"] = to_pos
			# Validate doesn't conflict (excluding itself)
			# Simplified: just check bounds
			if to_pos.x < 0 or to_pos.y < 0 or to_pos.x + existing_size.x > grid_size.x or to_pos.y + existing_size.y > grid_size.y:
				entry["position"] = saved_pos
				return false
			return true
	return false


func _recompute_themes() -> void:
	var ids: Array = placed_items.map(func(e: Dictionary) -> StringName: return e["item_id"])
	var new_active: Array = DecorationDatabase.compute_active_themes(ids)
	# Diff against previous
	for theme: StringName in new_active:
		if not active_themes.has(theme):
			theme_set_activated.emit(self, theme)
	for theme: StringName in active_themes:
		if not new_active.has(theme):
			theme_set_deactivated.emit(self, theme)
	active_themes = new_active


func get_decoration_count() -> int:
	return placed_items.size()


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var entries: Array = []
	for e in placed_items:
		entries.append({
			"item_id": String(e["item_id"]),
			"position_x": e["position"].x,
			"position_y": e["position"].y,
			"rotation": e["rotation"],
			"variant": e["variant"],
		})
	return {
		"plot_id": String(plot_id),
		"placed_items": entries,
	}


func from_save_data(data: Dictionary) -> void:
	placed_items.clear()
	for e in data.get("placed_items", []):
		placed_items.append({
			"item_id": StringName(e["item_id"]),
			"position": Vector2i(e["position_x"], e["position_y"]),
			"rotation": e.get("rotation", 0),
			"variant": e.get("variant", 0),
		})
	_recompute_themes()
