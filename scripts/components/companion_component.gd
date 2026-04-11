class_name CompanionComponent
extends Node

## Player-side companion management. Tracks recruited companions, their
## levels/XP, equipped gear, allocated skills, currently active companion,
## and the command state (attack/defend/etc).

signal companion_recruited(companion_id: StringName)
signal companion_summoned(companion_id: StringName)
signal companion_dismissed(companion_id: StringName)
signal companion_leveled_up(companion_id: StringName, new_level: int)
signal companion_downed(companion_id: StringName)
signal companion_revived(companion_id: StringName)
signal command_changed(new_command: StringName)

const COMMANDS: PackedStringArray = ["attack", "defend", "ability", "wait", "follow"]

## companion_id → { recruited, level, xp, hp, equipped_gear, allocated_skills, ult_cooldown_remaining }
var companion_state: Dictionary = {}
var active_companion_id: StringName = &""
var current_command: StringName = &"follow"


func _ready() -> void:
	# Initialize state for all companions (recruited=false)
	for c in CompanionDatabase.get_all():
		companion_state[c["id"]] = {
			"recruited": false,
			"level": 1,
			"xp": 0,
			"current_hp": float(c["max_hp"]),
			"max_hp": float(c["max_hp"]),
			"equipped_gear": {},
			"allocated_skills": {},
			"ultimate_cooldown_remaining": 0.0,
		}

	# Subscribe to events
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("enemy_killed"):
			bus.enemy_killed.connect(_on_enemy_killed)
		if bus.has_signal("quest_completed"):
			bus.quest_completed.connect(_on_quest_completed)


# === RECRUITMENT ===

func recruit(companion_id: StringName) -> bool:
	var state: Dictionary = companion_state.get(companion_id)
	if state == null or state.get("recruited", false):
		return false
	state["recruited"] = true
	companion_recruited.emit(companion_id)
	return true


func is_recruited(companion_id: StringName) -> bool:
	return companion_state.get(companion_id, {}).get("recruited", false)


func get_recruited_count() -> int:
	var count: int = 0
	for k: StringName in companion_state.keys():
		if companion_state[k].get("recruited", false):
			count += 1
	return count


func _on_quest_completed(quest_id: StringName) -> void:
	# Auto-recruit companions when their recruit quest is completed
	for c in CompanionDatabase.get_all():
		if c.get("recruit_quest") == quest_id:
			recruit(c["id"])


# === SUMMON / DISMISS ===

func summon(companion_id: StringName) -> bool:
	if not is_recruited(companion_id):
		return false
	if active_companion_id != &"":
		dismiss()
	active_companion_id = companion_id
	companion_summoned.emit(companion_id)
	return true


func dismiss() -> void:
	if active_companion_id == &"":
		return
	var prev: StringName = active_companion_id
	active_companion_id = &""
	companion_dismissed.emit(prev)


# === XP / LEVEL ===

func grant_xp(companion_id: StringName, amount: int) -> void:
	var state: Dictionary = companion_state.get(companion_id)
	if state == null or not state.get("recruited", false):
		return
	state["xp"] = state.get("xp", 0) + amount
	# Check level up
	while _xp_required_for_level(state["level"] + 1) <= state["xp"] and state["level"] < 50:
		state["level"] += 1
		state["max_hp"] *= 1.05
		companion_leveled_up.emit(companion_id, state["level"])


func _xp_required_for_level(level: int) -> int:
	return 100 * level * level


func _on_enemy_killed(_enemy: Node) -> void:
	if active_companion_id == &"":
		return
	# Companion present at the kill earns 50% of base XP (25 default)
	grant_xp(active_companion_id, 12)


# === HP / DOWNED ===

func damage(companion_id: StringName, amount: float) -> void:
	var state: Dictionary = companion_state.get(companion_id)
	if state == null:
		return
	state["current_hp"] = max(0.0, state["current_hp"] - amount)
	if state["current_hp"] <= 0.0:
		_on_downed(companion_id)


func heal(companion_id: StringName, amount: float) -> void:
	var state: Dictionary = companion_state.get(companion_id)
	if state == null:
		return
	state["current_hp"] = min(state["max_hp"], state["current_hp"] + amount)


func _on_downed(companion_id: StringName) -> void:
	companion_downed.emit(companion_id)
	# Affinity penalty for letting them go down
	var c: Dictionary = CompanionDatabase.get_companion(companion_id)
	var affinity_npc: StringName = c.get("affinity_npc", &"")
	if affinity_npc != &"":
		var aff: Node = _get_affinity_component()
		if aff != null and aff.has_method("change_affinity"):
			aff.change_affinity(affinity_npc, -25)


func revive(companion_id: StringName) -> void:
	var state: Dictionary = companion_state.get(companion_id)
	if state == null:
		return
	state["current_hp"] = state["max_hp"] * 0.5
	companion_revived.emit(companion_id)
	# Affinity bonus for the revive
	var c: Dictionary = CompanionDatabase.get_companion(companion_id)
	var affinity_npc: StringName = c.get("affinity_npc", &"")
	if affinity_npc != &"":
		var aff: Node = _get_affinity_component()
		if aff != null and aff.has_method("change_affinity"):
			aff.change_affinity(affinity_npc, 25)


# === COMMAND ===

func set_command(command: StringName) -> void:
	if not (command in COMMANDS):
		push_warning("CompanionComponent: invalid command %s" % command)
		return
	current_command = command
	command_changed.emit(command)


# === ABILITIES ===

func can_use_ultimate(companion_id: StringName) -> bool:
	var state: Dictionary = companion_state.get(companion_id, {})
	return state.get("ultimate_cooldown_remaining", 0.0) <= 0.0


func use_ultimate(companion_id: StringName) -> bool:
	if not can_use_ultimate(companion_id):
		return false
	var c: Dictionary = CompanionDatabase.get_companion(companion_id)
	var cd: float = c.get("ultimate_cd", 60.0)
	companion_state[companion_id]["ultimate_cooldown_remaining"] = cd
	return true


func tick_cooldowns(delta: float) -> void:
	for k: StringName in companion_state.keys():
		var state: Dictionary = companion_state[k]
		state["ultimate_cooldown_remaining"] = max(0.0, state.get("ultimate_cooldown_remaining", 0.0) - delta)


# === HELPERS ===

func _get_affinity_component() -> Node:
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player") if get_tree() != null else []
	if players.is_empty():
		return null
	return players[0].get_node_or_null("AffinityComponent")


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var states_str: Dictionary = {}
	for k: StringName in companion_state.keys():
		states_str[String(k)] = companion_state[k]
	return {
		"companion_state": states_str,
		"active_companion_id": String(active_companion_id),
		"current_command": String(current_command),
	}


func from_save_data(data: Dictionary) -> void:
	for k in data.get("companion_state", {}).keys():
		companion_state[StringName(k)] = data["companion_state"][k]
	active_companion_id = StringName(data.get("active_companion_id", ""))
	current_command = StringName(data.get("current_command", "follow"))
