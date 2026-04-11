class_name CraftingStation
extends Node3D

## A world-space crafting station the player can interact with. Drives the
## crafting UI and ambient effects (SFX, particles). One subclass per type
## (or just configure via @export station_type).

signal station_opened(station_type: StringName)
signal station_closed

@export var station_type: StringName = &"forge"  ## forge / lab / loom / compiler
@export var station_name: String = "Forge"
@export var ambient_sfx_path: NodePath
@export var ambient_particles_path: NodePath
@export var idle_sfx_volume_db: float = -12.0
@export var active_sfx_volume_db: float = -6.0

var _player_in_range: bool = false
var _opened: bool = false
var _ambient_sfx: AudioStreamPlayer3D
var _ambient_particles: GPUParticles3D


func _ready() -> void:
	add_to_group(&"interactable")
	add_to_group(&"crafting_station")
	_ambient_sfx = get_node_or_null(ambient_sfx_path) as AudioStreamPlayer3D
	_ambient_particles = get_node_or_null(ambient_particles_path) as GPUParticles3D
	if _ambient_sfx != null:
		_ambient_sfx.volume_db = idle_sfx_volume_db
		_ambient_sfx.play()
	if _ambient_particles != null:
		_ambient_particles.emitting = true


func interact(player: Node) -> void:
	if _opened:
		return
	_opened = true
	# Boost ambient effects when active
	if _ambient_sfx != null:
		_ambient_sfx.volume_db = active_sfx_volume_db
	station_opened.emit(station_type)

	# Notify the HUD via EventBus
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("crafting_station_opened"):
			bus.crafting_station_opened.emit(self, player)


func close_station() -> void:
	if not _opened:
		return
	_opened = false
	if _ambient_sfx != null:
		_ambient_sfx.volume_db = idle_sfx_volume_db
	station_closed.emit()


func get_tier_for_player(player: Node) -> int:
	var crafting: Node = player.get_node_or_null("CraftingComponent")
	if crafting == null:
		return 1
	return crafting.station_tiers.get(station_type, 1)


func get_recipes_for_player(player: Node) -> Array:
	var crafting: Node = player.get_node_or_null("CraftingComponent")
	if crafting == null:
		return []
	return crafting.get_known_recipes_for_station(station_type)
