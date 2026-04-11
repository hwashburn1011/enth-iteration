class_name EnvironmentPreset
extends Resource

## Single environment preset — defines lighting, fog, post-process, and
## color grading for a zone. Applied via EnvironmentManager.

@export var preset_id: StringName = &""
@export var display_name: String = ""

## === LIGHTING ===
@export var sun_enabled: bool = true
@export var sun_color: Color = Color(1.0, 0.95, 0.85)
@export var sun_energy: float = 1.5
@export var sun_angle_degrees: Vector2 = Vector2(50, 90)  ## elevation, azimuth

@export var ambient_color: Color = Color(0.4, 0.45, 0.55)
@export var ambient_energy: float = 0.5

## === SKY ===
@export var sky_horizon_color: Color = Color(0.4, 0.5, 0.7)
@export var sky_top_color: Color = Color(0.2, 0.3, 0.6)
@export var sky_ground_color: Color = Color(0.1, 0.1, 0.15)
@export var sky_energy: float = 1.0

## === FOG ===
@export var fog_enabled: bool = false
@export var fog_color: Color = Color(0.5, 0.6, 0.7)
@export var fog_density: float = 0.01
@export var fog_height_falloff: float = 0.1

## === VOLUMETRIC FOG ===
@export var vfog_enabled: bool = false
@export var vfog_density: float = 0.03
@export var vfog_albedo: Color = Color(0.8, 0.85, 0.95)
@export var vfog_emission: Color = Color.BLACK

## === POST-PROCESS ===
@export var bloom_enabled: bool = true
@export var bloom_threshold: float = 0.5
@export var bloom_intensity: float = 0.4
@export var bloom_strength: float = 1.0

@export var ssao_enabled: bool = true
@export var ssao_strength: float = 0.4
@export var ssao_radius: float = 0.5

@export var ssr_enabled: bool = false
@export var ssr_samples: int = 32

@export var sdfgi_enabled: bool = true
@export var sdfgi_cascades: int = 1

## === TONEMAP + GRADING ===
@export var tonemapper_mode: int = 2  ## 0 linear, 1 reinhard, 2 filmic, 3 aces
@export var exposure: float = 1.0
@export var color_grading_lut: Texture2D
@export var color_grading_strength: float = 0.7

## === GODRAYS ===
@export var godrays_enabled: bool = false
@export var godrays_intensity: float = 0.3
