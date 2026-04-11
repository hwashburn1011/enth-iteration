extends Node
## DistrictManager — global town district controller. Detects which district
## the player is in via region detection, smoothly crossfades music + lighting
## + ambient SFX as the player crosses district boundaries, exposes the
## current district to UI / quest / NPC systems.
##
## Add to project autoloads as "DistrictManager".

signal district_entered(district_id: StringName)
signal district_exited(district_id: StringName)
signal district_label_show(display_name: String)

const LABEL_DISPLAY_DURATION: float = 2.0

var current_district_id: StringName = &""


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("zone_entered"):
			bus.zone_entered.connect(_on_zone_entered)


func enter_district(district_id: StringName) -> void:
	if current_district_id == district_id:
		return
	var prev: StringName = current_district_id
	if prev != &"":
		district_exited.emit(prev)
	current_district_id = district_id
	district_entered.emit(district_id)
	_apply_district_settings(district_id)


func _apply_district_settings(district_id: StringName) -> void:
	var district: Dictionary = TownDistrictDatabase.get_district(district_id)
	if district.is_empty():
		return

	# Music crossfade
	var music_id: StringName = district.get("music_track", &"")
	if music_id != &"" and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_zone_track"):
			mm.play_zone_track(music_id)

	# Environment preset
	var env_id: StringName = district.get("environment_preset", &"")
	if env_id != &"" and has_node("/root/EnvironmentManager"):
		var em: Node = get_node("/root/EnvironmentManager")
		if em.has_method("apply_preset"):
			em.apply_preset(env_id)

	# Ambient SFX loops
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("stop_all_in_category"):
			sm.stop_all_in_category(&"world")
		if sm.has_method("play"):
			for sfx_id: StringName in district.get("ambient_sfx", []):
				sm.play(sfx_id)

	# Show district name label
	district_label_show.emit(district.get("display_name", ""))


func _on_zone_entered(zone_id: StringName, _env_preset: StringName) -> void:
	# Map region/zone IDs to districts
	var district: Dictionary = TownDistrictDatabase.get_district_for_region(zone_id)
	if not district.is_empty():
		enter_district(district["id"])


# === QUERIES ===

func get_current_district() -> Dictionary:
	return TownDistrictDatabase.get_district(current_district_id)


func is_in_district(district_id: StringName) -> bool:
	return current_district_id == district_id


func get_npcs_currently_present(district_id: StringName) -> Array:
	## Returns NPCs whose schedule places them in this district right now.
	## Used by quest hubs to show "available NPCs" lists.
	var result: Array = []
	if not has_node("/root/DayNightController"):
		return result
	var dnc: Node = get_node("/root/DayNightController")
	var current_hour: int = dnc.get_current_hour()
	var district: Dictionary = TownDistrictDatabase.get_district(district_id)
	if district.is_empty():
		return result
	# Walk all home + work NPCs and check schedules
	var candidate_npcs: Array = district.get("home_npcs", []).duplicate()
	for n in district.get("work_npcs", []):
		if not candidate_npcs.has(n):
			candidate_npcs.append(n)
	for npc_id: StringName in candidate_npcs:
		var stop: Dictionary = NPCSchedule.get_current_stop(npc_id, current_hour)
		var stop_location: StringName = stop.get("location", &"")
		# Heuristic: if the location string contains the district id, count it
		if String(stop_location).contains(String(district_id)):
			result.append(npc_id)
	return result


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {"current_district_id": String(current_district_id)}


func from_save_data(data: Dictionary) -> void:
	current_district_id = StringName(data.get("current_district_id", ""))
	if current_district_id != &"":
		_apply_district_settings(current_district_id)
