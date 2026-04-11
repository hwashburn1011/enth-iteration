class_name NPCDefinition
extends Resource

## Definition of an NPC for the affinity system. Loaded from data/npcs/.

@export var npc_id: StringName = &""
@export var display_name: String = ""
@export var role: String = ""               ## "shopkeeper", "blacksmith", etc.
@export var portrait: Texture2D
@export var color_tint: Color = Color.WHITE  ## UI accent color

## Birthday — in-game day of the year (1-90)
@export var birthday_day: int = 1

## Gift preference lists (item_ids)
@export var loved_gifts: Array[StringName] = []
@export var liked_gifts: Array[StringName] = []
@export var disliked_gifts: Array[StringName] = []
@export var hated_gifts: Array[StringName] = []

## Backstory dialogue lines per affinity tier (0-4)
@export var backstory_arcs: Array[String] = ["", "", "", "", ""]

## Personal quest IDs unlocked at Confidant tier
@export var personal_quest_ids: Array[StringName] = []

## NPC-NPC relationships
@export var friend_npcs: Array[StringName] = []
@export var rival_npcs: Array[StringName] = []
@export var family_npcs: Array[StringName] = []

## Schedule presets for each affinity tier
@export var schedule_stranger: Dictionary = {}
@export var schedule_friend: Dictionary = {}
@export var schedule_bond: Dictionary = {}
