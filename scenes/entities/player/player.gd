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

# Phase 3 #24 — light combo system. Each basic attack increments
# combo_count (1 → 2 → 3 → reset to 1). The chain decays back to 0
# when combo_window_left runs out of time, which physics_process
# decrements while the player isn't mid-attack. Energy Burst breaks
# the chain entirely. PlayerAttackState reads + updates these.
var combo_count: int = 0
var combo_window_left: float = 0.0
const COMBO_WINDOW: float = 1.10  # ~2x DATA_PULSE_COOLDOWN, gives breathing room

# Phase 3 #26 — skill tree / passive nodes. The player unlocks
# 1 passive every 3 levels (level 3, 6, 9, 12, ...). Auto-allocated
# in deterministic rotation order from PassiveNodeDatabase. The
# unlocked_passives list serializes to save data so progression
# survives reload. Effect application lives in _grant_passive.
var unlocked_passives: Array[String] = []
const PASSIVE_GRANT_LEVEL_INTERVAL: int = 3

# Phase 3 #25 — block / parry. Holding `block` (F by default) drains
# compute and mitigates incoming damage by BLOCK_DAMAGE_REDUCTION. The
# first BLOCK_PARRY_WINDOW seconds of a fresh block are a perfect parry
# — incoming hits are fully negated and the attacker gets tagged
# `fragmented` for free. hurtbox_component reads is_blocking +
# block_started_at to apply the damage reduction and parry payoff.
var is_blocking: bool = false
var block_started_at: float = 0.0
const BLOCK_COMPUTE_DRAIN_PER_SEC: float = 8.0
const BLOCK_DAMAGE_REDUCTION: float = 0.80  # 80% mitigation
const BLOCK_MOVE_SLOW: float = 0.30  # walk at 30% while blocking
const BLOCK_PARRY_WINDOW: float = 0.18  # first 0.18s of block = perfect parry
var _block_shield_ring: MeshInstance3D = null


func get_mesh_instances() -> Array[MeshInstance3D]:
	## Walk the model subtree and collect every MeshInstance3D so visual
	## effects (dash transparency, charge glow) work for both placeholder
	## meshes and the Blender GLB body model.
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


func _ready() -> void:
	add_to_group(&"player")
	_build_player_extras()
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed_color)
	hitbox_component.damage_source = self
	hurtbox_component.hit_received.connect(_on_hit_received)
	level_component.leveled_up.connect(_on_leveled_up)
	# Brief spawn-in flash on player when scene starts
	call_deferred(&"_spawn_in_flash")


func _spawn_in_flash() -> void:
	if not is_inside_tree():
		return
	# Bright cyan ring at player position
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.4
	torus.outer_radius = 0.55
	torus.rings = 16
	torus.ring_segments = 16
	ring.mesh = torus
	ring.scale = Vector3(0.3, 0.3, 0.3)
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position + Vector3(0, 0.1, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.85, 0.85, 0.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.25, 0.8, 0.8)
	mat.emission_energy_multiplier = 4.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = mat
	var tween: Tween = ring.create_tween()
	tween.tween_property(ring, "scale", Vector3(3.0, 1.0, 3.0), 0.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.6)
	tween.tween_callback(ring.queue_free)


func _on_health_changed_color(current: float, max_val: float) -> void:
	## Update player highlight ring color based on HP percentage
	var ring: MeshInstance3D = get_node_or_null("HighlightRing") as MeshInstance3D
	if ring == null or not is_instance_valid(ring):
		return
	var mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
	if mat == null:
		return
	var pct: float = current / max_val if max_val > 0 else 1.0
	var target_color: Color
	var emission_color: Color
	if pct > 0.6:
		# Healthy: cyan (default)
		target_color = Color(0.15, 0.6, 0.55, 0.35)
		emission_color = Color(0.1, 0.5, 0.45)
	elif pct > 0.3:
		# Medium: yellow-orange
		target_color = Color(0.7, 0.5, 0.1, 0.4)
		emission_color = Color(0.6, 0.4, 0.05)
	else:
		# Low: red
		target_color = Color(0.85, 0.15, 0.1, 0.45)
		emission_color = Color(0.75, 0.1, 0.05)
	var tween: Tween = ring.create_tween()
	tween.tween_property(mat, "albedo_color", target_color, 0.4)
	tween.parallel().tween_property(mat, "emission", emission_color, 0.4)


