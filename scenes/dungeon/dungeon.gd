extends Node3D
## Root dungeon scene — spawns the player, manages floor progression via FloorManager.

const FLOOR_DATA_PATHS: Array[String] = [
	"res://data/floors/floor_1_tutorial.tres",
	"res://data/floors/floor_2_escalation.tres",
	"res://data/floors/floor_3_exploration.tres",
	"res://data/floors/floor_4_challenge.tres",
	"res://data/floors/floor_5_boss.tres",
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

	# Start with floor 1
	_load_floor(_current_floor_index)


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
	env.tonemap_mode = Environment.TONE_MAP_FILMIC
	env.tonemap_white = 6.0
	# Glow for emission effects
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_bloom = 0.1

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
	push_warning("Dungeon: floor %d completed" % floor_number)
	_current_floor_index += 1
	if _current_floor_index < FLOOR_DATA_PATHS.size():
		_load_floor(_current_floor_index)
	else:
		push_warning("Dungeon: all floors cleared — returning to town")
		EventBus.returned_to_town.emit()
		GameManager.set_meta(&"town_entry_type", "portal_return")
		GameManager.change_scene_to("res://scenes/town/Town.tscn")
