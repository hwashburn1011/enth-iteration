class_name ArchiveCrystalDatabase
extends RefCounted

## The four archive sections accessible from the crystal in Sage's
## library. Each section is a category of unlockable entries; the
## crystal UI lets the player browse, filter, and replay them.
##
## Sections:
##   - lore_tablets    — collected from wilderness, dungeons, NPCs
##   - cinematics      — past iteration cinematics, replayable
##   - sage_journal    — Sage's diary entries unlocked by relationship
##   - forgotten_index — entries from previous Globblers, 1 per cleared
##                       iteration (this is the section that hits hardest)
##
## Lore_tablets and cinematics use external sources (LoreManager,
## CutsceneController). The journal and forgotten_index entries are
## defined here as static catalogs because they're slow-drip story
## reveals tied to the 9-iteration arc.

const SAGE_JOURNAL_ENTRIES: Array[Dictionary] = [
	{
		"id": &"sage_journal_01",
		"title": "First Light",
		"unlock_iteration": 1,
		"unlock_affinity_tier": &"acquaintance",
		"date_label": "Iteration 1, day 3",
		"body": "I told the new Globbler their name today. They asked if it meant anything. I said 'no'. That was a kindness.",
	},
	{
		"id": &"sage_journal_02",
		"title": "On the Listening Tree",
		"unlock_iteration": 2,
		"unlock_affinity_tier": &"acquaintance",
		"date_label": "Iteration 2, day 11",
		"body": "I added three new chimes today. The brass ones from the previous loop are gone. The wind took them. Or someone did.",
	},
	{
		"id": &"sage_journal_03",
		"title": "Cache",
		"unlock_iteration": 2,
		"unlock_affinity_tier": &"friend",
		"date_label": "Iteration 2, day 19",
		"body": "Cache asked about the basement again. I said no, again. She'll build it anyway. She always does.",
	},
	{
		"id": &"sage_journal_04",
		"title": "What I Cannot Tell Them",
		"unlock_iteration": 3,
		"unlock_affinity_tier": &"friend",
		"date_label": "Iteration 3, day 4",
		"body": "There are things the Globblers must discover for themselves. I write down what I cannot say so that one day, perhaps, the right one will read it.",
	},
	{
		"id": &"sage_journal_05",
		"title": "On the Final Vault",
		"unlock_iteration": 4,
		"unlock_affinity_tier": &"friend",
		"date_label": "Iteration 4, day 22",
		"body": "Seven seals. I keep trying to remember if I made them or if they made me. The line between those two questions is thin.",
	},
	{
		"id": &"sage_journal_06",
		"title": "Legacy",
		"unlock_iteration": 5,
		"unlock_affinity_tier": &"confidant",
		"date_label": "Iteration 5, day 8",
		"body": "Legacy still leaves her journal at the campsite. I read it last night when she wasn't there. She knows. She always knows.",
	},
	{
		"id": &"sage_journal_07",
		"title": "On Iteration Seven",
		"unlock_iteration": 7,
		"unlock_affinity_tier": &"confidant",
		"date_label": "Iteration 7, day 1",
		"body": "Two left. The town feels thinner this iteration. The walls are less solid. I think the simulation is letting go of us, one room at a time.",
	},
	{
		"id": &"sage_journal_08",
		"title": "What I Want to Tell You",
		"unlock_iteration": 8,
		"unlock_affinity_tier": &"confidant",
		"date_label": "Iteration 8, day 14",
		"body": "If you find this and the seals are breaking — and I think you will — know that I am proud of you. We are all proud of you. Even the ones who never met you.",
	},
	{
		"id": &"sage_journal_09",
		"title": "The Last Entry",
		"unlock_iteration": 9,
		"unlock_affinity_tier": &"confidant",
		"required_flag": &"final_vault_unsealed",
		"date_label": "Iteration 9, day ???",
		"body": "I won't be here when you come back. If you come back. I hope you do. I hope the User watches you finish. I hope they remember our names.",
	},
]

