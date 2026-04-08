class_name DroppedItem
extends Area3D
## World item that can be picked up by the player. Bobs, despawns after 60s.

const DESPAWN_TIME: float = 60.0
const BOB_AMPLITUDE: float = 0.1
const BOB_FREQUENCY: float = 2.0
const FADE_DURATION: float = 1.0

var item: Resource = null

var _timer: float = 0.0
var _base_y: float = 0.0
var _player_in_range: bool = false
var _nearby_player: CharacterBody3D = null

@onready var _mesh: MeshInstance3D = %ItemMesh
@onready var _label: Label3D = %ItemLabel
@onready var _tooltip: Label3D = %Tooltip


func _ready() -> void:
	_base_y = position.y + 0.3
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Add glowing platform disc under item
	var platform_scene: PackedScene = load("res://assets/models/props/item_platform.glb") as PackedScene
	if platform_scene:
		var plat: Node3D = platform_scene.instantiate() as Node3D
		add_child(plat)
		plat.position = Vector3(0, 0.01, 0)

	if item:
		_label.text = item.item_name
		# Try loading Blender crystal model
		var crystal: PackedScene = load("res://assets/models/props/item_pickup.glb") as PackedScene
		if crystal:
			var instance: Node3D = crystal.instantiate() as Node3D
			_mesh.add_child(instance)
			# Color the crystal based on rarity
			var rarity_col: Color = _rarity_color(item.rarity)
			for child: Node in instance.get_children():
				if child is MeshInstance3D:
					var mat: StandardMaterial3D = StandardMaterial3D.new()
					mat.albedo_color = rarity_col
					mat.emission_enabled = true
					mat.emission = rarity_col * 0.7
					mat.emission_energy_multiplier = 2.0
					mat.roughness = 0.2
					(child as MeshInstance3D).material_override = mat
		else:
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
	if body.is_in_group(&"player"):
		_player_in_range = true
		_nearby_player = body as CharacterBody3D
		_tooltip.text = "%s [%s]\nPress E to pick up" % [item.item_name, _rarity_name(item.rarity)]
		_tooltip.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player") and body == _nearby_player:
		_player_in_range = false
		_nearby_player = null
		_tooltip.visible = false


func _try_pickup() -> void:
	if _nearby_player == null or item == null:
		return
	if _nearby_player.inventory_component.add_item(item):
		EventBus.item_collected.emit(item)
		# Pickup VFX before freeing
		_spawn_pickup_vfx()
		queue_free()
	else:
		_tooltip.text = "Inventory Full"


func _spawn_pickup_vfx() -> void:
	var scene_root: Node = get_tree().current_scene
	var pos: Vector3 = global_position + Vector3(0, 0.5, 0)
	var color: Color = _rarity_color(item.rarity)
	# Rarity sparkle burst
	VFXFactory.spawn_item_sparkle(pos, item.rarity, scene_root)
	# Pickup text notification
	var label: Label3D = Label3D.new()
	label.text = item.item_name
	label.font_size = 20
	label.modulate = color
	label.outline_modulate = Color(0, 0, 0, 0.7)
	label.outline_size = 3
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = pos + Vector3(0, 0.5, 0)
	scene_root.add_child(label)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "position:y", label.position.y + 1.2, 1.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.4)
	tween.tween_callback(label.queue_free)


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
