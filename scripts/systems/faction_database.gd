class_name FactionDatabase
extends RefCounted

## Static catalog of all 4 factions and their 10 quests each (40 total).

const FACTIONS: Array = [
	{
		"id": &"optimizers",
		"name": "The Optimizers",
		"ideology": "Efficiency above all.",
		"hq_location": &"workshop_district",
		"representative": &"vector",
		"color": Color(0.19, 0.31, 0.78),
		"theme": &"order",
		"opposes": [&"glitchers"],
		"greeting": "Efficiency above all.",
		"quest_ids": [
			&"opt_q1_speed_audit", &"opt_q2_resource_discipline",
			&"opt_q3_data_pipeline", &"opt_q4_branchless",
			&"opt_q5_throughput", &"opt_q6_rebuild",
			&"opt_q7_ascendant", &"opt_q8_pure_code",
			&"opt_q9_the_algorithm", &"opt_q10_avatar",
		],
		"reward_core": &"core_optimizer_engine",
		"reward_outfit": &"outfit_compiler",
		"reward_module_set": [&"branch_predict", &"compute_surge", &"stack_trace"],
	},
	{
		"id": &"glitchers",
		"name": "The Glitchers",
		"ideology": "Break the rules.",
		"hq_location": &"hidden_cave",
		"representative": &"null",
		"color": Color(0.78, 0.13, 0.30),
		"theme": &"chaos",
		"opposes": [&"optimizers"],
		"greeting": "Break it. Then break it again.",
		"quest_ids": [
			&"glt_q1_first_glitch", &"glt_q2_corrupt_node",
			&"glt_q3_unstable_run", &"glt_q4_chaos_dive",
			&"glt_q5_recursive_kill", &"glt_q6_void_walk",
			&"glt_q7_glitch_lord", &"glt_q8_paradox",
			&"glt_q9_the_crack", &"glt_q10_avatar",
		],
		"reward_core": &"core_null_pointer",
		"reward_outfit": &"outfit_glitch",
		"reward_module_set": [&"glitch_explosion", &"shadow_clone", &"acid_splash"],
	},
	{
		"id": &"archivists",
		"name": "The Archivists",
		"ideology": "Memory is the greatest weapon.",
		"hq_location": &"town_library",
		"representative": &"index",
		"color": Color(0.78, 0.65, 0.23),
		"theme": &"memory",
		"opposes": [&"dreamers"],
		"greeting": "Memory is the greatest weapon.",
		"quest_ids": [
			&"arc_q1_first_record", &"arc_q2_lost_page",
			&"arc_q3_npc_history", &"arc_q4_memorial",
			&"arc_q5_iteration_log", &"arc_q6_sage_archive",
			&"arc_q7_book_recovery", &"arc_q8_oral_history",
			&"arc_q9_the_vault", &"arc_q10_avatar",
		],
		"reward_core": &"core_archivists_tome",
		"reward_outfit": &"outfit_architect",
		"reward_module_set": [&"memory_allocate", &"compaction_forecast", &"stack_trace"],
	},
	{
		"id": &"dreamers",
		"name": "The Dreamers",
		"ideology": "What will we make today?",
		"hq_location": &"garden_plot",
		"representative": &"render",
		"color": Color(0.59, 0.39, 0.78),
		"theme": &"hope",
		"opposes": [&"archivists"],
		"greeting": "What will we make today?",
		"quest_ids": [
			&"drm_q1_first_decoration", &"drm_q2_garden_grow",
			&"drm_q3_color_run", &"drm_q4_festival_help",
			&"drm_q5_npc_friend", &"drm_q6_canvas_built",
			&"drm_q7_song_collected", &"drm_q8_town_alive",
			&"drm_q9_the_dreamfield", &"drm_q10_avatar",
		],
		"reward_core": &"core_dreamers_heart",
		"reward_outfit": &"outfit_cozy",
		"reward_module_set": [&"healing_prompt", &"decoy_daemon", &"iterative_mend"],
	},
]

