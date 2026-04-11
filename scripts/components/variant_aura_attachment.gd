class_name VariantAuraAttachment
extends Node3D

## Composes the per-variant visual aura signature for an enemy by attaching
## the right combination of existing particle/aura/decal components based
## on the variant Resource. The "factory" pattern: one node, takes a
## variant, produces the visual hookup at runtime.
##
## Each variant gets a UNIQUE visible aura that distinguishes it from
## other variants of the same species at gameplay distance:
##
##   Standard         — no extra aura, just the base shader
##   Venom (red)      — drip particle trail emitting downward + red puff
##   Cold (blue)      — frost mist trail + blue absorb light field
##   Tox  (green)     — green gas particle cloud (using bubbling foam emitter)
##   Elite (purple)   — pack leader aura (already exists) + gold sparkle dust
##   Swarm (small)    — minimal: just a faint cyan ember flicker
##   Alpha (large)    — heavy ember trail + ground rumble decal
##   Queen (boss)     — pack leader aura + infested decal + foam emitter
##
## Required scene shape:
##   VariantAuraAttachment (Node3D + this script, child of enemy root)
##     export variant: EnemyVariant resource
##
## On _ready: reads the variant_id and applies_status_effect, then
## adds the right child components (HoverTrailEmitter, BubblingFoamEmitter,
## AbsorbLightField, PackLeaderAura, InfestedDecal, etc) configured with
## the variant's color palette.
##
## Hookup:
##   var aura: VariantAuraAttachment = VariantAuraAttachment.new()
##   aura.variant = preload("res://data/enemies/variants/glitchbug_cold.tres")
##   enemy_root.add_child(aura)

@export var variant: EnemyVariant
@export var auto_apply_on_ready: bool = true

var _attached_components: Array[Node] = []


func _ready() -> void:
	if auto_apply_on_ready:
		apply_variant()


func apply_variant() -> void:
	if variant == null:
		push_warning("VariantAuraAttachment: no variant assigned, skipping")
		return

	# Clear any previously-attached aura components so re-application is safe
	for c: Node in _attached_components:
		if is_instance_valid(c):
			c.queue_free()
	_attached_components.clear()

	# Dispatch by variant_id — covers the launch list. Falls through to
	# applies_status_effect for cross-pollinated variants
	var vid: String = String(variant.variant_id)

	if vid.ends_with("_venom") or variant.applies_status_effect == &"poison":
		_attach_venom_visuals()
	elif vid.ends_with("_cold") or variant.applies_status_effect == &"freeze":
		_attach_cold_visuals()
	elif vid.ends_with("_tox") or variant.applies_status_effect == &"acid":
		_attach_tox_visuals()
	elif vid.ends_with("_elite") or variant.has_pack_leader_aura:
		_attach_elite_visuals()
	elif vid.ends_with("_swarm"):
		_attach_swarm_visuals()
	elif vid.ends_with("_alpha"):
		_attach_alpha_visuals()
	elif vid.ends_with("_queen"):
		_attach_queen_visuals()
	# Standard / unidentified → no extra visuals (the base shader handles it)


# === Variant-specific composers ===

func _attach_venom_visuals() -> void:
	# Drip trail of red embers falling from the body
	var trail: HoverTrailEmitter = HoverTrailEmitter.new()
	trail.name = "VenomDrip"
	trail.trail_color = Color(0.95, 0.10, 0.05, 0.85)
	trail.particle_count = 32
	trail.emission_rate_per_s = 8.0
	trail.particle_lifetime_s = 1.6
	trail.emit_radius_m = 0.25
	trail.rise_speed_m_s = 0.0  # no upward bias — pure drips
	trail.gravity_strength = 5.0
	add_child(trail)
	_attached_components.append(trail)


func _attach_cold_visuals() -> void:
	# Frost mist absorb-light field tinted blue
	var field: AbsorbLightField = AbsorbLightField.new()
	field.name = "ColdField"
	field.field_radius_m = 1.6
	field.absorb_strength = 0.40
	field.tint_color = Color(0.45, 0.85, 1.05)
	field.pulse_period_s = 5.0
	field.pulse_amplitude = 0.05
	add_child(field)
	_attached_components.append(field)

	# Plus a slow upward foam emitter tinted blue (frost mist drifting up)
	var mist: BubblingFoamEmitter = BubblingFoamEmitter.new()
	mist.name = "ColdMist"
	mist.bubble_color = Color(0.65, 0.85, 1.0, 0.55)
	mist.bubble_count = 24
	mist.emit_rate_per_s = 4.0
	mist.bubble_lifetime_s = 2.4
	mist.emit_radius_m = 0.40
	mist.rise_speed_m_s = 0.20
	add_child(mist)
	_attached_components.append(mist)


