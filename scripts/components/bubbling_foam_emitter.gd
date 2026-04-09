class_name BubblingFoamEmitter
extends Node3D

## Continuous bubbling foam particle emitter for the MemoryLeak (and any
## "boiling" enemy or environmental hazard). Builds a GPUParticles3D node
## at runtime with a tuned ParticleProcessMaterial — small clear bubbles
## drifting upward from the body surface, popping at the top.
##
## The particles are EMITTED FROM A SHAPE (sphere by default) so they
## come from inside the body's volume rather than a single point. This
## sells the "boiling from within" feeling rather than "thing on top of
## a stick is bubbling."
##
## Two emit modes:
##   - Continuous (default): bubbles emit at a steady rate while the
##     parent is alive, used for the MemoryLeak ambient idle
##   - Triggered: emit a burst on demand via burst(count), used for
##     "boiling intensifies" beats — pairs with the Aggro Extend pose
##     and the spit windup
##
## Required scene shape:
##   BubblingFoamEmitter (Node3D + this script)
##     [GPUParticles3D added at runtime]
##
## Inspector configuration:
##   emit_radius_m       — sphere emit radius (volume the bubbles spawn in)
##   bubble_count        — total particle count for the system
##   emit_rate_per_s     — continuous emission rate (0 = no continuous)
##   bubble_lifetime_s   — how long each bubble lives
##   bubble_color        — base color (default light cyan-green)
##   rise_speed_m_s      — vertical velocity per bubble
##   amount_visible_s    — system lifetime per cycle (loops)
##   pause_when_dead     — auto-stop when parent dies (default true)

@export_range(0.05, 4.0) var emit_radius_m: float = 0.55
@export_range(8, 256) var bubble_count: int = 64
@export_range(0.0, 64.0) var emit_rate_per_s: float = 12.0
@export_range(0.5, 6.0) var bubble_lifetime_s: float = 1.8
@export var bubble_color: Color = Color(0.65, 0.95, 0.80, 0.75)
@export_range(0.1, 4.0) var rise_speed_m_s: float = 0.55
@export var pause_when_dead: bool = true
@export var health_component_path: NodePath

var _particles: GPUParticles3D
var _process_material: ParticleProcessMaterial
var _draw_material: StandardMaterial3D
var _bubble_mesh: SphereMesh


func _ready() -> void:
	_build_particles()

	if pause_when_dead:
		var hc: Node = get_node_or_null(health_component_path)
		if hc == null:
			# Auto-find: any sibling of the parent with a died signal
			var parent: Node = get_parent()
			if parent != null:
				for child: Node in parent.get_children():
					if child.has_signal("died"):
						hc = child
						break
		if hc != null and hc.has_signal("died"):
			hc.died.connect(_on_died)