func _build_player_extras() -> void:
	# v4 hero: Player.tscn now instances globbler_v4.glb directly. Trust the
	# scene's GlobblerV4 / HeroSword / HeroShield children — don't clobber.
	var has_v4_hero: bool = false
	for child: Node in model.get_children():
		if child.name.begins_with("GlobblerV4") or child.name.begins_with("GlobblerR3") or child.name.begins_with("HeroSword") or child.name.begins_with("HeroShield"):
			has_v4_hero = true
			break
	if not has_v4_hero:
		var glb: PackedScene = load("res://assets/models/characters/globbler_v4.glb") as PackedScene
		if glb:
			for child: Node in model.get_children():
				if child is MeshInstance3D:
					child.queue_free()
			var instance: Node3D = glb.instantiate() as Node3D
			# v4 model is built at unit scale (~1.6m tall). Scale 0.45 to match
			# the existing collision capsule height.
			instance.scale = Vector3(0.45, 0.45, 0.45)
			model.add_child(instance)

	# Task 6: Replace medieval sword with digital data blade
	_replace_sword_with_data_blade()

	# v4 hero ships with its own visor, eyes, nameplate, antenna, and
	# materials baked in. Skip the legacy R3 orb-material override + procedural
	# eye/antenna code below (kept for reference but gated off).
	if false:
		var orb_mat: StandardMaterial3D = StandardMaterial3D.new()
		orb_mat.albedo_color = Color(0.18, 0.55, 0.62)
		orb_mat.emission_enabled = true
		orb_mat.emission = Color(0.1, 0.55, 0.55)
		orb_mat.emission_energy_multiplier = 0.6
		orb_mat.metallic = 0.4
		orb_mat.metallic_specular = 0.6
		orb_mat.roughness = 0.35
		var meshes: Array = []
		var stack: Array = [model]
		while not stack.is_empty():
			var n: Node = stack.pop_back()
			if n is MeshInstance3D and not (n.name == "HighlightRing"):
				meshes.append(n)
			for c in n.get_children():
				stack.append(c)
		for mesh: MeshInstance3D in meshes:
			mesh.material_override = orb_mat
		# Procedural cyan eyes — position derived from the largest mesh AABB
		# so they land on the upper-front of the GlobblerR3 sculpt.
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.85, 1.0, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.4, 0.95, 1.0)
		eye_mat.emission_energy_multiplier = 3.0
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var biggest_mesh: MeshInstance3D = null
		var biggest_size: float = 0.0
		var s2: Array = [model]
		while not s2.is_empty():
			var nn: Node = s2.pop_back()
			if nn is MeshInstance3D and (nn as MeshInstance3D).mesh and not (nn.name == "HighlightRing"):
				var a: AABB = (nn as MeshInstance3D).mesh.get_aabb()
				var sv: float = a.size.x * a.size.y * a.size.z
				if sv > biggest_size:
					biggest_size = sv
					biggest_mesh = nn as MeshInstance3D
			for c in nn.get_children():
				s2.append(c)
		if biggest_mesh != null:
			# Place eyes as children of the mesh node so the mesh's own
			# transform offset (often nonzero in sculpted GLBs) is applied.
			var ab: AABB = biggest_mesh.mesh.get_aabb()
			var center_x: float = ab.position.x + ab.size.x * 0.5
			var top_y: float = ab.position.y + ab.size.y * 0.72
			var front_z: float = ab.position.z + ab.size.z * 0.05
			var x_off: float = ab.size.x * 0.18
			var eye_radius: float = max(ab.size.x, ab.size.y) * 0.07
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
		# Antenna spike on top — also parented to the biggest mesh so the
		# sculpt's internal offset is applied. Sized relative to mesh AABB.
		if biggest_mesh != null:
			var ab2: AABB = biggest_mesh.mesh.get_aabb()
			var center_x2: float = ab2.position.x + ab2.size.x * 0.5
			var center_z: float = ab2.position.z + ab2.size.z * 0.5
			var mesh_top: float = ab2.position.y + ab2.size.y
			var ant_h: float = ab2.size.y * 0.35
			var antenna: MeshInstance3D = MeshInstance3D.new()
			var ant_mesh: CylinderMesh = CylinderMesh.new()
			ant_mesh.top_radius = 0.0
			ant_mesh.bottom_radius = ab2.size.x * 0.04
			ant_mesh.height = ant_h
			antenna.mesh = ant_mesh
			antenna.position = Vector3(center_x2, mesh_top + ant_h * 0.5, center_z)
			var ant_mat: StandardMaterial3D = StandardMaterial3D.new()
			ant_mat.albedo_color = Color(0.6, 0.95, 0.9)
			ant_mat.emission_enabled = true
			ant_mat.emission = Color(0.3, 0.85, 0.85)
			ant_mat.emission_energy_multiplier = 1.4
			antenna.material_override = ant_mat
			biggest_mesh.add_child(antenna)
			# Antenna tip — bright bulb
			var bulb: MeshInstance3D = MeshInstance3D.new()
			var bulb_mesh: SphereMesh = SphereMesh.new()
			bulb_mesh.radius = ab2.size.x * 0.07
			bulb_mesh.height = ab2.size.x * 0.14
			bulb.mesh = bulb_mesh
			bulb.position = Vector3(center_x2, mesh_top + ant_h, center_z)
			bulb.material_override = eye_mat
			biggest_mesh.add_child(bulb)

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
	player_light.light_energy = 0.6
	player_light.omni_range = 4.0
	player_light.omni_attenuation = 2.0
	add_child(player_light)
	# Subtle pulse on player light to feel alive
	var light_tween: Tween = create_tween().set_loops()
	light_tween.tween_property(player_light, "light_energy", 0.85, 2.0).set_ease(Tween.EASE_IN_OUT)
	light_tween.tween_property(player_light, "light_energy", 0.55, 2.0).set_ease(Tween.EASE_IN_OUT)

	# v4 hero already has arms + boots in the model. Skip the legacy
	# placeholder arm/foot stubs.
	if not has_v4_hero:
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


