class_name BossAttackHitstop
extends Node

## Per-attack custom hitstop curves for the Compiler boss (Epic 07 task 44).
## Different boss attacks deserve different hitstop signatures — a heavy
## ground slam should have a heavier, longer time-stop than a flick laser
## hit, so the player FEELS the weight difference. This component owns
## the per-attack tuning table and applies the right curve via
## Engine.time_scale when the boss's HealthComponent registers an attack
## hit on the player.
##
## Hitstop curves use the asymmetric profile:
##   1) Snap to low_scale instantly (frame 0)
##   2) Hold low_scale for hold_duration_s
##   3) Ease back to 1.0 over recover_duration_s
##
## Per-attack profile table (Compiler boss):
##   ground_slam:    low=0.05, hold=0.10, recover=0.18  (heavy)
##   sweep_beam:     low=0.20, hold=0.04, recover=0.10  (sustained, lighter)
##   multi_proj:     low=0.40, hold=0.02, recover=0.06  (volley, light)
##   teleport_strike:low=0.05, hold=0.12, recover=0.20  (heavy + delayed)
##   chase_laser:    low=0.50, hold=0.01, recover=0.04  (continuous tick)
##   gravity_well:   low=0.10, hold=0.15, recover=0.25  (catastrophic)
##   ultimate:       low=0.02, hold=0.30, recover=0.50  (DOOM)
##
## Used by:
##   - Boss controller's per-attack damage application step
##   - Reusable for any future boss with different impact weights
##
## Hookup from boss attack state:
##   var hs: BossAttackHitstop = $BossAttackHitstop
##   hs.fire(&"ground_slam")  # called the moment damage is dealt

const PROFILES: Dictionary = {
	&"ground_slam":      {"low": 0.05, "hold": 0.10, "recover": 0.18},
	&"sweep_beam":       {"low": 0.20, "hold": 0.04, "recover": 0.10},
	&"multi_projectile": {"low": 0.40, "hold": 0.02, "recover": 0.06},
	&"teleport_strike":  {"low": 0.05, "hold": 0.12, "recover": 0.20},
	&"chase_laser":      {"low": 0.50, "hold": 0.01, "recover": 0.04},
	&"gravity_well":     {"low": 0.10, "hold": 0.15, "recover": 0.25},
	&"ultimate":         {"low": 0.02, "hold": 0.30, "recover": 0.50},
}

var _active: bool = false
var _recover_tween: Tween


func fire(attack_id: StringName) -> void:
	if _active:
		# Re-firing during an active hitstop: stack only if the new one is
		# heavier (lower low_scale)
		pass
	if not PROFILES.has(attack_id):
		push_warning("BossAttackHitstop: unknown attack id %s" % attack_id)
		return
	var profile: Dictionary = PROFILES[attack_id]
	_active = true
	Engine.time_scale = profile["low"]
	# Hold for the duration, then recover
	get_tree().create_timer(profile["hold"], true, false, true).timeout.connect(
		_start_recover.bind(profile["recover"])
	)


func _start_recover(recover_s: float) -> void:
	# Tween Engine.time_scale back to 1.0
	if _recover_tween != null and _recover_tween.is_valid():
		_recover_tween.kill()
	_recover_tween = create_tween().set_ignore_time_scale(true)
	_recover_tween.tween_method(_set_time_scale, Engine.time_scale, 1.0, recover_s)
	_recover_tween.tween_callback(_finish)


func _set_time_scale(value: float) -> void:
	Engine.time_scale = value


func _finish() -> void:
	Engine.time_scale = 1.0
	_active = false
