class_name EnemyBase
extends CharacterBody3D
## Base enemy — all enemy types inherit from this scene.

@export var move_speed: float = 3.0
@export var patrol_radius: float = 5.0
@export var attack_range: float = 2.0
@export var leash_time: float = 5.0
## Stable snake_case identifier emitted with EventBus.enemy_defeated.
## Used by LevelComponent's XP table and QuestManager objective filters.
## Subclasses must override this in _ready() — without it, the death
## state falls back to the PascalCase node name and the tiered XP table
## (and any quest filtering by enemy type) silently breaks.
@export var enemy_type: StringName = &""

@onready var state_machine: Node = %StateMachine
@onready var health_component: Node = %HealthComponent
@onready var stats_component: Node = %StatsComponent
@onready var hitbox_component: Node = %HitboxComponent
@onready var hurtbox_component: Node = %HurtboxComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var detection_area: Area3D = %DetectionArea
@onready var loot_dropper: Node = %LootDropper
@onready var model: Node3D = %Model

var target_player: Node3D = null
var spawn_position: Vector3 = Vector3.ZERO
var is_invulnerable: bool = false
## Seconds remaining before this enemy is allowed to start its next attack.
## Decremented by EnemyChaseState; set on EnemyAttackState.exit() so the
## per-type attack_cooldown actually gates the next swing instead of being
## dead data. Without this, chase→attack→chase→attack chains every ~0.6s.
var attack_cooldown_remaining: float = 0.0
var _health_bar_bg: MeshInstance3D = null
var _health_bar_fill: MeshInstance3D = null
var _health_bar_timer: float = 0.0
var _aggro_indicator: Label3D = null
var variant_tier: int = 0  ## 0=normal, 1=elite, 2=champion
var _elite_aura: GPUParticles3D = null

## Per-iteration HP multiplier added on top of the per-enemy base.
## Iteration 1 = 1.0x, iteration 6 = 1 + 5 * 0.15 = 1.75x. Reduced
## from 0.25 (playtest feedback: boss too hard on iter 2). Gentler
## curve lets players feel progression without hitting a wall.
const ITERATION_HP_MULT_PER_LOOP: float = 0.15
## Same curve for outgoing damage so harder enemies stay relatively
## threatening as the player's gear improves. Reduced from 0.25 to
## 0.15 (playtest feedback: player dies too fast on iter 2+).
const ITERATION_DAMAGE_MULT_PER_LOOP: float = 0.15
var damage_multiplier: float = 1.0
## Captured on the first iteration scaling call so re-scaling stays
## idempotent — without this, EnemyPool's pre-instantiated enemies were
## permanently locked to the iteration that was current when the pool
## warmed up at game launch, never picking up later iteration advances.
var _baseline_max_health: float = 0.0
var _baseline_captured: bool = false
## Snapshot of base_max_health + model.scale taken BEFORE any one-shot
## elite/variant buff (e.g. floor_2_config._buff_elite). reset() restores
## from these on pool return so the buff doesn't compound across iterations.
## Without this, the same RogueProcess instance buffed on iter 1 came out of
## the pool on iter 2 already 3x HP, then the buff stacked to 9x HP and 2.25x
## scale, etc.
var _pre_variant_max_health: float = 0.0
var _pre_variant_model_scale: Vector3 = Vector3.ONE
var _variant_buff_captured: bool = false
## At-spawn baseline of model.scale captured on first ready, restored on
## every pool reuse so the death-state dissolve tween (which shrinks the
## model to 0.01) doesn't leave subsequent re-activations invisible.
## Subclasses set their default scale in _ready (e.g. corrupted_compiler
## uses 2.0) so we have to grab the per-instance value, not Vector3.ONE.
var _baseline_model_scale: Vector3 = Vector3.ONE
var _baseline_scale_captured: bool = false


