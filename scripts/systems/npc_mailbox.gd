class_name NPCMailbox
extends RefCounted
## Post-V1 Epic B #20 — NPC mailbox system.
##
## NPCs leave letters after affinity milestones. Letters are stored
## in GameManager meta and read via a simple inbox UI.

## Letter templates keyed by npc_id + tier.
const LETTERS: Dictionary = {
	"ai_sage_Ally": {
		"from": "The AI Sage",
		"subject": "A Fragment of Truth",
		"body": "Globbler — I've been analyzing the data streams you recovered. The patterns are unmistakable. Someone designed this loop to contain you specifically. But they underestimated what you'd become. Keep fighting. The truth is close. — The Sage",
	},
	"cache_sprite_Acquaintance": {
		"from": "Cache Sprite",
		"subject": "Thanks for the Data!",
		"body": "Hey Globbler! Just wanted to say thanks for clearing those bugs out of the corridors. I found some neat cached data fragments in the sectors you cleaned up. Left a little something with the save shrine for you. — CS",
	},
	"villager_r3_Ally": {
		"from": "Villager",
		"subject": "The Town Feels Safer",
		"body": "I know we don't talk much, but I wanted you to know — the town feels different since you started the compaction runs. The glitches are quieter. The data streams run cleaner. Whatever you're doing in there, it's working. Don't stop.",
	},
}


## Check if a new letter should be delivered. Returns the letter dict or {}.
static func check_for_new_mail(npc_id: String, tier: String) -> Dictionary:
	var key: String = "%s_%s" % [npc_id, tier]
	if not LETTERS.has(key):
		return {}
	var read_key: String = "mail_read_%s" % key
	if GameManager.has_meta(StringName(read_key)):
		return {}
	return LETTERS[key]


## Mark a letter as read.
static func mark_read(npc_id: String, tier: String) -> void:
	var key: String = "mail_read_%s_%s" % [npc_id, tier]
	GameManager.set_meta(StringName(key), true)


## Returns all unread letters across all NPCs.
static func get_unread_mail() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key: String in LETTERS:
		var read_key: String = "mail_read_%s" % key
		if not GameManager.has_meta(StringName(read_key)):
			# Check if the player has reached the tier for this letter
			var parts: PackedStringArray = key.split("_", true, 1)
			if parts.size() >= 2:
				result.append(LETTERS[key])
	return result
