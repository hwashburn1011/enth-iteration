"""
Epic 26 — Time-of-Day Comparison Render Pipeline
=================================================
Builds a standardized hero-scene test bed (lit ground plane + reference
materials + character silhouette stand-in + sun light) and renders 4
comparison frames at DAWN / NOON / DUSK / NIGHT so the lighting bible can
be visually validated.

Saves:
  - _art_source/world/tod_comparison_scene.blend
  - _art_source/world/renders/tod_dawn.png
  - _art_source/world/renders/tod_noon.png
  - _art_source/world/renders/tod_dusk.png
  - _art_source/world/renders/tod_night.png

These are the reference frames the Pillar 1 lighting bible (Epic 19) will
be judged against for "does the character read clearly in every phase?".
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix, Euler

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/tod_comparison_scene.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.render.resolution_x = 960
scene.render.resolution_y = 540
scene.render.film_transparent = False

def make_pbr(name, base, rough=0.7, metal=0.0, emit=None, emit_strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*base, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if emit is not None:
        bsdf.inputs['Emission Color'].default_value = (*emit, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emit_strength
    return m

mat_ground = make_pbr("tod_ground", (0.22, 0.28, 0.18), 0.85)
mat_hero_body = make_pbr("tod_hero_body", (0.25, 0.40, 0.70), 0.55)
mat_hero_accent = make_pbr("tod_hero_accent", (0.90, 0.85, 0.20), 0.4, 0.0, (1.0, 0.9, 0.3), 2.0)
mat_ref_white = make_pbr("tod_ref_white", (0.85, 0.85, 0.85), 0.5)
mat_ref_chrome = make_pbr("tod_ref_chrome", (0.80, 0.80, 0.80), 0.1, 1.0)
mat_ref_dark = make_pbr("tod_ref_dark", (0.06, 0.06, 0.06), 0.6)
mat_ref_red = make_pbr("tod_ref_red", (0.75, 0.10, 0.10), 0.55)
mat_pillar = make_pbr("tod_pillar", (0.42, 0.40, 0.36), 0.85)

def add_mesh_obj(name, bm, mat, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot; obj.scale = scale
    bpy.context.scene.collection.objects.link(obj)
    return obj

# Ground plane
bm = bmesh.new()
bmesh.ops.create_grid(bm, x_segments=20, y_segments=20, size=20)
add_mesh_obj("TOD_Ground", bm, mat_ground, loc=(0,0,0))

# Hero silhouette (cylinder body + sphere head + glowing accent core)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=0.35, radius2=0.3, depth=1.4)
bmesh.ops.translate(bm, vec=(0,0,0.7), verts=bm.verts)
add_mesh_obj("TOD_HeroBody", bm, mat_hero_body, loc=(0,0,0))

bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.3)
add_mesh_obj("TOD_HeroHead", bm, mat_hero_body, loc=(0,0,1.55))

bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.12)
add_mesh_obj("TOD_HeroCore", bm, mat_hero_accent, loc=(0,0,1.0))

# 4 reference spheres for material validation
for i, mat in enumerate([mat_ref_white, mat_ref_chrome, mat_ref_dark, mat_ref_red]):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.4)
    add_mesh_obj(f"TOD_RefSphere_{i}", bm, mat, loc=(-3 + i*2, -3, 0.4))

# Backdrop pillars (for rim-light testing)
for i in range(4):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.35, radius2=0.3, depth=3.0)
    bmesh.ops.translate(bm, vec=(0,0,1.5), verts=bm.verts)
    add_mesh_obj(f"TOD_Pillar_{i}", bm, mat_pillar, loc=(-6 + i*4, 4, 0))

# Camera
cam_data = bpy.data.cameras.new("TOD_Cam")
cam_data.lens = 50
cam_obj = bpy.data.objects.new("TOD_Cam", cam_data)
cam_obj.location = (0, -6, 2.5)
cam_obj.rotation_euler = (math.radians(78), 0, 0)
bpy.context.scene.collection.objects.link(cam_obj)
scene.camera = cam_obj

# Sun light (we'll reposition + recolor per phase)
sun_data = bpy.data.lights.new("TOD_Sun", type='SUN')
sun_data.energy = 3.0
sun_obj = bpy.data.objects.new("TOD_Sun", sun_data)
sun_obj.rotation_euler = (math.radians(50), math.radians(30), 0)
bpy.context.scene.collection.objects.link(sun_obj)

# World shader for sky
world = bpy.data.worlds.new("TOD_World")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.5, 0.6, 0.8, 1.0)
bg.inputs['Strength'].default_value = 1.0

# Phase presets: (sun_pos_euler_deg, sun_color, sun_energy, sky_color, sky_strength)
PHASES = {
    "dawn": {
        "sun_rot": (15, 45, 0),
        "sun_color": (1.0, 0.72, 0.48),
        "sun_energy": 2.5,
        "sky_color": (0.85, 0.55, 0.40),
        "sky_strength": 0.9,
    },
    "noon": {
        "sun_rot": (60, 20, 0),
        "sun_color": (1.0, 0.98, 0.92),
        "sun_energy": 5.0,
        "sky_color": (0.50, 0.70, 1.0),
        "sky_strength": 1.3,
    },
    "dusk": {
        "sun_rot": (-5, -35, 0),
        "sun_color": (1.0, 0.45, 0.28),
        "sun_energy": 2.0,
        "sky_color": (0.95, 0.35, 0.28),
        "sky_strength": 0.7,
    },
    "night": {
        "sun_rot": (55, -120, 0),  # "moon" at top
        "sun_color": (0.55, 0.68, 1.0),
        "sun_energy": 0.8,
        "sky_color": (0.05, 0.07, 0.18),
        "sky_strength": 0.15,
    },
}

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# Render all 4 phases
for phase_name, p in PHASES.items():
    print(f"=== Rendering {phase_name} ===")
    sun_obj.rotation_euler = (
        math.radians(p["sun_rot"][0]),
        math.radians(p["sun_rot"][1]),
        math.radians(p["sun_rot"][2]),
    )
    sun_data.color = p["sun_color"]
    sun_data.energy = p["sun_energy"]
    bg.inputs['Color'].default_value = (*p["sky_color"], 1.0)
    bg.inputs['Strength'].default_value = p["sky_strength"]

    out_path = os.path.join(RENDER_DIR, f"tod_{phase_name}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"  → {out_path}")

print("Time-of-Day comparison pipeline complete.")
