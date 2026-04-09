class_name SlowZone
extends Area3D

## A short-lived ground area that applies a movement slow to any actor in
## the configured group while they're inside it. Self-frees after
## lifetime_s. Carries a Decal child for the visual.
##
## Used by Epic 05 task 29 LeakTrail (and reusable by anything that
## needs to drop a temporary slow patch — frost spells, oil pools,
## tar traps).
##
## Slow application uses an attribute increment on the actor's
## "movement_modifier" property if it exists, otherwise tries to call
## a `set_speed_multiplier` method. The component is forgiving — if
## neither exists it just passes the visual through with no behavior.

signal slow_applied(actor: Node3D)
signal slow_cleared(actor: Node3D)

@export_range(0.1, 30.0) var lifetime_s: float = 6.0
@export_range(0.05, 1.0) var slow_strength: float = 0.55  ## actor speed * this while inside
@export_range(0.5, 8.0) var radius_m: float = 1.2
@export var target_group: StringName = &"player"
@export var slick_color: Color = Color(0.10, 0.45, 0.20, 0.85)
@export var slick_texture_path: String = ""
@export_range(0.1, 4.0) var fade_in_s: float = 0.4
@export_range(0.1, 4.0) var fade_out_s: float = 1.2

var _decal: Decal
var _affected_actors: Dictionary = {}  ## actor → original_speed_multiplier
var _age_s: float = 0.0


func _ready() -> void:
	# Build the area collision shape
	var shape: CollisionShape3D = CollisionShape3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = radius_m
	shape.shape = sphere
	add_child(shape)

	# Build the decal visual
	_build_decal()

	# Wire signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	# Fade-in animation
	_decal.modulate = Color(slick_color.r, slick_color.g, slick_color.b, 0.0)
	var fade_in: Tween = create_tween()
	fade_in.tween_property(_decal, "modulate:a", slick_color.a, fade_in_s) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _build_decal() -> void:
	_decal = Decal.new()
	_decal.name = "SlickDecal"
	var diameter: float = radius_m * 2.0
	_decal.size = Vector3(diameter, 1.5, diameter)
	_decal.modulate = slick_color
	_decal.emission_energy = 0.4
	_decal.albedo_mix = 0.85
	if slick_texture_path != "" and ResourceLoader.exists(slick_texture_path):
		var tex: Texture2D = load(slick_texture_path) as Texture2D
		if tex != null:
			_decal.texture_albedo = tex
			_decal.texture_emission = tex
	add_child(_decal)


func _process(delta: float) -> void:
	_age_s += delta
	if _age_s >= lifetime_s - fade_out_s and _decal.modulate.a > 0.01:
		var remaining: float = max(0.01, lifetime_s - _age_s)
		# Linear fade-out over the remaining time
		var fade_alpha: float = clampf(remaining / fade_out_s, 0.0, 1.0) * slick_color.a
		_decal.modulate = Color(slick_color.r, slick_color.g, slick_color.b, fade_alpha)
	if _age_s >= lifetime_s:
		# Clear all slows before freeing so actors don't get stuck slowed
		for actor: Variant in _affected_actors.keys():
			if is_instance_valid(actor):
				_clear_slow_on(actor)
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	_try_apply_slow(body)


func _on_body_exited(body: Node3D) -> void:
	_try_clear_slow(body)


func _on_area_entered(area: Area3D) -> void:
	_try_apply_slow(area)


func _on_area_exited(area: Area3D) -> void:
	_try_clear_slow(area)


func _try_apply_slow(actor: Node) -> void:
	if not (actor is Node3D):
		return
	if not actor.is_in_group(target_group):
		return
	if _affected_actors.has(actor):
		return  # already slowed by this zone
	_apply_slow_to(actor)
	_affected_actors[actor] = true
	slow_applied.emit(actor)


func _try_clear_slow(actor: Node) -> void:
	if not _affected_actors.has(actor):
		return
	_clear_slow_on(actor)
	_affected_actors.erase(actor)
	slow_cleared.emit(actor)


func _apply_slow_to(actor: Node) -> void:
	# Try the standard project speed-modifier API in priority order
	if actor.has_method("apply_speed_modifier"):
		actor.call("apply_speed_modifier", &"slow_zone", slow_strength)
	elif actor.has_property("movement_modifier"):
		actor.set("movement_modifier", actor.get("movement_modifier") * slow_strength)
	elif actor.has_method("set_speed_multiplier"):
		actor.call("set_speed_multiplier", slow_strength)


func _clear_slow_on(actor: Node) -> void:
	if actor.has_method("remove_speed_modifier"):
		actor.call("remove_speed_modifier", &"slow_zone")
	elif actor.has_property("movement_modifier"):
		actor.set("movement_modifier", actor.get("movement_modifier") / slow_strength)
	elif actor.has_method("set_speed_multiplier"):
		actor.call("set_speed_multiplier", 1.0)