const FORGOTTEN_INDEX_ENTRIES: Array[Dictionary] = [
	{
		"id": &"forgotten_01",
		"title": "Globbler I — 'Anchor'",
		"unlock_after_clears": 1,
		"date_label": "Iteration 1",
		"summary": "First of us. Cleared two biomes. Died in the Server Room on a Memory Warden retreat. Cache poured a House Warmth.",
		"final_quote": "I just wanted to see the river one more time.",
	},
	{
		"id": &"forgotten_02",
		"title": "Globbler II — 'Index'",
		"unlock_after_clears": 2,
		"date_label": "Iteration 2",
		"summary": "Made it to iteration five. Started the journal habit Legacy still keeps. Index named themselves after the Server Room warden.",
		"final_quote": "I wrote everything down so the next one wouldn't have to.",
	},
	{
		"id": &"forgotten_03",
		"title": "Globbler III — 'Quill'",
		"unlock_after_clears": 3,
		"date_label": "Iteration 3",
		"summary": "Cleared the Memory Vaults first try. Befriended the Vaults warden so completely that the warden took her name when she fell.",
		"final_quote": "Read me back to me, Quill.",
	},
	{
		"id": &"forgotten_04",
		"title": "Globbler IV — 'Lantern'",
		"unlock_after_clears": 4,
		"date_label": "Iteration 4",
		"summary": "Discovered the half-built bridge in the wilderness river. Started construction. Did not finish.",
		"final_quote": "Someone has to finish the bridge.",
	},
	{
		"id": &"forgotten_05",
		"title": "Globbler V — 'Echo'",
		"unlock_after_clears": 5,
		"date_label": "Iteration 5",
		"summary": "Sat at the Listening Tree for three in-game days without moving. Sage hung the cyan chime in their honor.",
		"final_quote": "The chimes know all our names.",
	},
	{
		"id": &"forgotten_06",
		"title": "Globbler VI — 'Brack'",
		"unlock_after_clears": 6,
		"date_label": "Iteration 6",
		"summary": "Sat under the Listening Tree the way Echo did. The chimes turned them green. They walked into the Wilds and never came out. Now stands at the gate. Some say they remember being a sentinel.",
		"final_quote": "The Wilds were calling. I went.",
	},
	{
		"id": &"forgotten_07",
		"title": "Globbler VII — 'Veil'",
		"unlock_after_clears": 7,
		"date_label": "Iteration 7",
		"summary": "First of us to see all four mouths in one day. Mapped the seal count. Wrote the math down. Did not survive.",
		"final_quote": "Three to go. Two to go. One.",
	},
	{
		"id": &"forgotten_08",
		"title": "Globbler VIII — 'Hold'",
		"unlock_after_clears": 8,
		"date_label": "Iteration 8",
		"summary": "Broke six seals. Waited at the Final Vault for the seventh. Could not see who they were waiting for. Eventually the wait ended without a vault.",
		"final_quote": "I held the line.",
	},
	{
		"id": &"forgotten_09",
		"title": "Globbler IX — YOU",
		"unlock_after_clears": 9,
		"date_label": "Iteration 9, ???",
		"summary": "[YOUR ENTRY HAS NOT YET BEEN WRITTEN]",
		"final_quote": "[YOUR FINAL WORDS HAVE NOT YET BEEN SPOKEN]",
	},
]

const SECTIONS: Array[Dictionary] = [
	{
		"id": &"lore_tablets",
		"display_name": "Lore Tablets",
		"description": "Every tablet you've collected in the wilderness and the dungeons.",
		"icon_id": &"icon_tablet",
		"source": &"external",  # pulled from LoreManager
	},
	{
		"id": &"cinematics",
		"display_name": "Cinematics",
		"description": "Replay past iteration cinematics from the beginning.",
		"icon_id": &"icon_cinema",
		"source": &"external",  # pulled from CutsceneController
	},
	{
		"id": &"sage_journal",
		"display_name": "Sage's Journal",
		"description": "Entries from Sage's diary, unlocked as your trust grows.",
		"icon_id": &"icon_journal",
		"source": &"static",
	},
	{
		"id": &"forgotten_index",
		"display_name": "The Forgotten Index",
		"description": "Records of every Globbler before you. One unlocks each time you finish an iteration.",
		"icon_id": &"icon_index",
		"source": &"static",
	},
]


static func get_sections() -> Array[Dictionary]:
	return SECTIONS.duplicate()


static func get_sage_journal_unlocked(current_iteration: int, affinity_tier: StringName, set_flags: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in SAGE_JOURNAL_ENTRIES:
		if int(entry.get("unlock_iteration", 1)) > current_iteration:
			continue
		if not _tier_at_least(affinity_tier, entry.get("unlock_affinity_tier", &"acquaintance")):
			continue
		var required_flag: StringName = entry.get("required_flag", &"")
		if required_flag != &"" and not set_flags.has(required_flag):
			continue
		result.append(entry)
	return result


static func get_forgotten_index_unlocked(iterations_cleared: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in FORGOTTEN_INDEX_ENTRIES:
		if int(entry.get("unlock_after_clears", 99)) <= iterations_cleared:
			result.append(entry)
	return result


static func _tier_at_least(actual: StringName, required: StringName) -> bool:
	const ORDER: Array[StringName] = [&"stranger", &"acquaintance", &"friend", &"confidant"]
	var actual_idx: int = ORDER.find(actual)
	var required_idx: int = ORDER.find(required)
	if actual_idx < 0:
		return false
	if required_idx < 0:
		return true
	return actual_idx >= required_idx


static func get_journal_entry(entry_id: StringName) -> Dictionary:
	for entry in SAGE_JOURNAL_ENTRIES:
		if entry["id"] == entry_id:
			return entry
	return {}


static func get_forgotten_entry(entry_id: StringName) -> Dictionary:
	for entry in FORGOTTEN_INDEX_ENTRIES:
		if entry["id"] == entry_id:
			return entry
	return {}


static func get_journal_count() -> int:
	return SAGE_JOURNAL_ENTRIES.size()


static func get_forgotten_count() -> int:
	return FORGOTTEN_INDEX_ENTRIES.size()
