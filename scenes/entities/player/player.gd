class_name Player
extends CharacterBody3D
## Player character — Globbler. Composed of reusable component nodes.

@export var move_speed: float = 6.0
@export var friction: float = 0.2
@export var turn_speed: float = 10.0

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

var facing_direction: Vector3 = Vector3.FORWARD


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)

	var direction: Vector3 = Vector3.ZERO
	if input_vector.length() > 0.0:
		# Rotate input by camera Y rotation to get world-space direction
		var camera: Camera3D = get_viewport().get_camera_3d()
		var camera_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y) if camera else Basis.IDENTITY
		direction = camera_basis * Vector3(input_vector.x, 0.0, input_vector.y)
		direction = direction.normalized()

	if direction.length() > 0.0:
		velocity = direction * move_speed
		facing_direction = direction
		# Smooth model rotation toward movement direction
		var target_angle: float = atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, turn_speed * delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, friction)

	move_and_slide()
