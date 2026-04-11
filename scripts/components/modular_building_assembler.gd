class_name ModularBuildingAssembler
extends Node3D

## Modular building assembly tool (Epic 12 task 9 + 36).
## Snap-grid based building assembly from the kit pieces. Lets the
## runtime (or in-engine editor) compose buildings by stamping kit
## pieces (walls, roofs, doors, windows, trim) onto a 1m floor grid
## with auto-snap to nearest grid cell.
##
## Used by:
##   - Town generator: stamps filler buildings procedurally from a
##     district config
##   - Future Pillar 3 town builder feature: lets the player place
##     their own buildings during the building game phase
##   - Editor tooling for content authors
##
## Required scene shape:
##   ModularBuildingAssembler (Node3D + this script)
##     export grid_size_m: float = 1.0
##     export kit_master_path: String = "res://_art_source/buildings/kit/kit_master.blend"

@export var grid_size_m: float = 1.0
@export var kit_master_path: String = "res://_art_source/buildings/kit/kit_master.blend"
@export var snap_to_grid: bool = true

var _kit_pieces_cache: Dictionary = {}


func snap_position(world_pos: Vector3) -> Vector3:
	if not snap_to_grid:
		return world_pos
	return Vector3(
		round(world_pos.x / grid_size_m) * grid_size_m,
		round(world_pos.y / grid_size_m) * grid_size_m,
		round(world_pos.z / grid_size_m) * grid_size_m,
	)


func place_kit_piece(piece_id: StringName, world_pos: Vector3, rotation_y_deg: float = 0.0) -> Node3D:
	## Stamps a kit piece at the snapped grid position
	var piece_path: String = "res://scenes/buildings/kit/%s.tscn" % String(piece_id)
	if not ResourceLoader.exists(piece_path):
		push_warning("ModularBuildingAssembler: kit piece not found: %s" % piece_id)
		return null
	var packed: PackedScene = load(piece_path) as PackedScene
	if packed == null:
		return null
	var instance: Node3D = packed.instantiate() as Node3D
	add_child(instance)
	instance.global_position = snap_position(world_pos)
	instance.rotation.y = deg_to_rad(rotation_y_deg)
	return instance


func assemble_filler_blueprint(blueprint: Dictionary) -> Array[Node3D]:
	## Stamps an entire filler building from a blueprint dictionary.
	## blueprint format:
	##   {
	##     "pieces": [
	##       {"id": "wall_plain_stone", "pos": Vector3(0, 0, 0), "rot": 0},
	##       {"id": "roof_peaked",      "pos": Vector3(0, 0, 3), "rot": 0},
	##       ...
	##     ]
	##   }
	var spawned: Array[Node3D] = []
	if not blueprint.has("pieces"):
		return spawned
	for entry: Dictionary in blueprint["pieces"]:
		var piece: Node3D = place_kit_piece(
			entry.get("id", &""),
			entry.get("pos", Vector3.ZERO),
			entry.get("rot", 0.0),
		)
		if piece != null:
			spawned.append(piece)
	return spawned
