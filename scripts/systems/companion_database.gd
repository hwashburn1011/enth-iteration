class_name CompanionDatabase
extends RefCounted

## Static catalog of all 4 companions with stats, abilities, AI behavior tags.

const COMPANIONS: Array = [
	{
		"id": &"patch",
		"name": "Patch",
		"role": &"tank",
		"recruit_quest": &"main_12_companion",
		"personality": "Stoic, reliable, dry humor.",
		"color": Color(0.55, 0.55, 0.65),
		"accent": Color(0.95, 0.65, 0.30),
		"faction": &"optimizers",
		"affinity_npc": &"sentinel",  # gift preferences inherit from this NPC

		# Combat stats
		"max_hp":   250.0,
		"damage":   8.0,
		"defense":  1.5,
		"speed":    3.5,
		"attack_range": 2.0,
		"attack_speed": 0.6,  # attacks per second

		# Abilities
		"signature_id": &"ironclad",
		"signature_cd": 18.0,
		"ultimate_id":  &"phalanx",
		"ultimate_cd":  90.0,

		# AI tuning
		"target_priority": &"highest_threat",
		"engage_distance": 4.0,
		"reposition_distance": 1.5,
		"follow_offset": Vector3(-1.5, 0, -1.0),

		# Visual
		"model_path": "res://assets/models/companions/patch.glb",
		"portrait_path": "res://assets/textures/companions/patch_portrait.png",
	},
	{
		"id": &"ping",
		"name": "Ping",
		"role": &"ranged",
		"recruit_quest": &"side_lab_companion",
		"personality": "Cheerful, talkative, makes jokes.",
		"color": Color(0.95, 0.95, 0.30),
		"accent": Color(0.10, 0.10, 0.15),
		"faction": &"dreamers",
		"affinity_npc": &"lab",

		"max_hp":   100.0,
		"damage":   25.0,
		"defense":  0.7,
		"speed":    5.5,
		"attack_range": 12.0,
		"attack_speed": 1.5,

		"signature_id": &"marked_target",
		"signature_cd": 15.0,
		"ultimate_id":  &"overcharge_volley",
		"ultimate_cd":  90.0,

		"target_priority": &"lowest_hp",
		"engage_distance": 10.0,
		"reposition_distance": 6.0,  # ranged kites
		"follow_offset": Vector3(1.5, 0, -1.0),

		"model_path": "res://assets/models/companions/ping.glb",
		"portrait_path": "res://assets/textures/companions/ping_portrait.png",
	},
	{
		"id": &"mend",
		"name": "Mend",
		"role": &"healer",
		"recruit_quest": &"main_18_friend_indeed",  # iter 4 quest
		"personality": "Warm, empathetic, slightly anxious.",
		"color": Color(0.55, 0.85, 0.55),
		"accent": Color(0.95, 0.95, 0.85),
		"faction": &"archivists",
		"affinity_npc": &"index",

		"max_hp":   150.0,
		"damage":   5.0,
		"defense":  1.0,
		"speed":    4.5,
		"attack_range": 6.0,
		"attack_speed": 0.8,

		"signature_id": &"restoration_field",
		"signature_cd": 20.0,
		"ultimate_id":  &"iteration_mend",
		"ultimate_cd":  120.0,

		"target_priority": &"heal_lowest_hp",
		"engage_distance": 8.0,
		"reposition_distance": 4.0,
		"follow_offset": Vector3(0, 0, -2.0),

		"model_path": "res://assets/models/companions/mend.glb",
		"portrait_path": "res://assets/textures/companions/mend_portrait.png",
	},
	{
		"id": &"hex",
		"name": "Hex",
		"role": &"cc",
		"recruit_quest": &"main_29_lost_npc",  # iter 6 quest
		"personality": "Mysterious, glitchy speech, loves chaos.",
		"color": Color(0.60, 0.05, 0.30),
		"accent": Color(0.55, 0.20, 0.95),
		"faction": &"glitchers",
		"affinity_npc": &"sage",

		"max_hp":   120.0,
		"damage":   12.0,
		"defense":  0.85,
		"speed":    5.0,
		"attack_range": 8.0,
		"attack_speed": 1.0,

		"signature_id": &"stutter_field",
		"signature_cd": 16.0,
		"ultimate_id":  &"time_stop",
		"ultimate_cd":  100.0,

		"target_priority": &"elite_first",
		"engage_distance": 7.0,
		"reposition_distance": 5.0,
		"follow_offset": Vector3(2.0, 0, 0.5),

		"model_path": "res://assets/models/companions/hex.glb",
		"portrait_path": "res://assets/textures/companions/hex_portrait.png",
	},
]

const SIGNATURE_ABILITIES: Dictionary = {
	&"ironclad": {
		"name": "Ironclad",
		"description": "Taunt nearby enemies and -50% incoming damage for 5s.",
		"duration": 5.0,
		"effect": &"taunt_and_dr",
		"radius": 6.0,
	},
	&"marked_target": {
		"name": "Marked Target",
		"description": "Designate one enemy. All shots crit on it for 6s.",
		"duration": 6.0,
		"effect": &"mark_crit",
		"radius": 0.0,
	},
	&"restoration_field": {
		"name": "Restoration Field",
		"description": "AOE that heals 8 HP/s and cleanses statuses for 4s.",
		"duration": 4.0,
		"effect": &"heal_aoe",
		"radius": 5.0,
	},
	&"stutter_field": {
		"name": "Stutter Field",
		"description": "AOE that slows enemies 50% and applies brief stuns for 4s.",
		"duration": 4.0,
		"effect": &"slow_stun",
		"radius": 5.0,
	},
}

const ULTIMATE_ABILITIES: Dictionary = {
	&"phalanx": {
		"name": "Phalanx",
		"description": "Root in place, invulnerable for 8s, reflect 30% damage.",
		"duration": 8.0,
		"effect": &"invuln_reflect",
	},
	&"overcharge_volley": {
		"name": "Overcharge Volley",
		"description": "3 seconds of unlimited rapid-fire crit shots.",
		"duration": 3.0,
		"effect": &"rapid_crit",
	},
	&"iteration_mend": {
		"name": "Iteration Mend",
		"description": "Fully heal Globbler + remove all debuffs + 10s shield.",
		"duration": 10.0,
		"effect": &"full_heal_shield",
	},
	&"time_stop": {
		"name": "Time Stop",
		"description": "Freezes all enemies in 8m radius for 4 seconds.",
		"duration": 4.0,
		"effect": &"freeze_aoe",
		"radius": 8.0,
	},
}

static var _index: Dictionary = {}


static func get_all() -> Array:
	return COMPANIONS


static func get_companion(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for c in COMPANIONS:
		_index[c["id"]] = c


static func get_signature(ability_id: StringName) -> Dictionary:
	return SIGNATURE_ABILITIES.get(ability_id, {})


static func get_ultimate(ability_id: StringName) -> Dictionary:
	return ULTIMATE_ABILITIES.get(ability_id, {})


static func count() -> int:
	return COMPANIONS.size()
