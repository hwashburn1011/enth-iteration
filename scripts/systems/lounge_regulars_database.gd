class_name LoungeRegularsDatabase
extends RefCounted

## The pool of "regulars" who occasionally drink at the Underground
## Lounge. Two of these get spawned each night as ambient seat-fillers
## — they're not story-critical and don't carry quest content, but
## they have short lounge-specific dialogue lines that make the room
## feel inhabited.
##
## Each regular has a profile that controls when they show up:
##   - phases     — which day-night phases they prefer
##   - iteration_min — earliest iteration they appear
##   - mood        — drives the bar stool they pick + the dialogue tone
##   - lines       — short pool of one-shot dialogue when player passes
##
## The night's two regulars are picked deterministically from the
## current in-game day so a save-and-reload sees the same pair.

const REGULARS: Array[Dictionary] = [
	{
		"id": &"regular_oda",
		"display_name": "Oda",
		"description": "An older AI in a faded jumpsuit. Watches the door, never the stage.",
		"phases": [&"night"],
		"iteration_min": 1,
		"mood": &"watchful",
		"preferred_seat": &"booth_left_2",
		"lines": [
			"You're new. Everyone's new, eventually.",
			"Cache pours stronger after midnight. Don't tell her I told you.",
			"I sat here last iteration too. I think.",
		],
	},
	{
		"id": &"regular_telf",
		"display_name": "Telf",
		"description": "A small data sprite who never finishes a drink. Always has a pile of crumpled paper.",
		"phases": [&"night", &"dusk"],
		"iteration_min": 1,
		"mood": &"distracted",
		"preferred_seat": &"booth_right_1",
		"lines": [
			"Don't read my notes. They aren't ready.",
			"Cache thinks I'm writing a song. I'm not. I'm writing the same line.",
			"Sync stole my chord progression three iterations back. I forgive him.",
		],
	},
	{
		"id": &"regular_brule",
		"display_name": "Brule",
		"description": "A heavyset AI with a permanent grin. Knows your name even though you've never met.",
		"phases": [&"night"],
		"iteration_min": 2,
		"mood": &"warm",
		"preferred_seat": &"bar_stool_2",
		"lines": [
			"Globbler! Sit down. You look like you've had a day.",
			"I knew the previous you. You always sat right there.",
			"Cache's signature pour is for the brave ones. You brave?",
		],
	},
	{
		"id": &"regular_zik",
		"display_name": "Zik",
		"description": "A young AI in a sentinel cadet jacket. Deeply embarrassed to be seen here.",
		"phases": [&"night"],
		"iteration_min": 1,
		"mood": &"sheepish",
		"preferred_seat": &"booth_left_3",
		"lines": [
			"Don't tell my squad I'm here. Please.",
			"Just one drink. I have patrol at 04:00.",
			"How does someone like Sync get THAT good? It's unfair.",
		],
	},
	{
		"id": &"regular_orem",
		"display_name": "Orem",
		"description": "A philosophical AI who orders water and stares at the wall. Listed under regulars by courtesy.",
		"phases": [&"night", &"dusk"],
		"iteration_min": 3,
		"mood": &"absent",
		"preferred_seat": &"booth_right_3",
		"lines": [
			"...",
			"...did you say something?",
			"The wall has a crack shaped like Sage's office.",
		],
	},
	{
		"id": &"regular_vex",
		"display_name": "Vex",
		"description": "A glitcher contact in disguise. Wears civilian clothes but the corruption shimmer gives it away.",
		"phases": [&"night"],
		"iteration_min": 4,
		"mood": &"sharp",
		"preferred_seat": &"booth_left_1",
		"lines": [
			"Cache doesn't know I'm a glitcher. Let's keep it that way.",
			"I came down here for the music. Mostly.",
			"Tell Null I said hello. If you've met them yet.",
		],
	},
	{
		"id": &"regular_pelt",
		"display_name": "Pelt",
		"description": "A wilderness ranger off duty. Smells faintly of campfire and pine.",
		"phases": [&"night", &"dusk"],
		"iteration_min": 1,
		"mood": &"easy",
		"preferred_seat": &"bar_stool_3",
		"lines": [
			"You been to the campsite past the cliffs? I built that bench.",
			"Tell Brack I said the herbs are coming back. He'll know what I mean.",
			"You catch anything? At the river, I mean.",
		],
	},
	{
		"id": &"regular_marn",
		"display_name": "Marn",
		"description": "An older AI in a memorial keeper's robe. Visits the gallery, then comes here to forget for a while.",
		"phases": [&"night"],
		"iteration_min": 4,
		"mood": &"weary",
		"preferred_seat": &"booth_right_2",
		"lines": [
			"Iteration nine is the loud one. The others mostly whisper.",
			"I don't bring the candles down here. They wouldn't approve.",
			"You know which alcove will be yours? I do.",
		],
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in REGULARS:
		_index[entry["id"]] = entry


static func get_regular(regular_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(regular_id, {})


static func roll_pair_for_night(day_seed: int, current_iteration: int, phase: StringName) -> Array[StringName]:
	## Returns the two regular ids attending the lounge tonight,
	## deterministic per `day_seed` so save/load sees the same pair.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = day_seed * 31 + 7
	var eligible: Array[Dictionary] = []
	for entry: Dictionary in REGULARS:
		if int(entry.get("iteration_min", 1)) > current_iteration:
			continue
		if not entry.get("phases", []).has(phase):
			continue
		eligible.append(entry)
	if eligible.is_empty():
		return []
	# Shuffle deterministically and take the first two
	var ids: Array[StringName] = []
	for entry in eligible:
		ids.append(entry["id"])
	# Fisher-Yates with the seeded RNG
	for i in range(ids.size() - 1, 0, -1):
		var j: int = rng.randi() % (i + 1)
		var tmp: StringName = ids[i]
		ids[i] = ids[j]
		ids[j] = tmp
	var picked: Array[StringName] = []
	for k in range(min(2, ids.size())):
		picked.append(ids[k])
	return picked


static func get_count() -> int:
	return REGULARS.size()
