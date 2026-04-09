class_name LoungeBar
extends Area3D

## The Underground Lounge bar interactive. Cache (or her stand-in)
## serves a daily rotation of 3 drink specials from LoungeBarDatabase.
## Player walks up, presses interact, picks one, the drink is poured,
## currency is consumed, and a timed buff is applied via BuffManager.
##
## Behavior:
##   - Daily rotation seeds from the current in-game day so two visits
##     in one evening see the same 3 drinks
##   - One drink per in-game day (the bar refuses a second pour
##     until tomorrow)
##   - Story-flag-gated drinks (e.g. The Inheritor's Cup) only appear
##     on the rotation when the flag is set
##   - Plays the pour SFX, posts a flavor line via DialogueManager,
##     fires shop_purchased / lounge_drink_consumed signals
##
## Required scene shape:
##   LoungeBar (Area3D + this script)
##     CollisionShape3D (BoxShape3D, range across the bar surface)
##     [optional] BarStool markers, BartenderAnchor (Marker3D)

signal drink_consumed(drink_id: StringName)
signal interaction_blocked(reason: StringName)
signal rotation_changed(drink_ids: Array)

const ONCE_PER_DAY_HOURS: int = 20  # one drink per in-game day, slightly under 24

var _last_drink_hour_total: int = -100000
var _player_in_range: bool = false
var _cached_rotation_day: int = -1
var _cached_rotation: Array[StringName] = []


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false


# === ROTATION ===

func get_current_rotation() -> Array[StringName]:
	var day: int = _current_day()
	if day == _cached_rotation_day:
		return _cached_rotation
	_cached_rotation_day = day
	_cached_rotation = LoungeBarDatabase.roll_daily_rotation(day)
	# Filter story-locked drinks the player hasn't unlocked yet
	var filtered: Array[StringName] = []
	for drink_id in _cached_rotation:
		var entry: Dictionary = LoungeBarDatabase.get_drink(drink_id)
		var required_flag: StringName = entry.get("required_story_flag", &"")
		if required_flag != &"" and not _has_story_flag(required_flag):
			# Drop locked drinks from the visible rotation
			continue
		filtered.append(drink_id)
	_cached_rotation = filtered
	rotation_changed.emit(_cached_rotation)
	return _cached_rotation


# === ORDER ===

func can_order() -> bool:
	if not _player_in_range:
		return false
	if _hours_until_ready() > 0:
		return false
	return true


func order_drink(drink_id: StringName) -> bool:
	if not can_order():
		interaction_blocked.emit(&"on_cooldown" if _hours_until_ready() > 0 else &"not_in_range")
		return false

	var rotation: Array[StringName] = get_current_rotation()
	if not rotation.has(drink_id):
		interaction_blocked.emit(&"not_on_rotation")
		return false

	var entry: Dictionary = LoungeBarDatabase.get_drink(drink_id)
	if entry.is_empty():
		interaction_blocked.emit(&"unknown_drink")
		return false

	# Currency check + spend
	var price: int = int(entry.get("price", 0))
	if price > 0:
		if not _spend_currency(price):
			interaction_blocked.emit(&"insufficient_currency")
			return false

	# Apply the timed buff
	_apply_drink_buff(entry)

	# Play the pour SFX
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(entry.get("sound_id", &""))

	# Post the flavor line via DialogueManager (Cache speaking)
	var flavor: String = entry.get("flavor_line", "")
	if flavor != "" and has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line("Cache", flavor, &"voice_cache")

	# Music sting on tier 3 (signature pours)
	if int(entry.get("tier", 1)) >= 3 and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_lounge_signature_pour")

	_last_drink_hour_total = _current_hour_total()
	drink_consumed.emit(drink_id)

	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("lounge_drink_consumed"):
			bus.emit_signal("lounge_drink_consumed", drink_id)

	return true


func _apply_drink_buff(entry: Dictionary) -> void:
	var buff_id: StringName = entry.get("buff_id", &"")
	var duration_min: int = int(entry.get("duration_minutes", 10))
	var stat_mods: Dictionary = entry.get("stat_modifiers", {})
	if has_node("/root/BuffManager"):
		var bm: Node = get_node("/root/BuffManager")
		if bm.has_method("apply_timed_buff"):
			bm.apply_timed_buff(buff_id, stat_mods, duration_min * 60)
		elif bm.has_method("apply_buff"):
			bm.apply_buff(buff_id, stat_mods)


# === COOLDOWN ===

func _hours_until_ready() -> int:
	var elapsed: int = _current_hour_total() - _last_drink_hour_total
	if elapsed >= ONCE_PER_DAY_HOURS:
		return 0
	return ONCE_PER_DAY_HOURS - elapsed


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


func _current_day() -> int:
	if not has_node("/root/DayNightController"):
		return 0
	var dnc: Node = get_node("/root/DayNightController")
	if "current_day" in dnc:
		return int(dnc.current_day)
	return 0


func _spend_currency(amount: int) -> bool:
	if not has_node("/root/EconomyManager"):
		# Permissive when economy not loaded — assume the spend went through
		return true
	var em: Node = get_node("/root/EconomyManager")
	if em.has_method("spend"):
		return em.spend(&"data_credits", amount)
	return true


func _has_story_flag(flag: StringName) -> bool:
	if not has_node("/root/WildernessStoryManager"):
		return false
	var sm: Node = get_node("/root/WildernessStoryManager")
	if sm.has_method("has_flag"):
		return sm.has_flag(flag)
	return false


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"last_drink_hour_total": _last_drink_hour_total,
	}


func from_save_data(data: Dictionary) -> void:
	_last_drink_hour_total = int(data.get("last_drink_hour_total", -100000))