func _ready() -> void:
	add_to_group(&"enemies")
	spawn_position = global_position
	hitbox_component.damage_source = self
	# Enemies use hand-tuned per-type HP/compute, not the player's
	# integrity/memory progression scaling. Disable the auto-recalc so any
	# future stats_changed call (e.g. equipment, debuffs) doesn't stomp the
	# values set by the enemy subclass _ready or apply_variant().
	if &"enable_stat_scaling" in health_component:
		health_component.enable_stat_scaling = false
	var compute: Node = get_node_or_null("ComputeComponent") as Node
	if compute and &"enable_stat_scaling" in compute:
		compute.enable_stat_scaling = false
	_build_enemy_visual()
	_create_health_bar()
	# Guard against duplicate connections on pool reuse (_ready fires every add_child)
	if not hurtbox_component.hit_received.is_connected(_on_hit_received):
		hurtbox_component.hit_received.connect(_on_hit_received)
	if not health_component.died.is_connected(_on_died):
		health_component.died.connect(_on_died)
	if not detection_area.body_entered.is_connected(_on_detection_body_entered):
		detection_area.body_entered.connect(_on_detection_body_entered)
	if not detection_area.body_exited.is_connected(_on_detection_body_exited):
		detection_area.body_exited.connect(_on_detection_body_exited)
	# Defer the iteration scaling so it runs AFTER the subclass _ready
	# overrides health_component.max_health to its hand-tuned value.
	# Without the defer the multiplication happens against the EnemyBase
	# default and then the subclass overwrites it to a flat constant.
	call_deferred(&"_apply_iteration_scaling")
	# Capture model.scale baseline AFTER the subclass _ready has set its
	# per-type scale (e.g. corrupted_compiler uses 2.0). Used by reset()
	# to restore the death-state dissolve shrink on pool reuse.
	call_deferred(&"_capture_baseline_scale")


func _apply_iteration_scaling() -> void:
	## Idempotent — captures baseline on first call, then recomputes
	## max_health from baseline * iter_mult on every subsequent call.
	## EnemyPool calls this on _activate so pooled enemies always reflect
	## the CURRENT iteration when they re-enter combat, not whatever
	## iteration was active when the pool warmed up at game launch.
	if not _baseline_captured:
		_baseline_max_health = health_component.max_health
		_baseline_captured = true
	var iter: int = 1
	if has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method(&"get_current_iteration"):
			iter = int(im.get_current_iteration())
		elif "current_iteration" in im:
			iter = int(im.current_iteration)
	var hp_mult: float = 1.0 + float(maxi(iter - 1, 0)) * ITERATION_HP_MULT_PER_LOOP
	# Recompute from the captured baseline instead of multiplying current,
	# so pool re-activation doesn't compound the multiplier each loop.
	# Write to base_max_health (canonical) and mirror to max_health so the
	# value sticks even if some future stats_changed call recalculates
	# from the base. Pattern matches T7's enemy stat scaling audit.
	var scaled: float = _baseline_max_health * hp_mult
	if &"base_max_health" in health_component:
		health_component.base_max_health = scaled
	health_component.max_health = scaled
	health_component.current_health = scaled
	# Damage multiplier is read by attack states via scaled_attack_damage()
	# at the moment they seed the hitbox base_damage meta. Recomputed each
	# call so it stays in sync with the current iteration too.
	damage_multiplier = 1.0 + float(maxi(iter - 1, 0)) * ITERATION_DAMAGE_MULT_PER_LOOP


func scaled_attack_damage(base: float) -> float:
	## Helper used by attack states to apply iteration damage scaling.
	## Centralised here so the four attack-state subclasses don't have to
	## each duplicate the multiplier read.
	return base * damage_multiplier


func _on_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		target_player = body
		_show_aggro_indicator()


func _on_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player") and body == target_player:
		target_player = null
		_hide_aggro_indicator()


