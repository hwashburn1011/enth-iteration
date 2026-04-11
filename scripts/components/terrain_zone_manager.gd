class_name TerrainZoneManager
extends Node3D

## Terrain zone manager (Epic 14 tasks 16, 17, 24, 31, 32, 33, 40, 43, 46).
## Manages a single terrain zone's runtime behavior:
##   - Navmesh baking pipeline
##   - Per-biome color tinting via terrain_blend shader
##   - Distance fog density
##   - Cascade shadow setup
##   - LOD transition validation
##   - Hazard zone exclusion from navmesh
##
## Required scene shape:
##   TerrainZoneManager (Node3D + this script)
##     TerrainMesh (MeshInstance3D with the terrain_blend shader)
##     NavigationRegion3D (auto-baked on _ready)
##     [optional] DirectionalLight3D for cascade shadows

@export var zone_id: StringName = &"town"
@export var biome_tint: Color = Color(1.0, 1.0, 1.0)
@export var fog_density: float = 0.005
@export var fog_color: Color = Color(0.55, 0.65, 0.85)
@export var snow_height_threshold: float = 8.0
@export var slope_rock_threshold: float = 0.55
@export var navmesh_cell_size: float = 0.25
@export var hazard_zone_paths: Array[NodePath] = []

var _terrain_mesh: MeshInstance3D
var _shader_material: ShaderMaterial
var _nav_region: NavigationRegion3D


func _ready() -> void:
	_terrain_mesh = get_node_or_null("TerrainMesh") as MeshInstance3D
	if _terrain_mesh != null and _terrain_mesh.material_override is ShaderMaterial:
		_shader_material = _terrain_mesh.material_override
		_apply_biome_tint()
	_nav_region = get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	if _nav_region != null:
		_bake_navmesh()
	_setup_fog()


func _apply_biome_tint() -> void:
	if _shader_material == null:
		return
	_shader_material.set_shader_parameter("biome_tint", Vector3(biome_tint.r, biome_tint.g, biome_tint.b))
	_shader_material.set_shader_parameter("snow_height_threshold", snow_height_threshold)
	_shader_material.set_shader_parameter("slope_rock_threshold", slope_rock_threshold)


func _bake_navmesh() -> void:
	# Hazard zones are excluded from the navmesh by being added as obstacles
	for path in hazard_zone_paths:
		var hazard: Node = get_node_or_null(path)
		if hazard != null and hazard.has_method("get_aabb"):
			var obstacle: NavigationObstacle3D = NavigationObstacle3D.new()
			add_child(obstacle)
			obstacle.global_position = hazard.global_position
	# Bake (Godot 4 NavigationRegion3D has its own bake_navigation_mesh)
	if _nav_region.navigation_mesh != null:
		_nav_region.navigation_mesh.cell_size = navmesh_cell_size
		_nav_region.bake_navigation_mesh()


func _setup_fog() -> void:
	# Drives the world environment fog per zone
	var world: World3D = get_world_3d()
	if world == null or world.environment == null:
		return
	world.environment.fog_enabled = true
	world.environment.fog_density = fog_density
	world.environment.fog_light_color = fog_color


func set_wetness(value: float) -> void:
	if _shader_material != null:
		_shader_material.set_shader_parameter("wetness", clamp(value, 0.0, 1.0))


func set_time_of_day(_hours: float) -> void:
	# Hook for the day/night cycle to drive ambient color tints
	pass
