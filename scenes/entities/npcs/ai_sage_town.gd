extends "res://scenes/entities/npcs/npc_base.gd"
## AI Sage town variant — always present, switches dialogue after first talk.
## Phase 5 #41: per-iteration dialogue — sage delivers different lines at
## each iteration, hinting at the simulation's collapse and the narrative arc.

var _intro_dialogue: Resource = null
var _subsequent_dialogue: Resource = null
var _has_had_intro: bool = false
## Phase 5 #41 — per-iteration dialogue resources keyed by iteration number.
var _iteration_dialogues: Dictionary = {}


func _ready() -> void:
	npc_id = "ai_sage"
	npc_name = "The AI Sage"
	_intro_dialogue = load("res://data/dialogue/ai_sage_intro.tres") as Resource
	_subsequent_dialogue = load("res://data/dialogue/ai_sage_subsequent.tres") as Resource
	# Phase 5 #41 — load per-iteration dialogue
	_iteration_dialogues[2] = load("res://data/dialogue/ai_sage_iter2.tres") as Resource
	_iteration_dialogues[3] = load("res://data/dialogue/ai_sage_iter3.tres") as Resource
	_iteration_dialogues[4] = load("res://data/dialogue/ai_sage_iter4.tres") as Resource
	# R2 H23+H24: iterations 5 and 6
	_iteration_dialogues[5] = load("res://data/dialogue/ai_sage_iter5.tres") as Resource
	_iteration_dialogues[6] = load("res://data/dialogue/ai_sage_iter6.tres") as Resource
	# R3 K1-K3: iterations 7, 8, and 9
	_iteration_dialogues[7] = load("res://data/dialogue/ai_sage_iter7.tres") as Resource
	_iteration_dialogues[8] = load("res://data/dialogue/ai_sage_iter8.tres") as Resource
	_iteration_dialogues[9] = load("res://data/dialogue/ai_sage_iter9.tres") as Resource
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
		# Phase 5 #41 — pick iteration-specific dialogue if available,
		# otherwise fall back to the generic subsequent lines.
		var iter: int = 1
		if has_node("/root/IterationManager"):
			var im: Node = get_node("/root/IterationManager")
			if im.has_method(&"get_current_iteration"):
				iter = int(im.get_current_iteration())
		if _iteration_dialogues.has(iter):
			dialogue_resource = _iteration_dialogues[iter]
		else:
			dialogue_resource = _subsequent_dialogue
	super._start_conversation()
