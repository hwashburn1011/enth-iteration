class_name EnemyEggSpawner
extends Node3D

## "Spawn from egg" intro spawner for any enemy that should hatch into the
## world rather than appear instantly. Used by the GlitchBug (Epic 04 task
## 46) but reusable for any enemy variant that needs a "this just born"
## visual moment.
##
## Behavior:
## 1) On _ready: instantiates an egg shell mesh (procedural sphere) at
##    the spawner's position with the variant's tint color
## 2) Plays an idle "throb" tween until trigger() is called externally
##    (or auto_trigger_after_s is configured for self-triggering)
## 3) On trigger: plays the 4-stage hatch sequence
##    - Crack: faint cyan glow appears at the seams
##    - Wobble: egg shakes (root.position oscillation)
##    - BURST: shell halves separate and fall away with rotation, magenta
##      flash particle, scream SFX hook
##    - REVEAL: instantiates the actual enemy scene at the spawn point,
##      free the egg shells after a delay
##
## Required scene shape:
##   EnemyEggSpawner (Node3D + this script)
##     export enemy_scene → PackedScene of the enemy to spawn
##     export variant → optional EnemyVariant resource for tinting
##
## Inspector:
##   enemy_scene             — the enemy PackedScene to instantiate on hatch
##   variant                 — optional variant for egg tint matching
##   egg_radius_m            — visual size of the egg
##   auto_trigger_after_s    — 0 = wait for manual trigger(), >0 = auto-hatch after this delay
##   throb_period_s          — idle throb cycle duration
##   hatch_duration_s        — total time of the hatch sequence
##   shell_fall_distance_m   — how far the cracked shell halves fall
##   hatch_sfx_id            — SFX played on the burst
##
## Hookup:
##   var spawner: EnemyEggSpawner = EnemyEggSpawner.new()
##   spawner.enemy_scene = preload("res://scenes/enemies/glitchbug.tscn")
##   spawner.variant = preload("res://data/enemies/variants/glitchbug_venom.tres")
##   level_root.add_child(spawner)
##   spawner.global_position = spawn_pos

signal hatch_started
signal enemy_revealed(enemy: Node3D)

@export var enemy_scene: PackedScene
@export var variant: EnemyVariant
@export_range(0.1, 2.0) var egg_radius_m: float = 0.35
@export_range(0.0, 60.0) var auto_trigger_after_s: float = 0.0
@export_range(0.5, 8.0) var throb_period_s: float = 1.8
@export_range(0.5, 6.0) var hatch_duration_s: float = 2.4
@export_range(0.1, 2.0) var shell_fall_distance_m: float = 0.6
@export var egg_color: Color = Color(0.10, 0.08, 0.18, 1.0)
@export var hatch_sfx_id: StringName = &""

var _egg_top: MeshInstance3D
var _egg_bot: MeshInstance3D
var _hatched: bool = false
var _idle_throb_tween: Tween
var _auto_timer: float = 0.0


func _ready() -> void:
	_build_egg()
	_start_idle_throb()


func _process(delta: float) -> void:
	if _hatched or auto_trigger_after_s <= 0.0:
		return
	_auto_timer += delta
	if _auto_timer >= auto_trigger_after_s:
		trigger()


func _build_egg() -> void:
	# Build two hemispheres for the egg shell — one top half + one bottom half
	# When the egg cracks, the two halves separate
	_egg_top = _make_hemisphere("EggShellTop", flip=False)
	_egg_bot = _make_hemisphere("EggShellBot", flip=True)
	add_child(_egg_top)
	add_child(_egg_bot)
	# Stack them so they form a complete sphere
	_egg_top.position = Vector3(0, egg_radius_m * 0.05, 0)
	_egg_bot.position = Vector3(0, -egg_radius_m * 0.05, 0)


func _make_hemisphere(name: String, flip: bool = false) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = name
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = egg_radius_m
	sphere.height = egg_radius_m * 2.4  # taller than wide for "egg" shape
	sphere.radial_segments = 16
	sphere.rings = 8
	mi.mesh = sphere
	# Material: dark egg shell tinted by variant
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var tint: Color = egg_color
	if variant != null:
		# Mix the variant's crack hue into the base egg color
		tint = egg_color.lerp(variant.crack_color_a, 0.30)
	mat.albedo_color = tint
	mat.metallic = 0.40
	mat.roughness = 0.35
	mat.emission_enabled = true
	mat.emission = Color(0, 0, 0)  # starts dark
	mat.emission_energy_multiplier = 0.0
	mi.material_override = mat
	if flip:
		mi.rotation = Vector3(PI, 0, 0)  # flip upside down for bottom half
	return mi


