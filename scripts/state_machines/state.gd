class_name State
extends Node
## Base class for all states. Override virtual methods to define behavior.

var state_machine: StateMachine
var player: CharacterBody3D


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
