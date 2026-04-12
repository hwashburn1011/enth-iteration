# V1 Demo — `scripts/systems/` Audit

> Phase 1 #7 in `_bmad-output/v1-demo-backlog.md`. Tags every file under
> `scripts/systems/` as **IN** (ships in V1, keep + maintain), **STUB**
> (file exists, runtime consumer is needed for V1, write the consumer),
> or **OUT** (post-V1 — feature-flag or cut). Cuts happen incrementally
> in later phases; this doc is the decision record.

## Counts

- IN: 21
- STUB: 4
- OUT: 105
- **Total: 130**

About 80% of the directory is post-V1 work. The bulk of the OUT list is
deep design content for the full 9-iteration release that has no
runtime consumer yet — leaving it on disk is fine, but we should not
add new code that depends on any of it during V1 development.

## IN — ships in V1, keep + maintain

These are wired into the active play loop or referenced by V1 systems.

| File | Why it's in V1 |
|---|---|
| `enemy_pool.gd` | Combat — pooled enemies, autoload. |
| `enemy_spawner.gd` | Combat — combat room spawn nodes. |
| `spawn_wave.gd` | Combat — multi-spawn waves. |
| `floor_manager.gd` | Dungeon — floor progression. |
| `respawn_manager.gd` | Death loop, autoload. |
| `room_library.gd` | Dungeon — combat room registry. |
| `module_factory.gd` | Player abilities — generates module items. |
| `module_loadout_presets.gd` | Player abilities — preset loadouts. |
| `module_loadout_validator.gd` | Player abilities — equip rules. |
| `equipment_pickup.gd` | Loot pickup interaction. |
| `boss_database.gd` | Boss data — CorruptedCompiler attack patterns. |
| `dungeon_generator.gd` | Dungeon — procedural room sequencing. |
| `dungeon_layout.gd` | Dungeon — room layout helpers. |
| `dungeon_validator.gd` | Dungeon — connectivity check. |
| `music_track_database.gd` | Audio (T54). |
| `sfx_database.gd` | Audio (T55-T59). |
| `sfx_library_database.gd` | Audio — SFX clip catalog. |
| `soundtrack_database.gd` | Audio — music tracks. |
| `environment_database.gd` | Town/dungeon lighting + fog. |
| `weather_database.gd` | Per-iteration biome shift (Phase 2 #12). |
| `rarity_halo_vfx.gd` | Loot drop visual cue. |

## STUB — file exists, V1 needs the runtime consumer wired

These have data but no runtime path yet. Phase 2/3/4 will wire them.

| File | What's missing |
|---|---|
| `voice_database.gd` | NPC voice grunts on dialogue lines. Phase 4 task. |
| `voice_grunts_database.gd` | Same — grunt clip catalog. Phase 4 task. |
| `loading_screen_database.gd` | Loading screen tips between iterations. Phase 5 polish. |
| `dungeon_biome_cinematic_database.gd` | Cheap version of per-iteration biome cutscene (Phase 2 #16 / #17). |

## OUT — post-V1, do not extend during V1 work

The big list. None of these have runtime consumers and they would each
need a meaningful systems / UI investment to ship. Leave on disk
(deleting them triggers UID churn across the project), but **do not
write new code that depends on them during V1 development**.

### Town building / hub social (cut from V1 entirely)

- `affinity_subsystems.gd`
- `buildable_plot.gd`
- `decor_placement_subsystems.gd`
- `decoration_database.gd`
- `decoration_placer.gd`
- `town_district_database.gd`
- `hub_ambient_soundscape_database.gd`
- `hub_fast_travel_database.gd`
- `memorial_plaque_database.gd`
- `wardrobe_npc.gd`
- `outfit_favorites.gd`
- `outfit_set_definitions.gd`
- `respec_npc.gd`

### Companion / pet / NPC schedule systems

- `companion_database.gd`
- `companion_runtime_bridge.gd`
- `companion_skill_tree_database.gd`
- `pet_database.gd`
- `npc_database.gd`
- `npc_schedule.gd`

### Faction system

- `faction_database.gd`
- `faction_subsystems.gd`

### Cooking / farming / fishing / foraging

- `cooking_recipe_database.gd`
- `crafting_station.gd`
- `crafting_subsystems.gd`
- `recipe_database.gd`
- `crop_database.gd`
- `farm_plot.gd`
- `farming_subsystems.gd`
- `fish_database.gd`
- `fishing_minigame.gd`
- `fishing_resolver.gd`
- `foraging_table_database.gd`
- `wildlife_database.gd`
- `resource_node_database.gd`

### Lounge bar

- `lounge_bar_database.gd`
- `lounge_dialogue_database.gd`
- `lounge_regulars_database.gd`

### Wilderness exploration (separate from dungeon loop)

- `wilderness_encounter_database.gd`
- `wilderness_enemy_database.gd`
- `wilderness_landmark_database.gd`
- `wilderness_story_trigger_database.gd`
- `wilderness_waypoint_database.gd`
- `region_database.gd`
- `sub_area_database.gd`

### Quest data sets (V1 ships its own QuestManager — these are post-V1 expansion)

- `quest_database.gd`
- `side_quest_database.gd`
- `hidden_quest_database.gd`
- `quest_runtime_bridge.gd`

### Skill tree (V1 ships flat 4-stat allocation, not a tree)

- `class_system_database.gd`
- `skill_tree_factory.gd`
- `skill_tree_nodes_database.gd`
- `skill_tree_presets.gd`
- `companion_skill_tree_database.gd` (already listed above)

### Endgame / meta modes

- `boss_roster_database.gd`
- `boss_rush.gd`
- `challenge_tower.gd`
- `daily_challenge.gd`
- `endgame_modes_subsystems.gd`
- `hardcore_mode.gd`
- `infinite_mode.gd`
- `tower_telescope_database.gd`
- `trophy_mount_database.gd`
- `achievement_database.gd`

### Dungeon entrance variants (V1 has the one entrance)

- `dungeon_entrance_database.gd`
- `entrance_approach_path_database.gd`
- `entrance_particle_profile_database.gd`
- `entrance_return_cinematic_database.gd`
- `entrance_warden_database.gd`

### Cinematic content beyond the V1 essentials

- `cinematic_database.gd`
- `cinematic_reveal_database.gd`
- `day_night_cinematic_database.gd`
- `weather_cinematic_database.gd`
- `final_ending_cinematic_data.gd`
- `first_equip_cinematic.gd`

### Misc difficulty / accessibility / shrines

- `difficulty_accessibility_subsystems.gd`
- `difficulty_database.gd` *(read by IterationManager? double-check before any cut — flag yellow)*
- `shrine_buff_database.gd`
- `archive_crystal_database.gd`
- `ambient_soundscape_database.gd`
- `fog_volume_database.gd`
- `ground_decal_database.gd`
- `material_database.gd`
- `skybox_preset_database.gd`
- `training_dummy_database.gd`

### Minigames

- `minigame_database.gd`
- `minigame_polish_bundle.gd`
- `minigames/` (folder)

### Tooling / launch ops

- `equipment_stress_test.gd`
- `steam_launch_checklist.gd`

## Cut policy

1. **No deletions during V1 development.** Leave files on disk so UIDs don't churn and we don't accidentally break a still-wired reference.
2. **Do not extend any OUT file** during V1 work. If you find yourself needing one, surface it as a new STUB candidate first.
3. **Yellow-flag the one ambiguous case**: `difficulty_database.gd` — verify it isn't read by `IterationManager._iteration_xp_multiplier` or `enemy_base._apply_iteration_scaling` before any future cut.
4. **Phase 6 #46** in the V1 backlog is the formal "audit `scripts/systems/` — wire or cut" task. That's where the OUT list either gets deleted or feature-flagged behind a `Project Settings → V1 demo` toggle.

## Action items spawned by this audit

- Phase 4 #41 **per-iteration sage dialogue** depends on `voice_database.gd` + `voice_grunts_database.gd` becoming IN. Promote when starting Phase 4.
- Phase 2 #12 **per-iteration biome shift** can use `weather_database.gd` (already IN) and `dungeon_biome_cinematic_database.gd` (STUB). Promote when starting Phase 2.
- Phase 3 #26 **skill tree** is intentionally a NEW system for V1, not a wire-up of the existing `skill_tree_*` files (those are designed for the post-V1 class system).
