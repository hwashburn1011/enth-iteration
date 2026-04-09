class_name EnemyVariant
extends Resource

## Per-variant data for any enemy family. The base enemy (e.g. GlitchBug)
## has a baseline set of stats, mesh, materials, and animations. An
## EnemyVariant overlays on top of the base to produce a distinct subspecies
## without re-authoring the rig or animations.
##
## Schema is documented in epic-04-glitchbug-variant-bible.md and is
## intentionally generic — the same Resource works for MemoryLeak variants,
## Stack Overflow variants, etc.
##
## Variant resources live at:
##   res://data/enemies/variants/<family>_<variant>.tres
## e.g. glitchbug_venom.tres, memoryleak_chilled.tres

## Identity
@export var variant_id: StringName = &""
@export var display_name: String = ""
@export var base_enemy_id: StringName = &""  ## the family this is a variant of

# === VISUAL KNOBS ===
## Body uniform scale applied at the armature root
@export_range(0.3, 4.0) var body_scale: float = 1.0
## Mandible scale applied to the mandible bones (or equivalent appendage)
@export_range(0.5, 2.0) var mandible_scale: float = 1.0
## Plate breakup density multiplier (drives procedural plate generator)
@export_range(0.5, 2.0) var plate_density: float = 1.0
## Glitch crack hue A (the primary identifier color)
@export var crack_color_a: Color = Color(0.0, 0.95, 0.95)
## Glitch crack hue B (the secondary)
@export var crack_color_b: Color = Color(0.95, 0.05, 0.55)
## Pattern overlay name (one of: stripe, spot, frost, vein, plate_gold, symbol)
@export var pattern_overlay: StringName = &""
## Aura intensity (drives PackLeaderAura intensity)
@export_range(0.0, 5.0) var aura_intensity: float = 0.0
## Aura radius in meters
@export_range(0.0, 4.0) var aura_radius: float = 0.0

# === STAT MODIFIERS (multipliers relative to base) ===
@export_range(0.1, 10.0) var hp_mult: float = 1.0
@export_range(0.1, 10.0) var damage_mult: float = 1.0
@export_range(0.1, 5.0) var speed_mult: float = 1.0
@export_range(0.1, 5.0) var aggro_radius_mult: float = 1.0

# === BEHAVIORAL ===
@export var has_pack_leader_aura: bool = false
@export var leaves_footstep_decal: bool = false
@export var footstep_decal_path: String = ""
@export var applies_status_effect: StringName = &""

# === LOOT ===
@export var loot_table_override: Resource = null
@export var xp_value_override: int = -1

# === SFX HOOKS ===
## SFX IDs played at specific event hooks. The variant overrides the base
## enemy's SFX so that e.g. the "Cold" variant has a glassy hit sound and
## the "Venom" variant has a wet squelch.
##
## All fields are StringNames into the SfxManager registry. Empty strings
## fall back to the base enemy's SFX.
@export var sfx_idle: StringName = &""
@export var sfx_footstep: StringName = &""
@export var sfx_aggro: StringName = &""
@export var sfx_attack_windup: StringName = &""
@export var sfx_attack_strike: StringName = &""
@export var sfx_hit: StringName = &""
@export var sfx_death: StringName = &""
@export var sfx_aura_loop: StringName = &""  ## ambient hum for elite leaders
@export var sfx_summon_call: StringName = &""  ## queen-only call
