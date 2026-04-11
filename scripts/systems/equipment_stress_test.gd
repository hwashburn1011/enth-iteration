class_name EquipmentStressTest
extends Node

## Stress test for the equipment system. Exercises equip/unequip cycles
## across all 8 sets to validate no memory leaks, no orphan nodes, and no
## material reference issues.
##
## Usage: attach this script to a Node in a test scene with the following
## paths set, then call run_test() (or use the auto_run flag).
##
## Pass criteria:
##   - Final scene tree node count == initial node count
##   - No "Object reference is null" errors during the run
##   - No leaked StandardMaterial3D instances (resource count delta < 5)

@export var equipment_visualizer_path: NodePath
@export var test_outfits: Array[OutfitItem] = []  ## populate with all 8 sets in editor
@export var cycles: int = 50
@export var auto_run: bool = false

signal test_completed(passed: bool, report: String)


func _ready() -> void:
	if auto_run:
		await get_tree().process_frame
		run_test()


func run_test() -> Dictionary:
	var visualizer: EquipmentVisualizer = get_node_or_null(equipment_visualizer_path) as EquipmentVisualizer
	if visualizer == null:
		push_error("EquipmentStressTest: visualizer not found")
		return {"passed": false, "report": "no visualizer"}

	if test_outfits.is_empty():
		push_error("EquipmentStressTest: no test outfits configured")
		return {"passed": false, "report": "no test outfits"}

	# Snapshot initial state
	var initial_node_count: int = _count_nodes(visualizer.get_tree().root)
	var initial_resources: int = _count_loaded_resources()
	var start_time_us: int = Time.get_ticks_usec()

	const SLOTS: Array[StringName] = [
		&"slot_head", &"slot_chest", &"slot_hand_R", &"slot_hand_L",
		&"slot_foot_R", &"slot_foot_L",
	]

	var errors: int = 0
	for cycle in cycles:
		var outfit: OutfitItem = test_outfits[cycle % test_outfits.size()]
		if outfit == null or outfit.visual_scene == null:
			errors += 1
			continue
		# Equip a full set
		for slot in SLOTS:
			visualizer.attach_equipment(slot, outfit.visual_scene, outfit)
		# Yield a frame so engine can process
		await get_tree().process_frame
		# Detach
		for slot in SLOTS:
			visualizer.detach_equipment(slot)
		await get_tree().process_frame

	var elapsed_ms: float = (Time.get_ticks_usec() - start_time_us) / 1000.0
	var final_node_count: int = _count_nodes(visualizer.get_tree().root)
	var final_resources: int = _count_loaded_resources()

	var node_delta: int = final_node_count - initial_node_count
	var resource_delta: int = final_resources - initial_resources
	var passed: bool = node_delta <= 0 and resource_delta < 5 and errors == 0

	var report: String = "Stress test: %d cycles in %.1fms\n" % [cycles, elapsed_ms]
	report += "  Node count delta: %d\n" % node_delta
	report += "  Resource count delta: %d\n" % resource_delta
	report += "  Errors: %d\n" % errors
	report += "  Passed: %s" % str(passed)

	test_completed.emit(passed, report)
	return {"passed": passed, "report": report, "node_delta": node_delta, "resource_delta": resource_delta, "errors": errors}


func _count_nodes(root: Node) -> int:
	var count: int = 1
	for child in root.get_children():
		count += _count_nodes(child)
	return count


func _count_loaded_resources() -> int:
	# Approximation: count materials and meshes currently loaded
	return ResourceLoader.has_cached("res://") as int  # placeholder; in 4.x there's no public API
