class_name ExitBarrier
extends StaticBody3D
## Blocks exit until room is cleared, then dissolves with effect.

@onready var _mesh: MeshInstance3D = get_child(0) as MeshInstance3D
var _energy_mat: StandardMaterial3D = null


func _ready() -> void:
	# Apply red energy wall material
	_energy_mat = StandardMaterial3D.new()
	_energy_mat.albedo_color = Color(0.8, 0.1, 0.1, 0.5)
	_energy_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_energy_mat.emission_enabled = true
	_energy_mat.emission = Color(0.7, 0.05, 0.05)
	_energy_mat.emission_energy_multiplier = 1.5
	_energy_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if _mesh:
		_mesh.material_override = _energy_mat


func _process(_delta: float) -> void:
	# Pulse the barrier
	if _energy_mat and visible:
		var pulse: float = 0.4 + sin(Time.get_ticks_msec() * 0.004) * 0.15
		_energy_mat.albedo_color.a = pulse


func open() -> void:
	# Dissolve animation
	if _energy_mat:
		var tween: Tween = create_tween()
		tween.tween_property(_energy_mat, "albedo_color:a", 0.0, 0.5)
		tween.parallel().tween_property(_energy_mat, "emission_energy_multiplier", 0.0, 0.5)
		tween.tween_callback(_finish_open)
	else:
		_finish_open()


func _finish_open() -> void:
	visible = false
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
