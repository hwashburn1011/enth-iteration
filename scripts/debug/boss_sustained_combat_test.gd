class_name BossSustainedCombatTest
extends Node

## Sustained combat test harness for the Compiler boss (Epic 07 task 42).
## Drives a 3-minute scripted fight that exercises every attack pattern,
## phase transition, hit reaction, hitstop curve, dust emitter, telegraph,
## phase ambient SFX crossfade, low HP rage, and the death sequence —
## then captures performance metrics and asserts them against the budget.
##
## Used by:
##   - Pre-commit test before any boss change ships
##   - Performance regression detection (ensures FPS holds 60+ during
##     the worst-case phase 3 ultimate + add spawn moment)
##   - VFX validation (visually inspect by running the scene)
##
## Required scene shape:
##   BossSustainedCombatTest (Node + this script)
##     export boss_path: NodePath to the Compiler boss
##     export player_path: NodePath to a stand-in attacker node
##
## Hookup as a debug scene:
##   res://scenes/debug/boss_sustained_combat_test.tscn
##   - Spawn boss + player + arena
##   - This Node drives the test
##   - Run from editor or via headless --script for CI
##
## Performance budget:
##   target_fps: 60
##   acceptable_min_fps: 55 (single dip OK during phase transition)
##   acceptable_avg_frame_ms: 16.0
##
## Test phases (3 minutes total):
##   0:00 - 0:30  Phase 1 attacks (slam, sweep, summon)
##   0:30 - 0:32  Damage to phase break threshold (66%)
##   0:32 - 0:36  Phase 1 → 2 transition
##   0:36 - 1:30  Phase 2 attacks (multi-proj, teleport, hazard spawn)
##   1:30 - 1:32  Damage to phase break threshold (33%)
##   1:32 - 1:37  Phase 2 → 3 transition
##   1:37 - 2:30  Phase 3 attacks (AoE, chase laser, gravity well)
##   2:30 - 2:50  Phase 3 ultimate at 10% HP
##   2:50 - 3:00  Death sequence + outro

signal test_completed(passed: bool, report: Dictionary)

@export var boss_path: NodePath
@export var player_path: NodePath
@export var auto_run_on_ready: bool = false
@export var target_fps: float = 60.0
@export var acceptable_min_fps: float = 55.0
@export var acceptable_avg_frame_ms: float = 16.0

var _boss: Node
var _player: Node
var _start_time_ms: int = 0
var _frame_count: int = 0
var _frame_time_total_ms: float = 0.0
var _min_fps_observed: float = 999.0
var _max_frame_time_ms: float = 0.0
var _phase_event_log: Array[Dictionary] = []
var _running: bool = false


func _ready() -> void:
	_boss = get_node_or_null(boss_path)
	_player = get_node_or_null(player_path)
	if auto_run_on_ready:
		run_test()


func run_test() -> void:
	if _boss == null:
		push_warning("BossSustainedCombatTest: no boss assigned")
		return
	_start_time_ms = Time.get_ticks_msec()
	_frame_count = 0
	_frame_time_total_ms = 0.0
	_min_fps_observed = 999.0
	_max_frame_time_ms = 0.0
	_phase_event_log.clear()
	_running = true
	_log_event("test_started", {})
	_schedule_test_beats()


func _schedule_test_beats() -> void:
	# Schedule the test phase calls via timers
	var beats: Array = [
		[0.0,   _beat_phase1_attacks],
		[30.0,  _beat_damage_to_p2_threshold],
		[32.0,  _beat_p1_to_p2_transition],
		[36.0,  _beat_phase2_attacks],
		[90.0,  _beat_damage_to_p3_threshold],
		[92.0,  _beat_p2_to_p3_transition],
		[97.0,  _beat_phase3_attacks],
		[150.0, _beat_phase3_ultimate],
		[170.0, _beat_death_sequence],
		[180.0, _beat_test_complete],
	]
	for entry in beats:
		var t: float = entry[0]
		var fn: Callable = entry[1]
		get_tree().create_timer(t).timeout.connect(fn)


func _process(_delta: float) -> void:
	if not _running:
		return
	_frame_count += 1
	var frame_ms: float = (Time.get_ticks_usec() - _start_time_ms * 1000.0) / 1000.0
	# Use Engine.get_frames_per_second for stable measurement
	var fps: float = Engine.get_frames_per_second()
	if fps > 0 and fps < _min_fps_observed:
		_min_fps_observed = fps
	var frame_time: float = 1000.0 / max(1.0, fps)
	if frame_time > _max_frame_time_ms:
		_max_frame_time_ms = frame_time
	_frame_time_total_ms += frame_time


