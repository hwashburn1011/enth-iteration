class_name LightningProjectile
extends Area3D
## Ranged lightning bolt projectile fired by the player's Data Pulse attack.
## Travels forward in the facing direction and hits the first enemy.

const LIGHTNING_COLOR: Color = Color(0.3, 0.9, 1.0)

@export var speed: float = 20.0
@export var max_range: float = 12.0
@export var base_damage: float = 5.0
@export var damage_type: StringName = &"lightning"

## The entity that fired this projectile (used for knockback direction + self-skip).
var _source: CharacterBody3D = null
## Track distance traveled to enforce max_range.
var _distance_traveled: float = 0.0
## Direction of travel (unit vector on XZ plane).
var _direction: Vector3 = Vector3.FORWARD
## Whether a hit has already been processed (prevents multi-hit).
var _hit: bool = false
## Combo step index for status effect routing (2 = finisher applies fragmented).
var combo_step: int = 0


func _ready() -> void:
	# Collision setup: scan layer 7 (Hurtbox) to detect enemies.
	collision_layer = 0
	collision_mask = 64  # bit 6 = layer 7 (Hurtbox)
	monitoring = true
	monitorable = false

	# Add collision shape — small capsule along Z axis
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.15
	capsule.height = 0.5
	col_shape.shape = capsule
	col_shape.rotation.x = PI / 2.0  # align capsule along Z
	add_child(col_shape)

	# Build visual mesh — elongated glowing cyan box
	var mesh_inst: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.1, 0.1, 0.4)
	mesh_inst.mesh = box
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = LIGHTNING_COLOR
	mat.emission_enabled = true
	mat.emission = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b)
	mat.emission_energy_multiplier = 4.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_inst.material_override = mat
	add_child(mesh_inst)

	# Core glow — slightly larger transparent overlay
	var glow_inst: MeshInstance3D = MeshInstance3D.new()
	var glow_box: BoxMesh = BoxMesh.new()
	glow_box.size = Vector3(0.18, 0.18, 0.5)
	glow_inst.mesh = glow_box
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b, 0.3)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b)
	glow_mat.emission_energy_multiplier = 2.0
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_inst.material_override = glow_mat
	add_child(glow_inst)

	# Particle trail
	var trail: GPUParticles3D = GPUParticles3D.new()
	trail.amount = 12
	trail.lifetime = 0.2
	trail.position = Vector3(0, 0, 0.15)  # emit from rear
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 0, 1)  # backwards relative to bolt
	pmat.spread = 25.0
	pmat.initial_velocity_min = 1.0
	pmat.initial_velocity_max = 2.5
	pmat.gravity = Vector3.ZERO
	pmat.color = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b, 0.6)
	pmat.scale_min = 0.2
	pmat.scale_max = 0.5
	trail.process_material = pmat
	var spark_mesh: BoxMesh = BoxMesh.new()
	spark_mesh.size = Vector3(0.03, 0.03, 0.03)
	trail.draw_pass_1 = spark_mesh
	var spark_vis: StandardMaterial3D = StandardMaterial3D.new()
	spark_vis.albedo_color = LIGHTNING_COLOR
	spark_vis.emission_enabled = true
	spark_vis.emission = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b)
	spark_vis.emission_energy_multiplier = 3.0
	spark_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail.material_override = spark_vis
	add_child(trail)

	# Connect area_entered for hurtbox detection
	area_entered.connect(_on_area_entered)


func setup(source: CharacterBody3D, direction: Vector3, damage: float, step: int) -> void:
	## Call after instantiation to configure the bolt.
	_source = source
	_direction = direction.normalized()
	base_damage = damage
	combo_step = step


func _physics_process(delta: float) -> void:
	if _hit:
		return
	var move: Vector3 = _direction * speed * delta
	global_position += move
	_distance_traveled += move.length()
	if _distance_traveled >= max_range:
		_fizzle_and_free()


func _on_area_entered(area: Area3D) -> void:
	if _hit:
		return
	# Only interact with HurtboxComponents
	if not area.has_method(&"_on_area_entered"):
		return
	# Skip self (player hurtbox)
	var target_entity: Node = area.get_parent()
	if target_entity == _source:
		return

	_hit = true

	# Build a temporary hitbox-like object for the hurtbox to read damage from.
	# HurtboxComponent expects: is_active, damage_source, has_hit(), register_hit(),
	# and meta keys base_damage / damage_type / apply_status.
	set_meta(&"base_damage", base_damage)
	set_meta(&"damage_type", damage_type)
	if combo_step == 2:
		set_meta(&"apply_status", &"fragmented")

	# The hurtbox calls has_hit / register_hit on the "hitbox" — we just say
	# we haven't hit this target yet so it processes the hit.
	# We fake the hitbox API directly on ourselves.
	area._on_area_entered(self)

	# Spawn impact VFX
	_spawn_impact_vfx()

	# Hit feedback: screen shake + hitstop (mirrors melee feel)
	if _source and is_instance_valid(_source):
		_fire_hit_feedback()

	queue_free()


