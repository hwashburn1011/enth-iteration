class_name FreezeStatus
extends Node

## "Freezing" status effect that crystallizes the parent enemy. Built
## specifically for the MemoryLeak (Epic 05 task 48) but reusable on
## any enemy that should respond to cold damage by stopping in place.
##
## When freeze stacks reach freeze_threshold (default 4), the enemy:
##   - Plays the freeze visual: rapidly tints toward ice blue, snaps
##     to a still pose, gets a crystal sheen overlay
##   - Pauses its AI/state machine (sets process to false on the
##     state machine sibling)
##   - Becomes immobile (CharacterBody3D velocity zeroed)
##   - Becomes shatterable: damage taken while frozen multiplies by
##     shatter_multiplier (default 2.5x)
##
## Stacks decay over time. Stacks are added by external systems calling
## add_stack(amount) — typically from an Ice damage source.
##
## When the freeze duration expires the enemy thaws: visual fades back
## to normal, AI resumes, shatter bonus removed.
##
## Required scene shape:
##   FreezeStatus (Node + this script)
##     parent must be a Node3D
##     parent should have a HealthComponent and (optional) state_machine

signal freeze_started
signal freeze_ended
signal stack_added(stacks: int)
signal shattered  ## fired when killed while frozen (extra damage triggered death)

@export_range(1, 20) var freeze_threshold: int = 4
@export var freeze_duration_s: float = 4.0
@export_range(0.1, 5.0) var stack_decay_per_s: float = 0.6
@export_range(1.0, 8.0) var shatter_multiplier: float = 2.5
@export var freeze_tint: Color = Color(0.45, 0.85, 1.05, 1.0)
@export var sfx_freeze: StringName = &""
@export var sfx_shatter: StringName = &""
@export var health_component_path: NodePath
@export var state_machine_path: NodePath

var _parent: Node3D
var _hc: Node
var _state_machine: Node
var _stacks: float = 0.0
var _frozen: bool = false
var _freeze_timer: float = 0.0
var _original_materials: Dictionary = {}  ## MeshInstance3D → Array[Material]


func _ready() -> void:
	_parent = get_parent() as Node3D
	if _parent == null:
		return
	_hc = get_node_or_null(health_component_path)
	if _hc == null:
		for child: Node in _parent.get_children():
			if child.has_signal("damage_taken"):
				_hc = child
				break
	if _hc != null and _hc.has_signal("damage_taken"):
		_hc.damage_taken.connect(_on_damage_taken)
	_state_machine = get_node_or_null(state_machine_path)
	if _state_machine == null and _parent.has_node("state_machine"):
		_state_machine = _parent.get_node("state_machine")


func _process(delta: float) -> void:
	if _frozen:
		_freeze_timer -= delta
		if _freeze_timer <= 0.0:
			_thaw()
		return

	# Stack decay when not frozen
	if _stacks > 0.0:
		_stacks = maxf(0.0, _stacks - stack_decay_per_s * delta)


# === Public API ===

func add_stack(amount: float = 1.0) -> void:
	## External cold damage sources call this to add freeze stacks.
	if _frozen:
		return  # already frozen, no point adding more
	_stacks += amount
	stack_added.emit(int(_stacks))
	if _stacks >= float(freeze_threshold):
		_freeze()


func is_frozen() -> bool:
	return _frozen


# === Internal ===

func _freeze() -> void:
	_frozen = true
	_freeze_timer = freeze_duration_s

	# Visual: tint all meshes ice blue, increase metallic + roughness
	# (frosty glassy look) by overlaying a duplicated material
	var meshes: Array[MeshInstance3D] = _walk_meshes(_parent)
	for mesh: MeshInstance3D in meshes:
		var saved: Array[Material] = []
		var count: int = mesh.get_surface_override_material_count()
		if count == 0 and mesh.mesh != null:
			count = mesh.mesh.get_surface_count()
		for i: int in count:
			saved.append(mesh.get_surface_override_material(i))
			# Build a frozen overlay material
			var src: Material = mesh.get_surface_override_material(i)
			if src == null and mesh.mesh != null:
				src = mesh.mesh.surface_get_material(i)
			var frozen_mat: StandardMaterial3D = StandardMaterial3D.new()
			if src is StandardMaterial3D:
				var sm: StandardMaterial3D = src as StandardMaterial3D
				frozen_mat.albedo_texture = sm.albedo_texture
				frozen_mat.albedo_color = sm.albedo_color.lerp(freeze_tint, 0.65)
			else:
				frozen_mat.albedo_color = freeze_tint
			frozen_mat.metallic = 0.85
			frozen_mat.roughness = 0.10
			frozen_mat.emission_enabled = true
			frozen_mat.emission = freeze_tint
			frozen_mat.emission_energy_multiplier = 0.4
			mesh.set_surface_override_material(i, frozen_mat)
		_original_materials[mesh] = saved

	# Stop AI
	if _state_machine != null:
		_state_machine.set_process(false)
		_state_machine.set_physics_process(false)

	# Stop motion if the parent is a CharacterBody3D
	if _parent is CharacterBody3D:
		(_parent as CharacterBody3D).velocity = Vector3.ZERO

	# SFX
	if sfx_freeze != &"":
		var sfx: Node = get_node_or_null("/root/SfxManager")
		if sfx != null and sfx.has_method("play"):
			sfx.play(sfx_freeze, _parent.global_position)

	freeze_started.emit()


func _thaw() -> void:
	_frozen = false
	_stacks = 0.0
	_freeze_timer = 0.0

	# Restore materials
	for mesh_key: Variant in _original_materials.keys():
		if not is_instance_valid(mesh_key):
			continue
		var mesh: MeshInstance3D = mesh_key
		var saved: Array[Material] = _original_materials[mesh]
		for i: int in saved.size():
			mesh.set_surface_override_material(i, saved[i])
	_original_materials.clear()

	# Resume AI
	if _state_machine != null:
		_state_machine.set_process(true)
		_state_machine.set_physics_process(true)

	freeze_ended.emit()


func _on_damage_taken(amount: float = 0.0) -> void:
	if not _frozen:
		return
	# Apply the shatter bonus by re-dealing the EXTRA damage to the parent
	# (the original damage already landed; we add the multiplier delta on top)
	var bonus: float = amount * (shatter_multiplier - 1.0)
	if bonus <= 0.0 or _hc == null:
		return
	if _hc.has_method("take_damage"):
		_hc.call("take_damage", bonus, &"freeze_shatter")
		shattered.emit()
		if sfx_shatter != &"":
			var sfx: Node = get_node_or_null("/root/SfxManager")
			if sfx != null and sfx.has_method("play"):
				sfx.play(sfx_shatter, _parent.global_position)


func _walk_meshes(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		result.append(root)
	for child: Node in root.get_children():
		result.append_array(_walk_meshes(child))
	return result
