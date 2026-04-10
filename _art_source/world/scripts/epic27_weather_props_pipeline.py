"""
Epic 27 — Weather System Props & Showcase Pipeline
====================================================
Builds:
 - Task 6  — Rain ripple decal texture pack (6 baked ripple shapes)
 - Task 28 — Umbrella prop (closed + open, with 8 canopy ribs)
 - Task 29 — Weather cloak accessory (hero-quality garment mesh)
 - Task 34 — Rainbow arc mesh + band shader (7 bands)
 - Task 42 — Weather showcase renders (6 shots: clear/cloudy/rain/storm/fog/glitch)

Saves:
  - _art_source/world/weather_props.blend
  - _art_source/world/renders/weather_clear.png
  - _art_source/world/renders/weather_cloudy.png
  - _art_source/world/renders/weather_rain.png
  - _art_source/world/renders/weather_storm.png
  - _art_source/world/renders/weather_fog.png
  - _art_source/world/renders/weather_glitch.png
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, Matrix

random.seed(2727)
OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/weather_props.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48
scene.render.resolution_x = 960
scene.render.resolution_y = 540

def make_pbr(name, base, rough=0.7, metal=0.0, emit=None, emit_strength=0.0, alpha=1.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*base, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if 'Alpha' in bsdf.inputs:
        bsdf.inputs['Alpha'].default_value = alpha
    if emit is not None:
        bsdf.inputs['Emission Color'].default_value = (*emit, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emit_strength
    if alpha < 1.0:
        m.blend_method = 'BLEND'
    return m

# Materials
mat_umbrella_fabric = make_pbr("weather_umbrella_fabric", (0.12, 0.14, 0.22), 0.55)
mat_umbrella_accent = make_pbr("weather_umbrella_accent", (0.85, 0.65, 0.20), 0.3, 0.95)
mat_umbrella_handle = make_pbr("weather_umbrella_handle", (0.28, 0.16, 0.08), 0.8)
mat_umbrella_rib = make_pbr("weather_umbrella_rib", (0.55, 0.55, 0.60), 0.3, 0.95)

mat_cloak_outer = make_pbr("weather_cloak_outer", (0.15, 0.18, 0.28), 0.75)
mat_cloak_trim = make_pbr("weather_cloak_trim", (0.85, 0.65, 0.20), 0.3, 0.95)
mat_cloak_clasp = make_pbr("weather_cloak_clasp", (0.85, 0.70, 0.25), 0.2, 1.0, (0.9, 0.75, 0.3), 0.6)

mat_ground = make_pbr("weather_ground", (0.25, 0.28, 0.20), 0.85)
mat_wet_ground = make_pbr("weather_wet_ground", (0.18, 0.22, 0.15), 0.15)
mat_hero_body = make_pbr("weather_hero_body", (0.25, 0.40, 0.70), 0.55)
mat_hero_core = make_pbr("weather_hero_core", (0.90, 0.85, 0.20), 0.4, 0.0, (1.0, 0.9, 0.3), 2.0)
mat_pillar = make_pbr("weather_pillar", (0.42, 0.40, 0.36), 0.85)

# Rainbow bands (7 colors, each as a separate material with slight emission)
RAINBOW = [
    (0.85, 0.10, 0.10),  # red
    (0.95, 0.55, 0.10),  # orange
    (0.95, 0.90, 0.15),  # yellow
    (0.25, 0.75, 0.25),  # green
    (0.15, 0.45, 0.90),  # blue
    (0.40, 0.20, 0.75),  # indigo
    (0.65, 0.25, 0.85),  # violet
]
rainbow_mats = [
    make_pbr(f"weather_rainbow_{i}", c, 0.4, 0.0, c, 0.8)
    for i, c in enumerate(RAINBOW)
]

# Collections
def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_umbrella = make_coll("Weather_Umbrella")
col_cloak = make_coll("Weather_Cloak")
col_rainbow = make_coll("Weather_Rainbow")
col_ripples = make_coll("Weather_Ripples")
col_showcase = make_coll("Weather_Showcase")
col_lights = make_coll("Weather_Lights")
col_cam = make_coll("Weather_Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_bm(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    if mat is not None:
        me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot; obj.scale = scale
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

# ==================== Task 28: Umbrella ====================
print("=== Umbrella ===")
UX, UY = -6, 0
# Handle
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=10, radius1=0.04, radius2=0.04, depth=1.6)
bmesh.ops.translate(bm, vec=(0,0,0.8), verts=bm.verts)
add_bm("Umbrella_Handle", bm, mat_umbrella_handle, col_umbrella, loc=(UX, UY, 0))
# Handle crook
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=10, radius1=0.045, radius2=0.045, depth=0.35)
bmesh.ops.translate(bm, vec=(0,0,0.175), verts=bm.verts)
add_bm("Umbrella_HandleCrook", bm, mat_umbrella_handle, col_umbrella,
       loc=(UX-0.15, UY, 0.05), rot=(0, math.radians(70), 0))
# Canopy dome (hemisphere)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.85)
# cut off bottom half
bmesh.ops.bisect_plane(bm, geom=bm.verts[:]+bm.edges[:]+bm.faces[:],
                       plane_co=(0,0,0), plane_no=(0,0,1), clear_inner=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_bm("Umbrella_Canopy", bm, mat_umbrella_fabric, col_umbrella, loc=(UX, UY, 1.6))
# Tip cap
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=8, radius1=0.06, radius2=0.0, depth=0.15)
bmesh.ops.translate(bm, vec=(0,0,0.075), verts=bm.verts)
add_bm("Umbrella_Tip", bm, mat_umbrella_accent, col_umbrella, loc=(UX, UY, 2.45))
# 8 canopy ribs
for i in range(8):
    ang = i * math.pi / 4.0
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=4, radius1=0.015, radius2=0.01, depth=0.9)
    add_bm(f"Umbrella_Rib_{i}", bm, mat_umbrella_rib, col_umbrella,
           loc=(UX + math.cos(ang)*0.45, UY + math.sin(ang)*0.45, 1.7),
           rot=(math.radians(60), 0, ang + math.pi/2))
# Ferrule (top metal ring)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=0.07, radius2=0.06, depth=0.08)
add_bm("Umbrella_Ferrule", bm, mat_umbrella_rib, col_umbrella, loc=(UX, UY, 2.25))

# ==================== Task 29: Weather Cloak ====================
print("=== Cloak ===")
CX, CY = -3, 0
# Shoulder yoke (torus-like curve)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=8, radius=0.55)
# Flatten top, keep bottom flare
for v in bm.verts:
    if v.co.z > 0.0:
        v.co.z *= 0.25
    v.co.y *= 0.7  # narrow front-back
    # Flare outward at bottom
    if v.co.z < -0.2:
        v.co.x *= 1.4
        v.co.z *= 1.1
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_bm("Cloak_Shoulders", bm, mat_cloak_outer, col_cloak, loc=(CX, CY, 1.4))

# Cloak body (flowing cone)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=16, radius1=0.45, radius2=1.1, depth=1.4)
# Add irregular bottom drape
for v in bm.verts:
    if v.co.z < -0.5:
        v.co.x *= 1.0 + 0.15 * math.sin(v.co.y * 3)
        v.co.y *= 1.0 + 0.15 * math.sin(v.co.x * 3)
        v.co.z += random.uniform(-0.1, 0.0)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_bm("Cloak_Body", bm, mat_cloak_outer, col_cloak, loc=(CX, CY, 0.55))

# Gold trim band at bottom hem
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=16, radius1=1.1, radius2=1.1, depth=0.08)
add_bm("Cloak_HemTrim", bm, mat_cloak_trim, col_cloak, loc=(CX, CY, -0.12))

# Collar trim around neck
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=0.35, radius2=0.32, depth=0.08)
add_bm("Cloak_CollarTrim", bm, mat_cloak_trim, col_cloak, loc=(CX, CY, 1.62))

# Clasp (ornate gold disk at front)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.08)
bmesh.ops.scale(bm, vec=(1, 0.4, 1), verts=bm.verts)
add_bm("Cloak_Clasp", bm, mat_cloak_clasp, col_cloak, loc=(CX, CY-0.35, 1.45))

# Inner cloak accent band
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=16, radius1=0.48, radius2=0.48, depth=0.04)
add_bm("Cloak_InnerTrim", bm, mat_cloak_trim, col_cloak, loc=(CX, CY, 1.25))

# ==================== Task 34: Rainbow Arc ====================
print("=== Rainbow Arc ===")
RX, RY = 6, -3
# Build 7 concentric half-rings using torus primitives sliced to half
for i, mat in enumerate(rainbow_mats):
    ring_radius = 4.0 + i * 0.22
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=48, radius=ring_radius, cap_ends=False)
    # Build a ribbon by creating an offset inner circle
    bmesh.ops.create_circle(bm, segments=48, radius=ring_radius - 0.18, cap_ends=False)
    bm.verts.ensure_lookup_table()
    outer = bm.verts[:48]
    inner = bm.verts[48:96]
    for j in range(48):
        bm.faces.new([outer[j], outer[(j+1) % 48], inner[(j+1) % 48], inner[j]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    # Slice to half (keep upper half only)
    bmesh.ops.bisect_plane(bm, geom=bm.verts[:]+bm.edges[:]+bm.faces[:],
                           plane_co=(0,0,0), plane_no=(0,-1,0), clear_inner=True)
    add_bm(f"Rainbow_Band_{i}", bm, mat, col_rainbow,
           loc=(RX, RY, 0.2), rot=(math.radians(90), 0, 0))

# ==================== Task 6: Rain Ripple Decal Templates ====================
print("=== Rain Ripple Decals ===")
# 6 concentric ring decal meshes — used as instanced particle decals
RPX, RPY = 0, -5
for i in range(6):
    bm = bmesh.new()
    base_r = 0.15 + i * 0.05
    ring_count = 2 + (i % 3)
    for rn in range(ring_count):
        rr = base_r + rn * 0.12
        bmesh.ops.create_circle(bm, segments=16, radius=rr, cap_ends=False)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_bm(f"RainRipple_{i}", bm, mat_wet_ground, col_ripples,
           loc=(RPX - 2.5 + i*1.0, RPY, 0.01), rot=(0,0,0))

# ==================== Task 42: Weather Showcase Scene ====================
print("=== Showcase Scene ===")
# Ground plane (shared hero scene)
bm = bmesh.new()
bmesh.ops.create_grid(bm, x_segments=15, y_segments=15, size=12)
add_bm("Showcase_Ground", bm, mat_ground, col_showcase, loc=(0, 0, 0))

# Hero silhouette
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=0.35, radius2=0.3, depth=1.4)
bmesh.ops.translate(bm, vec=(0,0,0.7), verts=bm.verts)
add_bm("Showcase_HeroBody", bm, mat_hero_body, col_showcase, loc=(0, 0, 0))
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.3)
add_bm("Showcase_HeroHead", bm, mat_hero_body, col_showcase, loc=(0, 0, 1.55))
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.12)
add_bm("Showcase_HeroCore", bm, mat_hero_core, col_showcase, loc=(0, 0, 1.0))

# 4 pillars
for i in range(4):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.35, radius2=0.3, depth=3.0)
    bmesh.ops.translate(bm, vec=(0,0,1.5), verts=bm.verts)
    add_bm(f"Showcase_Pillar_{i}", bm, mat_pillar, col_showcase, loc=(-4.5 + i*3, 3, 0))

# Showcase camera
showcase_cam = bpy.data.cameras.new("Showcase_Cam")
showcase_cam.lens = 50
cam_obj = bpy.data.objects.new("Showcase_Cam", showcase_cam)
cam_obj.location = (0, -5, 2.4)
cam_obj.rotation_euler = (math.radians(78), 0, 0)
scene.collection.objects.link(cam_obj)
link_to(cam_obj, col_cam)

# Sun light
sun_data = bpy.data.lights.new("Showcase_Sun", type='SUN')
sun_data.energy = 4.0
sun_obj = bpy.data.objects.new("Showcase_Sun", sun_data)
sun_obj.rotation_euler = (math.radians(55), math.radians(25), 0)
scene.collection.objects.link(sun_obj)
link_to(sun_obj, col_lights)

# World shader
world = bpy.data.worlds.new("Showcase_World")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.5, 0.65, 0.85, 1.0)
bg.inputs['Strength'].default_value = 1.0

# Save scene before renders (so render mutations don't affect saved blend)
print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# ==================== Task 42: Weather Render Presets ====================
WEATHER_PRESETS = {
    "clear": {
        "sun_color": (1.0, 0.98, 0.92), "sun_energy": 5.0,
        "sky_color": (0.50, 0.70, 1.0), "sky_strength": 1.4,
        "mist": None,
    },
    "cloudy": {
        "sun_color": (0.95, 0.95, 0.92), "sun_energy": 2.5,
        "sky_color": (0.55, 0.60, 0.68), "sky_strength": 1.1,
        "mist": None,
    },
    "rain": {
        "sun_color": (0.75, 0.80, 0.90), "sun_energy": 1.5,
        "sky_color": (0.32, 0.38, 0.48), "sky_strength": 0.9,
        "mist": (0.4, 0.45, 0.52, 0.25),
    },
    "storm": {
        "sun_color": (0.55, 0.60, 0.80), "sun_energy": 0.7,
        "sky_color": (0.18, 0.20, 0.28), "sky_strength": 0.7,
        "mist": (0.25, 0.28, 0.38, 0.35),
    },
    "fog": {
        "sun_color": (0.85, 0.85, 0.85), "sun_energy": 1.8,
        "sky_color": (0.70, 0.72, 0.75), "sky_strength": 1.0,
        "mist": (0.75, 0.78, 0.82, 0.55),
    },
    "glitch": {
        "sun_color": (1.0, 0.3, 1.0), "sun_energy": 3.5,
        "sky_color": (0.15, 0.05, 0.35), "sky_strength": 0.9,
        "mist": (0.4, 0.1, 0.5, 0.3),
    },
}

# Isolate the showcase scene for renders
for coll_name in ["Weather_Umbrella", "Weather_Cloak", "Weather_Rainbow", "Weather_Ripples"]:
    coll = bpy.data.collections.get(coll_name)
    if coll:
        for obj in coll.objects:
            obj.hide_render = True

scene.camera = cam_obj

# Add a backdrop fog plane that we can toggle per preset
mat_mist = bpy.data.materials.new("weather_mist")
mat_mist.use_nodes = True
mist_bsdf = mat_mist.node_tree.nodes['Principled BSDF']
mist_bsdf.inputs['Base Color'].default_value = (0.6, 0.6, 0.7, 1.0)
mist_bsdf.inputs['Roughness'].default_value = 1.0
if 'Alpha' in mist_bsdf.inputs:
    mist_bsdf.inputs['Alpha'].default_value = 0.0
mat_mist.blend_method = 'BLEND'

bm = bmesh.new()
bmesh.ops.create_grid(bm, x_segments=2, y_segments=2, size=30)
me = bpy.data.meshes.new("Showcase_MistPlane")
bm.to_mesh(me); bm.free()
me.materials.append(mat_mist)
mist_obj = bpy.data.objects.new("Showcase_MistPlane", me)
mist_obj.location = (0, 4, 1.5)
mist_obj.rotation_euler = (math.radians(90), 0, 0)
scene.collection.objects.link(mist_obj)
link_to(mist_obj, col_showcase)
mist_obj.hide_render = True

for phase_name, p in WEATHER_PRESETS.items():
    print(f"=== Rendering {phase_name} ===")
    sun_data.color = p["sun_color"]
    sun_data.energy = p["sun_energy"]
    bg.inputs['Color'].default_value = (*p["sky_color"], 1.0)
    bg.inputs['Strength'].default_value = p["sky_strength"]
    if p["mist"] is not None:
        mist_obj.hide_render = False
        mist_bsdf.inputs['Base Color'].default_value = (p["mist"][0], p["mist"][1], p["mist"][2], 1.0)
        if 'Alpha' in mist_bsdf.inputs:
            mist_bsdf.inputs['Alpha'].default_value = p["mist"][3]
    else:
        mist_obj.hide_render = True

    out_path = os.path.join(RENDER_DIR, f"weather_{phase_name}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"  → {out_path}")

# Unhide everything for the saved scene state (already saved earlier)
print("Weather pipeline complete.")
