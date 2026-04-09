extends Node
## DayNightController — global in-game clock with 24-minute days, 4 phases,
## sun/moon orbit, EventBus emission for time changes, save/load.
##
## Add to project autoloads as "DayNightController".

signal phase_changed(new_phase: StringName)
signal hour_changed(new_in_game_hour: int)
signal day_advanced(new_day: int)

const REAL_SECONDS_PER_IN_GAME_DAY: float = 1440.0  ## 24 minutes
const IN_GAME_MINUTES_PER_DAY: int = 1440
const DUNGEON_TIME_MULT: float = 0.33  ## time slows in dungeons

const PHASE_DAWN: StringName = &"dawn"
const PHASE_DAY: StringName = &"day"
const PHASE_DUSK: StringName = &"dusk"
const PHASE_NIGHT: StringName = &"night"

# Phase boundaries in in-game minutes (0-1439)
const PHASE_BOUNDARIES: Dictionary = {
	PHASE_DAWN:  {"start": 300,  "end": 480},   # 5:00-8:00
	PHASE_DAY:   {"start": 480,  "end": 1080},  # 8:00-18:00
	PHASE_DUSK:  {"start": 1080, "end": 1260},  # 18:00-21:00
	PHASE_NIGHT: {"start": 1260, "end": 300},   # 21:00-5:00 (wraps)
}

const PHASE_BUFFS: Dictionary = {
	PHASE_DAWN:  {"xp_gain_pct": 0.10},
	PHASE_DAY:   {},
	PHASE_DUSK:  {"gold_drop_pct": 0.10},
	PHASE_NIGHT: {"crit_chance_bonus": 0.10},
}

var current_in_game_minute: float = 480.0  ## start at 8:00 AM (Day phase)
var current_day: int = 1
var current_phase: StringName = PHASE_DAY
var time_paused: bool = false
var in_dungeon: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_entered"):
			bus.dungeon_entered.connect(func() -> void: in_dungeon = true)
		if bus.has_signal("dungeon_exited"):
			bus.dungeon_exited.connect(func() -> void: in_dungeon = false)
		if bus.has_signal("combat_started"):
			bus.combat_started.connect(func() -> void: time_paused = true)
		if bus.has_signal("combat_ended"):
			bus.combat_ended.connect(func() -> void: time_paused = false)


func _process(delta: float) -> void:
	if time_paused:
		return

	# 1 real second = 1 in-game minute (or 0.33 in dungeons)
	var time_mult: float = DUNGEON_TIME_MULT if in_dungeon else 1.0
	var minute_delta: float = delta * time_mult

	var prev_minute: int = int(current_in_game_minute)
	current_in_game_minute += minute_delta

	# Day rollover
	if current_in_game_minute >= IN_GAME_MINUTES_PER_DAY:
		current_in_game_minute -= IN_GAME_MINUTES_PER_DAY
		current_day += 1
		day_advanced.emit(current_day)
		_emit_eventbus_day_advanced()

	# Hour change
	var new_minute: int = int(current_in_game_minute)
	if new_minute / 60 != prev_minute / 60:
		var new_hour: int = new_minute / 60
		hour_changed.emit(new_hour)
		_emit_eventbus_hour_changed(new_hour)

	# Phase change
	var new_phase: StringName = compute_phase(new_minute)
	if new_phase != current_phase:
		current_phase = new_phase
		phase_changed.emit(new_phase)
		_emit_eventbus_phase_changed(new_phase)


func compute_phase(in_game_minute: int) -> StringName:
	for phase: StringName in PHASE_BOUNDARIES.keys():
		var bounds: Dictionary = PHASE_BOUNDARIES[phase]
		var start: int = bounds["start"]
		var end: int = bounds["end"]
		if start < end:
			# Normal range
			if in_game_minute >= start and in_game_minute < end:
				return phase
		else:
			# Wraps midnight
			if in_game_minute >= start or in_game_minute < end:
				return phase
	return PHASE_DAY


func get_current_hour() -> int:
	return int(current_in_game_minute) / 60


func get_current_minute_of_hour() -> int:
	return int(current_in_game_minute) % 60


func get_normalized_day_progress() -> float:
	return current_in_game_minute / float(IN_GAME_MINUTES_PER_DAY)


func get_sun_angle_degrees() -> float:
	## Returns the sun's elevation angle for the current time.
	## 0° at sunrise/sunset, peaks at noon (~50°), goes negative at night.
	var t: float = get_normalized_day_progress()
	# Day arc: 6:00 = 0°, 12:00 = 50°, 18:00 = 0°
	# Night arc: 18:00 = 0°, 24:00 = -45° (moon high), 6:00 = 0°
	var hour_float: float = current_in_game_minute / 60.0
	if hour_float >= 6.0 and hour_float <= 18.0:
		# Daytime
		var day_t: float = (hour_float - 6.0) / 12.0  # 0-1
		return sin(day_t * PI) * 50.0
	else:
		# Nighttime
		var night_hour: float = hour_float if hour_float < 6.0 else hour_float - 24.0
		var night_t: float = (night_hour + 6.0) / 12.0
		return -sin(night_t * PI) * 45.0


func get_active_phase_buffs() -> Dictionary:
	return PHASE_BUFFS.get(current_phase, {})


# === SLEEP / SKIP ===

func sleep_till_morning() -> void:
	var minutes_until_dawn: int = 360 - int(current_in_game_minute)  # 6:00 = minute 360
	if minutes_until_dawn < 0:
		minutes_until_dawn += IN_GAME_MINUTES_PER_DAY
	advance_time(minutes_until_dawn)


func sleep_till_night() -> void:
	var minutes_until_night: int = 1260 - int(current_in_game_minute)  # 21:00 = minute 1260
	if minutes_until_night < 0:
		minutes_until_night += IN_GAME_MINUTES_PER_DAY
	advance_time(minutes_until_night)


func advance_time(minutes: int) -> void:
	var prev_day: int = current_day
	current_in_game_minute += float(minutes)
	while current_in_game_minute >= IN_GAME_MINUTES_PER_DAY:
		current_in_game_minute -= IN_GAME_MINUTES_PER_DAY
		current_day += 1
	if current_day != prev_day:
		day_advanced.emit(current_day)
		_emit_eventbus_day_advanced()
	current_phase = compute_phase(int(current_in_game_minute))
	phase_changed.emit(current_phase)
	_emit_eventbus_phase_changed(current_phase)


func pause_time() -> void:
	time_paused = true


func resume_time() -> void:
	time_paused = false


# === EVENTBUS HELPERS ===

func _emit_eventbus_day_advanced() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("day_advanced"):
			bus.day_advanced.emit(current_day)


func _emit_eventbus_hour_changed(hour: int) -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("hour_changed"):
			bus.hour_changed.emit(hour)


func _emit_eventbus_phase_changed(phase: StringName) -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("time_phase_changed"):
			bus.time_phase_changed.emit(phase)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"current_in_game_minute": current_in_game_minute,
		"current_day": current_day,
		"current_phase": String(current_phase),
		"time_paused": time_paused,
	}


func from_save_data(data: Dictionary) -> void:
	current_in_game_minute = data.get("current_in_game_minute", 480.0)
	current_day = data.get("current_day", 1)
	current_phase = StringName(data.get("current_phase", "day"))
	time_paused = data.get("time_paused", false)
