class_name EntranceBannerSet
extends Node3D

## Per-entrance decorative banner pair. Spawns two flagpole banners
## flanking the portal mouth, each with a biome-themed emblem and the
## entrance's accent color. Banners physically sway in the wind via
## the WindDirector global shader params (when their material uses
## vertex_wind) and dim if the entrance is sealed.
##
## Required scene shape:
##   EntranceBannerSet (Node3D + this script)
##     [no children needed; pole + cloth meshes built at runtime]
##
## Configure via inspector:
##   entrance_id      — drives biome color + emblem choice
##   pole_separation  — meters between the two flanking poles
##   pole_height      — pole height in meters
##   banner_size      — Vector2 cloth dimensions
##   banner_material  — optional Material; falls back to a tinted
##                      StandardMaterial3D using the entrance accent

const SEALED_ALPHA: float = 0.45

const BANNER_PROFILES: Dictionary = {
	&"server_room": {
		"accent_color": Color(0.55, 0.85, 1.00),
		"pole_color":   Color(0.20, 0.22, 0.28),
		"emblem_text":  "{ }",  # data-bracket emblem
	},
	&"memory_vaults": {
		"accent_color": Color(1.00, 0.85, 0.45),
		"pole_color":   Color(0.30, 0.25, 0.18),
		"emblem_text":  "§",  # archive section sign
	},
	&"corrupted_wilds": {
		"accent_color": Color(0.55, 1.00, 0.55),
		"pole_color":   Color(0.18, 0.16, 0.12),
		"emblem_text":  "✺",  # organic burst
	},
	&"final_vault": {
		"accent_color": Color(0.95, 0.90, 1.00),
		"pole_color":   Color(0.20, 0.18, 0.22),
		"emblem_text":  "VII",  # seven seals
	},
}

@export var entrance_id: StringName = &""
@export var pole_separation: float = 6.0
@export var pole_height: float = 4.5
@export var banner_size: Vector2 = Vector2(1.2, 2.4)
@export var banner_material: Material

var _profile: Dictionary = {}
var _banner_meshes: Array[MeshInstance3D] = []
var _is_sealed: bool = false


func _ready() -> void:
	_profile = BANNER_PROFILES.get(entrance_id, {})
	if _profile.is_empty():
		push_warning("EntranceBannerSet: unknown entrance_id '%s'" % entrance_id)
		return
	_resolve_lock_state()
	_build_pair()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_entrance_unlocked"):
			bus.dungeon_entrance_unlocked.connect(_on_entrance_unlocked)


# === BUILD ===

func _build_pair() -> void:
	_build_one(Vector3(-pole_separation * 0.5, 0, 0))
	_build_one(Vector3( pole_separation * 0.5, 0, 0))


func _build_one(local_offset: Vector3) -> void:
	var pivot: Node3D = Node3D.new()
	pivot.position = local_offset
	add_child(pivot)

	# Pole — slim cylinder
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pole_mesh: CylinderMesh = CylinderMesh.new()
	pole_mesh.top_radius = 0.08
	pole_mesh.bottom_radius = 0.10
	pole_mesh.height = pole_height
	pole.mesh = pole_mesh
	pole.position.y = pole_height * 0.5
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = _profile.get("pole_color", Color(0.25, 0.22, 0.20))
	pole_mat.roughness = 0.7
	pole.set_surface_override_material(0, pole_mat)
	pivot.add_child(pole)

	# Crossbar at the top
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cross_mesh: BoxMesh = BoxMesh.new()
	cross_mesh.size = Vector3(banner_size.x + 0.3, 0.08, 0.08)
	crossbar.mesh = cross_mesh
	crossbar.position.y = pole_height - 0.15
	crossbar.set_surface_override_material(0, pole_mat)
	pivot.add_child(crossbar)

	# Cloth — quad mesh hanging from crossbar
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var quad: QuadMesh = QuadMesh.new()
	quad.size = banner_size
	cloth.mesh = quad
	cloth.position.y = pole_height - 0.2 - banner_size.y * 0.5
	cloth.set_surface_override_material(0, _resolve_banner_material())
	pivot.add_child(cloth)
	_banner_meshes.append(cloth)

	# Emblem label on the cloth
	var emblem: Label3D = Label3D.new()
	emblem.text = _profile.get("emblem_text", "")
	emblem.position = Vector3(0, 0, 0.01)  # in front of the cloth
	emblem.font_size = 96
	emblem.outline_size = 8
	emblem.modulate = Color.WHITE
	emblem.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	emblem.no_depth_test = false
	cloth.add_child(emblem)


func _resolve_banner_material() -> Material:
	if banner_material != null:
		return banner_material
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var accent: Color = _profile.get("accent_color", Color.WHITE)
	mat.albedo_color = Color(accent.r, accent.g, accent.b, SEALED_ALPHA if _is_sealed else 1.0)
	mat.roughness = 0.85
	mat.metallic = 0.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if _is_sealed else BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.emission_enabled = true
	mat.emission = accent
	mat.emission_energy_multiplier = (0.20 if _is_sealed else 0.55)
	return mat


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
	# Tween every banner cloth's emission energy back to full
	for cloth in _banner_meshes:
		var mat: Material = cloth.get_surface_override_material(0)
		if mat is StandardMaterial3D:
			var sm: StandardMaterial3D = mat
			sm.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			create_tween().tween_property(sm, "emission_energy_multiplier", 0.55, 2.0)
			# Albedo alpha back to full
			var c: Color = sm.albedo_color
			create_tween().tween_property(sm, "albedo_color", Color(c.r, c.g, c.b, 1.0), 2.0)


# === HELPERS ===

func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1
