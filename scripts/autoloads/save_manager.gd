class_name SaveManagerClass
extends Node
## Centralized save/load system with versioned JSON schema.

const SAVE_PATH: String = "user://save_data.json"
const BACKUP_DIR: String = "user://backups/"
const SCHEMA_VERSION: int = 3

var current_data: Dictionary = {}
var last_save_time: float = 0.0
var _save_queued: bool = false
var _save_indicator: Label = null
var _item_registry: Script = null

const MIN_SAVE_INTERVAL: float = 10.0
const INDICATOR_DURATION: float = 1.5


func _ready() -> void:
	current_data = get_default_save_data()
	_item_registry = load("res://scripts/items/item_registry.gd")
	# Auto-save triggers
	EventBus.floor_completed.connect(_on_auto_save_trigger)
	EventBus.returned_to_town.connect(_on_auto_save_trigger_no_arg)
	EventBus.portal_used.connect(_on_auto_save_trigger_no_arg)
	EventBus.dungeon_entered.connect(_on_auto_save_trigger_no_arg)
	EventBus.game_saved.connect(_show_save_indicator)
	# Iteration advance is the single most precious progress milestone in
	# the game — the player just cleared a 5-floor run and the central
	# compaction conceit advanced. If we let the rate limiter swallow this
	# save, the next crash or alt-F4 wipes the loop they earned. Force-save
	# unconditionally on every advance.
	if has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_signal(&"iteration_advanced") and not im.iteration_advanced.is_connected(_on_iteration_advanced_force_save):
			im.iteration_advanced.connect(_on_iteration_advanced_force_save)
	_create_save_indicator()


func _on_iteration_advanced_force_save(_new_iteration: int) -> void:
	## Bypasses MIN_SAVE_INTERVAL because iteration advances are
	## permanent, player-earned progress that we can never lose. Skips the
	## in-combat queue too — the dungeon clear flow has already
	## transitioned out of combat by the time iteration_advanced fires.
	last_save_time = Time.get_ticks_msec() / 1000.0
	save_game()


func _on_auto_save_trigger(_arg: Variant = null) -> void:
	# Milestone autosave triggers (floor_completed, returned_to_town,
	# portal_used, dungeon_entered) are bounded transition events, not
	# periodic ticks — they fire a handful of times per run. Bypass
	# MIN_SAVE_INTERVAL: rate-limiting them silently dropped the save
	# right before a scene change, which left T68's pending_player_data
	# meta carrying stale state and the new scene's player rolled back to
	# whatever the last successful save captured.
	_force_milestone_save()


func _on_auto_save_trigger_no_arg() -> void:
	_force_milestone_save()


func _force_milestone_save() -> void:
	# Still respect the in-combat queue — we don't want to snapshot
	# mid-room with active enemies on screen, that's the whole point of
	# the deferred path. But unconditionally save once combat clears.
	if GameManager.has_meta(&"is_in_combat") and GameManager.get_meta(&"is_in_combat"):
		_save_queued = true
		if not EventBus.enemy_defeated.is_connected(_on_combat_may_have_ended):
			EventBus.enemy_defeated.connect(_on_combat_may_have_ended)
		return
	last_save_time = Time.get_ticks_msec() / 1000.0
	save_game()


func _on_combat_may_have_ended(_t: StringName, _p: Vector3, _l: Resource) -> void:
	if _save_queued:
		# Check if still in combat (room not cleared) — simple heuristic
		_save_queued = false
		if EventBus.enemy_defeated.is_connected(_on_combat_may_have_ended):
			EventBus.enemy_defeated.disconnect(_on_combat_may_have_ended)
		last_save_time = Time.get_ticks_msec() / 1000.0
		save_game()


