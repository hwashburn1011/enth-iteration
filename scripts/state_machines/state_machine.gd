class_name StateMachine
extends Node
## Generic state machine. Assign an initial_state and add State children.

@export var initial_state: Node  # State — untyped to avoid circular dependency

var current_state: Node  # State


func _ready() -> void:
	var parent_body: CharacterBody3D = get_parent() as CharacterBody3D
	for child: Node in get_children():
		if child.has_method(&"enter"):
			child.state_machine = self
			child.player = parent_body
	# Use exported initial_state, or fall back to first State child
	if initial_state == null:
		for child: Node in get_children():
			if child.has_method(&"enter"):
				initial_state = child
				break
	# Defer initial enter so parent's @onready vars are initialized first
	if initial_state and get_parent().visible:
		current_state = initial_state
		current_state.enter.call_deferred()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func transition_to(target_state: Node) -> void:
	if current_state:
		if not current_state.can_be_interrupted and target_state != current_state:
			return
		current_state.exit()
	current_state = target_state
	current_state.enter()


## Force a transition regardless of can_be_interrupted (for death, hurt).
func force_transition_to(target_state: Node) -> void:
	if current_state:
		current_state.exit()
	current_state = target_state
	current_state.enter()
