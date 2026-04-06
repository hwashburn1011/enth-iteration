class_name StateMachine
extends Node
## Generic state machine. Assign an initial_state and add State children.

@export var initial_state: State

var current_state: State


func _ready() -> void:
	var parent_body: CharacterBody3D = get_parent() as CharacterBody3D
	for child: Node in get_children():
		if child is State:
			child.state_machine = self
			child.player = parent_body
	# Use exported initial_state, or fall back to first State child
	if initial_state == null:
		for child: Node in get_children():
			if child is State:
				initial_state = child as State
				break
	if initial_state:
		current_state = initial_state
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func transition_to(target_state: State) -> void:
	if current_state:
		if not current_state.can_be_interrupted and target_state != current_state:
			# Only allow forced transitions (death overrides everything)
			return
		current_state.exit()
	current_state = target_state
	current_state.enter()


## Force a transition regardless of can_be_interrupted (for death, hurt).
func force_transition_to(target_state: State) -> void:
	if current_state:
		current_state.exit()
	current_state = target_state
	current_state.enter()
