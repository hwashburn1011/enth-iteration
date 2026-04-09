class_name CinematicDatabase
extends RefCounted

## Static catalog of all cinematics with metadata. Each cinematic also has
## a corresponding script in scripts/cinematics/ that builds the timeline.

const CINEMATICS: Array = [
	# Main story
	{"id": &"opening",                "name": "Awakening",          "category": &"opening",    "duration": 90, "trigger": &"new_game"},
	{"id": &"iter_1_to_2",            "name": "First Echo",         "category": &"iteration",  "duration": 30, "trigger": &"iteration_1_complete"},
	{"id": &"iter_2_to_3",            "name": "Choice",             "category": &"iteration",  "duration": 30, "trigger": &"iteration_2_complete"},
	{"id": &"iter_3_to_4",            "name": "Glitch",             "category": &"iteration",  "duration": 30, "trigger": &"iteration_3_complete"},
	{"id": &"iter_4_to_5",            "name": "Memory",             "category": &"iteration",  "duration": 30, "trigger": &"iteration_4_complete"},
	{"id": &"iter_5_to_6",            "name": "The User's Mark",    "category": &"iteration",  "duration": 30, "trigger": &"iteration_5_complete"},
	{"id": &"iter_6_to_7",            "name": "The Faction Choice", "category": &"iteration",  "duration": 30, "trigger": &"iteration_6_complete"},
	{"id": &"iter_7_to_8",            "name": "The Truth",          "category": &"iteration",  "duration": 30, "trigger": &"iteration_7_complete"},
	{"id": &"iter_8_to_9",            "name": "The Final Loop",     "category": &"iteration",  "duration": 30, "trigger": &"iteration_8_complete"},
	{"id": &"final_ending",           "name": "End of Cycle",       "category": &"ending",     "duration": 240, "trigger": &"compiler_reborn_defeated"},
	{"id": &"post_credits",           "name": "Post-Credits",       "category": &"ending",     "duration": 30,  "trigger": &"final_ending_finished"},

	# Utility / one-shots
	{"id": &"first_compaction",       "name": "First Compaction",   "category": &"first_time", "duration": 15, "trigger": &"compaction_portal_first_use"},
	{"id": &"first_boss_kill",        "name": "First Boss Kill",    "category": &"first_time", "duration": 8,  "trigger": &"any_boss_first_kill"},
	{"id": &"town_arrival",           "name": "Town Arrival",       "category": &"first_time", "duration": 10, "trigger": &"town_first_visit"},
	{"id": &"player_death",           "name": "System Failure",     "category": &"death",      "duration": 5,  "trigger": &"player_died"},

	# NPC recruit (6)
	{"id": &"recruit_patch",          "name": "Recruit: Patch",     "category": &"recruit",    "duration": 10, "trigger": &"main_12_companion"},
	{"id": &"recruit_ping",           "name": "Recruit: Ping",      "category": &"recruit",    "duration": 10, "trigger": &"side_lab_companion"},
	{"id": &"recruit_mend",           "name": "Recruit: Mend",      "category": &"recruit",    "duration": 10, "trigger": &"main_18_friend_indeed"},
	{"id": &"recruit_hex",            "name": "Recruit: Hex",       "category": &"recruit",    "duration": 10, "trigger": &"main_29_lost_npc"},
	{"id": &"recruit_companion_5",    "name": "Recruit: 5",         "category": &"recruit",    "duration": 10, "trigger": &"side_companion_5"},
	{"id": &"recruit_companion_6",    "name": "Recruit: 6",         "category": &"recruit",    "duration": 10, "trigger": &"side_companion_6"},

	# Affinity max (12)
	{"id": &"affinity_max_pixel",     "name": "Pixel: Soul-Linked",   "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_pixel"},
	{"id": &"affinity_max_forge",     "name": "Forge: Soul-Linked",   "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_forge"},
	{"id": &"affinity_max_cache",     "name": "Cache: Soul-Linked",   "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_cache"},
	{"id": &"affinity_max_index",     "name": "Index: Soul-Linked",   "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_index"},
	{"id": &"affinity_max_harvest",   "name": "Harvest: Soul-Linked", "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_harvest"},
	{"id": &"affinity_max_bit",       "name": "Bit: Soul-Linked",     "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_bit"},
	{"id": &"affinity_max_legacy",    "name": "Legacy: Soul-Linked",  "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_legacy"},
	{"id": &"affinity_max_trade",     "name": "Trade: Soul-Linked",   "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_trade"},
	{"id": &"affinity_max_lab",       "name": "Lab: Soul-Linked",     "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_lab"},
	{"id": &"affinity_max_render",    "name": "Render: Soul-Linked",  "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_render"},
	{"id": &"affinity_max_sync",      "name": "Sync: Soul-Linked",    "category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_sync"},
	{"id": &"affinity_max_sentinel",  "name": "Sentinel: Soul-Linked","category": &"affinity_max", "duration": 20, "trigger": &"affinity_max_sentinel"},

	# Secret discovery (15)
	# (auto-generated as "secret_<id>" entries — placeholder list)
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return CINEMATICS


static func get_cinematic(id: StringName) -> Dictionary:
	if _index.is_empty():
		for c in CINEMATICS:
			_index[c["id"]] = c
	return _index.get(id, {})


static func get_by_category(cat: StringName) -> Array:
	var result: Array = []
	for c in CINEMATICS:
		if c["category"] == cat:
			result.append(c)
	return result


static func get_by_trigger(trigger: StringName) -> StringName:
	for c in CINEMATICS:
		if c.get("trigger", &"") == trigger:
			return c["id"]
	return &""


static func count() -> int:
	return CINEMATICS.size()
