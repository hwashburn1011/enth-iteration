class_name MemorialPlaqueDatabase
extends RefCounted

## The 9 alcove plaques in the Memorial Gallery, one per iteration of
## the loop. Each plaque references the same named Globbler from the
## Forgotten Index (ArchiveCrystalDatabase.FORGOTTEN_INDEX_ENTRIES) so
## the player who reads both the library AND the gallery sees the same
## name + final words.
##
## Plaques unlock as the player clears iterations:
##   - Plaque 1 unlocks when iteration 1 ends
##   - Plaque 2 unlocks when iteration 2 ends
##   ...
##   - Plaque 9 ("YOU") unlocks at the end of iteration 9 — the moment
##     the player finishes the loop
##
## Each plaque carries:
##   - id, alcove_index 0-8 (placement order in the hall)
##   - globbler_name (matches the Forgotten Index)
##   - iteration_number
##   - portrait_id (silhouette texture, falls back to a placeholder
##                  Label3D '#N' badge)
##   - epitaph (the quote on the brass strip below the portrait)
##   - final_date (in-fiction date label)
##   - candle_color (per-iteration tint for the alcove candle)
##   - lore_paragraph (the longer text the player reads when interact)

const PLAQUES: Array[Dictionary] = [
	{
		"id": &"plaque_01",
		"alcove_index": 0,
		"globbler_name": "Anchor",
		"iteration_number": 1,
		"portrait_id": &"silhouette_anchor",
		"epitaph": "I just wanted to see the river one more time.",
		"final_date": "Iteration 1, day 14",
		"candle_color": Color(0.95, 0.85, 0.65),  # warm cream — first light
		"lore_paragraph": "First of us. Anchor cleared the Server Room and the Memory Vaults before the Compiler took them on a Memory Warden retreat. They never made it past the river. Cache poured a House Warmth.",
	},
	{
		"id": &"plaque_02",
		"alcove_index": 1,
		"globbler_name": "Index",
		"iteration_number": 2,
		"portrait_id": &"silhouette_index",
		"epitaph": "I wrote everything down so the next one wouldn't have to.",
		"final_date": "Iteration 2, day 31",
		"candle_color": Color(0.85, 0.92, 1.00),
		"lore_paragraph": "Made it to iteration five before the loop reset. Started the journal habit Legacy still keeps. Index named themselves after the Server Room warden, who kept the original. The current Index doesn't remember.",
	},
	{
		"id": &"plaque_03",
		"alcove_index": 2,
		"globbler_name": "Quill",
		"iteration_number": 3,
		"portrait_id": &"silhouette_quill",
		"epitaph": "Read me back to me, Quill.",
		"final_date": "Iteration 3, day 47",
		"candle_color": Color(1.00, 0.88, 0.55),
		"lore_paragraph": "Cleared the Memory Vaults first try. Befriended the Vaults warden so completely that the warden took her name when she fell. The Quill at the Vaults gate today does not know who she is named after, but she leaves a small offering at this alcove every iteration without remembering why.",
	},
	{
		"id": &"plaque_04",
		"alcove_index": 3,
		"globbler_name": "Lantern",
		"iteration_number": 4,
		"portrait_id": &"silhouette_lantern",
		"epitaph": "Someone has to finish the bridge.",
		"final_date": "Iteration 4, day 19",
		"candle_color": Color(1.00, 0.78, 0.40),
		"lore_paragraph": "Discovered the half-built bridge in the wilderness river and started construction. Did not finish. The scaffolding still stands and is now anchored in iteration 4 to mark where Lantern fell. Cache keeps a brick from it behind the lounge bar.",
	},
	{
		"id": &"plaque_05",
		"alcove_index": 4,
		"globbler_name": "Echo",
		"iteration_number": 5,
		"portrait_id": &"silhouette_echo",
		"epitaph": "The chimes know all our names.",
		"final_date": "Iteration 5, day ???",
		"candle_color": Color(0.65, 0.95, 0.85),
		"lore_paragraph": "Sat at the Listening Tree for three in-game days without moving. Sage hung the cyan chime in their honor; it still sounds when the wind hits it from the south. The cyan chime is the only one of the listening tree chimes that has never been replaced.",
	},
	{
		"id": &"plaque_06",
		"alcove_index": 5,
		"globbler_name": "Brack",
		"iteration_number": 6,
		"portrait_id": &"silhouette_brack",
		"epitaph": "The Wilds were calling. I went.",
		"final_date": "Iteration 6, day 42",
		"candle_color": Color(0.55, 1.00, 0.55),
		"lore_paragraph": "Sat under the Listening Tree the way Echo did. The chimes turned them green. They walked into the Wilds and never came out. They now stand at the Wilds entrance gate as the Wilds Warden. They do not remember being a Globbler. The bookkeepers in the Server Room insist they are still alive somewhere.",
	},
	{
		"id": &"plaque_07",
		"alcove_index": 6,
		"globbler_name": "Veil",
		"iteration_number": 7,
		"portrait_id": &"silhouette_veil",
		"epitaph": "Three to go. Two to go. One.",
		"final_date": "Iteration 7, day 8",
		"candle_color": Color(0.85, 0.30, 1.00),
		"lore_paragraph": "First of us to see all four mouths in one day. Mapped the seal count for the next Globbler. Wrote the math down on the back of a Cache barcoaster — the coaster is now in the Sage's library archive. Did not survive the Corrupted Wilds.",
	},
	{
		"id": &"plaque_08",
		"alcove_index": 7,
		"globbler_name": "Hold",
		"iteration_number": 8,
		"portrait_id": &"silhouette_hold",
		"epitaph": "I held the line.",
		"final_date": "Iteration 8, day ???",
		"candle_color": Color(0.92, 0.92, 1.00),
		"lore_paragraph": "Broke six seals on the Final Vault. Waited at the eastmost mouth for the seventh. Could not see who they were waiting for. Eventually the wait ended without a vault opening. Marn the Memorial Keeper does not light Hold's candle except on the days when she is alone in the gallery.",
	},
	{
		"id": &"plaque_09",
		"alcove_index": 8,
		"globbler_name": "YOU",
		"iteration_number": 9,
		"portrait_id": &"silhouette_blank",
		"epitaph": "[YOUR FINAL WORDS HAVE NOT YET BEEN SPOKEN]",
		"final_date": "Iteration 9, day ???",
		"candle_color": Color(1.00, 1.00, 1.00),
		"lore_paragraph": "[YOUR ENTRY HAS NOT YET BEEN WRITTEN]\n\nYou are the ninth. Eight Globblers stood in this gallery before you. Eight candles burn with the names you have just read. The ninth candle is unlit. Marn says the memorial does not write itself until the loop closes. The lighter is on the cenotaph in the back of the hall.",
	},
]


static func get_plaque(plaque_id: StringName) -> Dictionary:
	for entry in PLAQUES:
		if entry["id"] == plaque_id:
			return entry
	return {}


static func get_plaque_for_iteration(iteration: int) -> Dictionary:
	for entry in PLAQUES:
		if int(entry.get("iteration_number", -1)) == iteration:
			return entry
	return {}


static func get_unlocked(iterations_cleared: int) -> Array[Dictionary]:
	## Returns the plaques the player has earned. Plaque N unlocks
	## when iteration N has been completed.
	var result: Array[Dictionary] = []
	for entry: Dictionary in PLAQUES:
		if int(entry.get("iteration_number", 99)) <= iterations_cleared:
			result.append(entry)
	return result


static func get_count() -> int:
	return PLAQUES.size()
