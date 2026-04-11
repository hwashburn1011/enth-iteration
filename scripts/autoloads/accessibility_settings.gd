extends Node
## AccessibilitySettings autoload — global settings for visual, audio, input,
## and gameplay accessibility. Persisted to user://settings.cfg.
##
## Add to project autoloads as "AccessibilitySettings".

signal setting_changed(key: StringName, value: Variant)

const SETTINGS_PATH: String = "user://settings.cfg"

# === VISUAL ===
@export var colorblind_mode: int = 0  ## 0 None, 1 Protanopia, 2 Deuteranopia, 3 Tritanopia
@export var high_contrast_ui: bool = false
@export var ui_scale: float = 1.0  ## 0.8, 1.0, 1.2, 1.5, 2.0
@export var hud_opacity: float = 1.0  ## 0.0 - 1.0
@export var screen_shake_intensity: float = 1.0  ## 0.0 - 1.5
@export var damage_numbers_mode: int = 1  ## 0 off, 1 numbers, 2 with crit highlights
@export var hitstop_intensity: float = 1.0  ## 0.0 - 1.5

# === AUDIO ===
@export var master_volume: float = 1.0
@export var music_volume: float = 0.8
@export var sfx_volume: float = 1.0
@export var voice_volume: float = 1.0
@export var subtitles_enabled: bool = true
@export var subtitle_size: int = 1  ## 0 small, 1 medium, 2 large, 3 xl
@export var subtitle_background: int = 1  ## 0 none, 1 outline, 2 box

# === INPUT ===
@export var aim_assist_strength: int = 0  ## 0 off, 1 light, 2 medium, 3 strong
@export var auto_aim_mode: int = 0  ## 0 off, 1 hold, 2 toggle
@export var slow_time_on_aim: float = 0.0  ## 0 off, 0.5, 0.25
@export var hold_to_toggle: bool = false

# === GAMEPLAY ===
@export var skip_cinematics: bool = false
@export var auto_pause_on_focus_loss: bool = true
@export var tutorial_reminders_mode: int = 1  ## 0 off, 1 once, 2 always


func _ready() -> void:
	load_settings()


func set_value(key: StringName, value: Variant) -> void:
	if key in self:
		set(key, value)
		setting_changed.emit(key, value)
		save_settings()


func get_value(key: StringName) -> Variant:
	if key in self:
		return get(key)
	return null


# === COLORBLIND HELPERS ===

func get_colorblind_color(base_color: Color) -> Color:
	## Re-tints a base color based on the active colorblind mode.
	## Used by HUD elements to remain distinguishable.
	match colorblind_mode:
		1:  # Protanopia (red-blind)
			return Color(base_color.g, base_color.g, base_color.b, base_color.a)
		2:  # Deuteranopia (green-blind)
			return Color(base_color.r, base_color.r, base_color.b, base_color.a)
		3:  # Tritanopia (blue-blind)
			return Color(base_color.r, base_color.g, base_color.r, base_color.a)
	return base_color


# === SAVE / LOAD ===

func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()

	# Visual
	config.set_value("visual", "colorblind_mode", colorblind_mode)
	config.set_value("visual", "high_contrast_ui", high_contrast_ui)
	config.set_value("visual", "ui_scale", ui_scale)
	config.set_value("visual", "hud_opacity", hud_opacity)
	config.set_value("visual", "screen_shake_intensity", screen_shake_intensity)
	config.set_value("visual", "damage_numbers_mode", damage_numbers_mode)
	config.set_value("visual", "hitstop_intensity", hitstop_intensity)

	# Audio
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "voice_volume", voice_volume)
	config.set_value("audio", "subtitles_enabled", subtitles_enabled)
	config.set_value("audio", "subtitle_size", subtitle_size)
	config.set_value("audio", "subtitle_background", subtitle_background)

	# Input
	config.set_value("input", "aim_assist_strength", aim_assist_strength)
	config.set_value("input", "auto_aim_mode", auto_aim_mode)
	config.set_value("input", "slow_time_on_aim", slow_time_on_aim)
	config.set_value("input", "hold_to_toggle", hold_to_toggle)

	# Gameplay
	config.set_value("gameplay", "skip_cinematics", skip_cinematics)
	config.set_value("gameplay", "auto_pause_on_focus_loss", auto_pause_on_focus_loss)
	config.set_value("gameplay", "tutorial_reminders_mode", tutorial_reminders_mode)

	config.save(SETTINGS_PATH)


func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return  # use defaults

	# Visual
	colorblind_mode = config.get_value("visual", "colorblind_mode", 0)
	high_contrast_ui = config.get_value("visual", "high_contrast_ui", false)
	ui_scale = config.get_value("visual", "ui_scale", 1.0)
	hud_opacity = config.get_value("visual", "hud_opacity", 1.0)
	screen_shake_intensity = config.get_value("visual", "screen_shake_intensity", 1.0)
	damage_numbers_mode = config.get_value("visual", "damage_numbers_mode", 1)
	hitstop_intensity = config.get_value("visual", "hitstop_intensity", 1.0)

	# Audio
	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 0.8)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
	voice_volume = config.get_value("audio", "voice_volume", 1.0)
	subtitles_enabled = config.get_value("audio", "subtitles_enabled", true)
	subtitle_size = config.get_value("audio", "subtitle_size", 1)
	subtitle_background = config.get_value("audio", "subtitle_background", 1)

	# Input
	aim_assist_strength = config.get_value("input", "aim_assist_strength", 0)
	auto_aim_mode = config.get_value("input", "auto_aim_mode", 0)
	slow_time_on_aim = config.get_value("input", "slow_time_on_aim", 0.0)
	hold_to_toggle = config.get_value("input", "hold_to_toggle", false)

	# Gameplay
	skip_cinematics = config.get_value("gameplay", "skip_cinematics", false)
	auto_pause_on_focus_loss = config.get_value("gameplay", "auto_pause_on_focus_loss", true)
	tutorial_reminders_mode = config.get_value("gameplay", "tutorial_reminders_mode", 1)
