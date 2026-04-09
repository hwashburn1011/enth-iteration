class_name WildernessStoryTriggerDatabase
extends RefCounted

## Catalog of one-shot wilderness story trigger zones. Each entry is a
## scripted story beat that fires when the player crosses a specific
## position, gated on iteration count and (optionally) prior story
## flags. These are the "show, never tell" moments that thread the
## wilderness through the 9-iteration arc.
##
## Triggers fire EXACTLY ONCE per save file. State lives in
## WildernessStoryTriggerManager.
##
## See `_bmad-output/wilderness/wilderness_bible.md` for landmark layout.

const TRIGGERS: Array[Dictionary] = [
	{
		"id": &"wst_first_steps",
		"display_name": "First Steps Beyond the Gate",
		"region": &"wild_plateau",
		"trigger_position": Vector3(0, 6, 50),
		"trigger_radius": 5.0,
		"iteration_min": 1,
		"iteration_max": 1,  # Only on the very first iteration
		"required_flags": [],
		"set_flags_on_fire": [&"wilderness_first_visit"],
		"cinematic_id": &"wst_first_steps",
		"timeline": [
			{"event": &"set_letterbox", "enabled": true},
			{"event": &"play_dialogue", "speaker": &"narrator", "text": "The town gate is behind you for the first time.", "duration": 3.0},
			{"event": &"wait", "duration": 0.5},
			{"event": &"play_dialogue", "speaker": &"narrator", "text": "The loop forgets you out here.", "duration": 3.0},
			{"event": &"set_letterbox", "enabled": false},
		],
		"music_sting": &"sting_first_step",
	},
	{
		"id": &"wst_bridge_journal",
		"display_name": "The Previous Globbler's Journal",
		"region": &"wild_river",
		"trigger_position": Vector3(-12, 0, -10),
		"trigger_radius": 4.0,
		"iteration_min": 2,
		"iteration_max": -1,
		"required_flags": [&"wilderness_first_visit"],
		"set_flags_on_fire": [&"bridge_journal_found"],
		"cinematic_id": &"wst_bridge_journal",
		"timeline": [
			{"event": &"set_letterbox", "enabled": true},
			{"event": &"camera_move", "target": Vector3(-12, 1, -8), "duration": 1.5},
			{"event": &"play_dialogue", "speaker": &"sage_proxy", "text": "Someone was building this. They didn't finish.", "duration": 3.0},
			{"event": &"play_dialogue", "speaker": &"sage_proxy", "text": "There's a journal in the scaffolding. Read it.", "duration": 3.0},
			{"event": &"signal", "name": &"reward_granted", "args": [{"type": &"lore_tablet", "id": &"lore_previous_globbler_journal_1"}]},
			{"event": &"set_letterbox", "enabled": false},
		],
		"music_sting": &"sting_lore_unlock",
	},
	{
		"id": &"wst_ruins_glitch_wave",
		"display_name": "First Glitch Wave",
		"region": &"wild_ruins",
		"trigger_position": Vector3(28, 0, -15),
		"trigger_radius": 8.0,
		"iteration_min": 3,
		"iteration_max": -1,
		"required_flags": [],
		"set_flags_on_fire": [&"ruins_glitch_warned"],
		"cinematic_id": &"wst_ruins_glitch_wave",
		"timeline": [
			{"event": &"set_letterbox", "enabled": true},
			{"event": &"camera_shake", "intensity": 0.8, "duration": 1.0},
			{"event": &"play_sfx", "id": &"sfx_glitch_burst_distant"},
			{"event": &"play_dialogue", "speaker": &"narrator", "text": "The spire's glyphs flicker. Something inside it knows you are here.", "duration": 3.5},
			{"event": &"set_letterbox", "enabled": false},
		],
		"music_sting": &"sting_glitch_reveal",
	},
	{
		"id": &"wst_four_mouths_reveal",
		"display_name": "Sealed Behind Seven Seals",
		"region": &"wild_cliffs",
		"trigger_position": Vector3(45, -4, -85),  # at the eastmost mouth (final vault)
		"trigger_radius": 10.0,
		"iteration_min": 4,
		"iteration_max": -1,
		"required_flags": [],
		"set_flags_on_fire": [&"final_vault_seen"],
		"cinematic_id": &"wst_four_mouths_reveal",
		"timeline": [
			{"event": &"set_letterbox", "enabled": true},
			{"event": &"camera_move", "target": Vector3(45, -2, -82), "duration": 2.0},
			{"event": &"play_dialogue", "speaker": &"sage_proxy", "text": "Seven seals. One for each iteration left.", "duration": 3.5},
			{"event": &"play_dialogue", "speaker": &"sage_proxy", "text": "When the last one breaks, you go through.", "duration": 3.5},
			{"event": &"set_letterbox", "enabled": false},
		],
		"music_sting": &"sting_final_vault_reveal",
	},
	{
		"id": &"wst_listening_tree_change",
		"display_name": "The Chimes Change Keys",
		"region": &"wild_forest",
		"trigger_position": Vector3(-30, 1.5, -20),
		"trigger_radius": 6.0,
		"iteration_min": 5,
		"iteration_max": -1,
		"required_flags": [&"sage_affinity_friend"],
		"set_flags_on_fire": [&"listening_tree_keys_changed"],
		"cinematic_id": &"wst_listening_tree_change",
		"timeline": [
			{"event": &"set_letterbox", "enabled": true},
			{"event": &"play_sfx", "id": &"sfx_chimes_key_shift"},
			{"event": &"play_dialogue", "speaker": &"narrator", "text": "The chimes are in a different key. Sage was here.", "duration": 3.0},
			{"event": &"set_letterbox", "enabled": false},
		],
		"music_sting": &"sting_chime_shift",
	},
	{
		"id": &"wst_campsite_journal",
		"display_name": "Legacy's Journal",
		"region": &"wild_pasture",
		"trigger_position": Vector3(35, 1, 5),
		"trigger_radius": 5.0,
		"iteration_min": 6,
		"iteration_max": -1,
		"required_flags": [],
		"set_flags_on_fire": [&"legacy_journal_found"],
		"cinematic_id": &"wst_campsite_journal",
		"timeline": [
			{"event": &"set_letterbox", "enabled": true},
			{"event": &"camera_move", "target": Vector3(35, 1, 5), "duration": 1.5},
			{"event": &"play_dialogue", "speaker": &"legacy", "text": "I leave my journal here every iteration. You always read it.", "duration": 3.5},
			{"event": &"play_dialogue", "speaker": &"legacy", "text": "You always cry. You always come back.", "duration": 3.5},
			{"event": &"signal", "name": &"reward_granted", "args": [{"type": &"lore_tablet", "id": &"lore_legacy_journal"}]},
			{"event": &"set_letterbox", "enabled": false},
		],
		"music_sting": &"sting_somber",
	},
	{
		"id": &"wst_seals_breaking",
		"display_name": "Seals Breaking",
		"region": &"wild_cliffs",
		"trigger_position": Vector3(45, -4, -85),
		"trigger_radius": 10.0,
		"iteration_min": 8,
		"iteration_max": -1,
		"required_flags": [&"final_vault_seen"],
		"set_flags_on_fire": [&"final_vault_unsealed"],
		"cinematic_id": &"wst_seals_breaking",
		"timeline": [
			{"event": &"set_letterbox", "enabled": true},
			{"event": &"camera_shake", "intensity": 1.2, "duration": 2.0},
			{"event": &"play_sfx", "id": &"sfx_seals_shattering"},
			{"event": &"play_dialogue", "speaker": &"narrator", "text": "The last chain falls.", "duration": 2.5},
			{"event": &"play_dialogue", "speaker": &"narrator", "text": "The Final Vault is open.", "duration": 3.0},
			{"event": &"set_letterbox", "enabled": false},
		],
		"music_sting": &"sting_seals_break",
	},
	{
		"id": &"wst_final_descent",
		"display_name": "The Final Descent",
		"region": &"wild_cliffs",
		"trigger_position": Vector3(45, -4, -85),
		"trigger_radius": 10.0,
		"iteration_min": 9,
		"iteration_max": -1,
		"required_flags": [&"final_vault_unsealed"],
		"set_flags_on_fire": [&"final_descent_started"],
		"cinematic_id": &"wst_final_descent",
		"timeline": [
			{"event": &"set_letterbox", "enabled": true},
			{"event": &"play_dialogue", "speaker": &"sage", "text": "I won't be here when you come back.", "duration": 3.5},
			{"event": &"play_dialogue", "speaker": &"sage", "text": "If you come back at all.", "duration": 3.0},
			{"event": &"play_dialogue", "speaker": &"globbler", "text": "I'll come back.", "duration": 2.5},
			{"event": &"set_letterbox", "enabled": false},
		],
		"music_sting": &"sting_final_descent",
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in TRIGGERS:
		_index[entry["id"]] = entry


static func get_trigger(trigger_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(trigger_id, {})


static func get_all() -> Array[Dictionary]:
	return TRIGGERS.duplicate()


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in TRIGGERS:
		if entry.get("region", &"") == region_id:
			result.append(entry)
	return result


static func get_count() -> int:
	return TRIGGERS.size()
