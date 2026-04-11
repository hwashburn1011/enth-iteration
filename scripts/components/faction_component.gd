class_name FactionComponent
extends Node

## Player-side faction reputation tracker. Per-faction rep with rank progression,
## opposition penalties at higher ranks, faction quest completion tracking,
## and chosen-faction state for story branches.

signal reputation_changed(faction_id: StringName, new_rep: int, new_rank: int)
signal rank_advanced(faction_id: StringName, new_rank: int)
signal faction_quest_completed(faction_id: StringName, quest_id: StringName)
signal faction_chosen(faction_id: StringName)

var faction_state: Dictionary = {}  ## faction_id -> { reputation: int, completed_quests: Array }
var chosen_faction: StringName = &""  ## "" = neutral
var faction_war_history: Array[Dictionary] = []


func _ready() -> void:
	# Initialize all factions to 0
	for f in FactionDatabase.get_all_factions():
		faction_state[f["id"]] = {
			"reputation": 0,
			"completed_quests": [],
		}


# === REPUTATION ===

func get_reputation(faction_id: StringName) -> int:
	return faction_state.get(faction_id, {}).get("reputation", 0)


func get_rank(faction_id: StringName) -> int:
	return FactionDatabase.get_rank_for_rep(get_reputation(faction_id))


func get_rank_name(faction_id: StringName) -> String:
	return FactionDatabase.get_rank_name(get_rank(faction_id))


func change_reputation(faction_id: StringName, delta: int) -> void:
	if not faction_state.has(faction_id):
		return
	var state: Dictionary = faction_state[faction_id]
	var old_rep: int = state["reputation"]
	var old_rank: int = get_rank(faction_id)
	state["reputation"] = max(0, min(1000, old_rep + delta))
	var new_rank: int = get_rank(faction_id)

	reputation_changed.emit(faction_id, state["reputation"], new_rank)

	if new_rank > old_rank:
		rank_advanced.emit(faction_id, new_rank)
		# Apply opposition penalty if reaching Member or above
		if delta > 0 and new_rank >= 2:
			_apply_opposition_penalty(faction_id, delta, new_rank)


func _apply_opposition_penalty(rising_faction_id: StringName, gain_amount: int, current_rank: int) -> void:
	## Higher ranks pull opposing factions down
	var f: Dictionary = FactionDatabase.get_faction(rising_faction_id)
	var opposes: Array = f.get("opposes", [])
	var penalty: int = 0
	match current_rank:
		2: penalty = -int(gain_amount * 0.25)  # Member: 25% loss
		3: penalty = -int(gain_amount * 0.50)  # Officer: 50% loss
		4, 5: penalty = -int(gain_amount * 0.75)  # Champion+: 75% loss

	for opp_id: StringName in opposes:
		var opp_state: Dictionary = faction_state.get(opp_id)
		if opp_state == null:
			continue
		var old_opp_rep: int = opp_state["reputation"]
		opp_state["reputation"] = max(0, old_opp_rep + penalty)
		reputation_changed.emit(opp_id, opp_state["reputation"], get_rank(opp_id))


# === FACTION QUESTS ===

func complete_faction_quest(faction_id: StringName, quest_id: StringName) -> void:
	var state: Dictionary = faction_state.get(faction_id)
	if state == null:
		return
	var done: Array = state.get("completed_quests", [])
	if quest_id in done:
		return
	done.append(quest_id)
	state["completed_quests"] = done

	var quest: Dictionary = FactionDatabase.get_faction_quest(quest_id)
	var rep_reward: int = quest.get("rep", 0)
	change_reputation(faction_id, rep_reward)

	faction_quest_completed.emit(faction_id, quest_id)


# === CHOSEN FACTION ===

func choose_faction(faction_id: StringName) -> bool:
	if get_rank(faction_id) < 4:  # Must be Champion or higher
		return false
	chosen_faction = faction_id
	faction_chosen.emit(faction_id)
	return true


func is_neutral() -> bool:
	## Returns true if no faction is above Recruit rank
	for f_id: StringName in faction_state.keys():
		if get_rank(f_id) > 1:
			return false
	return true


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var entries: Dictionary = {}
	for k: StringName in faction_state.keys():
		var state: Dictionary = faction_state[k].duplicate()
		state["completed_quests"] = state["completed_quests"].map(
			func(s: StringName) -> String: return String(s))
		entries[String(k)] = state
	return {
		"faction_state": entries,
		"chosen_faction": String(chosen_faction),
		"faction_war_history": faction_war_history,
	}


func from_save_data(data: Dictionary) -> void:
	var entries: Dictionary = data.get("faction_state", {})
	for k in entries.keys():
		var state: Dictionary = entries[k].duplicate()
		var quests: Array = []
		for s in state.get("completed_quests", []):
			quests.append(StringName(s))
		state["completed_quests"] = quests
		faction_state[StringName(k)] = state
	chosen_faction = StringName(data.get("chosen_faction", ""))
	faction_war_history = data.get("faction_war_history", [])