func _build_particles() -> void:
	_particles = GPUParticles3D.new()
	_particles.name = "FoamParticles"
	_particles.amount = bubble_count
	_particles.lifetime = bubble_lifetime_s
	_particles.one_shot = false
	_particles.preprocess = bubble_lifetime_s * 0.5  # warm up so the system isn't empty on spawn
	_particles.local_coords = false  # bubbles inherit position once emitted then drift independently
	_particles.fixed_fps = 0
	_particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH

	# Process material — controls the spawning, motion, and per-particle behavior
	_process_material = ParticleProcessMaterial.new()
	_process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_process_material.emission_sphere_radius = emit_radius_m

	# Direction + spread — bubbles drift mostly straight up with small lateral wobble
	_process_material.direction = Vector3(0, 1, 0)
	_process_material.spread = 12.0  # degrees of cone spread
	_process_material.flatness = 0.0
	_process_material.initial_velocity_min = rise_speed_m_s * 0.7
	_process_material.initial_velocity_max = rise_speed_m_s * 1.3

	# Drift / wobble — small horizontal noise
	_process_material.gravity = Vector3(0, 0.0, 0)  # buoyant — counter-gravity
	_process_material.linear_accel_min = 0.0
	_process_material.linear_accel_max = 0.2
	_process_material.tangential_accel_min = -0.4
	_process_material.tangential_accel_max = 0.4

	# Lifetime fade — bubbles shrink + fade as they rise
	_process_material.scale_min = 0.4
	_process_material.scale_max = 0.9
	_process_material.scale_curve = _build_scale_curve()

	# Color: solid bubble color with alpha curve fading at end
	_process_material.color = bubble_color
	_process_material.color_ramp = _build_alpha_ramp()

	_particles.process_material = _process_material

	# Draw mesh: small sphere
	_bubble_mesh = SphereMesh.new()
	_bubble_mesh.radius = 0.04
	_bubble_mesh.height = 0.08
	_bubble_mesh.radial_segments = 8
	_bubble_mesh.rings = 4
	_particles.draw_pass_1 = _bubble_mesh

	# Bubble material: translucent emissive
	_draw_material = StandardMaterial3D.new()
	_draw_material.albedo_color = bubble_color
	_draw_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_draw_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_draw_material.emission_enabled = true
	_draw_material.emission = bubble_color
	_draw_material.emission_energy_multiplier = 1.4
	_draw_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_bubble_mesh.material = _draw_material

	# Wire emission rate via amount + lifetime so steady state matches request
	# rate ≈ amount / lifetime when continuous; bias amount accordingly
	if emit_rate_per_s > 0.0:
		var target_amount: int = int(ceilf(emit_rate_per_s * bubble_lifetime_s))
		_particles.amount = max(8, target_amount)

	add_child(_particles)


func _build_scale_curve() -> CurveTexture:
	var curve: Curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.3))   # small at spawn
	curve.add_point(Vector2(0.3, 1.0))   # full size in the middle
	curve.add_point(Vector2(0.85, 0.9))
	curve.add_point(Vector2(1.0, 0.0))   # pop at end
	var ct: CurveTexture = CurveTexture.new()
	ct.curve = curve
	return ct


func _build_alpha_ramp() -> GradientTexture1D:
	var grad: Gradient = Gradient.new()
	grad.set_color(0, Color(bubble_color.r, bubble_color.g, bubble_color.b, 0.0))
	grad.set_color(1, Color(bubble_color.r, bubble_color.g, bubble_color.b, 0.0))
	grad.add_point(0.05, Color(bubble_color.r, bubble_color.g, bubble_color.b, bubble_color.a))
	grad.add_point(0.75, Color(bubble_color.r, bubble_color.g, bubble_color.b, bubble_color.a))
	var gt: GradientTexture1D = GradientTexture1D.new()
	gt.gradient = grad
	return gt


# === Public API ===

func burst(count: int = 24) -> void:
	## One-shot burst of bubbles, used for "boiling intensifies" beats.
	if _particles == null:
		return
	# Temporarily increase amount for the burst, then restore
	# (GPUParticles3D doesn't have a direct one-shot burst; emit_particle is the
	# closest). Use emit_particle to spawn N particles immediately at random
	# positions inside the emit sphere.
	for _i: int in count:
		var offset: Vector3 = Vector3(
			randf_range(-emit_radius_m, emit_radius_m),
			randf_range(-emit_radius_m * 0.3, emit_radius_m * 0.3),
			randf_range(-emit_radius_m, emit_radius_m),
		)
		var velocity: Vector3 = Vector3(
			randf_range(-0.2, 0.2),
			rise_speed_m_s * randf_range(1.2, 1.8),
			randf_range(-0.2, 0.2),
		)
		var xform: Transform3D = Transform3D(Basis(), offset)
		_particles.emit_particle(
			xform,
			velocity,
			bubble_color,
			Color(1, 1, 1, 1),
			GPUParticles3D.EMIT_FLAG_POSITION | GPUParticles3D.EMIT_FLAG_VELOCITY | GPUParticles3D.EMIT_FLAG_COLOR,
		)


func set_emitting(active: bool) -> void:
	if _particles != null:
		_particles.emitting = active


func _on_died() -> void:
	if pause_when_dead and _particles != null:
		_particles.emitting = false
