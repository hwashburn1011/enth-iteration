class_name DungeonEntranceAmbience
extends Node3D

## Per-entrance ambient particle bed. Place at a dungeon entrance and
## set `entrance_id` to one of the EntranceParticleProfileDatabase keys
## (server_room / memory_vaults / corrupted_wilds / final_vault). The
## component builds a GPUParticles3D from the matching profile and
## activates it when the player walks into the surrounding Area3D.
##
## Honors the entrance's locked_visible / unlock_iteration flags from
## DungeonEntranceDatabase — sealed entrances dim their particles to
## a faint hint until they unlock.
##
## Required scene shape:
##   DungeonEntranceAmbience (Node3D + this script)
##     Presence (Area3D + CollisionShape3D — radius around the portal)
##
## Configure via inspector:
##   entrance_id  — must match an EntranceParticleProfileDatabase key
##   sealed_dim   — multiplier on amount + scale when sealed (default 0.25)

@export var entrance_id: StringName = &""
@export var sealed_dim_factor: float = 0.25

@onready var _presence: Area3D = $Presence if has_node("Presence") else null

var _particles: GPUParticles3D
var _player_in_range: bool = false
var _is_sealed: bool = false


func _ready() -> void:
	_resolve_lock_state()
	_build_particles()
	if _presence != null:
		_presence.body_entered.connect(_on_player_entered)
		_presence.body_exited.connect(_on_player_exited)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_entrance_unlocked"):
			bus.dungeon_entrance_unlocked.connect(_on_entrance_unlocked)


# === BUILD ===

func _build_particles() -> void:
	if entrance_id == &"":
		return
	var profile: Dictionary = EntranceParticleProfileDatabase.get_profile(entrance_id)
	if profile.is_empty():
		push_warning("DungeonEntranceAmbience: unknown entrance_id '%s'" % entrance_id)
		return

	_particles = GPUParticles3D.new()
	_particles.name = "EntranceParticles"
	add_child(_particles)
	_particles.position = profile.get("emission_box_offset", Vector3.ZERO)

	var dim_mult: float = sealed_dim_factor if _is_sealed else 1.0
	_particles.amount = int(profile.get("amount", 100) * dim_mult)
	_particles.lifetime = profile.get("lifetime", 3.0)
	_particles.preprocess = profile.get("lifetime", 3.0) * 0.5
	_particles.visibility_aabb = AABB(Vector3(-15, -15, -15), Vector3(30, 30, 30))
	_particles.draw_pass_1 = _build_quad_mesh()

	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = profile.get("emission_box_extents", Vector3(5, 1, 5))
	mat.gravity = profile.get("gravity", Vector3.ZERO)
	mat.initial_velocity_min = profile.get("initial_velocity_min", 0.1)
	mat.initial_velocity_max = profile.get("initial_velocity_max", 0.5)

	var sm: float = profile.get("scale_min", 0.05) * (0.6 if _is_sealed else 1.0)
	var sx: float = profile.get("scale_max", 0.15) * (0.6 if _is_sealed else 1.0)
	mat.scale_min = sm
	mat.scale_max = sx

	mat.color = profile.get("color", Color.WHITE)
	mat.angular_velocity_min = profile.get("angular_velocity_min", 0.0)
	mat.angular_velocity_max = profile.get("angular_velocity_max", 0.0)
	mat.direction = profile.get("direction", Vector3.UP)
	mat.spread = profile.get("spread", 30.0)

	_particles.process_material = mat
	_particles.emitting = false


func _build_quad_mesh() -> QuadMesh:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.35, 0.35)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	# Apply emission for the glow color
	var profile: Dictionary = EntranceParticleProfileDatabase.get_profile(entrance_id)
	mat.emission_enabled = true
	mat.emission = profile.get("emission_color", Color.WHITE)
	mat.emission_energy_multiplier = profile.get("emission_energy", 0.6)
	quad.surface_set_material(0, mat)
	return quad


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
	# Rebuild particles at full intensity
	if _particles != null:
		_particles.queue_free()
	_build_particles()
	if _player_in_range and _particles != null:
		_particles.emitting = true


# === PRESENCE ===

func _on_player_entered(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_in_range = true
	if _particles != null:
		_particles.emitting = true


func _on_player_exited(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_in_range = false
	if _particles != null:
		_particles.emitting = false


# === HELPERS ===

func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1