func _start_idle_throb() -> void:
	# Subtle vertical scale pulse so the egg "breathes"
	if _idle_throb_tween != null and _idle_throb_tween.is_valid():
		_idle_throb_tween.kill()
	_idle_throb_tween = create_tween()
	_idle_throb_tween.set_loops()
	_idle_throb_tween.tween_property(self, "scale", Vector3(1.05, 0.95, 1.05), throb_period_s * 0.5)
	_idle_throb_tween.tween_property(self, "scale", Vector3.ONE, throb_period_s * 0.5)


# === Public API ===

func trigger() -> void:
	## Manually start the hatch sequence. Idempotent — if already hatched
	## or hatching, calling again is a no-op.
	if _hatched:
		return
	_hatched = true
	if _idle_throb_tween != null and _idle_throb_tween.is_valid():
		_idle_throb_tween.kill()

	hatch_started.emit()
	_play_hatch_sequence()


func _play_hatch_sequence() -> void:
	var t1: float = hatch_duration_s * 0.25  # crack phase
	var t2: float = hatch_duration_s * 0.20  # wobble phase
	var t3: float = hatch_duration_s * 0.15  # burst phase
	var t4: float = hatch_duration_s * 0.40  # reveal + cleanup phase

	# === Phase 1: CRACK — emission lights up at the seam (top of bot half) ===
	var top_mat: StandardMaterial3D = _egg_top.material_override as StandardMaterial3D
	var bot_mat: StandardMaterial3D = _egg_bot.material_override as StandardMaterial3D
	var glow_color: Color = variant.crack_color_a if variant != null else Color(0.0, 0.95, 0.95)
	var phase1: Tween = create_tween()
	phase1.set_parallel(true)
	if top_mat != null:
		phase1.tween_property(top_mat, "emission", glow_color, t1)
		phase1.tween_property(top_mat, "emission_energy_multiplier", 2.0, t1)
	if bot_mat != null:
		phase1.tween_property(bot_mat, "emission", glow_color, t1)
		phase1.tween_property(bot_mat, "emission_energy_multiplier", 2.0, t1)

	await phase1.finished

	# === Phase 2: WOBBLE — egg shakes ===
	var phase2: Tween = create_tween()
	var orig_pos: Vector3 = position
	for i in 5:
		var offset: Vector3 = Vector3(
			randf_range(-0.04, 0.04),
			0,
			randf_range(-0.04, 0.04),
		)
		phase2.tween_property(self, "position", orig_pos + offset, t2 / 5.0)
	phase2.tween_property(self, "position", orig_pos, 0.05)
	await phase2.finished

	# === Phase 3: BURST — shell halves separate and fall ===
	var phase3: Tween = create_tween()
	phase3.set_parallel(true)
	# Top half flies up + tumbles
	if _egg_top != null:
		phase3.tween_property(_egg_top, "position",
			_egg_top.position + Vector3(randf_range(-0.2, 0.2), shell_fall_distance_m * 1.2, randf_range(-0.2, 0.2)),
			t3
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		phase3.tween_property(_egg_top, "rotation",
			_egg_top.rotation + Vector3(randf_range(-2, 2), randf_range(-2, 2), randf_range(-2, 2)),
			t3
		)
	# Bot half falls + tumbles
	if _egg_bot != null:
		phase3.tween_property(_egg_bot, "position",
			_egg_bot.position + Vector3(randf_range(-0.2, 0.2), -shell_fall_distance_m * 0.5, randf_range(-0.2, 0.2)),
			t3
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		phase3.tween_property(_egg_bot, "rotation",
			_egg_bot.rotation + Vector3(randf_range(-2, 2), randf_range(-2, 2), randf_range(-2, 2)),
			t3
		)

	# Hatch SFX hook
	if hatch_sfx_id != &"":
		var sfx: Node = get_node_or_null("/root/SfxManager")
		if sfx != null and sfx.has_method("play"):
			sfx.play(hatch_sfx_id, global_position)

	await phase3.finished

	# === Phase 4: REVEAL ===
	if enemy_scene != null:
		var enemy: Node = enemy_scene.instantiate()
		var world: Node = get_tree().current_scene
		if world != null:
			world.add_child(enemy)
			if enemy is Node3D:
				(enemy as Node3D).global_position = global_position
			enemy_revealed.emit(enemy)
	# Free the shell halves after the reveal delay
	await get_tree().create_timer(t4).timeout
	if is_instance_valid(self):
		queue_free()
