class_name BossAttackState
extends "res://scripts/state_machines/enemy/enemy_attack_state.gd"
## Corrupted Compiler boss attack — phase-aware multi-pattern attacks.

const COMPILE_ERROR_TELEGRAPH: float = 0.8
const COMPILE_ERROR_DAMAGE: float = 20.0
const COMPILE_ERROR_DURATION: float = 1.2
const OVERFLOW_PROJECTILE_COUNT: int = 3
const STACK_OVERFLOW_TELEGRAPH: float = 1.5
const STACK_OVERFLOW_DAMAGE: float = 50.0

# Phase 3 #32 — projectile fan telegraph constants for memory_overflow.
# The line is drawn 12 units long so it reaches the arena edge from
# any boss position; width is the projectile's collision diameter so
# the player can read the actual hit zone, not a vague hint. Lead
# duration is the wind-up window before the leak_projectiles spawn.
const TELEGRAPH_PROJECTILE_LENGTH: float = 12.0
const TELEGRAPH_PROJECTILE_WIDTH: float = 0.55
const TELEGRAPH_PROJECTILE_LEAD: float = 0.55

var _attack_count: int = 0
var _spawn_timer: float = 0.0


func _init() -> void:
	base_damage = 20.0
	attack_cooldown = 0.5


## Phase 3 #32 — telegraph audio cue. Routes through AudioManager
## (the actual loaded autoload) instead of the SfxManager hook in
## attack_telegraph.gd which is referenced by some legacy components
## but not registered as an autoload. play_sfx warns silently if the
## clip name is missing (T54), so we can ship the wiring before the
## actual audio assets land.
func _play_telegraph_cue(cue_id: StringName) -> void:
	if not state_machine or not state_machine.is_inside_tree():
		return
	var am: Node = state_machine.get_node_or_null("/root/AudioManager")
	if am and am.has_method(&"play_sfx"):
		am.play_sfx(String(cue_id))


## Phase 2 #14 — boss variant per iteration. Pulls the current
## compaction iteration so the rotation can tighten as the loop
## advances. Defensive against the autoload being absent (test
## scenes / pre-init pool warm-ups). Returns 1 as the floor.
func _current_iter() -> int:
	if Engine.has_singleton("IterationManager"):
		var im_a: Object = Engine.get_singleton("IterationManager")
		if im_a.has_method("get_current_iteration"):
			return int(im_a.call("get_current_iteration"))
	if state_machine and state_machine.is_inside_tree():
		var im_b: Node = state_machine.get_node_or_null("/root/IterationManager")
		if im_b and im_b.has_method(&"get_current_iteration"):
			return int(im_b.get_current_iteration())
	return 1


## Called from CorruptedCompiler.reset() so the attack rotation and add-spawn
## timer start fresh on every pool re-activation. Without this, iter 2's boss
## fight inherits whatever counter values the iter 1 fight ended on, jumping
## straight to a stack_overflow if _attack_count happened to land at 7.
func reset_pattern() -> void:
	_attack_count = 0
	_spawn_timer = 0.0


func enter() -> void:
	var boss = player
	if boss.is_transitioning:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)
		return

	_timer = 0.0
	_hitbox_enabled = false
	_attack_count += 1

	# Face player
	if boss.target_player:
		var dir: Vector3 = (boss.target_player.global_position - boss.global_position).normalized()
		dir.y = 0.0
		if dir.length() > 0.1:
			boss.model.rotation.y = atan2(dir.x, dir.z)

	boss.velocity = Vector3.ZERO

	# Phase 2 #14 — iteration-aware attack rotation. The base table
	# (iter 1) keeps the original gating so the first run is the
	# learn-the-fight version. As the loop deepens, attacks unlock
	# earlier and the rotation tightens.
	#
	#   iter | stack_overflow | memory_overflow | spawn_timer
	#   ---- | -------------- | --------------- | -----------
	#    1   | phase 3, %8    | phase 2, %3     | 15.0s
	#    2   | phase 3, %6    | phase 2, %3     | 12.0s
	#    3   | phase 2, %6    | phase 1, %3     | 10.0s
	#    4   | phase 1, %5    | phase 1, %3     |  8.0s
	#
	# Phase-gating is the dominant lever — by iter 4 the player
	# faces every pattern from the moment the bar starts dropping.
	var phase: int = boss.current_phase
	var iter: int = _current_iter()
	var stack_phase_min: int = 3
	var stack_mod: int = 8
	var mem_phase_min: int = 2
	match iter:
		2:
			stack_mod = 6
		3:
			stack_phase_min = 2
			stack_mod = 6
			mem_phase_min = 1
		_:
			if iter >= 4:
				stack_phase_min = 1
				stack_mod = 5
				mem_phase_min = 1
	if phase >= stack_phase_min and _attack_count % stack_mod == 0:
		_do_stack_overflow(boss)
	elif phase >= mem_phase_min and _attack_count % 3 == 0:
		_do_memory_overflow(boss)
	else:
		_do_compile_error(boss)


