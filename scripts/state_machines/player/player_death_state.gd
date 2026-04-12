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
	# Death text — large red glitch
	var death_label: Label = Label.new()
	death_label.text = "SYSTEM FAILURE"
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.set_anchors_preset(Control.PRESET_CENTER)
	death_label.offset_left = -260
	death_label.offset_right = 260
	death_label.offset_top = -50
	death_label.offset_bottom = 50
	death_label.add_theme_font_size_override(&"font_size", 56)
	death_label.add_theme_color_override(&"font_color", Color(0.95, 0.15, 0.1, 0.0))
	death_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.95))
	death_label.add_theme_constant_override(&"outline_size", 8)
	death_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(death_label)
	# Subtitle hex code
	var sublabel: Label = Label.new()
	sublabel.text = "0xDEADC0DE"
	sublabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sublabel.set_anchors_preset(Control.PRESET_CENTER)
	sublabel.offset_left = -120
	sublabel.offset_right = 120
	sublabel.offset_top = 30
	sublabel.offset_bottom = 60
	sublabel.add_theme_font_size_override(&"font_size", 22)
	sublabel.add_theme_color_override(&"font_color", Color(0.7, 0.1, 0.05, 0.0))
	sublabel.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	sublabel.add_theme_constant_override(&"outline_size", 5)
	sublabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(sublabel)
	# Phase 4 #39 — random gameplay tip below the death text
	var tips: Array[String] = [
		"Tip: Hold F to block — costs Compute but reduces damage by 80%.",
		"Tip: Dash with Space for i-frames. Dash-cancel into attack for aggression.",
		"Tip: Status effects stack — fragmented enemies take 30% more damage.",
		"Tip: Legendary items have 2.5x stat multipliers. Worth the extra floor.",
		"Tip: Every 3 levels grants a passive node. Check your build!",
		"Tip: The parry window is 0.18s after pressing F. Risky but rewarding.",
		"Tip: Combo finisher (3rd hit) applies fragmented to the target.",
		"Tip: Q uses your Health Prompt — don't forget to stock up.",
	]
	var tip_label: Label = Label.new()
	tip_label.text = tips[randi() % tips.size()]
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.set_anchors_preset(Control.PRESET_CENTER)
	tip_label.offset_left = -300
	tip_label.offset_right = 300
	tip_label.offset_top = 80
	tip_label.offset_bottom = 120
	tip_label.add_theme_font_size_override(&"font_size", 16)
	tip_label.add_theme_color_override(&"font_color", Color(0.6, 0.65, 0.7, 0.0))
	tip_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.8))
	tip_label.add_theme_constant_override(&"outline_size", 4)
	tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	tip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(tip_label)
	# Continue button — waits for click before respawning
	var continue_btn: Button = Button.new()
	continue_btn.text = "Continue"
	continue_btn.set_anchors_preset(Control.PRESET_CENTER)
	continue_btn.offset_left = -80
	continue_btn.offset_right = 80
	continue_btn.offset_top = 140
	continue_btn.offset_bottom = 175
	continue_btn.add_theme_font_size_override(&"font_size", 20)
	continue_btn.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	continue_btn.modulate.a = 0.0
	continue_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	var death_canvas_ref: CanvasLayer = canvas
	continue_btn.pressed.connect(func() -> void:
		if is_instance_valid(death_canvas_ref):
			death_canvas_ref.queue_free()
		# Trigger respawn via scene reload
		GameManager.change_scene_to("res://scenes/town/Town.tscn")
	)
	canvas.add_child(continue_btn)

	p.get_tree().root.add_child(canvas)
	# Animate: fade in dark overlay + text + glitch jitter
	# Use process tween mode so the slow-mo doesn't drag out the fade-in
	var tween: Tween = dim.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ignore_time_scale(true)
	tween.tween_property(dim, "color:a", 0.78, 0.5)
	var text_tween: Tween = death_label.create_tween()
	text_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	text_tween.set_ignore_time_scale(true)
	text_tween.tween_interval(0.15)
	text_tween.tween_property(death_label, "theme_override_colors/font_color:a", 1.0, 0.25)
	# Glitch jitter: randomly nudge the label position a few times
	text_tween.tween_callback(func() -> void:
		if not is_instance_valid(death_label):
			return
		var jitter_tween: Tween = death_label.create_tween()
		jitter_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		jitter_tween.set_ignore_time_scale(true)
		jitter_tween.set_loops(8)
		jitter_tween.tween_property(death_label, "position:x", randf_range(-6.0, 6.0), 0.05)
	)
	var sub_tween: Tween = sublabel.create_tween()
	sub_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	sub_tween.set_ignore_time_scale(true)
	sub_tween.tween_interval(0.4)
	sub_tween.tween_property(sublabel, "theme_override_colors/font_color:a", 1.0, 0.3)
	# Phase 4 #39 — fade in tip + continue button after the main text
	var tip_tween: Tween = tip_label.create_tween()
	tip_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tip_tween.set_ignore_time_scale(true)
	tip_tween.tween_interval(1.0)
	tip_tween.tween_property(tip_label, "theme_override_colors/font_color:a", 1.0, 0.5)
	var btn_tween: Tween = continue_btn.create_tween()
	btn_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	btn_tween.set_ignore_time_scale(true)
	btn_tween.tween_interval(1.5)
	btn_tween.tween_property(continue_btn, "modulate:a", 1.0, 0.4)
	btn_tween.tween_callback(continue_btn.grab_focus)


func exit() -> void:
	var p = player
	# Re-enable when respawn system transitions out of DeathState
	p.set_physics_process(true)
	p.set_process_unhandled_input(true)
	p.collision_layer = 1
	p.collision_mask = 138
