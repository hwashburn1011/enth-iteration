class_name TerminalHackingMinigame
extends Control

## Terminal Hacking minigame: a sequence of code symbols flashes once, then
## the player must reproduce the sequence in order. Difficulty controls the
## sequence length.

signal completed(success: bool, score: int)

const SYMBOLS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]
const FLASH_INTERVAL: float = 0.6
const TIMEOUT: float = 30.0

@export var difficulty_params: Dictionary = {"symbols": 6}

@onready var _sequence_label: Label = %SequenceLabel
@onready var _input_buttons: GridContainer = %InputButtons
@onready var _progress_label: Label = %ProgressLabel
@onready var _timer_label: Label = %TimerLabel

var _sequence: PackedStringArray = []
var _player_input: PackedStringArray = []
var _flashing_index: int = -1
var _timer: float = 0.0
var _accept_input: bool = false


func start() -> void:
	var symbol_count: int = difficulty_params.get("symbols", 6)
	_generate_sequence(symbol_count)
	_player_input.clear()
	_timer = TIMEOUT
	_accept_input = false
	visible = true
	_build_input_buttons()
	_start_flash_sequence()


func _generate_sequence(length: int) -> void:
	_sequence.clear()
	for i in length:
		_sequence.append(SYMBOLS[randi() % SYMBOLS.size()])


func _start_flash_sequence() -> void:
	_flashing_index = 0
	_flash_next_symbol()


func _flash_next_symbol() -> void:
	if _flashing_index >= _sequence.size():
		_flashing_index = -1
		_accept_input = true
		if _sequence_label != null:
			_sequence_label.text = "Now repeat:"
		return
	if _sequence_label != null:
		_sequence_label.text = _sequence[_flashing_index]
	_flashing_index += 1
	get_tree().create_timer(FLASH_INTERVAL).timeout.connect(_flash_next_symbol)


func _build_input_buttons() -> void:
	if _input_buttons == null:
		return
	for c in _input_buttons.get_children():
		c.queue_free()
	for symbol in SYMBOLS:
		var btn: Button = Button.new()
		btn.text = symbol
		btn.custom_minimum_size = Vector2(64, 64)
		btn.pressed.connect(_on_input_button_pressed.bind(symbol))
		_input_buttons.add_child(btn)


func _on_input_button_pressed(symbol: String) -> void:
	if not _accept_input:
		return
	_player_input.append(symbol)
	# Check correctness
	var idx: int = _player_input.size() - 1
	if _player_input[idx] != _sequence[idx]:
		_finish(false)
		return
	if _player_input.size() == _sequence.size():
		_finish(true)
	if _progress_label != null:
		_progress_label.text = "%d / %d" % [_player_input.size(), _sequence.size()]


func _process(delta: float) -> void:
	if not _accept_input:
		return
	_timer -= delta
	if _timer_label != null:
		_timer_label.text = "%.1f" % _timer
	if _timer <= 0.0:
		_finish(false)


func _finish(success: bool) -> void:
	_accept_input = false
	visible = false
	var score: int = int(_timer * 10) if success else 0
	completed.emit(success, score)