func _show_aggro_indicator() -> void:
	if _aggro_indicator != null:
		return
	_aggro_indicator = Label3D.new()
	_aggro_indicator.text = "!"
	_aggro_indicator.font_size = 36
	_aggro_indicator.modulate = Color(1.0, 0.3, 0.2, 0.9)
	_aggro_indicator.outline_modulate = Color(0, 0, 0, 0.8)
	_aggro_indicator.outline_size = 4
	_aggro_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_aggro_indicator.position = Vector3(0, 2.0, 0)
	add_child(_aggro_indicator)
	# Pop-in animation
	_aggro_indicator.scale = Vector3(0.01, 0.01, 0.01)
	var tween: Tween = _aggro_indicator.create_tween()
	tween.tween_property(_aggro_indicator, "scale", Vector3(1.3, 1.3, 1.3), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(_aggro_indicator, "scale", Vector3(1.0, 1.0, 1.0), 0.05)
	# Fade out after 1s
	tween.tween_interval(0.8)
	tween.tween_property(_aggro_indicator, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_cleanup_aggro_indicator)
	# Eye-shine flash at enemy's "face" height
	_spawn_aggro_flash()


func _spawn_aggro_flash() -> void:
	if not is_inside_tree():
		return
	var flash: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	flash.mesh = sphere
	flash.position = Vector3(0, 1.0, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.2, 0.1, 0.7)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.2, 0.1)
	mat.emission_energy_multiplier = 3.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash.material_override = mat
	add_child(flash)
	var tween: Tween = flash.create_tween()
	tween.tween_property(flash, "scale", Vector3(2.5, 2.5, 2.5), 0.25)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.25)
	tween.tween_callback(flash.queue_free)


func _hide_aggro_indicator() -> void:
	_cleanup_aggro_indicator()


func _cleanup_aggro_indicator() -> void:
	if _aggro_indicator != null and is_instance_valid(_aggro_indicator):
		_aggro_indicator.queue_free()
	_aggro_indicator = null


func _on_hit_received(damage_info: Resource) -> void:
	if health_component.is_dead:
		return
	if damage_info.source is Node3D:
		set_meta(&"damage_source_position", (damage_info.source as Node3D).global_position)
	# Aggro on hit
	if target_player == null and damage_info.source.is_in_group(&"player"):
		target_player = damage_info.source as Node3D
	var hurt_state: Node = state_machine.get_node_or_null("EnemyHurtState") as Node
	if hurt_state:
		state_machine.force_transition_to(hurt_state)


func _capture_baseline_scale() -> void:
	## Snapshot model.scale once after subclass _ready has set its per-type
	## value (e.g. corrupted_compiler uses 2.0). reset() restores from this
	## on every pool reuse so the death-state dissolve tween (which shrinks
	## model to 0.01) doesn't leave subsequent re-activations invisible.
	if _baseline_scale_captured:
		return
	if model != null:
		_baseline_model_scale = model.scale
		_baseline_scale_captured = true


## Called by one-shot variant buffers (floor_2_config._buff_elite, etc.)
## BEFORE they multiply HP/scale so reset() can restore the baseline on
## pool return. Idempotent — only captures the first call so re-buffing
## the same instance in a single fight doesn't lose the original baseline.
func capture_pre_variant_baseline() -> void:
	if _variant_buff_captured:
		return
	_pre_variant_max_health = health_component.base_max_health
	_pre_variant_model_scale = model.scale
	_variant_buff_captured = true


