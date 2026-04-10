class_name CodeCompileMinigame
extends CanvasLayer

## Code Compile Minigame (Epic 42 task 12).
##
## Logic puzzle: player is given a target output value and must arrange
## a sequence of 4 operation cards (ADD, SUB, MUL, DIV) with operand values
## (1-9) so the chained computation produces the target.
##
## Difficulty tiers:
##   Easy: 3 ops, target ≤ 30, integer-only
##   Medium: 4 ops, target ≤ 99, integer-only
##   Hard: 5 ops, target ≤ 200, allow division by 2/3
##
## Win: chain produces target. Fail: 3 wrong submissions OR timer runs out.

signal puzzle_started(target: int, ops: Array)
signal puzzle_solved(target: int, attempts: int, time_seconds: float)
signal puzzle_failed(reason: String)

const OPERATIONS: Array[StringName] = [&"ADD", &"SUB", &"MUL", &"DIV"]
const TIMER_BY_DIFFICULTY: Dictionary = {
	&"easy": 60.0, &"medium": 90.0, &"hard": 120.0,
}
const OP_COUNT_BY_DIFFICULTY: Dictionary = {
	&"easy": 3, &"medium": 4, &"hard": 5,
}

@export var difficulty: StringName = &"easy"

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _target_label: Label
var _equation_label: Label
var _timer_label: Label
var _ops_container: HBoxContainer
var _submit_button: Button
var _attempts_label: Label
var _hint_label: Label
var _starting_value: int = 0
var _target_value: int = 0
var _player_sequence: Array[Dictionary] = []
var _solution_sequence: Array[Dictionary] = []
var _attempts: int = 0
var _time_remaining: float = 60.0
var _is_running: bool = false


func _ready() -> void:
	layer = 60
	_build_ui()
	visible = false


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0, 0, 0, 0.7)
	_root.add_child(_bg_dim)

	_panel = Panel.new()
	_panel.size = Vector2(640, 480)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.offset_left = -320
	_panel.offset_top = -240
	_root.add_child(_panel)

	var title := Label.new()
	title.position = Vector2(20, 16)
	title.size = Vector2(600, 32)
	title.text = "CODE COMPILE"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	_target_label = Label.new()
	_target_label.position = Vector2(20, 60)
	_target_label.size = Vector2(600, 36)
	_target_label.add_theme_font_size_override("font_size", 22)
	_target_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_target_label)

	_equation_label = Label.new()
	_equation_label.position = Vector2(20, 110)
	_equation_label.size = Vector2(600, 32)
	_equation_label.add_theme_font_size_override("font_size", 18)
	_equation_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_equation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_equation_label)

	_timer_label = Label.new()
	_timer_label.position = Vector2(480, 16)
	_timer_label.size = Vector2(140, 32)
	_timer_label.add_theme_font_size_override("font_size", 18)
	_timer_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.30))
	_panel.add_child(_timer_label)

	_attempts_label = Label.new()
	_attempts_label.position = Vector2(20, 16)
	_attempts_label.size = Vector2(140, 32)
	_attempts_label.add_theme_font_size_override("font_size", 14)
	_attempts_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92))
	_panel.add_child(_attempts_label)

	_ops_container = HBoxContainer.new()
	_ops_container.position = Vector2(20, 170)
	_ops_container.size = Vector2(600, 100)
	_ops_container.add_theme_constant_override("separation", 10)
	_panel.add_child(_ops_container)

	_submit_button = Button.new()
	_submit_button.text = "Submit"
	_submit_button.position = Vector2(260, 290)
	_submit_button.size = Vector2(120, 36)
	_submit_button.pressed.connect(_on_submit)
	_panel.add_child(_submit_button)

	_hint_label = Label.new()
	_hint_label.position = Vector2(20, 340)
	_hint_label.size = Vector2(600, 60)
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_hint_label.add_theme_font_size_override("font_size", 13)
	_hint_label.add_theme_color_override("font_color", Color(0.6, 0.78, 0.92))
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_hint_label)

	var close := Button.new()
	close.text = "Close"
	close.position = Vector2(500, 430)
	close.size = Vector2(120, 32)
	close.pressed.connect(_on_close)
	_panel.add_child(close)


