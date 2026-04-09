class_name WildernessEncounterDatabase
extends RefCounted

## Catalog of wilderness wandering encounters — the rare-but-special NPC
## events that make the wilderness feel alive. See
## `_bmad-output/wilderness/wilderness_bible.md` "Wandering NPC events".
##
## Encounters fire on a probability check when the player enters or
## crosses a region (driven by WanderingNPCManager). Each encounter
## defines its own gating: time-of-day, iteration count, faction state,
## NPC affinity, and weather.

const ENCOUNTERS: Array[Dictionary] = [
	{
		"id": &"sentinel_dusk_patrol",
		"display_name": "Sentinel Patrol",
		"npc_id": &"sentinel",
		"region": &"wild_plateau",
		"path": [
			Vector3(  0.0, 6.0,  10.0),
			Vector3( 12.0, 6.0,  -5.0),
			Vector3( 24.0, 6.0, -20.0),
			Vector3( 36.0, 6.0, -40.0),
		],
		"phase_window": [&"dusk"],
		"weather_blacklist": [&"storm", &"glitch_storm"],
		"iteration_min": 1,
		"chance": 0.65,
		"cooldown_hours": 24,
		"can_interact": true,
		"interaction_type": &"daily_intel_report",
		"dialogue_pool": &"sentinel_wilderness_dusk",
		"music_sting": &"sting_friendly_arrival",
		"description": "Sentinel walks the old road north→south. Hails the player if friendly.",
	},
	{
		"id": &"lost_cache_sprite",
		"display_name": "Lost Cache Sprite",
		"npc_id": &"cache_sprite_lost",
		"region": &"wild_forest",  # Can also fire in plateau and ruins via random_region
		"random_region_pool": [&"wild_plateau", &"wild_forest", &"wild_ruins", &"wild_pasture"],
		"path": [],  # Static; player walks to it
		"phase_window": [&"dawn", &"day", &"dusk"],
		"weather_blacklist": [],
		"iteration_min": 1,
		"chance": 0.40,
		"cooldown_hours": 18,
		"can_interact": true,
		"interaction_type": &"free_sprite",
		"reward": {
			"type": &"loot_drop",
			"items": [
				{"id": &"data_fragment", "count": 3},
				{"id": &"healing_herb", "count": 2},
			],
		},
		"music_sting": &"sting_curious_discovery",
		"description": "A cache sprite stuck in a tree or rock. Free it for a small drop.",
	},
	{
		"id": &"sage_lantern_walk",
		"display_name": "Sage's Lantern Walk",
		"npc_id": &"sage",
		"region": &"wild_river",
		"path": [
			Vector3(-30.0, 0.0,  20.0),
			Vector3(-15.0, 0.0,  10.0),
			Vector3(  0.0, 0.0,   0.0),
			Vector3( 15.0, 0.0, -10.0),
			Vector3( 30.0, 0.0, -20.0),
		],
		"phase_window": [&"night"],
		"weather_blacklist": [&"glitch_storm"],
		"iteration_min": 1,
		"chance": 0.20,  # Rare — once per iteration target
		"cooldown_hours": 168,  # 7 in-game days
		"can_interact": true,
		"interaction_type": &"unique_dialogue",
		"dialogue_pool": &"sage_wilderness_night",
		"prop_attached": &"lantern_warm",
		"music_sting": &"sting_sage_appearance",
		"description": "Sage walks the full river loop with a lantern. Unique dialogue.",
	},
	{
		"id": &"glitcher_messenger",
		"display_name": "Glitcher Messenger",
		"npc_id": &"glitcher_messenger",
		"region": &"wild_river",
		"spawn_point": Vector3(0.0, 0.0, 0.0),  # At the half-bridge
		"path": [],
		"phase_window": [&"dusk", &"night"],
		"weather_blacklist": [&"clear"],  # Only fires in moodier weather
		"iteration_min": 4,  # Late iterations only
		"faction_required": &"glitchers",
		"faction_min_tier": &"acquaintance",
		"chance": 0.55,
		"cooldown_hours": 48,
		"can_interact": true,
		"interaction_type": &"faction_quest_offer",
		"quest_id": &"quest_glitcher_messenger_drop",
		"music_sting": &"sting_glitcher_contact",
		"description": "A Glitcher waits at the half-bridge with a faction quest hook.",
	},
	{
		"id": &"legacy_memorial_visit",
		"display_name": "Legacy at the Spire",
		"npc_id": &"legacy",
		"region": &"wild_ruins",
		"spawn_point": Vector3(0.0, 0.0, 0.0),  # At the tilted spire
		"path": [],
		"phase_window": [&"dawn", &"dusk"],
		"weather_blacklist": [&"storm"],
		"iteration_min": 2,
		"chance": 0.30,
		"cooldown_hours": 72,
		"can_interact": false,  # Cannot be interrupted — atmosphere only
		"interaction_type": &"observe_only",
		"music_sting": &"sting_somber",
		"description": "Legacy walks alone, kneels by the spire, walks back. Cannot be interrupted.",
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in ENCOUNTERS:
		_index[entry["id"]] = entry


static func get_encounter(encounter_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(encounter_id, {})


static func get_all() -> Array[Dictionary]:
	return ENCOUNTERS.duplicate()


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in ENCOUNTERS:
		if entry.get("region", &"") == region_id:
			result.append(entry)
			continue
		var pool: Array = entry.get("random_region_pool", [])
		if pool.has(region_id):
			result.append(entry)
	return result


static func get_count() -> int:
	return ENCOUNTERS.size()