func _create_save_indicator() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 90
	# Wrap label in a styled panel — matches HUD room-indicator chip style
	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -300.0  # match room indicator width
	panel.offset_top = 56.0
	panel.offset_right = -14.0
	panel.offset_bottom = 88.0
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.12, 0.92)
	style.border_color = Color(0.18, 0.55, 0.55, 0.85)
	style.set_border_width_all(1)
	style.border_width_left = 4
	style.set_corner_radius_all(4)
	style.set_content_margin_all(6)
	panel.add_theme_stylebox_override(&"panel", style)

	_save_indicator = Label.new()
	_save_indicator.text = "● SAVED"
	_save_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_indicator.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.7))
	_save_indicator.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
	_save_indicator.add_theme_constant_override(&"outline_size", 2)
	_save_indicator.add_theme_font_size_override(&"font_size", 14)
	panel.add_child(_save_indicator)

	panel.modulate.a = 0.0
	_save_indicator.set_meta(&"panel", panel)
	canvas.add_child(panel)
	add_child(canvas)


func _show_save_indicator() -> void:
	if _save_indicator == null:
		return
	var panel: PanelContainer = _save_indicator.get_meta(&"panel") as PanelContainer
	if panel == null:
		return
	panel.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(INDICATOR_DURATION)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)


func new_game() -> void:
	current_data = get_default_save_data()
	# Reset GameManager state
	GameManager.recruited_npcs.clear()
	GameManager.newly_recruited.clear()
	GameManager.npc_affinity.clear()
	GameManager._talked_this_session.clear()
	GameManager.first_run = true
	GameManager.set_meta(&"highest_floor", 0)
	GameManager.set_meta(&"total_runs", 0)
	GameManager.set_meta(&"town_entry_type", "new_game")
	# Write initial save
	save_game()
	# Load town
	GameManager.change_scene_to("res://scenes/town/Town.tscn")


