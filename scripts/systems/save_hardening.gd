class_name SaveHardening
extends RefCounted
## R8 Epic AJ — Save/load hardening and achievement/kill counter persistence.

const SAVE_VERSION: int = 8


## AJ1-AJ2: Wire achievement data into save pipeline.
static func save_achievements(save_data: Dictionary) -> void:
	save_data["achievements"] = AchievementSystem.to_save_data()

static func load_achievements(save_data: Dictionary) -> void:
	if save_data.has("achievements"):
		AchievementSystem.from_save_data(save_data["achievements"] as Dictionary)


## AJ3: Save infinite mode high score.
static func save_infinite_high_score(save_data: Dictionary) -> void:
	save_data["infinite_best_floor"] = ChallengeContent.get_infinite_high_score()

static func load_infinite_high_score(save_data: Dictionary) -> void:
	if save_data.has("infinite_best_floor"):
		GameManager.set_meta(ChallengeContent.INFINITE_HIGH_SCORE_KEY, int(save_data["infinite_best_floor"]))


## AJ5: Save kill counters per enemy type.
static func save_kill_counters(save_data: Dictionary) -> void:
	save_data["kill_counters"] = EnemyContent.get_all_kill_counts()

static func load_kill_counters(save_data: Dictionary) -> void:
	if save_data.has("kill_counters"):
		var counts: Dictionary = save_data["kill_counters"] as Dictionary
		for enemy_type: String in counts:
			GameManager.set_meta(StringName("kills_%s" % enemy_type), int(counts[enemy_type]))


## AJ7: Graceful load of pre-R8 saves — defaults missing fields.
static func apply_defaults(save_data: Dictionary) -> Dictionary:
	if not save_data.has("save_version"):
		save_data["save_version"] = 0
	if not save_data.has("achievements"):
		save_data["achievements"] = {"unlocked": []}
	if not save_data.has("infinite_best_floor"):
		save_data["infinite_best_floor"] = 0
	if not save_data.has("kill_counters"):
		save_data["kill_counters"] = {}
	return save_data


## AJ8: Add save version header.
static func stamp_version(save_data: Dictionary) -> void:
	save_data["save_version"] = SAVE_VERSION


## AJ9: Corrupt save recovery — try backup if primary fails.
static func safe_load_json(path: String, backup_path: String) -> Dictionary:
	var data: Dictionary = _try_load(path)
	if data.is_empty() and not backup_path.is_empty():
		data = _try_load(backup_path)
	return apply_defaults(data)


static func _try_load(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return {}
	if json.data is Dictionary:
		return json.data as Dictionary
	return {}
