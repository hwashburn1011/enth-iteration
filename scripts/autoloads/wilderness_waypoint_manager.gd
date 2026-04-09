extends Node
## WildernessWaypointManager — tracks discovered wilderness waypoints
## and exposes a fast-travel API at sub-region granularity. Sits beside
## WorldMapManager (which handles region-level fast travel) so wilderness
## landmarks can be travel destinations on their own.
##
## Add to project autoloads as "WildernessWaypointManager".
##
## Discovery flow:
##   1. Player walks within `discovery_radius` of a waypoint, OR
##      a WildernessWaypointTrigger fires on contact, OR
##      a quest grants the waypoint via grant_waypoint(id)
##   2. Manager records the discovery, plays a sting, fires a signal
##   3. Player can fast-travel to it from the world map UI

signal waypoint_discovered(waypoint_id: StringName)
signal waypoint_used(from_id: StringName, to_id: StringName)

var unlocked_waypoints: Array[StringName] = []
var last_used_waypoint: StringName = &""


func _ready() -> void:
	_grant_default_waypoints()
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("player_returned_to_town"):
			# Town gate is always available; nothing to do here yet
			pass


func _grant_default_waypoints() -> void:
	for wp_id in WildernessWaypointDatabase.get_default_unlocked():
		if not unlocked_waypoints.has(wp_id):
			unlocked_waypoints.append(wp_id)


# === DISCOVERY ===

func discover_waypoint(waypoint_id: StringName) -> bool:
	if unlocked_waypoints.has(waypoint_id):
		return false
	var entry: Dictionary = WildernessWaypointDatabase.get_waypoint(waypoint_id)
	if entry.is_empty():
		push_warning("WildernessWaypointManager: unknown waypoint '%s'" % waypoint_id)
		return false
	unlocked_waypoints.append(waypoint_id)
	waypoint_discovered.emit(waypoint_id)

	# Sting + achievement hooks
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_waypoint_discovered")
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("waypoint_discovered"):
			bus.emit_signal("waypoint_discovered", waypoint_id)

	# Mirror parent region into WorldMapManager so the region also unlocks
	if has_node("/root/WorldMapManager"):
		var wmm: Node = get_node("/root/WorldMapManager")
		var parent_region: StringName = entry.get("parent_region", &"")
		if parent_region != &"" and wmm.has_method("unlock_fast_travel"):
			wmm.unlock_fast_travel(parent_region)
	return true


func grant_waypoint(waypoint_id: StringName) -> bool:
	## Quest reward / story unlock path. Same as discover but explicit.
	return discover_waypoint(waypoint_id)


# === QUERY ===

func is_unlocked(waypoint_id: StringName) -> bool:
	return unlocked_waypoints.has(waypoint_id)


func get_unlocked_count() -> int:
	return unlocked_waypoints.size()


func get_total_count() -> int:
	return WildernessWaypointDatabase.get_count()


func get_unlocked_for_region(region_id: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	for entry: Dictionary in WildernessWaypointDatabase.get_for_region(region_id):
		var wp_id: StringName = entry["id"]
		if unlocked_waypoints.has(wp_id):
			result.append(wp_id)
	return result


# === FAST TRAVEL ===

func can_travel_to(waypoint_id: StringName) -> bool:
	if not unlocked_waypoints.has(waypoint_id):
		return false
	# Block fast travel during combat
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if "in_combat" in bus and bus.in_combat == true:
			return false
	return true


func travel_to(waypoint_id: StringName) -> bool:
	if not can_travel_to(waypoint_id):
		return false
	var entry: Dictionary = WildernessWaypointDatabase.get_waypoint(waypoint_id)
	if entry.is_empty():
		return false

	var from_id: StringName = last_used_waypoint
	last_used_waypoint = waypoint_id
	waypoint_used.emit(from_id, waypoint_id)

	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("wilderness_fast_travel_requested"):
			bus.emit_signal("wilderness_fast_travel_requested", waypoint_id, entry)
	return true


# === REST AT CAMPSITE ===

func rest_at_waypoint(waypoint_id: StringName) -> bool:
	var entry: Dictionary = WildernessWaypointDatabase.get_waypoint(waypoint_id)
	if entry.is_empty() or not entry.get("can_rest", false):
		return false
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_method("sleep_till_morning"):
			dnc.sleep_till_morning()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("buff_granted"):
			bus.emit_signal("buff_granted", &"well_rested")
	return true


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var u: Array = []
	for wp in unlocked_waypoints:
		u.append(String(wp))
	return {
		"unlocked_waypoints": u,
		"last_used_waypoint": String(last_used_waypoint),
	}


func from_save_data(data: Dictionary) -> void:
	unlocked_waypoints.clear()
	for s in data.get("unlocked_waypoints", []):
		unlocked_waypoints.append(StringName(s))
	last_used_waypoint = StringName(data.get("last_used_waypoint", ""))
	_grant_default_waypoints()
