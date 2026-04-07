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


func _on_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player") and body == target_player:
		target_player = null


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


func _play_spawn_effect() -> void:
	# Scale from 0 to 1 with particle burst
	model.scale = Vector3(0.01, 0.01, 0.01)
	var tween: Tween = create_tween()
	tween.tween_property(model, "scale", Vector3(1.2, 1.2, 1.2), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(model, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	# Spawn particles
	if is_inside_tree():
		VFXFactory.spawn_hit_flash(global_position + Vector3(0, 0.5, 0), get_tree().current_scene)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
