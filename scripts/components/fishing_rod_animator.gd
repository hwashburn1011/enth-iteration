class_name FishingRodAnimator
extends Node3D

## Drives the visible fishing rod animation through the cast cycle:
##
##   IDLE → CASTING → WAITING → BITE → REELING → CATCH/MISS → IDLE
##
## The animator owns the rod tip arc, the line projection, the bobber
## physics (sit on the water surface, dip on bite, snap to the rod tip
## on reel), and the splash particles. It does NOT own the catch logic
## — that lives in WildernessFishingSpot + FishingResolver. This
## component just makes the visible feedback match the underlying state.
##
## Required scene shape:
##   FishingRodAnimator (Node3D + this script)
##     RodPivot (Node3D — pivots the rod through the cast arc)
##     RodMesh (MeshInstance3D — the actual rod model)
##     RodTipMarker (Marker3D — top of the rod, line origin)
##     LineRenderer (ImmediateMesh inside MeshInstance3D — drawn each frame)
##     Bobber (Node3D — small mesh that floats on the water)
##     SplashParticles (GPUParticles3D — emit on cast/bite/reel)
##
## Configure via inspector:
##   cast_distance     — meters out from the rod tip
##   cast_arc_height   — apex height of the bobber's flight curve
##   wait_min_seconds  — minimum wait before a bite
##   wait_max_seconds  — maximum wait
##   bite_window_s     — seconds the player has to react

signal state_changed(new_state: int)
signal cast_started
signal bite_window_opened
signal reel_succeeded
signal reel_missed

enum RodState {
	IDLE,
	CASTING,
	WAITING,
	BITE,
	REELING,
	CATCH,
	MISS,
}

const REEL_INPUT_GRACE_S: float = 0.12

@export var cast_distance: float = 6.0
@export var cast_arc_height: float = 3.0
@export var wait_min_seconds: float = 2.0
@export var wait_max_seconds: float = 5.0
@export var bite_window_s: float = 1.4
@export var cast_anim_duration: float = 0.55
@export var reel_anim_duration: float = 0.50

@onready var _rod_pivot: Node3D = $RodPivot if has_node("RodPivot") else null
@onready var _rod_tip: Marker3D = $RodPivot/RodTipMarker if has_node("RodPivot/RodTipMarker") else null
@onready var _line_renderer: MeshInstance3D = $LineRenderer if has_node("LineRenderer") else null
@onready var _bobber: Node3D = $Bobber if has_node("Bobber") else null
@onready var _splash: GPUParticles3D = $SplashParticles if has_node("SplashParticles") else null

var _state: int = RodState.IDLE
var _bite_window_end_time: float = 0.0
var _bobber_target: Vector3
var _bobber_origin: Vector3
var _line_mesh: ImmediateMesh
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_bobber_origin = _bobber.global_position if _bobber != null else global_position
	if _line_renderer != null:
		_line_mesh = ImmediateMesh.new()
		_line_renderer.mesh = _line_mesh
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(0.92, 0.92, 0.95, 0.85)
		_line_renderer.set_surface_override_material(0, mat)


func _process(delta: float) -> void:
	_redraw_line()
	_tick_state(delta)


# === STATE MACHINE ===

func cast() -> bool:
	## Begin a cast. Returns false if not currently idle.
	if _state != RodState.IDLE:
		return false
	_set_state(RodState.CASTING)
	cast_started.emit()
	_animate_rod_arc_forward()
	_animate_bobber_arc_to_target()
	# After the cast animation finishes, transition to WAITING
	var t: SceneTreeTimer = get_tree().create_timer(cast_anim_duration)
	t.timeout.connect(_enter_waiting)
	return true


func reel() -> bool:
	## Player attempted to reel — only succeeds inside the bite window.
	if _state == RodState.BITE:
		var now: float = Time.get_ticks_msec() / 1000.0
		if now <= _bite_window_end_time + REEL_INPUT_GRACE_S:
			_enter_reeling()
			return true
	# Reeling outside a bite window is a miss
	if _state == RodState.WAITING or _state == RodState.BITE:
		_enter_miss()
		return false
	return false


func cancel() -> void:
	## Aborts mid-cast (player walked away, weather changed, etc.)
	_reset_to_idle()


# === STATE TRANSITIONS ===

func _set_state(new_state: int) -> void:
	if _state == new_state:
		return
	_state = new_state
	state_changed.emit(new_state)


func _enter_waiting() -> void:
	if _state != RodState.CASTING:
		return
	_set_state(RodState.WAITING)
	# Schedule the bite window
	var wait_s: float = _rng.randf_range(wait_min_seconds, wait_max_seconds)
	var t: SceneTreeTimer = get_tree().create_timer(wait_s)
	t.timeout.connect(_enter_bite)


