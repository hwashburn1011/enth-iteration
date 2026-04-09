class_name HitSplatEmitter
extends Node3D

## On-hit splat particle burst for slime/blob enemies. Listens for the
## parent's HealthComponent damage_taken signal and fires a one-shot
## directional spray of viscous droplets in the opposite direction of
## the hit (so the splat sprays AWAY from the source of damage).
##
## Distinct from BubblingFoamEmitter (continuous ambient bubbles): this
## one is a single burst per hit. The two coexist on the same enemy.
##
## Direction inference: prefers the `damage_direction` payload if the
## health component emits one, otherwise falls back to the camera
## forward vector at the moment of the hit.
##
## Required scene shape:
##   HitSplatEmitter (Node3D + this script)
##     [GPUParticles3D added at runtime]
##
## Inspector configuration:
##   splat_count          — particles per burst (default 18)
##   splat_color          — droplet color (default sickly green)
##   splat_speed_min/max  — initial velocity range
##   splat_lifetime_s     — how long droplets persist
##   gravity_strength     — drop arc gravity (default 4.0)
##   health_component_path — overrides auto-find

@export_range(4, 64) var splat_count: int = 18
@export var splat_color: Color = Color(0.20, 0.80, 0.30, 0.90)
@export_range(1.0, 12.0) var splat_speed_min: float = 3.0
@export_range(1.0, 12.0) var splat_speed_max: float = 6.0
@export_range(0.3, 4.0) var splat_lifetime_s: float = 0.9
@export_range(0.0, 20.0) var gravity_strength: float = 4.0
@export_range(0.05, 1.0) var droplet_size_m: float = 0.08
@export var health_component_path: NodePath

var _particles: GPUParticles3D
var _process_material: ParticleProcessMaterial
var _draw_material: StandardMaterial3D
var _droplet_mesh: SphereMesh


func _ready() -> void:
	_build_particles()

	var hc: Node = get_node_or_null(health_component_path)
	if hc == null:
		var parent: Node = get_parent()
		if parent != null:
			for child: Node in parent.get_children():
				if child.has_signal("damage_taken"):
					hc = child
					break
	if hc != null:
		# Try the typed signature first (with Vector3 hit_origin if the project
		# emits one). Fall back to the bare amount-only signature.
		if hc.has_signal("damage_taken"):
			hc.damage_taken.connect(_on_damage_taken)


func _build_particles() -> void:
	_particles = GPUParticles3D.new()
	_particles.name = "SplatParticles"
	_particles.amount = splat_count
	_particles.lifetime = splat_lifetime_s
	_particles.one_shot = true
	_particles.explosiveness = 1.0  # all particles spawn instantly on burst
	_particles.local_coords = false
	_particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH
	_particles.emitting = false  # only fire on hit

	_process_material = ParticleProcessMaterial.new()
	_process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	# Default direction +Y; we'll override per-burst by setting direction
	# directly on the process material before triggering emission
	_process_material.direction = Vector3(0, 1, 0)
	_process_material.spread = 35.0  # wide cone splay so the splat looks scattered
	_process_material.flatness = 0.0
	_process_material.initial_velocity_min = splat_speed_min
	_process_material.initial_velocity_max = splat_speed_max
	_process_material.gravity = Vector3(0, -gravity_strength, 0)
	_process_material.angular_velocity_min = -180.0
	_process_material.angular_velocity_max = 180.0

	_process_material.scale_min = 0.6
	_process_material.scale_max = 1.4
	_process_material.scale_curve = _build_scale_curve()
	_process_material.color = splat_color
	_process_material.color_ramp = _build_color_ramp()

	_particles.process_material = _process_material

	_droplet_mesh = SphereMesh.new()
	_droplet_mesh.radius = droplet_size_m * 0.5
	_droplet_mesh.height = droplet_size_m
	_droplet_mesh.radial_segments = 6
	_droplet_mesh.rings = 3

	_draw_material = StandardMaterial3D.new()
	_draw_material.albedo_color = splat_color
	_draw_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_draw_material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_draw_material.emission_enabled = true
	_draw_material.emission = splat_color
	_draw_material.emission_energy_multiplier = 0.6
	_draw_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_droplet_mesh.material = _draw_material

	_particles.draw_pass_1 = _droplet_mesh

	add_child(_particles)


func _build_scale_curve() -> CurveTexture:
	var curve: Curve = Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(0.6, 0.85))
	curve.add_point(Vector2(1.0, 0.0))   # vanish at end
	var ct: CurveTexture = CurveTexture.new()
	ct.curve = curve
	return ct


func _build_color_ramp() -> GradientTexture1D:
	var grad: Gradient = Gradient.new()
	grad.set_color(0, splat_color)
	grad.set_color(1, Color(splat_color.r * 0.6, splat_color.g * 0.6, splat_color.b * 0.6, 0.0))
	var gt: GradientTexture1D = GradientTexture1D.new()
	gt.gradient = grad
	return gt


# === Event handlers + Public API ===

func _on_damage_taken(_amount: float = 0.0) -> void:
	# Default direction: upward + away from camera if available, else just up
	var direction: Vector3 = _infer_default_direction()
	burst(direction)


func burst(direction: Vector3) -> void:
	## Fire a one-shot directional splat burst. The direction vector
	## defines the cone center axis — particles spread in a 35° cone
	## around it.
	if _particles == null or _process_material == null:
		return
	# Update the cone direction in the process material
	_process_material.direction = direction.normalized()
	# Restart the one-shot
	_particles.restart()
	_particles.emitting = true


func _infer_default_direction() -> Vector3:
	# Prefer to spray AWAY from the player camera so the splat reads as
	# coming "out of" the enemy toward the screen
	var cam: Camera3D = get_viewport().get_camera_3d() if is_inside_tree() else null
	if cam != null:
		var to_cam: Vector3 = (cam.global_position - global_position).normalized()
		# Bias upward so droplets arc visibly
		return (to_cam + Vector3(0, 0.6, 0)).normalized()
	return Vector3(0, 1, 0)
