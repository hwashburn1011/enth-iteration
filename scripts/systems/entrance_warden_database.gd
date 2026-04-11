class_name EntranceWardenDatabase
extends RefCounted

## Per-entrance warden NPC catalog. Each of the 4 dungeon mouths has a
## resident character who watches the gate, comments on the player's
## last clear, sells biome-specific consumables, and points out the
## daily-bonus entrance. Wardens are *thematic foils* to their biome —
## the Server Room warden is methodical, the Vaults warden is wistful,
## the Wilds warden is feral, the Final Vault warden is silent.
##
## Each warden defines:
##   - npc_id (links to the broader NPC system)
##   - display name + role description
##   - dialogue pools (greeting / lore / clear comment / daily intel)
##   - shop inventory (item id → price)
##   - schedule presence (which phases they're at the gate)

const WARDENS: Dictionary = {
	&"server_room": {
		"npc_id": &"warden_server",
		"display_name": "Index",
		"role": "Server Room Warden",
		"description": "A patient AI in a faded uniform, ledger always open. Knew every patch number that ever shipped.",
		"theme_color": Color(0.45, 0.65, 0.95),
		"voice_id": &"voice_index",
		"dialogue_pools": {
			"greeting_first": [
				"You're the new Globbler. I keep the ledger here. Welcome to the Server Room.",
				"I'll mark you in the log. Don't expect me to remember you across iterations — I never do.",
			],
			"greeting_recurring": [
				"Back already?",
				"You came back. I appreciate that.",
				"Index, here. Same as always.",
			],
			"lore": [
				"Every process that runs in this town routes through here eventually.",
				"The hum you hear is the heartbeat of the loop.",
				"I've seen seventeen Globblers come through this gate. You're the eighteenth, I think.",
				"The Compiler isn't evil. It's just very, very tired.",
			],
			"clear_comment_quick": [
				"That was fast. Don't get comfortable.",
				"Clean run. The next one won't be.",
			],
			"clear_comment_slow": [
				"You took your time. The Server Room rewards patience. Sometimes.",
				"Good. The hasty ones never come back.",
			],
			"daily_intel": [
				"The %s entrance is rotating bonus today. Worth the trip if you can spare the gear.",
				"I'm told the daily bonus is at the %s portal. I'd go myself but I don't leave the gate.",
			],
		},
		"shop_inventory": {
			&"healing_herb": 5,
			&"data_fragment": 12,
			&"ice_resist_potion": 25,
			&"recipe_data_packer": 60,
		},
		"schedule_phases": [&"dawn", &"day", &"dusk", &"night"],  # always present
	},
	&"memory_vaults": {
		"npc_id": &"warden_vault",
		"display_name": "Quill",
		"role": "Memory Vaults Warden",
		"description": "An older AI with paper-thin patience. Spends every waking hour reorganizing scrolls only she remembers.",
		"theme_color": Color(0.95, 0.78, 0.40),
		"voice_id": &"voice_quill",
		"dialogue_pools": {
			"greeting_first": [
				"Oh. Another one. Try not to disturb the silence on your way down.",
				"Quill. I'm the Vaults warden. Don't touch the scrolls — they're indexed.",
			],
			"greeting_recurring": [
				"Quill, here. Still cataloguing.",
				"You came back. The vault doesn't forget the ones who do.",
				"Reading anything good lately?",
			],
			"lore": [
				"I remember every scroll that was ever filed here. I just don't always remember when.",
				"There's a vault in there with my name on it. I've never opened it. I don't think I'm supposed to.",
				"The Wardens dream the scrolls. The scrolls dream the Wardens. We don't talk about it.",
				"You'll find a journal page in there. It's mine. I lost it twelve iterations ago.",
			],
			"clear_comment_quick": [
				"Too fast. You missed the point.",
				"Speed doesn't impress the Vaults. The Vaults impress the Vaults.",
			],
			"clear_comment_slow": [
				"You read the room. Good.",
				"The Vaults remember a slow walker. They reward them too.",
			],
			"daily_intel": [
				"I overheard a sentinel say the bonus is at the %s today. Worth knowing.",
				"The bonus rotation favors %s today. The Vaults are jealous.",
			],
		},
		"shop_inventory": {
			&"memory_glass": 18,
			&"healing_herb": 5,
			&"recipe_archive_lens": 80,
			&"vault_key_charm": 35,
		},
		"schedule_phases": [&"dawn", &"day", &"dusk"],  # naps at night
	},
	&"corrupted_wilds": {
		"npc_id": &"warden_wilds",
		"display_name": "Brack",
		"role": "Corrupted Wilds Warden",
		"description": "A feral-looking AI with vines growing through their chassis. Smells faintly of glow moss. Likes you, maybe.",
		"theme_color": Color(0.65, 0.95, 0.55),
		"voice_id": &"voice_brack",
		"dialogue_pools": {
			"greeting_first": [
				"Hah. You smell like the town. Don't worry, the Wilds will fix that.",
				"Brack. I keep the gate. Don't keep me — I get bored.",
			],
			"greeting_recurring": [
				"Brack, still here, still rooted.",
				"You came back. I LIKE the ones that come back.",
				"You smell less like town today. Good.",
			],
			"lore": [
				"The Wilds aren't sick. They're just running their own loop now.",
				"The trees in there used to be Globblers. Don't let that stop you.",
				"I was a sentinel once. Then I sat too long under the Listening Tree.",
				"If a vine grabs your ankle, talk to it. They're shy.",
			],
			"clear_comment_quick": [
				"Fast little thing! The Wilds barely got to know you.",
				"Good run. The Wilds will remember the speed.",
			],
			"clear_comment_slow": [
				"You took the long way. The Wilds love the long way.",
				"Slow walker. Good. The Wilds rewards the slow walker.",
			],
			"daily_intel": [
				"Bonus is at %s. The Wilds is jealous, but I'll let you go.",
				"%s gets the rotation today. Don't get attached.",
			],
		},
		"shop_inventory": {
			&"glow_moss": 8,
			&"healing_herb": 5,
			&"corruption_resist_brew": 30,
			&"recipe_vine_grapnel": 75,
		},
		"schedule_phases": [&"dusk", &"night", &"dawn"],  # nocturnal
	},
	&"final_vault": {
		"npc_id": &"warden_final",
		"display_name": "The Quiet One",
		"role": "Final Vault Warden",
		"description": "Robed, faceless, never speaks above a whisper. Stands at the eastmost mouth and watches the seals.",
		"theme_color": Color(0.85, 0.85, 1.00),
		"voice_id": &"voice_quiet",
		"dialogue_pools": {
			"greeting_first": [
				"...",
				"Six more.",
			],
			"greeting_recurring": [
				"...",
				"...",
				"You're early.",
				"The seal moved.",
			],
			"lore": [
				"The vault doesn't open. I open the vault.",
				"I have been here since before the loop. I will be here after.",
				"The seven seals are not chains. They are promises.",
				"I knew Sage.",
			],
			"clear_comment_quick": [],  # doesn't comment on quick clears
			"clear_comment_slow": [
				"You're getting closer.",
			],
			"daily_intel": [
				"The bonus is %s. Mind the rotation.",
			],
		},
		"shop_inventory": {
			&"void_speck": 120,
			&"loop_blessing_charm": 200,
		},
		"schedule_phases": [&"dawn", &"day", &"dusk", &"night"],  # always
		"silent": true,  # special UI flag — text appears slowly, no voice grunts
	},
}


static func get_warden(entrance_id: StringName) -> Dictionary:
	return WARDENS.get(entrance_id, {})


static func roll_line(entrance_id: StringName, pool_key: String) -> String:
	var warden: Dictionary = WARDENS.get(entrance_id, {})
	if warden.is_empty():
		return ""
	var pools: Dictionary = warden.get("dialogue_pools", {})
	var pool: Array = pools.get(pool_key, [])
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]


static func format_daily_intel(entrance_id: StringName, bonus_entrance_display_name: String) -> String:
	var line: String = roll_line(entrance_id, "daily_intel")
	if line.is_empty():
		return ""
	if "%s" in line:
		return line % bonus_entrance_display_name
	return line


static func is_present_in_phase(entrance_id: StringName, phase: StringName) -> bool:
	var warden: Dictionary = WARDENS.get(entrance_id, {})
	var phases: Array = warden.get("schedule_phases", [])
	return phases.has(phase)


static func get_count() -> int:
	return WARDENS.size()
