class_name AchievementDatabase
extends RefCounted

## Static catalog of all 50 Steam-ready achievements with display name,
## description, hidden flag, and Steam API id.

const ACHIEVEMENTS: Array = [
	# === STORY (10) ===
	{"id": &"ach_first_boot",         "name": "First Boot",         "desc": "Wake up for the first time.",                "hidden": false, "category": &"story"},
	{"id": &"ach_first_compaction",   "name": "First Compaction",   "desc": "Defeat the Corrupted Compiler for the first time.", "hidden": false, "category": &"story"},
	{"id": &"ach_iter_2",             "name": "Echo",               "desc": "Complete iteration 2.",                       "hidden": false, "category": &"story"},
	{"id": &"ach_iter_3",             "name": "Specialization",     "desc": "Complete iteration 3 and choose a class.",    "hidden": false, "category": &"story"},
	{"id": &"ach_iter_5",             "name": "Halfway",            "desc": "Complete iteration 5.",                       "hidden": false, "category": &"story"},
	{"id": &"ach_iter_7",             "name": "The Truth",          "desc": "Complete iteration 7.",                       "hidden": true,  "category": &"story"},
	{"id": &"ach_iter_9",             "name": "End of Cycle",       "desc": "Complete the main story.",                    "hidden": true,  "category": &"story"},
	{"id": &"ach_secret_ending",      "name": "What Lies Beyond",   "desc": "Discover the secret ending.",                 "hidden": true,  "category": &"story"},
	{"id": &"ach_post_credits",       "name": "Post-Credit",        "desc": "Watch the post-credits scene.",               "hidden": true,  "category": &"story"},
	{"id": &"ach_users_seal",         "name": "User's Mark",        "desc": "Find the User's Seal.",                       "hidden": false, "category": &"story"},

	# === COMBAT (10) ===
	{"id": &"ach_first_kill",         "name": "First Blood",        "desc": "Defeat your first enemy.",                    "hidden": false, "category": &"combat"},
	{"id": &"ach_100_kills",          "name": "Veteran",            "desc": "Defeat 100 enemies.",                         "hidden": false, "category": &"combat"},
	{"id": &"ach_1000_kills",         "name": "Legion",             "desc": "Defeat 1,000 enemies.",                       "hidden": false, "category": &"combat"},
	{"id": &"ach_no_hit_boss",        "name": "Untouchable",        "desc": "Defeat any boss without taking damage.",      "hidden": false, "category": &"combat"},
	{"id": &"ach_compiler_under_90s", "name": "Optimized",          "desc": "Defeat the Corrupted Compiler in under 90 seconds.", "hidden": false, "category": &"combat"},
	{"id": &"ach_first_crit",         "name": "Critical",           "desc": "Land your first critical hit.",               "hidden": false, "category": &"combat"},
	{"id": &"ach_kill_streak_10",     "name": "Unstoppable",        "desc": "Get a 10-kill streak.",                       "hidden": false, "category": &"combat"},
	{"id": &"ach_dodge_master",       "name": "Reflex",             "desc": "Dodge 100 attacks (using dash i-frames).",    "hidden": false, "category": &"combat"},
	{"id": &"ach_finish_with_prompt", "name": "Last Sip",           "desc": "Survive a fatal hit by using a healing prompt at <5% HP.", "hidden": true,  "category": &"combat"},
	{"id": &"ach_all_bosses",         "name": "Boss Slayer",        "desc": "Defeat all 6 bosses.",                        "hidden": false, "category": &"combat"},

	# === EXPLORATION (8) ===
	{"id": &"ach_all_floors_clear",   "name": "Cartographer",       "desc": "Clear every floor in every dungeon biome.",   "hidden": false, "category": &"exploration"},
	{"id": &"ach_secret_room",        "name": "Curious",            "desc": "Find a secret room.",                          "hidden": false, "category": &"exploration"},
	{"id": &"ach_all_secret_rooms",   "name": "Detective",          "desc": "Find every secret room.",                      "hidden": true,  "category": &"exploration"},
	{"id": &"ach_all_biomes",         "name": "Tourist",            "desc": "Visit all 4 dungeon biomes.",                  "hidden": false, "category": &"exploration"},
	{"id": &"ach_hidden_quest",       "name": "Hidden Path",        "desc": "Complete a hidden quest.",                     "hidden": true,  "category": &"exploration"},
	{"id": &"ach_all_lore",           "name": "Loremaster",         "desc": "Read every lore tablet.",                      "hidden": false, "category": &"exploration"},
	{"id": &"ach_explore_wilderness", "name": "Open Sky",           "desc": "Find every wilderness landmark.",              "hidden": false, "category": &"exploration"},
	{"id": &"ach_iteration_memorial", "name": "Remember",           "desc": "Visit the Iteration Memorial.",                "hidden": true,  "category": &"exploration"},

	# === SOCIAL (8) ===
	{"id": &"ach_first_friend",       "name": "First Friend",       "desc": "Reach Friend tier with any NPC.",              "hidden": false, "category": &"social"},
	{"id": &"ach_soul_linked",        "name": "Soul-Linked",        "desc": "Reach Soul-Linked tier with any NPC.",         "hidden": false, "category": &"social"},
	{"id": &"ach_all_npcs_friends",   "name": "Town Hero",          "desc": "Reach Friend with all 12 NPCs.",               "hidden": false, "category": &"social"},
	{"id": &"ach_all_npcs_max",       "name": "Heart of Town",      "desc": "Reach Soul-Linked with all 12 NPCs.",          "hidden": true,  "category": &"social"},
	{"id": &"ach_birthday_master",    "name": "Birthday Master",    "desc": "Give a loved gift on every NPC birthday in one iteration.", "hidden": false, "category": &"social"},
	{"id": &"ach_all_companions",     "name": "Full Party",         "desc": "Recruit all 4 companions.",                    "hidden": false, "category": &"social"},
	{"id": &"ach_all_pets",           "name": "Pet Collector",      "desc": "Own all 8 pets.",                              "hidden": false, "category": &"social"},
	{"id": &"ach_avatar_faction",     "name": "Avatar",             "desc": "Reach Avatar tier with any faction.",          "hidden": true,  "category": &"social"},

	# === LIFE-SIM (8) ===
	{"id": &"ach_first_craft",        "name": "First Craft",        "desc": "Craft any item.",                              "hidden": false, "category": &"life_sim"},
	{"id": &"ach_master_smith",       "name": "Master Smith",       "desc": "Craft 50 items.",                              "hidden": false, "category": &"life_sim"},
	{"id": &"ach_all_recipes",        "name": "Grand Compiler",     "desc": "Discover all 85 recipes.",                     "hidden": true,  "category": &"life_sim"},
	{"id": &"ach_first_harvest",      "name": "Green Thumb",        "desc": "Harvest your first crop.",                     "hidden": false, "category": &"life_sim"},
	{"id": &"ach_all_crops",          "name": "Diversifier",        "desc": "Grow all 20 crop types.",                      "hidden": false, "category": &"life_sim"},
	{"id": &"ach_all_fish",           "name": "Master Angler",      "desc": "Catch all 15 fish.",                           "hidden": false, "category": &"life_sim"},
	{"id": &"ach_decorator",          "name": "Interior Designer",  "desc": "Place 50 decorations.",                        "hidden": false, "category": &"life_sim"},
	{"id": &"ach_theme_set_bonus",    "name": "Themed",             "desc": "Activate any theme set bonus in your home.",   "hidden": false, "category": &"life_sim"},

	# === ENDGAME / CHALLENGE (6) ===
	{"id": &"ach_tower_25",           "name": "Tower Climber",      "desc": "Reach floor 25 in Challenge Tower.",           "hidden": false, "category": &"endgame"},
	{"id": &"ach_tower_50",           "name": "Tower Lord",         "desc": "Defeat the Tower Lord (floor 50).",            "hidden": true,  "category": &"endgame"},
	{"id": &"ach_infinite_100",       "name": "Infinite",           "desc": "Clear 100 rooms in Infinite Mode.",            "hidden": false, "category": &"endgame"},
	{"id": &"ach_boss_rush",          "name": "Speedrunner",        "desc": "Complete Boss Rush in under 30 minutes.",      "hidden": false, "category": &"endgame"},
	{"id": &"ach_daily_30",           "name": "Daily Devotion",     "desc": "Complete 30 daily challenges.",                "hidden": false, "category": &"endgame"},
	{"id": &"ach_hardcore_clear",     "name": "Iron Will",          "desc": "Beat the main story in Hardcore Mode.",        "hidden": true,  "category": &"endgame"},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return ACHIEVEMENTS


static func get_achievement(id: StringName) -> Dictionary:
	if _index.is_empty():
		for a in ACHIEVEMENTS:
			_index[a["id"]] = a
	return _index.get(id, {})


static func get_by_category(cat: StringName) -> Array:
	var result: Array = []
	for a in ACHIEVEMENTS:
		if a["category"] == cat:
			result.append(a)
	return result


static func count() -> int:
	return ACHIEVEMENTS.size()
