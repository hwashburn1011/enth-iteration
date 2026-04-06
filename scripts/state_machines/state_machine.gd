class_name StateMachine
extends Node
## Generic state machine. Assign an initial_state and add State children.

@export var initial_state: State

var current_state: State


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			child.state_machine = self
	if initial_state:
		current_state = initial_state
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func transition_to(target_state: State) -> void:
	if current_state:
		current_state.exit()
	current_state = target_state
	current_state.enter()
