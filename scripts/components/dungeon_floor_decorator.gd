class_name DungeonFloorDecorator
extends Node

## Dungeon Generated Floor Decorator (Epic 29 tasks 20-26, 40-41, 44).
##
## Walks a freshly generated dungeon floor (post-room-stitching) and decorates
## every room based on its tag(s) with:
##   - Environmental hazards (spike traps, lava puddles, falling debris)
##   - Prop placement variation (loose rocks, crates, broken pipes, decals)
##   - Ambient enemy patrol patterns (waypoint loops per room)
##   - Destructible objects (pots, crates, glass tubes)
##   - Lore objects (datapads, journals, terminal logs)
##   - Lighting fixtures placed by room tag
##   - Reflection probes per room
##   - Per-room ambient SFX hooks (task 40)
##   - Per-room particle accents (task 41)
##   - Ambient creature spawners per biome (task 44)
##
## Input: array of GeneratedRoom dicts:
##   {
##     "id": StringName,
##     "tag": StringName,                  # combat / loot / story / secret / elite / boss
##     "biome": StringName,                # server_room / memory_vaults / corrupted_wilds / boss_sanctum
##     "node": Node3D,                     # the room scene root in the world
##     "floor_polygon": PackedVector2Array,
##     "spawn_anchors": Array[Vector3],   # marker nodes for placeable spots
##   }
##
## Hook:
##   var dec := DungeonFloorDecorator.new()
##   add_child(dec)
##   dec.decorate_floor(generated_rooms, floor_index, biome)

signal decoration_started
signal room_decorated(room_id: StringName, prop_count: int)
signal decoration_finished(total_props: int, total_hazards: int)

const HAZARD_DENSITY_BY_FLOOR: Dictionary = {
	1: 0.05, 2: 0.08, 3: 0.12, 4: 0.16, 5: 0.20, 6: 0.24, 7: 0.28, 8: 0.32, 9: 0.36,
}
const PROP_DENSITY: float = 0.55  # 55% of anchors get props on average
const PATROL_WAYPOINTS_PER_COMBAT_ROOM: int = 4
const DESTRUCTIBLE_RATIO: float = 0.30
const LORE_OBJECT_CHANCE: float = 0.18
const REFLECTION_PROBE_PER_ROOM: bool = true

const HAZARD_TYPES_PER_BIOME: Dictionary = {
	&"server_room": [&"electric_grate", &"data_loop_loop", &"server_steam_vent"],
	&"memory_vaults": [&"falling_pillar", &"pressure_plate_dart", &"chained_pendulum"],
	&"corrupted_wilds": [&"thorn_pit", &"poison_geyser", &"mire_pit"],
	&"boss_sanctum": [&"void_rift", &"lava_pool", &"shadow_grasp"],
}

const PROP_LIBRARY_PER_BIOME: Dictionary = {
	&"server_room": [&"server_rack", &"loose_cable", &"broken_terminal", &"data_crystal"],
	&"memory_vaults": [&"clay_urn", &"book_pile", &"dusty_chest", &"hanging_chain"],
	&"corrupted_wilds": [&"twisted_root", &"glowing_mushroom", &"corrupted_egg", &"sapling_growth"],
	&"boss_sanctum": [&"shattered_obelisk", &"void_shard", &"bone_pile", &"forgotten_tome"],
}

const AMBIENT_CREATURE_PER_BIOME: Dictionary = {
	&"server_room": [&"data_moth", &"register_rat"],
	&"memory_vaults": [&"dust_sprite", &"forgotten_imp"],
	&"corrupted_wilds": [&"glitch_beetle", &"static_bird"],
	&"boss_sanctum": [&"echo_wisp", &"void_crawler"],
}

@export var hazard_factory_path: NodePath
@export var prop_factory_path: NodePath
@export var creature_factory_path: NodePath


