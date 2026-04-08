extends Node3D
## Root dungeon scene — spawns the player, manages floor progression via FloorManager.

const FLOOR_DATA_PATHS: Array[String] = [
	"res://data/floors/floor_1_tutorial.tres",
	"res://data/floors/floor_2_escalation.tres",
	"res://data/floors/floor_3_exploration.tres",
	"res://data/floors/floor_4_challenge.tres",
	"res://data/floors/floor_5_boss.tres",
]

const FLOOR_ACCENT_COLORS: Array[Color] = [
	Color(0.08, 0.4, 0.6),    # Floor 1: cyan (tutorial)
	Color(0.1, 0.55, 0.3),    # Floor 2: green (data sector)
	Color(0.6, 0.5, 0.15),    # Floor 3: amber (exploration)
	Color(0.65, 0.3, 0.1),    # Floor 4: orange (challenge)
	Color(0.6, 0.1, 0.1),     # Floor 5: red (boss)
]

const FLOOR_CONFIGS: Dictionary = {
	2: "res://scripts/dungeon/floor_2_config.gd",
	3: "res://scripts/dungeon/floor_3_config.gd",
	4: "res://scripts/dungeon/floor_4_config.gd",
	5: "res://scripts/dungeon/floor_5_config.gd",
}

var _floor_manager: Node = null
var _current_floor_index: int = 0
var _player: CharacterBody3D = null


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)
	AudioManager.play_music("dungeon_ambient")

	# --- Lighting and Environment ---
	_setup_environment()

	# Spawn player
	var player_scene: PackedScene = load("res://scenes/entities/player/Player.tscn") as PackedScene
	if player_scene:
		_player = player_scene.instantiate() as CharacterBody3D
		add_child(_player)

	# Spawn isometric camera targeting player
	var cam_script: GDScript = load("res://scripts/components/isometric_camera.gd") as GDScript
	var camera: Camera3D = Camera3D.new()
	camera.set_script(cam_script)
	if _player:
		camera.set(&"target", _player)
	add_child(camera)

	# Create FloorManager
	_floor_manager = FloorManager.new()
	_floor_manager.name = "FloorManager"
	add_child(_floor_manager)
	_floor_manager.floor_completed.connect(_on_floor_completed)

	# Spawn HUD
	var hud_scene: PackedScene = load("res://scenes/ui/hud/HUD.tscn") as PackedScene
	if hud_scene:
		var hud: Node = hud_scene.instantiate()
		add_child(hud)

	# Apply saved player data if loading
	SaveManager.apply_to_player(_player)

	# Show "DUNGEON" location label
	_show_location_label("THE DUNGEON")

	# Start with floor 1
	_load_floor(_current_floor_index)


func _show_location_label(location: String) -> void:
	## Brief location label fade-in/out at top of screen
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 85
	var label: Label = Label.new()
	label.text = location
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	label.offset_left = -250
	label.offset_right = 250
	label.offset_top = 80
	label.offset_bottom = 130
	label.add_theme_font_size_override(&"font_size", 32)
	label.add_theme_color_override(&"font_color", Color(0.85, 0.2, 0.15, 0.0))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	add_child(canvas)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "theme_override_colors/font_color:a", 1.0, 0.5)
	tween.tween_interval(2.0)
	tween.tween_property(label, "theme_override_colors/font_color:a", 0.0, 0.7)
	tween.tween_callback(canvas.queue_free)


func _setup_environment() -> void:
	# Directional light — warm, top-left per visual style guide
	var dir_light: DirectionalLight3D = DirectionalLight3D.new()
	dir_light.rotation_degrees = Vector3(-55, -35, 0)
	dir_light.light_energy = 0.8
	dir_light.light_color = Color(1.0, 0.95, 0.85)  # Slightly warm
	dir_light.shadow_enabled = true
	dir_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	add_child(dir_light)

	# Fill light from opposite side (softer, cooler)
	var fill_light: DirectionalLight3D = DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(-40, 145, 0)
	fill_light.light_energy = 0.3
	fill_light.light_color = Color(0.7, 0.8, 1.0)  # Cool blue fill
	fill_light.shadow_enabled = false
	add_child(fill_light)

	# World environment — dungeon atmosphere
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.06, 0.06, 0.1)  # Very dark blue-black
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.2, 0.22, 0.3)  # Cool ambient
	env.ambient_light_energy = 0.5
	# Fog for atmosphere
	env.fog_enabled = true
	env.fog_light_color = Color(0.1, 0.12, 0.18)
	env.fog_density = 0.015
	# Tonemap for better contrast
	env.tonemap_mode = 2 as Environment.ToneMapper  # Filmic
	env.tonemap_white = 6.0
	# Glow for emission effects — stronger to make edge strips and LEDs pop
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_bloom = 0.2
	env.glow_blend_mode = 0 as Environment.GlowBlendMode  # Additive
	# SSAO for depth in enclosed rooms
	env.ssao_enabled = true
	env.ssao_radius = 0.8
	env.ssao_intensity = 0.6
	# Volumetric fog for atmospheric depth
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.02
	env.volumetric_fog_albedo = Color(0.08, 0.1, 0.16)
	env.volumetric_fog_emission = Color(0.04, 0.06, 0.1)
	env.volumetric_fog_emission_energy = 0.3

	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)


