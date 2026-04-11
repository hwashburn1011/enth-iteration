class_name TowerTelescopeDatabase
extends RefCounted

## Catalog of telescope viewing targets at the Tower Top. The player
## stands at the iron telescope on a tripod and rotates through these
## targets — each yields a different reveal:
##
##   - Four Mouths       — lore tablet for the daily-bonus dungeon biome
##   - Listening Tree    — small lore line about Sage's chimes
##   - Tilted Spire      — lore line about the glyphs
##   - Final Vault       — grim countdown of remaining seals (iter 4+)
##   - Pasture deer      — *Watcher* cosmetic title (dawn only)
##   - North Star        — *Starlit* buff for next dungeon run (night only)
##
## Each entry defines:
##   - target_world_position — where the telescope's reticle aims
##   - aim_label             — text shown when reticle is on target
##   - phase_filter          — phases when this target is observable
##   - iteration_min         — earliest iteration the target appears
##   - reveal_type           — &"lore_tablet", &"buff", &"title", &"countdown"
##   - reveal_payload        — type-specific data (item id, buff config, etc.)
##   - reveal_cooldown_hours — how often the same target can be re-observed
##                              (0 = once per save, -1 = unlimited)

const TARGETS: Array[Dictionary] = [
	{
		"id": &"telescope_four_mouths",
		"display_name": "The Four Mouths",
		"target_world_position": Vector3(0, -4, -85),
		"aim_label": "The Four Mouths",
		"phase_filter": [],  # any phase
		"iteration_min": 1,
		"reveal_type": &"daily_bonus_lore",
		"reveal_payload": {
			"unselected_lore_pool": [
				&"lore_telescope_server_room",
				&"lore_telescope_memory_vaults",
				&"lore_telescope_corrupted_wilds",
				&"lore_telescope_final_vault",
			],
		},
		"reveal_cooldown_hours": 24,
		"flavor_line": "Four glowing mouths along the cliff line.",
	},
	{
		"id": &"telescope_listening_tree",
		"display_name": "The Listening Tree",
		"target_world_position": Vector3(-30, 1.5, -20),
		"aim_label": "The Listening Tree",
		"phase_filter": [],
		"iteration_min": 1,
		"reveal_type": &"lore_tablet",
		"reveal_payload": {"lore_id": &"lore_telescope_listening_tree"},
		"reveal_cooldown_hours": 0,  # one-shot per save
		"flavor_line": "From here you can see Sage's chimes turning.",
	},
	{
		"id": &"telescope_tilted_spire",
		"display_name": "The Tilted Spire",
		"target_world_position": Vector3(28, 0, -15),
		"aim_label": "The Tilted Spire",
		"phase_filter": [],
		"iteration_min": 1,
		"reveal_type": &"lore_tablet",
		"reveal_payload": {"lore_id": &"lore_telescope_tilted_spire"},
		"reveal_cooldown_hours": 0,
		"flavor_line": "The glyphs along the spire flicker if you watch long enough.",
	},
	{
		"id": &"telescope_final_vault",
		"display_name": "The Final Vault",
		"target_world_position": Vector3(45, -4, -85),
		"aim_label": "The Final Vault",
		"phase_filter": [],
		"iteration_min": 4,
		"reveal_type": &"countdown",
		"reveal_payload": {
			"countdown_id": &"final_vault_seals_remaining",
		},
		"reveal_cooldown_hours": 12,  # half-day so player can re-check
		"flavor_line": "The seals on the easternmost mouth.",
	},
	{
		"id": &"telescope_pasture_deer",
		"display_name": "The Pasture",
		"target_world_position": Vector3(35, 1, 5),
		"aim_label": "Sim-deer at the campsite",
		"phase_filter": [&"dawn"],  # deer only at dawn
		"iteration_min": 1,
		"reveal_type": &"title",
		"reveal_payload": {"title_id": &"watcher"},
		"reveal_cooldown_hours": 0,  # one-shot
		"flavor_line": "A doe and her fawn at the edge of the long grass.",
	},
	{
		"id": &"telescope_north_star",
		"display_name": "The North Star",
		"target_world_position": Vector3(0, 60, 0),  # high up
		"aim_label": "The North Star",
		"phase_filter": [&"night"],
		"iteration_min": 1,
		"reveal_type": &"buff",
		"reveal_payload": {
			"buff_id": &"starlit",
			"stat_modifiers": {&"crit_chance_add": 0.10, &"all_stats_mult": 1.05},
			"duration_minutes": 60,  # one full hour, lasts the next dungeon run
		},
		"reveal_cooldown_hours": 24,
		"flavor_line": "It hasn't moved since the loop started.",
	},
	{
		"id": &"telescope_horizon_west",
		"display_name": "The Horizon (West)",
		"target_world_position": Vector3(-200, 8, 0),
		"aim_label": "The western horizon",
		"phase_filter": [&"dusk"],
		"iteration_min": 5,
		"reveal_type": &"lore_tablet",
		"reveal_payload": {"lore_id": &"lore_telescope_west_horizon"},
		"reveal_cooldown_hours": 0,
		"flavor_line": "Beyond the wilderness, something flickers. Or doesn't.",
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in TARGETS:
		_index[entry["id"]] = entry


static func get_target(target_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(target_id, {})


static func get_observable(phase: StringName, iteration: int) -> Array[Dictionary]:
	## Returns the targets currently visible from the telescope
	## given the active phase and iteration count.
	var result: Array[Dictionary] = []
	for entry: Dictionary in TARGETS:
		var phases: Array = entry.get("phase_filter", [])
		if not phases.is_empty() and not phases.has(phase):
			continue
		if int(entry.get("iteration_min", 1)) > iteration:
			continue
		result.append(entry)
	return result


static func get_count() -> int:
	return TARGETS.size()
