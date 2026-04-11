class_name ClassSystemDatabase
extends RefCounted

## Class System Database (Epic 31 — central data hub).
##
## Single source of truth for the 3 player classes:
##   - Compiler: balanced melee+ranged
##   - Daemon: fast assassin
##   - Kernel: tank/control
##
## Holds: visual variant data, HUD theme colors, ability ids, music stings,
## dialogue tags, achievement triggers, leaderboard placeholders, dialogue
## filters, item restrictions, lore text, signature/ultimate procedurally-
## defined animation specs.
##
## Consumed by every class-related component in Epic 31.

const CLASS_IDS: Array[StringName] = [&"compiler", &"daemon", &"kernel"]

const CLASSES: Dictionary = {
	&"compiler": {
		"display_name": "Compiler",
		"role": "Balanced Melee + Ranged",
		"description": "A disciplined hybrid that compiles instructions into deadly combos.",
		"lore": "The Compiler was forged in the early iterations to translate raw input into structured intent. They strike with precision, parry with patience, and chain abilities like syntax.",

		# Visual / HUD
		"shell_color": Color(0.18, 0.42, 0.65),
		"accent_color": Color(1.0, 0.85, 0.35),
		"aura_color": Color(0.20, 0.55, 1.0),
		"hud_primary": Color(0.20, 0.55, 1.0),
		"hud_accent": Color(1.0, 0.85, 0.35),
		"hud_dark": Color(0.05, 0.10, 0.18),
		"portrait_path": "res://_art_source/characters/renders/class_compiler_portrait.png",

		# Abilities
		"signature_ability": &"compiler_compile_strike",
		"ultimate_ability": &"compiler_recursive_descent",
		"starting_modules": [&"basic_blade", &"parry_routine", &"compile_chain"],
		"cooldowns": {
			&"compiler_compile_strike": 9.0,
			&"compiler_recursive_descent": 60.0,
		},

		# Stats
		"base_stats": {
			"hp": 110,
			"mp": 90,
			"atk": 14,
			"def": 10,
			"speed": 4.6,
			"crit": 0.10,
		},
		"damage_type_bonuses": {
			&"slash": 1.20,
			&"pierce": 1.10,
		},
		"passives": [
			{"id": &"compile_chain_bonus", "label": "+15% damage on consecutive hits"},
			{"id": &"parry_window", "label": "0.3s parry window opens after blocking"},
			{"id": &"recursive_haste", "label": "Killing an enemy reduces ability cooldowns by 0.8s"},
		],

		# Dialogue / Quest tags
		"dialogue_tag": &"compiler_class",
		"quest_unlocks": [&"quest_compiler_specialization"],

		# Items
		"restricted_items": [&"daemon_cloak", &"kernel_bulwark"],
		"shared_items": [&"healing_packet", &"data_shard"],

		# Achievements
		"achievement_first_clear": &"first_dungeon_compiler",
		"achievement_master": &"compiler_master",

		# Audio
		"music_sting_select": &"music_sting_class_compiler",
		"level_up_sfx": &"sfx_levelup_compiler",
	},

	&"daemon": {
		"display_name": "Daemon",
		"role": "Fast Assassin",
		"description": "A nimble background process that strikes from the shadows.",
		"lore": "The Daemon runs invisible, an asynchronous executioner that closes distance before you finish a syscall. They dance between targets, leaving only stack traces.",

		"shell_color": Color(0.62, 0.10, 0.20),
		"accent_color": Color(1.0, 0.30, 0.45),
		"aura_color": Color(1.0, 0.15, 0.35),
		"hud_primary": Color(1.0, 0.15, 0.35),
		"hud_accent": Color(1.0, 0.55, 0.30),
		"hud_dark": Color(0.15, 0.04, 0.08),
		"portrait_path": "res://_art_source/characters/renders/class_daemon_portrait.png",

		"signature_ability": &"daemon_shadow_fork",
		"ultimate_ability": &"daemon_kernel_panic",
		"starting_modules": [&"twin_dagger", &"shadow_dash", &"poison_packet"],
		"cooldowns": {
			&"daemon_shadow_fork": 7.0,
			&"daemon_kernel_panic": 75.0,
		},

		"base_stats": {
			"hp": 85,
			"mp": 100,
			"atk": 18,
			"def": 6,
			"speed": 5.8,
			"crit": 0.25,
		},
		"damage_type_bonuses": {
			&"pierce": 1.30,
			&"poison": 1.25,
		},
		"passives": [
			{"id": &"backstab", "label": "+50% damage from behind"},
			{"id": &"shadow_step", "label": "First hit after dodging crits guaranteed"},
			{"id": &"async_heal", "label": "Killing in stealth restores 4 HP"},
		],

		"dialogue_tag": &"daemon_class",
		"quest_unlocks": [&"quest_daemon_specialization"],

		"restricted_items": [&"compiler_blade_set", &"kernel_bulwark"],
		"shared_items": [&"healing_packet", &"data_shard"],

		"achievement_first_clear": &"first_dungeon_daemon",
		"achievement_master": &"daemon_master",

		"music_sting_select": &"music_sting_class_daemon",
		"level_up_sfx": &"sfx_levelup_daemon",
	},

	&"kernel": {
		"display_name": "Kernel",
		"role": "Tank / Control",
		"description": "The immovable core. Holds the line, controls the battlefield.",
		"lore": "The Kernel is the foundation that all processes depend upon. They cannot be killed by mortal exceptions — only the void itself stops their execution. They taunt, they shield, they endure.",

		"shell_color": Color(0.15, 0.30, 0.30),
		"accent_color": Color(0.30, 0.85, 0.85),
		"aura_color": Color(0.25, 0.85, 0.95),
		"hud_primary": Color(0.25, 0.85, 0.95),
		"hud_accent": Color(0.65, 0.95, 1.0),
		"hud_dark": Color(0.04, 0.12, 0.14),
		"portrait_path": "res://_art_source/characters/renders/class_kernel_portrait.png",

		"signature_ability": &"kernel_fortify",
		"ultimate_ability": &"kernel_supervisor_call",
		"starting_modules": [&"tower_shield", &"taunt_protocol", &"bulwark_routine"],
		"cooldowns": {
			&"kernel_fortify": 11.0,
			&"kernel_supervisor_call": 90.0,
		},

		"base_stats": {
			"hp": 160,
			"mp": 70,
			"atk": 10,
			"def": 18,
			"speed": 3.6,
			"crit": 0.05,
		},
		"damage_type_bonuses": {
			&"blunt": 1.25,
			&"shield_bash": 1.40,
		},
		"passives": [
			{"id": &"hold_the_line", "label": "Standing still grants +25% defense"},
			{"id": &"taunt_aura", "label": "Nearby enemies prefer attacking the Kernel"},
			{"id": &"resilient_kernel", "label": "Below 30% HP grants +30% damage reduction"},
		],

		"dialogue_tag": &"kernel_class",
		"quest_unlocks": [&"quest_kernel_specialization"],

		"restricted_items": [&"daemon_cloak", &"compiler_blade_set"],
		"shared_items": [&"healing_packet", &"data_shard"],

		"achievement_first_clear": &"first_dungeon_kernel",
		"achievement_master": &"kernel_master",

		"music_sting_select": &"music_sting_class_kernel",
		"level_up_sfx": &"sfx_levelup_kernel",
	},
}


