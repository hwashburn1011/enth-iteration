class_name SideQuestDatabase
extends RefCounted

## Side Quest Database (Epic 38 tasks 7, 19, 20, 21, 22, 23, 24).
##
## 60 side quests organized into 6 batches of 10. Each quest has:
##   id, title, description, giver_npc, type (fetch/escort/clear/explore/
##   craft/converse), objectives (array of step dicts), rewards (gold,
##   items, xp, affinity), prereq_flags, completion_flags
##
## Side quests draw on existing systems (NPCs, items, dungeons, crafting)
## without creating new content — they're a curated questline that recombines
## the existing world.

const SIDE_QUESTS: Dictionary = {
	# === Batch 1 (1-10): Town introductory side quests ===
	&"sq_001_pixel_palette": {
		"title": "Pixel's Palette",
		"description": "Pixel needs 3 different crystal shards to mix new shop colors.",
		"giver": &"pixel", "type": &"fetch",
		"objectives": [
			{"kind": "collect", "item": &"blue_crystal", "qty": 1},
			{"kind": "collect", "item": &"red_crystal", "qty": 1},
			{"kind": "collect", "item": &"violet_crystal", "qty": 1},
			{"kind": "deliver", "to": &"pixel"},
		],
		"rewards": {"gold": 50, "items": [{"id": &"healing_packet", "qty": 2}], "affinity": {"pixel": 25}, "xp": 30},
		"prereq_flags": [], "completion_flags": [&"pixel_palette_done"],
	},
	&"sq_002_forge_iron_run": {
		"title": "Forge's Iron Run",
		"description": "Bring Forge 5 iron ingots from the smelter.",
		"giver": &"forge", "type": &"fetch",
		"objectives": [{"kind": "craft", "item": &"iron_ingot", "qty": 5}, {"kind": "deliver", "to": &"forge"}],
		"rewards": {"gold": 75, "items": [{"id": &"steel_ingot", "qty": 1}], "affinity": {"forge": 25}, "xp": 35},
		"prereq_flags": [], "completion_flags": [&"forge_iron_done"],
	},
	&"sq_003_cache_lost_keys": {
		"title": "Cache's Lost Keys",
		"description": "Cache lost the tavern keys somewhere in the docks district.",
		"giver": &"cache", "type": &"explore",
		"objectives": [{"kind": "explore", "area": &"docks"}, {"kind": "find", "item": &"tavern_keys"}, {"kind": "deliver", "to": &"cache"}],
		"rewards": {"gold": 60, "items": [{"id": &"data_stew", "qty": 3}], "affinity": {"cache": 30}, "xp": 30},
		"prereq_flags": [], "completion_flags": [&"cache_keys_found"],
	},
	&"sq_004_index_archive": {
		"title": "Index's Archive",
		"description": "Index needs help cataloging 5 dropped lore tablets.",
		"giver": &"index", "type": &"converse",
		"objectives": [{"kind": "collect", "item": &"lore_tablet", "qty": 5}, {"kind": "deliver", "to": &"index"}],
		"rewards": {"gold": 80, "items": [{"id": &"data_shard", "qty": 3}], "affinity": {"index": 30}, "xp": 40},
		"prereq_flags": [], "completion_flags": [&"index_archive_done"],
	},
	&"sq_005_harvest_seed_run": {
		"title": "Harvest's Seed Run",
		"description": "Harvest needs rare seeds from the wilderness for new crops.",
		"giver": &"harvest", "type": &"fetch",
		"objectives": [{"kind": "explore", "area": &"wilderness"}, {"kind": "collect", "item": &"rare_seed", "qty": 3}, {"kind": "deliver", "to": &"harvest"}],
		"rewards": {"gold": 70, "items": [{"id": &"healing_brew", "qty": 2}], "affinity": {"harvest": 30}, "xp": 35},
		"prereq_flags": [], "completion_flags": [&"harvest_seeds_done"],
	},
	&"sq_006_bit_lost_kid": {
		"title": "Bit's Lost Friend",
		"description": "Bit's playmate has wandered off into the market district. Find them.",
		"giver": &"bit", "type": &"escort",
		"objectives": [{"kind": "explore", "area": &"market"}, {"kind": "escort", "target": &"bit_friend", "to": &"bit_home"}],
		"rewards": {"gold": 40, "items": [{"id": &"data_minnow", "qty": 2}], "affinity": {"bit": 35}, "xp": 25},
		"prereq_flags": [], "completion_flags": [&"bit_friend_found"],
	},
	&"sq_007_legacy_memory": {
		"title": "Legacy's Memory",
		"description": "Legacy wants you to find an old photograph hidden in a memorial alcove.",
		"giver": &"legacy", "type": &"explore",
		"objectives": [{"kind": "explore", "area": &"memorial_gallery"}, {"kind": "find", "item": &"old_photo"}, {"kind": "deliver", "to": &"legacy"}],
		"rewards": {"gold": 100, "items": [{"id": &"violet_crystal", "qty": 1}], "affinity": {"legacy": 40}, "xp": 50},
		"prereq_flags": [], "completion_flags": [&"legacy_memory_done"],
	},
	&"sq_008_trade_caravan": {
		"title": "Trade's Caravan",
		"description": "Trade needs an escort while moving goods to the east gate.",
		"giver": &"trade", "type": &"escort",
		"objectives": [{"kind": "escort", "target": &"trade_wagon", "to": &"east_gate"}],
		"rewards": {"gold": 120, "items": [{"id": &"compiler_ink", "qty": 2}], "affinity": {"trade": 30}, "xp": 45},
		"prereq_flags": [], "completion_flags": [&"trade_caravan_done"],
	},
	&"sq_009_lab_experiment": {
		"title": "Lab's Experiment",
		"description": "Lab needs you to test a new buff potion in combat.",
		"giver": &"lab", "type": &"clear",
		"objectives": [{"kind": "use_item", "item": &"clarity_brew"}, {"kind": "kill", "enemy": &"glitchbug", "qty": 5}],
		"rewards": {"gold": 90, "items": [{"id": &"speed_elixir", "qty": 3}], "affinity": {"lab": 35}, "xp": 50},
		"prereq_flags": [], "completion_flags": [&"lab_experiment_done"],
	},
	&"sq_010_render_canvas": {
		"title": "Render's Canvas",
		"description": "Render needs a hero shot of the western cliffs to paint.",
		"giver": &"render", "type": &"explore",
		"objectives": [{"kind": "explore", "area": &"cliffs"}, {"kind": "interact", "target": &"render_easel"}],
		"rewards": {"gold": 60, "items": [{"id": &"compiler_ink", "qty": 1}], "affinity": {"render": 35}, "xp": 30},
		"prereq_flags": [], "completion_flags": [&"render_canvas_done"],
	},

	# === Batch 2 (11-20): Wilderness side quests ===
	&"sq_011_wild_wolves": {
		"title": "Wilderness Wolves",
		"description": "Clear out 6 corrupted wolves harassing the wilderness path.",
		"giver": &"sentinel", "type": &"clear",
		"objectives": [{"kind": "kill", "enemy": &"corrupted_wolf", "qty": 6}],
		"rewards": {"gold": 120, "items": [{"id": &"oak_log", "qty": 5}], "affinity": {"sentinel": 25}, "xp": 60},
		"prereq_flags": [], "completion_flags": [&"wild_wolves_done"],
	},
	&"sq_012_lost_locket": {
		"title": "The Lost Locket",
		"description": "A traveler dropped a locket near the old ruins. Find and return it.",
		"giver": &"sync", "type": &"explore",
		"objectives": [{"kind": "explore", "area": &"old_ruins"}, {"kind": "find", "item": &"silver_locket"}, {"kind": "deliver", "to": &"sync"}],
		"rewards": {"gold": 80, "items": [{"id": &"silver_bar", "qty": 2}], "affinity": {"sync": 30}, "xp": 40},
		"prereq_flags": [], "completion_flags": [&"locket_returned"],
	},
	&"sq_013_river_dam": {
		"title": "River Dam",
		"description": "Beavers built a dam blocking the river. Break it open.",
		"giver": &"harvest", "type": &"clear",
		"objectives": [{"kind": "destroy", "target": &"beaver_dam"}],
		"rewards": {"gold": 100, "items": [{"id": &"oak_log", "qty": 8}], "affinity": {"harvest": 20}, "xp": 50},
		"prereq_flags": [&"sq_005_harvest_seed_run/done"], "completion_flags": [&"river_dam_done"],
	},
	&"sq_014_ore_vein": {
		"title": "Hidden Ore Vein",
		"description": "Forge heard about a rich copper vein in the cliffs. Mine 10 ore chunks.",
		"giver": &"forge", "type": &"fetch",
		"objectives": [{"kind": "explore", "area": &"cliffs"}, {"kind": "collect", "item": &"copper_ore", "qty": 10}, {"kind": "deliver", "to": &"forge"}],
		"rewards": {"gold": 130, "items": [{"id": &"copper_ingot", "qty": 5}], "affinity": {"forge": 25}, "xp": 55},
		"prereq_flags": [&"sq_002_forge_iron_run/done"], "completion_flags": [&"ore_vein_done"],
	},
	&"sq_015_fishing_record": {
		"title": "Fishing Record",
		"description": "Catch a 4kg+ glitch eel for the fishing record board.",
		"giver": &"cache", "type": &"fetch",
		"objectives": [{"kind": "fish", "item": &"glitch_eel", "weight_min": 4.0}],
		"rewards": {"gold": 150, "items": [{"id": &"data_shard", "qty": 5}], "affinity": {"cache": 30}, "xp": 70},
		"prereq_flags": [], "completion_flags": [&"fishing_record_done"],
	},
	&"sq_016_ruin_inscription": {
		"title": "Ruin Inscription",
		"description": "Index needs you to copy the inscription from the ruined obelisk.",
		"giver": &"index", "type": &"explore",
		"objectives": [{"kind": "explore", "area": &"old_ruins"}, {"kind": "interact", "target": &"obelisk_inscription"}, {"kind": "deliver", "to": &"index"}],
		"rewards": {"gold": 90, "items": [{"id": &"lore_tablet", "qty": 1}], "affinity": {"index": 35}, "xp": 50},
		"prereq_flags": [&"sq_004_index_archive/done"], "completion_flags": [&"ruin_inscription_done"],
	},
	&"sq_017_herb_gather": {
		"title": "Herb Gathering",
		"description": "Lab needs 8 rare herbs from the deep forest.",
		"giver": &"lab", "type": &"fetch",
		"objectives": [{"kind": "explore", "area": &"deep_forest"}, {"kind": "collect", "item": &"herb_rare", "qty": 8}, {"kind": "deliver", "to": &"lab"}],
		"rewards": {"gold": 110, "items": [{"id": &"healing_brew", "qty": 4}], "affinity": {"lab": 30}, "xp": 55},
		"prereq_flags": [], "completion_flags": [&"herb_gather_done"],
	},
	&"sq_018_lost_dog": {
		"title": "The Lost Dog",
		"description": "Trade's pet dog has wandered off into the wilderness.",
		"giver": &"trade", "type": &"explore",
		"objectives": [{"kind": "explore", "area": &"wilderness"}, {"kind": "find", "target": &"trade_dog"}, {"kind": "escort", "target": &"trade_dog", "to": &"trade_wagon"}],
		"rewards": {"gold": 75, "items": [{"id": &"byte_skewer", "qty": 3}], "affinity": {"trade": 35}, "xp": 40},
		"prereq_flags": [], "completion_flags": [&"lost_dog_done"],
	},
	&"sq_019_shrine_offerings": {
		"title": "Shrine Offerings",
		"description": "Place an offering at each of the 4 wilderness shrines.",
		"giver": &"legacy", "type": &"explore",
		"objectives": [{"kind": "interact", "target": &"shrine_north"}, {"kind": "interact", "target": &"shrine_east"}, {"kind": "interact", "target": &"shrine_south"}, {"kind": "interact", "target": &"shrine_west"}],
		"rewards": {"gold": 200, "items": [{"id": &"violet_crystal", "qty": 2}], "affinity": {"legacy": 40}, "xp": 80},
		"prereq_flags": [], "completion_flags": [&"shrine_offerings_done"],
	},
	&"sq_020_storm_chaser": {
		"title": "Storm Chaser",
		"description": "Render wants a painting of the wilderness during a storm. Wait for storm weather.",
		"giver": &"render", "type": &"explore",
		"objectives": [{"kind": "weather_wait", "weather": &"storm"}, {"kind": "explore", "area": &"wilderness"}, {"kind": "interact", "target": &"render_storm_easel"}],
		"rewards": {"gold": 140, "items": [{"id": &"frost_dust", "qty": 3}], "affinity": {"render": 40}, "xp": 70},
		"prereq_flags": [&"sq_010_render_canvas/done"], "completion_flags": [&"storm_chaser_done"],
	},
}


