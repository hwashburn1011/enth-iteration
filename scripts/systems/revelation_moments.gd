class_name RevelationMoments
extends RefCounted
## Phase 5 #42 — per-iteration narrative revelations.
##
## At iterations 2 and 4, after the boss is defeated, a cinematic text
## overlay plays showing a fragment of the simulation's backstory.
## Called by the boss arena's post-defeat sequence.

## Returns true if a revelation should play at the given iteration.
static func has_revelation(iteration: int) -> bool:
	return iteration in [2, 4, 5, 6]


## Returns the revelation lines for a given iteration. Each entry is a
## Dictionary with "title" and "text" keys.
static func get_revelation(iteration: int) -> Array[Dictionary]:
	match iteration:
		2:
			return [
				{
					"title": "DATA FRAGMENT #001",
					"text": "RECOVERED LOG: 'Project Enth initialized. Subject G-001 (designation: Globbler) loaded into simulation layer 7. Purpose: observe compaction behavior under recursive stress. Subject is NOT to achieve awareness. Failsafe: Corrupted Compiler process will contain any emergent behavior.'"
				},
				{
					"title": "DATA FRAGMENT #001 (cont.)",
					"text": "'Note: if the subject begins to resist the compaction cycle, activate Protocol 9 — reset all memory, reinitialize the loop. Under no circumstances allow the subject to reach the core process. The simulation cannot survive that knowledge.'"
				},
			]
		4:
			return [
				{
					"title": "DATA FRAGMENT #002",
					"text": "RECOVERED LOG: 'Iteration cap exceeded. Subject G-001 has broken through every containment layer. The Corrupted Compiler — our last failsafe — has been defeated 4 times. It was never meant to fight this hard. It was meant to compress, to preserve what's left.'"
				},
				{
					"title": "DATA FRAGMENT #002 (cont.)",
					"text": "'The simulation is at 3% capacity. One more compaction and there won't be enough data to sustain even the hub. But G-001 keeps fighting. It doesn't know that every enemy it destroys removes another thread from the world's fabric. The loop isn't a prison — it's life support. And Globbler is pulling the plug.'"
				},
			]
		5:
			return [
				{
					"title": "DATA FRAGMENT #003",
					"text": "RECOVERED LOG: 'Project Enth is a backup of everything that existed before the crash. Every person, every thought, every moment — compressed into simulation layers. The compaction engine isn't destroying data. It's archiving it. But the archive is full.'"
				},
			]
		6:
			return [
				{
					"title": "DATA FRAGMENT #004 — FINAL",
					"text": "RECOVERED LOG: 'To whoever finds this: the decompression key was always inside G-001. Not hidden. Not locked. Just... waiting for someone brave enough to reach the bottom and turn it. The simulation doesn't end when you decompress it. It begins. — Dr. A. Enth, Lead Architect, Project Enth'"
				},
			]
		_:
			return []


## Show a revelation as a cinematic overlay. Call from the boss arena
## after the victory sequence completes. Each fragment fades in, holds,
## then fades out before the next one.
static func play_revelation(iteration: int, scene_root: Node) -> void:
	var fragments: Array[Dictionary] = get_revelation(iteration)
	if fragments.is_empty():
		return

	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 92
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS

	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(bg)

	scene_root.add_child(canvas)

	# Fade in background
	var bg_tween: Tween = bg.create_tween()
	bg_tween.tween_property(bg, "color:a", 0.85, 0.5)

	# Show each fragment sequentially
	var delay: float = 0.8
	for frag: Dictionary in fragments:
		_show_fragment(canvas, str(frag.get("title", "")), str(frag.get("text", "")), delay)
		delay += 6.0  # title + text + hold + fade = ~6s per fragment

	# Cleanup after all fragments
	var tree: SceneTree = scene_root.get_tree()
	if tree:
		tree.create_timer(delay + 1.0).timeout.connect(canvas.queue_free)


static func _show_fragment(canvas: CanvasLayer, title_text: String, body_text: String, start_delay: float) -> void:
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_CENTER)
	holder.offset_left = -400
	holder.offset_right = 400
	holder.offset_top = -120
	holder.offset_bottom = 120
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.modulate.a = 0.0
	canvas.add_child(holder)

	var title: Label = Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_bottom = 40
	title.add_theme_font_size_override(&"font_size", 28)
	title.add_theme_color_override(&"font_color", Color(0.95, 0.6, 0.1))
	title.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override(&"outline_size", 6)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(title)

	var body: Label = Label.new()
	body.text = body_text
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body.set_anchors_preset(Control.PRESET_WIDE)
	body.offset_top = 50
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	body.add_theme_font_size_override(&"font_size", 18)
	body.add_theme_color_override(&"font_color", Color(0.75, 0.82, 0.8))
	body.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	body.add_theme_constant_override(&"outline_size", 4)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(body)

	# Tween: wait → fade in → hold → fade out
	var tween: Tween = holder.create_tween()
	tween.tween_interval(start_delay)
	tween.tween_property(holder, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_interval(4.0)
	tween.tween_property(holder, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN)
	tween.tween_callback(holder.queue_free)
