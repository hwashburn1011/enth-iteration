class_name ComputeComponent
extends Node
## Tracks compute (mana) resource for abilities, with passive regeneration.

signal compute_changed(new_value: float, max_value: float)
signal compute_depleted

@export var base_max_compute: float = 50.0
@export var regen_rate: float = 2.0

var max_compute: float
var current_compute: float
var _last_emitted_compute: float


func _ready() -> void:
	max_compute = base_max_compute
	current_compute = max_compute
	_last_emitted_compute = current_compute
	# Listen for stat changes to recalculate max_compute
	var stats: Node = get_parent().get_node_or_null("StatsComponent") as Node
	if stats:
		stats.stats_changed.connect(_on_stats_changed.bind(stats))


func _process(delta: float) -> void:
	if current_compute >= max_compute:
		return
	current_compute = minf(max_compute, current_compute + regen_rate * delta)
	# Only emit signal when change is noticeable (>= 0.1)
	if absf(current_compute - _last_emitted_compute) >= 0.1:
		_last_emitted_compute = current_compute
		compute_changed.emit(current_compute, max_compute)


func spend(amount: float) -> bool:
	if current_compute < amount:
		return false
	current_compute -= amount
	_last_emitted_compute = current_compute
	compute_changed.emit(current_compute, max_compute)
	if current_compute <= 0.0:
		compute_depleted.emit()
	return true


func restore(amount: float) -> void:
	current_compute = minf(max_compute, current_compute + amount)
	_last_emitted_compute = current_compute
	compute_changed.emit(current_compute, max_compute)


func reset() -> void:
	current_compute = max_compute
	_last_emitted_compute = current_compute
	compute_changed.emit(current_compute, max_compute)


func get_compute_percentage() -> float:
	return current_compute / max_compute


func _on_stats_changed(stats: Node) -> void:
	max_compute = base_max_compute + stats.get_stat("memory") * 5.0
	current_compute = minf(current_compute, max_compute)
	_last_emitted_compute = current_compute
	compute_changed.emit(current_compute, max_compute)
