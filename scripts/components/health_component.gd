class_name HealthComponent
extends Node
## Tracks health, emits signals on change and death.

signal health_changed(new_value: float, max_value: float)
signal died

@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if is_dead:
		return
	# Check invulnerability on parent if it has the property
	var parent: Node = get_parent()
	if parent and &"is_invulnerable" in parent and parent.is_invulnerable:
		return
	current_health = maxf(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0 and not is_dead:
		is_dead = true
		died.emit()
		if parent.is_in_group(&"player"):
			EventBus.player_died.emit(parent.global_position if parent is Node3D else Vector3.ZERO)


func heal(amount: float) -> void:
	if is_dead:
		return
	current_health = minf(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
	# Heal VFX
	var parent: Node = get_parent()
	if parent is Node3D:
		var pos: Vector3 = (parent as Node3D).global_position
		VFXFactory.spawn_heal_particles(pos, parent.get_tree().current_scene)
		VFXFactory.spawn_heal_number(pos, int(amount), parent.get_tree().current_scene)
		# Brief green flash on player mesh
		if parent.is_in_group(&"player") and parent.has_node("Model"):
			var model: Node3D = parent.get_node("Model") as Node3D
			_flash_mesh_green(model, parent)


func _flash_mesh_green(model: Node3D, parent: Node) -> void:
	if model == null or model.get_child_count() == 0:
		return
	var mesh: MeshInstance3D = null
	for child: Node in model.get_children():
		if child is MeshInstance3D:
			mesh = child as MeshInstance3D
			break
	if mesh == null:
		return
	var original_mat: Material = mesh.material_override
	var flash_mat: StandardMaterial3D = StandardMaterial3D.new()
	flash_mat.albedo_color = Color(0.4, 1.0, 0.4)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(0.3, 1.0, 0.3)
	flash_mat.emission_energy_multiplier = 2.0
	mesh.material_override = flash_mat
	if parent.is_inside_tree():
		parent.get_tree().create_timer(0.15).timeout.connect(func() -> void:
			if is_instance_valid(mesh):
				mesh.material_override = original_mat
		)


func reset() -> void:
	current_health = max_health
	is_dead = false
	health_changed.emit(current_health, max_health)


func get_health_percentage() -> float:
	if max_health <= 0.0:
		return 0.0
	return current_health / max_health
