class_name FoliageScatterSystem
extends Node3D

## Foliage scatter system (Epic 13 tasks 21, 22, 40).
## Procedurally scatters grass/flower/bush instances across a designated
## area using MultiMeshInstance3D for efficient batched rendering. Tuned
## to handle 10K+ instances without perf impact.
##
## Used by:
##   - Town district zones to scatter grass under building feet
##   - Wilderness zones to fill open areas
##   - Any area marker requiring procedural foliage filling
##
## Required scene shape:
##   FoliageScatterSystem (Node3D + this script)
##     export source_meshes: Array[Mesh] — base meshes to scatter from
##     export area_size: Vector2 — width × depth of the scatter area
##     export instance_count: int — how many instances to spawn
##     export density_per_m2: float — alternative to instance_count
##     export random_seed: int

@export var source_meshes: Array[Mesh] = []
@export var area_size: Vector2 = Vector2(20.0, 20.0)
@export var instance_count: int = 1000
@export var density_per_m2: float = 0.0
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
@export var random_y_rotation: bool = true
@export var avoid_radius_m: float = 0.0
@export var avoidance_targets: Array[NodePath] = []
@export var random_seed: int = 13

var _multimesh_instances: Array[MultiMeshInstance3D] = []


func _ready() -> void:
	scatter()


func scatter() -> void:
	# Clear previous instances
	for mmi in _multimesh_instances:
		if is_instance_valid(mmi):
			mmi.queue_free()
	_multimesh_instances.clear()

	if source_meshes.is_empty():
		push_warning("FoliageScatterSystem: no source meshes assigned")
		return

	# Calculate target instance count
	var target_count: int = instance_count
	if density_per_m2 > 0.0:
		target_count = int(area_size.x * area_size.y * density_per_m2)

	# Resolve avoidance positions (e.g. building footprints)
	var avoidance_positions: Array[Vector3] = []
	for path in avoidance_targets:
		var node: Node3D = get_node_or_null(path) as Node3D
		if node != null:
			avoidance_positions.append(node.global_position)

	# Build one MultiMeshInstance3D per source mesh
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = random_seed
	var instances_per_mesh: int = target_count / max(1, source_meshes.size())

	for src_mesh in source_meshes:
		var mmi: MultiMeshInstance3D = MultiMeshInstance3D.new()
		var mm: MultiMesh = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_colors = false
		mm.use_custom_data = false
		mm.mesh = src_mesh
		mm.instance_count = instances_per_mesh
		mmi.multimesh = mm
		add_child(mmi)
		_multimesh_instances.append(mmi)

		var placed: int = 0
		var attempts: int = 0
		while placed < instances_per_mesh and attempts < instances_per_mesh * 4:
			attempts += 1
			var x: float = rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
			var z: float = rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)
			var pos: Vector3 = global_position + Vector3(x, 0, z)

			# Avoidance check
			if avoid_radius_m > 0.0:
				var blocked: bool = false
				for ap in avoidance_positions:
					if pos.distance_to(ap) < avoid_radius_m:
						blocked = true
						break
				if blocked:
					continue

			var scale_factor: float = rng.randf_range(min_scale, max_scale)
			var yaw: float = rng.randf() * TAU if random_y_rotation else 0.0
			var basis: Basis = Basis()
			basis = basis.rotated(Vector3.UP, yaw)
			basis = basis.scaled(Vector3(scale_factor, scale_factor, scale_factor))
			var t: Transform3D = Transform3D(basis, pos - global_position)
			mm.set_instance_transform(placed, t)
			placed += 1