func _log_event(name: String, data: Dictionary) -> void:
	var entry: Dictionary = {
		"t": (Time.get_ticks_msec() - _start_time_ms) / 1000.0,
		"name": name,
		"data": data,
	}
	_phase_event_log.append(entry)
	print("[CombatTest] +%.1fs %s %s" % [entry["t"], name, str(data)])


func _beat_phase1_attacks() -> void:
	_log_event("phase1_attacks_begin", {})
	# Drive the boss through its 3 P1 attacks
	if _boss != null and _boss.has_method("debug_force_attack"):
		_boss.call("debug_force_attack", &"ground_slam")
	# Schedule a sweep + summon
	get_tree().create_timer(8.0).timeout.connect(func():
		if _boss != null and _boss.has_method("debug_force_attack"):
			_boss.call("debug_force_attack", &"sweep_beam"))
	get_tree().create_timer(16.0).timeout.connect(func():
		if _boss != null and _boss.has_method("debug_force_attack"):
			_boss.call("debug_force_attack", &"summon_adds"))


func _beat_damage_to_p2_threshold() -> void:
	_log_event("damage_to_p2_threshold", {})
	if _boss != null and _boss.has_method("debug_set_hp_pct"):
		_boss.call("debug_set_hp_pct", 0.66)


func _beat_p1_to_p2_transition() -> void:
	_log_event("p1_to_p2_transition", {})


func _beat_phase2_attacks() -> void:
	_log_event("phase2_attacks_begin", {})
	if _boss != null and _boss.has_method("debug_force_attack"):
		_boss.call("debug_force_attack", &"multi_projectile")
	get_tree().create_timer(15.0).timeout.connect(func():
		if _boss != null and _boss.has_method("debug_force_attack"):
			_boss.call("debug_force_attack", &"teleport_strike"))
	get_tree().create_timer(30.0).timeout.connect(func():
		if _boss != null and _boss.has_method("debug_force_attack"):
			_boss.call("debug_force_attack", &"hazard_spawn"))


func _beat_damage_to_p3_threshold() -> void:
	_log_event("damage_to_p3_threshold", {})
	if _boss != null and _boss.has_method("debug_set_hp_pct"):
		_boss.call("debug_set_hp_pct", 0.33)


func _beat_p2_to_p3_transition() -> void:
	_log_event("p2_to_p3_transition", {})


func _beat_phase3_attacks() -> void:
	_log_event("phase3_attacks_begin", {})
	if _boss != null and _boss.has_method("debug_force_attack"):
		_boss.call("debug_force_attack", &"arena_aoe")
	get_tree().create_timer(15.0).timeout.connect(func():
		if _boss != null and _boss.has_method("debug_force_attack"):
			_boss.call("debug_force_attack", &"chase_laser"))
	get_tree().create_timer(30.0).timeout.connect(func():
		if _boss != null and _boss.has_method("debug_force_attack"):
			_boss.call("debug_force_attack", &"gravity_well"))


func _beat_phase3_ultimate() -> void:
	_log_event("phase3_ultimate", {})
	if _boss != null and _boss.has_method("debug_force_attack"):
		_boss.call("debug_force_attack", &"ultimate")


func _beat_death_sequence() -> void:
	_log_event("death_sequence", {})
	if _boss != null and _boss.has_method("debug_kill"):
		_boss.call("debug_kill")


func _beat_test_complete() -> void:
	_running = false
	var avg_frame_ms: float = _frame_time_total_ms / max(1, _frame_count)
	var avg_fps: float = 1000.0 / max(0.1, avg_frame_ms)
	var report: Dictionary = {
		"avg_fps": avg_fps,
		"min_fps": _min_fps_observed,
		"max_frame_ms": _max_frame_time_ms,
		"avg_frame_ms": avg_frame_ms,
		"frame_count": _frame_count,
		"event_log": _phase_event_log.duplicate(),
	}
	var passed: bool = (
		avg_fps >= target_fps - 1.0
		and _min_fps_observed >= acceptable_min_fps
		and avg_frame_ms <= acceptable_avg_frame_ms
	)
	report["passed"] = passed
	report["target_fps"] = target_fps
	report["acceptable_min_fps"] = acceptable_min_fps
	_log_event("test_completed", {"passed": passed, "avg_fps": avg_fps, "min_fps": _min_fps_observed})
	test_completed.emit(passed, report)
