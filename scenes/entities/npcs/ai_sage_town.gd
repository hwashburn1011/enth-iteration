extends "res://scenes/entities/npcs/npc_base.gd"
## AI Sage town variant — always present, switches dialogue after first talk.

var _intro_dialogue: Resource = null
var _subsequent_dialogue: Resource = null
var _has_had_intro: bool = false


func _ready() -> void:
	npc_id = "ai_sage"
	npc_name = "The AI Sage"
	_intro_dialogue = load("res://data/dialogue/ai_sage_intro.tres") as Resource
	_subsequent_dialogue = load("res://data/dialogue/ai_sage_subsequent.tres") as Resource
	dialogue_resource = _intro_dialogue
	super._ready()


func _start_conversation() -> void:
	if not _has_had_intro:
		dialogue_resource = _intro_dialogue
		_has_had_intro = true
	else:
		dialogue_resource = _subsequent_dialogue
	super._start_conversation()
