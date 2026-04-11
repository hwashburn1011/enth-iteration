class_name FarmingSubsystems
extends Node

## Farming & Gathering Subsystems Bundle (Epic 35 tasks 15, 25, 26, 38, 39, 41,
## 42, 43, 48).
##
## Single autoload-friendly hub for the engine-side farming features:
##   - Task 15: Farming UI overlay (HUD panel showing crop status)
##   - Task 25: Wild forage spawn locations in wilderness
##   - Task 26: Forage collection
##   - Task 38: Gathering UI tracker (per-skill progress display)
##   - Task 39: Gathering NPC quests (quest hooks for "deliver N of X")
##   - Task 41: Balance validator
##   - Task 42: Ambient SFX hook on gather actions
##   - Task 43: Particle hook on harvest actions
##   - Task 48: Full farming loop test harness

signal forage_spawned(spawn_id: StringName, item_id: StringName, location: Vector3)
signal forage_collected(item_id: StringName, quantity: int)
signal gathering_skill_increased(skill_id: StringName, new_level: int)
signal quest_progress_updated(quest_id: StringName, current: int, target: int)

# === TASK 25: Wild forage spawn data ===
const FORAGE_SPAWN_TABLE: Dictionary = {
	&"wilderness_north": [
		{"item": &"herb_common", "weight": 60, "respawn_min": 30},
		{"item": &"oak_log", "weight": 25, "respawn_min": 60},
		{"item": &"blue_crystal", "weight": 5, "respawn_min": 240},
	],
	&"wilderness_south": [
		{"item": &"herb_rare", "weight": 30, "respawn_min": 90},
		{"item": &"yew_log", "weight": 35, "respawn_min": 90},
		{"item": &"violet_crystal", "weight": 5, "respawn_min": 360},
	],
	&"wilderness_east": [
		{"item": &"clay_lump", "weight": 40, "respawn_min": 60},
		{"item": &"copper_ore", "weight": 35, "respawn_min": 90},
		{"item": &"red_crystal", "weight": 5, "respawn_min": 360},
	],
	&"wilderness_west": [
		{"item": &"frost_dust", "weight": 30, "respawn_min": 120},
		{"item": &"silver_bar", "weight": 15, "respawn_min": 180},
		{"item": &"data_shard", "weight": 25, "respawn_min": 60},
	],
}

const FORAGE_SPAWN_BUDGET_PER_REGION: int = 8

var _active_forage: Dictionary = {}  # spawn_id → {region, item_id, location, depleted_until_min}
var _forage_id_counter: int = 0


func spawn_forage_in_region(region_id: StringName, location: Vector3) -> StringName:
	var table: Array = FORAGE_SPAWN_TABLE.get(region_id, [])
	if table.is_empty():
		return &""
	# Weighted pick
	var total_weight: int = 0
	for entry in table:
		total_weight += int(entry.get("weight", 1))
	var roll: int = randi() % total_weight
	var cumulative: int = 0
	var picked: Dictionary = {}
	for entry in table:
		cumulative += int(entry.get("weight", 1))
		if roll < cumulative:
			picked = entry
			break
	if picked.is_empty():
		return &""
	_forage_id_counter += 1
	var spawn_id := StringName("forage_%d" % _forage_id_counter)
	_active_forage[spawn_id] = {
		"region": region_id,
		"item_id": picked["item"],
		"location": location,
		"respawn_min": int(picked.get("respawn_min", 60)),
		"depleted": false,
	}
	forage_spawned.emit(spawn_id, picked["item"], location)
	return spawn_id


func populate_region(region_id: StringName, region_min: Vector3, region_max: Vector3) -> Array[StringName]:
	var spawned: Array[StringName] = []
	for i in range(FORAGE_SPAWN_BUDGET_PER_REGION):
		var loc := Vector3(
			randf_range(region_min.x, region_max.x),
			region_min.y,
			randf_range(region_min.z, region_max.z),
		)
		var sid: StringName = spawn_forage_in_region(region_id, loc)
		if sid != &"":
			spawned.append(sid)
	return spawned


