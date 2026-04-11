class_name NPCScheduleSystem
extends Node

## Town NPC schedule system (Epic 10 task 42).
## Drives where each NPC is at any given time of day. Each NPC has a
## list of (time_window, location_node_path, animation_id) entries.
## The system listens to the GameManager day/night cycle clock and
## moves NPCs to their scheduled positions.
##
## Schedule format:
##   {
##     "pixel": [
##       {"start": 6.0, "end": 22.0, "location": "TownSquare/PixelShop", "anim": "pixel_work"},
##       {"start": 22.0, "end": 6.0, "location": "TownSquare/PixelHome", "anim": "pixel_idle"},
##     ],
##     ...
##   }
##
## Hookup:
##   var schedule: NPCScheduleSystem = $NPCScheduleSystem
##   schedule.register_npc("pixel", pixel_node)
##   schedule.set_time_of_day(14.5)  # 2:30pm
##
## Game time wraps at 24.0 hours.

signal npc_relocated(npc_id: StringName, location_path: NodePath)
signal npc_animation_changed(npc_id: StringName, anim_id: StringName)

@export var schedule_data: Dictionary = {}
@export var location_root_path: NodePath
@export var current_time_of_day: float = 8.0  # 8am default

var _npcs: Dictionary = {}  # npc_id → Node3D
var _location_root: Node3D
var _last_applied_state: Dictionary = {}


func _ready() -> void:
	_location_root = get_node_or_null(location_root_path) as Node3D
	_load_default_schedule()


func _load_default_schedule() -> void:
	## Default schedule for the 12 town NPCs from the bible
	if not schedule_data.is_empty():
		return
	schedule_data = {
		&"pixel": [
			{"start": 7.0, "end": 21.0, "location": "PixelShop", "anim": &"pixel_work"},
			{"start": 21.0, "end": 7.0, "location": "PixelHome", "anim": &"pixel_idle"},
		],
		&"forge": [
			{"start": 6.0, "end": 18.0, "location": "ForgeAnvil", "anim": &"forge_work"},
			{"start": 18.0, "end": 22.0, "location": "Tavern", "anim": &"forge_idle"},
			{"start": 22.0, "end": 6.0, "location": "ForgeHome", "anim": &"forge_idle"},
		],
		&"cache": [
			{"start": 16.0, "end": 24.0, "location": "TavernBar", "anim": &"cache_work"},
			{"start": 0.0, "end": 8.0, "location": "CacheHome", "anim": &"cache_idle"},
			{"start": 8.0, "end": 16.0, "location": "Market", "anim": &"cache_idle"},
		],
		&"index": [
			{"start": 8.0, "end": 20.0, "location": "Library", "anim": &"index_work"},
			{"start": 20.0, "end": 8.0, "location": "IndexHome", "anim": &"index_idle"},
		],
		&"harvest": [
			{"start": 5.0, "end": 18.0, "location": "Field", "anim": &"harvest_work"},
			{"start": 18.0, "end": 22.0, "location": "Tavern", "anim": &"harvest_idle"},
			{"start": 22.0, "end": 5.0, "location": "HarvestHome", "anim": &"harvest_idle"},
		],
		&"bit": [
			{"start": 7.0, "end": 12.0, "location": "Library", "anim": &"bit_idle"},
			{"start": 12.0, "end": 18.0, "location": "TownSquare", "anim": &"bit_work"},
			{"start": 18.0, "end": 7.0, "location": "BitHome", "anim": &"bit_idle"},
		],
		&"legacy": [
			{"start": 8.0, "end": 18.0, "location": "TownSquareBench", "anim": &"legacy_work"},
			{"start": 18.0, "end": 8.0, "location": "LegacyHome", "anim": &"legacy_idle"},
		],
		&"trade": [
			{"start": 8.0, "end": 18.0, "location": "Market", "anim": &"trade_work"},
			{"start": 18.0, "end": 22.0, "location": "Tavern", "anim": &"trade_idle"},
			{"start": 22.0, "end": 8.0, "location": "TradeWagon", "anim": &"trade_idle"},
		],
		&"lab": [
			{"start": 0.0, "end": 24.0, "location": "Lab", "anim": &"lab_work"},
		],
		&"render": [
			{"start": 9.0, "end": 19.0, "location": "TownSquareEasel", "anim": &"render_work"},
			{"start": 19.0, "end": 9.0, "location": "RenderHome", "anim": &"render_idle"},
		],
		&"sync": [
			{"start": 14.0, "end": 23.0, "location": "TownSquare", "anim": &"sync_work"},
			{"start": 23.0, "end": 14.0, "location": "SyncHome", "anim": &"sync_idle"},
		],
		&"sentinel": [
			{"start": 0.0, "end": 12.0, "location": "GateNorth", "anim": &"sentinel_work"},
			{"start": 12.0, "end": 24.0, "location": "GateSouth", "anim": &"sentinel_work"},
		],
	}


func register_npc(npc_id: StringName, npc_node: Node3D) -> void:
	_npcs[npc_id] = npc_node


func set_time_of_day(hours: float) -> void:
	current_time_of_day = fposmod(hours, 24.0)
	_apply_schedule()


func _apply_schedule() -> void:
	for npc_id: StringName in _npcs.keys():
		if not schedule_data.has(npc_id):
			continue
		var entries: Array = schedule_data[npc_id]
		var entry: Dictionary = _find_entry_for_time(entries, current_time_of_day)
		if entry.is_empty():
			continue
		_apply_entry(npc_id, entry)


func _find_entry_for_time(entries: Array, time: float) -> Dictionary:
	for e: Dictionary in entries:
		var start: float = e["start"]
		var end_t: float = e["end"]
		if start <= end_t:
			if start <= time and time < end_t:
				return e
		else:
			# Wraparound (e.g. 22.0 → 6.0)
			if time >= start or time < end_t:
				return e
	return {}


func _apply_entry(npc_id: StringName, entry: Dictionary) -> void:
	var prev: Dictionary = _last_applied_state.get(npc_id, {})
	var loc_path: String = entry.get("location", "")
	var anim_id: StringName = entry.get("anim", &"")
	if prev.get("location", "") != loc_path:
		_relocate_npc(npc_id, loc_path)
	if prev.get("anim", &"") != anim_id:
		_play_animation(npc_id, anim_id)
	_last_applied_state[npc_id] = {"location": loc_path, "anim": anim_id}


func _relocate_npc(npc_id: StringName, location_relative_path: String) -> void:
	var npc: Node3D = _npcs.get(npc_id)
	if npc == null or _location_root == null:
		return
	var location: Node3D = _location_root.get_node_or_null(location_relative_path) as Node3D
	if location == null:
		return
	npc.global_position = location.global_position
	npc_relocated.emit(npc_id, location.get_path())


func _play_animation(npc_id: StringName, anim_id: StringName) -> void:
	var npc: Node3D = _npcs.get(npc_id)
	if npc == null:
		return
	var anim_player: AnimationPlayer = npc.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if anim_player == null:
		# Search children
		for child: Node in npc.get_children():
			if child is AnimationPlayer:
				anim_player = child
				break
	if anim_player != null and anim_player.has_animation(String(anim_id)):
		anim_player.play(String(anim_id))
		npc_animation_changed.emit(npc_id, anim_id)
