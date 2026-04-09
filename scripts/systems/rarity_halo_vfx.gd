class_name RarityHaloVFX
extends Node3D

## Spawns a colored halo + rotating glyph + ambient particles around equipment
## of legendary tier or higher. Attached as a child of the slot mount when
## the equipped item's rarity >= halo_threshold.

@export var halo_threshold: int = 3  ## epic and above
@export var rarity: int = 0
@export var radius: float = 0.6

const RARITY_PALETTE: Array[Color] = [
	Color(0.85, 0.85, 0.85, 1),
	Color(0.40, 0.95, 0.40, 1),
	Color(0.40, 0.55, 0.95, 1),
	Color(0.85, 0.40, 0.95, 1),
	Color(0.95, 0.65, 0.20, 1),
	Color(0.95, 0.20, 0.20, 1),
]

@onready var _ring_mesh: MeshInstance3D = $Ring
@onready var _glyph: MeshInstance3D = $Glyph
@onready var _light: OmniLight3D = $Light
@onready var _particles: GPUParticles3D = $AmbientMotes


func _ready() -> void:
	_apply_rarity()


func set_rarity(new_rarity: int) -> void:
	rarity = new_rarity
	_apply_rarity()


func _apply_rarity() -> void:
	visible = rarity >= halo_threshold
	if not visible:
		return

	var color: Color = RARITY_PALETTE[clampi(rarity, 0, RARITY_PALETTE.size() - 1)]

	if _light != null:
		_light.light_color = color
		_light.light_energy = 1.5 + float(rarity - halo_threshold) * 0.5
		_light.omni_range = radius * 3.0

	if _ring_mesh != null and _ring_mesh.material_override is StandardMaterial3D:
		var mat: StandardMaterial3D = _ring_mesh.material_override
		mat.albedo_color = color
		mat.emission = color
		mat.emission_energy_multiplier = 4.0

	if _glyph != null and _glyph.material_override is StandardMaterial3D:
		var gm: StandardMaterial3D = _glyph.material_override
		gm.albedo_color = color
		gm.emission = color
		gm.emission_energy_multiplier = 5.0

	if _particles != null and _particles.process_material is ParticleProcessMaterial:
		var pm: ParticleProcessMaterial = _particles.process_material
		pm.color = color


func _process(delta: float) -> void:
	if not visible:
		return
	# Slow rotation on the glyph for visual interest
	if _glyph != null:
		_glyph.rotation.y += delta * 0.8
	if _ring_mesh != null:
		_ring_mesh.rotation.y -= delta * 0.4