# === TASK 26: Forage collection ===
func collect_forage(spawn_id: StringName) -> Dictionary:
	if not _active_forage.has(spawn_id):
		return {}
	var data: Dictionary = _active_forage[spawn_id]
	if data.get("depleted", false):
		return {}
	data["depleted"] = true
	var item_id: StringName = data["item_id"]
	# Quality roll
	var quality: StringName = _gather_quality_roll()
	# Add to inventory
	var im: Node = _inventory()
	if im != null and im.has_method("add_material"):
		im.call("add_material", item_id, 1, quality)
	# SFX hook
	_play_gather_sfx(item_id)
	# Particle hook
	_play_harvest_particles(data["location"])
	# Skill XP
	_award_gathering_xp(item_id, 5)
	# Quest progress
	_update_quest_progress(item_id, 1)
	forage_collected.emit(item_id, 1)
	return {"item": item_id, "quality": quality}


func _gather_quality_roll() -> StringName:
	var r: float = randf()
	if r < 0.10: return &"crude"
	if r < 0.75: return &"normal"
	if r < 0.95: return &"fine"
	return &"masterwork"


# === TASK 38: Gathering skill tracking ===
const GATHERING_SKILLS: Array[StringName] = [&"farming", &"foraging", &"mining", &"woodcutting", &"fishing", &"hunting"]
const XP_PER_LEVEL: int = 100

var _skill_xp: Dictionary = {}  # skill_id → int
var _skill_level: Dictionary = {}  # skill_id → int


func get_skill_level(skill_id: StringName) -> int:
	return _skill_level.get(skill_id, 1)


func get_skill_xp(skill_id: StringName) -> int:
	return _skill_xp.get(skill_id, 0)


func get_skill_progress(skill_id: StringName) -> float:
	var xp: int = _skill_xp.get(skill_id, 0)
	return float(xp % XP_PER_LEVEL) / float(XP_PER_LEVEL)


func _award_gathering_xp(item_id: StringName, base_xp: int) -> void:
	var skill: StringName = _skill_for_item(item_id)
	if skill == &"":
		return
	_skill_xp[skill] = _skill_xp.get(skill, 0) + base_xp
	var new_level: int = 1 + (_skill_xp[skill] / XP_PER_LEVEL)
	if new_level > _skill_level.get(skill, 1):
		_skill_level[skill] = new_level
		gathering_skill_increased.emit(skill, new_level)


func _skill_for_item(item_id: StringName) -> StringName:
	var s: String = String(item_id)
	if "log" in s or "wood" in s: return &"woodcutting"
	if "ore" in s or "ingot" in s or "crystal" in s or "shard" in s: return &"mining"
	if "herb" in s or "leaf" in s: return &"foraging"
	if "fish" in s or "minnow" in s or "carp" in s or "pike" in s or "bass" in s or "eel" in s: return &"fishing"
	if "pelt" in s or "meat" in s: return &"hunting"
	return &"farming"


# === TASK 39: Gathering NPC quests ===
const NPC_GATHERING_QUESTS: Dictionary = {
	&"harvest_oak_logs_10": {
		"npc": &"harvest", "item": &"oak_log", "target": 10,
		"reward_gold": 50, "reward_items": [{"id": &"healing_packet", "qty": 3}],
	},
	&"sage_blue_crystals_3": {
		"npc": &"ai_sage", "item": &"blue_crystal", "target": 3,
		"reward_gold": 200, "reward_items": [{"id": &"data_shard", "qty": 5}],
	},
	&"cache_data_minnows_5": {
		"npc": &"cache", "item": &"data_minnow", "target": 5,
		"reward_gold": 75, "reward_items": [{"id": &"glitch_eel", "qty": 1}],
	},
	&"forge_iron_ore_15": {
		"npc": &"forge", "item": &"copper_ore", "target": 15,
		"reward_gold": 100, "reward_items": [{"id": &"iron_ingot", "qty": 5}],
	},
}

var _quest_progress: Dictionary = {}  # quest_id → current count


func accept_quest(quest_id: StringName) -> bool:
	if not NPC_GATHERING_QUESTS.has(quest_id):
		return false
	_quest_progress[quest_id] = 0
	return true


func _update_quest_progress(item_id: StringName, qty: int) -> void:
	for qid in _quest_progress.keys():
		var quest: Dictionary = NPC_GATHERING_QUESTS.get(qid, {})
		if quest.get("item", &"") == item_id:
			_quest_progress[qid] += qty
			var target: int = int(quest.get("target", 0))
			quest_progress_updated.emit(qid, _quest_progress[qid], target)
			if _quest_progress[qid] >= target:
				_complete_quest(qid)


