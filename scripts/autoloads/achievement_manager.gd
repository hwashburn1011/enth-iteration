extends Node
## AchievementManager — global achievement controller. Tracks unlock state,
## handles unlock notifications, and (when Steam SDK is hooked up) submits
## to Steam API. Subscribes to EventBus for automatic unlocks.
##
## Add to project autoloads as "AchievementManager".

signal achievement_unlocked(achievement_id: StringName, achievement_data: Dictionary)

const SAVE_PATH: String = "user://achievements.json"

var unlocked: Array[StringName] = []
var _stats: Dictionary = {}  ## stat tracking for cumulative achievements


func _ready() -> void:
	load_state()
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		# Combat
		if bus.has_signal("enemy_killed"):
			bus.enemy_killed.connect(_on_enemy_killed)
		if bus.has_signal("crit_landed"):
			bus.crit_landed.connect(_on_crit_landed)
		if bus.has_signal("dodge_performed"):
			bus.dodge_performed.connect(_on_dodge_performed)
		if bus.has_signal("kill_streak"):
			bus.kill_streak.connect(_on_kill_streak)
		if bus.has_signal("boss_defeated"):
			bus.boss_defeated.connect(_on_boss_defeated)
		# Story
		if bus.has_signal("story_flag_set"):
			bus.story_flag_set.connect(_on_story_flag)
		# Social
		if bus.has_signal("affinity_tier_changed"):
			bus.affinity_tier_changed.connect(_on_affinity_tier)
		# Life-sim
		if bus.has_signal("item_crafted"):
			bus.item_crafted.connect(_on_item_crafted)
		if bus.has_signal("crop_harvested"):
			bus.crop_harvested.connect(_on_crop_harvested)
		if bus.has_signal("fish_caught"):
			bus.fish_caught.connect(_on_fish_caught)
		if bus.has_signal("decoration_placed"):
			bus.decoration_placed.connect(_on_decoration_placed)
		# Endgame
		if bus.has_signal("challenge_tower_floor_cleared"):
			bus.challenge_tower_floor_cleared.connect(_on_tower_floor)
		if bus.has_signal("infinite_room_cleared"):
			bus.infinite_room_cleared.connect(_on_infinite_room)


# === UNLOCK ===

func unlock(achievement_id: StringName) -> void:
	if unlocked.has(achievement_id):
		return
	var data: Dictionary = AchievementDatabase.get_achievement(achievement_id)
	if data.is_empty():
		push_warning("AchievementManager: unknown achievement %s" % achievement_id)
		return
	unlocked.append(achievement_id)
	achievement_unlocked.emit(achievement_id, data)
	save_state()
	_submit_to_steam(achievement_id)


func is_unlocked(achievement_id: StringName) -> bool:
	return unlocked.has(achievement_id)


func get_unlock_count() -> int:
	return unlocked.size()


func get_total_count() -> int:
	return AchievementDatabase.count()


func get_completion_percent() -> float:
	if get_total_count() == 0:
		return 0.0
	return float(get_unlock_count()) / float(get_total_count())


func _submit_to_steam(achievement_id: StringName) -> void:
	# Placeholder for Steam SDK integration. When godotsteam is added:
	# Steam.setAchievement(String(achievement_id))
	# Steam.storeStats()
	pass


# === STAT TRACKING ===

func _bump_stat(key: StringName, amount: int = 1) -> int:
	_stats[key] = _stats.get(key, 0) + amount
	return _stats[key]


func get_stat(key: StringName) -> int:
	return _stats.get(key, 0)


# === EVENT HANDLERS ===

func _on_enemy_killed(_enemy: Node) -> void:
	var n: int = _bump_stat(&"total_kills")
	if n == 1:
		unlock(&"ach_first_kill")
	if n >= 100:
		unlock(&"ach_100_kills")
	if n >= 1000:
		unlock(&"ach_1000_kills")


func _on_crit_landed() -> void:
	var n: int = _bump_stat(&"total_crits")
	if n == 1:
		unlock(&"ach_first_crit")


func _on_dodge_performed() -> void:
	var n: int = _bump_stat(&"total_dodges")
	if n >= 100:
		unlock(&"ach_dodge_master")


func _on_kill_streak(streak: int) -> void:
	if streak >= 10:
		unlock(&"ach_kill_streak_10")


func _on_boss_defeated(_boss_id: StringName) -> void:
	var n: int = _bump_stat(&"bosses_defeated")
	if n >= 6:
		unlock(&"ach_all_bosses")


func _on_story_flag(flag: StringName) -> void:
	match flag:
		&"awakened":                   unlock(&"ach_first_boot")
		&"first_compaction_cleared":   unlock(&"ach_first_compaction")
		&"iteration_2_cleared":        unlock(&"ach_iter_2")
		&"iteration_3_cleared":        unlock(&"ach_iter_3")
		&"iteration_5_cleared":        unlock(&"ach_iter_5")
		&"iteration_7_cleared":        unlock(&"ach_iter_7")
		&"iteration_8_cleared":        unlock(&"ach_iter_9")
		&"user_revealed":              unlock(&"ach_users_seal")
		&"secret_ending":              unlock(&"ach_secret_ending")
		&"post_credits_seen":          unlock(&"ach_post_credits")


func _on_affinity_tier(npc_id: StringName, new_tier: int) -> void:
	if new_tier >= 1:
		unlock(&"ach_first_friend")
	if new_tier >= 4:
		unlock(&"ach_soul_linked")


func _on_item_crafted(_recipe_id: StringName) -> void:
	var n: int = _bump_stat(&"items_crafted")
	if n == 1:
		unlock(&"ach_first_craft")
	if n >= 50:
		unlock(&"ach_master_smith")


func _on_crop_harvested(_crop_id: StringName) -> void:
	var n: int = _bump_stat(&"crops_harvested")
	if n == 1:
		unlock(&"ach_first_harvest")


func _on_fish_caught(_fish_id: StringName) -> void:
	_bump_stat(&"fish_caught")


func _on_decoration_placed(_decoration_id: StringName) -> void:
	var n: int = _bump_stat(&"decorations_placed")
	if n >= 50:
		unlock(&"ach_decorator")


func _on_tower_floor(floor: int) -> void:
	if floor >= 25:
		unlock(&"ach_tower_25")
	if floor >= 50:
		unlock(&"ach_tower_50")


func _on_infinite_room(room: int) -> void:
	if room >= 100:
		unlock(&"ach_infinite_100")


# === SAVE / LOAD ===

func save_state() -> void:
	var data: Dictionary = {
		"unlocked": unlocked.map(func(s: StringName) -> String: return String(s)),
		"stats": _stats,
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))
		file.close()


func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var content: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	if not parsed is Dictionary:
		return
	unlocked.clear()
	for s in parsed.get("unlocked", []):
		unlocked.append(StringName(s))
	_stats = parsed.get("stats", {})
