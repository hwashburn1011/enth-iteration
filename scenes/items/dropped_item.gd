class_name DroppedItem
extends Area3D
## World item that can be picked up by the player. Bobs, despawns after 60s.

const DESPAWN_TIME: float = 60.0
const BOB_AMPLITUDE: float = 0.1
const BOB_FREQUENCY: float = 2.0
const FADE_DURATION: float = 1.0

var item: ItemBase = null

var _timer: float = 0.0
var _base_y: float = 0.0
var _player_in_range: bool = false
var _nearby_player: Player = null

@onready var _mesh: MeshInstance3D = %ItemMesh
@onready var _label: Label3D = %ItemLabel
@onready var _tooltip: Label3D = %Tooltip


func _ready() -> void:
	_base_y = position.y + 0.3
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if item:
		_label.text = item.item_name
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = _rarity_color(item.rarity)
		_mesh.material_override = mat

	_tooltip.visible = false


func _process(delta: float) -> void:
	_timer += delta

	# Bobbing
	_mesh.position.y = _base_y + sin(_timer * BOB_FREQUENCY * TAU) * BOB_AMPLITUDE

	# Despawn
	if _timer >= DESPAWN_TIME - FADE_DURATION:
		var fade_progress: float = (_timer - (DESPAWN_TIME - FADE_DURATION)) / FADE_DURATION
		_mesh.transparency = clampf(fade_progress, 0.0, 1.0)
		if _timer >= DESPAWN_TIME:
			queue_free()
			return


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _nearby_player == null:
		return
	if event.is_action_pressed(&"interact"):
		_try_pickup()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_player_in_range = true
		_nearby_player = body as Player
		_tooltip.text = "%s [%s]\nPress E to pick up" % [item.item_name, _rarity_name(item.rarity)]
		_tooltip.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player and body == _nearby_player:
		_player_in_range = false
		_nearby_player = null
		_tooltip.visible = false


func _try_pickup() -> void:
	if _nearby_player == null or item == null:
		return
	if _nearby_player.inventory_component.add_item(item):
		EventBus.item_collected.emit(item)
		queue_free()
	else:
		_tooltip.text = "Inventory Full"


func _rarity_color(rarity: int) -> Color:
	match rarity:
		0: return Color(0.9, 0.9, 0.9)
		1: return Color(0.3, 0.9, 0.3)
		2: return Color(0.3, 0.5, 1.0)
		3: return Color(1.0, 0.85, 0.1)
		_: return Color.WHITE


func _rarity_name(rarity: int) -> String:
	match rarity:
		0: return "Common"
		1: return "Uncommon"
		2: return "Rare"
		3: return "Legendary"
		_: return "Unknown"
