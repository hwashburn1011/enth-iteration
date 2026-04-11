class_name WildernessForagingSpot
extends Area3D

## Hands-only foraging patch. Place where the bible's "foraging spots"
## live — clearings, riverbanks, ruin grass tufts, etc. On player
## interaction, calls ForagingTableDatabase.roll() with the player's
## gathering level + luck and the current phase, grants the rolled
## item, awards XP scaled by tier, and disables the patch for
## `cooldown_hours` in-game hours.
##
## Required scene shape:
##   WildernessForagingSpot (Area3D + this script)
##     CollisionShape3D (SphereShape3D, interact range)
##     Visual (any Node3D — the foraging visual that hides on cooldown)

signal foraged(item_id: StringName, count: int, tier: int)
signal foraging_failed(reason: StringName)

@export var region_id: StringName = &"wild_plateau"
@export var cooldown_hours: int = 6

var _last_used_hour_total: int = -100000
var _player_in_range: bool = false
var _foraging: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false


# === INTERACTION ===

func can_forage() -> bool:
	if _foraging or not _player_in_range:
		return false
	return _hours_until_ready() <= 0


func forage(player: Node3D) -> bool:
	if not can_forage():
		foraging_failed.emit(&"on_cooldown" if _hours_until_ready() > 0 else &"not_in_range")
		return false

	var skill: int = _get_player_gathering_level(player)
	var luck: int = _get_player_luck(player)
	var phase: StringName = _current_phase()

	_foraging = true
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_forage_search")

	# Brief search delay
	var t: SceneTreeTimer = get_tree().create_timer(1.5)
	t.timeout.connect(_resolve_foraging.bind(player, skill, luck, phase))
	return true


func _resolve_foraging(player: Node3D, skill: int, luck: int, phase: StringName) -> void:
	if not _foraging:
		return
	_foraging = false

	var entry: Dictionary = ForagingTableDatabase.roll(region_id, skill, luck, phase)
	if entry.is_empty():
		foraging_failed.emit(&"empty_pool")
		_record_use()
		return

	var item_id: StringName = entry["item_id"]
	var count_min: int = int(entry.get("count_min", 1))
	var count_max: int = int(entry.get("count_max", count_min))
	var count: int = randi_range(count_min, count_max)
	var tier: int = int(entry.get("tier", 1))

	# Grant items
	if has_node("/root/InventoryManager"):
		var inv: Node = get_node("/root/InventoryManager")
		if inv.has_method("add_item"):
			inv.add_item(item_id, count)

	# Grant XP scaled by tier (3 / 6 / 12 / 22)
	var xp_table: Array[int] = [3, 6, 12, 22]
	var xp: int = xp_table[clampi(tier - 1, 0, xp_table.size() - 1)]
	if player != null:
		var farm_comp: Node = player.get_node_or_null("FarmingComponent")
		if farm_comp != null and farm_comp.has_method("add_gathering_xp"):
			farm_comp.add_gathering_xp(xp)

	# Tier 3+ rare-find sting + log message
	if tier >= 3:
		if has_node("/root/MusicManager"):
			var mm: Node = get_node("/root/MusicManager")
			if mm.has_method("play_sting"):
				mm.play_sting(&"sting_rare_forage")
		var msg: String = entry.get("rare_message", "")
		if not msg.is_empty() and has_node("/root/EventBus"):
			var bus: Node = get_node("/root/EventBus")
			if bus.has_signal("log_message"):
				bus.emit_signal("log_message", msg, &"rare_find")

	foraged.emit(item_id, count, tier)
	_record_use()


# === COOLDOWN ===

func _record_use() -> void:
	_last_used_hour_total = _current_hour_total()
	_set_visual_visible(false)


func _hours_until_ready() -> int:
	if cooldown_hours <= 0:
		return 0
	var elapsed: int = _current_hour_total() - _last_used_hour_total
	if elapsed >= cooldown_hours:
		if not _foraging:
			_set_visual_visible(true)
		return 0
	return cooldown_hours - elapsed


func _process(_delta: float) -> void:
	if _last_used_hour_total > 0 and _hours_until_ready() == 0:
		_set_visual_visible(true)


func _set_visual_visible(visible: bool) -> void:
	var v: Node = get_node_or_null(^"Visual")
	if v is Node3D:
		(v as Node3D).visible = visible


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


func _get_player_gathering_level(player: Node3D) -> int:
	if player == null:
		return 1
	var farm: Node = player.get_node_or_null("FarmingComponent")
	if farm != null and "gathering_level" in farm:
		return int(farm.gathering_level)
	return 1


func _get_player_luck(player: Node3D) -> int:
	if player == null:
		return 0
	var stats: Node = player.get_node_or_null("StatsComponent")
	if stats != null and stats.has_method("get_stat"):
		return int(stats.get_stat(&"luck"))
	return 0


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"last_used_hour_total": _last_used_hour_total,
	}


func from_save_data(data: Dictionary) -> void:
	_last_used_hour_total = int(data.get("last_used_hour_total", -100000))
	_set_visual_visible(_hours_until_ready() == 0)