# --- Hitbox API stubs so HurtboxComponent can treat us as a hitbox ---

var is_active: bool = true
var damage_source: Node:
	get:
		return _source
var hit_targets: Array[Node] = []

func has_hit(target: Node) -> bool:
	return target in hit_targets

func register_hit(target: Node) -> void:
	hit_targets.append(target)

func activate() -> void:
	pass

func deactivate() -> void:
	pass


# --- VFX helpers ---

func _spawn_impact_vfx() -> void:
	if not is_inside_tree():
		return
	var scene_root: Node = get_tree().current_scene
	var pos: Vector3 = global_position

	# Flash sphere
	var flash: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	flash.mesh = sphere
	flash.position = pos
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b, 0.9)
	mat.emission_enabled = true
	mat.emission = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b)
	mat.emission_energy_multiplier = 5.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.material_override = mat
	scene_root.add_child(flash)
	var tween: Tween = flash.create_tween()
	tween.tween_property(flash, "scale", Vector3(2.0, 2.0, 2.0), 0.12)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.15)
	tween.tween_callback(flash.queue_free)

	# Sparks
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 10
	sparks.lifetime = 0.25
	sparks.one_shot = true
	sparks.emitting = true
	sparks.position = pos
	var spark_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spark_mat.direction = Vector3(0, 0.5, 0)
	spark_mat.spread = 180.0
	spark_mat.initial_velocity_min = 3.0
	spark_mat.initial_velocity_max = 6.0
	spark_mat.gravity = Vector3(0, -5, 0)
	spark_mat.color = LIGHTNING_COLOR
	spark_mat.scale_min = 0.2
	spark_mat.scale_max = 0.5
	sparks.process_material = spark_mat
	var spark_mesh: BoxMesh = BoxMesh.new()
	spark_mesh.size = Vector3(0.03, 0.03, 0.03)
	sparks.draw_pass_1 = spark_mesh
	var spark_vis: StandardMaterial3D = StandardMaterial3D.new()
	spark_vis.albedo_color = LIGHTNING_COLOR
	spark_vis.emission_enabled = true
	spark_vis.emission = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b)
	spark_vis.emission_energy_multiplier = 3.5
	spark_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sparks.material_override = spark_vis
	scene_root.add_child(sparks)
	get_tree().create_timer(0.5).timeout.connect(sparks.queue_free)


func _fizzle_and_free() -> void:
	## Small fade-out when the bolt reaches max range without hitting anything.
	if not is_inside_tree():
		queue_free()
		return
	# Tiny spark puff at endpoint
	var scene_root: Node = get_tree().current_scene
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 4
	sparks.lifetime = 0.15
	sparks.one_shot = true
	sparks.emitting = true
	sparks.position = global_position
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 0.3, 0)
	pmat.spread = 120.0
	pmat.initial_velocity_min = 1.0
	pmat.initial_velocity_max = 2.0
	pmat.gravity = Vector3(0, -3, 0)
	pmat.color = Color(LIGHTNING_COLOR.r, LIGHTNING_COLOR.g, LIGHTNING_COLOR.b, 0.4)
	pmat.scale_min = 0.1
	pmat.scale_max = 0.3
	sparks.process_material = pmat
	var spark_mesh: BoxMesh = BoxMesh.new()
	spark_mesh.size = Vector3(0.02, 0.02, 0.02)
	sparks.draw_pass_1 = spark_mesh
	scene_root.add_child(sparks)
	get_tree().create_timer(0.3).timeout.connect(sparks.queue_free)
	queue_free()


func _fire_hit_feedback() -> void:
	## Screen shake + hitstop on projectile hit, matching melee feel.
	var camera: Camera3D = _source.get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		var shake_bonus: float = [0.0, 0.02, 0.08][combo_step]
		camera.shake(0.07 + shake_bonus, 14.0)
	# Brief hitstop
	if _source.is_inside_tree():
		Engine.time_scale = 0.2
		_source.get_tree().create_timer(0.06, true, false, true).timeout.connect(func() -> void:
			Engine.time_scale = 1.0
		)
	# Finisher audio sting
	if combo_step == 2:
		AudioManager.play_sfx("combo_finisher")