## Task 6: Replace medieval sword GLB with a procedural digital energy blade.
## Finds any HeroSword* child in Model and replaces its meshes with a glowing
## cyan/violet BoxMesh "data blade" that fits the digital simulation theme.
func _replace_sword_with_data_blade() -> void:
	var sword_root: Node = null
	for child: Node in model.get_children():
		if child.name.begins_with("HeroSword"):
			sword_root = child
			break
	if sword_root == null:
		return
	# Hide all original sword meshes
	var stack: Array[Node] = [sword_root]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			(n as MeshInstance3D).visible = false
		for c: Node in n.get_children():
			stack.append(c)
	# Create a procedural energy blade
	var blade: MeshInstance3D = MeshInstance3D.new()
	blade.name = "DataBlade"
	var blade_mesh: BoxMesh = BoxMesh.new()
	blade_mesh.size = Vector3(0.06, 0.8, 0.02)
	blade.mesh = blade_mesh
	blade.position = Vector3(0, 0.4, 0)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.1, 0.7, 0.9, 0.85)
	blade_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	blade_mat.emission_enabled = true
	blade_mat.emission = Color(0.2, 0.8, 1.0)
	blade_mat.emission_energy_multiplier = 2.5
	blade_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	blade.material_override = blade_mat
	sword_root.add_child(blade)
	# Hilt — small dark grip
	var hilt: MeshInstance3D = MeshInstance3D.new()
	hilt.name = "DataHilt"
	var hilt_mesh: BoxMesh = BoxMesh.new()
	hilt_mesh.size = Vector3(0.1, 0.12, 0.04)
	hilt.mesh = hilt_mesh
	hilt.position = Vector3(0, -0.02, 0)
	var hilt_mat: StandardMaterial3D = StandardMaterial3D.new()
	hilt_mat.albedo_color = Color(0.08, 0.12, 0.18)
	hilt_mat.emission_enabled = true
	hilt_mat.emission = Color(0.05, 0.3, 0.4)
	hilt_mat.emission_energy_multiplier = 0.5
	hilt.material_override = hilt_mat
	sword_root.add_child(hilt)


func _process(delta: float) -> void:
	if _prompt_cooldown > 0.0:
		_prompt_cooldown -= delta
	# Phase 3 #24 — combo decay. The window only ticks down while we
	# aren't actively swinging; PlayerAttackState refreshes the window
	# on every basic-attack enter() so chained hits keep the count.
	if combo_window_left > 0.0:
		combo_window_left -= delta
		if combo_window_left <= 0.0:
			combo_count = 0
	# Phase 3 #25 — block tick. Hold to drain compute, release or
	# run dry to drop the block. Blocked while attacking/dashing/dead
	# is just ignored (the action poll is skipped via the state-machine
	# guards in the active states).
	_tick_block(delta)
	# R7 AE1: Gold autopickup — walk over gold drops to collect
	IntegrationWiring.wire_gold_autopickup(self)
	# R7 AE8: Footstep SFX — play when moving
	if not has_meta(&"_footstep_timer"):
		set_meta(&"_footstep_timer", {"t": 0.0})
	AudioSceneWiring.wire_footstep(velocity.length(), delta, get_meta(&"_footstep_timer") as Dictionary)


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
				_spawn_buff_vfx()
	_prompt_cooldown = 0.5


