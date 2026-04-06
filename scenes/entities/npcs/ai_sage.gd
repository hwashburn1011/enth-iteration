class_name AISage
extends Node3D
## AI Sage hologram NPC — provides lore and warnings before boss encounters.

const DIALOGUE_LINES: Array[String] = [
	"Globbler... you've made it further than I calculated possible.",
	"Beyond this chamber lies the Corrupted Compiler — a process gone rogue.",
	"It was once the system's guardian, but the data corruption has twisted it.",
	"Be careful. It adapts. And it remembers.",
]

var _dialogue_index: int = 0
var _player_in_range: bool = false
var _has_talked: bool = false

@onready var _label: Label3D = %DialogueLabel
@onready var _prompt_label: Label3D = %PromptLabel
@onready var _detection: Area3D = %DetectionArea


func _ready() -> void:
	_label.visible = false
	_prompt_label.visible = false
	_detection.body_entered.connect(_on_body_entered)
	_detection.body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed(&"interact"):
		_advance_dialogue()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		if not _has_talked:
			_prompt_label.text = "Press E to talk"
			_prompt_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_prompt_label.visible = false
		_label.visible = false


func _advance_dialogue() -> void:
	if _dialogue_index == 0:
		EventBus.dialogue_started.emit(&"ai_sage")

	if _dialogue_index < DIALOGUE_LINES.size():
		_label.text = DIALOGUE_LINES[_dialogue_index]
		_label.visible = true
		_prompt_label.visible = false
		_dialogue_index += 1
	else:
		_label.visible = false
		_has_talked = true
		EventBus.dialogue_ended.emit()
