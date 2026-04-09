class_name PlayerPortraitProvider
extends Node

## Bridges Globbler's current outfit to the DialoguePanel speaker portrait
## system. When the player is the dialogue speaker, this component supplies
## the appropriate portrait texture set (one per emotion expression).
##
## Outfit-specific portraits live in PORTRAIT_SETS as preloaded references;
## when no override exists for the current outfit, falls back to default.

## Each outfit can have its own portrait set: { expression_name -> Texture2D }
@export var portrait_sets: Dictionary = {}  ## set_id (StringName) -> Dict
@export var default_portraits: Dictionary = {}  ## expression_name -> Texture2D
@export var equipment_component_path: NodePath

const SUPPORTED_EXPRESSIONS: PackedStringArray = [
	&"neutral", &"smile", &"frown", &"surprised",
	&"angry", &"sad", &"smirk", &"hurt",
]

var _equipment_component: Node
var _current_set_id: StringName = &""


func _ready() -> void:
	_equipment_component = get_node_or_null(equipment_component_path)
	if _equipment_component != null and _equipment_component.has_signal("equipment_changed"):
		_equipment_component.equipment_changed.connect(_on_equipment_changed)


func get_portraits_for_dialogue() -> Dictionary:
	## Returns the portrait dictionary the DialoguePanel expects.
	## Prefers outfit-specific set, falls back to defaults piecewise.
	var result: Dictionary = {}
	var override_set: Dictionary = portrait_sets.get(_current_set_id, {})
	for expr in SUPPORTED_EXPRESSIONS:
		if override_set.has(expr):
			result[expr] = override_set[expr]
		elif default_portraits.has(expr):
			result[expr] = default_portraits[expr]
	return result


func push_to_dialogue_panel(panel: Node) -> void:
	if panel == null:
		return
	if "speaker_portraits" in panel:
		panel.speaker_portraits = get_portraits_for_dialogue()
	if "speaker_npc_id" in panel:
		panel.speaker_npc_id = "globbler"


func _on_equipment_changed(_slot: StringName, _item: Resource) -> void:
	# Detect the dominant set ID across equipped pieces (for portrait selection)
	if _equipment_component == null:
		return
	if _equipment_component.has_method("get_all_equipped"):
		var all: Dictionary = _equipment_component.get_all_equipped()
		var counts: Dictionary = {}
		for slot in all.keys():
			var item: Resource = all[slot]
			if item is OutfitItem:
				var sid: StringName = (item as OutfitItem).set_id
				counts[sid] = counts.get(sid, 0) + 1
		var dominant: StringName = &""
		var dominant_count: int = 0
		for sid in counts.keys():
			if counts[sid] > dominant_count:
				dominant_count = counts[sid]
				dominant = sid
		_current_set_id = dominant