func _spawn_buff_vfx() -> void:
	if not is_inside_tree():
		return
	# Purple overclock burst around player
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.emitting = true
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 1.0
	mat.initial_velocity_max = 2.5
	mat.orbit_velocity_min = 1.0
	mat.orbit_velocity_max = 1.8
	mat.gravity = Vector3(0, -1, 0)
	mat.color = Color(0.8, 0.3, 1.0, 0.8)
	mat.scale_min = 0.4
	mat.scale_max = 1.0
	particles.process_material = mat
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.04, 0.04, 0.04)
	particles.draw_pass_1 = mesh
	var vis: StandardMaterial3D = StandardMaterial3D.new()
	vis.albedo_color = Color(0.85, 0.35, 1.0, 0.8)
	vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis.emission_enabled = true
	vis.emission = Color(0.75, 0.25, 0.9)
	vis.emission_energy_multiplier = 3.0
	vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis
	get_tree().current_scene.add_child(particles)
	particles.global_position = global_position + Vector3(0, 0.5, 0)
	get_tree().create_timer(1.5).timeout.connect(particles.queue_free)
	# "OVERCLOCKED" text label
	var label: Label3D = Label3D.new()
	label.text = "OVERCLOCKED"
	label.font_size = 20
	label.modulate = Color(0.85, 0.35, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.7)
	label.outline_size = 3
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = global_position + Vector3(0, 2.0, 0)
	get_tree().current_scene.add_child(label)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "position:y", label.position.y + 1.5, 1.2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2).set_delay(0.4)
	tween.tween_callback(label.queue_free)


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
		# Camera zoom pulse
		var camera: Camera3D = get_viewport().get_camera_3d()
		if camera and camera.has_method(&"zoom_pulse"):
			camera.zoom_pulse(11.0, 0.4)
	var panel: Node = load("res://scripts/ui/stat_allocation_panel.gd").new()
	get_tree().root.add_child(panel)
	panel.show_panel(self)
	# Phase 3 #26 — passive node grant every PASSIVE_GRANT_LEVEL_INTERVAL levels.
	# The rotation index equals the number of passives already unlocked, so
	# reloading a save and re-granting produces the same sequence.
	if _new_level > 0 and _new_level % PASSIVE_GRANT_LEVEL_INTERVAL == 0:
		var idx: int = unlocked_passives.size()
		var node_id: String = PassiveNodeDatabase.get_id_at_index(idx)
		if node_id != "":
			unlocked_passives.append(node_id)
			_grant_passive(node_id)


## Phase 3 #26 — apply a single passive node's effect. Called on level-up
## and on save-load replay. For "stat" nodes, delegates to StatsComponent.
## For behavior nodes (crit / dash_cd / compute_kill), stacks into player
## metas that the respective consumers read each frame / event.
func _grant_passive(node_id: String) -> void:
	var node: Dictionary = PassiveNodeDatabase.get_by_id(node_id)
	if node.is_empty():
		push_warning("Player._grant_passive: unknown node '%s'" % node_id)
		return
	var effect_type: String = str(node.get("effect_type", ""))
	var amount: float = float(node.get("amount", 0.0))
	match effect_type:
		"stat":
			var key: String = str(node.get("effect_key", ""))
			if stats_component:
				if key == "all":
					# R5 U3: Final Optimization — apply to all 4 stats
					for stat_key: String in ["processing", "integrity", "bandwidth", "memory"]:
						stats_component.add_passive_bonus(stat_key, amount)
				elif key != "":
					stats_component.add_passive_bonus(key, amount)
		"crit":
			var prev: float = float(get_meta(&"passive_crit_bonus", 0.0))
			set_meta(&"passive_crit_bonus", prev + amount)
		"dash_cd":
			var prev: float = float(get_meta(&"passive_dash_cd_reduction", 0.0))
			set_meta(&"passive_dash_cd_reduction", prev + amount)
		"compute_kill":
			var prev: float = float(get_meta(&"passive_compute_on_kill", 0.0))
			set_meta(&"passive_compute_on_kill", prev + amount)
		"lifesteal":
			# R5 U1: Heal % of damage dealt
			var prev: float = float(get_meta(&"passive_lifesteal_pct", 0.0))
			set_meta(&"passive_lifesteal_pct", prev + amount)
		"thorns":
			# R5 U2: Reflect % damage to attackers
			var prev: float = float(get_meta(&"passive_thorns_pct", 0.0))
			set_meta(&"passive_thorns_pct", prev + amount)
		_:
			push_warning("Player._grant_passive: unknown effect_type '%s'" % effect_type)


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


