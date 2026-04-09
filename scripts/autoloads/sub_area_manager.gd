extends Node
## SubAreaManager — tracks sub-area discovery + reward claim state.
##
## Sub-areas are hidden pockets of content tied to town districts and
## wilderness zones. Discovery is sticky — once found, a sub-area remains
## known across iterations. Rewards are claimed once per save file.
##
## Add to project autoloads as "SubAreaManager".
##
## See `_bmad-output/town/sub_areas_bible.md` for the full design.

signal subarea_discovered(sub_area_id: StringName)
signal subarea_reward_claimed(sub_area_id: StringName, reward: Dictionary)
signal subarea_discovery_failed(sub_area_id: StringName, reason: StringName)

var discovered_subareas: Array[StringName] = []
var claimed_rewards: Array[StringName] = []


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("zone_entered"):
			bus.zone_entered.connect(_on_zone_entered)


# === DISCOVERY ===

func discover_subarea(sub_area_id: StringName) -> bool:
	if discovered_subareas.has(sub_area_id):
		return false

	var entry: Dictionary = SubAreaDatabase.get_sub_area(sub_area_id)
	if entry.is_empty():
		push_warning("SubAreaManager: unknown sub-area '%s'" % sub_area_id)
		return false

	if not _passes_gate(entry):
		subarea_discovery_failed.emit(sub_area_id, &"gate_locked")
		return false

	discovered_subareas.append(sub_area_id)
	subarea_discovered.emit(sub_area_id)

	# Mirror discovery into world map for the marker pin
	if has_node("/root/WorldMapManager"):
		var wmm: Node = get_node("/root/WorldMapManager")
		if wmm.has_method("mark_discovered"):
			wmm.mark_discovered(entry.get("parent_region", &""))

	# Achievement hooks
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("subarea_discovered"):
			bus.emit_signal("subarea_discovered", sub_area_id)

	# Auto-claim simple rewards (lore tablets, titles); gated rewards
	# (NPC unlocks, faction unlocks) are handled by the consumer.
	var reward: Dictionary = entry.get("discovery_reward", {})
	if not reward.is_empty():
		_grant_reward(sub_area_id, reward)

	return true


func _passes_gate(entry: Dictionary) -> bool:
	var gate: StringName = entry.get("hidden_behind", &"none")
	var iteration_gate: int = entry.get("discovery_iteration_gate", 0)

	if iteration_gate > 0 and has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method("get_current_iteration"):
			if im.get_current_iteration() < iteration_gate:
				return false

	match gate:
		&"none", &"vine_ladder", &"walk_through_waterfall":
			# Spatial puzzles — getting here means you solved them
			return true
		&"affinity_confidant_sage":
			return _affinity_at_least(&"sage", &"confidant")
		&"affinity_friend_cache":
			return _affinity_at_least(&"cache", &"friend")
		&"iteration_4_story", &"iteration_5_story":
			# Iteration gate already checked above
			return true
	return true


func _affinity_at_least(npc_id: StringName, tier: StringName) -> bool:
	if not has_node("/root/AffinityManager"):
		# Permissive when system not loaded — caller can re-check later
		return true
	var am: Node = get_node("/root/AffinityManager")
	if am.has_method("is_at_least_tier"):
		return am.is_at_least_tier(npc_id, tier)
	return true


# === REWARDS ===

func _grant_reward(sub_area_id: StringName, reward: Dictionary) -> void:
	if claimed_rewards.has(sub_area_id):
		return
	claimed_rewards.append(sub_area_id)
	subarea_reward_claimed.emit(sub_area_id, reward)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("reward_granted"):
			bus.emit_signal("reward_granted", reward)


func has_claimed_reward(sub_area_id: StringName) -> bool:
	return claimed_rewards.has(sub_area_id)


# === QUERIES ===

func is_discovered(sub_area_id: StringName) -> bool:
	return discovered_subareas.has(sub_area_id)


func get_discovered_count() -> int:
	return discovered_subareas.size()


func get_total_count() -> int:
	return SubAreaDatabase.get_count()


func get_discovered_in_region(region_id: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	for entry: Dictionary in SubAreaDatabase.get_for_region(region_id):
		var sid: StringName = entry["id"]
		if discovered_subareas.has(sid):
			result.append(sid)
	return result


# === EVENT HANDLERS ===

func _on_zone_entered(zone_id: StringName, _env_preset: StringName) -> void:
	# Some sub-areas have their own zone trigger; if a zone matches a
	# sub-area connector id, attempt discovery.
	for entry: Dictionary in SubAreaDatabase.get_all():
		if entry.get("connects_from", &"") == zone_id:
			discover_subarea(entry["id"])


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var d: Array = []
	for sid in discovered_subareas:
		d.append(String(sid))
	var c: Array = []
	for sid in claimed_rewards:
		c.append(String(sid))
	return {
		"discovered_subareas": d,
		"claimed_rewards": c,
	}


func from_save_data(data: Dictionary) -> void:
	discovered_subareas.clear()
	for s in data.get("discovered_subareas", []):
		discovered_subareas.append(StringName(s))
	claimed_rewards.clear()
	for s in data.get("claimed_rewards", []):
		claimed_rewards.append(StringName(s))
