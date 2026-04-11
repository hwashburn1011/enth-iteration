class_name RogueProcessShield
extends Node3D

## "Shielded" variant component for the RogueProcess (Epic 06 task 33).
## Wraps the unit in a bubble shield that absorbs damage until the shield
## health is depleted, then collapses with a flash. Designed for the future
## "Sentinel Shielded" sub-archetype but works on any RogueProcess.
##
## Behavior:
##   1) Spawns a sphere mesh sized to the unit's bounding radius
##   2) Applies the existing force_field_bubble.gdshader with cyan tuning
##   3) Listens for damage_taken on the parent's HealthComponent and routes
##      it to the shield until shield_hp depletes
##   4) On hit, animates impact_intensity from 1.0 → 0.0 over 0.4s with the
##      impact_origin_local set to the local hit position so the ripple
##      emanates from the right spot
##   5) When shield_hp <= 0, plays a quick collapse Tween (fresnel rim
##      brightens then alpha fades to 0) and frees the bubble
##   6) Re-emits the residual damage to the actual HealthComponent so the
##      shield doesn't make the unit invincible if hit hard enough
##
## Required scene shape:
##   AnyEnemyRoot (Node3D)
##     RogueProcessShield (Node3D + this script, set max_shield_hp)
##     HealthComponent (with damage_taken signal that returns the amount)
##
## Hookup from a spawn factory:
##   var shield: RogueProcessShield = preload("res://scenes/effects/rogueprocess_shield.tscn").instantiate()
##   shield.max_shield_hp = 60.0
##   enemy_root.add_child(shield)

signal shield_hit(remaining_hp: float)
signal shield_broken

@export var max_shield_hp: float = 60.0
@export var bubble_radius_m: float = 0.85
@export var shield_color: Color = Color(0.30, 0.85, 1.00)
@export var hex_color: Color = Color(0.65, 0.98, 1.00)
@export var health_component_path: NodePath
@export var auto_attach_on_ready: bool = true

const SHIELD_SHADER_PATH: String = "res://assets/shaders/force_field_bubble.gdshader"

var current_shield_hp: float
var _bubble: MeshInstance3D
var _material: ShaderMaterial
var _hc: Node
var _impact_tween: Tween
var _is_broken: bool = false


func _ready() -> void:
	current_shield_hp = max_shield_hp
	if auto_attach_on_ready:
		_build_bubble()
		_connect_health()


func _build_bubble() -> void:
	_bubble = MeshInstance3D.new()
	_bubble.name = "ShieldBubble"
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = bubble_radius_m
	sphere.height = bubble_radius_m * 2.0
	sphere.radial_segments = 32
	sphere.rings = 16
	_bubble.mesh = sphere

	var shader: Shader = load(SHIELD_SHADER_PATH) as Shader
	if shader == null:
		push_warning("RogueProcessShield: force_field_bubble shader missing")
		return
	_material = ShaderMaterial.new()
	_material.shader = shader
	_material.set_shader_parameter("field_color", shield_color)
	_material.set_shader_parameter("hex_color", hex_color)
	_material.set_shader_parameter("impact_color", Color(1.0, 1.0, 1.0))
	_material.set_shader_parameter("hex_scale", 22.0)
	_material.set_shader_parameter("hex_brightness", 1.1)
	_material.set_shader_parameter("pulse_speed", 2.0)
	_material.set_shader_parameter("fresnel_power", 2.6)
	_material.set_shader_parameter("is_shield", true)
	_material.set_shader_parameter("impact_intensity", 0.0)
	_bubble.material_override = _material
	_bubble.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_bubble)


func _connect_health() -> void:
	_hc = get_node_or_null(health_component_path)
	if _hc == null:
		var parent: Node = get_parent()
		if parent != null:
			for child: Node in parent.get_children():
				if child.has_signal("damage_taken"):
					_hc = child
					break
	if _hc != null and _hc.has_signal("damage_taken"):
		_hc.damage_taken.connect(_on_damage_taken)


func _on_damage_taken(amount: float) -> void:
	if _is_broken:
		return
	# Pull a hit position if the HealthComponent provides one
	var hit_local: Vector3 = Vector3.ZERO
	if _hc.has_method("get_last_hit_position"):
		var world_hit: Vector3 = _hc.get_last_hit_position()
		hit_local = to_local(world_hit)
	_play_impact(hit_local)
	current_shield_hp -= amount
	shield_hit.emit(current_shield_hp)
	if current_shield_hp <= 0.0:
		_break_shield()


func _play_impact(local_pos: Vector3) -> void:
	if _material == null:
		return
	_material.set_shader_parameter("impact_origin_local", local_pos)
	_material.set_shader_parameter("impact_intensity", 1.0)
	if _impact_tween != null and _impact_tween.is_valid():
		_impact_tween.kill()
	_impact_tween = create_tween()
	_impact_tween.tween_method(_set_impact, 1.0, 0.0, 0.4)


func _set_impact(value: float) -> void:
	if _material != null:
		_material.set_shader_parameter("impact_intensity", value)


func _break_shield() -> void:
	if _is_broken:
		return
	_is_broken = true
	shield_broken.emit()
	# Quick flash + fade
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_method(_set_impact, 1.5, 0.0, 0.5)
	tw.tween_method(_set_hex_brightness, 1.1, 0.0, 0.5)
	tw.chain().tween_callback(queue_free)


func _set_hex_brightness(value: float) -> void:
	if _material != null:
		_material.set_shader_parameter("hex_brightness", value)


func absorb_damage(amount: float) -> float:
	## Public API: returns the residual damage that should be passed through
	## to the HealthComponent (0 if shield absorbed it fully).
	if _is_broken:
		return amount
	var absorbed: float = min(amount, current_shield_hp)
	current_shield_hp -= absorbed
	shield_hit.emit(current_shield_hp)
	if current_shield_hp <= 0.0:
		_break_shield()
	return amount - absorbed
