class_name EnemyPromotion
extends RefCounted
## Phase 3 #20 — enemy roster expansion via runtime promotions.
##
## Authoring 5 brand-new enemy types (charger, shielder, summoner,
## sniper, suicide bomber) would require new scenes, scripts, state
## machines, and animations per archetype — well outside a single
## cron-task budget. Instead, this helper PROMOTES an existing enemy
## at spawn time by overlaying stat/scale/material tweaks on top of
## the base. The result is 5 mechanically-distinct archetypes built
## from the 3 existing enemy bases:
##
##   · Charger     (glitch_bug)   — fast, hits hard, dies fast
##   · Shielder    (glitch_bug)   — slow, tanky, low damage
##   · Sniper      (memory_leak)  — bigger projectile, more damage
##   · Bomber      (memory_leak)  — on-death AoE explode
##   · Summoner    (rogue_process)— bigger, periodically spawns adds
##
## Promotions reuse capture_pre_variant_baseline so reset() restores
## the un-promoted form on pool return — same idempotency safety net
## the floor 2 elite + floor 3 mini-boss code uses (gameplay/T46).
##
## EnemySpawner rolls a promotion chance per spawn slot scaling with
## iteration. At iter 1 the chance is 0% so the learn-the-game phase
## is unchanged. At iter 4 each spawn has a 35% chance to roll a
## random eligible promotion for its base type.

const PROMOTION_NONE: StringName = &""
const PROMOTION_CHARGER: StringName = &"charger"
const PROMOTION_SHIELDER: StringName = &"shielder"
const PROMOTION_SNIPER: StringName = &"sniper"
const PROMOTION_BOMBER: StringName = &"bomber"
const PROMOTION_SUMMONER: StringName = &"summoner"

## Per-base eligible promotion table. Used by EnemySpawner when
## rolling a random promotion for a given enemy type.
const ELIGIBLE_BY_TYPE: Dictionary = {
	"glitch_bug": [PROMOTION_CHARGER, PROMOTION_SHIELDER],
	"memory_leak": [PROMOTION_SNIPER, PROMOTION_BOMBER],
	"rogue_process": [PROMOTION_SUMMONER],
}


## Apply the named promotion to an enemy CharacterBody3D. Defensive
## against missing components (boss enemies skip stat scaling and
## are also exempt from promotion in the spawner). Idempotent on
## pool reuse via the capture_pre_variant_baseline pattern.
static func apply(enemy: CharacterBody3D, promotion_id: StringName) -> void:
	if enemy == null or promotion_id == PROMOTION_NONE:
		return
	# Skip if already promoted this round (re-apply on reset is OK
	# but double-promote in the same activation is not).
	if enemy.has_meta(&"_promotion"):
		return
	enemy.set_meta(&"_promotion", promotion_id)
	# Snapshot baseline so reset() can restore on pool return.
	if enemy.has_method(&"capture_pre_variant_baseline"):
		enemy.capture_pre_variant_baseline()
	match promotion_id:
		PROMOTION_CHARGER:
			_apply_charger(enemy)
		PROMOTION_SHIELDER:
			_apply_shielder(enemy)
		PROMOTION_SNIPER:
			_apply_sniper(enemy)
		PROMOTION_BOMBER:
			_apply_bomber(enemy)
		PROMOTION_SUMMONER:
			_apply_summoner(enemy)


static func _apply_charger(enemy: CharacterBody3D) -> void:
	## Glitch Bug variant: 2x movement speed, 1.5x base damage,
	## 0.6x HP. Reads as "the bug that picks one target and runs
	## you down." Tinted bright red with smaller scale.
	if &"move_speed" in enemy:
		enemy.move_speed = float(enemy.move_speed) * 2.0
	var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
	if hp:
		var base_hp: float = enemy._pre_variant_max_health if enemy._pre_variant_max_health > 0.0 else hp.base_max_health
		hp.base_max_health = base_hp * 0.6
		hp.max_health = base_hp * 0.6
		hp.current_health = hp.max_health
	if enemy.has_meta(&"base_attack_damage_mult"):
		enemy.set_meta(&"base_attack_damage_mult", 1.5)
	else:
		enemy.set_meta(&"base_attack_damage_mult", 1.5)
	if enemy.model:
		enemy.model.scale = enemy._pre_variant_model_scale * 0.85
	_tint(enemy, Color(1.0, 0.30, 0.20), Color(1.0, 0.05, 0.0), 1.4)