func save_game() -> bool:
	current_data = get_default_save_data()
	current_data["timestamp"] = Time.get_datetime_string_from_system()

	# 1. Player data
	var player: Node = _find_player()
	if player:
		current_data["player"]["health"] = player.health_component.current_health
		current_data["player"]["compute"] = player.compute_component.current_compute
		current_data["player"]["position"] = {
			"x": player.global_position.x,
			"y": player.global_position.y,
			"z": player.global_position.z,
		}
		current_data["player"]["stat_points"] = player.stats_component.level_points.duplicate()
		# Save level and XP from LevelComponent
		if player.level_component:
			current_data["player"]["level"] = player.level_component.current_level
			current_data["player"]["xp"] = player.level_component.current_xp
			current_data["player"]["xp_to_next"] = player.level_component.xp_to_next_level
			current_data["player"]["unspent_stat_points"] = player.level_component.unspent_stat_points
	# Save current scene path
	var scene_path: String = get_tree().current_scene.scene_file_path
	if scene_path != "":
		current_data["player"]["current_scene"] = scene_path

	# 2. Inventory data
	if player and player.inventory_component:
		var grid_items: Array = []
		var _seen_items: Array = []  # Track item instances to avoid multi-cell duplicates
		for y: int in player.inventory_component.grid_height:
			for x: int in player.inventory_component.grid_width:
				var item: Resource = player.inventory_component.grid[y][x] as Resource
				if item != null and item not in _seen_items:
					_seen_items.append(item)
					# Save the BASE stat_modifiers, not the effective (durability-
					# scaled, core-bonus-merged) result. On load the item will be
					# rebuilt and get_effective_stat_modifiers() runs again at
					# equip time — saving the effective values would double-scale
					# durability and double-merge CoreItem.core_bonus_stats every
					# save/load cycle. The saved durability separately rebuilds
					# the scaling at load time.
					grid_items.append({
						"item_id": item.item_id,
						"grid_pos": [x, y],
						"durability": item.current_durability,
						"rarity": item.rarity,
						"stat_modifiers": item.stat_modifiers.duplicate(),
					})
		current_data["inventory"]["grid_items"] = grid_items
		var hotbar: Array = []
		for entry: Dictionary in player.inventory_component.prompt_hotbar:
			var prompt: Resource = entry["item"] as Resource
			hotbar.append({"item_id": prompt.item_id, "quantity": int(entry["quantity"])})
		current_data["inventory"]["prompt_hotbar"] = hotbar

	# 3. Equipment data — mirror the grid_items shape so durability, rolled
	# rarity, and rolled stat_modifiers (the item_generator affixes) survive
	# save/load. Storing only item_id was wiping every player's gear back to
	# the base template on every load — a fully-rolled Legendary became a
	# stock common copy. Helper closure keeps the slot serialization tight.
	if player and player.equipment_component:
		var eq: Node = player.equipment_component
		var modules: Array = []
		for m: Variant in eq.module_slots:
			modules.append(_serialize_equipped_slot(m))
		current_data["equipment"]["modules"] = modules
		current_data["equipment"]["core"] = _serialize_equipped_slot(eq.core_slot)
		var chips: Array = []
		for c: Variant in eq.chip_slots:
			chips.append(_serialize_equipped_slot(c))
		current_data["equipment"]["chips"] = chips
		var protocols: Array = []
		for p: Variant in eq.protocol_slots:
			protocols.append(_serialize_equipped_slot(p))
		current_data["equipment"]["protocols"] = protocols

	# 4. Town data
	current_data["town"]["recruited_npcs"] = GameManager.recruited_npcs.duplicate()
	current_data["town"]["npc_affinity"] = GameManager.npc_affinity.duplicate()
	current_data["town"]["expansion_stage"] = GameManager.recruited_npcs.size()

	# 5. Dungeon data (stored on GameManager)
	current_data["dungeon"]["highest_floor_reached"] = GameManager.get_meta(&"highest_floor", 0) as int
	current_data["dungeon"]["total_runs"] = GameManager.get_meta(&"total_runs", 0) as int

	# 6. Progression — IterationManager state. Without this, every load
	# resets to iteration 1 and the central compaction conceit silently
	# never advances even after a player completes the loop.
	if has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method(&"to_save_data"):
			current_data["progression"] = im.to_save_data()

	# 7. Quest progress — QuestManager state. Same problem as progression:
	# active_quests + completed_quests are pure in-memory and the per-
	# objective current_count fields are non-@exported, so a fresh .tres
	# load on town reentry restores them to zero. Without this snapshot,
	# every save/load wiped quest progress and the starter quest re-seeded.
	if has_node("/root/QuestManager"):
		var qm: Node = get_node("/root/QuestManager")
		if qm.has_method(&"to_save_data"):
			current_data["quests"] = qm.to_save_data()

	# Create backup before writing
	_create_backup()

	# Write to file
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file — %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(current_data, "\t"))
	file.close()
	# Stage pending metas from the just-saved snapshot. apply_to_player only
	# applies state when these metas exist; previously they were *only*
	# populated in _apply_loaded_data (i.e. load_game), so an autosave on
	# dungeon_entered → change_scene_to(dungeon) would write the file but
	# the new dungeon scene's player respawn would still see no pending data
	# and stay at default level 1 with empty equipment. Mirror the load
	# population here so save → scene swap → apply_to_player carries the
	# freshly-saved player forward instead of resetting them.
	set_meta(&"pending_player_data", current_data.get("player", {}))
	set_meta(&"pending_inventory_data", current_data.get("inventory", {}))
	set_meta(&"pending_equipment_data", current_data.get("equipment", {}))
	EventBus.game_saved.emit()
	return true


func load_game() -> bool:
	var data: Dictionary = _read_save_file(SAVE_PATH)
	if data.is_empty():
		# Try backups sequentially
		for i: int in range(1, 4):
			push_warning("SaveManager: trying backup %d..." % i)
			data = _read_save_file(_backup_path(i))
			if not data.is_empty():
				break
		if data.is_empty():
			push_error("SaveManager: no valid save file or backup found")
			return false

	# Validate and migrate schema
	var version: int = data.get("schema_version", 0) as int
	if version < SCHEMA_VERSION:
		data = _migrate_save(data, version, SCHEMA_VERSION)

	current_data = data
	_apply_loaded_data(data)
	EventBus.game_loaded.emit()
	return true


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func _read_save_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to open '%s'" % path)
		return {}
	var content: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary:
		return parsed as Dictionary
	push_error("SaveManager: corrupted save file '%s'" % path)
	return {}


