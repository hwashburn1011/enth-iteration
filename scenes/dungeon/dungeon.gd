extends Node3D
## Root dungeon scene — spawns the player, manages floor progression via FloorManager.

const FLOOR_DATA_PATHS: Array[String] = [
	"res://data/floors/floor_1_tutorial.tres",
	"res://data/floors/floor_2_escalation.tres",
	"res://data/floors/floor_3_exploration.tres",
	"res://data/floors/floor_4_challenge.tres",
	"res://data/floors/floor_5_boss.tres",
]

const FLOOR_ACCENT_COLORS: Array[Color] = [
	Color(0.08, 0.4, 0.6),    # Floor 1: cyan (tutorial)
	Color(0.1, 0.55, 0.3),    # Floor 2: green (data sector)
	Color(0.6, 0.5, 0.15),    # Floor 3: amber (exploration)
	Color(0.65, 0.3, 0.1),    # Floor 4: orange (challenge)
	Color(0.6, 0.1, 0.1),     # Floor 5: red (boss)
]

const FLOOR_CONFIGS: Dictionary = {
	2: "res://scripts/dungeon/floor_2_config.gd",
	3: "res://scripts/dungeon/floor_3_config.gd",
	4: "res://scripts/dungeon/floor_4_config.gd",
	5: "res://scripts/dungeon/floor_5_config.gd",
}

var _floor_manager: Node = null
var _current_floor_index: int = 0
var _player: CharacterBody3D = null


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)
	# W23: Wire per-iteration dungeon ambient music
	var _iter: int = 1
	if has_node("/root/IterationManager"):
		_iter = int(get_node("/root/IterationManager").current_iteration)
	AudioSceneWiring.wire_dungeon_music(_iter)

	# --- Lighting and Environment ---
	_setup_environment()

	# Spawn player
	var player_scene: PackedScene = load("res://scenes/entities/player/Player.tscn") as PackedScene
	if player_scene:
		_player = player_scene.instantiate() as CharacterBody3D
		add_child(_player)

	# Spawn isometric camera targeting player
	var cam_script: GDScript = load("res://scripts/components/isometric_camera.gd") as GDScript
	var camera: Camera3D = Camera3D.new()
	camera.set_script(cam_script)
	if _player:
		camera.set(&"target", _player)
	add_child(camera)

	# Create FloorManager
	_floor_manager = FloorManager.new()
	_floor_manager.name = "FloorManager"
	add_child(_floor_manager)
	_floor_manager.floor_completed.connect(_on_floor_completed)

	# Spawn HUD
	var hud_scene: PackedScene = load("res://scenes/ui/hud/HUD.tscn") as PackedScene
	if hud_scene:
		var hud: Node = hud_scene.instantiate()
		add_child(hud)

	# Apply saved player data if loading
	SaveManager.apply_to_player(_player)

	# Show "DUNGEON" location label
	_show_location_label("THE DUNGEON")

	# Start with floor 1
	_load_floor(_current_floor_index)


