extends Node
## WeatherParticleSystem — code-built weather particle follower.
##
## Creates and parents a GPUParticles3D node above the player on weather
## change, configured with a procedurally-built ParticleProcessMaterial
## for the active weather. Saves the project from authoring six separate
## particle scenes by hand and lets us tune particle behavior in code
## alongside everything else.
##
## Listens to:
##   WeatherController.weather_changed
##   WeatherController.thunder_struck (for storm flash particles)
##
## Parents the follower under the player node found in the &"player"
## group at activation time. If the player isn't present (menu, cutscene)
## the follower stays detached and inactive.
##
## Add to project autoloads as "WeatherParticleSystem".

const FOLLOWER_HEIGHT_OFFSET: float = 12.0  # spawn box rides 12m above player
const SPAWN_BOX: Vector3 = Vector3(40, 1, 40)  # 40m × 40m around the player

var _follower: GPUParticles3D
var _current_weather: StringName = &"clear"


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)
		if wc.has_signal("thunder_struck"):
			wc.thunder_struck.connect(_on_thunder_struck)


# === FOLLOWER MANAGEMENT ===

func _ensure_follower() -> void:
	if _follower != null and is_instance_valid(_follower):
		return
	_follower = GPUParticles3D.new()
	_follower.name = "WeatherParticleFollower"
	_follower.amount = 600
	_follower.lifetime = 2.5
	_follower.preprocess = 1.0
	_follower.visibility_aabb = AABB(Vector3(-30, -30, -30), Vector3(60, 60, 60))
	_follower.draw_pass_1 = _build_quad_mesh()
	_follower.process_material = ParticleProcessMaterial.new()
	_follower.emitting = false


func _attach_to_player() -> bool:
	_ensure_follower()
	if _follower.get_parent() != null:
		_follower.get_parent().remove_child(_follower)
	var nodes: Array = get_tree().get_nodes_in_group(&"player")
	if nodes.is_empty():
		return false
	var player: Node3D = nodes[0] as Node3D
	if player == null:
		return false
	player.add_child(_follower)
	_follower.position = Vector3(0, FOLLOWER_HEIGHT_OFFSET, 0)
	return true


# === CONFIG ===

func apply_weather(weather_id: StringName) -> void:
	_current_weather = weather_id

	# Detach for clear weather
	if weather_id == &"clear":
		if _follower != null and is_instance_valid(_follower):
			_follower.emitting = false
		return

	if not _attach_to_player():
		return

	var mat: ParticleProcessMaterial = _follower.process_material
	if mat == null:
		mat = ParticleProcessMaterial.new()
		_follower.process_material = mat

	# Reset to a known baseline
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = SPAWN_BOX
	mat.gravity = Vector3.ZERO
	mat.angular_velocity_min = 0.0
	mat.angular_velocity_max = 0.0
	mat.scale_min = 0.05
	mat.scale_max = 0.10
	mat.color = Color.WHITE
	mat.initial_velocity_min = 0.0
	mat.initial_velocity_max = 0.0

	match weather_id:
		&"rain":
			_configure_rain(mat, 1.0)
		&"storm":
			_configure_rain(mat, 1.6)
			_configure_storm_extras(mat)
		&"fog":
			_configure_fog_motes(mat)
		&"glitch_storm":
			_configure_glitch_sparks(mat)
		&"cloudy":
			# Subtle cloud-shadow flecks
			_configure_cloud_drift(mat)
		_:
			_follower.emitting = false
			return

	_follower.emitting = true
	_follower.restart()


func _configure_rain(mat: ParticleProcessMaterial, intensity: float) -> void:
	_follower.amount = int(700 * intensity)
	_follower.lifetime = 1.4
	mat.gravity = Vector3(2.0, -22.0, 0.0)
	mat.initial_velocity_min = 12.0 * intensity
	mat.initial_velocity_max = 18.0 * intensity
	mat.scale_min = 0.04
	mat.scale_max = 0.08
	mat.color = Color(0.65, 0.78, 0.95, 0.55)
	mat.direction = Vector3(0.1, -1.0, 0.0)
	mat.spread = 5.0


func _configure_storm_extras(mat: ParticleProcessMaterial) -> void:
	# Storm rain is angled by wind
	mat.gravity = Vector3(6.0, -26.0, 0.0)
	mat.spread = 12.0
	mat.color = Color(0.55, 0.68, 0.88, 0.65)


func _configure_fog_motes(mat: ParticleProcessMaterial) -> void:
	_follower.amount = 250
	_follower.lifetime = 6.0
	mat.gravity = Vector3(0.4, -0.2, 0.3)
	mat.initial_velocity_min = 0.2
	mat.initial_velocity_max = 0.6
	mat.scale_min = 0.10
	mat.scale_max = 0.22
	mat.color = Color(0.85, 0.86, 0.90, 0.35)
	mat.direction = Vector3(1.0, 0.0, 0.5)
	mat.spread = 80.0


func _configure_glitch_sparks(mat: ParticleProcessMaterial) -> void:
	_follower.amount = 350
	_follower.lifetime = 1.2
	mat.gravity = Vector3(0.0, -3.0, 0.0)
	mat.initial_velocity_min = 6.0
	mat.initial_velocity_max = 14.0
	mat.scale_min = 0.06
	mat.scale_max = 0.14
	mat.color = Color(0.85, 0.30, 1.00, 0.85)
	mat.direction = Vector3.ZERO
	mat.spread = 180.0
	mat.angular_velocity_min = -180.0
	mat.angular_velocity_max = 180.0


func _configure_cloud_drift(mat: ParticleProcessMaterial) -> void:
	_follower.amount = 80
	_follower.lifetime = 8.0
	mat.gravity = Vector3.ZERO
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.2
	mat.scale_min = 0.30
	mat.scale_max = 0.60
	mat.color = Color(0.85, 0.85, 0.92, 0.18)
	mat.direction = Vector3(1.0, 0.0, 0.4)
	mat.spread = 25.0


# === LIGHTNING FLASH (one-shot on thunder) ===

func _on_thunder_struck() -> void:
	if _current_weather != &"storm":
		return
	# Brief flash via WorldEnvironment exposure spike — request EnvironmentManager
	# to apply a lightning flash burst preset if available
	if has_node("/root/EnvironmentManager"):
		var em: Node = get_node("/root/EnvironmentManager")
		if em.has_method("flash_lightning"):
			em.flash_lightning()


# === MESH ===

func _build_quad_mesh() -> QuadMesh:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.4, 0.4)
	# Use unshaded billboard material so particles read in any lighting
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.use_particle_trails = false
	quad.surface_set_material(0, mat)
	return quad


# === EVENTS ===

func _on_weather_changed(weather_id: StringName) -> void:
	apply_weather(weather_id)