func _do_compile_error(boss: CharacterBody3D) -> void:
	# Telegraph
	boss.hitbox_component.set_meta(&"base_damage", boss.scaled_attack_damage(COMPILE_ERROR_DAMAGE))
	boss.hitbox_component.set_meta(&"damage_type", &"physical")

	# Apply status in later phases
	if boss.current_phase >= 3:
		boss.set_meta(&"apply_fragmented", true)
	elif boss.current_phase >= 2:
		boss.set_meta(&"apply_corrupted", true)

	if boss.animation_player.has_animation(&"attack"):
		boss.animation_player.play(&"attack")

	# Speed modifier for phase 2+
	var speed_mult: float = 1.2 if boss.current_phase >= 2 else 1.0
	var telegraph: float = COMPILE_ERROR_TELEGRAPH / speed_mult

	# Phase 3 #32 — polished AoE telegraph: 3-phase yellow → orange → red
	# ramp with outline ring (v2 helper) instead of the flat red disk.
	# Audio sting fires on telegraph start so the player can react even
	# with the camera off-center.
	if boss.is_inside_tree() and boss.target_player:
		var attack_dir: Vector3 = (boss.target_player.global_position - boss.global_position).normalized()
		attack_dir.y = 0.0
		AttackTelegraph.show_circle_telegraph(
			boss.global_position + attack_dir * 1.5,
			boss.attack_range * 0.8,
			telegraph,
			boss.get_tree().current_scene,
			false,  # use_decal=false → plane fill (no Decal hit on dungeon scenes)
		)
		_play_telegraph_cue(&"boss_telegraph_aoe")

	await boss.get_tree().create_timer(telegraph).timeout
	if not is_instance_valid(boss) or boss.is_transitioning:
		return

	boss.hitbox_component.activate()
	await boss.get_tree().create_timer(0.3).timeout
	if is_instance_valid(boss):
		boss.hitbox_component.deactivate()
		boss.remove_meta(&"apply_fragmented")
		boss.remove_meta(&"apply_corrupted")

	await boss.get_tree().create_timer(0.5).timeout
	if is_instance_valid(boss) and not boss.is_transitioning:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func _do_memory_overflow(boss: CharacterBody3D) -> void:
	if boss.target_player == null:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)
		return

	var base_dir: Vector3 = (boss.target_player.global_position - boss.global_position).normalized()
	base_dir.y = 0.0

	# Phase 2 #14 — iter 3+ adds a 4th projectile, iter 4 adds a 5th.
	# Center index shifts so the spread stays symmetric. The base
	# constant stays at 3 so iter 1/2 fights are unchanged.
	var iter_proj: int = _current_iter()
	var proj_count: int = OVERFLOW_PROJECTILE_COUNT
	if iter_proj >= 4:
		proj_count = 5
	elif iter_proj >= 3:
		proj_count = 4
	var center_idx: float = float(proj_count - 1) * 0.5

	# Phase 3 #32 — telegraph the projectile fan BEFORE it fires so the
	# player can dash out of the line. Pre-T32 the projectiles spawned
	# instantly with no warning, which made memory_overflow feel like a
	# damage roulette instead of a readable attack. We draw a thin line
	# telegraph along each spawn vector and play the projectile cue.
	if boss.is_inside_tree():
		for i: int in proj_count:
			var angle_offset: float = (float(i) - center_idx) * 0.3
			var dir: Vector3 = base_dir.rotated(Vector3.UP, angle_offset)
			AttackTelegraph.show_line_telegraph(
				boss.global_position + Vector3(0, 0.5, 0),
				dir,
				TELEGRAPH_PROJECTILE_LENGTH,
				TELEGRAPH_PROJECTILE_WIDTH,
				TELEGRAPH_PROJECTILE_LEAD,
				boss.get_tree().current_scene,
			)
		_play_telegraph_cue(&"boss_telegraph_projectile")
		await boss.get_tree().create_timer(TELEGRAPH_PROJECTILE_LEAD).timeout
		if not is_instance_valid(boss) or boss.is_transitioning:
			return

	for i: int in proj_count:
		var angle_offset: float = (float(i) - center_idx) * 0.3
		var dir: Vector3 = base_dir.rotated(Vector3.UP, angle_offset)
		var projectile: Node = load("res://scenes/entities/enemies/memory_leak/leak_projectile.gd").new()
		projectile.source_node = boss
		projectile.base_damage = boss.scaled_attack_damage(15.0)
		projectile.direction = dir
		# Collision shape
		var shape: CollisionShape3D = CollisionShape3D.new()
		var sphere: SphereShape3D = SphereShape3D.new()
		sphere.radius = 0.4
		shape.shape = sphere
		projectile.add_child(shape)
		boss.get_tree().current_scene.add_child(projectile)
		projectile.global_position = boss.global_position + Vector3(0, 0.5, 0)

	await boss.get_tree().create_timer(1.0).timeout
	if is_instance_valid(boss) and not boss.is_transitioning:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func _do_stack_overflow(boss: CharacterBody3D) -> void:
	# Arena-wide telegraph — flash warning
	# Safe zone in a random corner
	var corners: Array[Vector3] = [
		Vector3(-10, 0, -10), Vector3(10, 0, -10),
		Vector3(-10, 0, 10), Vector3(10, 0, 10)
	]
	var safe_corner: Vector3 = corners[randi() % corners.size()]

	# Phase 3 #32 — pre-T32 only the safe corner had a green tint, which
	# read as "stand here for a reward" instead of "everywhere else is
	# about to die". Now we paint the danger zone with the polished v2
	# circle telegraph (3-phase yellow → orange → red ramp on a giant
	# AoE) AND keep the safe corner indicator so the player has both
	# pieces of information. Audio sting fires on telegraph start.
	if boss.is_inside_tree():
		AttackTelegraph.show_circle_telegraph(
			boss.global_position,
			18.0,  # ~ arena radius — covers everything except the safe corner
			STACK_OVERFLOW_TELEGRAPH,
			boss.get_tree().current_scene,
			false,
		)
		_play_telegraph_cue(&"boss_telegraph_arena")

	# Create visual indicator (placeholder green zone)
	var safe_zone: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(6, 6)
	safe_zone.mesh = plane
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 1.0, 0.2, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	safe_zone.material_override = mat
	boss.get_tree().current_scene.add_child(safe_zone)
	safe_zone.global_position = safe_corner + Vector3(0, 0.05, 0)

	await boss.get_tree().create_timer(STACK_OVERFLOW_TELEGRAPH).timeout
	if not is_instance_valid(boss):
		safe_zone.queue_free()
		return

	# Deal damage to player if not in safe zone
	var nodes: Array[Node] = boss.get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		var p: CharacterBody3D = nodes[0] as CharacterBody3D
		if p.global_position.distance_to(safe_corner) > 4.0:
			p.health_component.take_damage(boss.scaled_attack_damage(STACK_OVERFLOW_DAMAGE))
			if p.has_meta(&"damage_source_position") == false:
				p.set_meta(&"damage_source_position", boss.global_position)
			var hurt: Node = p.state_machine.get_node_or_null("HurtState") as Node
			if hurt and not p.health_component.is_dead:
				p.state_machine.force_transition_to(hurt)

	safe_zone.queue_free()

	await boss.get_tree().create_timer(0.5).timeout
	if is_instance_valid(boss) and not boss.is_transitioning:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func physics_update(delta: float) -> void:
	# Spawn Glitch Bugs periodically in phase 1+. Phase 2 #14: the
	# spawn cadence tightens with the iteration so by iter 4 the boss
	# refreshes its add pool every 8s instead of every 15s. Add count
	# also bumps up by 1 at iter 4 to feed the more aggressive rotation.
	var boss = player
	_spawn_timer += delta
	var iter_phys: int = _current_iter()
	var spawn_threshold: float = 15.0
	var add_count: int = 3
	match iter_phys:
		2:
			spawn_threshold = 12.0
		3:
			spawn_threshold = 10.0
		_:
			if iter_phys >= 4:
				spawn_threshold = 8.0
				add_count = 4
	if _spawn_timer >= spawn_threshold:
		_spawn_timer = 0.0
		for i: int in add_count:
			var enemy: CharacterBody3D = EnemyPool.get_enemy("glitch_bug")
			if enemy:
				enemy.global_position = boss.global_position + Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
				if enemy.is_in_group(&"enemies"):
					(enemy as CharacterBody3D).spawn_position = enemy.global_position
				enemy.reparent(boss.get_tree().current_scene)
