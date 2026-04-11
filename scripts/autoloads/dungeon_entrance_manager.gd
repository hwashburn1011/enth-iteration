extends Node
## DungeonEntranceManager — global entrance state. Tracks discovered/unlocked
## entrances, clear counts, best times, daily bonus rotation, story-locked
## reveals.
##
## Add to project autoloads as "DungeonEntranceManager".

signal entrance_discovered(entrance_id: StringName)
signal entrance_unlocked(entrance_id: StringName)
signal entrance_cleared(entrance_id: StringName, clear_time_seconds: int)
signal daily_bonus_changed(new_biome: StringName)

const DAILY_BONUS_REWARDS: Dictionary = {
	"xp_mult": 1.5,
	"material_mult": 1.25,
	"daily_token": 1,
}

var discovered_entrances: Array[StringName] = []
var entrance_clear_counts: Dictionary = {}     ## entrance_id -> int
var entrance_boss_defeats: Dictionary = {}     ## entrance_id -> int
var entrance_best_times: Dictionary = {}       ## entrance_id -> int seconds
var entrance_last_iteration: Dictionary = {}   ## entrance_id -> int
var daily_bonus_biome: StringName = &"server_room"
var last_daily_bonus_date: String = ""


func _ready() -> void:
	_initialize_state()
	_check_daily_bonus()
	_subscribe_to_events()


func _initialize_state() -> void:
	# Auto-discover entrances that are unlocked from start
	for entrance in DungeonEntranceDatabase.get_all():
		if entrance.get("unlock_iteration", 1) == 1 and entrance.get("unlock_quest", &"") == &"":
			discovered_entrances.append(entrance["id"])


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("quest_completed"):
			bus.quest_completed.connect(_on_quest_completed)
		if bus.has_signal("iteration_changed"):
			bus.iteration_changed.connect(_on_iteration_changed)
		if bus.has_signal("dungeon_cleared"):
			bus.dungeon_cleared.connect(_on_dungeon_cleared)
		if bus.has_signal("boss_defeated"):
			bus.boss_defeated.connect(_on_boss_defeated)


# === DISCOVERY ===

func discover_entrance(entrance_id: StringName) -> bool:
	if discovered_entrances.has(entrance_id):
		return false
	if DungeonEntranceDatabase.get_entrance(entrance_id).is_empty():
		return false
	discovered_entrances.append(entrance_id)
	entrance_discovered.emit(entrance_id)
	entrance_unlocked.emit(entrance_id)
	return true


func is_discovered(entrance_id: StringName) -> bool:
	return discovered_entrances.has(entrance_id)


func is_unlocked_for_player(entrance_id: StringName, player_iteration: int, completed_quests: Array) -> bool:
	var entrance: Dictionary = DungeonEntranceDatabase.get_entrance(entrance_id)
	if entrance.is_empty():
		return false
	if player_iteration < entrance.get("unlock_iteration", 1):
		return false
	var unlock_quest: StringName = entrance.get("unlock_quest", &"")
	if unlock_quest != &"" and not completed_quests.has(unlock_quest):
		return false
	return true


# === EVENT HANDLERS ===

func _on_quest_completed(quest_id: StringName) -> void:
	# Auto-discover entrances when their unlock quest is completed
	for entrance in DungeonEntranceDatabase.get_all():
		if entrance.get("unlock_quest", &"") == quest_id:
			discover_entrance(entrance["id"])


func _on_iteration_changed(new_iteration: int) -> void:
	# Auto-discover entrances when their unlock iteration is reached
	for entrance in DungeonEntranceDatabase.get_all():
		if entrance.get("unlock_iteration", 1) == new_iteration and entrance.get("unlock_quest", &"") == &"":
			discover_entrance(entrance["id"])


func _on_dungeon_cleared(dungeon_id: StringName, clear_time_seconds: int) -> void:
	# Find the entrance for this dungeon biome
	var entrance: Dictionary = DungeonEntranceDatabase.get_for_biome(dungeon_id)
	if entrance.is_empty():
		return
	var entrance_id: StringName = entrance["id"]
	entrance_clear_counts[entrance_id] = entrance_clear_counts.get(entrance_id, 0) + 1
	var prev_best: int = entrance_best_times.get(entrance_id, 999999)
	if clear_time_seconds < prev_best:
		entrance_best_times[entrance_id] = clear_time_seconds
	entrance_cleared.emit(entrance_id, clear_time_seconds)


func _on_boss_defeated(boss_id: StringName) -> void:
	# Find the entrance whose boss matches
	for entrance in DungeonEntranceDatabase.get_all():
		if entrance.get("boss_id", &"") == boss_id:
			var entrance_id: StringName = entrance["id"]
			entrance_boss_defeats[entrance_id] = entrance_boss_defeats.get(entrance_id, 0) + 1
			break


# === DAILY BONUS ===

func _check_daily_bonus() -> void:
	var today: String = _get_today_date_string()
	if today != last_daily_bonus_date:
		_rotate_daily_bonus(today)
		last_daily_bonus_date = today


func _rotate_daily_bonus(date_string: String) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _date_string_to_seed(date_string)
	var entrances: Array = DungeonEntranceDatabase.get_all()
	var idx: int = rng.randi() % entrances.size()
	daily_bonus_biome = entrances[idx]["biome_id"]
	daily_bonus_changed.emit(daily_bonus_biome)


func is_daily_bonus_biome(biome_id: StringName) -> bool:
	return biome_id == daily_bonus_biome


func get_daily_bonus_rewards() -> Dictionary:
	return DAILY_BONUS_REWARDS.duplicate()


func _get_today_date_string() -> String:
	var dt: Dictionary = Time.get_datetime_dict_from_system(true)
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]


func _date_string_to_seed(date_string: String) -> int:
	var parts: PackedStringArray = date_string.split("-")
	if parts.size() != 3:
		return 0
	return int(parts[0]) * 10000 + int(parts[1]) * 100 + int(parts[2])


# === STATS ===

func get_clear_count(entrance_id: StringName) -> int:
	return entrance_clear_counts.get(entrance_id, 0)


func get_best_time(entrance_id: StringName) -> int:
	return entrance_best_times.get(entrance_id, -1)


func get_total_clears() -> int:
	var total: int = 0
	for n in entrance_clear_counts.values():
		total += n
	return total


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"discovered_entrances": discovered_entrances.map(func(s: StringName) -> String: return String(s)),
		"entrance_clear_counts": entrance_clear_counts,
		"entrance_boss_defeats": entrance_boss_defeats,
		"entrance_best_times": entrance_best_times,
		"entrance_last_iteration": entrance_last_iteration,
		"daily_bonus_biome": String(daily_bonus_biome),
		"last_daily_bonus_date": last_daily_bonus_date,
	}


func from_save_data(data: Dictionary) -> void:
	discovered_entrances.clear()
	for s in data.get("discovered_entrances", []):
		discovered_entrances.append(StringName(s))
	entrance_clear_counts = data.get("entrance_clear_counts", {})
	entrance_boss_defeats = data.get("entrance_boss_defeats", {})
	entrance_best_times = data.get("entrance_best_times", {})
	entrance_last_iteration = data.get("entrance_last_iteration", {})
	daily_bonus_biome = StringName(data.get("daily_bonus_biome", "server_room"))
	last_daily_bonus_date = data.get("last_daily_bonus_date", "")
	_check_daily_bonus()