func _migrate_save(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
	# Sequential migration — add cases as schema evolves
	var migrated: Dictionary = data
	for v: int in range(from_version, to_version):
		match v:
			0:
				# v0 → v1: fill missing fields with defaults
				var defaults: Dictionary = get_default_save_data()
				for key: String in defaults:
					if key not in migrated:
						migrated[key] = defaults[key]
				migrated["schema_version"] = 1
			1:
				# v1 → v2: introduce progression section for IterationManager.
				# Existing v1 saves have no iteration data, so default to 1
				# (a v1 save was made before iteration tracking existed,
				# meaning the player never advanced past the first loop).
				if "progression" not in migrated:
					migrated["progression"] = {"current_iteration": 1}
				migrated["schema_version"] = 2
			2:
				# v2 → v3: introduce quests section for QuestManager. Existing
				# v2 saves had no quest data — every load wiped quest progress
				# back to a fresh seed. Treat them as having no active or
				# completed quests; the next town entry will re-seed normally.
				if "quests" not in migrated:
					migrated["quests"] = {"active": [], "completed": []}
				migrated["schema_version"] = 3
	return migrated


func _backup_path(index: int) -> String:
	return BACKUP_DIR + "save_backup_%d.json" % index


func _create_backup() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	DirAccess.make_dir_recursive_absolute(BACKUP_DIR)
	# Rotate: 2→3, 1→2
	if FileAccess.file_exists(_backup_path(2)):
		DirAccess.copy_absolute(_backup_path(2), _backup_path(3))
	if FileAccess.file_exists(_backup_path(1)):
		DirAccess.copy_absolute(_backup_path(1), _backup_path(2))
	# Current save → backup 1
	DirAccess.copy_absolute(SAVE_PATH, _backup_path(1))


func load_backup(index: int = 1) -> bool:
	var data: Dictionary = _read_save_file(_backup_path(index))
	if data.is_empty():
		return false
	var version: int = data.get("schema_version", 0) as int
	if version < SCHEMA_VERSION:
		data = _migrate_save(data, version, SCHEMA_VERSION)
	current_data = data
	_apply_loaded_data(data)
	EventBus.game_loaded.emit()
	return true


func has_valid_save() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var data: Dictionary = _read_save_file(SAVE_PATH)
		if not data.is_empty():
			return true
	for i: int in range(1, 4):
		if FileAccess.file_exists(_backup_path(i)):
			var data: Dictionary = _read_save_file(_backup_path(i))
			if not data.is_empty():
				return true
	return false


func _apply_loaded_data(data: Dictionary) -> void:
	var defaults: Dictionary = get_default_save_data()

	# 4. Town data — restore to GameManager first (before scene loads)
	var town: Dictionary = data.get("town", defaults["town"]) as Dictionary
	GameManager.recruited_npcs.clear()
	for npc_id: Variant in town.get("recruited_npcs", []):
		GameManager.recruited_npcs.append(str(npc_id))
	GameManager.npc_affinity = {}
	var affinity_data: Dictionary = town.get("npc_affinity", {}) as Dictionary
	for npc_id: String in affinity_data:
		GameManager.npc_affinity[npc_id] = int(affinity_data[npc_id])

	# 5. Dungeon data
	var dungeon: Dictionary = data.get("dungeon", defaults["dungeon"]) as Dictionary
	GameManager.set_meta(&"highest_floor", int(dungeon.get("highest_floor_reached", 0)))
	GameManager.set_meta(&"total_runs", int(dungeon.get("total_runs", 0)))

	# 6. Progression — restore IterationManager state. Loads BEFORE the scene
	# change so any node that reads current_iteration in _ready picks up the
	# right value on first tick instead of starting at 1 and re-syncing later.
	var progression: Dictionary = data.get("progression", defaults["progression"]) as Dictionary
	if has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method(&"from_save_data"):
			im.from_save_data(progression)

	# 7. Quest progress — restore QuestManager state. Apply BEFORE the town
	# scene reloads so town.gd._seed_starter_quests sees the restored
	# active/completed lists and its idempotent add_quest is a no-op.
	var quests: Dictionary = data.get("quests", defaults.get("quests", {})) as Dictionary
	if has_node("/root/QuestManager"):
		var qm: Node = get_node("/root/QuestManager")
		if qm.has_method(&"from_save_data"):
			qm.from_save_data(quests)

	# Player, inventory, and equipment are applied after scene load
	# (player node must exist). Store data for deferred application.
	set_meta(&"pending_player_data", data.get("player", defaults["player"]))
	set_meta(&"pending_inventory_data", data.get("inventory", defaults["inventory"]))
	set_meta(&"pending_equipment_data", data.get("equipment", defaults["equipment"]))


func apply_to_player(player: Node) -> void:
	## Called after player is instantiated to restore saved state.
	if not has_meta(&"pending_player_data"):
		return
	var pdata: Dictionary = get_meta(&"pending_player_data") as Dictionary
	# Restore stat allocations FIRST so the component recalculations use the
	# saved integrity / memory / bandwidth values, then trigger stats_changed
	# so HealthComponent and ComputeComponent recompute their max values.
	# After T6/T7 max_health is derived from base + integrity*INTEGRITY_HP_SCALE,
	# so writing max_health directly here would be silently overwritten.
	var stat_pts: Dictionary = pdata.get("stat_points", {}) as Dictionary
	for stat_name: String in stat_pts:
		player.stats_component.level_points[stat_name] = int(stat_pts[stat_name])
	player.stats_component.stats_changed.emit()
	# Now restore current resource values, clamped to the freshly recalculated
	# maxes (saved value may be lower than max — that's a wounded character).
	var saved_hp: float = float(pdata.get("health", player.health_component.max_health))
	player.health_component.current_health = clampf(saved_hp, 0.0, player.health_component.max_health)
	var saved_compute: float = float(pdata.get("compute", player.compute_component.max_compute))
	player.compute_component.current_compute = clampf(saved_compute, 0.0, player.compute_component.max_compute)
	var pos: Dictionary = pdata.get("position", {}) as Dictionary
	player.global_position = Vector3(
		float(pos.get("x", 0.0)),
		float(pos.get("y", 0.0)),
		float(pos.get("z", 0.0))
	)

	# Restore level and XP
	if player.level_component:
		player.level_component.current_level = int(pdata.get("level", 1))
		player.level_component.current_xp = int(pdata.get("xp", 0))
		player.level_component.xp_to_next_level = int(pdata.get("xp_to_next", player.level_component.xp_to_next_level))
		player.level_component.unspent_stat_points = int(pdata.get("unspent_stat_points", 0))

	# Inventory
	var inv_data: Dictionary = get_meta(&"pending_inventory_data", {}) as Dictionary
	var grid_items: Array = inv_data.get("grid_items", []) as Array
	for entry: Variant in grid_items:
		var e: Dictionary = entry as Dictionary
		var item: Resource = _item_registry.create_item(
			str(e.get("item_id", "")),
			float(e.get("durability", 100.0)),
			e.get("stat_modifiers", {}) as Dictionary,
			int(e.get("rarity", 0))
		)
		if item:
			player.inventory_component.add_item(item)
	var hotbar: Array = inv_data.get("prompt_hotbar", []) as Array
	for entry: Variant in hotbar:
		var e: Dictionary = entry as Dictionary
		var prompt: Resource = _item_registry.create_item(str(e.get("item_id", "")))
		if prompt and prompt.get("item_type") == "prompt":
			for i: int in int(e.get("quantity", 1)):
				player.inventory_component.add_prompt(prompt)

	# Equipment — _create_equipped_item handles both the legacy v1 string
	# entries (just an item_id) and the new v2 dict entries that carry
	# durability + rarity + rolled stat_modifiers from T34.
	var eq_data: Dictionary = get_meta(&"pending_equipment_data", {}) as Dictionary
	var modules: Array = eq_data.get("modules", []) as Array
	for i: int in modules.size():
		var item: Resource = _create_equipped_item(modules[i])
		if item:
			player.equipment_component.equip(item, i)
	var core_entry: Variant = eq_data.get("core")
	var core_item: Resource = _create_equipped_item(core_entry)
	if core_item:
		player.equipment_component.equip(core_item)
	var chips: Array = eq_data.get("chips", []) as Array
	for i: int in chips.size():
		var chip_item: Resource = _create_equipped_item(chips[i])
		if chip_item:
			player.equipment_component.equip(chip_item, i)
	var protocols: Array = eq_data.get("protocols", []) as Array
	for i: int in protocols.size():
		var proto_item: Resource = _create_equipped_item(protocols[i])
		if proto_item:
			player.equipment_component.equip(proto_item, i)

	# Clean up pending data
	remove_meta(&"pending_player_data")
	remove_meta(&"pending_inventory_data")
	remove_meta(&"pending_equipment_data")


func _serialize_equipped_slot(item: Variant) -> Variant:
	## Mirror of the grid_items entry shape but as a single dict (or null
	## when the slot is empty) so the existing save layout stays flat.
	## Preserves rolled rarity / rolled affixes (stat_modifiers) /
	## durability so loaded equipment matches what the player had.
	if item == null:
		return null
	return {
		"item_id": item.item_id,
		"durability": item.current_durability,
		"rarity": item.rarity,
		"stat_modifiers": item.stat_modifiers.duplicate(),
	}


func _create_equipped_item(entry: Variant) -> Resource:
	## Inverse of _serialize_equipped_slot. Accepts both the legacy v1
	## string format ("just an item_id") and the v2 dict format so old
	## saves don't break — they just lose the rolled details that
	## weren't being saved anyway.
	if entry == null:
		return null
	if entry is String:
		return _item_registry.create_item(entry as String)
	if entry is Dictionary:
		var e: Dictionary = entry as Dictionary
		return _item_registry.create_item(
			str(e.get("item_id", "")),
			float(e.get("durability", 100.0)),
			e.get("stat_modifiers", {}) as Dictionary,
			int(e.get("rarity", 0))
		)
	return null


func _find_player() -> Node:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		return nodes[0]
	return null


func get_default_save_data() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"timestamp": "",
		"player": {
			"level": 1,
			"xp": 0,
			"stat_points": {
				"processing": 0,
				"bandwidth": 0,
				"memory": 0,
				"integrity": 0,
			},
			"health": 100.0,
			"compute": 50.0,
			"position": {"x": 0.0, "y": 0.0, "z": 0.0},
			"current_scene": "res://scenes/town/Town.tscn",
		},
		"inventory": {
			"grid_items": [],
			"prompt_hotbar": [],
		},
		"equipment": {
			"modules": [null, null, null, null],
			"core": null,
			"chips": [null, null, null, null],
			"protocols": [null, null, null],
		},
		"town": {
			"recruited_npcs": [],
			"npc_affinity": {},
			"expansion_stage": 0,
		},
		"dungeon": {
			"highest_floor_reached": 0,
			"total_runs": 0,
		},
		"quests": {
			"active": [],
			"completed": [],
		},
		"settings": {
			"master_volume": 1.0,
			"music_volume": 0.8,
			"sfx_volume": 1.0,
		},
		"progression": {
			"current_iteration": 1,
		},
	}
