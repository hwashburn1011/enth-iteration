class_name LoadingScreenDatabase
extends RefCounted

## Per-entrance loading screen catalog. Each entry defines the
## background art, biome subtitle, color palette, sting id, and a pool
## of rotating tips/lore that show beneath the progress bar. The
## LoadingScreen UI picks an entry based on the destination dungeon
## entrance id (or the active biome) and rolls a tip on each show.
##
## Tips intentionally MIX gameplay hints with lore lines so the loading
## screen reads as part of the world rather than a UX surface.

const SCREENS: Dictionary = {
	&"server_room": {
		"display_name": "Server Room",
		"subtitle": "Where all processes begin.",
		"theme_color":   Color(0.20, 0.40, 0.85),
		"accent_color":  Color(0.55, 0.85, 1.00),
		"background_id": &"loading_bg_server_room",
		"sting_id":      &"loading_sting_server_room",
		"tips": [
			{"category": &"gameplay", "text": "Cold servers run faster. Your dash cooldown is 10% shorter here."},
			{"category": &"gameplay", "text": "Compiler crashes drop bit fragments — used in basic crafting."},
			{"category": &"lore",     "text": "The Server Room never sleeps. The hum you hear is older than the loop."},
			{"category": &"lore",     "text": "All processes begin here. All processes return."},
			{"category": &"hint",     "text": "The first floor is always safe. Use it to swap ability loadouts."},
			{"category": &"hint",     "text": "Watch for blue panel tiles — they discharge if you stand too long."},
		],
	},
	&"memory_vaults": {
		"display_name": "Memory Vaults",
		"subtitle": "What the system forgets, the vault remembers.",
		"theme_color":   Color(0.78, 0.65, 0.20),
		"accent_color":  Color(1.00, 0.92, 0.65),
		"background_id": &"loading_bg_memory_vaults",
		"sting_id":      &"loading_sting_memory_vaults",
		"tips": [
			{"category": &"gameplay", "text": "Vault locks read your previous iteration's choices. Pay attention."},
			{"category": &"gameplay", "text": "Memory glass drops here are used in the Archive's reconstruction quest."},
			{"category": &"lore",     "text": "The Vaults were Sage's idea. Or the previous Sage's. The memory is hazy."},
			{"category": &"lore",     "text": "Some doors here have never been opened. Some never will be."},
			{"category": &"hint",     "text": "Memory Wardens telegraph their lunge — sidestep, don't dash."},
			{"category": &"hint",     "text": "If a vault hums, there's lore inside. Even if there's nothing else."},
		],
	},
	&"corrupted_wilds": {
		"display_name": "Corrupted Wilds",
		"subtitle": "Where the rot meets the code.",
		"theme_color":   Color(0.55, 0.20, 0.85),
		"accent_color":  Color(0.95, 0.50, 1.00),
		"background_id": &"loading_bg_corrupted_wilds",
		"sting_id":      &"loading_sting_corrupted_wilds",
		"tips": [
			{"category": &"gameplay", "text": "Corruption stacks rebuild slowly when you're outside the Wilds."},
			{"category": &"gameplay", "text": "Glow moss harvested from the Wilds shows hidden glyphs in the ruins."},
			{"category": &"lore",     "text": "The Wilds were a garden once. Then they ran themselves."},
			{"category": &"lore",     "text": "If a tree calls your name, don't answer. It hasn't heard yours yet."},
			{"category": &"hint",     "text": "Pack-type enemies here alert each other. Take out the spotters first."},
			{"category": &"hint",     "text": "Storm weather doubles glitch storm chance in the Wilds. Plan accordingly."},
		],
	},
	&"final_vault": {
		"display_name": "The Final Vault",
		"subtitle": "The final question. The final answer.",
		"theme_color":   Color(0.10, 0.05, 0.15),
		"accent_color":  Color(0.85, 0.85, 1.00),
		"background_id": &"loading_bg_final_vault",
		"sting_id":      &"loading_sting_final_vault",
		"tips": [
			{"category": &"gameplay", "text": "There is no respawn here. Save your strongest module for the last room."},
			{"category": &"gameplay", "text": "Iteration carries over. Whatever you used in the run, the Vault remembers."},
			{"category": &"lore",     "text": "Seven seals. One for each iteration left."},
			{"category": &"lore",     "text": "When the last one breaks, you go through."},
			{"category": &"lore",     "text": "Sage said she wouldn't be there when you came back. She wasn't."},
			{"category": &"hint",     "text": "Bring a Tier-4 offering to the Shrine before you descend."},
		],
	},
	# === Bonus: town loading screen for re-entry from dungeons ===
	&"town_return": {
		"display_name": "Town",
		"subtitle": "Home, more or less.",
		"theme_color":   Color(0.65, 0.55, 0.40),
		"accent_color":  Color(0.95, 0.85, 0.65),
		"background_id": &"loading_bg_town",
		"sting_id":      &"loading_sting_town_return",
		"tips": [
			{"category": &"gameplay", "text": "Sleep at home to advance the calendar. Some NPCs only appear on certain days."},
			{"category": &"gameplay", "text": "Cache's tavern is the best place to hear what's new this iteration."},
			{"category": &"lore",     "text": "Every iteration the town looks a little different. Or maybe you just notice more."},
			{"category": &"hint",     "text": "Affinity decays slowly between visits. Talk to your favorites first."},
			{"category": &"hint",     "text": "The tutorial vendor sells one new thing per iteration. Always check."},
		],
	},
}


static func get_screen(screen_id: StringName) -> Dictionary:
	return SCREENS.get(screen_id, {})


static func roll_tip(screen_id: StringName, category: StringName = &"") -> Dictionary:
	## Returns a random tip from the screen's tip pool. Pass a category
	## to filter (e.g. &"hint" for tutorial-friendly screens).
	var screen: Dictionary = SCREENS.get(screen_id, {})
	var tips: Array = screen.get("tips", [])
	if tips.is_empty():
		return {}
	if category != &"":
		var filtered: Array = tips.filter(func(t: Dictionary) -> bool: return t.get("category", &"") == category)
		if not filtered.is_empty():
			return filtered[randi() % filtered.size()]
	return tips[randi() % tips.size()]


static func get_count() -> int:
	return SCREENS.size()
