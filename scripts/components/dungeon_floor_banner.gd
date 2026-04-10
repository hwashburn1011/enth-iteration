class_name DungeonFloorBanner
extends CanvasLayer

## Dungeon Floor Name + Difficulty Banner (Epic 30 tasks 45 & 46).
##
## Animated full-width banner that swoops in from the top when the player
## enters a new floor. Displays:
##   - Floor number ("FLOOR 04")
##   - Floor name ("Boss Approach")
##   - Biome label ("Sanctum Approach")
##   - Difficulty stars (1-5)
##   - Recommended level
##
## Total animation: 0.5s slide-in → 2.8s hold → 0.5s slide-out (3.8s total)
## Drawn entirely from Control nodes — ships with no textures.
##
## Hook:
##   var banner := DungeonFloorBanner.new()
##   add_child(banner)
##   banner.show_floor_banner(4, "Boss Approach", "Sanctum Approach", 4, 18)

signal banner_started
signal banner_finished

const SLIDE_IN_DURATION: float = 0.5
const HOLD_DURATION: float = 2.8
const SLIDE_OUT_DURATION: float = 0.5

var _root: Control
var _bg_strip: ColorRect
var _accent_strip: ColorRect
var _floor_number_label: Label
var _floor_name_label: Label
var _biome_label: Label
var _difficulty_stars: Label
var _level_label: Label
var _is_running: bool = false
var _elapsed: float = 0.0


func _ready() -> void:
	layer = 90
	_build_ui()
	_hide_all()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	# Background strip (full width, centered vertically)
	_bg_strip = ColorRect.new()
	_bg_strip.anchor_left = 0.0
	_bg_strip.anchor_right = 1.0
	_bg_strip.anchor_top = 0.18
	_bg_strip.anchor_bottom = 0.18
	_bg_strip.offset_top = -90
	_bg_strip.offset_bottom = 90
	_bg_strip.color = Color(0.04, 0.06, 0.12, 0.92)
	_root.add_child(_bg_strip)

	# Gold accent strip top + bottom of bg
	_accent_strip = ColorRect.new()
	_accent_strip.anchor_left = 0.0
	_accent_strip.anchor_right = 1.0
	_accent_strip.anchor_top = 0.18
	_accent_strip.anchor_bottom = 0.18
	_accent_strip.offset_top = -90
	_accent_strip.offset_bottom = -86
	_accent_strip.color = Color(0.95, 0.78, 0.30, 1.0)
	_root.add_child(_accent_strip)

	var accent_bottom := ColorRect.new()
	accent_bottom.anchor_left = 0.0
	accent_bottom.anchor_right = 1.0
	accent_bottom.anchor_top = 0.18
	accent_bottom.anchor_bottom = 0.18
	accent_bottom.offset_top = 86
	accent_bottom.offset_bottom = 90
	accent_bottom.color = Color(0.95, 0.78, 0.30, 1.0)
	_root.add_child(accent_bottom)

	# Floor number (huge)
	_floor_number_label = Label.new()
	_floor_number_label.anchor_left = 0.0
	_floor_number_label.anchor_right = 1.0
	_floor_number_label.anchor_top = 0.18
	_floor_number_label.anchor_bottom = 0.18
	_floor_number_label.offset_top = -75
	_floor_number_label.offset_bottom = -25
	_floor_number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_floor_number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_floor_number_label.add_theme_font_size_override("font_size", 28)
	_floor_number_label.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_floor_number_label.add_theme_constant_override("outline_size", 4)
	_floor_number_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_root.add_child(_floor_number_label)

	# Floor name (large)
	_floor_name_label = Label.new()
	_floor_name_label.anchor_left = 0.0
	_floor_name_label.anchor_right = 1.0
	_floor_name_label.anchor_top = 0.18
	_floor_name_label.anchor_bottom = 0.18
	_floor_name_label.offset_top = -25
	_floor_name_label.offset_bottom = 25
	_floor_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_floor_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_floor_name_label.add_theme_font_size_override("font_size", 56)
	_floor_name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	_floor_name_label.add_theme_constant_override("outline_size", 6)
	_floor_name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	_root.add_child(_floor_name_label)

	# Biome label (small)
	_biome_label = Label.new()
	_biome_label.anchor_left = 0.0
	_biome_label.anchor_right = 1.0
	_biome_label.anchor_top = 0.18
	_biome_label.anchor_bottom = 0.18
	_biome_label.offset_top = 30
	_biome_label.offset_bottom = 55
	_biome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_biome_label.add_theme_font_size_override("font_size", 18)
	_biome_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92))
	_root.add_child(_biome_label)

	# Difficulty stars (under biome)
	_difficulty_stars = Label.new()
	_difficulty_stars.anchor_left = 0.0
	_difficulty_stars.anchor_right = 0.5
	_difficulty_stars.anchor_top = 0.18
	_difficulty_stars.anchor_bottom = 0.18
	_difficulty_stars.offset_top = 55
	_difficulty_stars.offset_bottom = 80
	_difficulty_stars.offset_right = -10
	_difficulty_stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_difficulty_stars.add_theme_font_size_override("font_size", 22)
	_difficulty_stars.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	_root.add_child(_difficulty_stars)

	# Recommended level
	_level_label = Label.new()
	_level_label.anchor_left = 0.5
	_level_label.anchor_right = 1.0
	_level_label.anchor_top = 0.18
	_level_label.anchor_bottom = 0.18
	_level_label.offset_top = 55
	_level_label.offset_bottom = 80
	_level_label.offset_left = 10
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_level_label.add_theme_font_size_override("font_size", 18)
	_level_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_root.add_child(_level_label)


