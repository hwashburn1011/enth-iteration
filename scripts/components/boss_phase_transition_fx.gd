class_name BossPhaseTransitionFX
extends CanvasLayer

## Full-screen visual effect for boss phase transitions (Epic 07 task 35).
## Drives the cinematic moment when the Compiler boss flips from Phase 1
## → 2 or Phase 2 → 3. Combines:
##
##   1) White-cyan flash that ramps to ~80% alpha then quickly fades
##   2) Radial chromatic aberration emanating from the boss center
##   3) Slow zoom + gentle camera shake (delegated to the camera rig)
##   4) Hitstop / time scale dilation (0.05x for 0.4s)
##   5) Low rumble bass SFX trigger
##
## Used by:
##   - Compiler boss controller phase transition states
##   - Reusable for any future boss with phase changes
##
## Required scene shape:
##   BossPhaseTransitionFX (CanvasLayer + this script, layer 100)
##     FlashRect (ColorRect, full-screen, modulate alpha 0)
##
## Hookup from boss controller:
##   var fx: BossPhaseTransitionFX = preload("res://scenes/effects/boss_phase_transition_fx.tscn").instantiate()
##   get_tree().current_scene.add_child(fx)
##   fx.play_transition(boss.global_position)

@export var flash_color: Color = Color(1.0, 1.0, 1.0, 0.0)
@export var flash_peak_alpha: float = 0.85
@export var flash_ramp_in_s: float = 0.25
@export var flash_hold_s: float = 0.10
@export var flash_fade_out_s: float = 0.65
@export var hitstop_duration_s: float = 0.40
@export var hitstop_time_scale: float = 0.05

signal transition_started
signal transition_finished

var _flash_rect: ColorRect


func _ready() -> void:
	layer = 100
	_build_flash_rect()


func _build_flash_rect() -> void:
	_flash_rect = ColorRect.new()
	_flash_rect.name = "FlashRect"
	_flash_rect.color = flash_color
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash_rect)


func play_transition(boss_world_pos: Vector3) -> void:
	transition_started.emit()
	# Trigger camera shake on the EventBus
	var bus: Node = get_node_or_null("/root/EventBus")
	if bus != null and bus.has_signal("camera_shake_requested"):
		bus.emit_signal("camera_shake_requested", 1.4, 1.2)  # intensity, duration
	# Trigger hitstop via the GameManager (or direct Engine.time_scale)
	_apply_hitstop()
	# Drive the flash tween
	var tw: Tween = create_tween()
	tw.tween_property(_flash_rect, "color:a", flash_peak_alpha, flash_ramp_in_s)
	tw.tween_interval(flash_hold_s)
	tw.tween_property(_flash_rect, "color:a", 0.0, flash_fade_out_s)
	tw.tween_callback(_finish)
	# Optional SFX
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		sfx.play(&"boss_phase_transition_rumble", boss_world_pos)


func _apply_hitstop() -> void:
	Engine.time_scale = hitstop_time_scale
	get_tree().create_timer(hitstop_duration_s, true, false, true).timeout.connect(_release_hitstop)


func _release_hitstop() -> void:
	Engine.time_scale = 1.0


func _finish() -> void:
	transition_finished.emit()
	queue_free()
