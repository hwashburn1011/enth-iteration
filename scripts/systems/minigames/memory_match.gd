class_name MemoryMatchMinigame
extends Control

## Memory Match minigame: a grid of face-down tiles. Player flips 2 at a
## time, matching pairs are removed. Goal: clear the grid before the timer.

signal completed(success: bool, score: int)

const ICONS: Array[String] = [
	"⚙", "◆", "★", "✦", "▲", "●", "♦", "♥",
	"♠", "♣", "■", "▼", "◯", "☼", "✪", "❀",
]

const FLIP_DURATION: float = 0.6
const TIMEOUT: float = 90.0

@export var difficulty_params: Dictionary = {"pairs": 8}

@onready var _grid: GridContainer = %TileGrid
@onready var _timer_label: Label = %TimerLabel
@onready var _matches_label: Label = %MatchesLabel

var _tiles: Array = []        ## { button, icon, matched, flipped }
var _flipped_indices: Array[int] = []
var _matches: int = 0
var _total_pairs: int = 0
var _timer: float = 0.0
var _accept_input: bool = false


func start() -> void:
	var pair_count: int = difficulty_params.get("pairs", 8)
	_total_pairs = pair_count
	_matches = 0
	_timer = TIMEOUT
	_accept_input = true
	visible = true
	_build_grid(pair_count)


func _build_grid(pair_count: int) -> void:
	if _grid == null:
		return
	for c in _grid.get_children():
		c.queue_free()
	_tiles.clear()
	_flipped_indices.clear()

	# Build pairs of icons and shuffle
	var icon_pool: Array[String] = []
	for i in pair_count:
		var icon: String = ICONS[i % ICONS.size()]
		icon_pool.append(icon)
		icon_pool.append(icon)
	icon_pool.shuffle()

	# Set grid columns
	var cols: int = int(ceil(sqrt(float(icon_pool.size()))))
	_grid.columns = cols

	for i in icon_pool.size():
		var btn: Button = Button.new()
		btn.text = "?"
		btn.custom_minimum_size = Vector2(72, 72)
		btn.add_theme_font_size_override(&"font_size", 32)
		btn.pressed.connect(_on_tile_pressed.bind(i))
		_grid.add_child(btn)
		_tiles.append({
			"button": btn,
			"icon": icon_pool[i],
			"matched": false,
			"flipped": false,
		})


func _on_tile_pressed(index: int) -> void:
	if not _accept_input:
		return
	var tile: Dictionary = _tiles[index]
	if tile["matched"] or tile["flipped"]:
		return
	if _flipped_indices.size() >= 2:
		return

	tile["flipped"] = true
	tile["button"].text = tile["icon"]
	_flipped_indices.append(index)

	if _flipped_indices.size() == 2:
		_accept_input = false
		await get_tree().create_timer(FLIP_DURATION).timeout
		_resolve_flip()


func _resolve_flip() -> void:
	var a: Dictionary = _tiles[_flipped_indices[0]]
	var b: Dictionary = _tiles[_flipped_indices[1]]
	if a["icon"] == b["icon"]:
		a["matched"] = true
		b["matched"] = true
		_matches += 1
		if _matches_label != null:
			_matches_label.text = "%d / %d" % [_matches, _total_pairs]
		if _matches >= _total_pairs:
			_finish(true)
			return
	else:
		a["flipped"] = false
		b["flipped"] = false
		a["button"].text = "?"
		b["button"].text = "?"
	_flipped_indices.clear()
	_accept_input = true


func _process(delta: float) -> void:
	if not visible:
		return
	_timer -= delta
	if _timer_label != null:
		_timer_label.text = "%.1f" % _timer
	if _timer <= 0.0:
		_finish(false)


func _finish(success: bool) -> void:
	_accept_input = false
	visible = false
	var score: int = int(_timer * 5) if success else 0
	completed.emit(success, score)
