class_name Player
extends CharacterBody3D
## Player character — Globbler. Composed of reusable component nodes.

@export var move_speed: float = 6.0
@export var friction: float = 0.2
@export var turn_speed: float = 10.0
@export var dash_distance: float = 4.0
@export var dash_cooldown: float = 1.0
@export var iframe_duration: float = 0.3

@onready var state_machine: Node = %StateMachine
@onready var health_component: Node = %HealthComponent
@onready var compute_component: Node = %ComputeComponent
@onready var stats_component: Node = %StatsComponent
@onready var hitbox_component: Node = %HitboxComponent
@onready var hurtbox_component: Node = %HurtboxComponent
@onready var inventory_component: Node = %InventoryComponent
@onready var equipment_component: Node = %EquipmentComponent
@onready var ability_manager: Node = %AbilityManager
@onready var level_component: Node = %LevelComponent
@onready var interaction_area: Area3D = %InteractionArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var model: Node3D = %Model
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer
@onready var attack_cooldown_timer: Timer = %AttackCooldownTimer

var facing_direction: Vector3 = Vector3.FORWARD
var is_invulnerable: bool = false
var can_dash: bool = true
var can_attack: bool = true
var _prompt_cooldown: float = 0.0


func _ready() -> void:
	add_to_group(&"player")
	_build_player_extras()
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	health_component.died.connect(_on_died)
	hitbox_component.damage_source = self
	hurtbox_component.hit_received.connect(_on_hit_received)
	level_component.leveled_up.connect(_on_leveled_up)


func _build_player_extras() -> void:
	# Try loading Blender model for the player
	var glb: PackedScene = load("res://assets/models/characters/char_globbler_v2.glb") as PackedScene
	if glb:
		# Remove existing capsule mesh from Model node
		for child: Node in model.get_children():
			child.queue_free()
		var instance: Node3D = glb.instantiate() as Node3D
		model.add_child(instance)

	# Shadow disc under player
	var shadow: MeshInstance3D = MeshInstance3D.new()
	var shadow_mesh: PlaneMesh = PlaneMesh.new()
	shadow_mesh.size = Vector2(0.8, 0.8)
	shadow.mesh = shadow_mesh
	shadow.position = Vector3(0, 0.02, 0)
	var shadow_mat: StandardMaterial3D = StandardMaterial3D.new()
	shadow_mat.albedo_color = Color(0, 0, 0, 0.3)
	shadow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow.material_override = shadow_mat
	add_child(shadow)

	# Player highlight ring (helps visibility on dark dungeon floors)
	var ring: MeshInstance3D = MeshInstance3D.new()
	ring.name = "HighlightRing"
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.35
	ring_mesh.outer_radius = 0.42
	ring_mesh.rings = 12
	ring_mesh.ring_segments = 16
	ring.mesh = ring_mesh
	ring.position = Vector3(0, 0.03, 0)
	ring.rotation.x = 0  # Flat on ground
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.15, 0.6, 0.55, 0.35)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.1, 0.5, 0.45)
	ring_mat.emission_energy_multiplier = 0.8
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	add_child(ring)
	# Subtle pulse animation on ring emission
	var ring_tween: Tween = create_tween().set_loops()
	ring_tween.tween_property(ring_mat, "emission_energy_multiplier", 1.4, 1.5).set_ease(Tween.EASE_IN_OUT)
	ring_tween.tween_property(ring_mat, "emission_energy_multiplier", 0.6, 1.5).set_ease(Tween.EASE_IN_OUT)

	# Small overhead light so player is always visible
	var player_light: OmniLight3D = OmniLight3D.new()
	player_light.position = Vector3(0, 2.0, 0)
	player_light.light_color = Color(0.6, 0.9, 0.85)
	player_light.light_energy = 0.4
	player_light.omni_range = 3.0
	player_light.omni_attenuation = 2.0
	add_child(player_light)

	# Small arm stubs for silhouette
	var arm_mat: StandardMaterial3D = StandardMaterial3D.new()
	arm_mat.albedo_color = Color(0.22, 0.78, 0.75)
	arm_mat.roughness = 0.7
	for side: float in [-0.4, 0.4]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var arm_mesh: SphereMesh = SphereMesh.new()
		arm_mesh.radius = 0.12
		arm_mesh.height = 0.24
		arm.mesh = arm_mesh
		arm.position = Vector3(side, 0.45, 0)
		arm.material_override = arm_mat
		model.add_child(arm)

	# Small feet stubs
	for side: float in [-0.15, 0.15]:
		var foot: MeshInstance3D = MeshInstance3D.new()
		var foot_mesh: SphereMesh = SphereMesh.new()
		foot_mesh.radius = 0.1
		foot_mesh.height = 0.15
		foot.mesh = foot_mesh
		foot.position = Vector3(side, 0.08, 0)
		foot.material_override = arm_mat
		model.add_child(foot)


