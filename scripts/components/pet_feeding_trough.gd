class_name PetFeedingTrough
extends Area3D

## The pet hutch trough. Player walks up, presses interact, drops a
## food item from inventory into the trough, and the trough portion
## auto-feeds pets that visit during the next in-game day. Routes
## through the existing PetComponent.feed_treat happiness pump while
## also tracking a per-pet hunger meter that decays per in-game day.
##
## Behavior:
##   - The trough has 4 food slots (drop up to 4 portions)
##   - Each portion feeds 1 pet visit (auto-consumed)
##   - When a pet visits the hutch and the trough has portions, the
##     trough fires feed_treat() on PetComponent for that pet
##   - Pet hunger decays per in-game day; hungry pets that find food
##     get +bonus happiness on top of the standard +10 from feed_treat
##
## Required scene shape:
##   PetFeedingTrough (Area3D + this script)
##     CollisionShape3D (BoxShape3D, trough range)
##     PortionSlots (Node3D — 4 child Marker3D for visible food piles)
##     [optional] FoodPileMesh PackedScene for visible portions
##
## Configure via inspector:
##   max_portions      — slots in the trough (default 4)
##   bonus_per_hunger  — extra happiness per hunger point on a hungry pet

signal portion_added(food_id: StringName, slots_filled: int)
signal portion_consumed(pet_id: StringName, food_id: StringName, slots_remaining: int)
signal hunger_decayed
signal interaction_blocked(reason: StringName)

@export var max_portions: int = 4
@export var bonus_per_hunger: int = 1
@export var food_pile_scene: PackedScene  # optional visible mesh

@onready var _portion_slots: Node3D = $PortionSlots if has_node("PortionSlots") else null

var _portions: Array[Dictionary] = []  # [{food_id, source_id, visible_node}]
var _player_in_range: bool = false
var _player_node: Node3D
var _pet_hunger: Dictionary = {}  # pet_id → int 0-10
var _last_hunger_day: int = -1


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_layer = 0
	collision_mask = (1 << 0) | (1 << 4)  # player layer + pet layer
	monitorable = false
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("day_advanced"):
			dnc.day_advanced.connect(_on_day_advanced)


# === DROP FOOD ===

func can_drop() -> bool:
	if not _player_in_range:
		return false
	return _portions.size() < max_portions


func drop_food(food_id: StringName) -> bool:
	if not can_drop():
		interaction_blocked.emit(&"trough_full" if _portions.size() >= max_portions else &"not_in_range")
		return false
	if _player_node == null:
		interaction_blocked.emit(&"no_player")
		return false

	# Consume from inventory
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		interaction_blocked.emit(&"no_inventory")
		return false
	if not inv.has_method("remove_item_by_id") or not inv.remove_item_by_id(String(food_id), 1):
		interaction_blocked.emit(&"no_food_item")
		return false

	# Spawn the visible pile and record the portion
	var visible_node: Node3D = _spawn_portion_visual(_portions.size())
	_portions.append({
		"food_id": food_id,
		"visible_node": visible_node,
	})
	portion_added.emit(food_id, _portions.size())

	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_trough_drop")
	return true


func _spawn_portion_visual(slot_index: int) -> Node3D:
	if _portion_slots == null or food_pile_scene == null:
		return null
	var marker: Marker3D = _portion_slots.get_child(slot_index) as Marker3D if slot_index < _portion_slots.get_child_count() else null
	if marker == null:
		return null
	var inst: Node3D = food_pile_scene.instantiate() as Node3D
	if inst == null:
		return null
	marker.add_child(inst)
	inst.position = Vector3.ZERO
	return inst


# === PET FEEDING ===

