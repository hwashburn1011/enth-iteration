class_name NPCBase
extends CharacterBody3D
## Reusable NPC base with interaction area and dialogue integration.

@export var npc_id: String = ""
@export var npc_name: String = ""
@export var dialogue_resource: Resource
@export var portrait_default: Texture2D
@export var portraits: Dictionary = {}  # expression name -> Texture2D

var has_been_talked_to: bool = false
var _player_in_range: bool = false

@onready var _interaction_area: Area3D = %InteractionArea
@onready var _name_label: Label3D = %NameLabel
@onready var _prompt_label: Label3D = %PromptLabel
@onready var _model: Node3D = %Model


func _ready() -> void:
	_name_label.text = npc_name
	_prompt_label.visible = false
	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed(&"interact"):
		_start_conversation()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_prompt_label.text = "Press E to talk"
		_prompt_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_prompt_label.visible = false


func _start_conversation() -> void:
	if dialogue_resource == null or dialogue_resource.lines.is_empty():
		return

	has_been_talked_to = true
	EventBus.npc_talked.emit(StringName(npc_id))

	# Find or create DialoguePanel
	var panel: Node = _find_dialogue_panel()
	if panel:
		panel.speaker_portraits = portraits
		panel.speaker_npc_id = npc_id
		panel.start_dialogue(dialogue_resource.lines)


func _find_dialogue_panel() -> Node:
	# Search for existing panel in scene tree
	for node: Node in get_tree().root.get_children():
		if node.has_method(&"start_dialogue"):
			return node as Node
	# Instantiate one
	var scene: PackedScene = load("res://scenes/ui/dialogue/DialoguePanel.tscn") as PackedScene
	if scene:
		var panel: Node = scene.instantiate() as Node
		get_tree().root.add_child(panel)
		return panel
	return null
