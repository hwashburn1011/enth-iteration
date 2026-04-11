class_name HiddenQuestDatabase
extends RefCounted

## Hidden Quest Database (Epic 38 tasks 9, 26).
##
## 15 secret/hidden quests that the player only discovers through specific
## triggers (interacting with hidden objects, completing prereq sequences,
## reaching specific times, finding lore tablets, etc).
##
## Each hidden quest has:
##   id, title, description, trigger (the condition that reveals it),
##   objectives, rewards, lore_text (shown when revealed)

const HIDDEN_QUESTS: Dictionary = {
	&"hq_001_whispering_well": {
		"title": "The Whispering Well",
		"description": "A well in the cliffs whispers secrets at midnight.",
		"trigger": {"kind": "time_at_location", "location": &"cliffs_well", "hour": 0},
		"objectives": [
			{"kind": "interact", "target": &"cliffs_well", "during_hour": 0},
			{"kind": "find", "item": &"whispering_pendant"},
			{"kind": "deliver", "to": &"index"},
		],
		"rewards": {"gold": 250, "items": [{"id": &"violet_crystal", "qty": 3}], "xp": 150},
		"lore_text": "Some wells listen, even when no one's there.",
	},
	&"hq_002_blood_moon_hunter": {
		"title": "Blood Moon Hunter",
		"description": "On the rare blood moon, the dungeon spawns a unique elite.",
		"trigger": {"kind": "moon_phase", "phase": &"blood_moon"},
		"objectives": [
			{"kind": "kill", "enemy": &"blood_moon_elite"},
			{"kind": "collect", "item": &"crimson_essence", "qty": 1},
		],
		"rewards": {"gold": 400, "items": [{"id": &"red_crystal", "qty": 5}], "xp": 250},
		"lore_text": "Where the moon bleeds, only the brave answer.",
	},
	&"hq_003_secret_chef": {
		"title": "The Secret Chef",
		"description": "Cache mentions a 'secret recipe' she'd never share. Find proof of it.",
		"trigger": {"kind": "affinity", "npc": &"cache", "level": &"bond"},
		"objectives": [
			{"kind": "explore", "area": &"underground_lounge"},
			{"kind": "find", "item": &"cache_recipe_book"},
			{"kind": "deliver", "to": &"cache"},
		],
		"rewards": {"gold": 200, "items": [{"id": &"glitch_pie", "qty": 5}], "affinity": {"cache": 100}, "xp": 200},
		"lore_text": "Even the keeper of the bar has dishes she only makes for ghosts.",
	},
	&"hq_004_sage_test": {
		"title": "The Sage's Test",
		"description": "Solve the ancient riddle the Sage hid in three lore tablets.",
		"trigger": {"kind": "items_collected", "items": [&"lore_tablet_alpha", &"lore_tablet_beta", &"lore_tablet_gamma"]},
		"objectives": [
			{"kind": "interact", "target": &"sage_riddle_pedestal"},
			{"kind": "deliver", "to": &"ai_sage"},
		],
		"rewards": {"gold": 300, "items": [{"id": &"sage_robe_fragment", "qty": 1}], "affinity": {"ai_sage": 50}, "xp": 200},
		"lore_text": "The Sage's first iteration left clues for the ones who would follow.",
	},
	&"hq_005_clockwork_messenger": {
		"title": "Clockwork Messenger",
		"description": "A small mechanical bird drops a sealed letter at your feet.",
		"trigger": {"kind": "random_chance", "chance": 0.02, "context": &"in_town"},
		"objectives": [
			{"kind": "find", "item": &"sealed_letter"},
			{"kind": "deliver", "to": &"trade"},
		],
		"rewards": {"gold": 180, "items": [{"id": &"memory_chip", "qty": 2}], "xp": 90},
		"lore_text": "From whom? It bears no name. Only a route.",
	},
	&"hq_006_cursed_painting": {
		"title": "The Cursed Painting",
		"description": "Render's old painting moves when no one's looking.",
		"trigger": {"kind": "interact_count", "target": &"render_old_painting", "count": 3},
		"objectives": [
			{"kind": "interact", "target": &"render_old_painting", "during_hour": 0},
			{"kind": "kill", "enemy": &"painting_wraith"},
			{"kind": "deliver", "to": &"render"},
		],
		"rewards": {"gold": 220, "items": [{"id": &"compiler_ink", "qty": 5}], "affinity": {"render": 60}, "xp": 150},
		"lore_text": "What Render painted that night, no one remembers — except the painting.",
	},
	&"hq_007_iron_legacy": {
		"title": "Iron Legacy",
		"description": "Forge mentions his teacher disappeared into the dungeons. Find any trace.",
		"trigger": {"kind": "affinity", "npc": &"forge", "level": &"confidant"},
		"objectives": [
			{"kind": "explore", "area": &"server_room"},
			{"kind": "find", "item": &"masters_hammer"},
			{"kind": "deliver", "to": &"forge"},
		],
		"rewards": {"gold": 320, "items": [{"id": &"steel_ingot", "qty": 8}], "affinity": {"forge": 80}, "xp": 200},
		"lore_text": "Some teachers go where their students cannot follow.",
	},
	&"hq_008_garden_visitor": {
		"title": "The Garden Visitor",
		"description": "An owl appears in Sage's Garden every dawn. Discover what it wants.",
		"trigger": {"kind": "time_at_location", "location": &"sage_garden", "hour": 5},
		"objectives": [
			{"kind": "wait", "duration_seconds": 30},
			{"kind": "interact", "target": &"sage_garden_owl"},
		],
		"rewards": {"gold": 150, "items": [{"id": &"data_shard", "qty": 8}], "xp": 120},
		"lore_text": "Some questions are answered by patience alone.",
	},
	&"hq_009_silent_forge": {
		"title": "Silent Forge",
		"description": "Forge's hammer goes quiet for 3 nights running. Investigate.",
		"trigger": {"kind": "schedule_anomaly", "npc": &"forge", "duration_days": 3},
		"objectives": [
			{"kind": "explore", "area": &"forge_home"},
			{"kind": "interact", "target": &"forge_letter"},
			{"kind": "deliver", "to": &"forge"},
		],
		"rewards": {"gold": 200, "items": [{"id": &"iron_ingot", "qty": 10}], "affinity": {"forge": 60}, "xp": 150},
		"lore_text": "Even the strongest hands sometimes need to rest.",
	},
	&"hq_010_pixel_paradox": {
		"title": "Pixel's Paradox",
		"description": "Pixel says her shop sold the same item twice. Investigate her ledger.",
		"trigger": {"kind": "purchase_count", "from": &"pixel", "count": 10},
		"objectives": [
			{"kind": "interact", "target": &"pixel_ledger"},
			{"kind": "find", "item": &"duplicated_invoice"},
			{"kind": "deliver", "to": &"pixel"},
		],
		"rewards": {"gold": 180, "items": [{"id": &"compiler_ink", "qty": 3}], "affinity": {"pixel": 50}, "xp": 100},
		"lore_text": "Some glitches reveal themselves only to keen observers.",
	},
	&"hq_011_underground_chord": {
		"title": "The Underground Chord",
		"description": "Music drifts up from beneath the lounge floor. Find its source.",
		"trigger": {"kind": "interact", "target": &"lounge_floor_grate"},
		"objectives": [
			{"kind": "explore", "area": &"sub_lounge_basement"},
			{"kind": "find", "item": &"phantom_phonograph"},
		],
		"rewards": {"gold": 240, "items": [{"id": &"data_shard", "qty": 6}], "xp": 150},
		"lore_text": "Some music plays for nobody, until somebody listens.",
	},
	&"hq_012_glitched_door": {
		"title": "The Glitched Door",
		"description": "A door in the Memory Vaults flickers between two states. Step through both.",
		"trigger": {"kind": "explore_count", "area": &"memory_vaults", "count": 5},
		"objectives": [
			{"kind": "interact", "target": &"glitched_door", "phase": &"open"},
			{"kind": "interact", "target": &"glitched_door", "phase": &"closed"},
			{"kind": "find", "item": &"paradox_key"},
		],
		"rewards": {"gold": 280, "items": [{"id": &"void_essence", "qty": 2}], "xp": 180},
		"lore_text": "When reality stutters, two things become possible.",
	},
	&"hq_013_lost_iteration": {
		"title": "Lost Iteration",
		"description": "Find evidence of a 10th iteration that never officially existed.",
		"trigger": {"kind": "lore_tablets_collected", "count": 9},
		"objectives": [
			{"kind": "explore", "area": &"iteration_memorial"},
			{"kind": "find", "item": &"iteration_x_fragment"},
			{"kind": "deliver", "to": &"ai_sage"},
		],
		"rewards": {"gold": 500, "items": [{"id": &"void_essence", "qty": 5}], "affinity": {"ai_sage": 100}, "xp": 300},
		"lore_text": "Nine iterations are recorded. The tenth was erased — but not completely.",
	},
	&"hq_014_quiet_companion": {
		"title": "The Quiet Companion",
		"description": "A small companion creature follows Globbler from the shadows. Find out who sent it.",
		"trigger": {"kind": "iteration_at", "iteration": 5},
		"objectives": [
			{"kind": "wait", "duration_seconds": 60},
			{"kind": "interact", "target": &"shadow_companion"},
		],
		"rewards": {"gold": 220, "items": [{"id": &"data_shard", "qty": 10}], "xp": 200},
		"lore_text": "You are never as alone as you think.",
	},
	&"hq_015_silent_garden": {
		"title": "The Silent Garden",
		"description": "Sage's Garden goes silent for one full night. Find why.",
		"trigger": {"kind": "weather_at_location", "location": &"sage_garden", "weather": &"glitch_storm"},
		"objectives": [
			{"kind": "explore", "area": &"sage_garden", "during_hour": 22},
			{"kind": "kill", "enemy": &"silent_wraith"},
			{"kind": "deliver", "to": &"ai_sage"},
		],
		"rewards": {"gold": 350, "items": [{"id": &"violet_crystal", "qty": 4}], "affinity": {"ai_sage": 80}, "xp": 250},
		"lore_text": "When the garden falls silent, the Sage knows the world is listening.",
	},
}


static func get_quest(quest_id: StringName) -> Dictionary:
	return HIDDEN_QUESTS.get(quest_id, {}).duplicate(true)


static func get_all_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for k in HIDDEN_QUESTS.keys():
		ids.append(k)
	return ids


## Returns the trigger condition for a quest. Used by HiddenQuestTriggerWatcher
## to know what events to subscribe to.
static func get_trigger(quest_id: StringName) -> Dictionary:
	var q: Dictionary = HIDDEN_QUESTS.get(quest_id, {})
	return q.get("trigger", {}).duplicate(true)


## Find quests whose triggers match a runtime event.
static func find_triggered_quests(event_kind: StringName, event_data: Dictionary) -> Array[StringName]:
	var triggered: Array[StringName] = []
	for qid in HIDDEN_QUESTS.keys():
		var q: Dictionary = HIDDEN_QUESTS[qid]
		var trigger: Dictionary = q.get("trigger", {})
		if trigger.get("kind", &"") != event_kind:
			continue
		# Match event data fields against trigger requirements
		var matched: bool = true
		for key in trigger.keys():
			if key == "kind":
				continue
			if event_data.has(key) and event_data[key] != trigger[key]:
				matched = false
				break
		if matched:
			triggered.append(qid)
	return triggered
