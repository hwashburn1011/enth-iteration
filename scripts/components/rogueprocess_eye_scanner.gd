class_name RogueProcessEyeScanner
extends Node3D

## Scanning eye-laser idle behavior for the RogueProcess (Epic 06 task 41).
## When the unit is in idle state, its primary optical sensors emit thin
## visible laser beams that sweep slowly across the room — the species's
## "I'm watching you" idle tell.
##
## Distinct from the actual ranged attack laser (which fires fast and hits
## the player). This is the SLOW SCANNING beam — it doesn't damage anything,
## it just communicates "this thing is actively surveilling the area."
##
## Behavior:
## 1) Two beam meshes anchored to the optical sensor bones (sensor.PR / PL)
## 2) Each beam is a thin cylinder pointing forward from its sensor
## 3) Each beam has a target world position that drifts slowly in a
##    figure-8 sweep pattern
## 4) The beam length raycasts to find the actual hit distance, so the
##    beam visibly stops at walls instead of clipping through
## 5) On state change to combat: beams snap off (the unit has switched
##    to actual targeting, not idle scanning)
##
## Required scene shape:
##   RogueProcessEyeScanner (Node3D + this script)
##     export armature_path → Skeleton3D with sensor.PR / sensor.PL bones
##     export sensor_bone_names → array of bone names (default 2)
##
## Inspector configuration:
##   sweep_period_s        — full figure-8 cycle duration (default 4.0)
##   sweep_radius_m        — how far the beams spread from straight-forward
##   beam_length_max_m     — max raycast length
##   beam_radius_m         — visual thickness of the beam cylinder
##   beam_color            — beam emission color (cyan default for idle)
##   active                — bool, drives visibility from gameplay state

@export var armature_path: NodePath
@export var sensor_bone_names: PackedStringArray = PackedStringArray(["sensor.PR", "sensor.PL"])
@export_range(0.5, 30.0) var sweep_period_s: float = 4.0
@export_range(0.1, 4.0) var sweep_radius_m: float = 0.8
@export_range(1.0, 30.0) var beam_length_max_m: float = 8.0
@export_range(0.005, 0.10) var beam_radius_m: float = 0.012
@export var beam_color: Color = Color(0.0, 0.95, 0.95)
@export_range(0.0, 12.0) var beam_emission: float = 4.0
@export var active: bool = true
@export_flags_3d_physics var raycast_collision_mask: int = 1

var _armature: Skeleton3D
var _sensor_bone_indices: Array[int] = []
var _beam_meshes: Array[MeshInstance3D] = []
var _beam_material: StandardMaterial3D
var _time_accum: float = 0.0


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
		push_warning("RogueProcessEyeScanner: no Skeleton3D found")
		return

	# Resolve sensor bone indices
	for bone_name: String in sensor_bone_names:
		var idx: int = _armature.find_bone(bone_name)
		if idx >= 0:
			_sensor_bone_indices.append(idx)

	_build_beams()


func _build_beams() -> void:
	# Build the shared beam material
	_beam_material = StandardMaterial3D.new()
	_beam_material.albedo_color = Color(beam_color.r, beam_color.g, beam_color.b, 0.85)
	_beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_beam_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_beam_material.emission_enabled = true
	_beam_material.emission = beam_color
	_beam_material.emission_energy_multiplier = beam_emission
	_beam_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	# One MeshInstance3D per sensor bone
	for _idx: int in _sensor_bone_indices.size():
		var beam: MeshInstance3D = MeshInstance3D.new()
		beam.name = "EyeBeam_%d" % _idx
		var cyl: CylinderMesh = CylinderMesh.new()
		cyl.top_radius = beam_radius_m
		cyl.bottom_radius = beam_radius_m
		cyl.height = beam_length_max_m
		cyl.radial_segments = 8
		beam.mesh = cyl
		beam.material_override = _beam_material
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(beam)
		_beam_meshes.append(beam)


func _process(delta: float) -> void:
	if not active or _armature == null or _beam_meshes.is_empty():
		# Hide beams when inactive
		for b: MeshInstance3D in _beam_meshes:
			b.visible = false
		return

	_time_accum += delta
	# Figure-8 sweep parameters from TIME (Lissajous curve with 2:1 frequency
	# ratio gives a horizontal figure-8)
	var t: float = _time_accum * TAU / sweep_period_s
	var sweep_x: float = sin(t) * sweep_radius_m
	var sweep_y: float = sin(t * 2.0) * sweep_radius_m * 0.4  # narrower vertical

	# Update each beam's transform from its sensor bone
	for i: int in _beam_meshes.size():
		var bone_idx: int = _sensor_bone_indices[i]
		var beam: MeshInstance3D = _beam_meshes[i]
		beam.visible = true

		# Sensor world position
		var sensor_pose: Transform3D = _armature.get_bone_global_pose(bone_idx)
		var sensor_world: Vector3 = _armature.global_transform * sensor_pose.origin

		# Beam direction: parent's forward + sweep offset
		var parent: Node3D = _armature.get_parent() as Node3D
		var forward: Vector3 = -parent.global_transform.basis.z if parent != null else Vector3(0, 0, -1)
		var right: Vector3 = parent.global_transform.basis.x if parent != null else Vector3(1, 0, 0)
		var up: Vector3 = parent.global_transform.basis.y if parent != null else Vector3(0, 1, 0)
		# Each sensor sweeps with a phase offset so the two beams cross paths
		var per_sensor_phase: float = float(i) * PI
		var sweep_offset: Vector3 = right * (sweep_x + sin(t + per_sensor_phase) * 0.2) + up * sweep_y
		var beam_dir: Vector3 = (forward + sweep_offset.normalized() * 0.2).normalized()

		# Raycast to find the actual hit point (so the beam stops at walls)
		var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var beam_length: float = beam_length_max_m
		if space != null:
			var ray_start: Vector3 = sensor_world + beam_dir * 0.05
			var ray_end: Vector3 = sensor_world + beam_dir * beam_length_max_m
			var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
				ray_start, ray_end, raycast_collision_mask
			)
			# Exclude the parent rogueprocess body from the raycast
			if parent is CollisionObject3D:
				query.exclude = [(parent as CollisionObject3D).get_rid()]
			var result: Dictionary = space.intersect_ray(query)
			if not result.is_empty():
				var hit_pos: Vector3 = result.get("position", ray_end)
				beam_length = sensor_world.distance_to(hit_pos)

		# Position beam at the midpoint between the sensor and the hit
		var midpoint: Vector3 = sensor_world + beam_dir * (beam_length * 0.5)
		beam.global_position = midpoint

		# Update beam length by setting the cylinder mesh height directly
		(beam.mesh as CylinderMesh).height = max(0.05, beam_length)

		# Orient the beam along the direction
		# CylinderMesh defaults to +Y axis, so we need to rotate +Y to beam_dir
		if absf(beam_dir.dot(Vector3.UP)) < 0.999:
			beam.look_at(sensor_world + beam_dir * (beam_length + 1.0), Vector3.UP)
			# look_at points -Z; rotate so cylinder Y aligns with -Z
			beam.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))


func set_active(value: bool) -> void:
	active = value
	if not value:
		for b: MeshInstance3D in _beam_meshes:
			b.visible = false
