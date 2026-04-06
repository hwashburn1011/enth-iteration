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
@onready var equipment_component: EquipmentComponent = %EquipmentComponent
@onready var ability_manager: AbilityManager = %AbilityManager
@onready var level_component: LevelComponent = %LevelComponent
@onready var interaction_area: Area3D = %InteractionArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var model: Node3D = %Model
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer
@onready var attack_cooldown_timer: Timer = %AttackCooldownTimer

var facing_direction: Vector3 = Vector3.FORWARD
var is_invulnerable: bool = false
var can_dash: bool = true
var can_attack: bool = true
var _prompt_cooldown: float = 0.0


func _ready() -> void:
	add_to_group(&"player")
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	health_component.died.connect(_on_died)
	hitbox_component.damage_source = self
	hurtbox_component.hit_received.connect(_on_hit_received)
	level_component.leveled_up.connect(_on_leveled_up)


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


func _process(delta: float) -> void:
	if _prompt_cooldown > 0.0:
		_prompt_cooldown -= delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"use_prompt"):
		_try_use_prompt()
	elif event.is_action_pressed(&"inventory"):
		inventory_component.cycle_active_prompt()


func _try_use_prompt() -> void:
	if _prompt_cooldown > 0.0:
		return
	# Block during dash or death
	var current: State = state_machine.current_state
	if current is PlayerDashState or current is PlayerDeathState:
		return
	var prompt: PromptItem = inventory_component.consume_active_prompt()
	if prompt == null:
		return
	match prompt.prompt_type:
		"health":
			health_component.heal(prompt.restore_amount)
		"compute":
			compute_component.restore(prompt.restore_amount)
		"buff":
			var sem: StatusEffectManager = get_node_or_null("StatusEffectManager") as StatusEffectManager
			if sem:
				var effect: StatusEffect = StatusEffect.new()
				effect.effect_name = "Overclocked"
				effect.effect_type = "overclocked"
				effect.duration = prompt.buff_duration
				effect.tick_rate = 1.0
				effect.potency = 1.0
				sem.apply_effect(effect)
	_prompt_cooldown = 0.5


func _on_leveled_up(new_level: int) -> void:
	var panel: StatAllocationPanel = StatAllocationPanel.new()
	get_tree().root.add_child(panel)
	panel.show_panel(self)


func _on_dash_cooldown_timeout() -> void:
	can_dash = true


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