func reset() -> void:
	# Restore the at-spawn model.scale unconditionally so the death-state
	# dissolve tween (which shrinks model to 0.01) doesn't leave the next
	# pool re-activation invisible. The variant branch below can override
	# this with its own snapshot for elite enemies — both end up at the
	# same value for non-buffed pool reuse since pre_variant snapshots
	# the at-spawn scale before any mutation.
	if _baseline_scale_captured and model != null:
		model.scale = _baseline_model_scale
	# Restore pre-variant baseline FIRST so any iteration scaling that runs
	# after reset() recomputes from the un-buffed base_max_health, not the
	# 3x-elite-stacked one.
	if _variant_buff_captured:
		health_component.base_max_health = _pre_variant_max_health
		health_component.max_health = _pre_variant_max_health
		model.scale = _pre_variant_model_scale
		_variant_buff_captured = false
		# Force the next iteration scaling call to recapture the baseline
		# from this restored value rather than the stale stacked value.
		_baseline_captured = false
		remove_meta(&"_floor2_elite")
	health_component.reset()
	is_invulnerable = false
	target_player = null
	collision_layer = 2
	collision_mask = 9
	set_physics_process(true)
	set_process_unhandled_input(true)
	hitbox_component.deactivate()
	# Ensure StateMachine processing is enabled
	state_machine.set_process(true)
	state_machine.set_physics_process(true)
	state_machine.set_process_unhandled_input(true)
	# Reset state machine to idle
	var idle_state: Node = state_machine.get_node_or_null("EnemyIdleState") as Node
	if idle_state:
		state_machine.force_transition_to(idle_state)
	# Spawn-in materialization effect
	_play_spawn_effect()


func _create_health_bar() -> void:
	if _health_bar_bg != null:
		return
	# Background bar
	_health_bar_bg = MeshInstance3D.new()
	var bg_mesh: BoxMesh = BoxMesh.new()
	bg_mesh.size = Vector3(0.8, 0.08, 0.02)
	_health_bar_bg.mesh = bg_mesh
	_health_bar_bg.position = Vector3(0, 1.6, 0)
	var bg_mat: StandardMaterial3D = StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.15, 0.05, 0.05, 0.8)
	bg_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_health_bar_bg.material_override = bg_mat
	_health_bar_bg.visible = false
	add_child(_health_bar_bg)

	# Fill bar
	_health_bar_fill = MeshInstance3D.new()
	var fill_mesh: BoxMesh = BoxMesh.new()
	fill_mesh.size = Vector3(0.76, 0.06, 0.02)
	_health_bar_fill.mesh = fill_mesh
	_health_bar_fill.position = Vector3(0, 1.6, -0.01)
	var fill_mat: StandardMaterial3D = StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.9, 0.2, 0.15)
	fill_mat.emission_enabled = true
	fill_mat.emission = Color(0.8, 0.15, 0.1)
	fill_mat.emission_energy_multiplier = 0.5
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fill_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_health_bar_fill.material_override = fill_mat
	_health_bar_fill.visible = false
	add_child(_health_bar_fill)

	# Connect health changed
	if not health_component.health_changed.is_connected(_on_health_bar_update):
		health_component.health_changed.connect(_on_health_bar_update)


func _on_health_bar_update(current: float, max_val: float) -> void:
	if _health_bar_bg == null or _health_bar_fill == null:
		return
	if current >= max_val:
		_health_bar_bg.visible = false
		_health_bar_fill.visible = false
		return
	_health_bar_bg.visible = true
	_health_bar_fill.visible = true
	var ratio: float = clampf(current / max_val, 0.0, 1.0)
	_health_bar_fill.scale.x = ratio
	_health_bar_fill.position.x = (ratio - 1.0) * 0.38  # Offset to keep left-aligned
	# Color: green→yellow→red based on health
	var fill_mat: StandardMaterial3D = _health_bar_fill.material_override as StandardMaterial3D
	if fill_mat:
		if ratio > 0.5:
			fill_mat.albedo_color = Color(0.2, 0.85, 0.2)
			fill_mat.emission = Color(0.15, 0.7, 0.15)
		elif ratio > 0.25:
			fill_mat.albedo_color = Color(0.9, 0.8, 0.15)
			fill_mat.emission = Color(0.8, 0.7, 0.1)
		else:
			fill_mat.albedo_color = Color(0.9, 0.2, 0.15)
			fill_mat.emission = Color(0.8, 0.15, 0.1)
	_health_bar_timer = 4.0


