class_name Campsite
extends Area3D

## Wilderness campsite interactable. Place at the bible's pasture
## campsite (or any campfire). Player walks within range, presses
## interact, and the campsite plays a fade-to-dawn cinematic, restores
## full health, grants the *Well-Rested* buff (+10% XP next dungeon),
## and pulses any nearby ResourceNode to skip its respawn timer.
##
## One rest per in-game day so it doesn't replace the bed in town.
##
## Required scene shape:
##   Campsite (Area3D + this script)
##     CollisionShape3D (SphereShape3D, interact range)
##     Visual (Node3D — fire ring + benches + kettle)
##     Fire (GPUParticles3D — flame particles)
##     FireLight (OmniLight3D — warm point light)
##     SitPoint (Marker3D — where the player snaps to when sitting)
##
## Configure via the inspector:
##   campsite_id              — unique save key
##   rest_cooldown_hours      — default 18 (just under one in-game day)
##   regrow_nearby_radius     — meters to push for early respawn
##   well_rested_duration_h   — buff duration in in-game hours

signal rested_at_campsite
signal cooldown_remaining_changed(hours: int)

@export var campsite_id: StringName = &"campsite_pasture"
@export var rest_cooldown_hours: int = 18
@export var regrow_nearby_radius: float = 12.0
@export var well_rested_duration_h: int = 24

var _last_rested_hour_total: int = -100000
var _player_in_range: bool = false
var _resting: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false


# === INTERACTION ===

func can_rest() -> bool:
	if _resting or not _player_in_range:
		return false
	return _hours_until_ready() <= 0


func rest(player: Node3D) -> bool:
	if not can_rest():
		return false
	_resting = true
	rested_at_campsite.emit()

	_play_rest_cinematic()
	_advance_to_dawn()
	_full_heal(player)
	_apply_well_rested_buff(player)
	_pulse_nearby_resource_nodes()
	_record_rest()

	# Slight delay to let cinematic settle before re-enabling interact
	var t: SceneTreeTimer = get_tree().create_timer(2.0)
	t.timeout.connect(func() -> void:
		_resting = false
	)
	return true


# === CINEMATIC ===

func _play_rest_cinematic() -> void:
	if not has_node("/root/CutsceneController"):
		return
	var cc: Node = get_node("/root/CutsceneController")
	if not cc.has_method("play_timeline"):
		return
	var timeline: Array = [
		{"event": &"set_letterbox", "enabled": true},
		{"event": &"fade", "to": Color(0, 0, 0, 1), "duration": 1.5},
		{"event": &"play_sfx", "id": &"sfx_campfire_settle"},
		{"event": &"play_dialogue", "speaker": &"narrator", "text": "You sleep until first light.", "duration": 2.5},
		{"event": &"wait", "duration": 1.0},
		{"event": &"fade", "to": Color(0, 0, 0, 0), "duration": 1.5},
		{"event": &"set_letterbox", "enabled": false},
	]
	cc.play_timeline(timeline)


func _advance_to_dawn() -> void:
	if not has_node("/root/DayNightController"):
		return
	var dnc: Node = get_node("/root/DayNightController")
	if dnc.has_method("sleep_till_morning"):
		dnc.sleep_till_morning()
	elif dnc.has_method("set_phase"):
		dnc.set_phase(&"dawn")


# === EFFECTS ===

func _full_heal(player: Node3D) -> void:
	if player == null:
		return
	var stats: Node = player.get_node_or_null("StatsComponent")
	if stats == null:
		return
	if stats.has_method("heal_to_full"):
		stats.heal_to_full()
	elif stats.has_method("set_health"):
		var max_hp: int = int(stats.get(&"max_health")) if "max_health" in stats else 100
		stats.set_health(max_hp)


func _apply_well_rested_buff(player: Node3D) -> void:
	var stat_mods: Dictionary = {
		&"xp_gain_mult": 1.10,
		&"max_health_mult": 1.05,
	}
	if has_node("/root/BuffManager"):
		var bm: Node = get_node("/root/BuffManager")
		if bm.has_method("apply_timed_buff"):
			bm.apply_timed_buff(&"well_rested", stat_mods, well_rested_duration_h * 3600)
		elif bm.has_method("apply_buff"):
			bm.apply_buff(&"well_rested", stat_mods)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("buff_granted"):
			bus.emit_signal("buff_granted", &"well_rested")


func _pulse_nearby_resource_nodes() -> void:
	## Bible: campsite "regrows nearby herbs". Walks the scene tree for
	## ResourceNode instances in range and forces their respawn check.
	var nearby: Array[Node] = []
	_collect_nearby_resource_nodes(get_tree().current_scene, nearby)
	for n in nearby:
		if n.has_method("_respawn"):
			n._respawn()


func _collect_nearby_resource_nodes(node: Node, out: Array[Node]) -> void:
	if node == null:
		return
	if node is Node3D and node.get_script() != null and node is ResourceNode:
		var dist: float = (node as Node3D).global_position.distance_to(global_position)
		if dist <= regrow_nearby_radius:
			out.append(node)
	for child in node.get_children():
		_collect_nearby_resource_nodes(child, out)


# === COOLDOWN ===

func _record_rest() -> void:
	_last_rested_hour_total = _current_hour_total()
	cooldown_remaining_changed.emit(rest_cooldown_hours)


func _hours_until_ready() -> int:
	if rest_cooldown_hours <= 0:
		return 0
	var elapsed: int = _current_hour_total() - _last_rested_hour_total
	if elapsed >= rest_cooldown_hours:
		return 0
	return rest_cooldown_hours - elapsed


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


# === EVENTS ===

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"campsite_id": String(campsite_id),
		"last_rested_hour_total": _last_rested_hour_total,
	}


func from_save_data(data: Dictionary) -> void:
	_last_rested_hour_total = int(data.get("last_rested_hour_total", -100000))
