class_name EntranceWarden
extends Node3D

## Per-entrance warden NPC controller. Wraps an interactable Area3D
## that opens dialogue and a small shop UI when the player presses
## interact in range. Reads from EntranceWardenDatabase for all
## content. Hides the warden during phases they don't have on schedule
## (e.g. Quill naps at night).
##
## Required scene shape:
##   EntranceWarden (Node3D + this script)
##     Visual (any Node3D — the warden's mesh)
##     Interact (Area3D + CollisionShape3D — interact range)
##     [optional] DialogueAnchor (Marker3D — where dialogue UI orbits)
##
## Configure via inspector:
##   entrance_id — must match an EntranceWardenDatabase key

signal dialogue_requested(line: String, speaker_name: String)
signal shop_opened(inventory: Dictionary)
signal warden_appeared
signal warden_left

@export var entrance_id: StringName = &""

@onready var _interact: Area3D = $Interact if has_node("Interact") else null
@onready var _visual: Node3D = $Visual if has_node("Visual") else null

var _player_in_range: bool = false
var _has_greeted_this_visit: bool = false
var _has_met_player_ever: bool = false


func _ready() -> void:
	if _interact != null:
		_interact.body_entered.connect(_on_player_entered)
		_interact.body_exited.connect(_on_player_exited)
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
	_apply_phase_visibility()


# === INTERACTION ===

func can_interact() -> bool:
	if not _player_in_range:
		return false
	if not _is_present_now():
		return false
	return true


func interact() -> void:
	if not can_interact():
		return

	var greeting_pool: String = "greeting_first" if not _has_met_player_ever else "greeting_recurring"
	var line: String = EntranceWardenDatabase.roll_line(entrance_id, greeting_pool)
	if line.is_empty():
		line = EntranceWardenDatabase.roll_line(entrance_id, "lore")
	if line.is_empty():
		return

	var warden: Dictionary = EntranceWardenDatabase.get_warden(entrance_id)
	var speaker_name: String = warden.get("display_name", "Warden")

	dialogue_requested.emit(line, speaker_name)
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line(speaker_name, line, _get_voice_id())

	_has_met_player_ever = true
	_has_greeted_this_visit = true


func say_clear_comment(time_taken_seconds: float) -> void:
	## Called by FloorManager / DungeonResultsScreen after a successful
	## clear so the warden has something to say next time.
	var pool_key: String = "clear_comment_quick" if time_taken_seconds < 600 else "clear_comment_slow"
	var line: String = EntranceWardenDatabase.roll_line(entrance_id, pool_key)
	if line.is_empty():
		return
	var warden: Dictionary = EntranceWardenDatabase.get_warden(entrance_id)
	dialogue_requested.emit(line, warden.get("display_name", "Warden"))
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line(warden.get("display_name", "Warden"), line, _get_voice_id())


func say_daily_intel(bonus_entrance_display_name: String) -> void:
	var line: String = EntranceWardenDatabase.format_daily_intel(entrance_id, bonus_entrance_display_name)
	if line.is_empty():
		return
	var warden: Dictionary = EntranceWardenDatabase.get_warden(entrance_id)
	dialogue_requested.emit(line, warden.get("display_name", "Warden"))
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line(warden.get("display_name", "Warden"), line, _get_voice_id())


func open_shop() -> void:
	var warden: Dictionary = EntranceWardenDatabase.get_warden(entrance_id)
	var inventory: Dictionary = warden.get("shop_inventory", {})
	shop_opened.emit(inventory)
	if has_node("/root/ShopManager"):
		var sm: Node = get_node("/root/ShopManager")
		if sm.has_method("open_for_npc"):
			sm.open_for_npc(warden.get("npc_id", &""), inventory)


# === SCHEDULE ===

func _is_present_now() -> bool:
	var phase: StringName = _current_phase()
	return EntranceWardenDatabase.is_present_in_phase(entrance_id, phase)


func _apply_phase_visibility() -> void:
	var present: bool = _is_present_now()
	if _visual != null:
		_visual.visible = present
	if present:
		warden_appeared.emit()
	else:
		warden_left.emit()


func _on_phase_changed(_phase: StringName) -> void:
	_apply_phase_visibility()


# === HELPERS ===

func _get_voice_id() -> StringName:
	var warden: Dictionary = EntranceWardenDatabase.get_warden(entrance_id)
	if warden.get("silent", false):
		return &""
	return StringName(warden.get("voice_id", ""))


func _current_phase() -> StringName:
	if not has_node("/root/DayNightController"):
		return &"day"
	var dnc: Node = get_node("/root/DayNightController")
	if "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_has_greeted_this_visit = false


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"entrance_id": String(entrance_id),
		"has_met_player_ever": _has_met_player_ever,
	}


func from_save_data(data: Dictionary) -> void:
	_has_met_player_ever = data.get("has_met_player_ever", false)
