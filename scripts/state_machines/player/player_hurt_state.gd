class_name PlayerHurtState
extends "res://scripts/state_machines/state.gd"
## Player was hit — brief stun with knockback, then recover or die.

const STUN_DURATION: float = 0.3
const KNOCKBACK_SPEED: float = 8.0

var _timer: float = 0.0
var _knockback_dir: Vector3 = Vector3.ZERO
func _ready() -> void:
	can_be_interrupted = false


func enter() -> void:
	var p = player
	_timer = 0.0

	# Determine knockback direction from damage source metadata
	if p.has_meta(&"damage_source_position"):
		var source_pos: Vector3 = p.get_meta(&"damage_source_position") as Vector3
		_knockback_dir = (p.global_position - source_pos).normalized()
		_knockback_dir.y = 0.0
		p.remove_meta(&"damage_source_position")
	else:
		_knockback_dir = -p.facing_direction

	if p.animation_player.has_animation(&"hurt"):
		p.animation_player.play(&"hurt")

	# Damage feedback VFX
	_spawn_damage_vignette(p)
	# Directional damage indicator
	if _knockback_dir.length() > 0.1:
		_spawn_directional_indicator(p, -_knockback_dir)
	# Screen shake
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		camera.shake(0.15, 8.0)
	# Player mesh white flash
	_flash_player_white(p)


func physics_update(delta: float) -> void:
	var p = player
	_timer += delta

	# Apply ease-out knockback — fast start, gentle stop
	var t: float = clampf(_timer / STUN_DURATION, 0.0, 1.0)
	var knockback_factor: float = (1.0 - t) * (1.0 - t)  # quadratic ease-out
	p.velocity = _knockback_dir * KNOCKBACK_SPEED * knockback_factor
	p.move_and_slide()

	if _timer >= STUN_DURATION:
		# Check if player died during stun
		if p.health_component.is_dead:
			state_machine.force_transition_to(state_machine.get_node("DeathState") as Node)
			return
		var input_vector: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_back"
		)
		if input_vector.length() > 0.0:
			state_machine.force_transition_to(state_machine.get_node("WalkState") as Node)
		else:
			state_machine.force_transition_to(state_machine.get_node("IdleState") as Node)


func _flash_player_white(p: CharacterBody3D) -> void:
	## Brief white emission flash on the player model
	if p.model == null or p.model.get_child_count() == 0:
		return
	# Find first MeshInstance3D in model
	var mesh: MeshInstance3D = null
	for child: Node in p.model.get_children():
		if child is MeshInstance3D:
			mesh = child as MeshInstance3D
			break
	if mesh == null:
		return
	var original_mat: Material = mesh.material_override
	var flash_mat: StandardMaterial3D = StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1, 1, 1)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1, 1, 1)
	flash_mat.emission_energy_multiplier = 2.5
	mesh.material_override = flash_mat
	if p.is_inside_tree():
		p.get_tree().create_timer(0.08).timeout.connect(func() -> void:
			if is_instance_valid(mesh):
				mesh.material_override = original_mat
		)


func _spawn_directional_indicator(p: CharacterBody3D, from_dir: Vector3) -> void:
	## Arrow pointing toward the source of damage
	if not p.is_inside_tree():
		return
	var indicator: Label3D = Label3D.new()
	indicator.text = "▼"
	indicator.font_size = 48
	indicator.modulate = Color(1.0, 0.2, 0.1, 0.8)
	indicator.outline_modulate = Color(0, 0, 0, 0.6)
	indicator.outline_size = 4
	indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	# Position indicator in the direction of the damage source
	var offset: Vector3 = from_dir.normalized() * 1.5 + Vector3(0, 1.5, 0)
	indicator.position = p.global_position + offset
	# Rotate to point toward damage source
	indicator.rotation.z = atan2(from_dir.x, from_dir.z)
	p.get_tree().current_scene.add_child(indicator)
	var tween: Tween = indicator.create_tween()
	tween.tween_property(indicator, "modulate:a", 0.0, 0.6)
	tween.tween_callback(indicator.queue_free)


func _spawn_damage_vignette(p: CharacterBody3D) -> void:
	## Brief red screen flash when player takes damage
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 90
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.color = Color(0.8, 0.05, 0.02, 0.3)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(rect)
	p.get_tree().root.add_child(canvas)
	var tween: Tween = rect.create_tween()
	tween.tween_property(rect, "color:a", 0.0, 0.25)
	tween.tween_callback(canvas.queue_free)
