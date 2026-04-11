class_name ResourceNode
extends Node3D

## In-world harvestable resource node. Place at any wilderness gathering
## position. Validates the player's tool, runs the harvest action over
## `harvest_time_s`, grants the rolled yield + XP, and disables the node
## visually until the 24-in-game-hour respawn timer elapses.
##
## Required scene shape:
##   ResourceNode (Node3D + this script)
##     Visual (any Node3D — the model that hides when depleted)
##     InteractArea (Area3D + CollisionShape3D — interact range)
##     OptionalLight (OmniLight3D — only if the node type emits_light)
##
## Configure via the inspector:
##   node_type_id — must match a ResourceNodeDatabase entry id

signal harvest_started(node_type_id: StringName)
signal harvest_completed(node_type_id: StringName, items: Array)
signal harvest_failed(reason: StringName)
signal depleted
signal respawned

@export var node_type_id: StringName = &""

var _depleted: bool = false
var _depleted_at_hour_total: int = -100000
var _harvesting: bool = false
var _harvest_started_at: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	# Phase-restricted nodes (e.g., glow moss only at night) hide on phase change
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
	_apply_phase_visibility()


func _process(_delta: float) -> void:
	if _depleted:
		_check_respawn()


# === HARVEST ===

func can_harvest_with(tool_id: StringName, player_skill_level: int) -> bool:
	if _depleted or _harvesting:
		return false
	var entry: Dictionary = ResourceNodeDatabase.get_node_type(node_type_id)
	if entry.is_empty():
		return false
	if entry.get("required_tool", &"hands") != tool_id:
		return false
	if player_skill_level < int(entry.get("required_skill_level", 1)):
		return false
	if not _phase_allows():
		return false
	return true


func begin_harvest(player: Node3D) -> void:
	var entry: Dictionary = ResourceNodeDatabase.get_node_type(node_type_id)
	if entry.is_empty():
		harvest_failed.emit(&"unknown_node_type")
		return
	if _depleted:
		harvest_failed.emit(&"depleted")
		return
	if _harvesting:
		harvest_failed.emit(&"already_harvesting")
		return

	# Tool check
	var required_tool: StringName = entry.get("required_tool", &"hands")
	var player_tool: StringName = _get_equipped_tool(player)
	if required_tool != &"hands" and player_tool != required_tool:
		harvest_failed.emit(&"wrong_tool")
		return

	# Skill check
	var skill_level: int = _get_player_gathering_level(player)
	if skill_level < int(entry.get("required_skill_level", 1)):
		harvest_failed.emit(&"skill_too_low")
		return

	# Phase check
	if not _phase_allows():
		harvest_failed.emit(&"wrong_time_of_day")
		return

	_harvesting = true
	_harvest_started_at = Time.get_ticks_msec() / 1000.0
	harvest_started.emit(node_type_id)

	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(entry.get("sfx_id", &""))

	# Start a one-shot timer for the harvest duration
	var t: SceneTreeTimer = get_tree().create_timer(entry.get("harvest_time_s", 2.0))
	t.timeout.connect(_complete_harvest.bind(player, entry))


func _complete_harvest(player: Node3D, entry: Dictionary) -> void:
	if not _harvesting:
		return
	_harvesting = false

	# Roll yields
	var rolled_items: Array = []
	for item_def in entry.get("yield", []):
		var item_id: StringName = item_def.get("item_id", &"")
		var min_count: int = int(item_def.get("min", 1))
		var max_count: int = int(item_def.get("max", min_count))
		var count: int = _rng.randi_range(min_count, max_count)
		if count > 0 and item_id != &"":
			rolled_items.append({"item_id": item_id, "count": count})

	# Grant items
	if has_node("/root/InventoryManager"):
		var inv: Node = get_node("/root/InventoryManager")
		for item in rolled_items:
			if inv.has_method("add_item"):
				inv.add_item(item["item_id"], item["count"])

	# Grant XP
	var xp: int = int(entry.get("xp_reward", 0))
	if xp > 0 and player != null:
		var farm_comp: Node = player.get_node_or_null("FarmingComponent")
		if farm_comp != null and farm_comp.has_method("add_gathering_xp"):
			farm_comp.add_gathering_xp(xp)

	# VFX
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("vfx_play_at"):
			bus.emit_signal("vfx_play_at", entry.get("vfx_id", &""), global_position)

	harvest_completed.emit(node_type_id, rolled_items)
	_deplete()


# === STATE ===

func _deplete() -> void:
	_depleted = true
	_depleted_at_hour_total = _current_hour_total()
	_set_visual_visible(false)
	depleted.emit()


func _check_respawn() -> void:
	var entry: Dictionary = ResourceNodeDatabase.get_node_type(node_type_id)
	var respawn_hours: int = int(entry.get("respawn_hours", 24))
	var elapsed: int = _current_hour_total() - _depleted_at_hour_total
	if elapsed >= respawn_hours:
		_respawn()


func _respawn() -> void:
	_depleted = false
	_set_visual_visible(true)
	respawned.emit()


func _set_visual_visible(visible: bool) -> void:
	var visual: Node = get_node_or_null(^"Visual")
	if visual is Node3D:
		(visual as Node3D).visible = visible


# === PHASE ===

func _phase_allows() -> bool:
	var entry: Dictionary = ResourceNodeDatabase.get_node_type(node_type_id)
	var allowed: Array = entry.get("phase_restriction", [])
	if allowed.is_empty():
		return true
	return allowed.has(_current_phase())


func _apply_phase_visibility() -> void:
	if _depleted:
		return
	_set_visual_visible(_phase_allows())


func _on_phase_changed(_phase: StringName) -> void:
	_apply_phase_visibility()


# === HELPERS ===

func _current_hour_total() -> int:
	if not has_node("/root/DayNightController"):
		return 0
	var dnc: Node = get_node("/root/DayNightController")
	var day: int = 0
	var hour: int = 0
	if "current_day" in dnc:
		day = int(dnc.current_day)
	if dnc.has_method("get_current_hour"):
		hour = int(dnc.get_current_hour())
	return day * 24 + hour


func _current_phase() -> StringName:
	if not has_node("/root/DayNightController"):
		return &"day"
	var dnc: Node = get_node("/root/DayNightController")
	if "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"


func _get_equipped_tool(player: Node3D) -> StringName:
	if player == null:
		return &"hands"
	var equip: Node = player.get_node_or_null("EquipmentComponent")
	if equip != null and equip.has_method("get_equipped_tool"):
		return equip.get_equipped_tool()
	return &"hands"


func _get_player_gathering_level(player: Node3D) -> int:
	if player == null:
		return 1
	var farm_comp: Node = player.get_node_or_null("FarmingComponent")
	if farm_comp != null and "gathering_level" in farm_comp:
		return int(farm_comp.gathering_level)
	return 1


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"depleted": _depleted,
		"depleted_at_hour_total": _depleted_at_hour_total,
	}


func from_save_data(data: Dictionary) -> void:
	_depleted = data.get("depleted", false)
	_depleted_at_hour_total = int(data.get("depleted_at_hour_total", -100000))
	_set_visual_visible(not _depleted and _phase_allows())