func _process(delta: float) -> void:
	if _health_bar_timer > 0.0:
		_health_bar_timer -= delta
		if _health_bar_timer <= 0.0 and _health_bar_bg:
			_health_bar_bg.visible = false
			_health_bar_fill.visible = false
	# Idle bob animation on model
	if model and visible:
		var t: float = Time.get_ticks_msec() * 0.003
		model.position.y = sin(t) * 0.03
	# Phase 3 #20 — Summoner promotion: periodically spawn an add.
	# Meta is set by enemy_promotion._apply_summoner. The timer
	# lives in a separate meta key so reset() doesn't need to
	# touch it (it ticks down freshly on each pool reuse).
	if has_meta(&"summon_interval") and visible and not health_component.is_dead:
		var timer_left: float = float(get_meta(&"_summon_timer", 0.0))
		timer_left -= delta
		if timer_left <= 0.0:
			timer_left = float(get_meta(&"summon_interval"))
			_summoner_spawn_add()
		set_meta(&"_summon_timer", timer_left)


func _summoner_spawn_add() -> void:
	## Spawn 1 add of the summoner's configured type. Skipped if the
	## EnemyPool autoload is unavailable. New add inherits the same
	## scene parent so it joins the active enemy pool.
	if not has_node("/root/EnemyPool"):
		return
	var pool: Node = get_node("/root/EnemyPool")
	if not pool.has_method(&"get_enemy"):
		return
	var summon_type: String = String(get_meta(&"summon_type", "glitch_bug"))
	var add: CharacterBody3D = pool.get_enemy(summon_type)
	if add == null:
		return
	add.global_position = global_position + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5))
	if add.is_in_group(&"enemies"):
		add.spawn_position = add.global_position
	if add.get_parent() != get_tree().current_scene:
		add.reparent(get_tree().current_scene)


func _build_enemy_visual() -> void:
	# Override in subclasses for unique visuals
	pass


func _polish_r3_enemy(r3_root: Node3D, body_color: Color, eye_color: Color) -> void:
	## R5 round-4: same orb-polish workaround used for the player and NPCs.
	## R3 baked albedos are placeholder UV pads of solid pale color, so the
	## sculpts render as featureless white spheres in-game. Override the
	## material with a distinct hue and bolt on procedural eyes anchored to
	## the largest mesh's AABB so the enemy reads as a *creature* not a blob.
	if r3_root == null:
		return
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body_mat.emission_enabled = true
	body_mat.emission = body_color * 0.7
	body_mat.emission_energy_multiplier = 0.5
	body_mat.metallic = 0.2
	body_mat.roughness = 0.5
	body_mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	var biggest_mesh: MeshInstance3D = null
	var biggest_size: float = 0.0
	var stack: Array = [r3_root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).mesh:
			var a: AABB = (n as MeshInstance3D).mesh.get_aabb()
			var s: float = a.size.x * a.size.y * a.size.z
			if s > biggest_size:
				biggest_size = s
				biggest_mesh = n as MeshInstance3D
			(n as MeshInstance3D).material_override = body_mat
		for c in n.get_children():
			stack.append(c)
	if biggest_mesh == null:
		return
	# Procedural eyes anchored to the mesh's local AABB
	var ab: AABB = biggest_mesh.mesh.get_aabb()
	var center_x: float = ab.position.x + ab.size.x * 0.5
	var top_y: float = ab.position.y + ab.size.y * 0.78
	var front_z: float = ab.position.z + ab.size.z * 0.05
	var x_off: float = ab.size.x * 0.18
	var eye_radius: float = max(ab.size.x, ab.size.y) * 0.07
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = eye_color
	eye_mat.emission_enabled = true
	eye_mat.emission = eye_color
	eye_mat.emission_energy_multiplier = 3.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for side: float in [-x_off, x_off]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = eye_radius
		em.height = eye_radius * 2.0
		em.radial_segments = 12
		em.rings = 6
		eye.mesh = em
		eye.position = Vector3(center_x + side, top_y, front_z)
		eye.material_override = eye_mat
		biggest_mesh.add_child(eye)


