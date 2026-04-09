class_name WildernessShrine
extends Area3D

## Interactable Shrine of the Loop. Place at the wilderness shrine
## landmark position. The player walks within range, presses interact,
## chooses an offering item from inventory, and the shrine rolls a buff
## from the ShrineBuffDatabase pool weighted by the offering's tier.
##
## One offering per in-game day. Cooldown persists across the day-night
## cycle and across save/load.
##
## Required scene shape:
##   WildernessShrine (Area3D + this script)
##     CollisionShape3D (SphereShape3D, interaction range)
##     Visual (any Node3D — the shrine model)
##     OfferingPedestal (Marker3D — where offerings appear visually)

signal offering_made(item_id: StringName, buff_id: StringName)
signal cooldown_remaining_changed(remaining_minutes: int)

const COOLDOWN_HOURS: int = 24  # one offering per in-game day
const TIER_WEIGHTS: Array[float] = [1.0, 0.55, 0.30, 0.12]  # tier1, 2, 3, 4

@export var shrine_id: StringName = &"shrine_of_the_loop"
@export var require_discovered_landmark: bool = true

var _last_offering_hour_total: int = -100000
var _player_in_range: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_layer = 0
	collision_mask = 1 << 0  # Player layer
	monitorable = false


# === INTERACTION ===

func can_interact() -> bool:
	if not _player_in_range:
		return false
	if require_discovered_landmark and not _landmark_discovered():
		return false
	return true


func can_offer() -> bool:
	if not can_interact():
		return false
	return _hours_until_next_offering() <= 0


func make_offering(item_id: StringName) -> StringName:
	## Consumes the item from inventory, rolls a buff weighted by the
	## offering tier, applies the buff, and returns the buff_id.
	## Returns &"" on failure.
	if not can_offer():
		return &""

	var tier: int = ShrineBuffDatabase.get_offering_tier(item_id)
	if tier <= 0:
		return &""

	# Consume the item
	if has_node("/root/InventoryManager"):
		var inv: Node = get_node("/root/InventoryManager")
		if inv.has_method("consume_item"):
			if not inv.consume_item(item_id, 1):
				return &""

	# Roll a buff from the eligible pool
	var pool: Array[Dictionary] = ShrineBuffDatabase.get_pool_for_tier(tier)
	if pool.is_empty():
		return &""

	var buff: Dictionary = _weighted_pick(pool)
	if buff.is_empty():
		return &""
	var buff_id: StringName = buff["id"]

	# Apply the buff
	_apply_buff(buff)

	# Record cooldown
	_last_offering_hour_total = _current_hour_total()

	# Emit
	offering_made.emit(item_id, buff_id)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("shrine_offering_made"):
			bus.emit_signal("shrine_offering_made", shrine_id, item_id, buff_id)

	# SFX + visual
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_shrine_offering_accepted")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_shrine_blessing")

	return buff_id


func _weighted_pick(pool: Array[Dictionary]) -> Dictionary:
	var total: float = 0.0
	for entry in pool:
		var tier: int = clampi(int(entry.get("tier", 1)), 1, TIER_WEIGHTS.size())
		total += TIER_WEIGHTS[tier - 1]
	if total <= 0.0:
		return {}
	var roll: float = _rng.randf() * total
	var acc: float = 0.0
	for entry in pool:
		var tier: int = clampi(int(entry.get("tier", 1)), 1, TIER_WEIGHTS.size())
		acc += TIER_WEIGHTS[tier - 1]
		if roll <= acc:
			return entry
	return pool[pool.size() - 1]


func _apply_buff(buff: Dictionary) -> void:
	var buff_id: StringName = buff["id"]
	var duration_min: int = buff.get("duration_minutes", 30)
	var stat_mods: Dictionary = buff.get("stat_modifiers", {})

	if has_node("/root/BuffManager"):
		var bm: Node = get_node("/root/BuffManager")
		if bm.has_method("apply_timed_buff"):
			bm.apply_timed_buff(buff_id, stat_mods, duration_min * 60)
		elif bm.has_method("apply_buff"):
			bm.apply_buff(buff_id, stat_mods)
	# Fallback: emit a generic buff_granted signal if no BuffManager
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("buff_granted"):
			bus.emit_signal("buff_granted", buff_id)


# === COOLDOWN ===

func _hours_until_next_offering() -> int:
	var elapsed: int = _current_hour_total() - _last_offering_hour_total
	if elapsed >= COOLDOWN_HOURS:
		return 0
	return COOLDOWN_HOURS - elapsed


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

func _landmark_discovered() -> bool:
	if not has_node("/root/WildernessLandmarkManager"):
		return true  # permissive when system unloaded
	var lm: Node = get_node("/root/WildernessLandmarkManager")
	if lm.has_method("is_discovered"):
		return lm.is_discovered(&"lm_shrine")
	return true


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
		"last_offering_hour_total": _last_offering_hour_total,
	}


func from_save_data(data: Dictionary) -> void:
	_last_offering_hour_total = int(data.get("last_offering_hour_total", -100000))
