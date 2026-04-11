class_name EquipmentPickup
extends Area3D

## World-space pickup for an outfit item. Spawns a small floating prop with
## a rarity-tinted glow ring + sparkle particles. Player walks over it to grab.

@export var item: OutfitItem
@export var bob_amplitude: float = 0.08
@export var bob_speed: float = 2.0
@export var spin_speed: float = 1.5
@export var pickup_radius: float = 1.0
@export var auto_pickup: bool = true

const RARITY_COLORS: Array[Color] = [
	Color(0.85, 0.85, 0.85, 1),  # 0 common  - white
	Color(0.40, 0.95, 0.40, 1),  # 1 uncommon - green
	Color(0.40, 0.55, 0.95, 1),  # 2 rare    - blue
	Color(0.85, 0.40, 0.95, 1),  # 3 epic    - purple
	Color(0.95, 0.65, 0.20, 1),  # 4 legendary - orange-gold
	Color(0.95, 0.20, 0.20, 1),  # 5 cursed  - crimson
]

@onready var _model: Node3D = $Model
@onready var _glow: OmniLight3D = $GlowLight
@onready var _particles: GPUParticles3D = $Sparkles

var _time: float = 0.0
var _initial_y: float


func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	if _model != null:
		_initial_y = _model.position.y
	_apply_rarity_visuals()


func _apply_rarity_visuals() -> void:
	if item == null:
		return
	var rarity_color: Color = RARITY_COLORS[clampi(item.rarity, 0, RARITY_COLORS.size() - 1)]
	if _glow != null:
		_glow.light_color = rarity_color
		_glow.light_energy = 1.0 + float(item.rarity) * 0.3
	if _particles != null and _particles.process_material is ParticleProcessMaterial:
		var pm: ParticleProcessMaterial = _particles.process_material
		pm.color = rarity_color


func _process(delta: float) -> void:
	_time += delta
	if _model != null:
		_model.position.y = _initial_y + sin(_time * bob_speed) * bob_amplitude
		_model.rotation.y += spin_speed * delta


func _on_body_entered(body: Node3D) -> void:
	if not auto_pickup:
		return
	if body.is_in_group(&"player"):
		_grant_to_player(body)


func _grant_to_player(player: Node3D) -> void:
	var inventory: Node = player.get_node_or_null("InventoryComponent")
	if inventory != null and inventory.has_method("add_item"):
		var ok: bool = inventory.add_item(item)
		if ok:
			if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
				var bus: Node = get_node("/root/EventBus")
				if bus.has_signal("item_picked_up"):
					bus.item_picked_up.emit(item)
			queue_free()
