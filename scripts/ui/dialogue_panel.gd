class_name DialoguePanel
extends CanvasLayer
## Bottom-screen dialogue panel with typewriter effect. Works while paused.

signal dialogue_finished

const CHARS_PER_SECOND: float = 30.0

var dialogue_data: Array[DialogueLine] = []
var _current_index: int = 0
var _typing: bool = false
var _visible_chars: int = 0
var _full_text: String = ""
var _char_timer: float = 0.0

@onready var _panel: PanelContainer = %DialoguePanel
@onready var _portrait_rect: TextureRect = %PortraitRect
@onready var _name_label: Label = %NameLabel
@onready var _dialogue_label: RichTextLabel = %DialogueLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	_panel.visible = false


func _process(delta: float) -> void:
	if not _typing:
		return
	_char_timer += delta
	var chars_to_show: int = int(_char_timer * CHARS_PER_SECOND)
	if chars_to_show > _visible_chars:
		_visible_chars = chars_to_show
		_dialogue_label.visible_characters = mini(_visible_chars, _full_text.length())
		if _visible_chars >= _full_text.length():
			_typing = false


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"attack_primary"):
		_advance()
		get_viewport().set_input_as_handled()


func start_dialogue(data: Array[DialogueLine]) -> void:
	dialogue_data = data
	_current_index = 0
	_panel.visible = true
	get_tree().paused = true
	GameManager.set_state(GameManager.GameState.DIALOGUE)
	EventBus.dialogue_started.emit(&"")
	_display_line(dialogue_data[0])


func _display_line(line: DialogueLine) -> void:
	_name_label.text = line.speaker_name
	if line.portrait:
		_portrait_rect.texture = line.portrait
		_portrait_rect.visible = true
	else:
		_portrait_rect.visible = false
	_full_text = line.text
	_dialogue_label.text = _full_text
	_dialogue_label.visible_characters = 0
	_visible_chars = 0
	_char_timer = 0.0
	_typing = true


func _advance() -> void:
	if _typing:
		# Instantly show full text
		_typing = false
		_dialogue_label.visible_characters = -1
		return

	_current_index += 1
	if _current_index < dialogue_data.size():
		_display_line(dialogue_data[_current_index])
	else:
		_close()


func _close() -> void:
	_panel.visible = false
	get_tree().paused = false
	GameManager.set_state(GameManager.GameState.PLAYING)
	EventBus.dialogue_ended.emit()
	dialogue_finished.emit()
