class_name DataSortMinigame
extends CanvasLayer

## Data Sort Minigame (Epic 42 task 13).
##
## Timed sorting puzzle: player gets a row of N number cards in random
## order and must drag them into ascending order before the timer expires.
##
## Difficulty tiers:
##   Easy: 5 cards, 30s
##   Medium: 8 cards, 30s
##   Hard: 12 cards, 25s

signal sort_started(card_count: int, time_limit: float)
signal sort_solved(card_count: int, time_seconds: float, swaps_used: int)
signal sort_failed(reason: String)

const CARDS_BY_DIFFICULTY: Dictionary = {&"easy": 5, &"medium": 8, &"hard": 12}
const TIME_BY_DIFFICULTY: Dictionary = {&"easy": 30.0, &"medium": 30.0, &"hard": 25.0}

@export var difficulty: StringName = &"easy"

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _card_row: HBoxContainer
var _timer_label: Label
var _swaps_label: Label
var _hint_label: Label
var _values: Array[int] = []
var _selected_index: int = -1
var _swaps_used: int = 0
var _time_remaining: float = 30.0
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
	_panel.size = Vector2(820, 360)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.offset_left = -410
	_panel.offset_top = -180
	_root.add_child(_panel)

	var title := Label.new()
	title.position = Vector2(20, 16)
	title.size = Vector2(780, 32)
	title.text = "DATA SORT"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	_timer_label = Label.new()
	_timer_label.position = Vector2(660, 16)
	_timer_label.size = Vector2(140, 32)
	_timer_label.add_theme_font_size_override("font_size", 18)
	_timer_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.30))
	_panel.add_child(_timer_label)

	_swaps_label = Label.new()
	_swaps_label.position = Vector2(20, 16)
	_swaps_label.size = Vector2(160, 32)
	_swaps_label.add_theme_font_size_override("font_size", 14)
	_swaps_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92))
	_panel.add_child(_swaps_label)

	var instr := Label.new()
	instr.position = Vector2(20, 60)
	instr.size = Vector2(780, 24)
	instr.text = "Click two cards to swap. Sort ascending."
	instr.add_theme_font_size_override("font_size", 14)
	instr.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	instr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(instr)

	_card_row = HBoxContainer.new()
	_card_row.position = Vector2(20, 110)
	_card_row.size = Vector2(780, 120)
	_card_row.add_theme_constant_override("separation", 8)
	_panel.add_child(_card_row)

	_hint_label = Label.new()
	_hint_label.position = Vector2(20, 250)
	_hint_label.size = Vector2(780, 32)
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.add_theme_color_override("font_color", Color(0.6, 0.78, 0.92))
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_hint_label)

	var close := Button.new()
	close.text = "Close"
	close.position = Vector2(680, 310)
	close.size = Vector2(120, 32)
	close.pressed.connect(_on_close)
	_panel.add_child(close)


func start_sort(diff: StringName = &"easy") -> void:
	difficulty = diff
	_swaps_used = 0
	_selected_index = -1
	_time_remaining = TIME_BY_DIFFICULTY.get(diff, 30.0)
	_is_running = true
	visible = true
	_generate_cards()
	_render_cards()
	sort_started.emit(_values.size(), _time_remaining)
	set_process(true)


func _generate_cards() -> void:
	var count: int = CARDS_BY_DIFFICULTY.get(difficulty, 5)
	_values = []
	var pool: Array[int] = []
	for i in range(count):
		pool.append(randi_range(10, 99))
	pool.sort()
	# Shuffle
	for i in range(count - 1, 0, -1):
		var j: int = randi() % (i + 1)
		var tmp: int = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	_values = pool


func _render_cards() -> void:
	for child in _card_row.get_children():
		child.queue_free()
	for i in range(_values.size()):
		var btn := Button.new()
		btn.text = str(_values[i])
		btn.custom_minimum_size = Vector2(56, 100)
		var color: Color = Color(0.20, 0.45, 0.65) if i != _selected_index else Color(1.0, 0.85, 0.30)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.pressed.connect(_on_card_pressed.bind(i))
		_card_row.add_child(btn)
	_swaps_label.text = "Swaps: %d" % _swaps_used


func _on_card_pressed(index: int) -> void:
	if not _is_running:
		return
	if _selected_index == -1:
		_selected_index = index
		_render_cards()
	else:
		# Swap
		var tmp: int = _values[_selected_index]
		_values[_selected_index] = _values[index]
		_values[index] = tmp
		_swaps_used += 1
		_selected_index = -1
		_render_cards()
		_check_win()


func _check_win() -> void:
	for i in range(_values.size() - 1):
		if _values[i] > _values[i + 1]:
			return
	_is_running = false
	set_process(false)
	var elapsed: float = TIME_BY_DIFFICULTY.get(difficulty, 30.0) - _time_remaining
	_hint_label.text = "✓ SORTED in %d swaps" % _swaps_used
	sort_solved.emit(_values.size(), elapsed, _swaps_used)


func _process(delta: float) -> void:
	if not _is_running:
		return
	_time_remaining -= delta
	_timer_label.text = "Time: %.0fs" % _time_remaining
	if _time_remaining <= 0:
		_is_running = false
		set_process(false)
		_hint_label.text = "✗ TIMEOUT"
		sort_failed.emit("timeout")


func _on_close() -> void:
	visible = false
	_is_running = false
	set_process(false)
