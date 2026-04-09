class_name DailyChallenge
extends Node

## Daily Challenge mode. Same seed for everyone each day. Reset at UTC midnight.
## Forces a class + starting modules + modifiers + final boss for the day.

signal daily_started(challenge_data: Dictionary)
signal daily_completed(time_seconds: int)
signal daily_failed
signal new_daily_available(date_string: String)

const CLASS_POOL: PackedStringArray = ["compiler", "daemon", "kernel"]
const BOSS_POOL: PackedStringArray = [
	"corrupted_compiler", "memory_warden", "root_heart",
	"sentinel_prime",
]
const MODIFIER_POOL: PackedStringArray = [
	"no_prompts", "double_damage", "lifesteal_50",
	"cd_x15", "no_compute_regen",
]

var current_daily_data: Dictionary = {}
var last_reset_date: String = ""
var run_active: bool = false
var run_start_time: int = -1

# Persistent stats
var total_completions: int = 0
var current_streak: int = 0
var longest_streak: int = 0
var last_completion_date: String = ""
var daily_tokens: int = 0


func is_unlocked(quest_component: Node) -> bool:
	if quest_component == null:
		return false
	return quest_component.completed_quests.has(StringName("main_05_compaction"))


func _ready() -> void:
	_check_for_new_daily()


func _check_for_new_daily() -> void:
	var today: String = _get_today_date_string()
	if today != last_reset_date:
		_generate_new_daily(today)
		last_reset_date = today
		new_daily_available.emit(today)


func _generate_new_daily(date_string: String) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _date_string_to_int(date_string)

	var class_id: String = CLASS_POOL[rng.randi() % CLASS_POOL.size()]
	var boss_id: String = BOSS_POOL[rng.randi() % BOSS_POOL.size()]
	var modifier_count: int = rng.randi_range(1, 3)
	var modifiers: Array = []
	var pool_copy: Array = MODIFIER_POOL.duplicate()
	for i in modifier_count:
		if pool_copy.is_empty():
			break
		var idx: int = rng.randi() % pool_copy.size()
		modifiers.append(pool_copy[idx])
		pool_copy.remove_at(idx)

	current_daily_data = {
		"date": date_string,
		"class_id": class_id,
		"boss_id": boss_id,
		"modifiers": modifiers,
		"floor_count": 5,
		"seed": rng.seed,
	}


func _get_today_date_string() -> String:
	var dt: Dictionary = Time.get_datetime_dict_from_system(true)
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]


func _date_string_to_int(date_string: String) -> int:
	# Convert "YYYY-MM-DD" to integer seed
	var parts: PackedStringArray = date_string.split("-")
	if parts.size() != 3:
		return 0
	return int(parts[0]) * 10000 + int(parts[1]) * 100 + int(parts[2])


func start_run() -> void:
	if current_daily_data.is_empty():
		return
	run_active = true
	run_start_time = Time.get_unix_time_from_system()
	daily_started.emit(current_daily_data)


func complete_run() -> void:
	if not run_active:
		return
	run_active = false
	var time: int = Time.get_unix_time_from_system() - run_start_time

	var today: String = _get_today_date_string()
	total_completions += 1
	# Update streak
	if last_completion_date == "":
		current_streak = 1
	else:
		var yesterday: String = _get_yesterday_string()
		if last_completion_date == yesterday:
			current_streak += 1
		elif last_completion_date != today:
			current_streak = 1
	last_completion_date = today
	if current_streak > longest_streak:
		longest_streak = current_streak

	# Award daily token
	daily_tokens += 1
	if current_streak % 7 == 0:
		daily_tokens += 5  # weekly bonus

	daily_completed.emit(time)


func _get_yesterday_string() -> String:
	var yesterday_unix: int = Time.get_unix_time_from_system() - 86400
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(yesterday_unix)
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]


func fail_run() -> void:
	if not run_active:
		return
	run_active = false
	current_streak = 0
	daily_failed.emit()


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"current_daily_data": current_daily_data,
		"last_reset_date": last_reset_date,
		"total_completions": total_completions,
		"current_streak": current_streak,
		"longest_streak": longest_streak,
		"last_completion_date": last_completion_date,
		"daily_tokens": daily_tokens,
	}


func from_save_data(data: Dictionary) -> void:
	current_daily_data = data.get("current_daily_data", {})
	last_reset_date = data.get("last_reset_date", "")
	total_completions = data.get("total_completions", 0)
	current_streak = data.get("current_streak", 0)
	longest_streak = data.get("longest_streak", 0)
	last_completion_date = data.get("last_completion_date", "")
	daily_tokens = data.get("daily_tokens", 0)
	_check_for_new_daily()
