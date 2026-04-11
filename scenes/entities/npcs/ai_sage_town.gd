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
	# R5 round-51 fix: wire up the AI Sage portrait textures. The .tscn never
	# set portrait_default or the portraits dict, so every Sage dialogue was
	# rendering a placeholder T icon instead of the actual sage portrait.
	# The portrait files have existed at res://assets/textures/portraits/
	# the entire time — they just weren't loaded.
	portrait_default = load("res://assets/textures/portraits/ai_sage_portrait.png") as Texture2D
	portraits = {
		"default": portrait_default,
		"smile": load("res://assets/textures/portraits/ai_sage_portrait_smile.png") as Texture2D,
		"sad": load("res://assets/textures/portraits/ai_sage_portrait_sad.png") as Texture2D,
		"surprise": load("res://assets/textures/portraits/ai_sage_portrait_surprise.png") as Texture2D,
		"wisdom": load("res://assets/textures/portraits/ai_sage_portrait_wisdom.png") as Texture2D,
	}
	super._ready()


func _start_conversation() -> void:
	if not _has_had_intro:
		dialogue_resource = _intro_dialogue
		_has_had_intro = true
	else:
		dialogue_resource = _subsequent_dialogue
	super._start_conversation()
