class_name BossRosterDatabase
extends RefCounted

## Boss Roster Database (Epic 43 tasks 34, 35, 36, 37, 45).
##
## Hosts the per-boss support data for the 5 expansion bosses:
##   - Music tracks
##   - Reward chests with item drops
##   - Bestiary entries (lore + stats)
##   - Lore tablets (1 per boss, dropped on first kill)
##   - Test harness for full boss validation

const BOSSES: Dictionary = {
	&"memory_warden": {
		"display_name": "Memory Warden",
		"biome": &"memory_vaults",
		"music_track": &"music_boss_memory_warden",
		"intro_cinematic": &"cinematic_warden_intro",
		"outro_cinematic": &"cinematic_warden_outro",
		"reward_chest": {
			"guaranteed": [{"id": &"warden_seal", "qty": 1}],
			"random": [
				{"id": &"memory_chip", "qty": 5, "weight": 50},
				{"id": &"compiler_ink", "qty": 3, "weight": 30},
				{"id": &"healing_brew", "qty": 4, "weight": 20},
			],
			"gold": 500,
			"xp": 800,
		},
		"bestiary": {
			"hp": 4500, "atk": 65, "def": 40, "speed": 2.8,
			"weakness": &"slash",
			"resistance": &"blunt",
			"description": "An armored guardian forged from forgotten chapters of the archive. The Warden's tomes orbit silently, casting spell-pages that strike with the weight of memory.",
		},
		"lore_tablet": {
			"id": &"lore_warden_origin",
			"text": "Built in iteration 2 to guard the first archive. The Warden has not spoken in seven hundred years, but the books still float.",
		},
		"hero_shot": "res://_art_source/bosses/renders/boss_warden_hero.png",
	},

	&"root_heart": {
		"display_name": "Root Heart",
		"biome": &"corrupted_wilds",
		"music_track": &"music_boss_root_heart",
		"intro_cinematic": &"cinematic_root_intro",
		"outro_cinematic": &"cinematic_root_outro",
		"reward_chest": {
			"guaranteed": [{"id": &"corrupted_seed", "qty": 3}],
			"random": [
				{"id": &"herb_rare", "qty": 6, "weight": 50},
				{"id": &"violet_crystal", "qty": 2, "weight": 30},
				{"id": &"void_essence", "qty": 1, "weight": 20},
			],
			"gold": 600,
			"xp": 900,
		},
		"bestiary": {
			"hp": 5200, "atk": 70, "def": 30, "speed": 1.5,
			"weakness": &"fire",
			"resistance": &"poison",
			"description": "A pulsing heart of corrupted wood, encased in a bark cage. Six vine tentacles writhe from its base, each ending in a glowing core.",
		},
		"lore_tablet": {
			"id": &"lore_root_heart_origin",
			"text": "When the corruption first reached the wilds, the oldest tree drew it inward. The Root Heart is what was left when the bark closed.",
		},
		"hero_shot": "res://_art_source/bosses/renders/boss_root_hero.png",
	},

	&"sentinel_prime": {
		"display_name": "Sentinel Prime",
		"biome": &"server_room",
		"music_track": &"music_boss_sentinel_prime",
		"intro_cinematic": &"cinematic_sentinel_intro",
		"outro_cinematic": &"cinematic_sentinel_outro",
		"reward_chest": {
			"guaranteed": [{"id": &"sentinel_core", "qty": 1}],
			"random": [
				{"id": &"steel_ingot", "qty": 4, "weight": 50},
				{"id": &"data_shard", "qty": 8, "weight": 30},
				{"id": &"copper_ingot", "qty": 6, "weight": 20},
			],
			"gold": 700,
			"xp": 1000,
		},
		"bestiary": {
			"hp": 6000, "atk": 80, "def": 60, "speed": 2.0,
			"weakness": &"pierce",
			"resistance": &"slash",
			"description": "A towering server-room construct with three turret arms. The red core eye tracks intruders, and the cyan turret tips fire compressed data shards.",
		},
		"lore_tablet": {
			"id": &"lore_sentinel_prime_origin",
			"text": "The first sentinel ever compiled. It was meant to guard the server racks, and it still does, even though no one has fed it instructions in centuries.",
		},
		"hero_shot": "res://_art_source/bosses/renders/boss_sentinel_hero.png",
	},

	&"iteration_phantom": {
		"display_name": "Iteration Phantom",
		"biome": &"boss_sanctum",
		"music_track": &"music_boss_iteration_phantom",
		"intro_cinematic": &"cinematic_phantom_intro",
		"outro_cinematic": &"cinematic_phantom_outro",
		"reward_chest": {
			"guaranteed": [{"id": &"phantom_shard", "qty": 1}],
			"random": [
				{"id": &"violet_crystal", "qty": 4, "weight": 50},
				{"id": &"void_essence", "qty": 2, "weight": 30},
				{"id": &"data_shard", "qty": 10, "weight": 20},
			],
			"gold": 800,
			"xp": 1200,
		},
		"bestiary": {
			"hp": 4000, "atk": 95, "def": 35, "speed": 5.0,
			"weakness": &"holy",
			"resistance": &"shadow",
			"description": "A mirror Globbler from a forgotten iteration. Moves like the player, fights like the player, but its attacks come from the wrong angle. Floats in a violet aura.",
		},
		"lore_tablet": {
			"id": &"lore_iteration_phantom_origin",
			"text": "Iteration 5 was lost. The phantom remembers what the player has forgotten, and it does not forgive easily.",
		},
		"hero_shot": "res://_art_source/bosses/renders/boss_phantom_hero.png",
	},

	&"compiler_reborn": {
		"display_name": "The Compiler Reborn",
		"biome": &"sanctum_core",
		"music_track": &"music_boss_compiler_reborn",
		"intro_cinematic": &"cinematic_compiler_intro",
		"outro_cinematic": &"cinematic_compiler_outro",
		"reward_chest": {
			"guaranteed": [
				{"id": &"compiler_heart", "qty": 1},
				{"id": &"final_iteration_key", "qty": 1},
			],
			"random": [
				{"id": &"void_essence", "qty": 6, "weight": 40},
				{"id": &"compiler_ink", "qty": 10, "weight": 30},
				{"id": &"violet_crystal", "qty": 8, "weight": 30},
			],
			"gold": 2000,
			"xp": 5000,
		},
		"bestiary": {
			"hp": 12000, "atk": 110, "def": 80, "speed": 3.5,
			"weakness": &"none",
			"resistance": &"none",
			"description": "The original compiler, reborn as a multi-form crystal entity. Three phases: Crystal Core, Shattered Spire, Ascended Light. Defeat all three to end the iteration cycle.",
			"phase_count": 3,
		},
		"lore_tablet": {
			"id": &"lore_compiler_reborn_origin",
			"text": "The Compiler was the first thing in Enth. It will be the last. Defeating it does not end the simulation — it begins the next iteration.",
		},
		"hero_shot": "res://_art_source/bosses/renders/boss_compiler_hero.png",
	},
}


