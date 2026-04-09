class_name PetComponent
extends Node

## Player-side pet manager. Owns: per-pet ownership, happiness, custom names,
## active pet selection, hatching eggs, evolution state.

signal pet_acquired(pet_id: StringName)
signal pet_active_changed(pet_id: StringName)
signal pet_happiness_changed(pet_id: StringName, new_happiness: int, new_tier: int)
signal pet_evolved(pet_id: StringName)
signal egg_hatched(pet_id: StringName)

## pet_id → { owned, happiness, name, last_pet_day, last_fed_day, evolved, completed_quest, treats_today }
var pet_state: Dictionary = {}
var active_pet_id: StringName = &""

## hatching_eggs: array of { egg_id, pet_id, hatch_at_unix_time }
var hatching_eggs: Array[Dictionary] = []


func _ready() -> void:
	# Initialize all pets
	for p in PetDatabase.get_all():
		pet_state[p["id"]] = {
			"owned": false,
			"happiness": 50,
			"name": String(p["name"]),
			"last_pet_day": -1,
			"last_fed_day": -1,
			"treats_today": 0,
			"evolved": false,
			"completed_quest": false,
		}

	# Subscribe to events
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("day_advanced"):
			bus.day_advanced.connect(_on_day_advanced)
		if bus.has_signal("dungeon_completed"):
			bus.dungeon_completed.connect(_on_dungeon_completed)


func _process(delta: float) -> void:
	_check_egg_hatching()


# === ACQUISITION ===

func acquire_pet(pet_id: StringName) -> bool:
	var state: Dictionary = pet_state.get(pet_id)
	if state == null or state.get("owned", false):
		return false
	state["owned"] = true
	pet_acquired.emit(pet_id)
	return true


func is_owned(pet_id: StringName) -> bool:
	return pet_state.get(pet_id, {}).get("owned", false)


func get_owned_count() -> int:
	var n: int = 0
	for k: StringName in pet_state.keys():
		if pet_state[k].get("owned", false):
			n += 1
	return n


# === ACTIVE PET ===

func set_active_pet(pet_id: StringName) -> bool:
	if pet_id != &"" and not is_owned(pet_id):
		return false
	active_pet_id = pet_id
	pet_active_changed.emit(pet_id)
	return true


func get_active_pet() -> StringName:
	return active_pet_id


func get_active_stat_bonus() -> Dictionary:
	if active_pet_id == &"":
		return {}
	return PetDatabase.get_stat_bonus(active_pet_id, get_happiness(active_pet_id))


# === HAPPINESS ===

func get_happiness(pet_id: StringName) -> int:
	return pet_state.get(pet_id, {}).get("happiness", 50)


func change_happiness(pet_id: StringName, delta: int) -> void:
	var state: Dictionary = pet_state.get(pet_id)
	if state == null:
		return
	var old_tier: int = PetDatabase.get_happiness_tier(state["happiness"])
	state["happiness"] = clampi(state["happiness"] + delta, 0, 100)
	var new_tier: int = PetDatabase.get_happiness_tier(state["happiness"])
	pet_happiness_changed.emit(pet_id, state["happiness"], new_tier)


func pet_interact(pet_id: StringName, current_day: int) -> bool:
	## Player petting. +5 happiness, max 1/day per pet.
	var state: Dictionary = pet_state.get(pet_id)
	if state == null:
		return false
	if state.get("last_pet_day", -1) == current_day:
		return false
	state["last_pet_day"] = current_day
	change_happiness(pet_id, 5)
	return true


func feed_treat(pet_id: StringName, current_day: int) -> bool:
	## Feed treat. +10 happiness, max 3/day.
	var state: Dictionary = pet_state.get(pet_id)
	if state == null:
		return false
	# Reset daily counter
	if state.get("last_fed_day", -1) != current_day:
		state["last_fed_day"] = current_day
		state["treats_today"] = 0
	if state["treats_today"] >= 3:
		return false
	state["treats_today"] += 1
	change_happiness(pet_id, 10)
	return true


# === HATCHING ===

func add_egg(egg_id: StringName, pet_id: StringName, hatch_minutes: int) -> void:
	var hatch_at: int = Time.get_unix_time_from_system() + hatch_minutes * 60
	hatching_eggs.append({
		"egg_id": egg_id,
		"pet_id": pet_id,
		"hatch_at_unix_time": hatch_at,
	})


func _check_egg_hatching() -> void:
	if hatching_eggs.is_empty():
		return
	var now: int = Time.get_unix_time_from_system()
	var to_remove: Array = []
	for i in hatching_eggs.size():
		var egg: Dictionary = hatching_eggs[i]
		if now >= egg["hatch_at_unix_time"]:
			acquire_pet(egg["pet_id"])
			egg_hatched.emit(egg["pet_id"])
			to_remove.append(i)
	# Remove in reverse order
	for i in range(to_remove.size() - 1, -1, -1):
		hatching_eggs.remove_at(to_remove[i])


# === EVOLUTION ===

func can_evolve(pet_id: StringName) -> bool:
	var state: Dictionary = pet_state.get(pet_id, {})
	if not state.get("owned", false):
		return false
	if state.get("evolved", false):
		return false
	if PetDatabase.get_happiness_tier(state.get("happiness", 0)) < 3:
		return false  # Must be Devoted
	if not state.get("completed_quest", false):
		return false  # Must have done their quest
	return true


func evolve(pet_id: StringName) -> bool:
	if not can_evolve(pet_id):
		return false
	pet_state[pet_id]["evolved"] = true
	pet_evolved.emit(pet_id)
	return true


# === RENAMING ===

func rename_pet(pet_id: StringName, new_name: String) -> bool:
	var state: Dictionary = pet_state.get(pet_id)
	if state == null or new_name.is_empty():
		return false
	state["name"] = new_name
	return true


# === DAILY TICK ===

func _on_day_advanced(_new_day: int) -> void:
	# Decay -2 happiness for any pet not interacted with today
	for pet_id: StringName in pet_state.keys():
		var state: Dictionary = pet_state[pet_id]
		if not state.get("owned", false):
			continue
		change_happiness(pet_id, -2)


func _on_dungeon_completed(_dungeon_id: StringName) -> void:
	# +15 happiness if active pet survived the dungeon
	if active_pet_id != &"":
		change_happiness(active_pet_id, 15)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"pet_state": pet_state,
		"active_pet_id": String(active_pet_id),
		"hatching_eggs": hatching_eggs,
	}


func from_save_data(data: Dictionary) -> void:
	pet_state = data.get("pet_state", {})
	active_pet_id = StringName(data.get("active_pet_id", ""))
	hatching_eggs = data.get("hatching_eggs", [])