func _show_location_label(location: String) -> void:
	## Cinematic location title — dramatic fade in/out at the top of the screen.
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 85
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_CENTER_TOP)
	holder.offset_left = -300
	holder.offset_right = 300
	holder.offset_top = 140  # below tutorial hint banner area
	holder.offset_bottom = 230
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.modulate.a = 0.0
	canvas.add_child(holder)
	var label: Label = Label.new()
	label.text = location
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_top = 0
	label.offset_bottom = 50
	label.add_theme_font_size_override(&"font_size", 44)
	label.add_theme_color_override(&"font_color", Color(0.9, 0.25, 0.18))
	label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override(&"outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(label)
	var rule: ColorRect = ColorRect.new()
	rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	rule.offset_left = 80
	rule.offset_right = -80
	rule.offset_top = 56
	rule.offset_bottom = 58
	rule.color = Color(0.85, 0.2, 0.12, 0.7)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(rule)
	add_child(canvas)
	var tween: Tween = holder.create_tween()
	tween.tween_property(holder, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(holder, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_IN)
	tween.tween_callback(canvas.queue_free)


func _setup_environment() -> void:
	# V1 demo per-iteration biome tint. Each compaction iteration repaints
	# the dungeon with a different accent so the world visibly mutates as
	# the player loops. Index by current_iteration - 1, clamp to the array
	# length so post-V1 (FINAL_ITERATION = 9) doesn't crash on a missing
	# tint slot. See _bmad-output/v1-demo-backlog.md Phase 2 #12.
	var iter: int = 1
	if has_node("/root/IterationManager"):
		iter = int(get_node("/root/IterationManager").current_iteration)
	var tint: Dictionary = _iteration_tint(iter)
	# Directional light — warm cyan key from above-left, brighter so the new
	# textured surfaces are properly lit and the cellular panel grid pops
	var dir_light: DirectionalLight3D = DirectionalLight3D.new()
	dir_light.rotation_degrees = Vector3(-55, -35, 0)
	dir_light.light_energy = 1.4
	dir_light.light_color = tint["key"] as Color
	dir_light.shadow_enabled = true
	dir_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	dir_light.shadow_bias = 0.05
	add_child(dir_light)

	# Cool blue fill light from opposite side — stronger so shadows aren't pitch black
	var fill_light: DirectionalLight3D = DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(-40, 145, 0)
	fill_light.light_energy = 0.55
	fill_light.light_color = tint["fill"] as Color
	fill_light.shadow_enabled = false
	add_child(fill_light)

	# World environment — dungeon atmosphere
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = tint["bg"] as Color
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = tint["ambient"] as Color
	env.ambient_light_energy = 0.85  # Brighter so floor texture reads
	# Fog for atmosphere — slightly stronger so distance falls off naturally
	env.fog_enabled = true
	env.fog_light_color = tint["fog"] as Color
	env.fog_density = 0.018
	# Tonemap for better contrast
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_white = 6.5
	env.tonemap_exposure = 1.05
	# Glow for emission effects — stronger to make edge strips and LEDs pop
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_strength = 1.1
	env.glow_bloom = 0.28
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	# SSAO for depth in enclosed rooms — stronger to make panel seams pop
	env.ssao_enabled = true
	env.ssao_radius = 1.2
	env.ssao_intensity = 1.4
	env.ssao_detail = 2.5
	# SSIL for indirect light bounces (gives subtle color bleed)
	env.ssil_enabled = true
	env.ssil_radius = 4.0
	env.ssil_intensity = 0.8
	# Volumetric fog for atmospheric depth — slightly stronger
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.025
	env.volumetric_fog_albedo = tint["volume_albedo"] as Color
	env.volumetric_fog_emission = tint["volume_emission"] as Color
	env.volumetric_fog_emission_energy = 0.4
	# Adjustments for color punch
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.05
	env.adjustment_contrast = 1.08
	env.adjustment_saturation = 1.12

	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)


## Per-iteration biome tint table for V1's 4-iteration arc. Iteration 1 is
## the cyan baseline (matches every screenshot taken before this task).
## Iterations 2-4 walk the spectrum: violet → amber → red so the player
## visibly feels the loop deepen. Index by iteration - 1, clamped so any
## post-V1 iteration past 4 reuses the iteration-4 red palette without
## crashing on a missing slot. See _bmad-output/v1-demo-backlog.md #12.
func _iteration_tint(iter: int) -> Dictionary:
	const TINTS: Array[Dictionary] = [
		{
			# Iteration 1 — cyan baseline (the original look)
			"key": Color(0.95, 0.95, 0.92),
			"fill": Color(0.55, 0.7, 1.0),
			"bg": Color(0.05, 0.06, 0.12),
			"ambient": Color(0.25, 0.30, 0.42),
			"fog": Color(0.10, 0.14, 0.22),
			"volume_albedo": Color(0.10, 0.13, 0.20),
			"volume_emission": Color(0.05, 0.08, 0.14),
		},
		{
			# Iteration 2 — violet creeping in
			"key": Color(0.95, 0.90, 0.95),
			"fill": Color(0.65, 0.55, 1.0),
			"bg": Color(0.07, 0.05, 0.14),
			"ambient": Color(0.32, 0.26, 0.45),
			"fog": Color(0.16, 0.12, 0.24),
			"volume_albedo": Color(0.14, 0.10, 0.22),
			"volume_emission": Color(0.10, 0.06, 0.16),
		},
		{
			# Iteration 3 — amber distortion
			"key": Color(1.0, 0.92, 0.80),
			"fill": Color(0.85, 0.65, 0.45),
			"bg": Color(0.10, 0.07, 0.06),
			"ambient": Color(0.40, 0.30, 0.20),
			"fog": Color(0.22, 0.16, 0.10),
			"volume_albedo": Color(0.20, 0.14, 0.10),
			"volume_emission": Color(0.16, 0.10, 0.05),
		},
		{
			# Iteration 4 — red end-game (the simulation breaking apart)
			"key": Color(1.0, 0.85, 0.78),
			"fill": Color(1.0, 0.45, 0.40),
			"bg": Color(0.13, 0.04, 0.05),
			"ambient": Color(0.45, 0.20, 0.18),
			"fog": Color(0.25, 0.10, 0.10),
			"volume_albedo": Color(0.22, 0.08, 0.08),
			"volume_emission": Color(0.18, 0.05, 0.05),
		},
		{
			# Iteration 5 — deep crimson corruption
			"key": Color(1.0, 0.78, 0.75),
			"fill": Color(0.95, 0.30, 0.35),
			"bg": Color(0.15, 0.03, 0.04),
			"ambient": Color(0.50, 0.15, 0.15),
			"fog": Color(0.28, 0.08, 0.08),
			"volume_albedo": Color(0.25, 0.06, 0.06),
			"volume_emission": Color(0.20, 0.04, 0.04),
		},
		{
			# Iteration 6 — white void / decompression
			"key": Color(1.0, 1.0, 0.98),
			"fill": Color(0.90, 0.92, 1.0),
			"bg": Color(0.12, 0.12, 0.15),
			"ambient": Color(0.50, 0.50, 0.55),
			"fog": Color(0.20, 0.20, 0.25),
			"volume_albedo": Color(0.18, 0.18, 0.22),
			"volume_emission": Color(0.12, 0.12, 0.16),
		},
		{
			# Iteration 7 — fragmentation / glitch mosaic
			"key": Color(0.90, 1.0, 0.85),
			"fill": Color(0.40, 0.95, 0.55),
			"bg": Color(0.04, 0.12, 0.06),
			"ambient": Color(0.20, 0.45, 0.25),
			"fog": Color(0.08, 0.22, 0.10),
			"volume_albedo": Color(0.06, 0.20, 0.08),
			"volume_emission": Color(0.04, 0.16, 0.06),
		},
		{
			# Iteration 8 — recursion / infinite mirror
			"key": Color(0.85, 0.85, 1.0),
			"fill": Color(0.50, 0.50, 1.0),
			"bg": Color(0.06, 0.06, 0.16),
			"ambient": Color(0.25, 0.25, 0.55),
			"fog": Color(0.10, 0.10, 0.28),
			"volume_albedo": Color(0.08, 0.08, 0.25),
			"volume_emission": Color(0.06, 0.06, 0.20),
		},
		{
			# Iteration 9 — origin / pure white
			"key": Color(1.0, 1.0, 1.0),
			"fill": Color(0.95, 0.95, 0.98),
			"bg": Color(0.18, 0.18, 0.20),
			"ambient": Color(0.60, 0.60, 0.62),
			"fog": Color(0.30, 0.30, 0.32),
			"volume_albedo": Color(0.25, 0.25, 0.28),
			"volume_emission": Color(0.18, 0.18, 0.22),
		},
	]
	var idx: int = clampi(iter - 1, 0, TINTS.size() - 1)
	return TINTS[idx]


func _load_floor(index: int) -> void:
	if index >= FLOOR_DATA_PATHS.size():
		push_warning("Dungeon: all floors completed")
		return
	var data: Resource = load(FLOOR_DATA_PATHS[index]) as Resource
	if data == null:
		push_error("Dungeon: failed to load floor data at index %d" % index)
		return

	# Set floor accent color for room theming
	if index < FLOOR_ACCENT_COLORS.size():
		GameManager.set_meta(&"floor_accent_color", FLOOR_ACCENT_COLORS[index])
		# Update world environment fog to match floor theme
		_update_environment_for_floor(FLOOR_ACCENT_COLORS[index])

	# Set floor-specific room configurator
	var floor_number: int = data.floor_number
	if floor_number in FLOOR_CONFIGS:
		var config_script: GDScript = load(FLOOR_CONFIGS[floor_number]) as GDScript
		if config_script:
			_floor_manager.room_configurator = Callable(config_script, "configure_room")
		else:
			_floor_manager.room_configurator = Callable()
	else:
		_floor_manager.room_configurator = Callable()

	_floor_manager.load_floor(data)


func _on_floor_completed(floor_number: int) -> void:
	_current_floor_index += 1
	# Floor clear celebration
	_show_floor_clear_banner(floor_number)
	if _current_floor_index < FLOOR_DATA_PATHS.size():
		# Brief pause before loading next floor
		await get_tree().create_timer(2.0).timeout
		_load_floor(_current_floor_index)
	else:
		# Full dungeon clear — final boss is down. This is the moment
		# the compaction loop closes and the next iteration unlocks.
		# Without this advance the player is permanently stuck on iter 1
		# and the IterationManager / enemy HP scaling work from Epic 4
		# never engages.
		_advance_compaction_iteration()
		await get_tree().create_timer(2.0).timeout
		EventBus.returned_to_town.emit()
		GameManager.set_meta(&"town_entry_type", "portal_return")
		GameManager.change_scene_to("res://scenes/town/Town.tscn")


func _advance_compaction_iteration() -> void:
	if not has_node("/root/IterationManager"):
		return
	var im: Node = get_node("/root/IterationManager")
	if not im.has_method(&"advance_iteration"):
		return
	# Skip the no-op when the player is already at the final iteration so
	# the banner doesn't claim a fresh advance that didn't happen.
	if im.has_method(&"is_final_iteration") and im.is_final_iteration():
		return
	var prev_iter: int = int(im.get_current_iteration()) if im.has_method(&"get_current_iteration") else 1
	im.advance_iteration()
	var new_iter: int = int(im.get_current_iteration()) if im.has_method(&"get_current_iteration") else prev_iter + 1
	# Phase 5 #42 — tag the completed iteration so town.gd can play revelations
	GameManager.set_meta(&"just_completed_iteration", prev_iter)
	_show_iteration_compacted_banner(prev_iter, new_iter)


func _show_iteration_compacted_banner(prev_iter: int, new_iter: int) -> void:
	## Bigger sister to _show_floor_clear_banner — fires once per dungeon
	## clear when the compaction loop closes. Same tween shape so the two
	## banners feel consistent, but with a violet/cyan accent so the
	## iteration banner reads as a higher-tier event than a floor clear.
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 86  # one above the floor clear banner
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_CENTER)
	holder.offset_left = -340
	holder.offset_right = 340
	holder.offset_top = -70
	holder.offset_bottom = 80
	holder.pivot_offset = Vector2(340, 75)
	holder.modulate.a = 0.0
	holder.scale = Vector2(0.65, 0.65)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(holder)
	# Subtitle "ITERATION N → N+1"
	var sub: Label = Label.new()
	sub.text = "ITERATION %d → %d" % [prev_iter, new_iter]
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.offset_top = 0
	sub.offset_bottom = 28
	sub.add_theme_font_size_override(&"font_size", 22)
	sub.add_theme_color_override(&"font_color", Color(0.55, 0.85, 1.0))
	sub.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.9))
	sub.add_theme_constant_override(&"outline_size", 4)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(sub)
	# Main "COMPACTED"
	var label: Label = Label.new()
	label.text = "COMPACTED"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_top = 32
	label.offset_bottom = 110
	label.add_theme_font_size_override(&"font_size", 64)
	label.add_theme_color_override(&"font_color", Color(0.75, 0.55, 1.0))
	label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.92))
	label.add_theme_constant_override(&"outline_size", 9)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(label)
	var rule: ColorRect = ColorRect.new()
	rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	rule.offset_left = 110
	rule.offset_right = -110
	rule.offset_top = 116
	rule.offset_bottom = 119
	rule.color = Color(0.65, 0.45, 0.95, 0.8)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(rule)
	# T16 iteration debrief: biome name + "what changed" line so the
	# player has something to actually READ during the compacted moment.
	# Sourced from the same iteration table the dungeon environment tint
	# in T12 uses, so the rendered colours and the announced biome agree.
	var debrief: Dictionary = _iteration_debrief(new_iter)
	var biome_label: Label = Label.new()
	biome_label.text = debrief["biome"] as String
	biome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	biome_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	biome_label.offset_top = 124
	biome_label.offset_bottom = 154
	biome_label.add_theme_font_size_override(&"font_size", 24)
	biome_label.add_theme_color_override(&"font_color", debrief["color"] as Color)
	biome_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.92))
	biome_label.add_theme_constant_override(&"outline_size", 4)
	biome_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(biome_label)
	var change_label: Label = Label.new()
	change_label.text = debrief["change"] as String
	change_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	change_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	change_label.offset_top = 156
	change_label.offset_bottom = 184
	change_label.add_theme_font_size_override(&"font_size", 16)
	change_label.add_theme_color_override(&"font_color", Color(0.85, 0.88, 0.95))
	change_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	change_label.add_theme_constant_override(&"outline_size", 3)
	change_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(change_label)
	# Make the holder taller to fit the new lines without overlap
	holder.offset_top = -110
	holder.offset_bottom = 110
	add_child(canvas)
	var tween: Tween = holder.create_tween()
	tween.tween_property(holder, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(holder, "scale", Vector2(1.08, 1.08), 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(holder, "scale", Vector2(1.0, 1.0), 0.15)
	# Hold for 4.5s now (was 2.2s) so the player can actually READ the
	# biome name and what-changed line. The total banner time is still
	# under 6s — short enough that the player isn't stuck staring at it.
	tween.tween_interval(4.5)
	tween.tween_property(holder, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_IN)
	tween.tween_callback(canvas.queue_free)


## Per-iteration debrief data — biome name + a one-line "what changed"
## hint shown on the compacted banner. Mirrors the tint table in
## _iteration_tint() so the announced biome and the rendered palette
## agree. Index by iteration - 1, clamped against the array length so
## any post-V1 iteration past 4 reuses the iteration-4 entry.
func _iteration_debrief(iter: int) -> Dictionary:
	const ENTRIES: Array[Dictionary] = [
		{
			"biome": "BASELINE  ·  CYAN ARCHIVE",
			"change": "The simulation is stable. For now.",
			"color": Color(0.55, 0.85, 1.0),
		},
		{
			"biome": "DRIFT  ·  VIOLET STRATA",
			"change": "Memory pages bleed at the seams. Enemies hit harder.",
			"color": Color(0.75, 0.55, 1.0),
		},
		{
			"biome": "DECAY  ·  AMBER FAULT",
			"change": "The kernel is leaking. The dungeon remembers you now.",
			"color": Color(0.95, 0.75, 0.30),
		},
		{
			"biome": "COLLAPSE  ·  RED HORIZON",
			"change": "Final compaction. Whatever you're chasing — it's down here.",
			"color": Color(1.0, 0.40, 0.35),
		},
		# R2 H21: iteration 5 biome — deep corrupted
		{
			"biome": "CORRUPTION  ·  DEEP CRIMSON",
			"change": "The simulation's core is exposed. Reality tears at the edges.",
			"color": Color(0.85, 0.15, 0.25),
		},
		# R2 H22: iteration 6 biome — void / decompressed
		{
			"biome": "DECOMPRESSION  ·  WHITE VOID",
			"change": "Nothing left to compress. The raw data of existence, laid bare.",
			"color": Color(0.95, 0.95, 1.0),
		},
		# R3 K1: iteration 7 biome — fragmentation / glitch mosaic
		{
			"biome": "FRAGMENTATION  ·  GLITCH MOSAIC",
			"change": "Data splits into contradictory copies. The walls are made of memories.",
			"color": Color(0.40, 0.95, 0.55),
		},
		# R3 K2: iteration 8 biome — recursion / infinite mirror
		{
			"biome": "RECURSION  ·  INFINITE MIRROR",
			"change": "Every surface reflects another. The simulation folds inward.",
			"color": Color(0.50, 0.50, 1.0),
		},
		# R3 K3: iteration 9 biome — origin / pure white
		{
			"biome": "ORIGIN  ·  PURE WHITE",
			"change": "The beginning and the end. One byte. One choice. One moment.",
			"color": Color(1.0, 1.0, 1.0),
		},
	]
	var idx: int = clampi(iter - 1, 0, ENTRIES.size() - 1)
	return ENTRIES[idx]


func _update_environment_for_floor(accent: Color) -> void:
	## Tint dungeon environment fog + volumetric fog to match floor accent
	var world_env: WorldEnvironment = null
	for child: Node in get_children():
		if child is WorldEnvironment:
			world_env = child as WorldEnvironment
			break
	if world_env == null or world_env.environment == null:
		return
	var env: Environment = world_env.environment
	# Fog tint toward accent
	env.fog_light_color = Color(
		0.08 + accent.r * 0.15,
		0.1 + accent.g * 0.15,
		0.15 + accent.b * 0.15
	)
	# Volumetric fog emission
	env.volumetric_fog_albedo = Color(
		0.06 + accent.r * 0.12,
		0.08 + accent.g * 0.12,
		0.13 + accent.b * 0.15
	)
	env.volumetric_fog_emission = Color(
		0.03 + accent.r * 0.08,
		0.05 + accent.g * 0.08,
		0.08 + accent.b * 0.1
	)
	# Ambient light shift
	env.ambient_light_color = Color(
		0.18 + accent.r * 0.1,
		0.2 + accent.g * 0.1,
		0.28 + accent.b * 0.1
	)


func _show_floor_clear_banner(floor_number: int) -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 85
	# Holder so the entire group fades + scales together with proper pivot
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_CENTER)
	holder.offset_left = -300
	holder.offset_right = 300
	holder.offset_top = -50
	holder.offset_bottom = 60
	holder.pivot_offset = Vector2(300, 55)
	holder.modulate.a = 0.0
	holder.scale = Vector2(0.7, 0.7)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(holder)
	# Subtitle "FLOOR N"
	var sub: Label = Label.new()
	sub.text = "FLOOR %d" % floor_number
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.offset_top = 0
	sub.offset_bottom = 24
	sub.add_theme_font_size_override(&"font_size", 18)
	sub.add_theme_color_override(&"font_color", Color(0.55, 0.85, 0.85))
	sub.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	sub.add_theme_constant_override(&"outline_size", 4)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(sub)
	# Main "CLEARED"
	var label: Label = Label.new()
	label.text = "CLEARED"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_top = 28
	label.offset_bottom = 90
	label.add_theme_font_size_override(&"font_size", 56)
	label.add_theme_color_override(&"font_color", Color(0.95, 0.85, 0.25))
	label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override(&"outline_size", 8)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(label)
	# Decorative underline rule
	var rule: ColorRect = ColorRect.new()
	rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	rule.offset_left = 100
	rule.offset_right = -100
	rule.offset_top = 96
	rule.offset_bottom = 99
	rule.color = Color(0.95, 0.8, 0.2, 0.7)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(rule)
	add_child(canvas)
	# Cinematic in/hold/out — use sequential tween with parallel sub-tweens
	var tween: Tween = holder.create_tween()
	# Phase 1: fade-in + scale-pop in parallel
	tween.tween_property(holder, "modulate:a", 1.0, 0.35).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(holder, "scale", Vector2(1.05, 1.05), 0.35).set_ease(Tween.EASE_OUT)
	# Phase 2: settle scale
	tween.tween_property(holder, "scale", Vector2(1.0, 1.0), 0.12)
	# Phase 3: hold
	tween.tween_interval(1.8)
	# Phase 4: fade out
	tween.tween_property(holder, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	tween.tween_callback(canvas.queue_free)
	# VFX burst at player position
	if _player and _player.is_inside_tree():
		VFXFactory.spawn_level_up_effect(_player.global_position, get_tree().current_scene)
