class_name RoomLibrary
extends RefCounted

## Per-biome catalog of room templates. Loaded once at startup from
## res://data/room_templates/<biome>/. The dungeon generator queries this
## for templates that match required tags + floor restrictions.

const TEMPLATE_BASE_DIR: String = "res://data/room_templates/"

static var _libraries: Dictionary = {}  ## biome (StringName) -> Array[RoomTemplate]


static func get_templates_for_biome(biome: StringName) -> Array:
	if not _libraries.has(biome):
		_load_biome(biome)
	return _libraries.get(biome, [])


static func _load_biome(biome: StringName) -> void:
	var dir_path: String = TEMPLATE_BASE_DIR + String(biome) + "/"
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		_libraries[biome] = []
		return

	var templates: Array = []
	dir.list_dir_begin()
	while true:
		var file_name: String = dir.get_next()
		if file_name == "":
			break
		if file_name.ends_with(".tres"):
			var path: String = dir_path + file_name
			var t: RoomTemplate = load(path) as RoomTemplate
			if t != null:
				templates.append(t)
	dir.list_dir_end()
	_libraries[biome] = templates


static func get_templates_with_tag(biome: StringName, tag: StringName, floor: int = 1) -> Array:
	var result: Array = []
	for t: RoomTemplate in get_templates_for_biome(biome):
		if t.has_tag(tag) and t.is_eligible_for_floor(floor):
			result.append(t)
	return result


static func get_random_template(biome: StringName, tag: StringName, floor: int, rng: RandomNumberGenerator) -> RoomTemplate:
	var matches: Array = get_templates_with_tag(biome, tag, floor)
	if matches.is_empty():
		return null
	return matches[rng.randi() % matches.size()]


static func count_for_biome(biome: StringName) -> int:
	return get_templates_for_biome(biome).size()


static func clear_cache() -> void:
	_libraries.clear()