func start_puzzle(diff: StringName = &"easy") -> void:
	difficulty = diff
	_attempts = 0
	_time_remaining = TIMER_BY_DIFFICULTY.get(diff, 60.0)
	_is_running = true
	visible = true
	_generate_puzzle()
	_render_op_buttons()
	puzzle_started.emit(_target_value, _solution_sequence)
	set_process(true)


func _generate_puzzle() -> void:
	# Build a solution by picking random ops + operands, computing the result
	var op_count: int = OP_COUNT_BY_DIFFICULTY.get(difficulty, 3)
	_starting_value = randi_range(1, 9)
	_solution_sequence = []
	var current: int = _starting_value
	for i in range(op_count):
		var op: StringName = OPERATIONS[randi() % OPERATIONS.size()]
		var operand: int = randi_range(1, 9)
		# Avoid div by zero / fractional
		if op == &"DIV":
			# pick operand that divides current
			operand = 1
			for d in range(2, 10):
				if current % d == 0:
					operand = d
					break
		current = _apply_op(current, op, operand)
		_solution_sequence.append({"op": op, "operand": operand})
	_target_value = current
	_target_label.text = "Start: %d   →   Target: %d" % [_starting_value, _target_value]
	_player_sequence = []


func _apply_op(value: int, op: StringName, operand: int) -> int:
	match op:
		&"ADD": return value + operand
		&"SUB": return value - operand
		&"MUL": return value * operand
		&"DIV":
			if operand == 0: return value
			return int(value / operand)
	return value


func _render_op_buttons() -> void:
	for child in _ops_container.get_children():
		child.queue_free()
	# 6 op buttons (each = random op + operand) — player picks 3-5
	for i in range(8):
		var op: StringName = OPERATIONS[randi() % OPERATIONS.size()]
		var operand: int = randi_range(1, 9)
		var btn := Button.new()
		btn.text = "%s %d" % [op, operand]
		btn.custom_minimum_size = Vector2(70, 60)
		btn.set_meta("op", op)
		btn.set_meta("operand", operand)
		btn.pressed.connect(_on_op_pressed.bind(btn, op, operand))
		_ops_container.add_child(btn)
	_render_equation()


func _on_op_pressed(btn: Button, op: StringName, operand: int) -> void:
	var op_count: int = OP_COUNT_BY_DIFFICULTY.get(difficulty, 3)
	if _player_sequence.size() >= op_count:
		# Reset and start over
		_player_sequence.clear()
	_player_sequence.append({"op": op, "operand": operand})
	_render_equation()


func _render_equation() -> void:
	var s: String = "%d" % _starting_value
	var current: int = _starting_value
	for entry in _player_sequence:
		s += " %s %d" % [entry["op"], entry["operand"]]
		current = _apply_op(current, entry["op"], entry["operand"])
	s += " = %d" % current
	_equation_label.text = s


func _on_submit() -> void:
	var op_count: int = OP_COUNT_BY_DIFFICULTY.get(difficulty, 3)
	if _player_sequence.size() != op_count:
		_hint_label.text = "Need exactly %d operations" % op_count
		return
	var current: int = _starting_value
	for entry in _player_sequence:
		current = _apply_op(current, entry["op"], entry["operand"])
	_attempts += 1
	_attempts_label.text = "Attempts: %d / 3" % _attempts
	if current == _target_value:
		_is_running = false
		set_process(false)
		_hint_label.text = "✓ COMPILED SUCCESSFULLY"
		var elapsed: float = TIMER_BY_DIFFICULTY.get(difficulty, 60.0) - _time_remaining
		puzzle_solved.emit(_target_value, _attempts, elapsed)
	elif _attempts >= 3:
		_is_running = false
		set_process(false)
		_hint_label.text = "✗ COMPILATION FAILED — out of attempts"
		puzzle_failed.emit("attempts")
	else:
		_hint_label.text = "Got %d, target is %d. Try again." % [current, _target_value]
		_player_sequence.clear()
		_render_equation()


func _process(delta: float) -> void:
	if not _is_running:
		return
	_time_remaining -= delta
	_timer_label.text = "Time: %.0fs" % _time_remaining
	if _time_remaining <= 0:
		_is_running = false
		set_process(false)
		_hint_label.text = "✗ TIMEOUT"
		puzzle_failed.emit("timeout")


func _on_close() -> void:
	visible = false
	_is_running = false
	set_process(false)
