extends Node
## ClassRegistry — autoload that owns the catalog of all player ClassDefinition
## resources, the active class for the current run, and class-related events.
##
## Add to project autoloads as "ClassRegistry".

signal class_changed(new_class_id: StringName, previous_class_id: StringName)
signal class_unlocked(class_id: StringName)
signal class_milestone_reached(class_id: StringName, milestone_level: int, unlock_id: StringName)

const CLASS_DIR: String = "res://data/classes/"

var classes: Dictionary = {}                  ## class_id -> ClassDefinition
var active_class_id: StringName = &""
var unlocked_classes: Array[StringName] = []

var _restricted_items_by_class: Dictionary = {}  ## item_id -> class_id


func _ready() -> void:
	_load_all_classes()
	_build_restriction_index()


func _load_all_classes() -> void:
	var dir: DirAccess = DirAccess.open(CLASS_DIR)
	if dir == null:
		push_warning("ClassRegistry: %s not found, classes will need manual registration" % CLASS_DIR)
		return
	dir.list_dir_begin()
	while true:
		var file_name: String = dir.get_next()
		if file_name == "":
			break
		if file_name.ends_with(".tres"):
			var path: String = CLASS_DIR + file_name
			var def: ClassDefinition = load(path) as ClassDefinition
			if def != null and def.class_id != &"":
				classes[def.class_id] = def
	dir.list_dir_end()
	#print("ClassRegistry: loaded %d classes" % classes.size())


func _build_restriction_index() -> void:
	for class_id: StringName in classes.keys():
		var def: ClassDefinition = classes[class_id]
		for item_id in def.restricted_item_ids:
			_restricted_items_by_class[item_id] = class_id


func register_class(def: ClassDefinition) -> void:
	if def == null or def.class_id == &"":
		return
	classes[def.class_id] = def
	for item_id in def.restricted_item_ids:
		_restricted_items_by_class[item_id] = def.class_id


func get_class(class_id: StringName) -> ClassDefinition:
	return classes.get(class_id)


func get_active_class() -> ClassDefinition:
	return classes.get(active_class_id)


func set_active_class(class_id: StringName) -> bool:
	if not classes.has(class_id):
		push_warning("ClassRegistry: unknown class %s" % class_id)
		return false
	var prev: StringName = active_class_id
	active_class_id = class_id
	if not unlocked_classes.has(class_id):
		unlocked_classes.append(class_id)
		class_unlocked.emit(class_id)
	class_changed.emit(class_id, prev)
	return true


func can_class_use_item(class_id: StringName, item_id: StringName) -> bool:
	if not _restricted_items_by_class.has(item_id):
		return true
	return _restricted_items_by_class[item_id] == class_id


func can_active_use_item(item_id: StringName) -> bool:
	return can_class_use_item(active_class_id, item_id)


func get_milestones_for_level(class_id: StringName, level: int) -> Array:
	var def: ClassDefinition = get_class(class_id)
	if def == null:
		return []
	var hits: Array = []
	for m in def.milestones:
		if m.get("level", 0) == level:
			hits.append(m)
	return hits


func check_level_milestones(class_id: StringName, new_level: int) -> void:
	for m in get_milestones_for_level(class_id, new_level):
		class_milestone_reached.emit(class_id, new_level, m.get("unlock_id", &""))


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"active_class_id": String(active_class_id),
		"unlocked_classes": unlocked_classes.map(func(s: StringName) -> String: return String(s)),
	}


func from_save_data(data: Dictionary) -> void:
	active_class_id = StringName(data.get("active_class_id", ""))
	unlocked_classes.clear()
	for s in data.get("unlocked_classes", []):
		unlocked_classes.append(StringName(s))
