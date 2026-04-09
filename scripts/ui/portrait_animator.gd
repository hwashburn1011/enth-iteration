class_name PortraitAnimator
extends Sprite2D

## Drives the dialogue portrait atlas — plays a breathing loop with
## occasional blinks. The atlas is laid out 4 columns × 2 rows:
##   Frames 0-6: breathing cycle (sin scale on the chest core)
##   Frame 7:    blink (visor compressed)
##
## The breathing cycle plays continuously at ~30 frames per cycle
## (slow, calming). The blink is triggered randomly every 3-5 seconds
## by jumping to frame 7 for 2 frames then returning.
##
## Required scene shape:
##   PortraitAnimator (Sprite2D + this script)
##     texture = res://assets/textures/portraits/globbler_portrait_atlas.png
##     hframes = 4
##     vframes = 2

signal blinked
signal breath_cycle_completed

const BREATHING_FRAMES: Array[int] = [0, 1, 2, 3, 4, 5, 6]
const BLINK_FRAME: int = 7
const BREATH_FRAME_DURATION: float = 0.35  # ~2.5s per breath
const BLINK_HOLD_S: float = 0.10
const BLINK_INTERVAL_MIN: float = 3.0
const BLINK_INTERVAL_MAX: float = 6.0

var _breath_index: int = 0
var _breath_timer: float = 0.0
var _next_blink_at: float = 0.0
var _blinking: bool = false
var _blink_end_time: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	hframes = 4
	vframes = 2
	frame = BREATHING_FRAMES[0]
	_rng.randomize()
	_schedule_next_blink()


func _process(delta: float) -> void:
	var now: float = Time.get_ticks_msec() / 1000.0

	# Handle blink hold
	if _blinking:
		if now >= _blink_end_time:
			_blinking = false
			frame = BREATHING_FRAMES[_breath_index]
		return

	# Advance breathing
	_breath_timer += delta
	if _breath_timer >= BREATH_FRAME_DURATION:
		_breath_timer = 0.0
		_breath_index = (_breath_index + 1) % BREATHING_FRAMES.size()
		frame = BREATHING_FRAMES[_breath_index]
		if _breath_index == 0:
			breath_cycle_completed.emit()

	# Trigger blink?
	if now >= _next_blink_at:
		_start_blink()


func _start_blink() -> void:
	_blinking = true
	frame = BLINK_FRAME
	_blink_end_time = (Time.get_ticks_msec() / 1000.0) + BLINK_HOLD_S
	_schedule_next_blink()
	blinked.emit()


func _schedule_next_blink() -> void:
	var interval: float = _rng.randf_range(BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX)
	_next_blink_at = (Time.get_ticks_msec() / 1000.0) + interval


# === API ===

func swap_outfit(outfit_slug: StringName) -> void:
	## Swaps the portrait texture to the matching outfit variant.
	## Defaults to the base portrait if the outfit-specific atlas
	## doesn't exist (most outfits will use the same atlas with
	## just a different texture, OR future work can produce per-
	## outfit animated atlases).
	var path: String = "res://assets/textures/portraits/globbler_%s.png" % outfit_slug
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
		# Per-outfit static portraits don't have animation frames
		hframes = 1
		vframes = 1
		frame = 0
	else:
		# Fall back to default animated atlas
		texture = load("res://assets/textures/portraits/globbler_portrait_atlas.png") as Texture2D
		hframes = 4
		vframes = 2
		frame = BREATHING_FRAMES[0]


func force_blink() -> void:
	if not _blinking:
		_start_blink()
