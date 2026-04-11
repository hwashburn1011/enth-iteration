class_name LoadingScreen
extends Control

## Per-entrance loading screen controller. On `show_for(screen_id)`, looks
## up the LoadingScreenDatabase entry, applies the theme color to UI
## elements, loads the background art if it exists, rolls a fresh tip,
## plays the sting, and animates a progress bar driven by an external
## progress value (set via `set_progress(0..1)`).
##
## Required scene shape:
##   LoadingScreen (Control + this script)
##     %Background (TextureRect — fades in with the theme)
##     %ThemeOverlay (ColorRect — full-screen tint at low alpha)
##     %TitleLabel (Label — display_name)
##     %SubtitleLabel (Label — subtitle italic)
##     %TipLabel (Label — rolled tip text)
##     %TipCategoryLabel (Label — small "HINT" / "LORE" tag)
##     %ProgressBar (ProgressBar)
##     %AccentBar (ColorRect — single accent line above the progress bar)

signal loading_finished

const BACKGROUND_BASE_PATH: String = "res://assets/textures/loading_screens/"
const FADE_IN_DURATION: float = 0.5
const TIP_ROTATION_INTERVAL_S: float = 6.0

@onready var _background: TextureRect = %Background
@onready var _theme_overlay: ColorRect = %ThemeOverlay
@onready var _title_label: Label = %TitleLabel
@onready var _subtitle_label: Label = %SubtitleLabel
@onready var _tip_label: Label = %TipLabel
@onready var _tip_category_label: Label = %TipCategoryLabel
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _accent_bar: ColorRect = %AccentBar

var _current_screen_id: StringName = &""
var _tip_rotation_timer: float = 0.0


func _ready() -> void:
	visible = false


func _process(delta: float) -> void:
	if not visible or _current_screen_id == &"":
		return
	_tip_rotation_timer += delta
	if _tip_rotation_timer >= TIP_ROTATION_INTERVAL_S:
		_tip_rotation_timer = 0.0
		_roll_new_tip()


# === SHOW / HIDE ===

func show_for(screen_id: StringName) -> void:
	_current_screen_id = screen_id
	var entry: Dictionary = LoadingScreenDatabase.get_screen(screen_id)
	if entry.is_empty():
		push_warning("LoadingScreen: unknown screen '%s'" % screen_id)
		return

	# Apply theme
	var theme_color: Color = entry.get("theme_color", Color.WHITE)
	var accent_color: Color = entry.get("accent_color", Color.WHITE)
	if _theme_overlay != null:
		_theme_overlay.color = Color(theme_color.r, theme_color.g, theme_color.b, 0.35)
	if _accent_bar != null:
		_accent_bar.color = accent_color
	if _title_label != null:
		_title_label.text = entry.get("display_name", "")
		_title_label.add_theme_color_override(&"font_color", accent_color)
	if _subtitle_label != null:
		_subtitle_label.text = entry.get("subtitle", "")
	if _progress_bar != null:
		_progress_bar.value = 0.0
		_apply_progress_bar_color(accent_color)

	# Load background art
	var bg_id: StringName = entry.get("background_id", &"")
	if _background != null:
		if bg_id != &"":
			var path: String = BACKGROUND_BASE_PATH + String(bg_id) + ".png"
			if ResourceLoader.exists(path):
				_background.texture = load(path) as Texture2D
			else:
				_background.texture = null
		_background.modulate = Color(1, 1, 1, 0)

	# Roll initial tip
	_roll_new_tip()

	# Sting
	var sting_id: StringName = entry.get("sting_id", &"")
	if sting_id != &"" and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(sting_id)

	visible = true
	_fade_in()


func hide_screen() -> void:
	visible = false
	_current_screen_id = &""
	loading_finished.emit()


# === PROGRESS ===

func set_progress(value: float) -> void:
	if _progress_bar != null:
		_progress_bar.value = clampf(value, 0.0, 1.0) * 100.0
	if value >= 1.0:
		# Brief settle delay before hiding
		var t: SceneTreeTimer = get_tree().create_timer(0.4)
		t.timeout.connect(hide_screen)


# === TIPS ===

func _roll_new_tip() -> void:
	var tip: Dictionary = LoadingScreenDatabase.roll_tip(_current_screen_id)
	if tip.is_empty():
		return
	if _tip_label != null:
		_tip_label.text = tip.get("text", "")
	if _tip_category_label != null:
		var category: StringName = tip.get("category", &"")
		_tip_category_label.text = String(category).to_upper()
		_tip_category_label.add_theme_color_override(&"font_color", _category_color(category))


func _category_color(category: StringName) -> Color:
	match category:
		&"hint":     return Color(0.65, 0.85, 1.00)  # cyan
		&"gameplay": return Color(1.00, 0.85, 0.40)  # gold
		&"lore":     return Color(0.85, 0.65, 1.00)  # purple
	return Color.WHITE


# === FADE ===

func _fade_in() -> void:
	if _background == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_background, "modulate:a", 1.0, FADE_IN_DURATION)


func _apply_progress_bar_color(accent: Color) -> void:
	if _progress_bar == null:
		return
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = accent
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_left = 2
	fill_style.corner_radius_bottom_right = 2
	_progress_bar.add_theme_stylebox_override(&"fill", fill_style)