func decorate_floor(rooms: Array, floor_index: int, biome: StringName) -> Dictionary:
	decoration_started.emit()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("floor_%d_%s" % [floor_index, biome])
	var total_props: int = 0
	var total_hazards: int = 0

	for room: Dictionary in rooms:
		var stats: Dictionary = _decorate_room(room, floor_index, biome, rng)
		total_props += stats["props"]
		total_hazards += stats["hazards"]
		room_decorated.emit(room.get("id", &""), stats["props"])

	decoration_finished.emit(total_props, total_hazards)
	return {"total_props": total_props, "total_hazards": total_hazards}


func _decorate_room(room: Dictionary, floor_index: int, biome: StringName, rng: RandomNumberGenerator) -> Dictionary:
	var stats: Dictionary = {"props": 0, "hazards": 0}
	var tag: StringName = room.get("tag", &"combat")
	var node: Node3D = room.get("node") as Node3D
	var anchors: Array = room.get("spawn_anchors", [])
	if node == null or anchors.is_empty():
		return stats

	var hazard_density: float = HAZARD_DENSITY_BY_FLOOR.get(floor_index, 0.05)

	# === Hazards (skip in story / loot rooms) ===
	if tag != &"loot" and tag != &"story" and tag != &"secret":
		var hazards: Array = HAZARD_TYPES_PER_BIOME.get(biome, [])
		if not hazards.is_empty():
			for anchor: Vector3 in anchors:
				if rng.randf() < hazard_density:
					var hazard_id: StringName = hazards[rng.randi() % hazards.size()]
					_spawn_hazard(node, anchor, hazard_id)
					stats["hazards"] += 1

	# === Props ===
	var props: Array = PROP_LIBRARY_PER_BIOME.get(biome, [])
	if not props.is_empty():
		for anchor: Vector3 in anchors:
			if rng.randf() < PROP_DENSITY:
				var prop_id: StringName = props[rng.randi() % props.size()]
				var is_destructible: bool = rng.randf() < DESTRUCTIBLE_RATIO
				_spawn_prop(node, anchor, prop_id, is_destructible)
				stats["props"] += 1

	# === Lore object ===
	if tag != &"combat" and rng.randf() < LORE_OBJECT_CHANCE:
		_spawn_lore_object(node, anchors[rng.randi() % anchors.size()], biome)

	# === Patrol waypoints (combat rooms only) ===
	if tag == &"combat" or tag == &"elite":
		_place_patrol_waypoints(node, anchors, rng)

	# === Lighting by tag ===
	_place_lighting_for_tag(node, tag, biome)

	# === Reflection probe ===
	if REFLECTION_PROBE_PER_ROOM:
		_place_reflection_probe(node, room.get("floor_polygon", PackedVector2Array()))

	# === Ambient SFX hook (task 40) ===
	_attach_ambient_sfx(node, tag, biome)

	# === Particle accent (task 41) ===
	_attach_particle_accent(node, tag, biome)

	# === Ambient creature (task 44) — soft, low chance ===
	if rng.randf() < 0.18:
		var creatures: Array = AMBIENT_CREATURE_PER_BIOME.get(biome, [])
		if not creatures.is_empty():
			_spawn_ambient_creature(node, anchors[rng.randi() % anchors.size()],
				creatures[rng.randi() % creatures.size()])

	return stats


func _spawn_hazard(parent: Node3D, position: Vector3, hazard_id: StringName) -> void:
	var marker := Marker3D.new()
	marker.name = "Hazard_%s" % hazard_id
	marker.position = position
	marker.set_meta("hazard_id", hazard_id)
	marker.set_meta("decorator_managed", true)
	parent.add_child(marker)


func _spawn_prop(parent: Node3D, position: Vector3, prop_id: StringName, destructible: bool) -> void:
	var marker := Marker3D.new()
	marker.name = "Prop_%s%s" % [prop_id, "_dest" if destructible else ""]
	marker.position = position
	marker.set_meta("prop_id", prop_id)
	marker.set_meta("destructible", destructible)
	parent.add_child(marker)


func _spawn_lore_object(parent: Node3D, position: Vector3, biome: StringName) -> void:
	var marker := Marker3D.new()
	marker.name = "Lore_%s" % biome
	marker.position = position
	marker.set_meta("lore_biome", biome)
	marker.set_meta("interaction_type", &"datapad")
	parent.add_child(marker)


