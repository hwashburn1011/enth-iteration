extends Node
## WorldMapManager — global map state. Tracks discovered/explored regions,
## fast travel unlocks, waypoint, player notes, and per-region completion.
##
## Add to project autoloads as "WorldMapManager".

signal region_discovered(region_id: StringName)
signal region_explored(region_id: StringName)
signal fast_travel_unlocked(region_id: StringName)
signal fast_travel_started(from_id: StringName, to_id: StringName)
signal fast_travel_finished(to_id: StringName)
signal waypoint_set(position: Vector2)
signal waypoint_cleared

var discovered_regions: Array[StringName] = []
var explored_regions: Array[StringName] = []
var fast_travel_unlocked: Array[StringName] = []
var current_region_id: StringName = &"town_commons"
var waypoint_position: Vector2 = Vector2.ZERO
var waypoint_active: bool = false
var player_notes: Dictionary = {}  ## Vector2 -> String
var region_completion: Dictionary = {}  ## region_id -> Dict { npcs_talked, quests_done, lore_read, secrets_found }


func _ready() -> void:
	# Auto-discover default regions
	for region_id: StringName in RegionDatabase.get_default_discovered():
		discover_region(region_id)
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("zone_entered"):
			bus.zone_entered.connect(_on_zone_entered)
		if bus.has_signal("npc_talked_to"):
			bus.npc_talked_to.connect(_on_npc_talked_to)
		if bus.has_signal("quest_completed"):
			bus.quest_completed.connect(_on_quest_completed)
		if bus.has_signal("lore_tablet_read"):
			bus.lore_tablet_read.connect(_on_lore_read)
		if bus.has_signal("secret_room_found"):
			bus.secret_room_found.connect(_on_secret_room_found)


# === DISCOVERY ===

func discover_region(region_id: StringName) -> bool:
	if discovered_regions.has(region_id):
		return false
	if RegionDatabase.get_region(region_id).is_empty():
		return false
	discovered_regions.append(region_id)
	region_discovered.emit(region_id)
	# Auto-unlock fast travel when discovered
	unlock_fast_travel(region_id)
	return true


func mark_explored(region_id: StringName) -> bool:
	if explored_regions.has(region_id):
		return false
	if not discovered_regions.has(region_id):
		discover_region(region_id)
	explored_regions.append(region_id)
	region_explored.emit(region_id)
	return true


func is_discovered(region_id: StringName) -> bool:
	return discovered_regions.has(region_id)


func is_explored(region_id: StringName) -> bool:
	return explored_regions.has(region_id)


# === FAST TRAVEL ===

func unlock_fast_travel(region_id: StringName) -> bool:
	if fast_travel_unlocked.has(region_id):
		return false
	fast_travel_unlocked.append(region_id)
	fast_travel_unlocked_signal_helper(region_id)
	return true


func fast_travel_unlocked_signal_helper(region_id: StringName) -> void:
	fast_travel_unlocked.emit(region_id)


func can_fast_travel_to(region_id: StringName) -> bool:
	if not fast_travel_unlocked.has(region_id):
		return false
	# No fast travel during combat or from inside dungeons
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.get("in_combat") == true:
			return false
	return true


func fast_travel(target_region_id: StringName) -> bool:
	if not can_fast_travel_to(target_region_id):
		return false
	var from_id: StringName = current_region_id
	fast_travel_started.emit(from_id, target_region_id)
	# The actual scene loading is handled by the SceneTransition system
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("scene_transition_requested"):
			bus.scene_transition_requested.emit(target_region_id)
	current_region_id = target_region_id
	fast_travel_finished.emit(target_region_id)
	return true


# === WAYPOINT ===

func set_waypoint(world_position: Vector2) -> void:
	waypoint_position = world_position
	waypoint_active = true
	waypoint_set.emit(world_position)


func clear_waypoint() -> void:
	waypoint_active = false
	waypoint_cleared.emit()


# === NOTES ===

func add_note(map_position: Vector2, text: String) -> void:
	if text.is_empty():
		return
	# Use rounded coordinates as keys to allow approximate hits
	var key: Vector2 = Vector2(round(map_position.x), round(map_position.y))
	player_notes[key] = text


