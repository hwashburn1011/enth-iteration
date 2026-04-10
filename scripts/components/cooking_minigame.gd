class_name CookingMinigame
extends CanvasLayer

## Cooking Minigame (Epic 42 task 15).
##
## Resource management puzzle: player has 3 cooking stations (saute, boil,
## bake) with limited fuel. They must serve N recipes within the time limit
## by routing ingredients to the right station, watching cook times so
## food doesn't burn.
##
## Difficulty tiers:
##   Easy: 3 recipes, 90s, generous burn windows
##   Medium: 5 recipes, 90s
##   Hard: 7 recipes, 75s, tight burn windows

signal cook_started(recipe_count: int, time_limit: float)
signal recipe_served(recipe_id: StringName, quality: StringName)
signal recipe_burned(recipe_id: StringName)
signal session_finished(served: int, burned: int, score: int)

const RECIPES_BY_DIFFICULTY: Dictionary = {&"easy": 3, &"medium": 5, &"hard": 7}
const TIME_BY_DIFFICULTY: Dictionary = {&"easy": 90.0, &"medium": 90.0, &"hard": 75.0}

const RECIPE_POOL: Array[Dictionary] = [
	{"id": &"data_stew", "station": &"boil", "cook_time": 6.0, "burn_window": 3.0},
	{"id": &"byte_skewer", "station": &"saute", "cook_time": 4.0, "burn_window": 2.0},
	{"id": &"glitch_pie", "station": &"bake", "cook_time": 10.0, "burn_window": 4.0},
	{"id": &"cache_cookie", "station": &"bake", "cook_time": 7.0, "burn_window": 3.0},
	{"id": &"register_roast", "station": &"saute", "cook_time": 8.0, "burn_window": 3.0},
	{"id": &"buffer_bisque", "station": &"boil", "cook_time": 5.0, "burn_window": 2.0},
	{"id": &"thread_tea", "station": &"boil", "cook_time": 3.0, "burn_window": 2.0},
]

@export var difficulty: StringName = &"easy"

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _timer_label: Label
var _score_label: Label
var _stations: Dictionary = {}  # station_id → {label, panel, current_recipe, cook_progress, started_at}
var _recipe_queue: Array[Dictionary] = []
var _served_count: int = 0
var _burned_count: int = 0
var _time_remaining: float = 90.0
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
	_panel.size = Vector2(820, 540)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.offset_left = -410
	_panel.offset_top = -270
	_root.add_child(_panel)

	var title := Label.new()
	title.position = Vector2(20, 16)
	title.size = Vector2(780, 32)
	title.text = "COOKING"
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

	_score_label = Label.new()
	_score_label.position = Vector2(20, 16)
	_score_label.size = Vector2(220, 32)
	_score_label.add_theme_font_size_override("font_size", 14)
	_score_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92))
	_panel.add_child(_score_label)

	# 3 station panels
	var x_off: int = 20
	for i, station_id in enumerate([&"boil", &"saute", &"bake"]):
		var s_panel := Panel.new()
		s_panel.position = Vector2(x_off, 70)
		s_panel.size = Vector2(250, 200)
		_panel.add_child(s_panel)

		var s_title := Label.new()
		s_title.position = Vector2(10, 8)
		s_title.size = Vector2(230, 24)
		s_title.text = String(station_id).to_upper()
		s_title.add_theme_font_size_override("font_size", 18)
		s_title.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
		s_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		s_panel.add_child(s_title)

		var s_recipe := Label.new()
		s_recipe.position = Vector2(10, 40)
		s_recipe.size = Vector2(230, 24)
		s_recipe.text = "(empty)"
		s_recipe.add_theme_font_size_override("font_size", 14)
		s_recipe.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		s_recipe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		s_panel.add_child(s_recipe)

		var s_progress := ProgressBar.new()
		s_progress.position = Vector2(10, 80)
		s_progress.size = Vector2(230, 24)
		s_progress.max_value = 1.0
		s_panel.add_child(s_progress)

		var s_serve_btn := Button.new()
		s_serve_btn.text = "Serve"
		s_serve_btn.position = Vector2(75, 120)
		s_serve_btn.size = Vector2(100, 32)
		s_serve_btn.pressed.connect(_on_serve_pressed.bind(station_id))
		s_panel.add_child(s_serve_btn)

		var s_clear_btn := Button.new()
		s_clear_btn.text = "Clear"
		s_clear_btn.position = Vector2(75, 158)
		s_clear_btn.size = Vector2(100, 28)
		s_clear_btn.pressed.connect(_on_clear_pressed.bind(station_id))
		s_panel.add_child(s_clear_btn)

		_stations[station_id] = {
			"recipe_label": s_recipe,
			"progress_bar": s_progress,
			"current": null,
			"started_at": 0.0,
		}
		x_off += 260

	# Recipe queue (bottom)
	var queue_header := Label.new()
	queue_header.position = Vector2(20, 290)
	queue_header.size = Vector2(780, 24)
	queue_header.text = "PENDING ORDERS"
	queue_header.add_theme_font_size_override("font_size", 14)
	queue_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_panel.add_child(queue_header)

	var queue_row := HBoxContainer.new()
	queue_row.position = Vector2(20, 320)
	queue_row.size = Vector2(780, 100)
	queue_row.add_theme_constant_override("separation", 8)
	queue_row.name = "QueueRow"
	_panel.add_child(queue_row)

	var close := Button.new()
	close.text = "Close"
	close.position = Vector2(680, 490)
	close.size = Vector2(120, 32)
	close.pressed.connect(_on_close)
	_panel.add_child(close)


