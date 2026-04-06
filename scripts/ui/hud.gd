class_name HUD
extends CanvasLayer
## Gameplay HUD — health bar, compute bar. Hides during dialogue.

const TWEEN_DURATION: float = 0.2

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var compute_bar: ProgressBar = %ComputeBar
@onready var compute_label: Label = %ComputeLabel
@onready var _container: Control = %HUDContainer

var _health_tween: Tween = null
var _compute_tween: Tween = null


func _ready() -> void:
	layer = 10
	# Connect to player signals after a frame (player may not exist yet)
	_connect_player.call_deferred()
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)


func _connect_player() -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.is_empty():
		return
	var player: Player = nodes[0] as Player
	if player == null:
		return
	player.health_component.health_changed.connect(_on_health_changed)
	player.compute_component.compute_changed.connect(_on_compute_changed)
	# Initialize bars
	_on_health_changed(player.health_component.current_health, player.health_component.max_health)
	_on_compute_changed(player.compute_component.current_compute, player.compute_component.max_compute)


func _on_health_changed(current: float, max_val: float) -> void:
	health_bar.max_value = max_val
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	_health_tween = create_tween()
	_health_tween.tween_property(health_bar, "value", current, TWEEN_DURATION).set_ease(Tween.EASE_OUT)
	health_label.text = "%d / %d" % [int(current), int(max_val)]


func _on_compute_changed(current: float, max_val: float) -> void:
	compute_bar.max_value = max_val
	if _compute_tween and _compute_tween.is_running():
		_compute_tween.kill()
	_compute_tween = create_tween()
	_compute_tween.tween_property(compute_bar, "value", current, TWEEN_DURATION).set_ease(Tween.EASE_OUT)
	compute_label.text = "%d / %d" % [int(current), int(max_val)]


func _on_dialogue_started(_npc_id: StringName) -> void:
	_container.visible = false


func _on_dialogue_ended() -> void:
	_container.visible = true
