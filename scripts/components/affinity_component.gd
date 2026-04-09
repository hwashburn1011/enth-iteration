class_name AffinityComponent
extends Node

## Player-side affinity tracker. Owns: per-NPC affinity, mood, last_gift_day,
## last_talk_day, completed personal quests, gifts given counts. Handles
## affinity gain/loss, tier transitions, daily decay, and gift validation.

signal affinity_changed(npc_id: StringName, new_affinity: int, new_tier: int)
signal tier_advanced(npc_id: StringName, new_tier: int)
signal gift_given(npc_id: StringName, item_id: StringName, preference: StringName, affinity_delta: int)
signal personal_quest_unlocked(npc_id: StringName, quest_id: StringName)

const TIER_THRESHOLDS: PackedInt32Array = [0, 100, 250, 500, 800]
const TIER_NAMES: PackedStringArray = ["Stranger", "Friend", "Confidant", "Bond", "Soul-Linked"]

const PREFERENCE_GAIN: Dictionary = {
	&"loved":     30,
	&"liked":     15,
	&"neutral":    3,
	&"disliked": -10,
	&"hated":    -25,
}

var npc_state: Dictionary = {}  ## npc_id -> { affinity, mood, last_gift_day, ... }


func _ready() -> void:
	# Initialize state for all NPCs
	for n in NPCDatabase.get_all():
		npc_state[n["id"]] = {
			"affinity": 0,
			"mood": &"neutral",
			"last_gift_day": -1,
			"last_talk_day": -1,
			"completed_personal_quests": [],
			"birthday_gifts_given": 0,
		}

	# Subscribe to day advance for decay + mood reset
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("day_advanced"):
			bus.day_advanced.connect(_on_day_advanced)


func get_affinity(npc_id: StringName) -> int:
	return npc_state.get(npc_id, {}).get("affinity", 0)


func get_tier(npc_id: StringName) -> int:
	var aff: int = get_affinity(npc_id)
	for i in range(TIER_THRESHOLDS.size() - 1, -1, -1):
		if aff >= TIER_THRESHOLDS[i]:
			return i
	return 0


func get_tier_name(npc_id: StringName) -> String:
	return TIER_NAMES[get_tier(npc_id)]


func change_affinity(npc_id: StringName, delta: int) -> int:
	if not npc_state.has(npc_id):
		return 0
	var state: Dictionary = npc_state[npc_id]
	var old_tier: int = get_tier(npc_id)

	# Apply mood multiplier (only on positive gains)
	if delta > 0:
		var mood: StringName = state.get("mood", &"neutral")
		match mood:
			&"happy":   delta = int(round(delta * 1.25))
			&"tired":   delta = int(round(delta * 0.75))
			&"sad":     delta = int(round(delta * 0.5))
			&"angry":   delta = int(round(delta * 0.25))

	state["affinity"] = max(0, state["affinity"] + delta)
	var new_tier: int = get_tier(npc_id)
	affinity_changed.emit(npc_id, state["affinity"], new_tier)

	if new_tier > old_tier:
		tier_advanced.emit(npc_id, new_tier)
		_unlock_tier_rewards(npc_id, new_tier)

	return state["affinity"]


func _unlock_tier_rewards(npc_id: StringName, tier: int) -> void:
	# Confidant unlocks personal quests
	if tier == 2:
		var npc: Dictionary = NPCDatabase.get_npc(npc_id)
		for q in npc.get("personal_quests", []):
			personal_quest_unlocked.emit(npc_id, q)


# === GIFT GIVING ===

func can_give_gift(npc_id: StringName, current_day: int) -> bool:
	var state: Dictionary = npc_state.get(npc_id, {})
	return state.get("last_gift_day", -1) != current_day


func give_gift(npc_id: StringName, item_id: StringName, current_day: int, is_birthday: bool = false) -> Dictionary:
	## Returns { success: bool, preference: StringName, delta: int, was_birthday_bonus: bool }
	if not can_give_gift(npc_id, current_day):
		return {"success": false, "preference": &"none", "delta": 0, "was_birthday_bonus": false}

	var preference: StringName = NPCDatabase.get_gift_preference(npc_id, item_id)
	var delta: int = PREFERENCE_GAIN.get(preference, 3)

	# Birthday bonus: loved gifts on birthday give +75 instead of +30
	var birthday_bonus: bool = false
	if is_birthday and preference == &"loved":
		delta = 75
		birthday_bonus = true
		var state: Dictionary = npc_state[npc_id]
		state["birthday_gifts_given"] = state.get("birthday_gifts_given", 0) + 1

	change_affinity(npc_id, delta)
	npc_state[npc_id]["last_gift_day"] = current_day

	# Sad mood if hated, happy if loved
	if preference == &"hated":
		set_mood(npc_id, &"angry")
	elif preference == &"loved":
		set_mood(npc_id, &"happy")

	gift_given.emit(npc_id, item_id, preference, delta)
	return {"success": true, "preference": preference, "delta": delta, "was_birthday_bonus": birthday_bonus}


# === DIALOGUE / TALK ===

func record_talk(npc_id: StringName, current_day: int) -> int:
	## First talk of the day grants +5 affinity. Returns gain delta.
	var state: Dictionary = npc_state.get(npc_id)
	if state == null:
		return 0
	if state.get("last_talk_day", -1) == current_day:
		return 0
	state["last_talk_day"] = current_day
	return change_affinity(npc_id, 5) - get_affinity(npc_id) + 5  # always 5 here


# === MOOD ===

func set_mood(npc_id: StringName, mood: StringName) -> void:
	if not npc_state.has(npc_id):
		return
	npc_state[npc_id]["mood"] = mood


func get_mood(npc_id: StringName) -> StringName:
	return npc_state.get(npc_id, {}).get("mood", &"neutral")


# === DAILY TICK ===

func _on_day_advanced(new_day: int) -> void:
	for npc_id: StringName in npc_state.keys():
		var state: Dictionary = npc_state[npc_id]
		# Decay if not talked to in 5+ days
		var last_talk: int = state.get("last_talk_day", -1)
		if last_talk >= 0 and (new_day - last_talk) >= 5:
			var current_aff: int = state["affinity"]
			var tier_floor: int = TIER_THRESHOLDS[get_tier(npc_id)]
			if current_aff > tier_floor:
				state["affinity"] = max(tier_floor, current_aff - 5)
				affinity_changed.emit(npc_id, state["affinity"], get_tier(npc_id))
		# Reset mood to neutral
		state["mood"] = &"neutral"


# === PERSONAL QUESTS ===

func mark_personal_quest_complete(npc_id: StringName, quest_id: StringName) -> void:
	var state: Dictionary = npc_state.get(npc_id)
	if state == null:
		return
	var done: Array = state.get("completed_personal_quests", [])
	if quest_id in done:
		return
	done.append(quest_id)
	state["completed_personal_quests"] = done
	change_affinity(npc_id, 50)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var entries: Dictionary = {}
	for k: StringName in npc_state.keys():
		var state: Dictionary = npc_state[k].duplicate()
		state["mood"] = String(state["mood"])
		state["completed_personal_quests"] = state["completed_personal_quests"].map(func(s: StringName) -> String: return String(s))
		entries[String(k)] = state
	return entries


func from_save_data(data: Dictionary) -> void:
	for k in data.keys():
		var state: Dictionary = data[k].duplicate()
		state["mood"] = StringName(state.get("mood", "neutral"))
		var quests: Array = []
		for s in state.get("completed_personal_quests", []):
			quests.append(StringName(s))
		state["completed_personal_quests"] = quests
		npc_state[StringName(k)] = state
