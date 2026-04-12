class_name AudioVisualPolish
extends RefCounted
## R2 Epic J — Audio & Visual Polish config (items 41-50).
##
## Defines audio tracks, SFX triggers, and visual polish settings.
## Actual .wav/.ogg files need to be authored and placed in assets/audio/
## — this script provides the mapping and trigger conditions so the
## AudioManager can consume them when they're ready.

## J41: Iteration-specific dungeon ambient tracks.
const DUNGEON_AMBIENT_BY_ITER: Dictionary = {
	1: "dungeon_ambient",         # cyan archive — existing
	2: "dungeon_ambient",         # violet strata — reuse until unique track
	3: "dungeon_ambient_decay",   # amber fault — needs authoring
	4: "dungeon_ambient_collapse",# red horizon — needs authoring
	5: "dungeon_ambient_corrupt", # deep crimson — needs authoring
	6: "dungeon_ambient_void",    # white void — needs authoring
	7: "dungeon_ambient_mosaic",  # glitch mosaic — needs authoring
	8: "dungeon_ambient_mirror",  # infinite mirror — needs authoring
	9: "dungeon_ambient_origin",  # pure white / origin — needs authoring
}

## J42: Boss music per iteration.
const BOSS_MUSIC_BY_ITER: Dictionary = {
	1: "boss_music",     # existing
	2: "boss_music",
	3: "boss_music_v2",  # needs authoring — more intense
	4: "boss_music_v2",
	5: "boss_music_v3",  # needs authoring — desperate
	6: "boss_music_final",# needs authoring — final confrontation
	7: "boss_music_mosaic",# needs authoring — fragmented, glitchy
	8: "boss_music_mirror",# needs authoring — recursive, echoing
	9: "boss_music_origin",# needs authoring — ultimate, transcendent
}

## J43: Victory fanfare — play when all_enemies_defeated fires.
const VICTORY_SFX: String = "victory_fanfare"

## J44: Menu hover SFX.
const MENU_HOVER_SFX: String = "menu_hover"

## J45: Footstep SFX — not yet implemented (needs per-frame check).
const FOOTSTEP_SFX: String = "footstep"
const FOOTSTEP_INTERVAL: float = 0.35  # Seconds between footstep sounds

## J46: Town music shift per iteration.
const TOWN_MUSIC_BY_ITER: Dictionary = {
	1: "town_ambient",      # existing
	2: "town_ambient",
	3: "town_ambient_tense",# needs authoring
	4: "town_ambient_tense",
	5: "town_ambient_dire", # needs authoring
	6: "town_ambient_dire",
	7: "town_ambient_fractured",# needs authoring — glitch mosaic
	8: "town_ambient_echo",     # needs authoring — infinite mirror
	9: "town_ambient_origin",   # needs authoring — pure white finale
}

## J47: Dialogue typing SFX — subtle keystroke per character.
const DIALOGUE_TYPE_SFX: String = "dialogue_type"
const DIALOGUE_TYPE_INTERVAL: int = 3  # Play every N characters

## J48: Item pickup flash — white flash on player mesh.
const PICKUP_FLASH_DURATION: float = 0.12
const PICKUP_FLASH_COLOR: Color = Color(1, 1, 1, 0.4)

## J49: Low health heartbeat — pulsing audio + vignette below threshold.
const LOW_HEALTH_THRESHOLD: float = 0.25
const HEARTBEAT_SFX: String = "heartbeat"
const HEARTBEAT_INTERVAL: float = 0.8  # Seconds between beats at threshold
const HEARTBEAT_VIGNETTE_COLOR: Color = Color(0.5, 0, 0, 0.3)

## J50: Screen-space ambient occlusion — enable in project settings.
## Not a runtime toggle — just documents the setting location:
## Project > Project Settings > Rendering > Environment > SSAO
const SSAO_ENABLED: bool = true
const SSAO_RADIUS: float = 1.0
const SSAO_INTENSITY: float = 2.0
