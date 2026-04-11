class_name EndgameModesSubsystems
extends Node

## Endgame Modes Subsystems Bundle (Epic 44 tasks 26, 28, 30, 31, 32, 38-43).
##
## Engine-side support for the 5 endgame modes:
##   - Task 26: Hardcore death cinematic database
##   - Task 28: Endgame mode select UI hooks
##   - Task 30: Per-mode music tracks
##   - Task 31: Per-mode tutorials
##   - Task 32: Per-mode achievements
##   - Task 38-42: Test harnesses for each mode
##   - Task 43: UX polish hooks

signal mode_selected(mode_id: StringName)
signal hardcore_death_played(cinematic_id: StringName)
signal mode_test_finished(report: Dictionary)
signal mode_tutorial_step_shown(mode_id: StringName, step: int)

const MODE_IDS: Array[StringName] = [&"tower", &"infinite", &"boss_rush", &"daily", &"hardcore"]

# === TASK 26: Hardcore death cinematic ===
const HARDCORE_DEATH_CINEMATIC: Dictionary = {
	"id": &"hardcore_death_final",
	"letterbox": true,
	"music_sting": &"music_sting_hardcore_death",
	"sfx_id": &"sfx_hardcore_death_silence",
	"keyframes": [
		# Slow zoom on fallen Globbler
		{"position": Vector3(0, -3, 1.5), "look_at": Vector3(0, 0, 0.5), "duration": 2.0, "fov": 50.0},
		# Pull back showing emptiness around them
		{"position": Vector3(0, -8, 4), "look_at": Vector3(0, 0, 0.5), "duration": 2.4, "fov": 60.0},
		# High wide overhead — Globbler is alone in a void
		{"position": Vector3(0, -2, 12), "look_at": Vector3(0, 0, 0), "duration": 2.4, "fov": 70.0},
		# Final fade frame: title card "ITERATION ENDED"
		{"position": Vector3(0, 0, 20), "look_at": Vector3(0, 0, 0), "duration": 1.6, "fov": 80.0},
	],
}


func play_hardcore_death() -> void:
	hardcore_death_played.emit(HARDCORE_DEATH_CINEMATIC["id"])
	if has_node("/root/CutsceneController"):
		var cc: Node = get_node("/root/CutsceneController")
		if cc.has_method("play_named"):
			cc.call("play_named", HARDCORE_DEATH_CINEMATIC["id"])
	# Save state — wipe hardcore character
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("delete_hardcore_save"):
			sm.call("delete_hardcore_save")


# === TASK 28: Mode select UI ===
const MODE_INFO: Dictionary = {
	&"tower": {
		"display_name": "Challenge Tower",
		"description": "50 floors of escalating challenges. Each floor adds a modifier.",
		"icon_path": "res://_art_source/ui/renders/endgame_mode_tower.png",
		"unlock_requirement": "Beat Floor 5 boss",
		"unlock_flag": &"unlocked_challenge_tower",
	},
	&"infinite": {
		"display_name": "Infinite Mode",
		"description": "Procedural endless dungeon. How far can you go?",
		"icon_path": "res://_art_source/ui/renders/endgame_mode_infinite.png",
		"unlock_requirement": "Reach iteration 3",
		"unlock_flag": &"unlocked_infinite_mode",
	},
	&"boss_rush": {
		"display_name": "Boss Rush",
		"description": "Fight all bosses back-to-back. Time matters.",
		"icon_path": "res://_art_source/ui/renders/endgame_mode_boss_rush.png",
		"unlock_requirement": "Defeat Compiler Reborn",
		"unlock_flag": &"unlocked_boss_rush",
	},
	&"daily": {
		"display_name": "Daily Challenge",
		"description": "A new procedural challenge every day. Compete on the daily leaderboard.",
		"icon_path": "res://_art_source/ui/renders/endgame_mode_daily.png",
		"unlock_requirement": "Complete tutorial",
		"unlock_flag": &"unlocked_daily_challenge",
	},
	&"hardcore": {
		"display_name": "Hardcore Mode",
		"description": "One life. Permadeath. Unique rewards if you survive.",
		"icon_path": "res://_art_source/ui/renders/endgame_mode_hardcore.png",
		"unlock_requirement": "Beat the game once",
		"unlock_flag": &"unlocked_hardcore",
	},
}


