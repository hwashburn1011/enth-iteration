class_name EnemyBase
extends CharacterBody3D
## Base enemy — all enemy types inherit from this scene.

@export var move_speed: float = 3.0
@export var patrol_radius: float = 5.0
@export var attack_range: float = 2.0
@export var leash_time: float = 5.0

@onready var state_machine: Node = %StateMachine
@onready var health_component: Node = %HealthComponent
@onready var stats_component: Node = %StatsComponent
@onready var hitbox_component: Node = %HitboxComponent
@onready var hurtbox_component: Node = %HurtboxComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var detection_area: Area3D = %DetectionArea
@onready var loot_dropper: Node = %LootDropper
@onready var model: Node3D = %Model

var target_player: Node3D = null
var spawn_position: Vector3 = Vector3.ZERO
var is_invulnerable: bool = false


func _ready() -> void:
	add_to_group(&"enemies")
	spawn_position = global_position
	hitbox_component.damage_source = self
	hurtbox_component.hit_received.connect(_on_hit_received)
	health_component.died.connect(_on_died)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)


func _on_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		target_player = body


func _on_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player") and body == target_player:
		target_player = null


func _on_hit_received(damage_info: Resource) -> void:
	if health_component.is_dead:
		return
	if damage_info.source is Node3D:
		set_meta(&"damage_source_position", (damage_info.source as Node3D).global_position)
	# Aggro on hit
	if target_player == null and damage_info.source.is_in_group(&"player"):
		target_player = damage_info.source as Node3D
	var hurt_state: Node = state_machine.get_node_or_null("EnemyHurtState") as Node
	if hurt_state:
		state_machine.force_transition_to(hurt_state)


func reset() -> void:
	health_component.reset()
	is_invulnerable = false
	target_player = null
	collision_layer = 2
	collision_mask = 9
	set_physics_process(true)
	set_process_unhandled_input(true)
	hitbox_component.deactivate()
	# Reset state machine to idle
	var idle_state: Node = state_machine.get_node_or_null("EnemyIdleState") as Node
	if idle_state:
		state_machine.force_transition_to(idle_state)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
