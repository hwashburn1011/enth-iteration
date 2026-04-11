extends Node
## WanderingNPCManager — schedules + spawns rare wilderness encounters.
##
## When the player enters a wilderness region, this manager checks the
## encounter pool for that region and rolls a chance per eligible
## encounter (filtered by phase, weather, iteration, faction, cooldown).
## The first one that fires is spawned via the EventBus
## `wilderness_encounter_spawn_requested` signal — the wilderness scene
## handles the actual NPC spawn at the encounter's path/point.
##
## Add to project autoloads as "WanderingNPCManager".

signal encounter_triggered(encounter_id: StringName)
signal encounter_finished(encounter_id: StringName)

const ROLL_DISTANCE_FROM_PLAYER_MAX: float = 60.0
const ROLL_DISTANCE_FROM_PLAYER_MIN: float = 20.0

var _last_fired: Dictionary = {}  # encounter_id → in-game hour
var _active_encounters: Array[StringName] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("region_entered"):
			bus.region_entered.connect(_on_region_entered)


# === ROLL ===

func roll_for_region(region_id: StringName) -> StringName:
	## Walks the encounter pool for `region_id` and returns the first
	## encounter id that passes all gates and wins its random check.
	## Returns &"" if nothing fires.
	var pool: Array[Dictionary] = WildernessEncounterDatabase.get_for_region(region_id)
	pool.shuffle()
	for entry: Dictionary in pool:
		if not _passes_gates(entry):
			continue
		var chance: float = entry.get("chance", 0.0)
		if _rng.randf() <= chance:
			_fire_encounter(entry)
			return entry["id"]
	return &""


func _passes_gates(entry: Dictionary) -> bool:
	var encounter_id: StringName = entry["id"]

	# Cooldown
	var cooldown_hours: int = entry.get("cooldown_hours", 0)
	if cooldown_hours > 0 and _last_fired.has(encounter_id):
		var elapsed_h: int = _current_hour_total() - int(_last_fired[encounter_id])
		if elapsed_h < cooldown_hours:
			return false

	# Phase window
	var phases: Array = entry.get("phase_window", [])
	if not phases.is_empty():
		var phase: StringName = _current_phase()
		if not phases.has(phase):
			return false

	# Weather blacklist
	var blacklist: Array = entry.get("weather_blacklist", [])
	if not blacklist.is_empty():
		var weather: StringName = _current_weather()
		if blacklist.has(weather):
			return false

	# Iteration gate
	var min_iter: int = entry.get("iteration_min", 0)
	if min_iter > 0:
		var iter: int = _current_iteration()
		if iter < min_iter:
			return false

	# Faction gate
	var faction: StringName = entry.get("faction_required", &"")
	if faction != &"":
		var min_tier: StringName = entry.get("faction_min_tier", &"none")
		if not _faction_at_least(faction, min_tier):
			return false

	# Already-active prevention
	if _active_encounters.has(encounter_id):
		return false

	return true


func _fire_encounter(entry: Dictionary) -> void:
	var encounter_id: StringName = entry["id"]
	_last_fired[encounter_id] = _current_hour_total()
	_active_encounters.append(encounter_id)
	encounter_triggered.emit(encounter_id)

	# Spawn request handled by wilderness scene
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("wilderness_encounter_spawn_requested"):
			bus.emit_signal("wilderness_encounter_spawn_requested", encounter_id, entry)

	# Music sting
	var sting: StringName = entry.get("music_sting", &"")
	if sting != &"" and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(sting)


# === LIFECYCLE ===

func mark_encounter_finished(encounter_id: StringName) -> void:
	_active_encounters.erase(encounter_id)
	encounter_finished.emit(encounter_id)


func is_encounter_active(encounter_id: StringName) -> bool:
	return _active_encounters.has(encounter_id)


func get_active_encounters() -> Array[StringName]:
	return _active_encounters.duplicate()


# === HELPERS ===

func _current_hour_total() -> int:
	if not has_node("/root/DayNightController"):
		return 0
	var dnc: Node = get_node("/root/DayNightController")
	var day: int = 0
	var hour: int = 0
	if "current_day" in dnc:
		day = int(dnc.current_day)
	if dnc.has_method("get_current_hour"):
		hour = int(dnc.get_current_hour())
	return day * 24 + hour


func _current_phase() -> StringName:
	if not has_node("/root/DayNightController"):
		return &"day"
	var dnc: Node = get_node("/root/DayNightController")
	if "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"


func _current_weather() -> StringName:
	if not has_node("/root/WeatherController"):
		return &"clear"
	var wc: Node = get_node("/root/WeatherController")
	if "current_weather_id" in wc:
		return StringName(wc.current_weather_id)
	return &"clear"


func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	if "current_iteration" in im:
		return int(im.current_iteration)
	return 1


func _faction_at_least(faction_id: StringName, tier: StringName) -> bool:
	if not has_node("/root/FactionManager"):
		return true  # permissive when system unloaded
	var fm: Node = get_node("/root/FactionManager")
	if fm.has_method("is_at_least_tier"):
		return fm.is_at_least_tier(faction_id, tier)
	return true


# === EVENT HANDLERS ===

func _on_region_entered(region_id: StringName, _meta: Dictionary) -> void:
	# Only roll for wilderness regions
	if not String(region_id).begins_with("wild_"):
		return
	roll_for_region(region_id)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var lf: Dictionary = {}
	for k in _last_fired.keys():
		lf[String(k)] = int(_last_fired[k])
	return {
		"last_fired": lf,
	}


func from_save_data(data: Dictionary) -> void:
	_last_fired.clear()
	var lf: Dictionary = data.get("last_fired", {})
	for k in lf.keys():
		_last_fired[StringName(k)] = int(lf[k])
	_active_encounters.clear()