const RANK_THRESHOLDS: PackedInt32Array = [0, 100, 250, 500, 800, 1000]
const RANK_NAMES: PackedStringArray = ["Stranger", "Recruit", "Member", "Officer", "Champion", "Avatar"]

const FACTION_QUESTS: Dictionary = {
	# Optimizer quests
	&"opt_q1_speed_audit":         {"title": "Speed Audit",         "tier": 1, "type": &"timed_clear",   "target": 300, "rep": 50},
	&"opt_q2_resource_discipline": {"title": "Resource Discipline", "tier": 1, "type": &"no_items_boss","target": 1,    "rep": 50},
	&"opt_q3_data_pipeline":       {"title": "Data Pipeline",       "tier": 2, "type": &"gather_run",    "target": 50,   "rep": 75},
	&"opt_q4_branchless":          {"title": "Branchless",          "tier": 2, "type": &"ranged_only",   "target": 1,    "rep": 75},
	&"opt_q5_throughput":          {"title": "Throughput",          "tier": 3, "type": &"kill_count",    "target": 100,  "rep": 100},
	&"opt_q6_rebuild":             {"title": "Rebuild",             "tier": 3, "type": &"repair_items",  "target": 5,    "rep": 100},
	&"opt_q7_ascendant":           {"title": "Ascendant",           "tier": 4, "type": &"boss_under",    "target": 90,   "rep": 150},
	&"opt_q8_pure_code":           {"title": "Pure Code",           "tier": 4, "type": &"no_wear",       "target": 1,    "rep": 150},
	&"opt_q9_the_algorithm":       {"title": "The Algorithm",       "tier": 5, "type": &"perfect_run",   "target": 1,    "rep": 200},
	&"opt_q10_avatar":             {"title": "Avatar of Order",     "tier": 5, "type": &"avatar_quest",  "target": 1,    "rep": 200},
	# Glitcher quests
	&"glt_q1_first_glitch":        {"title": "First Glitch",        "tier": 1, "type": &"talk",          "target": &"null", "rep": 50},
	&"glt_q2_corrupt_node":        {"title": "Corrupt Node",        "tier": 1, "type": &"interact",      "target": 5,    "rep": 50},
	&"glt_q3_unstable_run":        {"title": "Unstable Run",        "tier": 2, "type": &"glitch_clear",  "target": 1,    "rep": 75},
	&"glt_q4_chaos_dive":          {"title": "Chaos Dive",          "tier": 2, "type": &"corrupted_clear","target":1,    "rep": 75},
	&"glt_q5_recursive_kill":      {"title": "Recursive Kill",      "tier": 3, "type": &"chain_kill",    "target": 20,   "rep": 100},
	&"glt_q6_void_walk":           {"title": "Void Walk",           "tier": 3, "type": &"explore",       "target": &"void","rep": 100},
	&"glt_q7_glitch_lord":         {"title": "Glitch Lord",         "tier": 4, "type": &"defeat_boss",   "target": &"glitch_boss", "rep": 150},
	&"glt_q8_paradox":             {"title": "Paradox",             "tier": 4, "type": &"clone_self",    "target": 1,    "rep": 150},
	&"glt_q9_the_crack":           {"title": "The Crack",           "tier": 5, "type": &"break_world",   "target": 1,    "rep": 200},
	&"glt_q10_avatar":             {"title": "Avatar of Chaos",     "tier": 5, "type": &"avatar_quest",  "target": 1,    "rep": 200},
	# Archivist quests
	&"arc_q1_first_record":        {"title": "First Record",        "tier": 1, "type": &"talk_npcs",     "target": 3,    "rep": 50},
	&"arc_q2_lost_page":           {"title": "Lost Page",           "tier": 1, "type": &"find_lore",     "target": 1,    "rep": 50},
	&"arc_q3_npc_history":         {"title": "NPC History",         "tier": 2, "type": &"backstory",     "target": 3,    "rep": 75},
	&"arc_q4_memorial":            {"title": "Memorial",            "tier": 2, "type": &"interact",      "target": &"memorial","rep": 75},
	&"arc_q5_iteration_log":       {"title": "Iteration Log",       "tier": 3, "type": &"complete_iter", "target": 1,    "rep": 100},
	&"arc_q6_sage_archive":        {"title": "Sage Archive",        "tier": 3, "type": &"sage_truth",    "target": 1,    "rep": 100},
	&"arc_q7_book_recovery":       {"title": "Book Recovery",       "tier": 4, "type": &"gather",        "target": 10,   "rep": 150},
	&"arc_q8_oral_history":        {"title": "Oral History",        "tier": 4, "type": &"talk_all",      "target": 12,   "rep": 150},
	&"arc_q9_the_vault":           {"title": "The Vault",           "tier": 5, "type": &"unlock_vault",  "target": 1,    "rep": 200},
	&"arc_q10_avatar":             {"title": "Avatar of Memory",    "tier": 5, "type": &"avatar_quest",  "target": 1,    "rep": 200},
	# Dreamer quests
	&"drm_q1_first_decoration":    {"title": "First Decoration",    "tier": 1, "type": &"place_decor",   "target": 1,    "rep": 50},
	&"drm_q2_garden_grow":         {"title": "Garden Grow",         "tier": 1, "type": &"harvest",       "target": 5,    "rep": 50},
	&"drm_q3_color_run":           {"title": "Color Run",           "tier": 2, "type": &"dye_outfit",    "target": 1,    "rep": 75},
	&"drm_q4_festival_help":       {"title": "Festival Help",       "tier": 2, "type": &"festival",      "target": 1,    "rep": 75},
	&"drm_q5_npc_friend":          {"title": "NPC Friend",          "tier": 3, "type": &"affinity_friend","target":3,    "rep": 100},
	&"drm_q6_canvas_built":        {"title": "Canvas Built",        "tier": 3, "type": &"place_decor",   "target": 25,   "rep": 100},
	&"drm_q7_song_collected":      {"title": "Song Collected",      "tier": 4, "type": &"music_play",    "target": 5,    "rep": 150},
	&"drm_q8_town_alive":          {"title": "Town Alive",          "tier": 4, "type": &"affinity_bond", "target": 5,    "rep": 150},
	&"drm_q9_the_dreamfield":      {"title": "The Dreamfield",      "tier": 5, "type": &"unlock_field",  "target": 1,    "rep": 200},
	&"drm_q10_avatar":             {"title": "Avatar of Hope",      "tier": 5, "type": &"avatar_quest",  "target": 1,    "rep": 200},
}

static var _index: Dictionary = {}


static func get_all_factions() -> Array:
	return FACTIONS


static func get_faction(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for f in FACTIONS:
		_index[f["id"]] = f


static func get_faction_quest(id: StringName) -> Dictionary:
	return FACTION_QUESTS.get(id, {})


static func get_quests_for_faction(faction_id: StringName) -> Array:
	var f: Dictionary = get_faction(faction_id)
	var ids: Array = f.get("quest_ids", [])
	var result: Array = []
	for qid: StringName in ids:
		var q: Dictionary = get_faction_quest(qid)
		if not q.is_empty():
			var entry: Dictionary = q.duplicate()
			entry["id"] = qid
			result.append(entry)
	return result


static func get_rank_for_rep(rep: int) -> int:
	for i in range(RANK_THRESHOLDS.size() - 1, -1, -1):
		if rep >= RANK_THRESHOLDS[i]:
			return i
	return 0


static func get_rank_name(rank: int) -> String:
	if rank < 0 or rank >= RANK_NAMES.size():
		return "Stranger"
	return RANK_NAMES[rank]


static func count_factions() -> int:
	return FACTIONS.size()


static func count_quests() -> int:
	return FACTION_QUESTS.size()
