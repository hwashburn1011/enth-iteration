class_name Player
extends CharacterBody3D
## Player character — Globbler. Composed of reusable component nodes.

@export var move_speed: float = 6.0
@export var friction: float = 0.2
@export var turn_speed: float = 10.0
@export var dash_distance: float = 4.0
@export var dash_cooldown: float = 1.0
@export var iframe_duration: float = 0.3

@onready var state_machine: StateMachine = %StateMachine
@onready var health_component: HealthComponent = %HealthComponent
@onready var compute_component: ComputeComponent = %ComputeComponent
@onready var stats_component: StatsComponent = %StatsComponent
@onready var hitbox_component: HitboxComponent = %HitboxComponent
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent
@onready var inventory_component: InventoryComponent = %InventoryComponent
@onready var ability_manager: Node = %AbilityManager
@onready var interaction_area: Area3D = %InteractionArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var model: Node3D = %Model
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer
@onready var attack_cooldown_timer: Timer = %AttackCooldownTimer

var facing_direction: Vector3 = Vector3.FORWARD
var is_invulnerable: bool = false
var can_dash: bool = true
var can_attack: bool = true


func _ready() -> void:
	add_to_group(&"player")
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	health_component.died.connect(_on_died)
	hitbox_component.damage_source = self
	hurtbox_component.hit_received.connect(_on_hit_received)


func receive_hit(damage_info: DamageInfo) -> void:
	if is_invulnerable:
		return
	health_component.take_damage(damage_info.base_damage)
	if health_component.is_dead:
		return  # _on_died handles death transition
	# Store source position for knockback direction
	if damage_info.source is Node3D:
		set_meta(&"damage_source_position", (damage_info.source as Node3D).global_position)
	var hurt_state: State = state_machine.get_node_or_null("HurtState") as State
	if hurt_state:
		state_machine.force_transition_to(hurt_state)


func _on_hit_received(damage_info: DamageInfo) -> void:
	# HurtboxComponent already applied damage via HealthComponent and pipeline.
	# We just need to trigger the hurt state for knockback/stun.
	if is_invulnerable or health_component.is_dead:
		return
	if damage_info.source is Node3D:
		set_meta(&"damage_source_position", (damage_info.source as Node3D).global_position)
	var hurt_state: State = state_machine.get_node_or_null("HurtState") as State
	if hurt_state:
		state_machine.force_transition_to(hurt_state)


func _on_died() -> void:
	var death_state: State = state_machine.get_node_or_null("DeathState") as State
	if death_state:
		state_machine.force_transition_to(death_state)


func _on_dash_cooldown_timeout() -> void:
	can_dash = true


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