static func get_boss(boss_id: StringName) -> Dictionary:
	return BOSSES.get(boss_id, {}).duplicate(true)


static func get_all_boss_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for k in BOSSES.keys():
		ids.append(k)
	return ids


static func get_music_track(boss_id: StringName) -> StringName:
	return BOSSES.get(boss_id, {}).get("music_track", &"")


static func get_reward_chest(boss_id: StringName) -> Dictionary:
	return BOSSES.get(boss_id, {}).get("reward_chest", {}).duplicate(true)


static func get_bestiary_entry(boss_id: StringName) -> Dictionary:
	return BOSSES.get(boss_id, {}).get("bestiary", {}).duplicate(true)


static func get_lore_tablet(boss_id: StringName) -> Dictionary:
	return BOSSES.get(boss_id, {}).get("lore_tablet", {}).duplicate(true)


## Test harness — validates each boss has all required fields.
static func run_boss_validation_test() -> Dictionary:
	var report: Dictionary = {
		"total": BOSSES.size(),
		"valid": 0,
		"failures": [],
	}
	for boss_id in BOSSES.keys():
		var boss: Dictionary = BOSSES[boss_id]
		var missing: Array[String] = []
		for required in ["display_name", "music_track", "reward_chest", "bestiary", "lore_tablet", "intro_cinematic", "outro_cinematic", "hero_shot"]:
			if not boss.has(required):
				missing.append(required)
		if missing.is_empty():
			report["valid"] += 1
		else:
			report["failures"].append({"boss": boss_id, "missing": missing})
	return report