func _place_patrol_waypoints(parent: Node3D, anchors: Array, rng: RandomNumberGenerator) -> void:
	var count: int = min(PATROL_WAYPOINTS_PER_COMBAT_ROOM, anchors.size())
	var picked: Array = anchors.duplicate()
	picked.shuffle()
	for i in range(count):
		var marker := Marker3D.new()
		marker.name = "PatrolWaypoint_%d" % i
		marker.position = picked[i]
		marker.set_meta("patrol_index", i)
		parent.add_child(marker)


func _place_lighting_for_tag(parent: Node3D, tag: StringName, biome: StringName) -> void:
	var light_data := OmniLight3D.new()
	light_data.name = "RoomLight_%s" % tag
	match tag:
		&"combat":
			light_data.light_color = Color(1.0, 0.85, 0.7)
			light_data.light_energy = 1.6
			light_data.omni_range = 8.0
		&"loot":
			light_data.light_color = Color(1.0, 0.92, 0.5)
			light_data.light_energy = 2.4
			light_data.omni_range = 6.0
		&"story":
			light_data.light_color = Color(0.7, 0.85, 1.0)
			light_data.light_energy = 1.2
			light_data.omni_range = 7.0
		&"secret":
			light_data.light_color = Color(0.6, 0.4, 0.85)
			light_data.light_energy = 1.5
			light_data.omni_range = 5.0
		&"elite":
			light_data.light_color = Color(1.0, 0.4, 0.3)
			light_data.light_energy = 2.0
			light_data.omni_range = 9.0
		&"boss":
			light_data.light_color = Color(0.85, 0.2, 0.4)
			light_data.light_energy = 2.6
			light_data.omni_range = 12.0
	light_data.position = Vector3(0, 4.0, 0)
	parent.add_child(light_data)


func _place_reflection_probe(parent: Node3D, floor_polygon: PackedVector2Array) -> void:
	var probe := ReflectionProbe.new()
	probe.name = "RoomReflectionProbe"
	# Compute polygon centroid + half-extents
	if floor_polygon.size() > 0:
		var sum := Vector2.ZERO
		var min_v := Vector2(INF, INF)
		var max_v := Vector2(-INF, -INF)
		for p in floor_polygon:
			sum += p
			min_v.x = min(min_v.x, p.x)
			min_v.y = min(min_v.y, p.y)
			max_v.x = max(max_v.x, p.x)
			max_v.y = max(max_v.y, p.y)
		var centroid: Vector2 = sum / float(floor_polygon.size())
		probe.position = Vector3(centroid.x, 3.0, centroid.y)
		probe.size = Vector3(max_v.x - min_v.x, 6.0, max_v.y - min_v.y)
	else:
		probe.position = Vector3(0, 3.0, 0)
		probe.size = Vector3(12, 6, 12)
	probe.update_mode = ReflectionProbe.UPDATE_ONCE
	parent.add_child(probe)


func _attach_ambient_sfx(parent: Node3D, tag: StringName, biome: StringName) -> void:
	var marker := Marker3D.new()
	marker.name = "AmbientSFX_%s_%s" % [biome, tag]
	marker.set_meta("sfx_bed", &"%s_%s_bed" % [biome, tag])
	marker.set_meta("decorator_managed", true)
	parent.add_child(marker)


func _attach_particle_accent(parent: Node3D, tag: StringName, biome: StringName) -> void:
	var marker := Marker3D.new()
	marker.name = "ParticleAccent_%s" % biome
	marker.set_meta("particle_id", &"%s_accent" % biome)
	marker.set_meta("room_tag", tag)
	parent.add_child(marker)


func _spawn_ambient_creature(parent: Node3D, position: Vector3, creature_id: StringName) -> void:
	var marker := Marker3D.new()
	marker.name = "AmbientCreature_%s" % creature_id
	marker.position = position
	marker.set_meta("creature_id", creature_id)
	marker.set_meta("ambient_only", true)
	parent.add_child(marker)
