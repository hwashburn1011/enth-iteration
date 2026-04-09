class_name ShrineBuffDatabase
extends RefCounted

## Buffs grantable by the Shrine of the Loop. Each entry has:
##   - id, display_name, description
##   - tier (1=common, 2=uncommon, 3=rare, 4=epic)
##   - duration_minutes (in-game minutes)
##   - stat_modifiers (Dictionary of stat → value)
##   - vfx_id for the buff aura
##
## The shrine rolls from a pool weighted by offering tier — higher
## quality offerings unlock higher-tier buff rolls.

const BUFFS: Array[Dictionary] = [
	# Tier 1 — common
	{
		"id": &"shrine_swift_step",
		"display_name": "Swift Step",
		"description": "+10% movement speed for 30 in-game minutes.",
		"tier": 1,
		"duration_minutes": 30,
		"stat_modifiers": {&"move_speed_mult": 1.10},
		"vfx_id": &"vfx_speed_trail",
	},
	{
		"id": &"shrine_keen_eye",
		"display_name": "Keen Eye",
		"description": "+20% loot drop chance for 30 in-game minutes.",
		"tier": 1,
		"duration_minutes": 30,
		"stat_modifiers": {&"loot_chance_mult": 1.20},
		"vfx_id": &"vfx_eye_glow",
	},
	{
		"id": &"shrine_steady_breath",
		"display_name": "Steady Breath",
		"description": "+5% max health for 30 in-game minutes.",
		"tier": 1,
		"duration_minutes": 30,
		"stat_modifiers": {&"max_health_mult": 1.05},
		"vfx_id": &"vfx_calm_aura",
	},
	# Tier 2 — uncommon
	{
		"id": &"shrine_focused_mind",
		"display_name": "Focused Mind",
		"description": "+15% ability cooldown rate for 30 in-game minutes.",
		"tier": 2,
		"duration_minutes": 30,
		"stat_modifiers": {&"cooldown_rate_mult": 1.15},
		"vfx_id": &"vfx_focus_glow",
	},
	{
		"id": &"shrine_warm_blood",
		"display_name": "Warm Blood",
		"description": "+25% healing received for 30 in-game minutes.",
		"tier": 2,
		"duration_minutes": 30,
		"stat_modifiers": {&"healing_received_mult": 1.25},
		"vfx_id": &"vfx_warm_pulse",
	},
	{
		"id": &"shrine_river_grace",
		"display_name": "River Grace",
		"description": "+30% dodge chance for 30 in-game minutes.",
		"tier": 2,
		"duration_minutes": 30,
		"stat_modifiers": {&"dodge_chance_add": 0.30},
		"vfx_id": &"vfx_water_shimmer",
	},
	# Tier 3 — rare
	{
		"id": &"shrine_loop_blessing",
		"display_name": "The Loop's Blessing",
		"description": "+10% to ALL stats for 30 in-game minutes.",
		"tier": 3,
		"duration_minutes": 30,
		"stat_modifiers": {&"all_stats_mult": 1.10},
		"vfx_id": &"vfx_loop_blessing",
	},
	{
		"id": &"shrine_iron_will",
		"display_name": "Iron Will",
		"description": "+50% damage resistance for 30 in-game minutes.",
		"tier": 3,
		"duration_minutes": 30,
		"stat_modifiers": {&"damage_resist_mult": 1.50},
		"vfx_id": &"vfx_iron_aura",
	},
	# Tier 4 — epic
	{
		"id": &"shrine_glitcher_favor",
		"display_name": "Glitcher's Favor",
		"description": "Next attack guaranteed crit for 30 in-game minutes.",
		"tier": 4,
		"duration_minutes": 30,
		"stat_modifiers": {&"next_crit_guaranteed": 1.0, &"crit_damage_mult": 2.50},
		"vfx_id": &"vfx_glitch_aura_purple",
	},
]

# Offering tier determines max buff tier rollable
const OFFERING_TIER_TABLE: Dictionary = {
	&"healing_herb":     1,
	&"wild_mint":        1,
	&"echo_feather":     1,
	&"river_fish":       2,
	&"forest_mushroom":  2,
	&"iron_ingot":       2,
	&"glow_moss":        3,
	&"sages_mint":       3,
	&"voidshark_fillet": 4,
	&"compiled_tuna":    4,
	&"glitcher_token":   4,
}

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in BUFFS:
		_index[entry["id"]] = entry


static func get_buff(buff_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(buff_id, {})


static func get_all() -> Array[Dictionary]:
	return BUFFS.duplicate()


static func get_pool_for_tier(max_tier: int) -> Array[Dictionary]:
	## Returns the buffs eligible for a roll given the offering's max tier.
	## Higher offerings include all lower-tier buffs in the pool too, but
	## with lower weight so the rare ones still feel rare.
	var result: Array[Dictionary] = []
	for entry: Dictionary in BUFFS:
		if int(entry.get("tier", 1)) <= max_tier:
			result.append(entry)
	return result


static func get_offering_tier(item_id: StringName) -> int:
	return OFFERING_TIER_TABLE.get(item_id, 0)


static func get_buff_count() -> int:
	return BUFFS.size()