func start_cooking(diff: StringName = &"easy") -> void:
	difficulty = diff
	_served_count = 0
	_burned_count = 0
	_time_remaining = TIME_BY_DIFFICULTY.get(diff, 90.0)
	_is_running = true
	visible = true
	_generate_recipe_queue()
	_render_queue()
	cook_started.emit(_recipe_queue.size(), _time_remaining)
	set_process(true)


func _generate_recipe_queue() -> void:
	_recipe_queue.clear()
	var count: int = RECIPES_BY_DIFFICULTY.get(difficulty, 3)
	for i in range(count):
		var template: Dictionary = RECIPE_POOL[randi() % RECIPE_POOL.size()]
		_recipe_queue.append(template.duplicate())


func _render_queue() -> void:
	var row: HBoxContainer = _panel.get_node("QueueRow") as HBoxContainer
	for child in row.get_children():
		child.queue_free()
	for i in range(_recipe_queue.size()):
		var recipe: Dictionary = _recipe_queue[i]
		var btn := Button.new()
		btn.text = "%s\n(%s)" % [String(recipe["id"]).capitalize(), String(recipe["station"]).to_upper()]
		btn.custom_minimum_size = Vector2(120, 80)
		btn.pressed.connect(_on_queue_pressed.bind(i))
		row.add_child(btn)


func _on_queue_pressed(queue_index: int) -> void:
	if queue_index >= _recipe_queue.size():
		return
	var recipe: Dictionary = _recipe_queue[queue_index]
	var station_id: StringName = recipe["station"]
	var station: Dictionary = _stations[station_id]
	if station["current"] != null:
		return  # station busy
	station["current"] = recipe
	station["started_at"] = Time.get_ticks_msec() / 1000.0
	(station["recipe_label"] as Label).text = String(recipe["id"]).capitalize()
	_recipe_queue.remove_at(queue_index)
	_render_queue()


func _on_serve_pressed(station_id: StringName) -> void:
	var station: Dictionary = _stations[station_id]
	var recipe: Dictionary = station.get("current", null) if station.get("current") else {}
	if recipe.is_empty():
		return
	var elapsed: float = Time.get_ticks_msec() / 1000.0 - float(station["started_at"])
	var cook_time: float = float(recipe["cook_time"])
	var burn_window: float = float(recipe["burn_window"])
	var quality: StringName = &"normal"
	if elapsed < cook_time:
		quality = &"undercooked"
	elif elapsed < cook_time + burn_window * 0.5:
		quality = &"perfect"
	elif elapsed < cook_time + burn_window:
		quality = &"normal"
	else:
		# burned — count as failure
		_burned_count += 1
		recipe_burned.emit(recipe["id"])
		_clear_station(station_id)
		_update_score()
		return
	_served_count += 1
	recipe_served.emit(recipe["id"], quality)
	_clear_station(station_id)
	_update_score()
	if _recipe_queue.is_empty() and _all_stations_empty():
		_finish_session()


func _on_clear_pressed(station_id: StringName) -> void:
	_clear_station(station_id)


func _clear_station(station_id: StringName) -> void:
	var station: Dictionary = _stations[station_id]
	station["current"] = null
	station["started_at"] = 0.0
	(station["recipe_label"] as Label).text = "(empty)"
	(station["progress_bar"] as ProgressBar).value = 0


func _all_stations_empty() -> bool:
	for s in _stations.values():
		if s.get("current") != null:
			return false
	return true


func _update_score() -> void:
	_score_label.text = "Served: %d  Burned: %d" % [_served_count, _burned_count]


func _finish_session() -> void:
	_is_running = false
	set_process(false)
	var score: int = _served_count * 100 - _burned_count * 50
	session_finished.emit(_served_count, _burned_count, score)


func _process(delta: float) -> void:
	if not _is_running:
		return
	_time_remaining -= delta
	_timer_label.text = "Time: %.0fs" % _time_remaining
	# Update progress bars + check for auto-burn
	for station_id in _stations.keys():
		var station: Dictionary = _stations[station_id]
		var recipe = station.get("current")
		if recipe == null or (recipe is Dictionary and recipe.is_empty()):
			continue
		var elapsed: float = Time.get_ticks_msec() / 1000.0 - float(station["started_at"])
		var cook_time: float = float(recipe["cook_time"])
		var burn_window: float = float(recipe["burn_window"])
		var pct: float = clamp(elapsed / (cook_time + burn_window), 0.0, 1.0)
		(station["progress_bar"] as ProgressBar).value = pct
		# Auto-burn if exceeds burn window
		if elapsed > cook_time + burn_window:
			_burned_count += 1
			recipe_burned.emit(recipe["id"])
			_clear_station(station_id)
			_update_score()
	if _time_remaining <= 0:
		_finish_session()


func _on_close() -> void:
	visible = false
	_is_running = false
	set_process(false)
