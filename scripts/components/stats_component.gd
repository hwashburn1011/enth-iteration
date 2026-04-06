class_name StatsComponent
extends Node
## Holds the four base stats: Processing, Bandwidth, Memory, Integrity.

signal stats_changed

@export var base_processing: float = 10.0
@export var base_bandwidth: float = 10.0
@export var base_memory: float = 10.0
@export var base_integrity: float = 10.0


func get_stat(stat_name: String) -> float:
	return 0.0
