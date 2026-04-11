class_name AbilityManager
extends Node
## Manages module abilities bound to keys 1-4. Handles cooldowns and compute costs.
##
## Module activation goes through _execute_ability() which dispatches by
## item_id (same pattern as ProtocolRunner). The legacy ability_scene
## field on ModuleItem is still honored as a fallback so future modules
## can ship a packed scene if they need complex per-ability nodes — but
## the three shipped modules (logic_bomb, packet_storm, defrag_pulse)
## have null ability_scene fields and use the inline dispatch below.
## Without this dispatch, pressing 1-4 with a module equipped just spends
## compute and goes on cooldown for zero effect.

signal ability_used(slot_index: int, module: Resource)
signal ability_ready(slot_index: int)

const LOGIC_BOMB_RADIUS: float = 5.0
const LOGIC_BOMB_DAMAGE: float = 35.0
const PACKET_STORM_PROJECTILES: int = 5
const PACKET_STORM_DAMAGE: float = 8.0
const PACKET_STORM_RANGE: float = 12.0
const PACKET_STORM_CONE_DEG: float = 30.0
const DEFRAG_HEAL_AMOUNT: float = 40.0

var ability_slots: Array[Dictionary] = [{}, {}, {}, {}]

var _compute_component: Node = null
var _player: Node = null


func _ready() -> void:
	_player = get_parent()
	_compute_component = _player.get_node_or_null("ComputeComponent") as Node
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


func refresh_abilities(modules: Array[Resource]) -> void:
	for i: int in 4:
		var module: Resource = modules[i] if i < modules.size() else null
		ability_slots[i]["module"] = module
		if module == null:
			ability_slots[i]["cooldown_timer"] = 0.0
			ability_slots[i]["is_ready"] = true


func _try_use_ability(slot_index: int) -> void:
	var slot: Dictionary = ability_slots[slot_index]
	var module: Resource = slot.get("module") as Resource
	if module == null:
		return
	if not slot.get("is_ready", true):
		return

	# Check compute cost
	if _compute_component and not _compute_component.spend(module.compute_cost):
		return

	_execute_ability(module)

	# Start cooldown
	slot["is_ready"] = false
	slot["cooldown_timer"] = module.cooldown

	ability_used.emit(slot_index, module)


func _execute_ability(module: Resource) -> void:
	## Dispatch the active effect. Prefer the legacy ability_scene path if
	## one is set on the resource (lets future modules ship complex per-
	## ability scenes). Otherwise fall back to the item_id dispatch below.
	if module.ability_scene:
		var ability_instance: Node = module.ability_scene.instantiate()
		_player.add_child(ability_instance)
		return
	match module.item_id:
		"module_logic_bomb":
			_do_logic_bomb()
		"module_packet_storm":
			_do_packet_storm()
		"module_defrag_pulse":
			_do_defrag_pulse()
		_:
			push_warning("AbilityManager: no implementation for module '%s'" % module.item_id)


func _do_logic_bomb() -> void:
	## AoE explosion centered on the player — damages every enemy in
	## LOGIC_BOMB_RADIUS for LOGIC_BOMB_DAMAGE.
	if not _player.is_inside_tree():
		return
	var origin: Vector3 = (_player as Node3D).global_position
	var tree: SceneTree = _player.get_tree()
	for enemy: Node in tree.get_nodes_in_group(&"enemies"):
		if not enemy is Node3D:
			continue
		var dist: float = (enemy as Node3D).global_position.distance_to(origin)
		if dist > LOGIC_BOMB_RADIUS:
			continue
		var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
		if hp and hp.has_method(&"take_damage"):
			hp.take_damage(LOGIC_BOMB_DAMAGE)


func _do_packet_storm() -> void:
	## Forward cone of small damage hits — picks the PACKET_STORM_PROJECTILES
	## closest enemies inside the cone and applies PACKET_STORM_DAMAGE to each.
	## No projectile entity, just an instant cone for now — keeps the runner
	## dependency-free until projectile pooling exists.
	if not _player.is_inside_tree():
		return
	var p: Node3D = _player as Node3D
	var origin: Vector3 = p.global_position
	var forward: Vector3 = -p.global_basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		return
	forward = forward.normalized()
	var cone_cos: float = cos(deg_to_rad(PACKET_STORM_CONE_DEG))
	var candidates: Array = []
	for enemy: Node in p.get_tree().get_nodes_in_group(&"enemies"):
		if not enemy is Node3D:
			continue
		var to_enemy: Vector3 = (enemy as Node3D).global_position - origin
		var dist: float = to_enemy.length()
		if dist > PACKET_STORM_RANGE or dist < 0.1:
			continue
		var dir: Vector3 = to_enemy / dist
		dir.y = 0.0
		if dir.length() < 0.01:
			continue
		dir = dir.normalized()
		if dir.dot(forward) < cone_cos:
			continue
		candidates.append({"enemy": enemy, "dist": dist})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["dist"]) < float(b["dist"]))
	var hits: int = mini(PACKET_STORM_PROJECTILES, candidates.size())
	for i: int in hits:
		var enemy: Node = (candidates[i] as Dictionary)["enemy"] as Node
		var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
		if hp and hp.has_method(&"take_damage"):
			hp.take_damage(PACKET_STORM_DAMAGE)


func _do_defrag_pulse() -> void:
	## Burst self-heal. The hand-tuned amount is intentionally large because
	## the 8s cooldown and 15 compute cost gate the spam.
	var hp: Node = _player.get_node_or_null("HealthComponent") as Node
	if hp and hp.has_method(&"heal"):
		hp.heal(DEFRAG_HEAL_AMOUNT)
