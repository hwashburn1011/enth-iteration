extends Node
## WildernessStoryManager — fires one-shot wilderness story triggers
## gated on iteration count and story flags. Triggers are catalog
## entries; the actual Area3D collision lives on
## `WildernessStoryTrigger` scene components in the wilderness scene.
##
## Add to project autoloads as "WildernessStoryManager".

signal story_trigger_fired(trigger_id: StringName)
signal story_flag_set(flag: StringName)

var fired_triggers: Array[StringName] = []
var story_flags: Array[StringName] = []


func _ready() -> void:
	pass


# === FIRE ===

func try_fire_trigger(trigger_id: StringName) -> bool:
	if fired_triggers.has(trigger_id):
		return false
	var entry: Dictionary = WildernessStoryTriggerDatabase.get_trigger(trigger_id)
	if entry.is_empty():
		push_warning("WildernessStoryManager: unknown trigger '%s'" % trigger_id)
		return false
	if not _passes_gates(entry):
		return false

	fired_triggers.append(trigger_id)
	story_trigger_fired.emit(trigger_id)

	# Set flags
	for flag in entry.get("set_flags_on_fire", []):
		set_flag(flag)

	# Play music sting
	var sting: StringName = entry.get("music_sting", &"")
	if sting != &"" and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(sting)

	# Play cinematic timeline
	var timeline: Array = entry.get("timeline", [])
	if not timeline.is_empty() and has_node("/root/CutsceneController"):
		var cc: Node = get_node("/root/CutsceneController")
		if cc.has_method("play_timeline"):
			cc.play_timeline(timeline)

	return true


func _passes_gates(entry: Dictionary) -> bool:
	# Iteration gate
	var iter: int = _current_iteration()
	var iter_min: int = entry.get("iteration_min", 0)
	var iter_max: int = entry.get("iteration_max", -1)
	if iter < iter_min:
		return false
	if iter_max > 0 and iter > iter_max:
		return false

	# Required flags
	for flag in entry.get("required_flags", []):
		if not story_flags.has(flag):
			return false
	return true


# === FLAGS ===

func set_flag(flag: StringName) -> void:
	if story_flags.has(flag):
		return
	story_flags.append(flag)
	story_flag_set.emit(flag)


func has_flag(flag: StringName) -> bool:
	return story_flags.has(flag)


func clear_flag(flag: StringName) -> void:
	story_flags.erase(flag)


# === QUERIES ===

func is_fired(trigger_id: StringName) -> bool:
	return fired_triggers.has(trigger_id)


func get_fired_count() -> int:
	return fired_triggers.size()


func get_total_count() -> int:
	return WildernessStoryTriggerDatabase.get_count()


# === HELPERS ===

func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	if "current_iteration" in im:
		return int(im.current_iteration)
	return 1


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var f: Array = []
	for t in fired_triggers:
		f.append(String(t))
	var fl: Array = []
	for s in story_flags:
		fl.append(String(s))
	return {
		"fired_triggers": f,
		"story_flags": fl,
	}


func from_save_data(data: Dictionary) -> void:
	fired_triggers.clear()
	for s in data.get("fired_triggers", []):
		fired_triggers.append(StringName(s))
	story_flags.clear()
	for s in data.get("story_flags", []):
		story_flags.append(StringName(s))