func _load_floor(index: int) -> void:
	if index >= FLOOR_DATA_PATHS.size():
		push_warning("Dungeon: all floors completed")
		return
	var data: Resource = load(FLOOR_DATA_PATHS[index]) as Resource
	if data == null:
		push_error("Dungeon: failed to load floor data at index %d" % index)
		return

	# Set floor accent color for room theming
	if index < FLOOR_ACCENT_COLORS.size():
		GameManager.set_meta(&"floor_accent_color", FLOOR_ACCENT_COLORS[index])
		# Update world environment fog to match floor theme
		_update_environment_for_floor(FLOOR_ACCENT_COLORS[index])

	# Set floor-specific room configurator
	var floor_number: int = data.floor_number
	if floor_number in FLOOR_CONFIGS:
		var config_script: GDScript = load(FLOOR_CONFIGS[floor_number]) as GDScript
		if config_script:
			_floor_manager.room_configurator = Callable(config_script, "configure_room")
		else:
			_floor_manager.room_configurator = Callable()
	else:
		_floor_manager.room_configurator = Callable()

	_floor_manager.load_floor(data)


func _on_floor_completed(floor_number: int) -> void:
	_current_floor_index += 1
	# Floor clear celebration
	_show_floor_clear_banner(floor_number)
	if _current_floor_index < FLOOR_DATA_PATHS.size():
		# Brief pause before loading next floor
		await get_tree().create_timer(2.0).timeout
		_load_floor(_current_floor_index)
	else:
		await get_tree().create_timer(2.0).timeout
		EventBus.returned_to_town.emit()
		GameManager.set_meta(&"town_entry_type", "portal_return")
		GameManager.change_scene_to("res://scenes/town/Town.tscn")


func _update_environment_for_floor(accent: Color) -> void:
	## Tint dungeon environment fog + volumetric fog to match floor accent
	var world_env: WorldEnvironment = null
	for child: Node in get_children():
		if child is WorldEnvironment:
			world_env = child as WorldEnvironment
			break
	if world_env == null or world_env.environment == null:
		return
	var env: Environment = world_env.environment
	# Fog tint toward accent
	env.fog_light_color = Color(
		0.08 + accent.r * 0.15,
		0.1 + accent.g * 0.15,
		0.15 + accent.b * 0.15
	)
	# Volumetric fog emission
	env.volumetric_fog_albedo = Color(
		0.06 + accent.r * 0.12,
		0.08 + accent.g * 0.12,
		0.13 + accent.b * 0.15
	)
	env.volumetric_fog_emission = Color(
		0.03 + accent.r * 0.08,
		0.05 + accent.g * 0.08,
		0.08 + accent.b * 0.1
	)
	# Ambient light shift
	env.ambient_light_color = Color(
		0.18 + accent.r * 0.1,
		0.2 + accent.g * 0.1,
		0.28 + accent.b * 0.1
	)


func _show_floor_clear_banner(floor_number: int) -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 85
	var label: Label = Label.new()
	label.text = "FLOOR %d CLEARED" % floor_number
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.offset_left = -200
	label.offset_right = 200
	label.offset_top = -30
	label.offset_bottom = 30
	label.add_theme_font_size_override(&"font_size", 36)
	label.add_theme_color_override(&"font_color", Color(0.3, 0.9, 0.8, 0.0))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	add_child(canvas)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "theme_override_colors/font_color:a", 1.0, 0.3)
	tween.tween_property(label, "scale", Vector2(1.15, 1.15), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_interval(1.2)
	tween.tween_property(label, "theme_override_colors/font_color:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)
	# VFX burst at player position
	if _player and _player.is_inside_tree():
		VFXFactory.spawn_level_up_effect(_player.global_position, get_tree().current_scene)
