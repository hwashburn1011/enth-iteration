class_name TowerTelescope
extends Node3D

## Tower Top telescope interaction. Player walks up, presses interact,
## enters telescope view mode, and rotates through the visible targets
## from TowerTelescopeDatabase. Each observation triggers the target's
## reveal — lore tablet unlock, buff application, title grant, or
## countdown query — gated on per-target cooldown.
##
## Required scene shape:
##   TowerTelescope (Node3D + this script)
##     CollisionShape3D (sphere, interact range)
##     Eyepiece (Marker3D — camera anchor when in view mode)
##     [optional] TelescopeMesh (MeshInstance3D — physical telescope)
##
## Configure via inspector:
##   none — pulls all data from TowerTelescopeDatabase

signal target_observed(target_id: StringName)
signal observation_blocked(target_id: StringName, reason: StringName)
signal cycled_to_target(target_id: StringName)

var _observed_log: Dictionary = {}  # target_id → in-game hour total of last observation
var _viewing: bool = false
var _current_target_index: int = 0
var _current_visible: Array[Dictionary] = []
var _player_in_range: bool = false


func _ready() -> void:
	var area: Area3D = get_node_or_null("InteractArea") as Area3D
	if area != null:
		area.body_entered.connect(_on_player_entered)
		area.body_exited.connect(_on_player_exited)
		area.collision_layer = 0
		area.collision_mask = 1 << 0
		area.monitorable = false


# === VIEW MODE ===

func can_use() -> bool:
	return _player_in_range and not _viewing


func enter_view_mode() -> void:
	if not can_use():
		return
	_viewing = true
	_refresh_visible_targets()
	_current_target_index = 0
	if not _current_visible.is_empty():
		cycled_to_target.emit(_current_visible[0]["id"])
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("telescope_view_entered"):
			bus.emit_signal("telescope_view_entered")


func exit_view_mode() -> void:
	_viewing = false
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("telescope_view_exited"):
			bus.emit_signal("telescope_view_exited")


func cycle_target(direction: int) -> void:
	if not _viewing or _current_visible.is_empty():
		return
	_current_target_index = (_current_target_index + direction) % _current_visible.size()
	if _current_target_index < 0:
		_current_target_index += _current_visible.size()
	cycled_to_target.emit(_current_visible[_current_target_index]["id"])


func get_current_target() -> Dictionary:
	if _current_visible.is_empty():
		return {}
	return _current_visible[_current_target_index]


# === OBSERVE ===

func observe_current_target() -> bool:
	if not _viewing:
		return false
	var entry: Dictionary = get_current_target()
	if entry.is_empty():
		return false
	var target_id: StringName = entry["id"]

	# Cooldown check
	var cooldown_h: int = int(entry.get("reveal_cooldown_hours", 0))
	if cooldown_h == 0 and _observed_log.has(target_id):
		observation_blocked.emit(target_id, &"already_observed_one_shot")
		return false
	if cooldown_h > 0 and _observed_log.has(target_id):
		var elapsed: int = _current_hour_total() - int(_observed_log[target_id])
		if elapsed < cooldown_h:
			observation_blocked.emit(target_id, &"on_cooldown")
			return false

	_resolve_reveal(entry)
	_observed_log[target_id] = _current_hour_total()
	target_observed.emit(target_id)

	# Music sting
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_telescope_observation")

	return true


func _resolve_reveal(entry: Dictionary) -> void:
	var reveal_type: StringName = entry.get("reveal_type", &"")
	var payload: Dictionary = entry.get("reveal_payload", {})

	match reveal_type:
		&"lore_tablet":
			_grant_lore_tablet(payload.get("lore_id", &""))

		&"buff":
			_grant_buff(payload)

		&"title":
			_grant_title(payload.get("title_id", &""))

		&"countdown":
			_show_countdown(payload.get("countdown_id", &""))

		&"daily_bonus_lore":
			_grant_daily_bonus_lore(payload.get("unselected_lore_pool", []))


func _grant_lore_tablet(lore_id: StringName) -> void:
	if lore_id == &"":
		return
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("reward_granted"):
			bus.emit_signal("reward_granted", {"type": &"lore_tablet", "id": lore_id})


func _grant_buff(payload: Dictionary) -> void:
	var buff_id: StringName = payload.get("buff_id", &"")
	var stat_mods: Dictionary = payload.get("stat_modifiers", {})
	var duration_min: int = int(payload.get("duration_minutes", 30))
	if buff_id == &"":
		return
	if has_node("/root/BuffManager"):
		var bm: Node = get_node("/root/BuffManager")
		if bm.has_method("apply_timed_buff"):
			bm.apply_timed_buff(buff_id, stat_mods, duration_min * 60)


func _grant_title(title_id: StringName) -> void:
	if title_id == &"":
		return
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("reward_granted"):
			bus.emit_signal("reward_granted", {"type": &"title", "id": title_id})


func _show_countdown(countdown_id: StringName) -> void:
	# For final_vault_seals_remaining: query iteration manager and show
	# the player a UI line with the seal count.
	if countdown_id != &"final_vault_seals_remaining":
		return
	var current_iter: int = _current_iteration()
	var seals_remaining: int = max(0, 8 - current_iter)
	var line: String = "Seals remaining: %d" % seals_remaining
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line("narrator", line, &"")


func _grant_daily_bonus_lore(pool: Array) -> void:
	## Aiming at the Four Mouths reveals a different lore tablet for
	## the daily-bonus dungeon entrance — drives the player to visit
	## that entrance to read the rest.
	if pool.is_empty():
		return
	# Pick the lore tablet associated with today's bonus entrance
	var bonus_id: StringName = _get_daily_bonus_entrance_id()
	var lore_id: StringName = _lore_for_bonus(bonus_id)
	if lore_id == &"":
		# Fallback: deterministic pick by day_seed
		var day: int = _current_day()
		lore_id = pool[day % pool.size()]
	_grant_lore_tablet(lore_id)


func _lore_for_bonus(bonus_entrance_id: StringName) -> StringName:
	match bonus_entrance_id:
		&"server_room":     return &"lore_telescope_server_room"
		&"memory_vaults":   return &"lore_telescope_memory_vaults"
		&"corrupted_wilds": return &"lore_telescope_corrupted_wilds"
		&"final_vault":     return &"lore_telescope_final_vault"
	return &""


# === STATE READERS ===

func _refresh_visible_targets() -> void:
	var phase: StringName = _current_phase()
	var iter: int = _current_iteration()
	_current_visible = TowerTelescopeDatabase.get_observable(phase, iter)


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


func _current_phase() -> StringName:
	if not has_node("/root/DayNightController"):
		return &"day"
	var dnc: Node = get_node("/root/DayNightController")
	if "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"


func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1


func _get_daily_bonus_entrance_id() -> StringName:
	if not has_node("/root/DungeonEntranceManager"):
		return &""
	var dem: Node = get_node("/root/DungeonEntranceManager")
	if dem.has_method("get_daily_bonus_entrance_id"):
		return dem.get_daily_bonus_entrance_id()
	return &""


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		exit_view_mode()


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var log: Dictionary = {}
	for k in _observed_log.keys():
		log[String(k)] = int(_observed_log[k])
	return {"observed_log": log}


func from_save_data(data: Dictionary) -> void:
	_observed_log.clear()
	var log: Dictionary = data.get("observed_log", {})
	for k in log.keys():
		_observed_log[StringName(k)] = int(log[k])
