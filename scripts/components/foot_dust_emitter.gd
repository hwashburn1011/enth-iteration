class_name FootDustEmitter
extends Node3D

## Spawns small one-shot dust particle bursts at each leg's foot bone
## position whenever that bone lands. Pairs with FootContactDecalEmitter
## (Epic 04 task 34) — together they form the "the bug walked here"
## visual feedback: decal stamps on the ground + dust puffs in the air.
##
## Distinct from HoverTrailEmitter (continuous trail under flying enemies)
## and HitSplatEmitter (one-shot directional bursts on damage).
##
## Uses the same landing detection as FootContactDecalEmitter (bone Y
## drop threshold + ground proximity check) so the two stay in sync —
## every footstep produces both a decal AND a dust puff.
##
## Implementation: builds ONE pooled GPUParticles3D node that gets its
## emit_particle() called on demand for each footstep, rather than
## instantiating new emitters. Cheaper than per-foot emitters.
##
## Required scene shape:
##   FootDustEmitter (Node3D + this script)
##     [GPUParticles3D added at runtime]
##     export armature_path → Skeleton3D
##
## Inspector configuration:
##   foot_bone_names      — array of bone names whose landings trigger dust
##   particles_per_step   — particles emitted per footstep burst
##   landing_threshold_m  — bone Y drop required to count as landing
##   ground_proximity_m   — bone Y must be below this to register
##   dust_color           — base color (default light dust gray)
##   particle_lifetime_s  — how long each dust particle persists
##   max_particles        — total particle pool size

@export var armature_path: NodePath
@export var foot_bone_names: PackedStringArray = PackedStringArray([
	"leg_FR_lower", "leg_FL_lower",
	"leg_MR_lower", "leg_ML_lower",
	"leg_RR_lower", "leg_RL_lower",
])
@export_range(2, 16) var particles_per_step: int = 5
@export_range(0.001, 0.1) var landing_threshold_m: float = 0.005
@export_range(0.0, 1.0) var ground_proximity_m: float = 0.05
@export var dust_color: Color = Color(0.65, 0.60, 0.55, 0.7)
@export_range(0.2, 4.0) var particle_lifetime_s: float = 0.8
@export_range(16, 512) var max_particles: int = 96
@export_range(0.05, 0.4) var dust_size_m: float = 0.08
@export var stop_when_dead: bool = true
@export var health_component_path: NodePath

var _armature: Skeleton3D
var _foot_bone_indices: Array[int] = []
var _last_foot_world_y: Array[float] = []
var _particles: GPUParticles3D
var _process_material: ParticleProcessMaterial
var _draw_material: StandardMaterial3D
var _enabled: bool = true


func _ready() -> void:
	_armature = get_node_or_null(armature_path) as Skeleton3D
	if _armature == null:
		var parent: Node = get_parent()
		var stack: Array[Node] = [parent]
		while stack.size() > 0:
			var node: Node = stack.pop_back()
			if node is Skeleton3D:
				_armature = node
				break
			for child: Node in node.get_children():
				stack.append(child)

	if _armature == null:
		push_warning("FootDustEmitter: no Skeleton3D found")
		return

	for bone_name: String in foot_bone_names:
		var idx: int = _armature.find_bone(bone_name)
		if idx >= 0:
			_foot_bone_indices.append(idx)
			_last_foot_world_y.append(_get_foot_world_pos(idx).y)

	_build_particles()

	if stop_when_dead:
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
	_particles.name = "FootDustParticles"
	_particles.amount = max_particles
	_particles.lifetime = particle_lifetime_s
	_particles.one_shot = false
	_particles.emitting = false  # we manually emit_particle() per footstep
	_particles.local_coords = false  # particles drift in world space
	_particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH

	_process_material = ParticleProcessMaterial.new()
	_process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	_process_material.direction = Vector3(0, 1, 0)
	_process_material.spread = 30.0
	_process_material.initial_velocity_min = 0.5
	_process_material.initial_velocity_max = 1.2
	_process_material.gravity = Vector3(0, -1.5, 0)
	_process_material.scale_min = 0.6
	_process_material.scale_max = 1.4
	_process_material.scale_curve = _build_scale_curve()
	_process_material.color = dust_color
	_process_material.color_ramp = _build_color_ramp()
	_particles.process_material = _process_material

	var dust_mesh: SphereMesh = SphereMesh.new()
	dust_mesh.radius = dust_size_m * 0.5
	dust_mesh.height = dust_size_m
	dust_mesh.radial_segments = 6
	dust_mesh.rings = 3

	_draw_material = StandardMaterial3D.new()
	_draw_material.albedo_color = dust_color
	_draw_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_draw_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_draw_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	dust_mesh.material = _draw_material
	_particles.draw_pass_1 = dust_mesh
	# Reparent the particles to the world so they keep playing when the
	# enemy moves away (similar to the foot decals)
	get_tree().current_scene.call_deferred("add_child", _particles) if get_tree() else null
	# Fallback parenting in case current_scene is null at this moment
	if _particles.get_parent() == null:
		add_child(_particles)


func _build_scale_curve() -> CurveTexture:
	var curve: Curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.5))
	curve.add_point(Vector2(0.4, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	var ct: CurveTexture = CurveTexture.new()
	ct.curve = curve
	return ct


func _build_color_ramp() -> GradientTexture1D:
	var grad: Gradient = Gradient.new()
	grad.set_color(0, dust_color)
	grad.set_color(1, Color(dust_color.r, dust_color.g, dust_color.b, 0.0))
	var gt: GradientTexture1D = GradientTexture1D.new()
	gt.gradient = grad
	return gt


func _physics_process(_delta: float) -> void:
	if not _enabled or _armature == null or _particles == null:
		return

	for i: int in _foot_bone_indices.size():
		var bone_idx: int = _foot_bone_indices[i]
		var pos: Vector3 = _get_foot_world_pos(bone_idx)
		var dy: float = _last_foot_world_y[i] - pos.y
		if dy >= landing_threshold_m and pos.y <= ground_proximity_m:
			_emit_dust_burst(pos)
		_last_foot_world_y[i] = pos.y


func _get_foot_world_pos(bone_idx: int) -> Vector3:
	var bone_pose: Transform3D = _armature.get_bone_global_pose(bone_idx)
	return _armature.global_transform * bone_pose.origin


func _emit_dust_burst(world_pos: Vector3) -> void:
	for _i: int in particles_per_step:
		var velocity: Vector3 = Vector3(
			randf_range(-0.4, 0.4),
			randf_range(0.5, 1.2),
			randf_range(-0.4, 0.4),
		)
		var xform: Transform3D = Transform3D(Basis(), Vector3(world_pos.x, world_pos.y + 0.02, world_pos.z))
		_particles.emit_particle(
			xform,
			velocity,
			dust_color,
			Color(1, 1, 1, 1),
			GPUParticles3D.EMIT_FLAG_POSITION | GPUParticles3D.EMIT_FLAG_VELOCITY | GPUParticles3D.EMIT_FLAG_COLOR,
		)


func _on_died() -> void:
	_enabled = false
