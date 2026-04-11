class_name ComputeComponent
extends Node
## Tracks compute (mana) resource for abilities, with passive regeneration.
##
## Stat hooks (recomputed on stats_changed):
##   max_compute = base_max_compute + memory * MEMORY_COMPUTE_SCALE
##   regen_rate  = base_regen_rate  + bandwidth * BANDWIDTH_REGEN_SCALE
## Memory builds give a deeper resource pool; bandwidth builds refill faster.

signal compute_changed(new_value: float, max_value: float)
signal compute_depleted

const MEMORY_COMPUTE_SCALE: float = 5.0
const BANDWIDTH_REGEN_SCALE: float = 0.20

@export var base_max_compute: float = 50.0
@export var base_regen_rate: float = 2.0

var max_compute: float
var regen_rate: float
var current_compute: float
var _last_emitted_compute: float


func _ready() -> void:
	max_compute = base_max_compute
	regen_rate = base_regen_rate
	current_compute = max_compute
	_last_emitted_compute = current_compute
	# Listen for stat changes to recalculate max_compute and regen_rate
	var stats: Node = get_parent().get_node_or_null("StatsComponent") as Node
	if stats:
		stats.stats_changed.connect(_on_stats_changed.bind(stats))
		# Apply current stats immediately on spawn
		_on_stats_changed(stats)


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
	# Compute restore VFX
	var parent: Node = get_parent()
	if parent is Node3D:
		var pos: Vector3 = (parent as Node3D).global_position
		VFXFactory.spawn_compute_particles(pos, parent.get_tree().current_scene)
		VFXFactory.spawn_compute_number(pos, int(amount), parent.get_tree().current_scene)


func reset() -> void:
	current_compute = max_compute
	_last_emitted_compute = current_compute
	compute_changed.emit(current_compute, max_compute)


func get_compute_percentage() -> float:
	if max_compute <= 0.0:
		return 0.0
	return current_compute / max_compute


func _on_stats_changed(stats: Node) -> void:
	## Recalculate max from memory, regen from bandwidth. If max grew, lift
	## current by the diff so a level-up feels immediate (you don't have to
	## wait for regen to fill the new headroom).
	var prev_max: float = max_compute
	max_compute = base_max_compute + stats.get_stat("memory") * MEMORY_COMPUTE_SCALE
	regen_rate = base_regen_rate + stats.get_stat("bandwidth") * BANDWIDTH_REGEN_SCALE
	var diff: float = max_compute - prev_max
	if diff > 0.0:
		current_compute += diff
	current_compute = clampf(current_compute, 0.0, max_compute)
	_last_emitted_compute = current_compute
	compute_changed.emit(current_compute, max_compute)
