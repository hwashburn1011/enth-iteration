class_name Player
extends CharacterBody3D
## Player character — Globbler. Composed of reusable component nodes.

@onready var state_machine: StateMachine = %StateMachine
@onready var health_component: Node = %HealthComponent
@onready var compute_component: Node = %ComputeComponent
@onready var stats_component: Node = %StatsComponent
@onready var hitbox_component: Area3D = %HitboxComponent
@onready var hurtbox_component: Area3D = %HurtboxComponent
@onready var inventory_component: Node = %InventoryComponent
@onready var ability_manager: Node = %AbilityManager
@onready var interaction_area: Area3D = %InteractionArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var model: Node3D = %Model