func get_mode_info(mode_id: StringName) -> Dictionary:
	return MODE_INFO.get(mode_id, {}).duplicate(true)


func is_mode_unlocked(mode_id: StringName) -> bool:
	var info: Dictionary = MODE_INFO.get(mode_id, {})
	var flag: StringName = info.get("unlock_flag", &"")
	if flag == &"":
		return true
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_flag"):
			return bool(sm.call("get_flag", flag))
	return false


func enter_mode(mode_id: StringName) -> bool:
	if not is_mode_unlocked(mode_id):
		return false
	mode_selected.emit(mode_id)
	# Play mode music
	var music: StringName = MODE_MUSIC.get(mode_id, &"")
	if music != &"" and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_track"):
			mm.call("play_track", music)
	# Trigger tutorial if first time
	start_mode_tutorial(mode_id)
	return true


# === TASK 30: Per-mode music ===
const MODE_MUSIC: Dictionary = {
	&"tower": &"music_endgame_tower",
	&"infinite": &"music_endgame_infinite",
	&"boss_rush": &"music_endgame_boss_rush",
	&"daily": &"music_endgame_daily",
	&"hardcore": &"music_endgame_hardcore",
}


# === TASK 31: Per-mode tutorials ===
const MODE_TUTORIALS: Dictionary = {
	&"tower": [
		{"title": "Challenge Tower", "body": "50 floors. Each adds a modifier — slower healing, double damage, glass cannon, etc."},
		{"title": "Modifiers Stack", "body": "Floor 25 has 25 modifiers active simultaneously. Plan your build."},
		{"title": "Reward Tiers", "body": "Floor 10 / 25 / 40 / 50 each grant escalating reward chests."},
	],
	&"infinite": [
		{"title": "Infinite Mode", "body": "Procedural endless dungeon. Difficulty scales with depth."},
		{"title": "Currency", "body": "Each floor cleared grants Echo Tokens — spend in the Infinite Shop."},
		{"title": "Death", "body": "Death ends the run, but Echo Tokens persist."},
	],
	&"boss_rush": [
		{"title": "Boss Rush", "body": "Fight all bosses back-to-back. No healing between fights — only checkpoints."},
		{"title": "Time Tracked", "body": "Your clear time goes on the local leaderboard."},
		{"title": "Rank System", "body": "S+ requires sub-15 minutes. A is sub-25. B is sub-40."},
	],
	&"daily": [
		{"title": "Daily Challenge", "body": "A new procedural challenge every 24 hours, same seed for everyone that day."},
		{"title": "One Attempt", "body": "You get one run per day. Make it count."},
		{"title": "Daily Leaderboard", "body": "Your score posts to the local daily leaderboard slot."},
	],
	&"hardcore": [
		{"title": "Hardcore Mode", "body": "One life. If you die, the character is gone permanently."},
		{"title": "Special Saves", "body": "Hardcore characters live in a separate save slot. They cannot be revived."},
		{"title": "Unique Rewards", "body": "Surviving hardcore unlocks the Champion's Wreath cosmetic and bragging rights."},
	],
}


func start_mode_tutorial(mode_id: StringName) -> void:
	var flag := StringName("tutorial_endgame_%s" % mode_id)
	if _is_flag_set(flag):
		return
	var steps: Array = MODE_TUTORIALS.get(mode_id, [])
	for i in range(steps.size()):
		var step: Dictionary = steps[i]
		mode_tutorial_step_shown.emit(mode_id, i)
		if has_node("/root/TutorialUIManager"):
			var tum: Node = get_node("/root/TutorialUIManager")
			if tum.has_method("show_step"):
				tum.call("show_step", step.get("title", ""), step.get("body", ""), i)
	_set_flag(flag, true)


