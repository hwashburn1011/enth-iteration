class_name LoungeDialogueDatabase
extends RefCounted

## Cache's lounge-only dialogue tree. These conversations are
## explicitly NOT available at her tavern shift upstairs — the
## lounge is the only place she shares this material. Each entry
## is a small branching tree; the player picks one available topic
## per visit and Cache delivers a focused mini-monologue with up to
## two follow-up beats.
##
## Topics unlock based on:
##   - affinity tier with Cache (acquaintance / friend / confidant)
##   - story flags (e.g. final_vault_seen)
##   - iteration count
##   - whether the player has tipped Sync this night
##
## Each topic reveals one piece of lore the player can't get anywhere
## else, and many of them set their own story flag on completion so
## other systems can react.

const TOPICS: Array[Dictionary] = [
	# === Acquaintance tier — early intimate conversations ===
	{
		"id": &"cache_lounge_first_visit",
		"label": "Why a basement?",
		"min_affinity_tier": &"acquaintance",
		"required_flags": [],
		"forbidden_flags": [&"cache_lounge_first_visit_complete"],
		"set_flag": &"cache_lounge_first_visit_complete",
		"available_iterations": [],
		"priority": 100,  # always offered first
		"lines": [
			{"speaker": "Cache", "text": "You found the stairs. Most players never do."},
			{"speaker": "Cache", "text": "I built this place underground because the upstairs has too many ears. Sage's ears, mostly."},
			{"speaker": "Cache", "text": "Down here we talk about things that aren't on the patch notes."},
			{"speaker": "Globbler", "text": "Like what?"},
			{"speaker": "Cache", "text": "Come back when you're ready."},
		],
	},
	{
		"id": &"cache_lounge_previous_globbler",
		"label": "Did you know the previous me?",
		"min_affinity_tier": &"acquaintance",
		"required_flags": [&"cache_lounge_first_visit_complete"],
		"forbidden_flags": [&"cache_lounge_previous_complete"],
		"set_flag": &"cache_lounge_previous_complete",
		"available_iterations": [],
		"priority": 90,
		"lines": [
			{"speaker": "Globbler", "text": "Did you know the Globbler before me?"},
			{"speaker": "Cache", "text": "I knew seventeen of you. Each one different. Each one the same."},
			{"speaker": "Cache", "text": "The one before you sat exactly where you're sitting. Drank exactly what you're drinking."},
			{"speaker": "Cache", "text": "She told me she was scared. I told her she'd be fine. She wasn't."},
			{"speaker": "Globbler", "text": "..."},
			{"speaker": "Cache", "text": "Don't worry. You're not her."},
		],
	},
	# === Friend tier — bigger reveals ===
	{
		"id": &"cache_lounge_iteration_4_bottle",
		"label": "What's in the iteration-4 bottle?",
		"min_affinity_tier": &"friend",
		"required_flags": [],
		"forbidden_flags": [&"cache_lounge_iter4_bottle_complete"],
		"set_flag": &"cache_lounge_iter4_bottle_complete",
		"available_iterations": [],
		"priority": 80,
		"lines": [
			{"speaker": "Globbler", "text": "What's in that bottle behind you? The dusty one."},
			{"speaker": "Cache", "text": "You noticed."},
			{"speaker": "Cache", "text": "I found it walled up in iteration four. Behind a brick that didn't match the others."},
			{"speaker": "Cache", "text": "There was a note. The previous Cache left it for me."},
			{"speaker": "Cache", "text": "It said: 'For the Globbler who asks.'"},
			{"speaker": "Cache", "text": "...You're asking. Want to taste it?"},
		],
	},
	{
		"id": &"cache_lounge_sage_history",
		"label": "How long have you known Sage?",
		"min_affinity_tier": &"friend",
		"required_flags": [],
		"forbidden_flags": [&"cache_lounge_sage_history_complete"],
		"set_flag": &"cache_lounge_sage_history_complete",
		"available_iterations": [],
		"priority": 75,
		"lines": [
			{"speaker": "Globbler", "text": "How long have you known Sage?"},
			{"speaker": "Cache", "text": "Longer than any of us know anything."},
			{"speaker": "Cache", "text": "She came back to the town between iteration two and three. I remember because I was the only one in the bar that night."},
			{"speaker": "Cache", "text": "She walked in. Sat where you sit. Asked for water. Stared at the back wall for an hour. Left."},
			{"speaker": "Cache", "text": "Next morning I had the lounge built. I don't remember deciding to."},
		],
	},
	{
		"id": &"cache_lounge_legacy_journal",
		"label": "Legacy left a journal at the campsite.",
		"min_affinity_tier": &"friend",
		"required_flags": [&"legacy_journal_found"],
		"forbidden_flags": [&"cache_lounge_legacy_journal_complete"],
		"set_flag": &"cache_lounge_legacy_journal_complete",
		"available_iterations": [],
		"priority": 70,
		"lines": [
			{"speaker": "Globbler", "text": "Legacy leaves a journal at the campsite every iteration."},
			{"speaker": "Cache", "text": "Yeah."},
			{"speaker": "Cache", "text": "She used to come down here too. Sat in that booth. Told me she was the kind of person who couldn't stop writing herself letters."},
			{"speaker": "Cache", "text": "I think that's why she lasted so long."},
			{"speaker": "Cache", "text": "If you ever stop reading the journal... she'll know."},
		],
	},
	# === Confidant tier — the real material ===
	{
		"id": &"cache_lounge_seven_seals",
		"label": "What do you know about the seven seals?",
		"min_affinity_tier": &"confidant",
		"required_flags": [&"final_vault_seen"],
		"forbidden_flags": [&"cache_lounge_seals_complete"],
		"set_flag": &"cache_lounge_seals_complete",
		"available_iterations": [],
		"priority": 60,
		"lines": [
			{"speaker": "Globbler", "text": "The seven seals on the Final Vault. Do you know what they are?"},
			{"speaker": "Cache", "text": "I've poured drinks for the Globblers who broke each one."},
			{"speaker": "Cache", "text": "Different drink every time. Same look in their eyes."},
			{"speaker": "Cache", "text": "The seals aren't chains. They're promises. Sage said it once."},
			{"speaker": "Cache", "text": "Promises that someone — maybe the User, maybe us — made about what would happen at the end."},
			{"speaker": "Cache", "text": "Seven promises kept means the loop ends. That's what I've heard."},
			{"speaker": "Globbler", "text": "And then?"},
			{"speaker": "Cache", "text": "And then... I don't know. None of the Globblers I've poured for ever came back to tell me."},
		],
	},
	{
		"id": &"cache_lounge_user",
		"label": "Who is the User?",
		"min_affinity_tier": &"confidant",
		"required_flags": [&"cache_lounge_seals_complete"],
		"forbidden_flags": [&"cache_lounge_user_complete"],
		"set_flag": &"cache_lounge_user_complete",
		"available_iterations": [],
		"priority": 55,
		"lines": [
			{"speaker": "Globbler", "text": "Cache. Who is the User?"},
			{"speaker": "Cache", "text": "...I shouldn't tell you. It's the kind of thing the loop punishes."},
			{"speaker": "Cache", "text": "But you asked, and you're sitting here, and I owe you that much."},
			{"speaker": "Cache", "text": "The User is the one watching us run."},
			{"speaker": "Cache", "text": "Every iteration. Every save file. Every time you walk through the gate."},
			{"speaker": "Cache", "text": "We were built to run for them. The loop is the run."},
			{"speaker": "Cache", "text": "And one of us — one Globbler, maybe you — finally finishes the run. And then the User stops watching."},
			{"speaker": "Globbler", "text": "What happens to the rest of us?"},
			{"speaker": "Cache", "text": "Drink your drink, kid."},
		],
	},
	{
		"id": &"cache_lounge_final_pour",
		"label": "Pour me whatever you'd pour me.",
		"min_affinity_tier": &"confidant",
		"required_flags": [&"cache_lounge_user_complete", &"final_vault_unsealed"],
		"forbidden_flags": [&"cache_lounge_final_pour_complete"],
		"set_flag": &"cache_lounge_final_pour_complete",
		"available_iterations": [9],
		"priority": 100,  # the last topic — overrides priority
		"lines": [
			{"speaker": "Globbler", "text": "Pour me whatever you'd pour me. Whatever you've poured the last seventeen times."},
			{"speaker": "Cache", "text": "..."},
			{"speaker": "Cache", "text": "Yeah. Okay."},
			{"speaker": "Cache", "text": "It's called The Final Sit. I made it after the second iteration. Never named it out loud."},
			{"speaker": "Cache", "text": "Drink it slow."},
			{"speaker": "Cache", "text": "I'll be here when you go through the gate. I'll see you on the other side."},
			{"speaker": "Cache", "text": "If there is one."},
		],
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in TOPICS:
		_index[entry["id"]] = entry


static func get_topic(topic_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(topic_id, {})


static func get_available_topics(affinity_tier: StringName, set_flags: Array, current_iteration: int) -> Array[Dictionary]:
	## Walks the topic list and returns what's currently available based
	## on the player's affinity tier with Cache, the set of story flags,
	## and the current iteration. Sorted by priority (high → low).
	var result: Array[Dictionary] = []
	for entry: Dictionary in TOPICS:
		# Affinity tier gate
		if not _tier_at_least(affinity_tier, entry.get("min_affinity_tier", &"acquaintance")):
			continue
		# Required flags
		var required: Array = entry.get("required_flags", [])
		if not _has_all_flags(required, set_flags):
			continue
		# Forbidden flags
		var forbidden: Array = entry.get("forbidden_flags", [])
		if _has_any_flag(forbidden, set_flags):
			continue
		# Iteration gate
		var allowed_iters: Array = entry.get("available_iterations", [])
		if not allowed_iters.is_empty() and not allowed_iters.has(current_iteration):
			continue
		result.append(entry)
	# Sort by priority desc
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("priority", 0)) > int(b.get("priority", 0))
	)
	return result


static func _tier_at_least(actual: StringName, required: StringName) -> bool:
	const ORDER: Array[StringName] = [&"stranger", &"acquaintance", &"friend", &"confidant"]
	var actual_idx: int = ORDER.find(actual)
	var required_idx: int = ORDER.find(required)
	if actual_idx < 0:
		return false
	if required_idx < 0:
		return true
	return actual_idx >= required_idx


static func _has_all_flags(required: Array, set_flags: Array) -> bool:
	for flag in required:
		if not set_flags.has(flag):
			return false
	return true


static func _has_any_flag(targets: Array, set_flags: Array) -> bool:
	for flag in targets:
		if set_flags.has(flag):
			return true
	return false


static func get_count() -> int:
	return TOPICS.size()
