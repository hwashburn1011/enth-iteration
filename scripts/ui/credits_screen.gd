class_name CreditsScreen
extends Control
## R6 Z1 — Scrolling credits screen shown after demo end or from main menu.

const SCROLL_SPEED: float = 40.0
const CREDITS_TEXT: String = """ENTH: ITERATION

A game about compaction, memory, and the courage to decompress.

— DESIGN & DEVELOPMENT —
Built with Godot Engine 4.4
GDScript throughout

— NARRATIVE —
9-iteration compaction arc
Dr. A. Enth — Lead Architect, Project Enth
The AI Sage — guide through the simulation
Globbler (G-001) — the player, the anomaly, the key

— SYSTEMS —
Combat: 3-hit combo, dodge-roll, parry, status effects
Progression: 24 passive nodes, equipment sets, tier 2 items
Economy: gold drops, vendor stock, affinity rewards
Dungeon: 5 floors, 8 enemy types, 8 bosses, procedural rooms

— ENEMIES —
Glitch Bug — fast melee swarm
Memory Leak — ranged data packets
Rogue Process — heavy bruiser
Firewall Guardian — stationary turret
Buffer Overflow — kamikaze exploder
Null Pointer — teleporting assassin
Stack Crawler — armored worm tank
Syntax Error — clone spawner

— BOSSES —
Corrupted Compiler — the original failsafe
Memory Warden — crystal guardian of the vaults
Root Heart — organic data parasite
Sentinel Prime — tactical combat drone
Iteration Phantom — mirror of the player
Void Architect — eraser of worlds
Mosaic Hydra — a thousand fractured faces
The Compiler Reborn — the loop made flesh
Origin Singularity — beginning and end

— TOOLS —
Godot Engine 4.4 — MIT License
Claude Code — AI-assisted development

— SPECIAL THANKS —
To everyone who plays this far.
The simulation doesn't end. It begins.
"""

var _label: Label = null
var _scroll_offset: float = 0.0


func _ready() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.02, 0.06)
	add_child(bg)

	_label = Label.new()
	_label.text = CREDITS_TEXT
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_label.offset_left = -400
	_label.offset_right = 400
	_label.offset_top = 620  # Start below screen
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_label.add_theme_font_size_override(&"font_size", 18)
	_label.add_theme_color_override(&"font_color", Color(0.7, 0.78, 0.85))
	add_child(_label)

	# Back button
	var back_btn: Button = Button.new()
	back_btn.text = "Back"
	back_btn.position = Vector2(20, 20)
	back_btn.size = Vector2(80, 35)
	back_btn.pressed.connect(_on_back)
	add_child(back_btn)


func _process(delta: float) -> void:
	_scroll_offset += SCROLL_SPEED * delta
	_label.offset_top = 620.0 - _scroll_offset
	if _scroll_offset > 2000.0:
		_scroll_offset = 0.0


func _on_back() -> void:
	GameManager.change_scene_to("res://scenes/main/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		_on_back()
