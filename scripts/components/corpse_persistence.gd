class_name CorpsePersistence
extends Node

## When the parent enemy dies, freeze the rig in its death pose, disable
## physics + AI, lay the corpse on the ground for `linger_seconds`, then
## play a dissolve effect over `dissolve_seconds` and queue_free.
##
## This is the system for Epic 04 task 41 (corpse persistence) but is
## generic to all enemies. The dissolve uses res://assets/shaders/dissolve.gdshader
## with a per-enemy edge color (cyan for GlitchBug, green for MemoryLeak,
## magenta for elites, etc).
##
## Required parent shape:
##   AnyEnemyRoot (Node3D)
##     HealthComponent (or compatible: must emit `died`)
##     MeshInstance3D(s) — collected automatically by walking the tree
##     [optional] CharacterBody3D / RigidBody3D — disabled on death
##     [optional] AIController / state_machine — disabled on death
##
## Configure via inspector:
##   linger_seconds      — seconds the corpse stays visible at full opacity
##   dissolve_seconds    — duration of the fade-out dissolve
##   dissolve_edge_color — color of the dissolve edge band (per-enemy theme)
##   dissolve_noise_path — texture for organic noise dissolve (optional)
##   physics_node_path   — body to disable (CollisionObject3D)
##   ai_node_path        — AI node to disable
##
## Hooked up via:
##   var corpse: CorpsePersistence = CorpsePersistence.new()
##   corpse.linger_seconds = 12.0
##   corpse.dissolve_edge_color = Color(0.0, 0.95, 0.95)
##   enemy_root.add_child(corpse)

@export var linger_seconds: float = 10.0
@export var dissolve_seconds: float = 1.6
@export var dissolve_edge_color: Color = Color(0.0, 0.95, 0.85)
@export_range(0.0, 8.0) var dissolve_edge_width: float = 0.045
@export_range(0.5, 8.0) var dissolve_noise_scale: float = 1.5
@export var dissolve_noise_path: NodePath
@export var health_component_path: NodePath
@export var physics_node_path: NodePath
@export var ai_node_path: NodePath

const DISSOLVE_SHADER_PATH: String = "res://assets/shaders/dissolve.gdshader"

var _dying: bool = false
var _meshes: Array[MeshInstance3D] = []
var _dissolve_materials: Array[ShaderMaterial] = []


func _ready() -> void:
	# Wire to the health component so we react to death
	var hc: Node = get_node_or_null(health_component_path)
	if hc == null:
		# Auto-find on parent — common scene shape
		var parent: Node = get_parent()
		if parent != null:
			for child: Node in parent.get_children():
				if child.has_signal("died"):
					hc = child
					break
	if hc != null and hc.has_signal("died"):
		hc.died.connect(_on_died)
	else:
		push_warning("CorpsePersistence: no HealthComponent with died signal found")


func _on_died() -> void:
	if _dying:
		return
	_dying = true

	# Collect all meshes under the parent so we can swap their materials
	_meshes = _walk_meshes(get_parent())

	# Swap each mesh's material to a duplicated dissolve material so the
	# tween can drive the dissolve uniform without affecting other instances
	var dissolve_shader: Shader = load(DISSOLVE_SHADER_PATH) as Shader
	if dissolve_shader == null:
		push_warning("CorpsePersistence: failed to load dissolve shader at %s" % DISSOLVE_SHADER_PATH)

	for mesh: MeshInstance3D in _meshes:
		_apply_dissolve_to(mesh, dissolve_shader)

	# Disable physics on the body so the corpse just lays there
	_disable_physics()

	# Disable AI so it stops trying to attack from beyond the grave
	_disable_ai()

	# Schedule the dissolve + free
	await get_tree().create_timer(linger_seconds).timeout
	if not is_inside_tree():
		return
	_play_dissolve()


func _apply_dissolve_to(mesh: MeshInstance3D, dissolve_shader: Shader) -> void:
	# For each surface, capture the existing albedo texture + base color and
	# build a fresh ShaderMaterial using the dissolve shader so the source
	# enemy material isn't mutated globally.
	var material_count: int = mesh.get_surface_override_material_count()
	if material_count == 0 and mesh.mesh != null:
		material_count = mesh.mesh.get_surface_count()

	for i: int in material_count:
		var src: Material = mesh.get_surface_override_material(i)
		if src == null and mesh.mesh != null:
			src = mesh.mesh.surface_get_material(i)

		var albedo_tex: Texture2D = null
		var base_col: Color = Color(1, 1, 1, 1)
		if src is StandardMaterial3D:
			var sm: StandardMaterial3D = src as StandardMaterial3D
			albedo_tex = sm.albedo_texture
			base_col = sm.albedo_color

		var dm: ShaderMaterial = ShaderMaterial.new()
		dm.shader = dissolve_shader
		if albedo_tex != null:
			dm.set_shader_parameter("albedo_texture", albedo_tex)
		dm.set_shader_parameter("base_color", base_col)
		dm.set_shader_parameter("dissolve", 0.0)
		dm.set_shader_parameter("edge_width", dissolve_edge_width)
		dm.set_shader_parameter("edge_color", dissolve_edge_color)
		dm.set_shader_parameter("edge_emission_strength", 4.0)
		dm.set_shader_parameter("noise_scale", dissolve_noise_scale)
		dm.set_shader_parameter("noise_variant", 0)

		# Provide a noise texture if configured
		if dissolve_noise_path != null and not dissolve_noise_path.is_empty():
			var noise_tex: Texture2D = get_node_or_null(dissolve_noise_path) as Texture2D
			if noise_tex != null:
				dm.set_shader_parameter("noise_texture", noise_tex)

		mesh.set_surface_override_material(i, dm)
		_dissolve_materials.append(dm)


func _disable_physics() -> void:
	var body: Node = get_node_or_null(physics_node_path)
	if body == null:
		# Auto-find on parent
		var parent: Node = get_parent()
		if parent is CollisionObject3D:
			body = parent
	if body is CollisionObject3D:
		var co: CollisionObject3D = body as CollisionObject3D
		# Disable all collision shapes by zeroing layers; cleaner than
		# walking the children since this also stops raycasts
		co.collision_layer = 0
		co.collision_mask = 0
	if body is CharacterBody3D:
		# Stop velocity so it doesn't keep sliding
		(body as CharacterBody3D).velocity = Vector3.ZERO


func _disable_ai() -> void:
	var ai: Node = get_node_or_null(ai_node_path)
	if ai == null:
		# Auto-find: any node named state_machine or AIController
		var parent: Node = get_parent()
		if parent != null:
			for child: Node in parent.get_children():
				if child.name == "state_machine" or child.name == "AIController":
					ai = child
					break
	if ai != null:
		ai.set_process(false)
		ai.set_physics_process(false)
		ai.set_process_unhandled_input(false)


func _play_dissolve() -> void:
	if _dissolve_materials.is_empty():
		# Nothing to dissolve — just free
		get_parent().queue_free()
		return

	var tw: Tween = create_tween()
	tw.set_parallel(true)
	for dm: ShaderMaterial in _dissolve_materials:
		tw.tween_property(dm, "shader_parameter/dissolve", 1.05, dissolve_seconds) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(_finalize_dissolve)


func _finalize_dissolve() -> void:
	if get_parent() != null:
		get_parent().queue_free()


func _walk_meshes(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		result.append(root)
	for child: Node in root.get_children():
		result.append_array(_walk_meshes(child))
	return result
