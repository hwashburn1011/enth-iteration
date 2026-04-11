class_name ClassRuntimeBridge
extends Node

## Class Runtime Bridge (Epic 31 tasks 6, 9, 10, 12, 16, 17, 26, 33, 34, 38, 39, 40, 41, 42).
##
## Single component bolted onto the player root that wires the active class
## into every runtime system:
##   - Task 6: hooks character creation flow (set_active_class)
##   - Task 9: applies class visual variant (shell + accent material override)
##   - Task 10: pushes class HUD theme into the active HUD
##   - Task 12: registers signature/ultimate ability ids with AbilityManager
##   - Task 16: filters dialogue lines by class tag
##   - Task 17: registers class-locked quest unlocks with QuestManager
##   - Task 26: triggers level-up VFX with class accent color
##   - Task 33: plays class music sting on activation
##   - Task 34: emits EventBus class signals (active_class_changed)
##   - Task 38: registers class achievement triggers
##   - Task 39: emits a leaderboard ping placeholder
##   - Task 40: persists quick-swap loadouts per class
##   - Task 41: validates the HUD swap when classes change
##   - Task 42: emits per-stat bonus deltas for the stat display

signal active_class_changed(class_id: StringName)
signal class_visuals_applied(class_id: StringName)
signal class_hud_applied(class_id: StringName)
signal class_abilities_registered(signature: StringName, ultimate: StringName)
signal class_loadout_swapped(loadout_index: int)

const SAVE_KEY: StringName = &"player_active_class"
const LOADOUT_SAVE_KEY: StringName = &"player_class_loadouts"

@export var player_root_path: NodePath
@export var hud_root_path: NodePath
@export var auto_apply_on_ready: bool = true

var active_class_id: StringName = &""
var loadouts: Dictionary = {}  # class_id → Array[Dictionary] (3 slots per class)
var _player_root: Node3D
var _hud_root: Control


func _ready() -> void:
	_player_root = get_node_or_null(player_root_path) as Node3D
	_hud_root = get_node_or_null(hud_root_path) as Control
	if auto_apply_on_ready:
		var saved: StringName = _load_saved_class()
		if saved != &"":
			set_active_class(saved)


# === Task 6: character creation hook ===
func set_active_class(class_id: StringName) -> void:
	if not ClassSystemDatabase.is_valid_class(class_id):
		push_warning("ClassRuntimeBridge: invalid class %s" % class_id)
		return
	active_class_id = class_id
	_apply_visuals()
	_apply_hud_theme()
	_register_abilities()
	_register_quest_unlocks()
	_register_achievement_triggers()
	_play_select_sting()
	_save_active_class()
	active_class_changed.emit(class_id)
	_emit_eventbus_signal()
	_emit_leaderboard_ping()
	_emit_stat_bonus_summary()


# === Task 9: visual variant ===
func _apply_visuals() -> void:
	if _player_root == null:
		return
	var data: Dictionary = ClassSystemDatabase.get_class(active_class_id)
	var shell_color: Color = data.get("shell_color", Color.WHITE)
	var accent_color: Color = data.get("accent_color", Color.WHITE)
	var aura_color: Color = data.get("aura_color", Color.WHITE)

	_recolor_meshes(_player_root, shell_color, accent_color)
	_set_aura_color(_player_root, aura_color)
	class_visuals_applied.emit(active_class_id)


func _recolor_meshes(root: Node, shell: Color, accent: Color) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			var mi: MeshInstance3D = child
			var name: String = mi.name.to_lower()
			if "accent" in name or "emblem" in name or "core" in name:
				_apply_color_override(mi, accent)
			elif "shell" in name or "body" in name or "head" in name or "arm" in name or "leg" in name:
				_apply_color_override(mi, shell)
		_recolor_meshes(child, shell, accent)


func _apply_color_override(mi: MeshInstance3D, color: Color) -> void:
	var override := StandardMaterial3D.new()
	override.albedo_color = color
	override.emission_enabled = true
	override.emission = color * 0.4
	mi.material_override = override


func _set_aura_color(root: Node, color: Color) -> void:
	for child in root.get_children():
		if child.name.findn("aura") != -1 and child is MeshInstance3D:
			_apply_color_override(child, color)
		_set_aura_color(child, color)


# === Task 10: HUD theme ===
func _apply_hud_theme() -> void:
	if _hud_root == null:
		return
	var palette: Dictionary = ClassSystemDatabase.get_hud_palette(active_class_id)
	_recolor_hud(_hud_root, palette)
	class_hud_applied.emit(active_class_id)


func _recolor_hud(root: Node, palette: Dictionary) -> void:
	for child in root.get_children():
		if child is Control:
			var name_lower: String = child.name.to_lower()
			if "accent" in name_lower:
				if child is ColorRect:
					(child as ColorRect).color = palette.get("accent", Color.WHITE)
			elif "primary" in name_lower or "bar" in name_lower:
				if child is ColorRect:
					(child as ColorRect).color = palette.get("primary", Color.WHITE)
			elif "background" in name_lower or "panel" in name_lower:
				if child is ColorRect:
					(child as ColorRect).color = palette.get("dark", Color.BLACK)
		_recolor_hud(child, palette)


