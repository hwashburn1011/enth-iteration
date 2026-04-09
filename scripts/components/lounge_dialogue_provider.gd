class_name LoungeDialogueProvider
extends Node3D

## Lounge-only dialogue presenter for Cache. Sits beside the
## LoungeBar Area3D. When the player presses interact while at the
## bar AND Cache is on shift, queries LoungeDialogueDatabase for the
## currently-available topics, presents them in a small list UI, and
## plays the chosen topic's lines via DialogueManager.
##
## On topic completion the manager sets the topic's `set_flag` so the
## player can never re-trigger the same conversation, and so other
## systems (LoungeBar drink rotation, story triggers) can react to
## the conversation having happened.
##
## Required scene shape:
##   LoungeDialogueProvider (Node3D + this script)
##     [no children needed; sits next to LoungeBar in the lounge scene]

signal topic_offered(topic_ids: Array)
signal topic_played(topic_id: StringName)

@export var cache_npc_id: StringName = &"cache"


func _ready() -> void:
	pass


# === API ===

func get_available_topics() -> Array[Dictionary]:
	var tier: StringName = _get_cache_affinity_tier()
	var flags: Array = _get_set_flags()
	var iteration: int = _current_iteration()
	return LoungeDialogueDatabase.get_available_topics(tier, flags, iteration)


func play_topic(topic_id: StringName) -> bool:
	var entry: Dictionary = LoungeDialogueDatabase.get_topic(topic_id)
	if entry.is_empty():
		return false

	# Verify the topic is actually available right now
	var available: Array[Dictionary] = get_available_topics()
	var found: bool = false
	for a in available:
		if a.get("id", &"") == topic_id:
			found = true
			break
	if not found:
		return false

	# Hand the line array to DialogueManager.play_sequence (or fallback
	# to one show_line call per beat for engines without a sequence API)
	var lines: Array = entry.get("lines", [])
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("play_sequence"):
			dm.play_sequence(lines)
		elif dm.has_method("show_line"):
			# Fallback: chain show_line calls with small delays
			_play_sequence_fallback(dm, lines)

	# Set the topic's flag so it can't repeat
	var flag: StringName = entry.get("set_flag", &"")
	if flag != &"":
		_set_story_flag(flag)

	# Pump Cache's affinity by 2 — even quiet conversations build trust
	if has_node("/root/AffinityManager"):
		var am: Node = get_node("/root/AffinityManager")
		if am.has_method("add_affinity"):
			am.add_affinity(cache_npc_id, 2)

	topic_played.emit(topic_id)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("lounge_dialogue_played"):
			bus.emit_signal("lounge_dialogue_played", topic_id)
	return true


func _play_sequence_fallback(dm: Node, lines: Array) -> void:
	for i in lines.size():
		var line: Dictionary = lines[i]
		# 2.5s gap per line
		var t: SceneTreeTimer = get_tree().create_timer(i * 2.5)
		t.timeout.connect(func() -> void:
			if dm.has_method("show_line"):
				dm.show_line(line.get("speaker", "Cache"), line.get("text", ""), &"voice_cache")
		)


# === HELPERS ===

func _get_cache_affinity_tier() -> StringName:
	if not has_node("/root/AffinityManager"):
		return &"acquaintance"
	var am: Node = get_node("/root/AffinityManager")
	if am.has_method("get_tier"):
		return am.get_tier(cache_npc_id)
	return &"acquaintance"


func _get_set_flags() -> Array:
	var flags: Array = []
	if has_node("/root/WildernessStoryManager"):
		var sm: Node = get_node("/root/WildernessStoryManager")
		if "story_flags" in sm:
			flags = (sm.story_flags as Array).duplicate()
	return flags


func _set_story_flag(flag: StringName) -> void:
	if has_node("/root/WildernessStoryManager"):
		var sm: Node = get_node("/root/WildernessStoryManager")
		if sm.has_method("set_flag"):
			sm.set_flag(flag)


func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1