# === Phase 3 #25 — block / parry ===

func _tick_block(delta: float) -> void:
	## Polled per-frame from _process. Reads the `block` action,
	## starts/stops the block state, drains compute, drops on empty.
	## Movement-side restrictions live in player_walk_state which
	## reads is_blocking + BLOCK_MOVE_SLOW directly.
	if not Input.is_action_pressed(&"block"):
		if is_blocking:
			_stop_block()
		return
	# Block-blocking states: dead / charging / dashing / mid-attack.
	# can_attack flips false during attack windups so it's a clean
	# proxy for "currently swinging".
	if health_component and health_component.is_dead:
		if is_blocking:
			_stop_block()
		return
	if not is_blocking:
		_start_block()
		return
	# Drain compute. The compute_component uses spend() which checks
	# the floor — we use it directly so the compute_depleted signal
	# fires on empty (which lets the HUD react if anything's wired).
	var drain: float = BLOCK_COMPUTE_DRAIN_PER_SEC * delta
	if compute_component and compute_component.current_compute > 0.0:
		# Use a direct decrement instead of spend() because spend()
		# requires the FULL amount and bails atomically; we want
		# partial drain on the last tick.
		compute_component.current_compute = maxf(
			0.0, compute_component.current_compute - drain
		)
		compute_component.compute_changed.emit(
			compute_component.current_compute, compute_component.max_compute
		)
		if compute_component.current_compute <= 0.0:
			_stop_block()


func _start_block() -> void:
	is_blocking = true
	block_started_at = Time.get_ticks_msec() / 1000.0
	set_meta(&"is_blocking", true)  # so hurtbox_component can read it
	_spawn_block_shield()


func _stop_block() -> void:
	is_blocking = false
	if has_meta(&"is_blocking"):
		remove_meta(&"is_blocking")
	_despawn_block_shield()


func _spawn_block_shield() -> void:
	## Cyan torus ring around the player while blocking. Tween-driven
	## subtle pulse so the player can see the block is active and the
	## brief parry window is over (the ring is brighter during parry).
	if _block_shield_ring and is_instance_valid(_block_shield_ring):
		_block_shield_ring.queue_free()
	_block_shield_ring = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 1.05
	torus.outer_radius = 1.30
	torus.rings = 24
	torus.ring_segments = 24
	_block_shield_ring.mesh = torus
	_block_shield_ring.position = Vector3(0, 0.6, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	# Bright cyan during parry window, cooler during sustained block
	mat.albedo_color = Color(0.45, 1.0, 0.95, 0.65)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.30, 0.85, 1.0)
	mat.emission_energy_multiplier = 3.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_block_shield_ring.material_override = mat
	add_child(_block_shield_ring)
	# Fade the parry-window glow down to a steady block hum
	var tween: Tween = _block_shield_ring.create_tween()
	tween.tween_interval(BLOCK_PARRY_WINDOW)
	tween.tween_property(mat, "emission_energy_multiplier", 1.6, 0.18)
	tween.parallel().tween_property(mat, "albedo_color", Color(0.30, 0.75, 1.0, 0.40), 0.18)


func _despawn_block_shield() -> void:
	if _block_shield_ring and is_instance_valid(_block_shield_ring):
		var ring: MeshInstance3D = _block_shield_ring
		_block_shield_ring = null
		var mat: Material = ring.material_override
		var tween: Tween = ring.create_tween()
		if mat is StandardMaterial3D:
			tween.tween_property(mat as StandardMaterial3D, "albedo_color:a", 0.0, 0.10)
		tween.tween_callback(ring.queue_free)


func is_in_parry_window() -> bool:
	## Returns true if the player started blocking within the last
	## BLOCK_PARRY_WINDOW seconds. Read by hurtbox_component on the
	## confirmed-hit path to upgrade a normal block into a parry.
	if not is_blocking:
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	return (now - block_started_at) < BLOCK_PARRY_WINDOW
