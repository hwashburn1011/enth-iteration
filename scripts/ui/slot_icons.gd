class_name SlotIcons
extends RefCounted

## Default placeholder icons for empty equipment slots. Each slot has a tinted
## glyph that hints at what goes there. Real per-set icons (rendered from the
## actual outfits) override these once those textures are available.
##
## All icons are generated procedurally as ImageTextures so the system works
## without external assets — replace with painted textures when ready.

static var _cache: Dictionary = {}  ## slot_name -> ImageTexture

const ICON_SIZE: int = 64

const SLOT_HINTS: Dictionary = {
	&"slot_head":       {"glyph": "H", "tint": Color(0.95, 0.85, 0.60)},
	&"slot_chest":      {"glyph": "C", "tint": Color(0.60, 0.85, 0.95)},
	&"slot_back":       {"glyph": "B", "tint": Color(0.85, 0.60, 0.95)},
	&"slot_hand_R":     {"glyph": "R", "tint": Color(0.95, 0.65, 0.60)},
	&"slot_hand_L":     {"glyph": "L", "tint": Color(0.95, 0.65, 0.60)},
	&"slot_hip_R":      {"glyph": "h", "tint": Color(0.85, 0.85, 0.60)},
	&"slot_hip_L":      {"glyph": "h", "tint": Color(0.85, 0.85, 0.60)},
	&"slot_foot_R":     {"glyph": "F", "tint": Color(0.60, 0.95, 0.75)},
	&"slot_foot_L":     {"glyph": "F", "tint": Color(0.60, 0.95, 0.75)},
	&"slot_shoulder_R": {"glyph": "s", "tint": Color(0.75, 0.75, 0.95)},
	&"slot_shoulder_L": {"glyph": "s", "tint": Color(0.75, 0.75, 0.95)},
}


static func get_default_icon(slot_name: StringName) -> ImageTexture:
	if _cache.has(slot_name):
		return _cache[slot_name]

	var info: Dictionary = SLOT_HINTS.get(slot_name, {"glyph": "?", "tint": Color.WHITE})
	var img: Image = Image.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
	var tint: Color = info["tint"]
	var bg: Color = tint.darkened(0.65)
	bg.a = 0.85
	var border: Color = tint
	border.a = 1.0

	# Fill background
	img.fill(bg)

	# Border (1px)
	for x in ICON_SIZE:
		img.set_pixel(x, 0, border)
		img.set_pixel(x, ICON_SIZE - 1, border)
	for y in ICON_SIZE:
		img.set_pixel(0, y, border)
		img.set_pixel(ICON_SIZE - 1, y, border)

	# Inner accent corner squares for visual interest
	var inset: int = 4
	for d in 6:
		img.set_pixel(inset + d, inset, tint)
		img.set_pixel(ICON_SIZE - 1 - inset - d, inset, tint)
		img.set_pixel(inset + d, ICON_SIZE - 1 - inset, tint)
		img.set_pixel(ICON_SIZE - 1 - inset - d, ICON_SIZE - 1 - inset, tint)

	var tex: ImageTexture = ImageTexture.create_from_image(img)
	_cache[slot_name] = tex
	return tex


static func get_humanized_slot_name(slot_name: StringName) -> String:
	const NAMES: Dictionary = {
		&"slot_head":       "Head",
		&"slot_chest":      "Chest",
		&"slot_back":       "Back",
		&"slot_hand_R":     "Right Hand",
		&"slot_hand_L":     "Left Hand",
		&"slot_hip_R":      "Right Hip",
		&"slot_hip_L":      "Left Hip",
		&"slot_foot_R":     "Right Foot",
		&"slot_foot_L":     "Left Foot",
		&"slot_shoulder_R": "Right Shoulder",
		&"slot_shoulder_L": "Left Shoulder",
	}
	return NAMES.get(slot_name, String(slot_name))
