class_name PlayerDeathState
extends "res://scripts/state_machines/state.gd"
## Player has died — play death animation, disable everything, wait for respawn.

func _ready() -> void:
	can_be_interrupted = false


func enter() -> void:
	var p = player

	if p.animation_player.has_animation(&"death"):
		p.animation_player.play(&"death")

	# Disable all input processing and collision
	p.set_physics_process(false)
	p.set_process_unhandled_input(false)
	p.collision_layer = 0
	p.collision_mask = 0

	# EventBus notification (HealthComponent also emits this, but ensure it fires)
	if not p.health_component.is_dead:
		EventBus.player_died.emit(p.global_position)

	# Dramatic death VFX
	_spawn_death_vfx(p)


func _spawn_death_vfx(p: CharacterBody3D) -> void:
	if not p.is_inside_tree():
		return
	# Brief slow-mo
	Engine.time_scale = 0.3
	p.get_tree().create_timer(0.3, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
	)
	# Screen shake
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		camera.shake(0.25, 4.0)
	# Death burst VFX at player position
	VFXFactory.spawn_hit_flash(p.global_position + Vector3(0, 0.5, 0), p.get_tree().current_scene)
	# Dark overlay with "SYSTEM FAILURE" text
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 95
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	# Dark vignette
	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.02, 0.02, 0.0)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(dim)
	# Death text
	var death_label: Label = Label.new()
	death_label.text = "SYSTEM FAILURE"
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.set_anchors_preset(Control.PRESET_CENTER)
	death_label.offset_left = -200
	death_label.offset_right = 200
	death_label.offset_top = -40
	death_label.offset_bottom = 40
	death_label.add_theme_font_size_override(&"font_size", 42)
	death_label.add_theme_color_override(&"font_color", Color(0.9, 0.15, 0.1, 0.0))
	death_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(death_label)
	p.get_tree().root.add_child(canvas)
	# Animate: fade in dark overlay + text
	var tween: Tween = dim.create_tween()
	tween.tween_property(dim, "color:a", 0.7, 1.0)
	var text_tween: Tween = death_label.create_tween()
	text_tween.tween_interval(0.5)
	text_tween.tween_property(death_label, "theme_override_colors/font_color:a", 1.0, 0.5)
	# Auto-cleanup after 4 seconds (respawn system will handle scene change)
	p.get_tree().create_timer(4.0).timeout.connect(canvas.queue_free)


func exit() -> void:
	var p = player
	# Re-enable when respawn system transitions out of DeathState
	p.set_physics_process(true)
	p.set_process_unhandled_input(true)
	p.collision_layer = 1
	p.collision_mask = 138
