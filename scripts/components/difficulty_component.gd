class_name DifficultyComponent
extends Node

## Player-side difficulty + modifier state. Tracks active difficulty tier
## and the list of active modifiers per dungeon run. Exposes the multipliers
## that combat / loot / economy systems should query.

signal difficulty_changed(new_difficulty: StringName)
signal modifier_added(modifier_id: StringName)
signal modifier_removed(modifier_id: StringName)

var current_difficulty: StringName = &"normal"
var active_modifiers: Array[StringName] = []
var permanent_positive_modifiers: Array[StringName] = []  ## from accessibility menu


func _ready() -> void:
	current_difficulty = &"normal"


# === DIFFICULTY ===

func set_difficulty(diff_id: StringName) -> bool:
	if DifficultyDatabase.get_difficulty(diff_id).is_empty():
		return false
	current_difficulty = diff_id
	difficulty_changed.emit(diff_id)
	return true


func get_enemy_hp_mult() -> float:
	var d: Dictionary = DifficultyDatabase.get_difficulty(current_difficulty)
	return d.get("enemy_hp_mult", 1.0)


func get_enemy_dmg_mult() -> float:
	var d: Dictionary = DifficultyDatabase.get_difficulty(current_difficulty)
	return d.get("enemy_dmg_mult", 1.0)


func get_loot_quality_mult() -> float:
	var d: Dictionary = DifficultyDatabase.get_difficulty(current_difficulty)
	return d.get("loot_quality_mult", 1.0)


func get_economy_mult() -> float:
	var d: Dictionary = DifficultyDatabase.get_difficulty(current_difficulty)
	return d.get("economy_mult", 1.0)


# === MODIFIERS ===

func count_negative_active() -> int:
	var n: int = 0
	for id: StringName in active_modifiers:
		var m: Dictionary = DifficultyDatabase.get_modifier(id)
		if m.get("type", &"") == &"negative":
			n += 1
	return n


func can_add_modifier(modifier_id: StringName) -> bool:
	if active_modifiers.has(modifier_id):
		return false
	var m: Dictionary = DifficultyDatabase.get_modifier(modifier_id)
	if m.is_empty():
		return false
	if m.get("type", &"") == &"negative":
		if count_negative_active() >= DifficultyDatabase.MAX_NEGATIVE_MODIFIERS:
			return false
	return true


func add_modifier(modifier_id: StringName) -> bool:
	if not can_add_modifier(modifier_id):
		return false
	active_modifiers.append(modifier_id)
	modifier_added.emit(modifier_id)
	return true


func remove_modifier(modifier_id: StringName) -> bool:
	if not active_modifiers.has(modifier_id):
		return false
	active_modifiers.erase(modifier_id)
	modifier_removed.emit(modifier_id)
	return true


func clear_modifiers() -> void:
	for id: StringName in active_modifiers.duplicate():
		remove_modifier(id)


func is_modifier_active(modifier_id: StringName) -> bool:
	return active_modifiers.has(modifier_id) or permanent_positive_modifiers.has(modifier_id)


func get_total_reward_bonus() -> float:
	## Combine active dungeon modifiers + difficulty's loot quality
	var bonus: float = DifficultyDatabase.compute_total_reward_bonus(active_modifiers)
	return bonus * get_loot_quality_mult()


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"current_difficulty": String(current_difficulty),
		"active_modifiers": active_modifiers.map(func(s: StringName) -> String: return String(s)),
		"permanent_positive_modifiers": permanent_positive_modifiers.map(func(s: StringName) -> String: return String(s)),
	}


func from_save_data(data: Dictionary) -> void:
	current_difficulty = StringName(data.get("current_difficulty", "normal"))
	active_modifiers.clear()
	for s in data.get("active_modifiers", []):
		active_modifiers.append(StringName(s))
	permanent_positive_modifiers.clear()
	for s in data.get("permanent_positive_modifiers", []):
		permanent_positive_modifiers.append(StringName(s))
