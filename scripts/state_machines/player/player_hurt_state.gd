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
	# Screen shake
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		camera.shake(0.15, 8.0)


func physics_update(delta: float) -> void:
	var p = player
	_timer += delta

	# Apply decaying knockback
	var knockback_factor: float = maxf(0.0, 1.0 - _timer / STUN_DURATION)
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
