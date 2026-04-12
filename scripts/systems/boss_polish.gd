class_name BossPolish
extends RefCounted
## R4 Epic P — Boss presentation polish config.
##
## P4: Boss variant scaling modifiers for iterations 7-9
## P5: Boss arena intro name references
## P6: Boss loot table paths for iter 6-9 bosses
## P7: Boss death VFX colors matching biome palette
## P8: Boss health bar iteration tint
## P9: Boss desperation phase triggers for iter 7-9
## P10: Boss music crossfade config

## P4: Additional variant modifiers for late-game bosses.
## Applied on top of base iteration scaling.
const BOSS_VARIANT_MODS: Dictionary = {
	7: {"hp_mult": 1.15, "damage_mult": 1.1, "speed_mult": 1.05},
	8: {"hp_mult": 1.25, "damage_mult": 1.2, "speed_mult": 1.1},
	9: {"hp_mult": 1.4, "damage_mult": 1.3, "speed_mult": 1.15},
}

## P5: Boss intro text per boss id — shown during cinematic intro.
const BOSS_INTRO_TITLES: Dictionary = {
	&"void_architect": "THE VOID ARCHITECT\nEraser of Worlds",
	&"mosaic_hydra": "THE MOSAIC HYDRA\nA Thousand Fractured Faces",
	&"compiler_reborn": "THE COMPILER REBORN\nThe Loop Made Flesh",
	&"origin_singularity": "THE ORIGIN SINGULARITY\nBeginning and End",
}

## P6: Loot table resource paths for new bosses.
const BOSS_LOOT_TABLES: Dictionary = {
	&"void_architect": "res://data/loot_tables/boss_void_architect.tres",
	&"mosaic_hydra": "res://data/loot_tables/boss_mosaic_hydra.tres",
	&"origin_singularity": "res://data/loot_tables/boss_origin_singularity.tres",
}

## P7: Boss death dissolve colors — matches biome palette per iteration.
const BOSS_DEATH_COLORS: Dictionary = {
	1: Color(0.55, 0.85, 1.0),     # cyan baseline
	2: Color(0.75, 0.55, 1.0),     # violet
	3: Color(0.95, 0.75, 0.30),    # amber
	4: Color(1.0, 0.40, 0.35),     # red
	5: Color(0.85, 0.15, 0.25),    # deep crimson
	6: Color(0.95, 0.95, 1.0),     # white void
	7: Color(0.40, 0.95, 0.55),    # glitch green
	8: Color(0.50, 0.50, 1.0),     # mirror blue
	9: Color(1.0, 1.0, 1.0),       # pure white
}

## P8: Boss health bar accent tint per iteration.
const BOSS_HP_BAR_TINT: Dictionary = {
	1: Color(0.3, 0.85, 0.8),
	2: Color(0.65, 0.45, 0.95),
	3: Color(0.95, 0.70, 0.20),
	4: Color(0.95, 0.30, 0.25),
	5: Color(0.80, 0.10, 0.20),
	6: Color(0.90, 0.90, 0.95),
	7: Color(0.30, 0.90, 0.45),
	8: Color(0.40, 0.40, 0.95),
	9: Color(0.95, 0.95, 0.95),
}

## P9: Boss desperation phase config — triggers extra mechanics at low HP.
## Extends CombatDepthV2 desperation triggers for later iterations.
const DESPERATION_TRIGGERS: Dictionary = {
	7: {"hp_threshold": 0.20, "speed_boost": 1.3, "damage_boost": 1.4, "summon_adds": true},
	8: {"hp_threshold": 0.25, "speed_boost": 1.4, "damage_boost": 1.5, "phase_shift": true},
	9: {"hp_threshold": 0.15, "speed_boost": 1.5, "damage_boost": 1.6, "summon_adds": true, "enrage_timer": 60.0},
}

## P10: Boss music crossfade config.
const MUSIC_CROSSFADE_DURATION: float = 1.5  # seconds
const MUSIC_CROSSFADE_CURVE: float = 2.0  # ease exponent


## Returns the death dissolve color for the current iteration.
static func get_death_color(iteration: int) -> Color:
	return BOSS_DEATH_COLORS.get(iteration, Color(1.0, 1.0, 1.0))


## Returns the HP bar tint for the current iteration.
static func get_hp_bar_tint(iteration: int) -> Color:
	return BOSS_HP_BAR_TINT.get(iteration, Color(0.3, 0.85, 0.8))


## Returns desperation config for the current iteration, or empty dict.
static func get_desperation(iteration: int) -> Dictionary:
	return DESPERATION_TRIGGERS.get(iteration, {})
