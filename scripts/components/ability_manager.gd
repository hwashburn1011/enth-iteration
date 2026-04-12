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

## Ability damage formulas all share the per-processing scaling pattern
## from the basic attack so build payoff modules stay relevant as the
## player levels. Without the *_PROCESSING_SCALE term, the constants
## become irrelevant against scaled basic attacks by mid-game.
const LOGIC_BOMB_RADIUS: float = 5.0
const LOGIC_BOMB_DAMAGE: float = 35.0
const LOGIC_BOMB_PROCESSING_SCALE: float = 2.5
const PACKET_STORM_PROJECTILES: int = 5
const PACKET_STORM_DAMAGE: float = 8.0
const PACKET_STORM_PROCESSING_SCALE: float = 0.8
const PACKET_STORM_RANGE: float = 12.0
const PACKET_STORM_CONE_DEG: float = 30.0
const DEFRAG_HEAL_AMOUNT: float = 40.0
## Defrag scales the heal off integrity so a tanky build self-sustains
## harder than a glass cannon — symmetric with how processing drives
## offensive abilities.
const DEFRAG_HEAL_INTEGRITY_SCALE: float = 1.5

# Phase 3 #27 — module roster expansion. Each ability has a tuning
# block here so a single edit retunes the whole module. The 5 new
# modules cover the design pillars: cone DoT (fork_bomb), CC vacuum
# (garbage_collect), chain damage (recursion), AoE stun (deadlock),
# self-buff (refactor). All five route through _execute_ability via
# the inline dispatch — no ability_scene needed.
const FORK_BOMB_RANGE: float = 7.0
const FORK_BOMB_CONE_DEG: float = 50.0
const GARBAGE_COLLECT_RADIUS: float = 7.0
const GARBAGE_COLLECT_PULL_FRAC: float = 0.85  # 85% of distance pulled
const RECURSION_BOUNCES: int = 5
const RECURSION_BASE_DAMAGE: float = 22.0
const RECURSION_FALLOFF: float = 0.75  # each bounce keeps 75% of prior
const RECURSION_HOP_RANGE: float = 6.0
const RECURSION_PROCESSING_SCALE: float = 1.2
const DEADLOCK_RADIUS: float = 4.0
const DEADLOCK_THROTTLED_DURATION: float = 4.0  # extended slow
const REFACTOR_DURATION: float = 4.0  # how long Overclocked stays up

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
		var prev_module: Resource = ability_slots[i].get("module") as Resource
		ability_slots[i]["module"] = module
		# Always reset cooldown when the slot's module changes — without
		# this branch, swapping a module mid-cooldown left the new module
		# locked behind the previous module's cooldown timer + is_ready
		# flag. Only the unequip-to-null path was clearing it before, so
		# swap-to-different-module inherited the stale cooldown.
		if module != prev_module:
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
		"module_fork_bomb":
			_do_fork_bomb()
		"module_garbage_collect":
			_do_garbage_collect()
		"module_recursion":
			_do_recursion()
		"module_deadlock":
			_do_deadlock()
		"module_refactor":
			_do_refactor()
		_:
			push_warning("AbilityManager: no implementation for module '%s'" % module.item_id)


func _do_logic_bomb() -> void:
	## AoE explosion centered on the player — damages every enemy in
	## LOGIC_BOMB_RADIUS for LOGIC_BOMB_DAMAGE plus processing scaling.
	if not _player.is_inside_tree():
		return
	var origin: Vector3 = (_player as Node3D).global_position
	var dmg: float = LOGIC_BOMB_DAMAGE + _processing_stat() * LOGIC_BOMB_PROCESSING_SCALE
	var tree: SceneTree = _player.get_tree()
	for enemy: Node in tree.get_nodes_in_group(&"enemies"):
		if not enemy is Node3D:
			continue
		var dist: float = (enemy as Node3D).global_position.distance_to(origin)
		if dist > LOGIC_BOMB_RADIUS:
			continue
		var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
		if hp and hp.has_method(&"take_damage"):
			hp.take_damage(dmg)


func _processing_stat() -> float:
	var stats: Node = _player.get_node_or_null("StatsComponent") as Node
	if stats == null or not stats.has_method(&"get_stat"):
		return 0.0
	return stats.get_stat("processing")


func _integrity_stat() -> float:
	var stats: Node = _player.get_node_or_null("StatsComponent") as Node
	if stats == null or not stats.has_method(&"get_stat"):
		return 0.0
	return stats.get_stat("integrity")


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
	var per_hit: float = PACKET_STORM_DAMAGE + _processing_stat() * PACKET_STORM_PROCESSING_SCALE
	var hits: int = mini(PACKET_STORM_PROJECTILES, candidates.size())
	for i: int in hits:
		var enemy: Node = (candidates[i] as Dictionary)["enemy"] as Node
		var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
		if hp and hp.has_method(&"take_damage"):
			hp.take_damage(per_hit)


func _do_defrag_pulse() -> void:
	## Burst self-heal scaled by integrity so a tanky build sustains
	## harder. 8s cooldown and 15 compute cost gate the spam.
	var hp: Node = _player.get_node_or_null("HealthComponent") as Node
	if hp and hp.has_method(&"heal"):
		var amount: float = DEFRAG_HEAL_AMOUNT + _integrity_stat() * DEFRAG_HEAL_INTEGRITY_SCALE
		hp.heal(amount)


# === Phase 3 #27 — new modules ===