func feed_visiting_pet(pet_id: StringName) -> bool:
	## Called by the pet AI when a pet enters the trough Area3D and
	## the trough has at least one portion.
	if _portions.is_empty():
		return false

	# Pop the oldest portion
	var portion: Dictionary = _portions.pop_front()
	var food_id: StringName = portion.get("food_id", &"")
	var visible: Node3D = portion.get("visible_node", null)
	if visible != null and is_instance_valid(visible):
		visible.queue_free()

	# Compute the happiness bonus from current hunger
	var hunger: int = int(_pet_hunger.get(pet_id, 0))
	var bonus: int = hunger * bonus_per_hunger

	# Route through PetComponent.feed_treat (which handles the +10 base
	# and the daily-cap logic)
	var pet_comp: Node = _get_pet_component()
	var current_day: int = _current_day()
	if pet_comp != null and pet_comp.has_method("feed_treat"):
		var ok: bool = pet_comp.feed_treat(pet_id, current_day)
		if ok and bonus > 0 and pet_comp.has_method("change_happiness"):
			pet_comp.change_happiness(pet_id, bonus)

	# Reset this pet's hunger
	_pet_hunger[pet_id] = 0

	# Refresh visible piles to slide down to fill the gap
	_compact_portion_visuals()

	portion_consumed.emit(pet_id, food_id, _portions.size())
	return true


func _compact_portion_visuals() -> void:
	# Re-anchor every remaining portion's visible node to its new slot
	if _portion_slots == null:
		return
	for i in _portions.size():
		var portion: Dictionary = _portions[i]
		var visible: Node3D = portion.get("visible_node", null)
		if visible == null or not is_instance_valid(visible):
			continue
		if i >= _portion_slots.get_child_count():
			continue
		var marker: Marker3D = _portion_slots.get_child(i) as Marker3D
		if marker == null:
			continue
		# Re-parent the visible to the new marker
		var current_parent: Node = visible.get_parent()
		if current_parent != marker:
			current_parent.remove_child(visible)
			marker.add_child(visible)
			visible.position = Vector3.ZERO


# === HUNGER DECAY ===

func _on_day_advanced(new_day: int) -> void:
	if new_day == _last_hunger_day:
		return
	_last_hunger_day = new_day
	# Every owned pet gains 1 hunger point per day, capped at 10
	var pet_comp: Node = _get_pet_component()
	if pet_comp == null or not pet_comp.has_method("get_owned_pets"):
		return
	var owned: Array = pet_comp.get_owned_pets()
	for pet_id in owned:
		var current: int = int(_pet_hunger.get(pet_id, 0))
		_pet_hunger[pet_id] = clampi(current + 1, 0, 10)
	hunger_decayed.emit()


func get_pet_hunger(pet_id: StringName) -> int:
	return int(_pet_hunger.get(pet_id, 0))


# === HELPERS ===

func _get_pet_component() -> Node:
	if _player_node != null:
		var c: Node = _player_node.get_node_or_null("PetComponent")
		if c != null:
			return c
	# Fallback to autoload if PetComponent isn't on the player directly
	if Engine.get_main_loop() != null:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		var pm: Node = root.get_node_or_null("PetManager")
		if pm != null:
			return pm
	return null


func _current_day() -> int:
	if not has_node("/root/DayNightController"):
		return 0
	var dnc: Node = get_node("/root/DayNightController")
	if "current_day" in dnc:
		return int(dnc.current_day)
	return 0


# === EVENTS ===

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_player_node = body
	elif body.is_in_group(&"pet"):
		# A pet wandered into the trough — try to feed it
		var pet_id: StringName = body.get_meta(&"pet_id", &"")
		if pet_id != &"":
			feed_visiting_pet(pet_id)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_player_node = null


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var p: Array = []
	for portion in _portions:
		p.append({"food_id": String(portion.get("food_id", &""))})
	var h: Dictionary = {}
	for k in _pet_hunger.keys():
		h[String(k)] = int(_pet_hunger[k])
	return {
		"portions": p,
		"pet_hunger": h,
		"last_hunger_day": _last_hunger_day,
	}


func from_save_data(data: Dictionary) -> void:
	_portions.clear()
	for entry in data.get("portions", []):
		_portions.append({
			"food_id": StringName(entry.get("food_id", "")),
			"visible_node": null,
		})
	_pet_hunger.clear()
	var h: Dictionary = data.get("pet_hunger", {})
	for k in h.keys():
		_pet_hunger[StringName(k)] = int(h[k])
	_last_hunger_day = int(data.get("last_hunger_day", -1))
	# Re-spawn visible piles for any restored portions
	for i in _portions.size():
		_portions[i]["visible_node"] = _spawn_portion_visual(i)