func _on_hit_received(damage_info: Resource) -> void:
	# HurtboxComponent already applied damage via HealthComponent and pipeline.
	# We just need to trigger the hurt state for knockback/stun.
	if is_invulnerable or health_component.is_dead:
		return
	if damage_info.source is Node3D:
		set_meta(&"damage_source_position", (damage_info.source as Node3D).global_position)
	var hurt_state: Node = state_machine.get_node_or_null("HurtState") as Node
	if hurt_state:
		state_machine.force_transition_to(hurt_state)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("DeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)


func _process(delta: float) -> void:
	if _prompt_cooldown > 0.0:
		_prompt_cooldown -= delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		_toggle_pause()
	elif event.is_action_pressed(&"use_prompt"):
		_try_use_prompt()
	elif event.is_action_pressed(&"inventory"):
		_toggle_inventory()
	elif event.is_action_pressed(&"toggle_quest_log"):
		_toggle_quest_log()


func _try_use_prompt() -> void:
	if _prompt_cooldown > 0.0:
		return
	# Block during dash or death
	var current: Node = state_machine.current_state
	if current.has_method(&"_flash_transparent") or (current.has_method(&"enter") and not current.can_be_interrupted):
		return
	var prompt: Resource = inventory_component.consume_active_prompt()
	if prompt == null:
		return
	match prompt.prompt_type:
		"health":
			health_component.heal(prompt.restore_amount)
		"compute":
			compute_component.restore(prompt.restore_amount)
		"buff":
			var sem: Node = get_node_or_null("StatusEffectManager") as Node
			if sem:
				var effect: Resource = load("res://scripts/combat/status_effect.gd").new()
				effect.effect_name = "Overclocked"
				effect.effect_type = "overclocked"
				effect.duration = prompt.buff_duration
				effect.tick_rate = 1.0
				effect.potency = 1.0
				sem.apply_effect(effect)
	_prompt_cooldown = 0.5


func _toggle_pause() -> void:
	if load("res://scripts/ui/pause_menu.gd").is_open():
		return  # Let the pause menu handle its own Esc
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	var menu: Node = load("res://scripts/ui/pause_menu.gd").new()
	get_tree().root.add_child(menu)


func _toggle_quest_log() -> void:
	if GameManager.current_state == GameManager.GameState.INVENTORY:
		return
	var quest_log: Node = load("res://scripts/ui/quest_log.gd").new()
	get_tree().root.add_child(quest_log)


func _toggle_inventory() -> void:
	if GameManager.current_state == GameManager.GameState.INVENTORY:
		return  # Already open, let the screen handle closing
	var screen: Node = load("res://scripts/ui/inventory_screen.gd").new()
	get_tree().root.add_child(screen)
	screen.open(self)


func _on_leveled_up(_new_level: int) -> void:
	# Level-up VFX burst
	if is_inside_tree():
		VFXFactory.spawn_level_up_effect(global_position, get_tree().current_scene)
		# Brief hitstop for dramatic impact
		_apply_level_up_hitstop()
	var panel: Node = load("res://scripts/ui/stat_allocation_panel.gd").new()
	get_tree().root.add_child(panel)
	panel.show_panel(self)


func _apply_level_up_hitstop() -> void:
	Engine.time_scale = 0.15
	get_tree().create_timer(0.08, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
	)


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	# Brief ring flash to indicate dash ready
	_flash_ring_ready()


func _flash_ring_ready() -> void:
	var ring: MeshInstance3D = get_node_or_null("HighlightRing") as MeshInstance3D
	if ring == null or not is_instance_valid(ring):
		return
	var mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
	if mat == null:
		return
	# Brief bright pulse
	var original_energy: float = mat.emission_energy_multiplier
	var original_color: Color = mat.albedo_color
	var tween: Tween = ring.create_tween()
	tween.tween_property(mat, "emission_energy_multiplier", 3.0, 0.08)
	tween.parallel().tween_property(mat, "albedo_color", Color(0.3, 0.9, 0.85, 0.6), 0.08)
	tween.tween_property(mat, "emission_energy_multiplier", original_energy, 0.2)
	tween.parallel().tween_property(mat, "albedo_color", original_color, 0.2)


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
