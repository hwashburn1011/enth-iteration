class_name PackLeaderAura
extends Node3D

## Visual + behavior tag for "pack leader" enemy variants. When active,
## projects a colored Fresnel aura sphere around the parent and broadcasts
## a buff signal to nearby allies via EventBus.
##
## Two distinct visuals:
##   - Aura sphere (energy_aura.gdshader) that pulses around the leader
##   - Tether beams to currently-buffed pack members (built lazily as
##     they enter range, freed when they leave or die)
##
## The aura color encodes the buff TYPE so players can read what's being
## granted at a glance:
##   cyan    = +damage  (most common — the basic GlitchBug pack leader)
##   magenta = +speed
##   amber   = +armor
##   green   = healing pulse (brief flash on every tick)
##
## Required scene shape:
##   PackLeaderAura (Node3D + this script)
##     [aura sphere mesh added at runtime — no children needed]
##
## Configure via inspector:
##   aura_radius_m       — sphere radius (default 1.6m)
##   buff_radius_m       — gameplay range for the buff effect (default 6m)
##   pulse_color_inner   — center color (default cyan)
##   pulse_color_outer   — edge color (default deep blue)
##   buff_type           — StringName broadcast on the EventBus signal
##   tether_visible      — draw beam lines to buffed allies (cosmetic, default true)
##
## Hooked from gameplay:
##   var aura: PackLeaderAura = PackLeaderAura.new()
##   aura.buff_type = &"damage"
##   aura.pulse_color_inner = Color(0.0, 0.95, 0.85)
##   enemy_root.add_child(aura)

@export var aura_radius_m: float = 1.6
@export var buff_radius_m: float = 6.0
@export var pulse_color_inner: Color = Color(0.0, 0.95, 0.85)
@export var pulse_color_outer: Color = Color(0.05, 0.20, 0.95)
@export_range(0.0, 8.0) var pulse_speed: float = 2.0
@export_range(0.0, 5.0) var intensity: float = 2.4
@export var buff_type: StringName = &"damage"
@export var tether_visible: bool = true
@export var rescan_interval_s: float = 0.5

const AURA_SHADER_PATH: String = "res://assets/shaders/energy_aura.gdshader"

var _aura_mesh: MeshInstance3D
var _aura_material: ShaderMaterial
var _tether_lines: Dictionary = {}  # ally_node -> ImmediateMesh node
var _tracked_allies: Array[Node3D] = []
var _scan_timer: float = 0.0


func _ready() -> void:
	_build_aura()


func _build_aura() -> void:
	_aura_mesh = MeshInstance3D.new()
	_aura_mesh.name = "AuraSphere"
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = aura_radius_m
	sphere.height = aura_radius_m * 2.0
	_aura_mesh.mesh = sphere
	# Render outside-in so the back faces are visible from outside the sphere
	_aura_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var shader: Shader = load(AURA_SHADER_PATH) as Shader
	_aura_material = ShaderMaterial.new()
	_aura_material.shader = shader
	_aura_material.set_shader_parameter("aura_inner", pulse_color_inner)
	_aura_material.set_shader_parameter("aura_outer", pulse_color_outer)
	_aura_material.set_shader_parameter("pulse_speed", pulse_speed)
	_aura_material.set_shader_parameter("pulse_amount", 0.20)
	_aura_material.set_shader_parameter("intensity", intensity)
	_aura_material.set_shader_parameter("falloff", 2.5)
	_aura_mesh.material_override = _aura_material
	add_child(_aura_mesh)


func _process(delta: float) -> void:
	_scan_timer += delta
	if _scan_timer >= rescan_interval_s:
		_scan_timer = 0.0
		_rescan_allies()
	if tether_visible:
		_update_tethers()