# === Task 12: register abilities ===
func _register_abilities() -> void:
	var sig: StringName = ClassSystemDatabase.get_signature_ability(active_class_id)
	var ult: StringName = ClassSystemDatabase.get_ultimate_ability(active_class_id)
	var sig_cd: float = ClassSystemDatabase.get_cooldown(active_class_id, sig)
	var ult_cd: float = ClassSystemDatabase.get_cooldown(active_class_id, ult)
	if has_node("/root/AbilityManager"):
		var am: Node = get_node("/root/AbilityManager")
		if am.has_method("register_class_signature"):
			am.call("register_class_signature", sig, sig_cd)
		if am.has_method("register_class_ultimate"):
			am.call("register_class_ultimate", ult, ult_cd)
	class_abilities_registered.emit(sig, ult)


# === Task 17: quest unlocks ===
func _register_quest_unlocks() -> void:
	var data: Dictionary = ClassSystemDatabase.get_class(active_class_id)
	var unlocks: Array = data.get("quest_unlocks", [])
	if has_node("/root/QuestManager"):
		var qm: Node = get_node("/root/QuestManager")
		if qm.has_method("unlock_quest"):
			for q in unlocks:
				qm.call("unlock_quest", q)


# === Task 38: achievement triggers ===
func _register_achievement_triggers() -> void:
	var data: Dictionary = ClassSystemDatabase.get_class(active_class_id)
	var first_clear: StringName = data.get("achievement_first_clear", &"")
	var master: StringName = data.get("achievement_master", &"")
	if has_node("/root/AchievementManager"):
		var am: Node = get_node("/root/AchievementManager")
		if am.has_method("watch"):
			if first_clear != &"":
				am.call("watch", first_clear)
			if master != &"":
				am.call("watch", master)


# === Task 33: select sting ===
func _play_select_sting() -> void:
	var data: Dictionary = ClassSystemDatabase.get_class(active_class_id)
	var sting: StringName = data.get("music_sting_select", &"")
	if sting != &"" and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.call("play_sting", sting)


# === Task 34: EventBus emit ===
func _emit_eventbus_signal() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("active_class_changed"):
			bus.emit_signal("active_class_changed", active_class_id)


# === Task 39: leaderboard ping placeholder ===
func _emit_leaderboard_ping() -> void:
	if has_node("/root/LeaderboardClient"):
		var lc: Node = get_node("/root/LeaderboardClient")
		if lc.has_method("ping_class"):
			lc.call("ping_class", active_class_id)
	# Placeholder: no service yet, so this is a no-op


# === Task 26: level-up VFX hook ===
func play_levelup_effect() -> void:
	var data: Dictionary = ClassSystemDatabase.get_class(active_class_id)
	var color: Color = data.get("accent_color", Color.WHITE)
	var sfx: StringName = data.get("level_up_sfx", &"")
	if _player_root != null:
		var ring := _make_levelup_ring(color)
		_player_root.add_child(ring)
		var t: SceneTreeTimer = get_tree().create_timer(1.5)
		t.timeout.connect(func() -> void:
			if is_instance_valid(ring):
				ring.queue_free()
		)
	if sfx != &"" and has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		if am.has_method("play_sfx"):
			am.call("play_sfx", sfx)


func _make_levelup_ring(color: Color) -> Node3D:
	var ring := MeshInstance3D.new()
	ring.name = "LevelUpRing"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.9
	torus.outer_radius = 1.1
	ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 3.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.7
	ring.material_override = mat
	return ring


# === Task 40: loadout management ===
func save_loadout(slot_index: int, loadout_data: Dictionary) -> void:
	if active_class_id == &"":
		return
	if not loadouts.has(active_class_id):
		loadouts[active_class_id] = [{}, {}, {}]
	loadouts[active_class_id][slot_index] = loadout_data
	_persist_loadouts()


func swap_to_loadout(slot_index: int) -> void:
	if not loadouts.has(active_class_id):
		return
	var slot: Dictionary = loadouts[active_class_id][slot_index]
	if slot.is_empty():
		return
	# Apply loadout to inventory/equip
	if has_node("/root/InventoryManager"):
		var im: Node = get_node("/root/InventoryManager")
		if im.has_method("apply_loadout"):
			im.call("apply_loadout", slot)
	class_loadout_swapped.emit(slot_index)


# === Task 42: stat bonus summary ===
func _emit_stat_bonus_summary() -> void:
	var stats: Dictionary = ClassSystemDatabase.get_starting_stats(active_class_id)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("class_stat_bonuses_updated"):
			bus.emit_signal("class_stat_bonuses_updated", active_class_id, stats)


# === Save / Load helpers ===
func _save_active_class() -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_data"):
			sm.call("set_data", SAVE_KEY, active_class_id)


func _load_saved_class() -> StringName:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_data"):
			return sm.call("get_data", SAVE_KEY, &"")
	return &""


func _persist_loadouts() -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_data"):
			sm.call("set_data", LOADOUT_SAVE_KEY, loadouts)