static func get_class(class_id: StringName) -> Dictionary:
	return CLASSES.get(class_id, {}).duplicate(true)


static func get_all_class_ids() -> Array[StringName]:
	return CLASS_IDS


static func is_valid_class(class_id: StringName) -> bool:
	return CLASSES.has(class_id)


static func get_display_name(class_id: StringName) -> String:
	return CLASSES.get(class_id, {}).get("display_name", "")


static func get_starting_stats(class_id: StringName) -> Dictionary:
	return CLASSES.get(class_id, {}).get("base_stats", {}).duplicate()


static func get_signature_ability(class_id: StringName) -> StringName:
	return CLASSES.get(class_id, {}).get("signature_ability", &"")


static func get_ultimate_ability(class_id: StringName) -> StringName:
	return CLASSES.get(class_id, {}).get("ultimate_ability", &"")


static func get_cooldown(class_id: StringName, ability_id: StringName) -> float:
	var cd: Dictionary = CLASSES.get(class_id, {}).get("cooldowns", {})
	return float(cd.get(ability_id, 0.0))


static func get_passives(class_id: StringName) -> Array:
	return CLASSES.get(class_id, {}).get("passives", []).duplicate()


static func is_item_restricted(class_id: StringName, item_id: StringName) -> bool:
	var restricted: Array = CLASSES.get(class_id, {}).get("restricted_items", [])
	return restricted.has(item_id)


static func get_hud_palette(class_id: StringName) -> Dictionary:
	var c: Dictionary = CLASSES.get(class_id, {})
	return {
		"primary": c.get("hud_primary", Color.WHITE),
		"accent": c.get("hud_accent", Color.WHITE),
		"dark": c.get("hud_dark", Color.BLACK),
	}


static func get_damage_bonus(class_id: StringName, damage_type: StringName) -> float:
	var b: Dictionary = CLASSES.get(class_id, {}).get("damage_type_bonuses", {})
	return float(b.get(damage_type, 1.0))
