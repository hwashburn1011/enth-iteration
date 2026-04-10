class_name ModulePickup
extends Area3D

## Module Pickup (Epic 33 task 40).
##
## Drops a module into the world that the player can interact with to add
## to their inventory. Spawned by enemy death, chest interaction, or
## procedural placement in dungeon rooms.
##
## Visual: hovering rotating icon mesh + ground glow ring with pulse,
## scaled and color-tinted by rarity tier (common/uncommon/rare/epic/legendary).
## On player approach, plays an attract animation that homes the module
## toward them. On contact, adds to inventory + plays pickup VFX/SFX.

signal pickup_collected(module_id: StringName, rarity: StringName)
signal pickup_attracted(player_node: Node3D)

const PLAYER_GROUP: StringName = &"player"
const ATTRACT_RADIUS: float = 5.0
const ATTRACT_SPEED: float = 8.0
const COLLECT_DISTANCE: float = 1.0
const HOVER_HEIGHT: float = 0.4
const HOVER_AMP: float = 0.15

@export var module_id: StringName = &""
@export var rarity: StringName = &"common"
@export var class_id: StringName = &"universal"

var _icon_mesh: MeshInstance3D
var _glow_ring: MeshInstance3D
var _player_target: Node3D
var _attracted: bool = false
var _hover_phase: float = 0.0
var _start_height: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1  # player layer
	body_entered.connect(_on_body_entered)
	monitoring = true
	# Build pickup visual
	_build_visual()
	# Detection collider
	var det := CollisionShape3D.new()
	var det_shape := SphereShape3D.new()
	det_shape.radius = ATTRACT_RADIUS
	det.shape = det_shape
	add_child(det)
	# Pickup collider (close)
	var pickup := CollisionShape3D.new()
	var pickup_shape := SphereShape3D.new()
	pickup_shape.radius = COLLECT_DISTANCE
	pickup.shape = pickup_shape
	add_child(pickup)
	_start_height = position.y


func _build_visual() -> void:
	var rarity_color: Color = _color_for_rarity()
	# Floating icon mesh (placeholder torus)
	_icon_mesh = MeshInstance3D.new()
	var icon_mesh := TorusMesh.new()
	icon_mesh.inner_radius = 0.18
	icon_mesh.outer_radius = 0.30
	_icon_mesh.mesh = icon_mesh
	var icon_mat := StandardMaterial3D.new()
	icon_mat.albedo_color = rarity_color
	icon_mat.emission_enabled = true
	icon_mat.emission = rarity_color
	icon_mat.emission_energy_multiplier = 2.0
	icon_mat.metallic = 0.7
	icon_mat.roughness = 0.3
	_icon_mesh.material_override = icon_mat
	_icon_mesh.position = Vector3(0, HOVER_HEIGHT, 0)
	add_child(_icon_mesh)

	# Ground glow ring
	_glow_ring = MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.55
	ring_mesh.outer_radius = 0.65
	_glow_ring.mesh = ring_mesh
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = rarity_color
	ring_mat.emission_enabled = true
	ring_mat.emission = rarity_color
	ring_mat.emission_energy_multiplier = 1.5
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.albedo_color.a = 0.7
	_glow_ring.material_override = ring_mat
	_glow_ring.position = Vector3(0, 0.05, 0)
	add_child(_glow_ring)


func _color_for_rarity() -> Color:
	match rarity:
		&"common": return Color(0.85, 0.85, 0.90)
		&"uncommon": return Color(0.30, 0.85, 0.40)
		&"rare": return Color(0.30, 0.55, 1.00)
		&"epic": return Color(0.75, 0.30, 1.00)
		&"legendary": return Color(1.0, 0.60, 0.10)
	return Color.WHITE


func _process(delta: float) -> void:
	# Hover bob + rotate icon
	_hover_phase += delta
	if _icon_mesh != null:
		_icon_mesh.position.y = HOVER_HEIGHT + sin(_hover_phase * 2.0) * HOVER_AMP
		_icon_mesh.rotate_y(delta * 1.5)
	# Glow ring pulse
	if _glow_ring != null:
		var pulse: float = 0.7 + 0.3 * sin(_hover_phase * 3.0)
		_glow_ring.scale = Vector3(pulse, 1.0, pulse)

	# Attract toward player when in range
	if _attracted and _player_target != null:
		var dir: Vector3 = (_player_target.global_position - global_position).normalized()
		global_position += dir * ATTRACT_SPEED * delta
		if global_position.distance_to(_player_target.global_position) < COLLECT_DISTANCE:
			_collect()


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group(PLAYER_GROUP):
		return
	if not _attracted:
		_attracted = true
		_player_target = body
		pickup_attracted.emit(body)


func _collect() -> void:
	pickup_collected.emit(module_id, rarity)
	# Add to inventory
	if has_node("/root/InventoryManager"):
		var im: Node = get_node("/root/InventoryManager")
		if im.has_method("add_module"):
			im.call("add_module", module_id, rarity, class_id)
	# Play SFX
	if has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		if am.has_method("play_sfx"):
			am.call("play_sfx", StringName("sfx_module_pickup_%s" % rarity))
	# Spawn pickup VFX (radial flash) by deferred-creating an emissive sphere
	var burst := MeshInstance3D.new()
	burst.mesh = SphereMesh.new()
	(burst.mesh as SphereMesh).radius = 0.4
	(burst.mesh as SphereMesh).height = 0.8
	var burst_mat := StandardMaterial3D.new()
	burst_mat.albedo_color = _color_for_rarity()
	burst_mat.emission_enabled = true
	burst_mat.emission = _color_for_rarity()
	burst_mat.emission_energy_multiplier = 6.0
	burst_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	burst_mat.albedo_color.a = 0.7
	burst.material_override = burst_mat
	burst.global_position = global_position
	get_parent().add_child(burst)
	var tween: Tween = burst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(burst, "scale", Vector3(3, 3, 3), 0.35)
	tween.tween_property(burst, "modulate:a", 0.0, 0.35)
	tween.set_parallel(false)
	tween.tween_callback(burst.queue_free)
	queue_free()
