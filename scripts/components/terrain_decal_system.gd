class_name TerrainDecalSystem
extends Node3D

## Terrain decal system (Epic 14 tasks 13, 18, 19, 20, 27, 38).
## Spawns ground decals for blood splatters, scorch marks, footprints,
## water-edge decals, path-blending decals, cave entrance transitions,
## and erosion-style detail. Pooled per type for perf.
##
## Used by:
##   - Combat system: blood splatters on enemy hits, scorch marks on
##     boss attacks, dust trails on player movement
##   - Town terrain: path-blending decals where stone meets grass
##   - Wilderness: water-edge decals along shorelines
##   - Dungeon biomes: cave entrance transition decals
##
## Required scene shape:
##   TerrainDecalSystem (Node3D + this script)
##     [decals spawned dynamically per spawn_decal call]

enum DecalType {
	BLOOD_SPLATTER,
	SCORCH_MARK,
	FOOTPRINT,
	WATER_EDGE,
	PATH_BLEND,
	CAVE_TRANSITION,
	EROSION,
	PEBBLE_SCATTER,
}

const DECAL_TEXTURES: Dictionary = {
	DecalType.BLOOD_SPLATTER:  "res://assets/textures/decals/blood_splatter.png",
	DecalType.SCORCH_MARK:     "res://assets/textures/decals/scorch_mark.png",
	DecalType.FOOTPRINT:       "res://assets/textures/decals/footprint.png",
	DecalType.WATER_EDGE:      "res://assets/textures/decals/water_edge.png",
	DecalType.PATH_BLEND:      "res://assets/textures/decals/path_blend.png",
	DecalType.CAVE_TRANSITION: "res://assets/textures/decals/cave_transition.png",
	DecalType.EROSION:         "res://assets/textures/decals/erosion.png",
	DecalType.PEBBLE_SCATTER:  "res://assets/textures/decals/pebble_scatter.png",
}

const DECAL_LIFETIMES: Dictionary = {
	DecalType.BLOOD_SPLATTER:  60.0,
	DecalType.SCORCH_MARK:     180.0,
	DecalType.FOOTPRINT:       30.0,
	DecalType.WATER_EDGE:      -1.0,  # permanent
	DecalType.PATH_BLEND:      -1.0,
	DecalType.CAVE_TRANSITION: -1.0,
	DecalType.EROSION:         -1.0,
	DecalType.PEBBLE_SCATTER:  -1.0,
}

@export var max_active_per_type: int = 32

var _active_decals_per_type: Dictionary = {}


func _ready() -> void:
	for t in DecalType.values():
		_active_decals_per_type[t] = []


func spawn_decal(decal_type: int, world_pos: Vector3, size_m: float = 1.0, rotation_y_deg: float = 0.0) -> Decal:
	var decal: Decal = Decal.new()
	decal.size = Vector3(size_m, 2.0, size_m)
	decal.upper_fade = 0.4
	decal.lower_fade = 0.4
	decal.albedo_mix = 1.0
	decal.modulate = Color(1, 1, 1, 1)
	if DECAL_TEXTURES.has(decal_type):
		var path: String = DECAL_TEXTURES[decal_type]
		if ResourceLoader.exists(path):
			decal.texture_albedo = load(path)
	add_child(decal)
	decal.global_position = world_pos
	decal.rotation.y = deg_to_rad(rotation_y_deg)

	# Track in pool
	var active: Array = _active_decals_per_type[decal_type]
	active.append(decal)
	if active.size() > max_active_per_type:
		var oldest: Decal = active.pop_front() as Decal
		if is_instance_valid(oldest):
			oldest.queue_free()

	# Schedule auto-fade if lifetime is positive
	var lifetime: float = DECAL_LIFETIMES.get(decal_type, -1.0)
	if lifetime > 0.0:
		var tw: Tween = create_tween()
		tw.tween_interval(lifetime - 1.5)
		tw.tween_property(decal, "modulate:a", 0.0, 1.5)
		tw.tween_callback(decal.queue_free)

	return decal


func clear_all() -> void:
	for t in _active_decals_per_type.keys():
		for d in _active_decals_per_type[t]:
			if is_instance_valid(d):
				d.queue_free()
		_active_decals_per_type[t].clear()