func _hide_all() -> void:
	_root.modulate.a = 0.0
	_root.position = Vector2.ZERO


func show_floor_banner(floor_number: int, floor_name: String, biome: String, difficulty: int, recommended_level: int) -> void:
	if _is_running:
		return
	_floor_number_label.text = "FLOOR %02d" % floor_number
	_floor_name_label.text = floor_name
	_biome_label.text = biome.to_upper()
	_difficulty_stars.text = "DIFFICULTY: %s%s" % [
		"★".repeat(clamp(difficulty, 1, 5)),
		"☆".repeat(5 - clamp(difficulty, 1, 5)),
	]
	_level_label.text = "RECOMMENDED LV %d" % recommended_level
	_is_running = true
	_elapsed = 0.0
	_root.modulate.a = 0.0
	banner_started.emit()
	set_process(true)


func _process(delta: float) -> void:
	if not _is_running:
		return
	_elapsed += delta

	# Stage 1: slide in (0.0 → 0.5)
	if _elapsed <= SLIDE_IN_DURATION:
		var t: float = _elapsed / SLIDE_IN_DURATION
		var ease_t: float = 1.0 - pow(1.0 - t, 3.0)
		_root.modulate.a = ease_t
		_root.position = Vector2(0, lerp(-200.0, 0.0, ease_t))

	# Stage 2: hold (0.5 → 3.3)
	elif _elapsed <= SLIDE_IN_DURATION + HOLD_DURATION:
		_root.modulate.a = 1.0
		_root.position = Vector2.ZERO

	# Stage 3: slide out (3.3 → 3.8)
	elif _elapsed <= SLIDE_IN_DURATION + HOLD_DURATION + SLIDE_OUT_DURATION:
		var t: float = (_elapsed - SLIDE_IN_DURATION - HOLD_DURATION) / SLIDE_OUT_DURATION
		var ease_t: float = pow(t, 2.0)
		_root.modulate.a = 1.0 - ease_t
		_root.position = Vector2(0, lerp(0.0, -200.0, ease_t))

	else:
		_is_running = false
		set_process(false)
		_hide_all()
		banner_finished.emit()