func _do_fork_bomb() -> void:
	## Forward cone — every enemy in front of the player gets tagged
	## with Corrupted. Doesn't deal direct damage; the value is the
	## DoT pressure + the +30% interaction with combat-amp builds.
	if not _player.is_inside_tree():
		return
	var p: Node3D = _player as Node3D
	var origin: Vector3 = p.global_position
	var forward: Vector3 = -p.global_basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		return
	forward = forward.normalized()
	var cone_cos: float = cos(deg_to_rad(FORK_BOMB_CONE_DEG))
	for enemy: Node in p.get_tree().get_nodes_in_group(&"enemies"):
		if not enemy is Node3D:
			continue
		var to_enemy: Vector3 = (enemy as Node3D).global_position - origin
		var dist: float = to_enemy.length()
		if dist > FORK_BOMB_RANGE or dist < 0.1:
			continue
		var dir: Vector3 = to_enemy / dist
		dir.y = 0.0
		if dir.length() < 0.01 or dir.normalized().dot(forward) < cone_cos:
			continue
		var sm: Node = enemy.get_node_or_null("StatusEffectManager") as Node
		if sm and sm.has_method(&"apply_effect"):
			var effect: Resource = load("res://scripts/combat/status_effect_library.gd").make_corrupted()
			if effect != null:
				sm.apply_effect(effect)


func _do_garbage_collect() -> void:
	## Pull every nearby enemy 85% of the way to the player's feet.
	## Sets up an AoE punish — pair with logic_bomb / fork_bomb for
	## the satisfying "vacuum then nuke" combo.
	if not _player.is_inside_tree():
		return
	var origin: Vector3 = (_player as Node3D).global_position
	for enemy: Node in _player.get_tree().get_nodes_in_group(&"enemies"):
		if not enemy is Node3D:
			continue
		var node3d: Node3D = enemy as Node3D
		var offset: Vector3 = origin - node3d.global_position
		offset.y = 0.0
		var dist: float = offset.length()
		if dist > GARBAGE_COLLECT_RADIUS or dist < 0.5:
			continue
		# Teleport-style yank — telegraph would be nicer but the 7s
		# cooldown gates the abuse and the AOE punish is the payoff.
		node3d.global_position = node3d.global_position + offset * GARBAGE_COLLECT_PULL_FRAC


func _do_recursion() -> void:
	## Chain damage that hops through the closest enemies. Each hop
	## loses 25% damage so it falls off after the 5th bounce.
	if not _player.is_inside_tree():
		return
	var origin: Vector3 = (_player as Node3D).global_position
	var per_hit: float = RECURSION_BASE_DAMAGE + _processing_stat() * RECURSION_PROCESSING_SCALE
	var visited: Array[Node] = []
	var current_pos: Vector3 = origin
	for hop: int in RECURSION_BOUNCES:
		# Find the nearest unvisited enemy within hop range of the
		# current position.
		var nearest: Node = null
		var nearest_dist: float = RECURSION_HOP_RANGE
		for enemy: Node in _player.get_tree().get_nodes_in_group(&"enemies"):
			if enemy in visited or not enemy is Node3D:
				continue
			var dist: float = (enemy as Node3D).global_position.distance_to(current_pos)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = enemy
		if nearest == null:
			return  # chain broke — no more hops in range
		visited.append(nearest)
		var hp: Node = nearest.get_node_or_null("HealthComponent") as Node
		if hp and hp.has_method(&"take_damage"):
			hp.take_damage(per_hit)
		per_hit *= RECURSION_FALLOFF
		current_pos = (nearest as Node3D).global_position


func _do_deadlock() -> void:
	## Hard CC — applies an extended Throttled to every enemy in a
	## tight radius. The point is to stop a melee swarm cold so the
	## player can reposition for a finisher. Lower compute cost than
	## logic_bomb because there's no damage payload.
	if not _player.is_inside_tree():
		return
	var origin: Vector3 = (_player as Node3D).global_position
	for enemy: Node in _player.get_tree().get_nodes_in_group(&"enemies"):
		if not enemy is Node3D:
			continue
		if (enemy as Node3D).global_position.distance_to(origin) > DEADLOCK_RADIUS:
			continue
		var sm: Node = enemy.get_node_or_null("StatusEffectManager") as Node
		if sm and sm.has_method(&"apply_effect"):
			# Build a one-shot Throttled with the extended duration —
			# we don't go through the library helper here because we
			# want a longer-than-default duration on this specific cast.
			var effect: Resource = load("res://scripts/combat/status_effect.gd").new()
			effect.effect_name = "Throttled"
			effect.effect_type = "throttled"
			effect.duration = DEADLOCK_THROTTLED_DURATION
			effect.tick_rate = 1.0
			effect.potency = 0.65  # heavier slow than the regular 50% bug snare
			sm.apply_effect(effect)


func _do_refactor() -> void:
	## Self-buff. Sets the player's Overclocked status flag for
	## REFACTOR_DURATION seconds. damage_calculator already reads
	## status_overclocked on the source side and applies +50% damage
	## (gameplay/T22 design pillar), so this is just a "build the
	## effect, hand it to the manager" call.
	var sm: Node = _player.get_node_or_null("StatusEffectManager") as Node
	if sm and sm.has_method(&"apply_effect"):
		var effect: Resource = load("res://scripts/combat/status_effect.gd").new()
		effect.effect_name = "Overclocked"
		effect.effect_type = "overclocked"
		effect.duration = REFACTOR_DURATION
		effect.tick_rate = 1.0
		# Damage_calculator just checks the meta presence (gameplay/T22
		# baseline reads `status_overclocked` for +50%), so potency is a
		# bookkeeping value — we set it to 1.0 for HUD readability.
		effect.potency = 1.0
		sm.apply_effect(effect)
