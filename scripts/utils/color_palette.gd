class_name ColorPalette
extends RefCounted
## Centralized color palette for consistent visual identity across all placeholders.

# Player
const PLAYER: Color = Color(0.2, 0.85, 0.85)  # Bright cyan/teal

# Enemies
const GLITCH_BUG: Color = Color(0.9, 0.15, 0.15)  # Red
const MEMORY_LEAK: Color = Color(0.2, 0.8, 0.3)   # Green
const ROGUE_PROCESS: Color = Color(0.2, 0.3, 0.9)  # Blue
const CORRUPTED_COMPILER: Color = Color(0.4, 0.1, 0.5)  # Dark purple

# Item rarity
const RARITY_COMMON: Color = Color(0.85, 0.85, 0.85)    # White
const RARITY_UNCOMMON: Color = Color(0.3, 0.9, 0.3)     # Green
const RARITY_RARE: Color = Color(0.3, 0.5, 1.0)         # Blue
const RARITY_LEGENDARY: Color = Color(1.0, 0.85, 0.1)   # Gold

# Environment
const DUNGEON_FLOOR: Color = Color(0.25, 0.25, 0.28)
const DUNGEON_WALL: Color = Color(0.35, 0.35, 0.38)
const TOWN_GROUND: Color = Color(0.55, 0.48, 0.38)  # Warm beige/brown
const TOWN_BUILDING: Color = Color(0.45, 0.4, 0.35)

# NPCs
const AI_SAGE: Color = Color(0.5, 0.8, 1.0)      # White/cyan
const CACHE_SPRITE: Color = Color(0.4, 0.8, 1.0)  # Light blue

# UI
const HEALTH_BAR: Color = Color(0.9, 0.2, 0.2)
const COMPUTE_BAR: Color = Color(0.2, 0.4, 0.9)
const XP_BAR: Color = Color(0.8, 0.7, 0.2)


static func rarity_color(rarity: int) -> Color:
	match rarity:
		0: return RARITY_COMMON
		1: return RARITY_UNCOMMON
		2: return RARITY_RARE
		3: return RARITY_LEGENDARY
		_: return RARITY_COMMON
