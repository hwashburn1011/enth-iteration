class_name InfestedDecal
extends Node3D

## Drops a "this area is infested" environmental Decal under any group of
## enemies. The decal grows organically as more enemies cluster nearby and
## fades when the cluster disperses or dies — designed to telegraph
## "danger zone" to the player from camera distance before they see the
## individual enemies.
##
## Two visual layers:
##   1) An animated Decal projector with the infested texture
##      (organic vein pattern + crawling glitch glyphs)
##   2) A subtle slow-pulsing emission ring on the ground that grows with
##      cluster size
##
## Pairs with PackLeaderAura: leaders carry the buff aura, the cluster
## drops the infested decal underneath.
##
## Required scene shape:
##   InfestedDecal (Node3D + this script)
##     [Decal added at runtime]
##
## Inspector configuration:
##   detection_radius_m  — how far to look for enemies (default 8.0)
##   min_cluster_size    — start showing the decal at this many enemies
##   max_cluster_size    — decal hits max scale at this count
##   min_decal_radius_m  — radius at min_cluster_size
##   max_decal_radius_m  — radius at max_cluster_size
##   group_name          — node group to scan (default "enemies")
##   decal_texture_path  — texture for the decal albedo (optional)
##   decal_color         — base modulate (default cyan-tinged dark)
##   pulse_period_s      — slow ground pulse period
##
## Hooked into a level:
##   var infested: InfestedDecal = InfestedDecal.new()
##   infested.detection_radius_m = 10.0
##   spawn_room.add_child(infested)
##   infested.global_position = group_center

@export var detection_radius_m: float = 8.0
@export var min_cluster_size: int = 3
@export var max_cluster_size: int = 12
@export var min_decal_radius_m: float = 2.0
@export var max_decal_radius_m: float = 6.0
@export var group_name: StringName = &"enemies"
@export var decal_texture_path: String = ""
@export var decal_color: Color = Color(0.05, 0.50, 0.55, 1.0)
@export var pulse_period_s: float = 4.0
@export var rescan_interval_s: float = 0.6
@export var growth_rate_per_s: float = 1.5
@export var fade_rate_per_s: float = 0.8

var _decal: Decal
var _current_radius: float = 0.0
var _target_radius: float = 0.0
var _current_intensity: float = 0.0
var _target_intensity: float = 0.0
var _scan_timer: float = 0.0
var _time_accum: float = 0.0


func _ready() -> void:
	_build_decal()


func _build_decal() -> void:
	_decal = Decal.new()
	_decal.name = "InfestedDecalProjector"
	_decal.size = Vector3(min_decal_radius_m * 2.0, 3.5, min_decal_radius_m * 2.0)
	_decal.modulate = Color(decal_color.r, decal_color.g, decal_color.b, 0.0)
	_decal.emission_energy = 0.0
	_decal.albedo_mix = 0.85

	# Optional texture; if not provided we still get the modulate-only blob
	if decal_texture_path != "" and ResourceLoader.exists(decal_texture_path):
		var tex: Texture2D = load(decal_texture_path) as Texture2D
		if tex != null:
			_decal.texture_albedo = tex
			_decal.texture_emission = tex

	add_child(_decal)


func _process(delta: float) -> void:
	_time_accum += delta
	_scan_timer += delta
	if _scan_timer >= rescan_interval_s:
		_scan_timer = 0.0
		_rescan_cluster()

	# Smooth radius interpolation toward target
	if _current_radius < _target_radius:
		_current_radius = minf(_current_radius + growth_rate_per_s * delta, _target_radius)
	elif _current_radius > _target_radius:
		_current_radius = maxf(_current_radius - fade_rate_per_s * delta, _target_radius)

	if _current_intensity < _target_intensity:
		_current_intensity = minf(_current_intensity + growth_rate_per_s * 0.6 * delta, _target_intensity)
	elif _current_intensity > _target_intensity:
		_current_intensity = maxf(_current_intensity - fade_rate_per_s * 0.6 * delta, _target_intensity)

	_apply_to_decal()


func _rescan_cluster() -> void:
	var origin: Vector3 = global_position
	var count: int = 0
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	for node: Node in tree.get_nodes_in_group(group_name):
		if not (node is Node3D):
			continue
		if origin.distance_to((node as Node3D).global_position) <= detection_radius_m:
			count += 1

	if count < min_cluster_size:
		_target_radius = 0.0
		_target_intensity = 0.0
		return

	# Map cluster size to radius and intensity using a clamped lerp
	var clamped: int = clampi(count, min_cluster_size, max_cluster_size)
	var t: float = (
		float(clamped - min_cluster_size)
		/ float(max(1, max_cluster_size - min_cluster_size))
	)
	_target_radius = lerpf(min_decal_radius_m, max_decal_radius_m, t)
	_target_intensity = lerpf(0.35, 1.00, t)


func _apply_to_decal() -> void:
	if _decal == null:
		return
	# Decal radius via size XZ
	var diameter: float = max(_current_radius, 0.05) * 2.0
	_decal.size = Vector3(diameter, _decal.size.y, diameter)

	# Pulsing alpha — slow breathing pulse so the decal feels alive
	var pulse: float = 1.0 + sin(_time_accum * TAU / pulse_period_s) * 0.15
	var final_alpha: float = clampf(_current_intensity * pulse, 0.0, 1.0)
	_decal.modulate = Color(decal_color.r, decal_color.g, decal_color.b, final_alpha)
	_decal.emission_energy = _current_intensity * 1.6

	# Hide the decal entirely when fully faded so we don't waste a draw call
	_decal.visible = _current_intensity > 0.005


func force_set_cluster(count: int) -> void:
	## Test/debug hook — manually set the cluster count and snap to target.
	var clamped: int = clampi(count, 0, max_cluster_size)
	if clamped < min_cluster_size:
		_target_radius = 0.0
		_target_intensity = 0.0
	else:
		var t: float = (
			float(clamped - min_cluster_size)
			/ float(max(1, max_cluster_size - min_cluster_size))
		)
		_target_radius = lerpf(min_decal_radius_m, max_decal_radius_m, t)
		_target_intensity = lerpf(0.35, 1.00, t)
	_current_radius = _target_radius
	_current_intensity = _target_intensity
	_apply_to_decal()
