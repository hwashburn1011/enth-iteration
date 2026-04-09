class_name DungeonEntrancePortalSurface
extends Node3D

## The visible portal energy surface inside each carved monument — the
## swirling void plane the player actually steps through. Procedurally
## builds a quad mesh with a ShaderMaterial that animates a swirling
## energy pattern in the biome accent color. The shader uses the
## existing portal_swirl.gdshader if present, otherwise falls back to
## a hand-built StandardMaterial3D with emission animation.
##
## Honors locked_visible / unlock_iteration: sealed surfaces dim to
## 25% intensity AND show a chain overlay quad on top until the unlock.
##
## Required scene shape:
##   DungeonEntrancePortalSurface (Node3D + this script)
##     [no children needed; built at runtime]
##
## Configure via inspector:
##   entrance_id    — drives biome accent color + intensity profile
##   surface_size   — quad dimensions (default 4x6, monument-mouth sized)

const PROFILES: Dictionary = {
	&"server_room": {
		"primary_color":   Color(0.30, 0.65, 1.00),
		"secondary_color": Color(0.10, 0.30, 0.85),
		"swirl_speed":  0.6,
		"intensity":    1.6,
		"distortion":   0.30,
	},
	&"memory_vaults": {
		"primary_color":   Color(1.00, 0.85, 0.40),
		"secondary_color": Color(0.85, 0.55, 0.10),
		"swirl_speed":  0.35,
		"intensity":    1.4,
		"distortion":   0.20,
	},
	&"corrupted_wilds": {
		"primary_color":   Color(0.50, 1.00, 0.55),
		"secondary_color": Color(0.20, 0.65, 0.25),
		"swirl_speed":  0.85,
		"intensity":    1.8,
		"distortion":   0.45,
	},
	&"final_vault": {
		"primary_color":   Color(0.95, 0.90, 1.00),
		"secondary_color": Color(0.55, 0.45, 0.85),
		"swirl_speed":  0.20,
		"intensity":    2.2,
		"distortion":   0.18,
	},
}

const SEALED_DIM_FACTOR: float = 0.25
const PORTAL_SHADER_PATH: String = "res://assets/shaders/portal_swirl.gdshader"

@export var entrance_id: StringName = &""
@export var surface_size: Vector2 = Vector2(4.0, 6.0)

var _surface: MeshInstance3D
var _seal_overlay: MeshInstance3D
var _profile: Dictionary = {}
var _shader_material: ShaderMaterial
var _is_sealed: bool = false


func _ready() -> void:
	_profile = PROFILES.get(entrance_id, {})
	if _profile.is_empty():
		push_warning("DungeonEntrancePortalSurface: unknown entrance_id '%s'" % entrance_id)
		return
	_resolve_lock_state()
	_build_surface()
	if _is_sealed:
		_build_seal_overlay()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_entrance_unlocked"):
			bus.dungeon_entrance_unlocked.connect(_on_entrance_unlocked)


# === BUILD ===

func _build_surface() -> void:
	_surface = MeshInstance3D.new()
	_surface.name = "PortalEnergy"
	var quad: QuadMesh = QuadMesh.new()
	quad.size = surface_size
	_surface.mesh = quad
	_surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Try to use the project's portal_swirl shader; fall back to a
	# hand-built emissive standard material if it doesn't exist
	if ResourceLoader.exists(PORTAL_SHADER_PATH):
		_shader_material = ShaderMaterial.new()
		_shader_material.shader = load(PORTAL_SHADER_PATH) as Shader
		var dim: float = SEALED_DIM_FACTOR if _is_sealed else 1.0
		_shader_material.set_shader_parameter(&"primary_color",   _profile.get("primary_color", Color.WHITE))
		_shader_material.set_shader_parameter(&"secondary_color", _profile.get("secondary_color", Color.WHITE))
		_shader_material.set_shader_parameter(&"swirl_speed",     float(_profile.get("swirl_speed", 0.5)))
		_shader_material.set_shader_parameter(&"intensity",       float(_profile.get("intensity", 1.0)) * dim)
		_shader_material.set_shader_parameter(&"distortion",      float(_profile.get("distortion", 0.3)))
		_surface.set_surface_override_material(0, _shader_material)
	else:
		_apply_fallback_material()

	add_child(_surface)
	# Position the surface 0.05m forward of the monument face so it sits
	# inside the carved opening rather than clipping the wall
	_surface.position = Vector3(0, surface_size.y * 0.5, 0.05)


func _apply_fallback_material() -> void:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var dim: float = SEALED_DIM_FACTOR if _is_sealed else 1.0
	mat.albedo_color = _profile.get("secondary_color", Color.WHITE)
	mat.emission_enabled = true
	mat.emission = _profile.get("primary_color", Color.WHITE)
	mat.emission_energy_multiplier = float(_profile.get("intensity", 1.0)) * dim * 2.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color.a = 0.85 if not _is_sealed else 0.45
	_surface.set_surface_override_material(0, mat)


func _build_seal_overlay() -> void:
	## Visible chain/seal overlay shown over the dimmed portal surface
	## while the entrance is iteration-locked. Removed on unlock.
	_seal_overlay = MeshInstance3D.new()
	_seal_overlay.name = "SealOverlay"
	var quad: QuadMesh = QuadMesh.new()
	quad.size = surface_size * 1.05
	_seal_overlay.mesh = quad
	_seal_overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.85, 0.95, 0.75)
	mat.emission_enabled = true
	mat.emission = Color(0.85, 0.85, 1.00)
	mat.emission_energy_multiplier = 0.60
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Use the existing dissolve shader path if present for the chain look
	var dissolve_path: String = "res://assets/textures/portal/seven_seals_overlay.png"
	if ResourceLoader.exists(dissolve_path):
		mat.albedo_texture = load(dissolve_path) as Texture2D
	_seal_overlay.set_surface_override_material(0, mat)
	add_child(_seal_overlay)
	_seal_overlay.position = Vector3(0, surface_size.y * 0.5, 0.06)


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
	_unseal_animated()


func _unseal_animated() -> void:
	# Tween the surface intensity back to full
	var target_intensity: float = float(_profile.get("intensity", 1.0))
	if _shader_material != null:
		var tw: Tween = create_tween()
		tw.tween_method(
			_set_shader_intensity,
			float(_shader_material.get_shader_parameter(&"intensity")),
			target_intensity,
			2.5
		)
	elif _surface != null:
		var mat: Material = _surface.get_surface_override_material(0)
		if mat is StandardMaterial3D:
			var sm: StandardMaterial3D = mat
			create_tween().tween_property(sm, "emission_energy_multiplier", target_intensity * 2.0, 2.5)
			var c: Color = sm.albedo_color
			create_tween().tween_property(sm, "albedo_color", Color(c.r, c.g, c.b, 0.85), 2.5)

	# Fade out the seal overlay
	if _seal_overlay != null:
		var mat: Material = _seal_overlay.get_surface_override_material(0)
		if mat is StandardMaterial3D:
			var sm: StandardMaterial3D = mat
			var tw: Tween = create_tween()
			tw.tween_property(sm, "albedo_color", Color(sm.albedo_color.r, sm.albedo_color.g, sm.albedo_color.b, 0.0), 2.0)
			tw.tween_callback(func() -> void:
				if is_instance_valid(_seal_overlay):
					_seal_overlay.queue_free()
			)


func _set_shader_intensity(v: float) -> void:
	if _shader_material != null:
		_shader_material.set_shader_parameter(&"intensity", v)


# === HELPERS ===

func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1


# === QUERY ===

func get_surface() -> MeshInstance3D:
	return _surface
