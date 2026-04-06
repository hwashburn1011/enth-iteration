class_name AbilityManager
extends Node
## Manages module abilities bound to keys 1-4. Handles cooldowns and compute costs.

signal ability_used(slot_index: int, module: ModuleItem)
signal ability_ready(slot_index: int)

var ability_slots: Array[Dictionary] = [{}, {}, {}, {}]

var _compute_component: ComputeComponent = null
var _player: Node = null


func _ready() -> void:
	_player = get_parent()
	_compute_component = _player.get_node_or_null("ComputeComponent") as ComputeComponent
	for i: int in 4:
		ability_slots[i] = {"module": null, "cooldown_timer": 0.0, "is_ready": true}


func _process(delta: float) -> void:
	for i: int in 4:
		var slot: Dictionary = ability_slots[i]
		if slot.get("module") != null and not slot.get("is_ready", true):
			slot["cooldown_timer"] -= delta
			if slot["cooldown_timer"] <= 0.0:
				slot["cooldown_timer"] = 0.0
				slot["is_ready"] = true
				ability_ready.emit(i)


func _unhandled_input(event: InputEvent) -> void:
	var actions: Array[StringName] = [&"ability_1", &"ability_2", &"ability_3", &"ability_4"]
	for i: int in 4:
		if event.is_action_pressed(actions[i]):
			_try_use_ability(i)
			return


func refresh_abilities(modules: Array[ModuleItem]) -> void:
	for i: int in 4:
		var module: ModuleItem = modules[i] if i < modules.size() else null
		ability_slots[i]["module"] = module
		if module == null:
			ability_slots[i]["cooldown_timer"] = 0.0
			ability_slots[i]["is_ready"] = true


func _try_use_ability(slot_index: int) -> void:
	var slot: Dictionary = ability_slots[slot_index]
	var module: ModuleItem = slot.get("module") as ModuleItem
	if module == null:
		return
	if not slot.get("is_ready", true):
		return

	# Check compute cost
	if _compute_component and not _compute_component.spend(module.compute_cost):
		return

	# Instantiate ability scene
	if module.ability_scene:
		var ability_instance: Node = module.ability_scene.instantiate()
		_player.add_child(ability_instance)

	# Start cooldown
	slot["is_ready"] = false
	slot["cooldown_timer"] = module.cooldown

	ability_used.emit(slot_index, module)
