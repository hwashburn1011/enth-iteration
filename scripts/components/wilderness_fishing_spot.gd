class_name WildernessFishingSpot
extends Area3D

## Place at any wilderness fishing position. Wraps the FishingResolver
## with player-in-range detection and a 24-in-game-hour cooldown to
## prevent infinite-grind exploits at a single spot.
##
## Required scene shape:
##   WildernessFishingSpot (Area3D + this script)
##     CollisionShape3D (SphereShape3D, interact range)
##     Visual (any Node3D — water swirl + indicator)
##
## Configure via the inspector:
##   region_id           — drives FishingResolver region pool
##   require_rod         — bail out if player has no fishing rod
##   cooldown_hours      — 0 = no cooldown (default 4 hours)
##   spot_quality        — multiplier on rarity (1.0 default, 1.5 for hidden lake)

signal fishing_started
signal fish_caught(fish_id: StringName, fish: Dictionary)
signal fishing_failed(reason: StringName)

@export var region_id: StringName = &"wild_river"
@export var require_rod: bool = true
@export var cooldown_hours: int = 4
@export var spot_quality: float = 1.0

var _last_catch_hour_total: int = -100000
var _player_in_range: bool = false
var _fishing: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_layer = 0
	collision_mask = 1 << 0  # Player layer
	monitorable = false


# === INTERACTION ===

func can_fish() -> bool:
	if _fishing or not _player_in_range:
		return false
	if _hours_until_next_cast() > 0:
		return false
	return true


func cast_line(player: Node3D) -> bool:
	if not can_fish():
		fishing_failed.emit(&"on_cooldown" if _hours_until_next_cast() > 0 else &"not_in_range")
		return false

	# Tool check
	var bait_id: StringName = _get_equipped_bait(player)
	if require_rod:
		var tool: StringName = _get_equipped_tool(player)
		if tool != &"fishing_rod":
			fishing_failed.emit(&"missing_rod")
			return false

	_fishing = true
	fishing_started.emit()

	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_fishing_line_cast")

	# Brief delay to read as a real cast (the actual minigame ramp lives
	# in the fishing minigame controller; this resolver gives the result)
	var t: SceneTreeTimer = get_tree().create_timer(2.5)
	t.timeout.connect(_resolve_catch.bind(player, bait_id))
	return true


func _resolve_catch(player: Node3D, bait_id: StringName) -> void:
	if not _fishing:
		return
	_fishing = false

	var caught: Dictionary = FishingResolver.try_catch(region_id, bait_id)
	if caught.is_empty():
		fishing_failed.emit(&"nothing_biting")
		_record_cast()
		return

	var fish_id: StringName = caught.get("id", &"")

	# Grant the catch into inventory
	if has_node("/root/InventoryManager"):
		var inv: Node = get_node("/root/InventoryManager")
		if inv.has_method("add_item"):
			inv.add_item(fish_id, 1)

	# Grant fishing XP based on rarity (rare fish give more)
	var rarity: int = int(caught.get("rarity", 0))
	var xp: int = 4 + rarity * 6  # 4, 10, 16, 22, 28
	if player != null:
		var farm_comp: Node = player.get_node_or_null("FarmingComponent")
		if farm_comp != null and farm_comp.has_method("add_fishing_xp"):
			farm_comp.add_fishing_xp(xp)

	# Music sting on rare+ catches
	if rarity >= 2 and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_rare_catch")

	# Achievement / story flag for legendary catches
	if rarity >= 3 and has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("rare_fish_caught"):
			bus.emit_signal("rare_fish_caught", fish_id)

	fish_caught.emit(fish_id, caught)
	_record_cast()


# === COOLDOWN ===

func _record_cast() -> void:
	_last_catch_hour_total = _current_hour_total()


func _hours_until_next_cast() -> int:
	if cooldown_hours <= 0:
		return 0
	var elapsed: int = _current_hour_total() - _last_catch_hour_total
	if elapsed >= cooldown_hours:
		return 0
	return cooldown_hours - elapsed


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


# === HELPERS ===

func _get_equipped_tool(player: Node3D) -> StringName:
	if player == null:
		return &"hands"
	var equip: Node = player.get_node_or_null("EquipmentComponent")
	if equip != null and equip.has_method("get_equipped_tool"):
		return equip.get_equipped_tool()
	return &"hands"


func _get_equipped_bait(player: Node3D) -> StringName:
	if player == null:
		return &"bait_worm"
	var equip: Node = player.get_node_or_null("EquipmentComponent")
	if equip != null and equip.has_method("get_equipped_bait"):
		return equip.get_equipped_bait()
	return &"bait_worm"


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
		"last_catch_hour_total": _last_catch_hour_total,
	}


func from_save_data(data: Dictionary) -> void:
	_last_catch_hour_total = int(data.get("last_catch_hour_total", -100000))