func get_mesh_instances() -> Array[MeshInstance3D]:
	## Walk the model subtree and collect every MeshInstance3D. Works for
	## both the placeholder fallback meshes (first child is the body mesh)
	## and the Blender GLB models (first child is a Node3D wrapper).
	var out: Array[MeshInstance3D] = []
	if model == null:
		return out
	var stack: Array = [model]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			out.append(n as MeshInstance3D)
		for c in n.get_children():
			stack.append(c)
	return out


func apply_variant(tier: int) -> void:
	## Apply elite/champion variant: scale up, tint, add aura particles.
	variant_tier = tier
	if tier == 0:
		return
	# Scale up (1.2x elite, 1.5x champion)
	var scale_mult: float = 1.0 + tier * 0.2
	model.scale *= scale_mult
	# Stat boost — write to base_max_health so the multiplier survives any
	# future stats_changed recalculation (currently disabled for enemies,
	# but write to the canonical field to be safe).
	var hp_mult: float = 1.0 + tier * 0.5
	health_component.base_max_health *= hp_mult
	health_component.max_health *= hp_mult
	health_component.current_health = health_component.max_health
	stats_component.base_processing *= 1.0 + tier * 0.3
	# Aura particles
	if is_inside_tree():
		_elite_aura = GPUParticles3D.new()
		_elite_aura.amount = 8 + tier * 6
		_elite_aura.lifetime = 0.8
		var aura_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		aura_mat.direction = Vector3(0, 1, 0)
		aura_mat.spread = 180.0
		aura_mat.initial_velocity_min = 0.3
		aura_mat.initial_velocity_max = 0.8
		aura_mat.gravity = Vector3(0, 0.5, 0)
		aura_mat.orbit_velocity_min = 0.5
		aura_mat.orbit_velocity_max = 1.0
		# Elite = orange, Champion = purple
		aura_mat.color = Color(1.0, 0.6, 0.1, 0.6) if tier == 1 else Color(0.7, 0.2, 1.0, 0.6)
		_elite_aura.process_material = aura_mat
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = 0.03
		mesh.height = 0.06
		_elite_aura.draw_pass_1 = mesh
		var vis_mat: StandardMaterial3D = StandardMaterial3D.new()
		vis_mat.albedo_color = aura_mat.color
		vis_mat.emission_enabled = true
		vis_mat.emission = aura_mat.color
		vis_mat.emission_energy_multiplier = 2.0
		vis_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_elite_aura.material_override = vis_mat
		_elite_aura.position = Vector3(0, 0.5, 0)
		add_child(_elite_aura)
		# Ground ring under elite/champion
		var ring: MeshInstance3D = MeshInstance3D.new()
		var torus: TorusMesh = TorusMesh.new()
		torus.inner_radius = 0.45
		torus.outer_radius = 0.55
		torus.rings = 12
		torus.ring_segments = 16
		ring.mesh = torus
		ring.position = Vector3(0, 0.05, 0)
		var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
		ring_mat.albedo_color = aura_mat.color
		ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_mat.emission_enabled = true
		ring_mat.emission = aura_mat.color
		ring_mat.emission_energy_multiplier = 2.5
		ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = ring_mat
		add_child(ring)


