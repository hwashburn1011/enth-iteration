class_name ClassDefinition
extends Resource

## Definition of a player class. Loaded from .tres files at startup
## via the ClassRegistry. Drives stat baselines, starting modules, abilities,
## visuals, and progression.

@export var class_id: StringName = &""              ## "compiler", "daemon", "kernel"
@export var display_name: String = ""
@export var tagline: String = ""                     ## one-line elevator pitch
@export var description: String = ""                 ## paragraph for class select screen

## === STAT BASELINES ===
@export var max_hp: float = 100.0
@export var max_compute: float = 100.0
@export var move_speed: float = 4.5
@export var crit_chance: float = 0.08
@export var damage_modifier: float = 1.0
@export var defense_modifier: float = 1.0
@export var dash_cooldown: float = 1.5
@export var charge_time: float = 0.6

## === VISUAL / UI ===
@export var color_primary: Color = Color.WHITE
@export var color_accent: Color = Color.WHITE
@export var hud_theme: StringName = &"default"
@export var music_sting: AudioStream
@export var portrait: Texture2D
@export var class_icon: Texture2D

## === STARTING KIT ===
@export var starting_modules: Array[StringName] = []
@export var starting_passives: Array[StringName] = []

## === SIGNATURE / ULTIMATE ===
@export var signature_ability_id: StringName = &""
@export var ultimate_ability_id: StringName = &""

## === DAMAGE BONUSES ===
@export var damage_type_bonuses: Dictionary = {}    ## enemy_type (StringName) -> multiplier (float)

## === PROGRESSION MILESTONES ===
## Each entry: { level (int), unlock_id (StringName), unlock_name (String) }
@export var milestones: Array[Dictionary] = []

## === ITERATION 3 UNLOCK ===
@export var iteration3_unlock_id: StringName = &""
@export var iteration3_unlock_name: String = ""
@export var iteration3_unlock_description: String = ""

## === RESTRICTED ITEMS ===
@export var restricted_item_ids: Array[StringName] = []


func get_stat(stat_name: StringName) -> float:
	match stat_name:
		&"max_hp":           return max_hp
		&"max_compute":      return max_compute
		&"move_speed":       return move_speed
		&"crit_chance":      return crit_chance
		&"damage_modifier":  return damage_modifier
		&"defense_modifier": return defense_modifier
		&"dash_cooldown":    return dash_cooldown
		&"charge_time":      return charge_time
	return 0.0


func can_use_item(item_id: StringName) -> bool:
	## Returns true unless the item is class-restricted to a different class.
	## Use the global ClassRegistry to check restrictions across all classes.
	return true  # default — restriction enforcement happens via ClassRegistry