func _enter_bite() -> void:
	if _state != RodState.WAITING:
		return
	_set_state(RodState.BITE)
	bite_window_opened.emit()
	_bite_window_end_time = (Time.get_ticks_msec() / 1000.0) + bite_window_s
	# Visual: bobber dips
	if _bobber != null:
		var tw: Tween = create_tween()
		tw.tween_property(_bobber, "position:y", _bobber.position.y - 0.18, 0.10)
		tw.tween_property(_bobber, "position:y", _bobber.position.y - 0.05, 0.20)
		tw.tween_property(_bobber, "position:y", _bobber.position.y - 0.18, 0.20)
	# Splash burst
	if _splash != null:
		_splash.restart()
	# Audio cue
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_fishing_bite_alert")
	# Auto-miss after the bite window expires
	var t: SceneTreeTimer = get_tree().create_timer(bite_window_s)
	t.timeout.connect(_check_bite_timeout)


func _check_bite_timeout() -> void:
	if _state == RodState.BITE:
		_enter_miss()


func _enter_reeling() -> void:
	_set_state(RodState.REELING)
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_fishing_reel")
	_animate_bobber_back_to_rod()
	var t: SceneTreeTimer = get_tree().create_timer(reel_anim_duration)
	t.timeout.connect(_enter_catch)


func _enter_catch() -> void:
	_set_state(RodState.CATCH)
	reel_succeeded.emit()
	_reset_to_idle_after(0.6)


func _enter_miss() -> void:
	_set_state(RodState.MISS)
	reel_missed.emit()
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_fishing_miss")
	_reset_to_idle_after(0.5)


func _reset_to_idle_after(delay: float) -> void:
	var t: SceneTreeTimer = get_tree().create_timer(delay)
	t.timeout.connect(_reset_to_idle)


func _reset_to_idle() -> void:
	_set_state(RodState.IDLE)
	if _bobber != null:
		_bobber.global_position = _bobber_origin
	_animate_rod_arc_back()


# === ROD ANIMATION ===

func _animate_rod_arc_forward() -> void:
	if _rod_pivot == null:
		return
	var tw: Tween = create_tween()
	tw.tween_property(_rod_pivot, "rotation_degrees", Vector3(-30, 0, 0), cast_anim_duration * 0.4)
	tw.tween_property(_rod_pivot, "rotation_degrees", Vector3(20, 0, 0), cast_anim_duration * 0.6)


func _animate_rod_arc_back() -> void:
	if _rod_pivot == null:
		return
	var tw: Tween = create_tween()
	tw.tween_property(_rod_pivot, "rotation_degrees", Vector3(0, 0, 0), 0.3)


# === BOBBER FLIGHT ===

func _animate_bobber_arc_to_target() -> void:
	if _bobber == null or _rod_tip == null:
		return
	var origin: Vector3 = _rod_tip.global_position
	var fwd: Vector3 = -global_transform.basis.z.normalized()
	_bobber_target = origin + fwd * cast_distance
	# Three-point parabolic arc via tween_method
	var tw: Tween = create_tween()
	tw.tween_method(_apply_bobber_arc, 0.0, 1.0, cast_anim_duration)
	# Pre-cache the start
	_bobber.global_position = origin


func _apply_bobber_arc(t: float) -> void:
	if _bobber == null or _rod_tip == null:
		return
	var origin: Vector3 = _rod_tip.global_position
	var dest: Vector3 = _bobber_target
	# Quadratic bezier with the apex at midpoint + cast_arc_height
	var mid: Vector3 = (origin + dest) * 0.5 + Vector3.UP * cast_arc_height
	var p: Vector3 = origin.lerp(mid, t).lerp(mid.lerp(dest, t), t)
	_bobber.global_position = p


func _animate_bobber_back_to_rod() -> void:
	if _bobber == null or _rod_tip == null:
		return
	var tw: Tween = create_tween()
	tw.tween_property(_bobber, "global_position", _rod_tip.global_position, reel_anim_duration)


# === LINE RENDERING ===

func _redraw_line() -> void:
	if _line_mesh == null or _rod_tip == null or _bobber == null:
		return
	_line_mesh.clear_surfaces()
	_line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	# Sag the line a little using a midpoint dropped slightly
	var a: Vector3 = _line_renderer.to_local(_rod_tip.global_position)
	var b: Vector3 = _line_renderer.to_local(_bobber.global_position)
	var sag: float = 0.0
	if _state == RodState.WAITING or _state == RodState.BITE:
		sag = 0.15
	var mid: Vector3 = (a + b) * 0.5 + Vector3.DOWN * sag
	_line_mesh.surface_add_vertex(a)
	_line_mesh.surface_add_vertex(mid)
	_line_mesh.surface_add_vertex(b)
	_line_mesh.surface_end()


# === STATE TICK ===

func _tick_state(_delta: float) -> void:
	# Reserved for state-specific per-frame work — currently the bobber
	# bob during WAITING state is the only thing that needs ticking
	if _state == RodState.WAITING and _bobber != null:
		var t: float = Time.get_ticks_msec() / 1000.0
		_bobber.position.y = _bobber_target.y - global_position.y + sin(t * 2.0) * 0.04