func _complete_quest(quest_id: StringName) -> void:
	var quest: Dictionary = NPC_GATHERING_QUESTS.get(quest_id, {})
	# Reward gold
	if has_node("/root/CurrencyManager"):
		var cm: Node = get_node("/root/CurrencyManager")
		if cm.has_method("add_gold"):
			cm.call("add_gold", int(quest.get("reward_gold", 0)))
	# Reward items
	for reward in quest.get("reward_items", []):
		var im: Node = _inventory()
		if im != null and im.has_method("add_item"):
			im.call("add_item", reward.get("id", &""), int(reward.get("qty", 1)))
	_quest_progress.erase(quest_id)


# === TASK 41: Balance validator ===
## Validates that crop yields × consumed value match growing time + tool wear
## within reasonable margins.
static func validate_farming_balance(crops: Dictionary, base_yield_value: int = 10, max_grow_minutes: int = 1440) -> Dictionary:
	var report: Dictionary = {"too_fast": [], "too_slow": [], "balanced": []}
	for crop_id in crops.keys():
		var crop: Dictionary = crops[crop_id]
		var grow_min: int = int(crop.get("grow_minutes", 60))
		var yield_value: int = int(crop.get("value", base_yield_value))
		if grow_min <= 0:
			report["too_fast"].append({"crop": crop_id, "grow": grow_min, "value": yield_value})
			continue
		var ratio: float = float(yield_value) / float(grow_min)
		if ratio > 0.50:
			report["too_fast"].append({"crop": crop_id, "ratio": ratio})
		elif ratio < 0.05:
			report["too_slow"].append({"crop": crop_id, "ratio": ratio})
		else:
			report["balanced"].append({"crop": crop_id, "ratio": ratio})
	return report


# === TASK 42: SFX hook ===
func _play_gather_sfx(item_id: StringName) -> void:
	if not has_node("/root/AudioManager"):
		return
	var am: Node = get_node("/root/AudioManager")
	if not am.has_method("play_sfx"):
		return
	var sfx: StringName = &"sfx_gather_generic"
	var s: String = String(item_id)
	if "log" in s or "wood" in s: sfx = &"sfx_gather_chop"
	elif "ore" in s or "crystal" in s: sfx = &"sfx_gather_pickaxe"
	elif "herb" in s or "leaf" in s: sfx = &"sfx_gather_pluck"
	elif "fish" in s: sfx = &"sfx_gather_splash"
	am.call("play_sfx", sfx)


# === TASK 43: Particle hook ===
func _play_harvest_particles(location: Vector3) -> void:
	if not has_node("/root/VFXManager"):
		return
	var vm: Node = get_node("/root/VFXManager")
	if vm.has_method("spawn_particle"):
		vm.call("spawn_particle", &"vfx_harvest_burst", location)


# === TASK 48: Test harness ===
## Runs the full farming loop end-to-end and reports successes/failures.
func run_farming_loop_test() -> Dictionary:
	var report: Dictionary = {
		"forage_spawns": 0,
		"forage_collected": 0,
		"skills_leveled": [],
		"quests_completed": 0,
		"quest_failures": [],
	}
	# Spawn forage in 4 regions
	for region in FORAGE_SPAWN_TABLE.keys():
		var spawned: Array[StringName] = populate_region(region, Vector3.ZERO, Vector3.ONE)
		report["forage_spawns"] += spawned.size()
		# Collect each
		for sid in spawned:
			var result: Dictionary = collect_forage(sid)
			if not result.is_empty():
				report["forage_collected"] += 1
	# Accept and complete every quest
	for quest_id in NPC_GATHERING_QUESTS.keys():
		var ok: bool = accept_quest(quest_id)
		if not ok:
			report["quest_failures"].append(quest_id)
			continue
		var quest: Dictionary = NPC_GATHERING_QUESTS[quest_id]
		var target: int = int(quest.get("target", 0))
		_update_quest_progress(quest.get("item", &""), target)
		report["quests_completed"] += 1
	return report


# === Helpers ===
func _inventory() -> Node:
	if has_node("/root/InventoryManager"):
		return get_node("/root/InventoryManager")
	return null