func _play_spawn_effect() -> void:
	# Digital assembly: cyan particle column → scale in → pixel pop
	model.scale = Vector3(0.01, 0.01, 0.01)
	# Brief spawn invulnerability so player can see the materialization
	is_invulnerable = true
	if is_inside_tree():
		_spawn_assembly_particles()
	var tween: Tween = create_tween()
	# Phase 1: Particle column swirls (0.3s delay while particles build)
	tween.tween_interval(0.3)
	# Phase 2: Scale in with overshoot
	tween.tween_property(model, "scale", Vector3(1.15, 1.15, 1.15), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(model, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	# Phase 3: Pixel pop flash + end invulnerability
	tween.tween_callback(_spawn_pixel_pop)
	tween.tween_callback(func() -> void: is_invulnerable = false)


func _spawn_assembly_particles() -> void:
	if not is_inside_tree():
		return
	# Shielded indicator: brief expanding sphere that shrinks
	var shield: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.6
	sphere.height = 1.2
	shield.mesh = sphere
	var shield_mat: StandardMaterial3D = StandardMaterial3D.new()
	shield_mat.albedo_color = Color(0, 0.85, 1.0, 0.4)
	shield_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shield_mat.emission_enabled = true
	shield_mat.emission = Color(0, 0.7, 1.0)
	shield_mat.emission_energy_multiplier = 2.0
	shield_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shield_mat.cull_mode = BaseMaterial3D.CULL_BACK
	shield.material_override = shield_mat
	get_tree().current_scene.add_child(shield)
	shield.global_position = global_position + Vector3(0, 0.5, 0)
	var shield_tween: Tween = shield.create_tween()
	shield_tween.tween_property(shield, "scale", Vector3(0.3, 0.3, 0.3), 0.6).set_ease(Tween.EASE_IN)
	shield_tween.parallel().tween_property(shield_mat, "albedo_color:a", 0.0, 0.6)
	shield_tween.tween_callback(shield.queue_free)

	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 24
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.emitting = true
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 15.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 4.0
	mat.gravity = Vector3.ZERO
	mat.orbit_velocity_min = 1.5
	mat.orbit_velocity_max = 2.5
	mat.color = Color(0, 0.85, 1.0, 0.8)
	mat.scale_min = 0.5
	mat.scale_max = 1.2
	particles.process_material = mat
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.04, 0.04, 0.04)
	particles.draw_pass_1 = mesh
	var vis_mat: StandardMaterial3D = StandardMaterial3D.new()
	vis_mat.albedo_color = Color(0, 0.85, 1.0, 0.8)
	vis_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis_mat.emission_enabled = true
	vis_mat.emission = Color(0, 0.7, 0.9)
	vis_mat.emission_energy_multiplier = 2.5
	vis_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis_mat
	get_tree().current_scene.add_child(particles)
	particles.global_position = global_position
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)


func _spawn_pixel_pop() -> void:
	if not is_inside_tree():
		return
	VFXFactory.spawn_hit_flash(global_position + Vector3(0, 0.5, 0), get_tree().current_scene)


func _on_died() -> void:
	# Phase 3 #20 — Bomber promotion: deal AoE damage to the player
	# (and any other enemies caught in the blast) on death. The meta
	# is set by enemy_promotion._apply_bomber. Fires once on death,
	# safe against double-trigger because the death state guards
	# against re-entry.
	if has_meta(&"death_explode_damage"):
		_explode_on_death()
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)


func _explode_on_death() -> void:
	## Phase 3 #20 — Bomber promotion AoE on death. Damage applies
	## to the player only (so bombers don't friendly-fire each other
	## in chain explosions). VFX is a quick orange ring shockwave.
	if not is_inside_tree():
		return
	var dmg: float = float(get_meta(&"death_explode_damage"))
	var radius: float = float(get_meta(&"death_explode_radius", 4.0))
	var origin: Vector3 = global_position
	for p_node: Node in get_tree().get_nodes_in_group(&"player"):
		if not p_node is Node3D:
			continue
		if (p_node as Node3D).global_position.distance_to(origin) > radius:
			continue
		var hp: Node = p_node.get_node_or_null("HealthComponent") as Node
		if hp and hp.has_method(&"take_damage"):
			hp.take_damage(dmg)
	# Quick visual: orange shockwave ring at the bomber's position
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.2
	torus.outer_radius = 0.4
	ring.mesh = torus
	ring.scale = Vector3(0.5, 0.5, 0.5)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.55, 0.10, 0.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.30, 0.0)
	mat.emission_energy_multiplier = 4.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = mat
	get_tree().current_scene.add_child(ring)
	ring.global_position = origin + Vector3(0, 0.15, 0)
	var tw: Tween = ring.create_tween()
	tw.tween_property(ring, "scale", Vector3(radius * 2.0, 1.0, radius * 2.0), 0.45).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.55)
	tw.tween_callback(ring.queue_free)