func remove_note_at(map_position: Vector2, radius: float = 10.0) -> void:
	for k in player_notes.keys():
		if (k as Vector2).distance_to(map_position) <= radius:
			player_notes.erase(k)
			break


func get_notes() -> Dictionary:
	return player_notes


# === COMPLETION TRACKING ===

func _ensure_completion_record(region_id: StringName) -> Dictionary:
	if not region_completion.has(region_id):
		region_completion[region_id] = {
			"npcs_talked": [],
			"quests_done": [],
			"lore_read": [],
			"secrets_found": [],
		}
	return region_completion[region_id]


func _on_zone_entered(zone_id: StringName, _env_preset: StringName) -> void:
	current_region_id = zone_id
	discover_region(zone_id)


func _on_npc_talked_to(npc_id: StringName) -> void:
	var record: Dictionary = _ensure_completion_record(current_region_id)
	if not record["npcs_talked"].has(npc_id):
		record["npcs_talked"].append(npc_id)


func _on_quest_completed(quest_id: StringName) -> void:
	var record: Dictionary = _ensure_completion_record(current_region_id)
	if not record["quests_done"].has(quest_id):
		record["quests_done"].append(quest_id)


func _on_lore_read(lore_id: StringName) -> void:
	var record: Dictionary = _ensure_completion_record(current_region_id)
	if not record["lore_read"].has(lore_id):
		record["lore_read"].append(lore_id)


func _on_secret_room_found(secret_id: StringName) -> void:
	var record: Dictionary = _ensure_completion_record(current_region_id)
	if not record["secrets_found"].has(secret_id):
		record["secrets_found"].append(secret_id)


func get_region_completion_pct(region_id: StringName) -> float:
	## Returns 0.0 - 1.0 based on how much of the region has been seen.
	## Currently uses a simple heuristic; a real impl would query the
	## per-region master lists.
	var record: Dictionary = region_completion.get(region_id, {})
	if record.is_empty():
		return 0.0
	var npcs: int = record.get("npcs_talked", []).size()
	var quests: int = record.get("quests_done", []).size()
	var lore: int = record.get("lore_read", []).size()
	var secrets: int = record.get("secrets_found", []).size()
	# Heuristic: each category contributes equally up to 5 items each
	var score: float = (mini(npcs, 5) + mini(quests, 5) + mini(lore, 5) + mini(secrets, 5)) / 20.0
	return score


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var notes_str: Dictionary = {}
	for k: Vector2 in player_notes.keys():
		notes_str["%d_%d" % [int(k.x), int(k.y)]] = player_notes[k]
	return {
		"discovered_regions": discovered_regions.map(func(s: StringName) -> String: return String(s)),
		"explored_regions": explored_regions.map(func(s: StringName) -> String: return String(s)),
		"fast_travel_unlocked": fast_travel_unlocked.map(func(s: StringName) -> String: return String(s)),
		"current_region_id": String(current_region_id),
		"waypoint_position": [waypoint_position.x, waypoint_position.y],
		"waypoint_active": waypoint_active,
		"player_notes": notes_str,
		"region_completion": region_completion,
	}


func from_save_data(data: Dictionary) -> void:
	discovered_regions.clear()
	for s in data.get("discovered_regions", []):
		discovered_regions.append(StringName(s))
	explored_regions.clear()
	for s in data.get("explored_regions", []):
		explored_regions.append(StringName(s))
	fast_travel_unlocked.clear()
	for s in data.get("fast_travel_unlocked", []):
		fast_travel_unlocked.append(StringName(s))
	current_region_id = StringName(data.get("current_region_id", "town_commons"))
	var wp: Array = data.get("waypoint_position", [0, 0])
	waypoint_position = Vector2(wp[0], wp[1])
	waypoint_active = data.get("waypoint_active", false)
	player_notes.clear()
	for k_str in data.get("player_notes", {}).keys():
		var parts: PackedStringArray = (k_str as String).split("_")
		if parts.size() == 2:
			var v: Vector2 = Vector2(int(parts[0]), int(parts[1]))
			player_notes[v] = data["player_notes"][k_str]
	region_completion = data.get("region_completion", {})
