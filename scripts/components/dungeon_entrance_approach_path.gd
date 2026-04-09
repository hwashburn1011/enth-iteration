class_name DungeonEntranceApproachPath
extends Node3D

## Scene-attached approach path builder. Reads
## EntranceApproachPathDatabase for `entrance_id` and produces:
##
##   1. A Path3D with the descent points so other systems (decals,
##      camera follow, AI patrol) can ride the curve
##   2. Guide markers (lanterns / glyphs / glowmoss stones / silver
##      chains) at evenly-spaced points along the path, each with a
##      child OmniLight3D in the biome accent color
##   3. A signpost at the top of the path (if sign_at_top is true)
##
## Honors the entrance's locked_visible / unlock_iteration so guide
## markers along a sealed entrance dim to 30% energy until the unlock.
##
## Required scene shape:
##   DungeonEntranceApproachPath (Node3D + this script)
##     [no children needed; built at runtime]
##
## Configure via inspector:
##   entrance_id            — must match an EntranceApproachPathDatabase key
##   guide_marker_scene     — optional PackedScene; falls back to small box mesh
##   sign_scene             — optional PackedScene for the entrance sign

const SEALED_DIM_FACTOR: float = 0.30

@export var entrance_id: StringName = &""
@export var guide_marker_scene: PackedScene
@export var sign_scene: PackedScene

var _path: Path3D
var _markers: Array[Node3D] = []
var _sign: Node3D
var _is_sealed: bool = false


func _ready() -> void:
	if entrance_id == &"":
		return
	_resolve_lock_state()
	_build_path()
	_build_markers()
	_build_sign()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_entrance_unlocked"):
			bus.dungeon_entrance_unlocked.connect(_on_entrance_unlocked)


# === BUILD ===

func _build_path() -> void:
	var entry: Dictionary = EntranceApproachPathDatabase.get_path(entrance_id)
	if entry.is_empty():
		return
	_path = Path3D.new()
	_path.name = "ApproachPath"
	var curve: Curve3D = Curve3D.new()
	for point: Vector3 in entry.get("points", []):
		curve.add_point(point)
	_path.curve = curve
	add_child(_path)


func _build_markers() -> void:
	var entry: Dictionary = EntranceApproachPathDatabase.get_path(entrance_id)
	if entry.is_empty() or _path == null or _path.curve == null:
		return
	var count: int = int(entry.get("guide_marker_count", 0))
	if count <= 0:
		return
	var glow_color: Color = entry.get("guide_marker_glow_color", Color.WHITE)
	var dim_factor: float = SEALED_DIM_FACTOR if _is_sealed else 1.0

	var length: float = _path.curve.get_baked_length()
	var step: float = length / float(count + 1)

	for i in range(1, count + 1):
		var t: float = step * float(i)
		var pos: Vector3 = _path.curve.sample_baked(t)
		var marker: Node3D = _create_marker_at(pos, glow_color, dim_factor)
		if marker != null:
			add_child(marker)
			_markers.append(marker)


func _create_marker_at(pos: Vector3, glow_color: Color, dim_factor: float) -> Node3D:
	var marker: Node3D
	if guide_marker_scene != null:
		marker = guide_marker_scene.instantiate() as Node3D
	if marker == null:
		# Fallback: tiny upright box mesh + light
		marker = Node3D.new()
		var mesh: MeshInstance3D = MeshInstance3D.new()
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(0.25, 0.8, 0.25)
		mesh.mesh = box
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.20, 0.20, 0.22, 1.0)
		mat.emission_enabled = true
		mat.emission = glow_color
		mat.emission_energy_multiplier = 1.5 * dim_factor
		mesh.set_surface_override_material(0, mat)
		mesh.position.y = 0.4
		marker.add_child(mesh)

	# Always add an OmniLight3D in the accent color
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = glow_color
	light.light_energy = 1.8 * dim_factor
	light.omni_range = 4.0
	light.shadow_enabled = false
	light.position.y = 0.6
	marker.add_child(light)

	marker.global_position = pos
	return marker


func _build_sign() -> void:
	var entry: Dictionary = EntranceApproachPathDatabase.get_path(entrance_id)
	if entry.is_empty() or not entry.get("sign_at_top", false):
		return
	if _path == null or _path.curve == null:
		return
	var top_point: Vector3 = _path.curve.sample_baked(0.0)
	if sign_scene != null:
		_sign = sign_scene.instantiate() as Node3D
	if _sign == null:
		# Fallback: simple wood-toned post + label3D
		_sign = Node3D.new()
		var post: MeshInstance3D = MeshInstance3D.new()
		var post_mesh: BoxMesh = BoxMesh.new()
		post_mesh.size = Vector3(0.15, 2.2, 0.15)
		post.mesh = post_mesh
		var post_mat: StandardMaterial3D = StandardMaterial3D.new()
		post_mat.albedo_color = Color(0.35, 0.25, 0.15)
		post.set_surface_override_material(0, post_mat)
		post.position.y = 1.1
		_sign.add_child(post)

		var label: Label3D = Label3D.new()
		label.text = entry.get("sign_text", "")
		label.position = Vector3(0, 2.4, 0)
		label.font_size = 32
		label.outline_size = 6
		label.modulate = entry.get("guide_marker_glow_color", Color.WHITE)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_sign.add_child(label)
	add_child(_sign)
	_sign.global_position = top_point


# === LOCK STATE ===

func _resolve_lock_state() -> void:
	var entry: Dictionary = DungeonEntranceDatabase.get_entrance(entrance_id)
	if entry.is_empty():
		return
	var locked_visible: bool = bool(entry.get("locked_visible", false))
	var unlock_iter: int = int(entry.get("unlock_iteration", 0))
	var current_iter: int = _current_iteration()
	_is_sealed = locked_visible and current_iter < unlock_iter


func _on_entrance_unlocked(unlocked_id: StringName) -> void:
	if unlocked_id != entrance_id:
		return
	_is_sealed = false
	# Tween every marker's light back to full intensity
	for marker in _markers:
		var light: OmniLight3D = _find_light_in(marker)
		if light != null:
			create_tween().tween_property(light, "light_energy", 1.8, 2.0)


func _find_light_in(node: Node) -> OmniLight3D:
	for child in node.get_children():
		if child is OmniLight3D:
			return child
	return null


# === HELPERS ===

func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1


# === QUERY ===

func get_path_curve() -> Curve3D:
	if _path == null:
		return null
	return _path.curve
