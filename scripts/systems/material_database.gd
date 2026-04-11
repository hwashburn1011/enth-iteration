class_name MaterialDatabase
extends RefCounted

## Static catalog of all 20 crafting materials. Built once at game start
## from MATERIALS data, queried by id from the rest of the system.

const MATERIALS: Array = [
	# Common
	{"id": &"bit_fragment",   "name": "Bit Fragment",   "rarity": 0, "source": &"drop",   "desc": "Basic data dust shed by every digital creature."},
	{"id": &"wire",           "name": "Wire",           "rarity": 0, "source": &"drop",   "desc": "Conductive thread, common in electronic enemies."},
	{"id": &"patch",          "name": "Patch",          "rarity": 0, "source": &"gather", "desc": "Soft fabric scrap. Useful for almost everything."},
	{"id": &"cache_crystal",  "name": "Cache Crystal",  "rarity": 0, "source": &"gather", "desc": "Small storage gem, harvested from crystal nodes."},
	{"id": &"bytewood",       "name": "Bytewood",       "rarity": 0, "source": &"gather", "desc": "Wood-equivalent, harvested from digital trees."},

	# Uncommon
	{"id": &"compiled_steel", "name": "Compiled Steel", "rarity": 1, "source": &"craft",  "desc": "Refined metal, smelted from Wire and Bit Fragment."},
	{"id": &"memory_glass",   "name": "Memory Glass",   "rarity": 1, "source": &"gather", "desc": "Translucent panel, found in Memory Vaults."},
	{"id": &"server_coil",    "name": "Server Coil",    "rarity": 1, "source": &"drop",   "desc": "Electrical component, drops from RogueProcess."},
	{"id": &"dyed_thread",    "name": "Dyed Thread",    "rarity": 1, "source": &"craft",  "desc": "Colored fabric, made at the Loom."},
	{"id": &"algorithm_stone","name": "Algorithm Stone","rarity": 1, "source": &"drop",   "desc": "Geometric crystal, drops from Compiler enemies."},

	# Rare
	{"id": &"quantum_shard",  "name": "Quantum Shard",  "rarity": 2, "source": &"drop",   "desc": "High-energy crystal from elite enemies."},
	{"id": &"iteration_echo", "name": "Iteration Echo", "rarity": 2, "source": &"boss",   "desc": "Temporal residue from late-game bosses."},
	{"id": &"pure_code",      "name": "Pure Code",      "rarity": 2, "source": &"craft",  "desc": "Ultra-refined data, made by combining Bit Fragments."},
	{"id": &"voidsteel",      "name": "Voidsteel",      "rarity": 2, "source": &"gather", "desc": "Corrupted metal from the Corrupted Wilds."},
	{"id": &"dream_silk",     "name": "Dream Silk",     "rarity": 2, "source": &"drop",   "desc": "Legendary fabric from rare dungeon spawns."},

	# Legendary
	{"id": &"sages_tear",     "name": "Sage's Tear",    "rarity": 3, "source": &"npc",    "desc": "Wisdom crystal, gifted by AI Sage at high affinity."},
	{"id": &"boss_soul",      "name": "Boss Soul",      "rarity": 3, "source": &"boss",   "desc": "Essence of the Corrupted Compiler. One per kill."},
	{"id": &"users_seal",     "name": "The User's Seal","rarity": 3, "source": &"story",  "desc": "Narrative drop. One per iteration."},
	{"id": &"glitch_core",    "name": "Glitch Core",    "rarity": 3, "source": &"drop",   "desc": "Corruption in physical form, dropped from Glitch sets."},
	{"id": &"compaction_heart","name": "Compaction Heart","rarity": 3, "source": &"portal","desc": "Heart of a cleared compaction portal."},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return MATERIALS


static func get_material(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for m in MATERIALS:
		_index[m["id"]] = m


static func get_by_rarity(rarity: int) -> Array:
	var result: Array = []
	for m in MATERIALS:
		if m["rarity"] == rarity:
			result.append(m)
	return result


static func get_by_source(source: StringName) -> Array:
	var result: Array = []
	for m in MATERIALS:
		if m["source"] == source:
			result.append(m)
	return result


static func count() -> int:
	return MATERIALS.size()
