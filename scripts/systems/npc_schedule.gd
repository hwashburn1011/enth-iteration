class_name NPCSchedule
extends RefCounted

## Per-NPC daily schedule data + lookup. Each schedule maps in-game hours
## to (location, animation) tuples. The NPCScheduleController autoload
## queries this on hour_changed events.

const SCHEDULES: Dictionary = {
	&"pixel": [
		{"hour": 6,  "location": &"home_pixel",  "anim": &"sleep"},
		{"hour": 7,  "location": &"shop_pixel",  "anim": &"walk"},
		{"hour": 8,  "location": &"shop_pixel",  "anim": &"shopkeep"},
		{"hour": 18, "location": &"shop_pixel",  "anim": &"closing"},
		{"hour": 19, "location": &"tavern",      "anim": &"social"},
		{"hour": 22, "location": &"home_pixel",  "anim": &"walk"},
		{"hour": 23, "location": &"home_pixel",  "anim": &"sleep"},
	],
	&"forge": [
		{"hour": 5,  "location": &"home_forge",  "anim": &"wake"},
		{"hour": 6,  "location": &"forge_shop",  "anim": &"hammer"},
		{"hour": 19, "location": &"home_forge",  "anim": &"walk"},
		{"hour": 21, "location": &"home_forge",  "anim": &"sleep"},
	],
	&"cache": [
		{"hour": 8,  "location": &"home_cache",  "anim": &"wake"},
		{"hour": 11, "location": &"tavern",      "anim": &"prep"},
		{"hour": 12, "location": &"tavern",      "anim": &"barkeep"},
		{"hour": 2,  "location": &"home_cache",  "anim": &"sleep"},
	],
	&"index": [
		{"hour": 6,  "location": &"library",     "anim": &"organize"},
		{"hour": 9,  "location": &"library",     "anim": &"librarian"},
		{"hour": 20, "location": &"home_index",  "anim": &"reading"},
		{"hour": 23, "location": &"home_index",  "anim": &"sleep"},
	],
	&"harvest": [
		{"hour": 4,  "location": &"farm",        "anim": &"farming"},
		{"hour": 18, "location": &"home_harvest","anim": &"walk"},
		{"hour": 21, "location": &"home_harvest","anim": &"sleep"},
	],
	&"bit": [
		{"hour": 7,  "location": &"home_bit",    "anim": &"wake"},
		{"hour": 9,  "location": &"town_square", "anim": &"playing"},
		{"hour": 12, "location": &"home_bit",    "anim": &"lunch"},
		{"hour": 13, "location": &"farm",        "anim": &"playing"},
		{"hour": 18, "location": &"home_bit",    "anim": &"dinner"},
		{"hour": 20, "location": &"home_bit",    "anim": &"sleep"},
	],
	&"legacy": [
		{"hour": 6,  "location": &"memorial",    "anim": &"contemplating"},
		{"hour": 10, "location": &"town_square", "anim": &"sitting"},
		{"hour": 14, "location": &"library",     "anim": &"reading"},
		{"hour": 19, "location": &"home_legacy", "anim": &"walk"},
		{"hour": 22, "location": &"home_legacy", "anim": &"sleep"},
	],
	&"trade": [
		{"hour": 7,  "location": &"market_stall","anim": &"prep"},
		{"hour": 8,  "location": &"market_stall","anim": &"merchant"},
		{"hour": 19, "location": &"home_trade",  "anim": &"walk"},
		{"hour": 22, "location": &"home_trade",  "anim": &"sleep"},
	],
	&"lab": [
		{"hour": 8,  "location": &"lab",         "anim": &"experiment"},
		{"hour": 21, "location": &"home_lab",    "anim": &"walk"},
		{"hour": 23, "location": &"home_lab",    "anim": &"sleep"},
	],
	&"render": [
		{"hour": 9,  "location": &"studio",      "anim": &"painting"},
		{"hour": 19, "location": &"home_render", "anim": &"walk"},
		{"hour": 22, "location": &"home_render", "anim": &"sleep"},
	],
	&"sync": [
		{"hour": 10, "location": &"lounge",      "anim": &"playing_music"},
		{"hour": 23, "location": &"lounge",      "anim": &"closing"},
		{"hour": 0,  "location": &"home_sync",   "anim": &"sleep"},
	],
	&"sentinel": [
		{"hour": 6,  "location": &"watchtower",  "anim": &"patrol"},
		{"hour": 18, "location": &"watchtower",  "anim": &"changeover"},
		{"hour": 19, "location": &"home_sentinel","anim": &"walk"},
		{"hour": 21, "location": &"home_sentinel","anim": &"sleep"},
	],
}


static func get_schedule(npc_id: StringName) -> Array:
	return SCHEDULES.get(npc_id, [])


static func get_current_stop(npc_id: StringName, current_hour: int) -> Dictionary:
	## Returns the most recent schedule stop for this NPC at this hour.
	var schedule: Array = get_schedule(npc_id)
	if schedule.is_empty():
		return {}
	var best: Dictionary = schedule[0]
	for stop in schedule:
		if stop["hour"] <= current_hour and stop["hour"] >= best["hour"]:
			best = stop
	# Handle wrap-around (e.g. hour 0 stops are after hour 23 stops)
	if best["hour"] > current_hour:
		# Look for a wrap-around stop
		for stop in schedule:
			if stop["hour"] >= 0 and stop["hour"] <= current_hour:
				return stop
	return best


static func get_npc_count() -> int:
	return SCHEDULES.size()
