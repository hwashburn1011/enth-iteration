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
@onready var hitbox_component: Area3D = %HitboxComponent
@onready var hurtbox_component: Area3D = %HurtboxComponent
@onready var inventory_component: Node = %InventoryComponent
@onready var ability_manager: Node = %AbilityManager
@onready var interaction_area: Area3D = %InteractionArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var model: Node3D = %Model
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer

var facing_direction: Vector3 = Vector3.FORWARD
var is_invulnerable: bool = false
var can_dash: bool = true


func _ready() -> void:
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
