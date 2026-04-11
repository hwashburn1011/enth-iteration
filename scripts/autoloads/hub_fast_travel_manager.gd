extends Node
## HubFastTravelManager — manages discovery + warp for the 17 town
## hub fast-travel points from HubFastTravelDatabase. Sister system to
## WildernessWaypointManager (which handles the wilderness side).
##
## Add to project autoloads as "HubFastTravelManager".
##
## Discovery flow:
##   - "always" points are unlocked at boot
##   - Other points unlock when their condition becomes true
##     (sub_area_discovered, story_flag, iteration_min, affinity_tier)
##   - The manager re-evaluates on relevant EventBus signals so the
##     unlock can happen mid-session (e.g. solving the bookshelf
##     puzzle immediately reveals the Treasure Room fast-travel)

signal point_unlocked(point_id: StringName)
signal travel_started(from_id: StringName, to_id: StringName)
signal travel_finished(to_id: StringName)

var unlocked_points: Array[StringName] = []
var last_used_point: StringName = &""


func _ready() -> void:
	_grant_always_unlocked()
	_subscribe_to_events()


func _grant_always_unlocked() -> void:
	for entry: Dictionary in HubFastTravelDatabase.get_all():
		var query: Dictionary = _build_query_state()
		if HubFastTravelDatabase.is_unlocked(entry, query):
			var pid: StringName = entry["id"]
			if not unlocked_points.has(pid):
				unlocked_points.append(pid)


func _subscribe_to_events() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		# Re-evaluate locks on any of these
		if bus.has_signal("subarea_discovered"):
			bus.subarea_discovered.connect(_reevaluate)
		if bus.has_signal("story_flag_set"):
			bus.story_flag_set.connect(_reevaluate)
		if bus.has_signal("iteration_changed"):
			bus.iteration_changed.connect(_reevaluate)
		if bus.has_signal("affinity_tier_changed"):
			bus.affinity_tier_changed.connect(_reevaluate)
		if bus.has_signal("bookshelf_puzzle_solved"):
			bus.bookshelf_puzzle_solved.connect(_reevaluate)


# === EVALUATE ===

func _reevaluate(_arg = null) -> void:
	var query: Dictionary = _build_query_state()
	for entry: Dictionary in HubFastTravelDatabase.get_all():
		var pid: StringName = entry["id"]
		if unlocked_points.has(pid):
			continue
		if HubFastTravelDatabase.is_unlocked(entry, query):
			unlocked_points.append(pid)
			point_unlocked.emit(pid)
			if has_node("/root/MusicManager"):
				var mm: Node = get_node("/root/MusicManager")
				if mm.has_method("play_sting"):
					mm.play_sting(&"sting_fast_travel_unlocked")


func _build_query_state() -> Dictionary:
	var query: Dictionary = {
		"discovered_sub_areas": [],
		"set_flags": [],
		"current_iteration": _current_iteration(),
		"npc_tiers": {},
	}
	if has_node("/root/SubAreaManager"):
		var sam: Node = get_node("/root/SubAreaManager")
		if "discovered_subareas" in sam:
			query["discovered_sub_areas"] = (sam.discovered_subareas as Array).duplicate()
	if has_node("/root/WildernessStoryManager"):
		var wsm: Node = get_node("/root/WildernessStoryManager")
		if "story_flags" in wsm:
			query["set_flags"] = (wsm.story_flags as Array).duplicate()
	if has_node("/root/AffinityManager"):
		var am: Node = get_node("/root/AffinityManager")
		if am.has_method("get_all_tiers"):
			query["npc_tiers"] = am.get_all_tiers()
	return query


# === QUERY ===

func is_unlocked(point_id: StringName) -> bool:
	return unlocked_points.has(point_id)


func get_unlocked_count() -> int:
	return unlocked_points.size()


func get_total_count() -> int:
	return HubFastTravelDatabase.get_count()


func get_locked_hint(point_id: StringName) -> String:
	var entry: Dictionary = HubFastTravelDatabase.get_point(point_id)
	return entry.get("locked_hint", "")


# === TRAVEL ===

func can_travel_to(point_id: StringName) -> bool:
	if not unlocked_points.has(point_id):
		return false
	# Block during combat
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if "in_combat" in bus and bus.in_combat == true:
			return false
	return true


func travel_to(point_id: StringName) -> bool:
	if not can_travel_to(point_id):
		return false
	var entry: Dictionary = HubFastTravelDatabase.get_point(point_id)
	if entry.is_empty():
		return false

	var from_id: StringName = last_used_point
	last_used_point = point_id
	travel_started.emit(from_id, point_id)

	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("hub_fast_travel_requested"):
			bus.emit_signal("hub_fast_travel_requested", point_id, entry)

	# The actual scene-level warp is handled by the SceneTransition
	# system; this manager just emits the request and signals
	travel_finished.emit(point_id)
	return true


# === HELPERS ===

func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var u: Array = []
	for p in unlocked_points:
		u.append(String(p))
	return {
		"unlocked_points": u,
		"last_used_point": String(last_used_point),
	}


func from_save_data(data: Dictionary) -> void:
	unlocked_points.clear()
	for s in data.get("unlocked_points", []):
		unlocked_points.append(StringName(s))
	last_used_point = StringName(data.get("last_used_point", ""))
	_grant_always_unlocked()