func _rescan_allies() -> void:
	## Find allies in buff_radius_m and update tracking lists. Allies are any
	## Node3D in the "enemies" group within range that isn't the parent itself.
	var origin: Vector3 = global_position
	var prev: Array[Node3D] = _tracked_allies.duplicate()
	_tracked_allies.clear()

	var tree: SceneTree = get_tree()
	if tree == null:
		return
	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or node == get_parent():
			continue
		var n3d: Node3D = node as Node3D
		if origin.distance_to(n3d.global_position) <= buff_radius_m:
			_tracked_allies.append(n3d)

	# Allies that LEFT the range — remove tether and broadcast buff_lost
	for ally: Node3D in prev:
		if not _tracked_allies.has(ally):
			_remove_tether(ally)
			_broadcast_buff_change(ally, false)

	# Allies that ENTERED the range — broadcast buff_gained
	for ally: Node3D in _tracked_allies:
		if not prev.has(ally):
			_broadcast_buff_change(ally, true)


func _broadcast_buff_change(ally: Node3D, gained: bool) -> void:
	# Use a direct method call if the ally has it, otherwise just emit
	# via EventBus if available
	if ally.has_method("on_pack_leader_buff_changed"):
		ally.call("on_pack_leader_buff_changed", buff_type, gained)
	var bus: Node = get_node_or_null("/root/EventBus")
	if bus != null and bus.has_signal("pack_leader_buff_changed"):
		bus.emit_signal("pack_leader_buff_changed", buff_type, ally, gained)


func _update_tethers() -> void:
	# Free tether lines for allies that no longer exist
	var stale: Array = []
	for ally_key: Variant in _tether_lines.keys():
		if not is_instance_valid(ally_key) or not _tracked_allies.has(ally_key):
			stale.append(ally_key)
	for s: Variant in stale:
		_remove_tether(s)

	# Build/update tethers for current allies
	for ally: Node3D in _tracked_allies:
		_ensure_tether(ally)


func _ensure_tether(ally: Node3D) -> void:
	if not is_instance_valid(ally):
		return
	var line: MeshInstance3D = _tether_lines.get(ally)
	if line == null:
		line = MeshInstance3D.new()
		line.name = "Tether_%s" % ally.name
		line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(line)
		_tether_lines[ally] = line

	# Build a thin cylinder from this aura's center to the ally
	var from_pos: Vector3 = global_position
	var to_pos: Vector3 = ally.global_position
	var dist: float = from_pos.distance_to(to_pos)
	if dist < 0.05:
		line.visible = false
		return
	line.visible = true

	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = 0.04
	cyl.bottom_radius = 0.04
	cyl.height = dist
	line.mesh = cyl

	# Material — additive emissive line in the same hue as the aura
	if line.material_override == null:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(pulse_color_inner.r, pulse_color_inner.g, pulse_color_inner.b, 0.6)
		mat.emission_enabled = true
		mat.emission = pulse_color_inner
		mat.emission_energy_multiplier = 2.0
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		line.material_override = mat

	# Orient the cylinder along the segment from leader to ally
	var mid: Vector3 = (from_pos + to_pos) * 0.5
	line.global_position = mid
	# CylinderMesh defaults to +Y. Rotate to point at ally
	var dir: Vector3 = (to_pos - from_pos).normalized()
	if absf(dir.dot(Vector3.UP)) < 0.999:
		line.look_at(to_pos, Vector3.UP)
		# look_at points -Z; rotate so cylinder Y aligns with -Z
		line.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))


func _remove_tether(ally_key: Variant) -> void:
	if _tether_lines.has(ally_key):
		var line: Node = _tether_lines[ally_key]
		if is_instance_valid(line):
			line.queue_free()
		_tether_lines.erase(ally_key)


func set_active(active: bool) -> void:
	## Toggle the visual + behavior. Use to hide the aura during stagger or
	## when the leader is mind-controlled.
	visible = active
	set_process(active)
	if not active:
		for ally: Node3D in _tracked_allies:
			_broadcast_buff_change(ally, false)
		_tracked_allies.clear()
		for k: Variant in _tether_lines.keys():
			_remove_tether(k)
