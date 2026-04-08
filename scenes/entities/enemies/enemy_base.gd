class_name EnemyBase
extends CharacterBody3D
## Base enemy — all enemy types inherit from this scene.

@export var move_speed: float = 3.0
@export var patrol_radius: float = 5.0
@export var attack_range: float = 2.0
@export var leash_time: float = 5.0

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
var _health_bar_bg: MeshInstance3D = null
var _health_bar_fill: MeshInstance3D = null
var _health_bar_timer: float = 0.0
var _aggro_indicator: Label3D = null
var variant_tier: int = 0  ## 0=normal, 1=elite, 2=champion
var _elite_aura: GPUParticles3D = null


func _ready() -> void:
	add_to_group(&"enemies")
	spawn_position = global_position
	hitbox_component.damage_source = self
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


func reset() -> void:
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


func _build_enemy_visual() -> void:
	# Override in subclasses for unique visuals
	pass


func apply_variant(tier: int) -> void:
	## Apply elite/champion variant: scale up, tint, add aura particles.
	variant_tier = tier
	if tier == 0:
		return
	# Scale up (1.2x elite, 1.5x champion)
	var scale_mult: float = 1.0 + tier * 0.2
	model.scale *= scale_mult
	# Stat boost
	health_component.max_health *= 1.0 + tier * 0.5
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


func _play_spawn_effect() -> void:
	# Digital assembly: cyan particle column → scale in → pixel pop
	model.scale = Vector3(0.01, 0.01, 0.01)
	if is_inside_tree():
		_spawn_assembly_particles()
	var tween: Tween = create_tween()
	# Phase 1: Particle column swirls (0.3s delay while particles build)
	tween.tween_interval(0.3)
	# Phase 2: Scale in with overshoot
	tween.tween_property(model, "scale", Vector3(1.15, 1.15, 1.15), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(model, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	# Phase 3: Pixel pop flash
	tween.tween_callback(_spawn_pixel_pop)


func _spawn_assembly_particles() -> void:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 24
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.emitting = true
	particles.global_position = global_position
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
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)


func _spawn_pixel_pop() -> void:
	if not is_inside_tree():
		return
	VFXFactory.spawn_hit_flash(global_position + Vector3(0, 0.5, 0), get_tree().current_scene)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
