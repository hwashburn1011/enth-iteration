class_name State
extends Node
## Base class for all states. Override virtual methods to define behavior.

var state_machine: Node  # StateMachine — untyped to avoid circular dependency
var player: CharacterBody3D
## If false, this state cannot be interrupted by lower-priority transitions.
var can_be_interrupted: bool = true


func enter() -> void:
	pass


func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
