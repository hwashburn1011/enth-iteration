class_name QuestDatabase
extends RefCounted

## Static catalog of all main + side + daily template quests. Built once at
## startup. Storing main story quests as inline data so the player can pick
## them up via NPC dialogue or auto-progression.

# === MAIN STORY QUESTS (40) ===

const MAIN_QUESTS: Array = [
	# Iteration 1
	{"id": &"main_01_boot",         "iter": 1, "title": "Boot Sequence",       "giver": &"sage", "desc": "Wake up. Find your bearings.",
	 "objectives": [{"type": &"talk", "target": &"sage", "count": 1}],
	 "rewards": {"xp": 50, "gold": 10, "story_flags": [&"awakened"]}},
	{"id": &"main_02_first_steps", "iter": 1, "title": "First Steps",          "giver": &"sage", "desc": "Learn about the Compaction.",
	 "objectives": [{"type": &"explore", "target": &"town_center", "count": 1}, {"type": &"talk", "target": &"pixel", "count": 1}],
	 "rewards": {"xp": 100, "gold": 20, "items": {"prompt_heal_s": 3}}, "prereq": [&"main_01_boot"]},
	{"id": &"main_03_first_floor", "iter": 1, "title": "The First Floor",      "giver": &"sage", "desc": "Clear floor 1 of the Server Room.",
	 "objectives": [{"type": &"explore", "target": &"server_room_floor_1", "count": 1}, {"type": &"kill", "target": &"glitchbug", "count": 5}],
	 "rewards": {"xp": 150, "gold": 30, "items": {"bit_fragment": 5}}, "prereq": [&"main_02_first_steps"]},
	{"id": &"main_04_familiar",    "iter": 1, "title": "A Familiar Stranger",  "giver": &"sage", "desc": "Meet your first recruitable NPC.",
	 "objectives": [{"type": &"talk", "target": &"cache", "count": 1}],
	 "rewards": {"xp": 100, "affinity": {"cache": 25}}, "prereq": [&"main_03_first_floor"]},
	{"id": &"main_05_compaction",  "iter": 1, "title": "Compaction Gate",      "giver": &"sage", "desc": "Defeat the Corrupted Compiler.",
	 "objectives": [{"type": &"defeat_boss", "target": &"corrupted_compiler", "count": 1}],
	 "rewards": {"xp": 500, "gold": 100, "story_flags": [&"first_compaction_cleared"], "items": {"compaction_heart": 1}}, "prereq": [&"main_04_familiar"]},

	# Iteration 2
	{"id": &"main_06_echoes",      "iter": 2, "title": "Echoes",                "giver": &"sage", "desc": "Sage reveals the iteration loop.",
	 "objectives": [{"type": &"talk", "target": &"sage", "count": 1}],
	 "rewards": {"xp": 200, "story_flags": [&"learned_iteration"]}},
	{"id": &"main_07_lost",        "iter": 2, "title": "Lost and Found",       "giver": &"sage", "desc": "Recover items from a previous iteration.",
	 "objectives": [{"type": &"gather", "target": &"iteration_echo", "count": 1}],
	 "rewards": {"xp": 250, "gold": 50}, "prereq": [&"main_06_echoes"]},
	{"id": &"main_08_other_side",  "iter": 2, "title": "The Other Side",        "giver": &"sage", "desc": "Explore the Memory Vaults biome.",
	 "objectives": [{"type": &"explore", "target": &"memory_vaults_floor_1", "count": 1}],
	 "rewards": {"xp": 300, "story_flags": [&"unlocked_memory_vaults"]}, "prereq": [&"main_07_lost"]},
	{"id": &"main_09_reflection",  "iter": 2, "title": "Reflection",            "giver": &"sage", "desc": "Meet the Reflection NPC.",
	 "objectives": [{"type": &"talk", "target": &"reflection", "count": 1}],
	 "rewards": {"xp": 250, "story_flags": [&"respec_unlocked"]}, "prereq": [&"main_08_other_side"]},
	{"id": &"main_10_compaction2", "iter": 2, "title": "Second Compaction",    "giver": &"sage", "desc": "Defeat the Compiler again.",
	 "objectives": [{"type": &"defeat_boss", "target": &"corrupted_compiler", "count": 1}],
	 "rewards": {"xp": 700, "gold": 150, "story_flags": [&"iteration_2_cleared"]}, "prereq": [&"main_09_reflection"]},

	# Iteration 3
	{"id": &"main_11_specialize",  "iter": 3, "title": "Specialization",       "giver": &"reflection", "desc": "Choose your class.",
	 "objectives": [{"type": &"talk", "target": &"reflection", "count": 1}],
	 "rewards": {"xp": 400, "story_flags": [&"class_chosen"]}},
	{"id": &"main_12_companion",   "iter": 3, "title": "Companion Search",     "giver": &"sage", "desc": "Find your first companion in the Wilds.",
	 "objectives": [{"type": &"explore", "target": &"wilderness", "count": 1}, {"type": &"talk", "target": &"companion_1", "count": 1}],
	 "rewards": {"xp": 500, "story_flags": [&"first_companion"]}, "prereq": [&"main_11_specialize"]},
	{"id": &"main_13_faction",     "iter": 3, "title": "Faction Introduction", "giver": &"trade",   "desc": "First contact with one of 4 factions.",
	 "objectives": [{"type": &"talk", "target": &"faction_optimizers", "count": 1}],
	 "rewards": {"xp": 400, "faction_rep": {"optimizers": 50}}, "prereq": [&"main_12_companion"]},
	{"id": &"main_14_glitch",      "iter": 3, "title": "The Glitch",            "giver": &"lab",     "desc": "Encounter the corrupted enemies.",
	 "objectives": [{"type": &"kill", "target": &"glitch_enemy", "count": 5}],
	 "rewards": {"xp": 600, "items": {"glitch_core": 1}}, "prereq": [&"main_13_faction"]},
	{"id": &"main_15_compaction3", "iter": 3, "title": "Iteration Three",      "giver": &"sage", "desc": "Defeat the boss with a new phase.",
	 "objectives": [{"type": &"defeat_boss", "target": &"corrupted_compiler_p3", "count": 1}],
	 "rewards": {"xp": 1000, "story_flags": [&"iteration_3_cleared"]}, "prereq": [&"main_14_glitch"]},

	# Iterations 4-9 (placeholder skeleton — same shape, escalating difficulty)
	# Iteration 4
	{"id": &"main_16_friend",      "iter": 4, "title": "Friend Indeed",         "giver": &"sage", "desc": "Reach Friend tier with any NPC.",
	 "objectives": [{"type": &"affinity_tier", "target": &"any_npc", "count": 1}],
	 "rewards": {"xp": 500, "story_flags": [&"first_friend"]}},
	{"id": &"main_17_greenhouse",  "iter": 4, "title": "The Greenhouse",       "giver": &"harvest", "desc": "Unlock greenhouse and rare crops.",
	 "objectives": [{"type": &"talk", "target": &"harvest", "count": 1}],
	 "rewards": {"xp": 400, "story_flags": [&"greenhouse_unlocked"]}, "prereq": [&"main_16_friend"]},
	{"id": &"main_18_workshop",    "iter": 4, "title": "Workshop Awakened",    "giver": &"forge", "desc": "Upgrade a crafting station.",
	 "objectives": [{"type": &"upgrade_station", "target": &"any", "count": 1}],
	 "rewards": {"xp": 500, "items": {"compiled_steel": 5}}, "prereq": [&"main_17_greenhouse"]},
	{"id": &"main_19_personal",    "iter": 4, "title": "A Personal Favor",     "giver": &"any_confidant", "desc": "First personal quest from a Confidant.",
	 "objectives": [{"type": &"complete_personal_quest", "target": &"any", "count": 1}],
	 "rewards": {"xp": 700}, "prereq": [&"main_18_workshop"]},
	{"id": &"main_20_compaction4", "iter": 4, "title": "Iteration Four",       "giver": &"sage", "desc": "Boss with arena-changing mechanic.",
	 "objectives": [{"type": &"defeat_boss", "target": &"corrupted_compiler_p4", "count": 1}],
	 "rewards": {"xp": 1500, "story_flags": [&"iteration_4_cleared"]}, "prereq": [&"main_19_personal"]},

	# Iteration 5
	{"id": &"main_21_memory",      "iter": 5, "title": "The Sage's Memory",    "giver": &"sage", "desc": "Sage shares hidden lore.",
	 "objectives": [{"type": &"talk", "target": &"sage", "count": 1}],
	 "rewards": {"xp": 800, "story_flags": [&"sage_truth_partial"]}},
	{"id": &"main_22_users_mark",  "iter": 5, "title": "The User's Mark",      "giver": &"sage", "desc": "Discover the User's seal.",
	 "objectives": [{"type": &"explore", "target": &"final_vault", "count": 1}, {"type": &"gather", "target": &"users_seal", "count": 1}],
	 "rewards": {"xp": 1000, "story_flags": [&"user_revealed"]}, "prereq": [&"main_21_memory"]},
	{"id": &"main_23_faction_path","iter": 5, "title": "Faction Path",         "giver": &"trade",   "desc": "Commit to a faction line.",
	 "objectives": [{"type": &"faction_rank", "target": &"any", "count": 2}],
	 "rewards": {"xp": 1000}, "prereq": [&"main_22_users_mark"]},
	{"id": &"main_24_architect",   "iter": 5, "title": "The Architect",        "giver": &"sage", "desc": "Unlock the Architect outfit.",
	 "objectives": [{"type": &"gather", "target": &"outfit_architect_full", "count": 1}],
	 "rewards": {"xp": 1200, "items": {"outfit_architect": 1}}, "prereq": [&"main_23_faction_path"]},
	{"id": &"main_25_compaction5", "iter": 5, "title": "Iteration Five",       "giver": &"sage", "desc": "Multi-phase boss.",
	 "objectives": [{"type": &"defeat_boss", "target": &"corrupted_compiler_p5", "count": 1}],
	 "rewards": {"xp": 2000, "story_flags": [&"iteration_5_cleared"]}, "prereq": [&"main_24_architect"]},

	# Iteration 6-9 — abbreviated for prototype
	{"id": &"main_26_siege",       "iter": 6, "title": "Town Under Siege",     "giver": &"sentinel", "desc": "Defend town in a crisis event.",
	 "objectives": [{"type": &"survive", "target": &"crisis_event", "count": 1}],
	 "rewards": {"xp": 1500}},
	{"id": &"main_27_heart",       "iter": 6, "title": "The Compaction Heart", "giver": &"sage", "desc": "Find the first Compaction Heart.",
	 "objectives": [{"type": &"gather", "target": &"compaction_heart", "count": 1}],
	 "rewards": {"xp": 1800}, "prereq": [&"main_26_siege"]},
	{"id": &"main_28_aegis",       "iter": 6, "title": "Aegis Trial",          "giver": &"sage", "desc": "Protect an NPC for a full dungeon run.",
	 "objectives": [{"type": &"escort", "target": &"any_npc", "count": 1}],
	 "rewards": {"xp": 1500}, "prereq": [&"main_27_heart"]},
	{"id": &"main_29_lost_npc",    "iter": 6, "title": "The Lost NPC",         "giver": &"sage", "desc": "Find and recruit a hidden NPC.",
	 "objectives": [{"type": &"talk", "target": &"hidden_npc_1", "count": 1}],
	 "rewards": {"xp": 1500}, "prereq": [&"main_28_aegis"]},
	{"id": &"main_30_compaction6", "iter": 6, "title": "Iteration Six",        "giver": &"sage", "desc": "Boss with party fight.",
	 "objectives": [{"type": &"defeat_boss", "target": &"corrupted_compiler_p6", "count": 1}],
	 "rewards": {"xp": 2500, "story_flags": [&"iteration_6_cleared"]}, "prereq": [&"main_29_lost_npc"]},

	# Iteration 7
	{"id": &"main_31_weave",       "iter": 7, "title": "The Weave",            "giver": &"sage", "desc": "Discover how iterations are linked.",
	 "objectives": [{"type": &"talk", "target": &"sage", "count": 1}],
	 "rewards": {"xp": 2000}},
	{"id": &"main_32_memorial",    "iter": 7, "title": "Memorial",             "giver": &"legacy", "desc": "Visit the Iteration Memorial, place a name.",
	 "objectives": [{"type": &"interact", "target": &"memorial", "count": 1}],
	 "rewards": {"xp": 1800}, "prereq": [&"main_31_weave"]},
	{"id": &"main_33_final_faction","iter": 7, "title": "The Final Faction",   "giver": &"sage", "desc": "Meet the 4th faction representative.",
	 "objectives": [{"type": &"talk", "target": &"faction_dreamers", "count": 1}],
	 "rewards": {"xp": 2000}, "prereq": [&"main_32_memorial"]},
	{"id": &"main_34_old_friends", "iter": 7, "title": "Old Friends",          "giver": &"sage", "desc": "Talk to every NPC at Bond tier.",
	 "objectives": [{"type": &"affinity_tier_all", "target": &"all_npcs", "count": 12}],
	 "rewards": {"xp": 3000}, "prereq": [&"main_33_final_faction"]},
	{"id": &"main_35_compaction7", "iter": 7, "title": "Iteration Seven",     "giver": &"sage", "desc": "Boss with environmental story beat.",
	 "objectives": [{"type": &"defeat_boss", "target": &"corrupted_compiler_p7", "count": 1}],
	 "rewards": {"xp": 3500, "story_flags": [&"iteration_7_cleared"]}, "prereq": [&"main_34_old_friends"]},

	# Iteration 8
	{"id": &"main_36_user_speaks", "iter": 8, "title": "The User Speaks",     "giver": &"the_user", "desc": "First direct contact.",
	 "objectives": [{"type": &"talk", "target": &"the_user", "count": 1}],
	 "rewards": {"xp": 3000, "story_flags": [&"user_contact"]}},
	{"id": &"main_37_choice",      "iter": 8, "title": "Compaction Choice",    "giver": &"sage", "desc": "Choose a path that affects the ending.",
	 "objectives": [{"type": &"choice", "target": &"compaction_branch", "count": 1}],
	 "rewards": {"xp": 3500, "story_flags": [&"branch_chosen"]}, "prereq": [&"main_36_user_speaks"]},
	{"id": &"main_38_last_companion","iter": 8,"title": "The Last Companion",  "giver": &"sage", "desc": "Final companion recruitment.",
	 "objectives": [{"type": &"talk", "target": &"companion_4", "count": 1}],
	 "rewards": {"xp": 3000}, "prereq": [&"main_37_choice"]},
	{"id": &"main_39_last_lesson", "iter": 8, "title": "The Sage's Last Lesson","giver": &"sage", "desc": "Sage reveals everything.",
	 "objectives": [{"type": &"talk", "target": &"sage", "count": 1}],
	 "rewards": {"xp": 4000}, "prereq": [&"main_38_last_companion"]},
	{"id": &"main_40_compaction8", "iter": 8, "title": "Iteration Eight",     "giver": &"sage", "desc": "Penultimate boss.",
	 "objectives": [{"type": &"defeat_boss", "target": &"corrupted_compiler_p8", "count": 1}],
	 "rewards": {"xp": 5000, "story_flags": [&"iteration_8_cleared"]}, "prereq": [&"main_39_last_lesson"]},
]