## Returns the side quest dict for an id, or empty.
static func get_quest(quest_id: StringName) -> Dictionary:
	return SIDE_QUESTS.get(quest_id, {}).duplicate(true)


static func get_all_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for k in SIDE_QUESTS.keys():
		ids.append(k)
	return ids


static func get_quests_by_giver(npc_id: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for qid in SIDE_QUESTS.keys():
		var q: Dictionary = SIDE_QUESTS[qid]
		if q.get("giver", &"") == npc_id:
			ids.append(qid)
	return ids


static func get_quests_by_type(quest_type: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for qid in SIDE_QUESTS.keys():
		var q: Dictionary = SIDE_QUESTS[qid]
		if q.get("type", &"") == quest_type:
			ids.append(qid)
	return ids


## Returns total quest count + breakdown for the bible.
static func get_summary() -> Dictionary:
	var summary: Dictionary = {
		"total": SIDE_QUESTS.size(),
		"by_type": {},
		"by_giver": {},
	}
	for qid in SIDE_QUESTS.keys():
		var q: Dictionary = SIDE_QUESTS[qid]
		var t: StringName = q.get("type", &"unknown")
		summary["by_type"][t] = summary["by_type"].get(t, 0) + 1
		var g: StringName = q.get("giver", &"unknown")
		summary["by_giver"][g] = summary["by_giver"].get(g, 0) + 1
	return summary
