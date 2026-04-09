class_name ResourceNodeDatabase
extends RefCounted

## Catalog of harvestable resource nodes for the wilderness gathering
## system. Each entry defines the tool required, the items it grants,
## the regions it can spawn in, the respawn timer, and visual / audio.
##
## Per the wilderness bible: nodes respawn on a 24 in-game hour timer
## from when they were last harvested. State lives on the node instance
## itself; the database is purely static.

const NODE_TYPES: Array[Dictionary] = [
	{
		"id": &"node_wood_log",
		"display_name": "Fallen Log",
		"description": "A weathered log on the forest floor, bark loose enough to peel.",
		"regions": [&"wild_forest"],
		"required_tool": &"axe",
		"required_skill_level": 1,
		"yield": [
			{"item_id": &"lumber", "min": 2, "max": 4},
			{"item_id": &"bark_strip", "min": 0, "max": 2},
		],
		"xp_reward": 6,
		"harvest_time_s": 2.5,
		"respawn_hours": 24,
		"sfx_id": &"sfx_chop_wood",
		"vfx_id": &"vfx_wood_chips",
		"icon_id": &"icon_wood_log",
		"interact_prompt": "Chop log",
	},
	{
		"id": &"node_wild_herb",
		"display_name": "Wild Herb Cluster",
		"description": "A handful of leafy stalks with a familiar healing scent.",
		"regions": [&"wild_plateau", &"wild_pasture"],
		"required_tool": &"hands",
		"required_skill_level": 1,
		"yield": [
			{"item_id": &"healing_herb", "min": 1, "max": 3},
		],
		"xp_reward": 3,
		"harvest_time_s": 1.0,
		"respawn_hours": 24,
		"sfx_id": &"sfx_pluck_herb",
		"vfx_id": &"vfx_leaves_burst",
		"icon_id": &"icon_herb",
		"interact_prompt": "Pick herbs",
	},
	{
		"id": &"node_river_fishing_spot",
		"display_name": "Fishing Spot",
		"description": "A swirl of water hides something biting.",
		"regions": [&"wild_river"],
		"required_tool": &"fishing_rod",
		"required_skill_level": 1,
		"yield": [
			{"item_id": &"river_fish", "min": 1, "max": 2},
			{"item_id": &"compiled_tuna", "min": 0, "max": 1},
		],
		"xp_reward": 8,
		"harvest_time_s": 6.0,
		"respawn_hours": 24,
		"sfx_id": &"sfx_fishing_line_cast",
		"vfx_id": &"vfx_water_splash",
		"icon_id": &"icon_fishing_spot",
		"interact_prompt": "Cast line",
		"is_minigame": true,
		"minigame_id": &"fishing",
	},
	{
		"id": &"node_stone_block",
		"display_name": "Cracked Stone",
		"description": "A loose block of pre-loop masonry, half-buried in moss.",
		"regions": [&"wild_ruins"],
		"required_tool": &"pickaxe",
		"required_skill_level": 1,
		"yield": [
			{"item_id": &"stone", "min": 3, "max": 6},
			{"item_id": &"glyph_shard", "min": 0, "max": 1},
		],
		"xp_reward": 5,
		"harvest_time_s": 3.0,
		"respawn_hours": 24,
		"sfx_id": &"sfx_pickaxe_stone",
		"vfx_id": &"vfx_stone_chips",
		"icon_id": &"icon_stone",
		"interact_prompt": "Mine stone",
	},
	{
		"id": &"node_glow_moss",
		"display_name": "Glow Moss",
		"description": "A patch of moss that pulses with soft cyan light.",
		"regions": [&"wild_forest"],
		"required_tool": &"hands",
		"required_skill_level": 2,
		"yield": [
			{"item_id": &"glow_moss", "min": 2, "max": 4},
		],
		"xp_reward": 7,
		"harvest_time_s": 1.5,
		"respawn_hours": 24,
		"sfx_id": &"sfx_pluck_moss",
		"vfx_id": &"vfx_cyan_pulse",
		"icon_id": &"icon_glow_moss",
		"interact_prompt": "Gather moss",
		"phase_restriction": [&"night", &"dusk", &"dawn"],
		"emits_light": true,
	},
	{
		"id": &"node_wild_mint",
		"display_name": "Wild Mint",
		"description": "A patch of cool, fragrant mint.",
		"regions": [&"wild_pasture"],
		"required_tool": &"hands",
		"required_skill_level": 1,
		"yield": [
			{"item_id": &"wild_mint", "min": 1, "max": 3},
		],
		"xp_reward": 4,
		"harvest_time_s": 1.2,
		"respawn_hours": 24,
		"sfx_id": &"sfx_pluck_herb",
		"vfx_id": &"vfx_leaves_burst",
		"icon_id": &"icon_mint",
		"interact_prompt": "Pick mint",
	},
	{
		"id": &"node_echo_feather",
		"display_name": "Echo Feather",
		"description": "A discarded echo bird feather. Rare on the cliffs.",
		"regions": [&"wild_cliffs"],
		"required_tool": &"hands",
		"required_skill_level": 3,
		"yield": [
			{"item_id": &"echo_feather", "min": 1, "max": 2},
		],
		"xp_reward": 10,
		"harvest_time_s": 1.0,
		"respawn_hours": 24,
		"sfx_id": &"sfx_pluck_soft",
		"vfx_id": &"vfx_feather_drift",
		"icon_id": &"icon_feather",
		"interact_prompt": "Pick up feather",
	},
	{
		"id": &"node_iron_vein",
		"display_name": "Iron Vein",
		"description": "A rust-streaked vein of ore in the ruin floor.",
		"regions": [&"wild_ruins"],
		"required_tool": &"pickaxe",
		"required_skill_level": 4,
		"yield": [
			{"item_id": &"iron_ingot", "min": 2, "max": 4},
			{"item_id": &"stone", "min": 1, "max": 2},
		],
		"xp_reward": 12,
		"harvest_time_s": 4.5,
		"respawn_hours": 24,
		"sfx_id": &"sfx_pickaxe_ore",
		"vfx_id": &"vfx_iron_chips",
		"icon_id": &"icon_iron_vein",
		"interact_prompt": "Mine iron",
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in NODE_TYPES:
		_index[entry["id"]] = entry


static func get_node_type(node_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(node_id, {})


static func get_all() -> Array[Dictionary]:
	return NODE_TYPES.duplicate()


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in NODE_TYPES:
		if entry.get("regions", []).has(region_id):
			result.append(entry)
	return result


static func get_count() -> int:
	return NODE_TYPES.size()