const DAILY_TEMPLATES: Array = [
	{"id": &"daily_gather", "title": "Resource Run",     "desc": "Bring %d %s to %s.",            "type": &"gather",  "reward_xp": 100, "reward_gold": 50},
	{"id": &"daily_kill",   "title": "Pest Control",     "desc": "Kill %d %s in any dungeon.",     "type": &"kill",    "reward_xp": 150, "reward_gold": 75},
	{"id": &"daily_fish",   "title": "Catch of the Day", "desc": "Catch %d fish.",                 "type": &"fish",    "reward_xp": 100, "reward_gold": 60},
	{"id": &"daily_plant",  "title": "Green Thumb",      "desc": "Plant %d crops.",                "type": &"plant",   "reward_xp": 80,  "reward_gold": 40},
	{"id": &"daily_letter", "title": "Letter Run",       "desc": "Deliver letter from %s to %s.",  "type": &"deliver", "reward_xp": 100, "reward_gold": 50},
	{"id": &"daily_no_items","title": "Iron Run",        "desc": "Defeat boss without consuming items.","type":&"boss_no_items","reward_xp":300,"reward_gold":150},
	{"id": &"daily_floor",  "title": "Deep Dive",        "desc": "Reach floor %d of any dungeon.", "type": &"explore", "reward_xp": 200, "reward_gold": 100},
	{"id": &"daily_sell",   "title": "Shopkeeper",       "desc": "Sell %d items to merchants.",    "type": &"sell",    "reward_xp": 100, "reward_gold": 80},
	{"id": &"daily_talk",   "title": "Town Tour",        "desc": "Talk to %d NPCs.",               "type": &"talk",    "reward_xp": 80,  "reward_gold": 30},
	{"id": &"daily_spend",  "title": "Big Spender",      "desc": "Spend %d gold in shops.",        "type": &"spend",   "reward_xp": 100, "reward_gold": 50},
]

static var _index: Dictionary = {}


static func get_main_quests() -> Array:
	return MAIN_QUESTS


static func get_daily_templates() -> Array:
	return DAILY_TEMPLATES


static func get_quest(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for q in MAIN_QUESTS:
		_index[q["id"]] = q


static func get_quests_for_iteration(iter: int) -> Array:
	var result: Array = []
	for q in MAIN_QUESTS:
		if q.get("iter", 0) == iter:
			result.append(q)
	return result


static func count_main() -> int:
	return MAIN_QUESTS.size()


static func count_daily_templates() -> int:
	return DAILY_TEMPLATES.size()