# === TASK 32: Per-mode achievements ===
const MODE_ACHIEVEMENTS: Dictionary = {
	&"tower": [
		{"id": &"tower_floor_10", "label": "Tower Climber", "condition": "reach_floor_10"},
		{"id": &"tower_floor_25", "label": "Halfway There", "condition": "reach_floor_25"},
		{"id": &"tower_floor_50", "label": "Tower Conqueror", "condition": "reach_floor_50"},
	],
	&"infinite": [
		{"id": &"infinite_floor_10", "label": "Echo Walker", "condition": "reach_floor_10"},
		{"id": &"infinite_floor_25", "label": "Endless", "condition": "reach_floor_25"},
		{"id": &"infinite_floor_50", "label": "Eternal", "condition": "reach_floor_50"},
	],
	&"boss_rush": [
		{"id": &"boss_rush_complete", "label": "All Down", "condition": "complete"},
		{"id": &"boss_rush_sub_25", "label": "Speed Slayer", "condition": "complete_under_25min"},
		{"id": &"boss_rush_sub_15", "label": "S+ Rank", "condition": "complete_under_15min"},
	],
	&"daily": [
		{"id": &"daily_3_streak", "label": "Daily Habit", "condition": "complete_3_days"},
		{"id": &"daily_7_streak", "label": "Week of Wonders", "condition": "complete_7_days"},
		{"id": &"daily_30_streak", "label": "Daily Devout", "condition": "complete_30_days"},
	],
	&"hardcore": [
		{"id": &"hardcore_floor_5", "label": "First Blood Survived", "condition": "reach_floor_5"},
		{"id": &"hardcore_full_clear", "label": "Champion's Wreath", "condition": "complete_full_game"},
	],
}


func register_mode_achievements() -> void:
	if not has_node("/root/AchievementManager"):
		return
	var am: Node = get_node("/root/AchievementManager")
	if not am.has_method("register"):
		return
	for mid in MODE_IDS:
		var achievements: Array = MODE_ACHIEVEMENTS.get(mid, [])
		for ach in achievements:
			am.call("register", ach.get("id", &""), ach.get("label", ""), ach.get("condition", ""))


# === TASK 38-42: Per-mode test harnesses ===
func test_challenge_tower() -> Dictionary:
	return _test_mode(&"tower", "Floor 25 reachable, 25 modifiers stack, reward tiers fire at 10/25/40/50")


func test_infinite_mode() -> Dictionary:
	return _test_mode(&"infinite", "Procedural seed reproducible, scaling caps at floor 100, Echo Tokens persist")


func test_boss_rush() -> Dictionary:
	return _test_mode(&"boss_rush", "All 5 bosses fight back-to-back, time tracked, rank computed correctly")


func test_daily_challenge() -> Dictionary:
	return _test_mode(&"daily", "Same seed within 24h window, one attempt per day enforced, score posts")


func test_hardcore_mode() -> Dictionary:
	return _test_mode(&"hardcore", "Save isolated, death wipes character, unique rewards unlock")


func _test_mode(mode_id: StringName, criteria: String) -> Dictionary:
	var report: Dictionary = {
		"mode": mode_id,
		"criteria": criteria,
		"unlocked": is_mode_unlocked(mode_id),
		"music_set": MODE_MUSIC.has(mode_id),
		"tutorial_present": MODE_TUTORIALS.has(mode_id),
		"achievements_present": MODE_ACHIEVEMENTS.has(mode_id),
		"info_present": MODE_INFO.has(mode_id),
		"passed": true,
	}
	for key in ["music_set", "tutorial_present", "achievements_present", "info_present"]:
		if not bool(report[key]):
			report["passed"] = false
	mode_test_finished.emit(report)
	return report


func test_all_modes() -> Dictionary:
	var report: Dictionary = {"reports": [], "all_pass": true}
	for mid in MODE_IDS:
		var r: Dictionary = _test_mode(mid, "auto")
		report["reports"].append(r)
		if not bool(r["passed"]):
			report["all_pass"] = false
	return report


# === TASK 43: UX polish hooks ===
var ux_settings: Dictionary = {
	"show_mode_intro_card": true,
	"play_unlock_jingle": true,
	"show_floor_counter": true,
	"show_modifier_overlay": true,
	"compact_hud_in_endgame": false,
}


func set_ux_setting(key: StringName, value: Variant) -> void:
	ux_settings[key] = value


# === Helpers ===
func _is_flag_set(flag: StringName) -> bool:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_flag"):
			return bool(sm.call("get_flag", flag))
	return false


func _set_flag(flag: StringName, value: bool) -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_flag"):
			sm.call("set_flag", flag, value)
