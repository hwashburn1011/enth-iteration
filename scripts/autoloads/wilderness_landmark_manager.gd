extends Node
## WildernessLandmarkManager — tracks discovered wilderness landmarks
## and grants their first-discovery rewards. Listens to the existing
## WildernessWaypointManager so the 7 waypoint-linked landmarks discover
## automatically when the player reaches the waypoint, while the 2
## standalone landmarks (signpost, shrine) are discovered via direct
## `discover_landmark()` calls from their own scene triggers.
##
## Add to project autoloads as "WildernessLandmarkManager".

signal landmark_discovered(landmark_id: StringName)
signal landmark_reward_granted(landmark_id: StringName, reward: Dictionary)

var discovered_landmarks: Array[StringName] = []


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if has_node("/root/WildernessWaypointManager"):
		var wwm: Node = get_node("/root/WildernessWaypointManager")
		if wwm.has_signal("waypoint_discovered"):
			wwm.waypoint_discovered.connect(_on_waypoint_discovered)


# === DISCOVERY ===

func discover_landmark(landmark_id: StringName) -> bool:
	if discovered_landmarks.has(landmark_id):
		return false
	var entry: Dictionary = WildernessLandmarkDatabase.get_landmark(landmark_id)
	if entry.is_empty():
		push_warning("WildernessLandmarkManager: unknown landmark '%s'" % landmark_id)
		return false

	discovered_landmarks.append(landmark_id)
	landmark_discovered.emit(landmark_id)

	# Achievement hooks (Mapmaker = all 9, Six Faces = all 6 regions)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("landmark_discovered"):
			bus.emit_signal("landmark_discovered", landmark_id)

	# Grant the discovery reward
	var reward: Dictionary = entry.get("discovery_reward", {})
	if not reward.is_empty():
		_grant_reward(landmark_id, reward)

	# Optional one-line narrator beat
	var dialogue: StringName = entry.get("first_discovery_dialogue", &"")
	if dialogue != &"" and has_node("/root/VoiceManager"):
		var vm: Node = get_node("/root/VoiceManager")
		if vm.has_method("play_narrator_line"):
			vm.play_narrator_line(dialogue)

	return true


func _grant_reward(landmark_id: StringName, reward: Dictionary) -> void:
	landmark_reward_granted.emit(landmark_id, reward)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("reward_granted"):
			bus.emit_signal("reward_granted", reward)


# === EVENT HANDLERS ===

func _on_waypoint_discovered(waypoint_id: StringName) -> void:
	var landmark_id: StringName = WildernessLandmarkDatabase.get_landmark_id_for_waypoint(waypoint_id)
	if landmark_id != &"":
		discover_landmark(landmark_id)


# === QUERIES ===

func is_discovered(landmark_id: StringName) -> bool:
	return discovered_landmarks.has(landmark_id)


func get_discovered_count() -> int:
	return discovered_landmarks.size()


func get_total_count() -> int:
	return WildernessLandmarkDatabase.get_count()


func get_regions_visited() -> Array[StringName]:
	## Returns unique regions touched by the discovered landmark set.
	## Used by the "Six Faces of the Wild" achievement.
	var regions: Array[StringName] = []
	for landmark_id in discovered_landmarks:
		var entry: Dictionary = WildernessLandmarkDatabase.get_landmark(landmark_id)
		var region: StringName = entry.get("region", &"")
		if region != &"" and not regions.has(region):
			regions.append(region)
	return regions


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var d: Array = []
	for lm in discovered_landmarks:
		d.append(String(lm))
	return {"discovered_landmarks": d}


func from_save_data(data: Dictionary) -> void:
	discovered_landmarks.clear()
	for s in data.get("discovered_landmarks", []):
		discovered_landmarks.append(StringName(s))
