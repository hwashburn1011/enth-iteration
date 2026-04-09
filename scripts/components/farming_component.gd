class_name FarmingComponent
extends Node

## Player-attached gathering skill state. Tracks XP, level, perks, fish
## bestiary, and crop bestiary. Independent from combat level.

signal level_changed(new_level: int)
signal xp_changed(current_xp: int, xp_to_next: int)
signal fish_caught_first_time(fish_id: StringName)
signal crop_grown_first_time(crop_id: StringName)
signal perk_unlocked(perk_id: StringName)

const XP_TABLE: Array[int] = [
	0, 100, 250, 450, 700, 1000,
	1400, 1900, 2500, 3200, 4000,
	5000, 6200, 7600, 9200, 11000,
	13000, 15200, 17600, 20200, 23000,
	26000, 29200, 32600, 36200, 40000,
	44000, 48200, 52600, 57200, 62000,
	67000, 72200, 77600, 83200, 89000,
	95000, 101200, 107600, 114200, 121000,
	128000, 135200, 142600, 150200, 158000,
	166000, 174200, 182600, 191200, 200000,
]

const LEVEL_PERKS: Dictionary = {
	5:  &"growth_speed_5pct",
	10: &"quality_fertilizer_2x",
	15: &"double_harvest_10pct",
	20: &"fishing_zone_25pct",
	25: &"rare_drops_50pct",
	30: &"legendary_in_normal_plots",
	50: &"harvest_master_title",
}

var xp: int = 0
var level: int = 1
var fish_bestiary: Array[StringName] = []
var crop_bestiary: Array[StringName] = []
var unlocked_perks: Array[StringName] = []


func grant_xp(amount: int) -> void:
	xp += amount
	xp_changed.emit(xp, _xp_to_next_level())
	while level < XP_TABLE.size() and xp >= XP_TABLE[level]:
		level += 1
		level_changed.emit(level)
		_check_perk_unlock(level)


func _xp_to_next_level() -> int:
	if level >= XP_TABLE.size():
		return 0
	return XP_TABLE[level] - xp


func _check_perk_unlock(new_level: int) -> void:
	if LEVEL_PERKS.has(new_level):
		var perk: StringName = LEVEL_PERKS[new_level]
		if not unlocked_perks.has(perk):
			unlocked_perks.append(perk)
			perk_unlocked.emit(perk)


func has_perk(perk_id: StringName) -> bool:
	return unlocked_perks.has(perk_id)


func record_fish_catch(fish_id: StringName) -> void:
	if not fish_bestiary.has(fish_id):
		fish_bestiary.append(fish_id)
		fish_caught_first_time.emit(fish_id)


func record_crop_harvest(crop_id: StringName) -> void:
	if not crop_bestiary.has(crop_id):
		crop_bestiary.append(crop_id)
		crop_grown_first_time.emit(crop_id)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"xp": xp,
		"level": level,
		"fish_bestiary": fish_bestiary.map(func(s: StringName) -> String: return String(s)),
		"crop_bestiary": crop_bestiary.map(func(s: StringName) -> String: return String(s)),
		"unlocked_perks": unlocked_perks.map(func(s: StringName) -> String: return String(s)),
	}


func from_save_data(data: Dictionary) -> void:
	xp = data.get("xp", 0)
	level = data.get("level", 1)
	fish_bestiary.clear()
	for s in data.get("fish_bestiary", []):
		fish_bestiary.append(StringName(s))
	crop_bestiary.clear()
	for s in data.get("crop_bestiary", []):
		crop_bestiary.append(StringName(s))
	unlocked_perks.clear()
	for s in data.get("unlocked_perks", []):
		unlocked_perks.append(StringName(s))
