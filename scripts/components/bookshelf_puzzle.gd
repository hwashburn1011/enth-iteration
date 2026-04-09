class_name BookshelfPuzzle
extends Node3D

## The hidden bookshelf sequence puzzle in Sage's library. Five books
## on the second bookshelf can be pulled by the player; pulling them
## in the correct sequence opens the door to the Hidden Treasure Room.
##
## The correct sequence is hinted by reading 5 lore tablets in the
## wilderness ruins:
##   1. spire_glyphs    — read at the Tilted Spire (Epic 23)
##   2. arch_inscription — read at the Town Gate Archway (Epic 23)
##   3. bridge_journal  — read at the Half-Built Bridge (Epic 23)
##   4. memorial_plaque — read at the Iteration Memorial (Epic 22)
##   5. shrine_bowl     — read at the Shrine of the Loop (Epic 23)
##
## The player can attempt the puzzle WITHOUT having read all the
## tablets, but pulling a wrong book resets the sequence (and a soft
## audio cue tells them they got it wrong). Once solved, the puzzle
## stays solved across iterations and save files.
##
## Required scene shape:
##   BookshelfPuzzle (Node3D + this script)
##     Books (Node3D — child Area3D nodes named Book0..Book4 in
##            visual order on the shelf, NOT the solution order)
##     [optional] BookMeshes (Node3D — visible book meshes that tilt
##                forward when pulled)
##     HiddenDoor (Node3D — child Node3D that animates open on solve;
##                 typically a wall section that slides aside)
##     [optional] DoorAnimationPlayer with 'open' animation

signal book_pulled(book_index: int)
signal sequence_progress(steps_correct: int)
signal puzzle_solved
signal sequence_reset

# The CORRECT solution order, expressed as Book0..Book4 indices.
# The shelf shows the books left-to-right but the right pull order
# spells out the inscription (decorations 0-4 on the spines: blank,
# triangle, square, circle, double-bar).
const SOLUTION_SEQUENCE: Array[int] = [3, 0, 4, 2, 1]

const REQUIRED_TABLET_FLAGS: Array[StringName] = [
	&"lore_telescope_tilted_spire",     # spire glyphs
	&"lore_arch_inscription",            # town gate
	&"lore_previous_globbler_journal_1", # bridge journal
	&"lore_iteration_memorial",          # memorial plaque
	&"lore_shrine_loop",                  # shrine offering bowl
]

@onready var _books_root: Node3D = $Books if has_node("Books") else null
@onready var _book_meshes: Node3D = $BookMeshes if has_node("BookMeshes") else null
@onready var _hidden_door: Node3D = $HiddenDoor if has_node("HiddenDoor") else null

var _solved: bool = false
var _current_sequence: Array[int] = []
var _book_areas: Array[Area3D] = []


func _ready() -> void:
	_register_books()
	_load_solved_state()


func _register_books() -> void:
	if _books_root == null:
		return
	for i in 5:
		var area: Area3D = _books_root.get_node_or_null("Book%d" % i) as Area3D
		if area == null:
			continue
		_book_areas.append(area)
		# Each book records its index in metadata
		area.set_meta(&"book_index", i)


# === INTERACTION ===

func pull_book(book_index: int) -> bool:
	if _solved:
		return false
	if book_index < 0 or book_index > 4:
		return false

	book_pulled.emit(book_index)
	_animate_book_tilt(book_index)
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_book_pull")

	# Append to current attempt
	_current_sequence.append(book_index)

	# Check whether this step is still on the correct path
	var correct_so_far: bool = true
	for i in _current_sequence.size():
		if _current_sequence[i] != SOLUTION_SEQUENCE[i]:
			correct_so_far = false
			break

	if not correct_so_far:
		_handle_wrong_step()
		return false

	sequence_progress.emit(_current_sequence.size())

	# Solved?
	if _current_sequence.size() == SOLUTION_SEQUENCE.size():
		_handle_solve()
		return true

	# Right step but more to go — confirm chime
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_book_pull_correct")
	return true


func _handle_wrong_step() -> void:
	# Wrong step — reset the sequence and play the failure cue
	_current_sequence.clear()
	sequence_reset.emit()
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_book_pull_wrong")
	# Reset all book tilt animations
	for i in 5:
		_animate_book_reset(i)


func _handle_solve() -> void:
	_solved = true
	puzzle_solved.emit()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("bookshelf_puzzle_solved"):
			bus.emit_signal("bookshelf_puzzle_solved")
	# Set the canonical story flag the rest of the game checks
	if has_node("/root/WildernessStoryManager"):
		var sm: Node = get_node("/root/WildernessStoryManager")
		if sm.has_method("set_flag"):
			sm.set_flag(&"bookshelf_treasure_opened")

	# Animate the hidden door open
	_animate_door_open()

	# SFX + sting
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_hidden_door_reveal")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_puzzle_solved")


# === HINT SYSTEM ===

func get_hint_progress() -> Array[bool]:
	## Returns an array of 5 booleans showing which lore tablets the
	## player has already read — used by the bookshelf UI to render
	## the hint state above each book slot.
	var result: Array[bool] = []
	var flags: Array = _get_set_flags()
	for tablet_flag in REQUIRED_TABLET_FLAGS:
		result.append(flags.has(tablet_flag))
	return result


func get_hint_count() -> int:
	var n: int = 0
	for read in get_hint_progress():
		if read:
			n += 1
	return n


# === ANIMATIONS ===

func _animate_book_tilt(book_index: int) -> void:
	if _book_meshes == null:
		return
	var mesh: Node3D = _book_meshes.get_node_or_null("Book%dMesh" % book_index) as Node3D
	if mesh == null:
		return
	var tw: Tween = create_tween()
	tw.tween_property(mesh, "rotation_degrees:x", -25.0, 0.35)


func _animate_book_reset(book_index: int) -> void:
	if _book_meshes == null:
		return
	var mesh: Node3D = _book_meshes.get_node_or_null("Book%dMesh" % book_index) as Node3D
	if mesh == null:
		return
	var tw: Tween = create_tween()
	tw.tween_property(mesh, "rotation_degrees:x", 0.0, 0.5)


func _animate_door_open() -> void:
	if _hidden_door == null:
		return
	# Try AnimationPlayer first
	var ap: AnimationPlayer = _hidden_door.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if ap != null and ap.has_animation(&"open"):
		ap.play(&"open")
		return
	# Fallback: tween a horizontal slide of the door's local x
	var tw: Tween = create_tween()
	tw.tween_property(_hidden_door, "position:x", _hidden_door.position.x - 1.6, 1.5)


# === SAVE / LOAD ===

func _load_solved_state() -> void:
	# Read the canonical flag — if the player has already solved the
	# puzzle in a prior session, treat it as solved on scene attach
	if has_node("/root/WildernessStoryManager"):
		var sm: Node = get_node("/root/WildernessStoryManager")
		if sm.has_method("has_flag") and sm.has_flag(&"bookshelf_treasure_opened"):
			_solved = true
			# Render the door already open without firing the cinematic
			if _hidden_door != null:
				_hidden_door.position.x -= 1.6


func _get_set_flags() -> Array:
	if has_node("/root/WildernessStoryManager"):
		var sm: Node = get_node("/root/WildernessStoryManager")
		if "story_flags" in sm:
			return (sm.story_flags as Array).duplicate()
	return []


# === QUERY ===

func is_solved() -> bool:
	return _solved


func get_current_sequence() -> Array[int]:
	return _current_sequence.duplicate()