static func _apply_shielder(enemy: CharacterBody3D) -> void:
	## Glitch Bug variant: 3x HP, 0.6x damage, 1.3x scale. The
	## "soak" archetype — buys time for backline summons / leaks
	## to chip the player. Tinted deep blue.
	var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
	if hp:
		var base_hp: float = enemy._pre_variant_max_health if enemy._pre_variant_max_health > 0.0 else hp.base_max_health
		hp.base_max_health = base_hp * 3.0
		hp.max_health = base_hp * 3.0
		hp.current_health = hp.max_health
	enemy.set_meta(&"base_attack_damage_mult", 0.6)
	if enemy.model:
		enemy.model.scale = enemy._pre_variant_model_scale * 1.30
	_tint(enemy, Color(0.20, 0.50, 1.0), Color(0.10, 0.30, 0.95), 1.6)


static func _apply_sniper(enemy: CharacterBody3D) -> void:
	## Memory Leak variant: projectile damage doubled, scale up
	## to read at distance. The "watch out for the back rank"
	## archetype. Tinted hot purple.
	var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
	if hp:
		var base_hp: float = enemy._pre_variant_max_health if enemy._pre_variant_max_health > 0.0 else hp.base_max_health
		hp.base_max_health = base_hp * 1.4
		hp.max_health = base_hp * 1.4
		hp.current_health = hp.max_health
	enemy.set_meta(&"base_attack_damage_mult", 2.0)
	if enemy.model:
		enemy.model.scale = enemy._pre_variant_model_scale * 1.15
	_tint(enemy, Color(0.85, 0.20, 1.0), Color(0.65, 0.05, 0.95), 1.8)


static func _apply_bomber(enemy: CharacterBody3D) -> void:
	## Memory Leak variant: explodes on death. The death payload
	## meta is read by enemy_base._on_died which spawns an AoE
	## damage tick. Smaller HP so the player is incentivized to
	## kill it from distance. Tinted bright orange.
	var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
	if hp:
		var base_hp: float = enemy._pre_variant_max_health if enemy._pre_variant_max_health > 0.0 else hp.base_max_health
		hp.base_max_health = base_hp * 0.7
		hp.max_health = base_hp * 0.7
		hp.current_health = hp.max_health
	enemy.set_meta(&"death_explode_damage", 30.0)
	enemy.set_meta(&"death_explode_radius", 4.0)
	if enemy.model:
		enemy.model.scale = enemy._pre_variant_model_scale * 1.10
	_tint(enemy, Color(1.0, 0.55, 0.10), Color(1.0, 0.30, 0.0), 2.2)


static func _apply_summoner(enemy: CharacterBody3D) -> void:
	## Rogue Process variant: 1.4x scale + summon meta read by
	## enemy_base._process tick to spawn 1 glitch_bug every 6s.
	## Tinted bright yellow. The "minion factory" archetype.
	var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
	if hp:
		var base_hp: float = enemy._pre_variant_max_health if enemy._pre_variant_max_health > 0.0 else hp.base_max_health
		hp.base_max_health = base_hp * 2.0
		hp.max_health = base_hp * 2.0
		hp.current_health = hp.max_health
	enemy.set_meta(&"summon_interval", 6.0)
	enemy.set_meta(&"summon_type", "glitch_bug")
	if enemy.model:
		enemy.model.scale = enemy._pre_variant_model_scale * 1.4
	_tint(enemy, Color(1.0, 0.85, 0.20), Color(0.95, 0.65, 0.05), 1.5)


static func _tint(enemy: CharacterBody3D, albedo: Color, emission: Color, energy: float) -> void:
	## Apply a uniform tint to every mesh in the model. Same pattern
	## floor_2_config._buff_elite uses for the violet rogue elite
	## treatment. Skipped silently if the enemy has no meshes.
	if not enemy.has_method(&"get_mesh_instances"):
		return
	var meshes: Array[MeshInstance3D] = enemy.get_mesh_instances()
	if meshes.is_empty():
		return
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = energy
	mat.metallic = 0.40
	mat.roughness = 0.40
	for mesh: MeshInstance3D in meshes:
		mesh.material_override = mat