func _attach_tox_visuals() -> void:
	# Green toxic gas cloud — bubbling foam tinted lime
	var gas: BubblingFoamEmitter = BubblingFoamEmitter.new()
	gas.name = "ToxGas"
	gas.bubble_color = Color(0.55, 0.95, 0.05, 0.65)
	gas.bubble_count = 36
	gas.emit_rate_per_s = 10.0
	gas.bubble_lifetime_s = 2.0
	gas.emit_radius_m = 0.50
	gas.rise_speed_m_s = 0.35
	add_child(gas)
	_attached_components.append(gas)


func _attach_elite_visuals() -> void:
	# Pack leader aura with the variant's crack color
	var aura: PackLeaderAura = PackLeaderAura.new()
	aura.name = "EliteAura"
	aura.aura_radius_m = variant.aura_radius if variant.aura_radius > 0.0 else 1.6
	aura.intensity = variant.aura_intensity if variant.aura_intensity > 0.0 else 2.4
	aura.pulse_color_inner = variant.crack_color_a
	aura.pulse_color_outer = variant.crack_color_b
	aura.buff_type = &"damage"
	aura.buff_radius_m = 6.0
	add_child(aura)
	_attached_components.append(aura)

	# Plus gold sparkle dust embers if the variant has gold accents
	var sparkle: HoverTrailEmitter = HoverTrailEmitter.new()
	sparkle.name = "EliteSparkle"
	sparkle.trail_color = Color(1.0, 0.85, 0.20, 0.85)
	sparkle.particle_count = 24
	sparkle.emission_rate_per_s = 6.0
	sparkle.particle_lifetime_s = 2.2
	sparkle.emit_radius_m = 0.55
	sparkle.rise_speed_m_s = 0.15  # slow upward float
	sparkle.gravity_strength = 0.5
	add_child(sparkle)
	_attached_components.append(sparkle)


func _attach_swarm_visuals() -> void:
	# Minimal — just a faint cyan ember flicker so the small body still
	# reads as the species at distance
	var ember: HoverTrailEmitter = HoverTrailEmitter.new()
	ember.name = "SwarmEmber"
	ember.trail_color = Color(0.0, 0.95, 0.95, 0.6)
	ember.particle_count = 8
	ember.emission_rate_per_s = 3.0
	ember.particle_lifetime_s = 0.8
	ember.emit_radius_m = 0.10
	ember.rise_speed_m_s = 0.4
	ember.gravity_strength = 1.0
	add_child(ember)
	_attached_components.append(ember)


func _attach_alpha_visuals() -> void:
	# Heavy ember trail + slight absorb field for the imposing presence
	var heavy_trail: HoverTrailEmitter = HoverTrailEmitter.new()
	heavy_trail.name = "AlphaEmber"
	heavy_trail.trail_color = Color(0.95, 0.20, 0.10, 0.9)
	heavy_trail.particle_count = 48
	heavy_trail.emission_rate_per_s = 14.0
	heavy_trail.particle_lifetime_s = 1.4
	heavy_trail.emit_radius_m = 0.45
	heavy_trail.rise_speed_m_s = 0.2
	heavy_trail.gravity_strength = 2.0
	add_child(heavy_trail)
	_attached_components.append(heavy_trail)

	var presence: AbsorbLightField = AbsorbLightField.new()
	presence.name = "AlphaPresence"
	presence.field_radius_m = 2.4
	presence.absorb_strength = 0.30
	presence.tint_color = Color(0.55, 0.20, 0.30)
	add_child(presence)
	_attached_components.append(presence)


func _attach_queen_visuals() -> void:
	# Boss-tier: pack leader aura at maximum + infested decal + foam
	var aura: PackLeaderAura = PackLeaderAura.new()
	aura.name = "QueenAura"
	aura.aura_radius_m = 3.5
	aura.intensity = 4.0
	aura.pulse_color_inner = variant.crack_color_a
	aura.pulse_color_outer = variant.crack_color_b
	aura.buff_type = &"damage"
	aura.buff_radius_m = 9.0
	add_child(aura)
	_attached_components.append(aura)

	var decal: InfestedDecal = InfestedDecal.new()
	decal.name = "QueenInfested"
	decal.detection_radius_m = 12.0
	decal.min_cluster_size = 1  # the queen alone counts
	decal.max_decal_radius_m = 8.0
	decal.decal_color = Color(0.50, 0.05, 0.55, 1.0)
	add_child(decal)
	_attached_components.append(decal)

	var foam: BubblingFoamEmitter = BubblingFoamEmitter.new()
	foam.name = "QueenFoam"
	foam.bubble_color = Color(1.0, 0.85, 0.20, 0.7)
	foam.bubble_count = 64
	foam.emit_rate_per_s = 16.0
	foam.bubble_lifetime_s = 2.6
	foam.emit_radius_m = 0.85
	foam.rise_speed_m_s = 0.5
	add_child(foam)
	_attached_components.append(foam)
