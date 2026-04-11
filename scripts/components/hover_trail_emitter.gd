class_name HoverTrailEmitter
extends Node3D

## Hover trail particle emitter for the RogueProcess (Epic 06 task 27).
## Drops a continuous warm-glow trail beneath the floating body — sparks
## and pinpoint embers that fall under gravity and fade out, leaving a
## visible "wake" beneath the unit.
##
## Distinct from BubblingFoamEmitter (rising bubbles from a sphere
## volume) and HitSplatEmitter (one-shot directional bursts on damage):
## this one is a CONTINUOUS DOWNWARD trail with gravity that responds
## to the parent's hover bob.
##
## When the parent moves, the trail naturally lags behind because the
## particles are emitted in world space — this creates the visible "wake"
## as the unit strafes or dashes.
##
## Required scene shape:
##   HoverTrailEmitter (Node3D + this script)
##     [GPUParticles3D added at runtime]
##
## Inspector configuration:
##   particle_count       — total system particle count
##   emit_radius_m        — sphere of randomized spawn positions under thruster
##   emission_rate_per_s  — continuous spawn rate
##   particle_lifetime_s  — how long each ember persists
##   trail_color          — base ember color (warm orange/yellow default)
##   gravity_strength     — downward acceleration (positive = down)
##   pause_when_dead      — auto-stop on parent died

@export_range(8, 256) var particle_count: int = 96
@export_range(0.05, 1.0) var emit_radius_m: float = 0.15
@export_range(0.0, 64.0) var emission_rate_per_s: float = 32.0
@export_range(0.3, 4.0) var particle_lifetime_s: float = 1.2
@export var trail_color: Color = Color(1.0, 0.55, 0.10, 0.85)
@export_range(0.0, 16.0) var gravity_strength: float = 3.5
@export_range(0.02, 0.5) var ember_size_m: float = 0.06
@export var pause_when_dead: bool = true
@export var health_component_path: NodePath

var _particles: GPUParticles3D
var _process_material: ParticleProcessMaterial
var _draw_material: StandardMaterial3D
var _ember_mesh: SphereMesh


func _ready() -> void:
	_build_particles()

	if pause_when_dead:
		var hc: Node = get_node_or_null(health_component_path)
		if hc == null:
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
	_particles.name = "HoverTrailParticles"
	_particles.amount = particle_count
	_particles.lifetime = particle_lifetime_s
	_particles.one_shot = false
	_particles.preprocess = particle_lifetime_s * 0.5
	_particles.local_coords = false  # particles drift in world space, lag the parent
	_particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH

	# Process material — controls spawning, gravity, motion
	_process_material = ParticleProcessMaterial.new()
	_process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_process_material.emission_sphere_radius = emit_radius_m

	# Direction: slightly downward + small lateral spread
	_process_material.direction = Vector3(0, -1, 0)
	_process_material.spread = 18.0
	_process_material.flatness = 0.0
	_process_material.initial_velocity_min = 0.4
	_process_material.initial_velocity_max = 1.2

	# Gravity pulls embers down faster than initial velocity
	_process_material.gravity = Vector3(0, -gravity_strength, 0)
	_process_material.linear_accel_min = 0.0
	_process_material.linear_accel_max = 0.3

	# Tiny random tumble
	_process_material.angular_velocity_min = -90.0
	_process_material.angular_velocity_max = 90.0

	# Scale curve: ember starts at full size, shrinks to nothing as it falls
	_process_material.scale_min = 0.6
	_process_material.scale_max = 1.4
	_process_material.scale_curve = _build_scale_curve()

	# Color ramp: bright at spawn, fades through warm color to transparent
	_process_material.color = trail_color
	_process_material.color_ramp = _build_color_ramp()

	_particles.process_material = _process_material

	# Adjust amount so steady state matches the requested rate
	if emission_rate_per_s > 0.0:
		var target_amount: int = int(ceilf(emission_rate_per_s * particle_lifetime_s))
		_particles.amount = max(8, target_amount)

	# Ember mesh — small sphere
	_ember_mesh = SphereMesh.new()
	_ember_mesh.radius = ember_size_m * 0.5
	_ember_mesh.height = ember_size_m
	_ember_mesh.radial_segments = 6
	_ember_mesh.rings = 3

	# Material — unshaded emissive translucent
	_draw_material = StandardMaterial3D.new()
	_draw_material.albedo_color = trail_color
	_draw_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_draw_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_draw_material.emission_enabled = true
	_draw_material.emission = trail_color
	_draw_material.emission_energy_multiplier = 2.0
	_draw_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_ember_mesh.material = _draw_material

	_particles.draw_pass_1 = _ember_mesh

	add_child(_particles)


func _build_scale_curve() -> CurveTexture:
	var curve: Curve = Curve.new()
	curve.add_point(Vector2(0.0, 1.0))    # full size at spawn
	curve.add_point(Vector2(0.4, 0.85))
	curve.add_point(Vector2(1.0, 0.0))    # vanish at end
	var ct: CurveTexture = CurveTexture.new()
	ct.curve = curve
	return ct


func _build_color_ramp() -> GradientTexture1D:
	var grad: Gradient = Gradient.new()
	# Bright at spawn (the warm thruster color)
	grad.set_color(0, Color(trail_color.r, trail_color.g, trail_color.b, trail_color.a))
	# Fade to a darker red-brown at end
	grad.set_color(1, Color(trail_color.r * 0.4, trail_color.g * 0.2, trail_color.b * 0.05, 0.0))
	var gt: GradientTexture1D = GradientTexture1D.new()
	gt.gradient = grad
	return gt


func set_emitting(active: bool) -> void:
	if _particles != null:
		_particles.emitting = active


func _on_died() -> void:
	if pause_when_dead and _particles != null:
		# Stop emission but let existing particles finish their lifetime
		_particles.emitting = false
