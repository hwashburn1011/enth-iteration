"""
Epic 33 — Module Icons & Showcase Pipeline
============================================
Renders 40 module icons (8 Compiler + 8 Daemon + 8 Kernel + 8 universal +
8 ultimate) plus a 6-frame trailer-style showcase sequence.

Each icon is a 256x256 transparent PNG with a class-themed frame and
unique inner symbol.

Saves:
  - _art_source/ui/module_icons.blend
  - _art_source/ui/renders/module_<class>_<idx>.png   (8 each × 5 = 40)
  - _art_source/ui/renders/module_showcase_<frame>.png  (6 frames)
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, Matrix

random.seed(3333)
OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/module_icons.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.render.film_transparent = True

def make_pbr(name, base, rough=0.5, metal=0.0, emit=None, emit_strength=0.0):
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

# Class palettes
CLASS_PALETTES = {
    "compiler": {"frame": (0.18, 0.42, 0.65), "accent": (1.0, 0.85, 0.35), "glow": 3.0},
    "daemon":   {"frame": (0.62, 0.10, 0.20), "accent": (1.0, 0.30, 0.45), "glow": 3.5},
    "kernel":   {"frame": (0.15, 0.30, 0.30), "accent": (0.30, 0.85, 0.85), "glow": 2.8},
    "universal":{"frame": (0.35, 0.35, 0.40), "accent": (0.85, 0.85, 0.92), "glow": 2.4},
    "ultimate": {"frame": (0.30, 0.10, 0.40), "accent": (0.95, 0.55, 1.00), "glow": 4.5},
}

class_mats = {}
for cid, p in CLASS_PALETTES.items():
    class_mats[cid] = {
        "frame": make_pbr(f"mod_{cid}_frame", p["frame"], 0.4, 0.4),
        "accent": make_pbr(f"mod_{cid}_accent", p["accent"], 0.3, 0.0, p["accent"], p["glow"]),
        "metal": make_pbr(f"mod_{cid}_metal", (0.55, 0.55, 0.60), 0.3, 0.95),
        "dark": make_pbr(f"mod_{cid}_dark", (0.05, 0.05, 0.08), 0.7),
    }

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_icons = make_coll("Module_Icons")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")
col_showcase = make_coll("Showcase")

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

# === Symbol shape builders ===
def sym_strike(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.05, 0.05, 0.45), verts=bm.verts)
    bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(35), 3, 'Y'), verts=bm.verts)
    parts.append((bm, mats["accent"]))
    return parts

def sym_burst(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.15)
    parts.append((bm, mats["accent"]))
    for i in range(6):
        ang = (i / 6) * math.tau
        ray = bmesh.new()
        bmesh.ops.create_cube(ray, size=1.0)
        bmesh.ops.scale(ray, vec=(0.04, 0.04, 0.2), verts=ray.verts)
        bmesh.ops.rotate(ray, matrix=Matrix.Rotation(ang, 3, 'X'), verts=ray.verts)
        parts.append((ray, mats["accent"]))
    return parts

def sym_arc(mats):
    parts = []
    for i in range(5):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(0.04, 0.04, 0.08), verts=bm.verts)
        bmesh.ops.translate(bm, vec=(-0.2 + i*0.1, 0, 0.06 * abs(i - 2)), verts=bm.verts)
        parts.append((bm, mats["accent"]))
    return parts

def sym_shield(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.32, 0.06, 0.42), verts=bm.verts)
    parts.append((bm, mats["frame"]))
    bm2 = bmesh.new()
    bmesh.ops.create_icosphere(bm2, subdivisions=2, radius=0.10)
    parts.append((bm2, mats["accent"]))
    return parts

def sym_explosion(mats):
    parts = []
    for i in range(3):
        bm = bmesh.new()
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.12 - i*0.03)
        bmesh.ops.translate(bm, vec=(0, 0, i*0.02), verts=bm.verts)
        parts.append((bm, mats["accent"]))
    return parts

def sym_waves(mats):
    parts = []
    for i in range(3):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.12 + i*0.10, radius2=0.12 + i*0.10, depth=0.03)
        parts.append((bm, mats["accent"]))
    return parts

def sym_circle(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.32, radius2=0.32, depth=0.04)
    parts.append((bm, mats["frame"]))
    bm2 = bmesh.new()
    bmesh.ops.create_cone(bm2, segments=24, radius1=0.20, radius2=0.20, depth=0.03)
    parts.append((bm2, mats["accent"]))
    return parts

def sym_arrow(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.05, 0.05, 0.45), verts=bm.verts)
    parts.append((bm, mats["accent"]))
    head = bmesh.new()
    bmesh.ops.create_cone(head, segments=4, radius1=0.15, radius2=0.0, depth=0.18)
    bmesh.ops.translate(head, vec=(0, 0, 0.32), verts=head.verts)
    parts.append((head, mats["accent"]))
    return parts

SYMBOL_BUILDERS = [
    sym_strike, sym_burst, sym_arc, sym_shield,
    sym_explosion, sym_waves, sym_circle, sym_arrow,
]

def build_icon(class_id, idx, position):
    mats = class_mats[class_id]
    objs = []
    # Frame
    frame = bmesh.new()
    bmesh.ops.create_cone(frame, segments=24, radius1=0.5, radius2=0.5, depth=0.05)
    objs.append(add_bm(f"mod_{class_id}_{idx}_frame", frame, mats["frame"], col_icons,
                       loc=position))
    # Inner ring
    ring = bmesh.new()
    bmesh.ops.create_cone(ring, segments=24, radius1=0.46, radius2=0.46, depth=0.06)
    objs.append(add_bm(f"mod_{class_id}_{idx}_ring", ring, mats["accent"], col_icons,
                       loc=(position[0], position[1], position[2] + 0.005)))
    # Inner backing
    inner = bmesh.new()
    bmesh.ops.create_cone(inner, segments=24, radius1=0.42, radius2=0.42, depth=0.05)
    objs.append(add_bm(f"mod_{class_id}_{idx}_inner", inner, mats["dark"], col_icons,
                       loc=(position[0], position[1], position[2] + 0.01)))
    # Symbol
    parts = SYMBOL_BUILDERS[idx % len(SYMBOL_BUILDERS)](mats)
    for pi, (bm, mat) in enumerate(parts):
        objs.append(add_bm(f"mod_{class_id}_{idx}_p{pi}", bm, mat, col_icons,
                           loc=(position[0], position[1], position[2] + 0.05),
                           rot=(math.radians(90), 0, 0)))
    return objs

# Build all 40 icons
print("=== Building 40 module icons ===")
all_icons = {}
for ci, class_id in enumerate(["compiler", "daemon", "kernel", "universal", "ultimate"]):
    for idx in range(8):
        x_pos = ci * 6 + (idx % 4) * 1.4 - 9
        y_pos = (idx // 4) * 1.4 - 1
        objs = build_icon(class_id, idx, (x_pos, y_pos, 0))
        all_icons[(class_id, idx)] = objs

# === Showcase scene: 5 hero icons floating with rotation ===
print("=== Showcase scene ===")
showcase_icons = []
for ci, class_id in enumerate(["compiler", "daemon", "kernel", "universal", "ultimate"]):
    sx = (ci - 2) * 2.0
    objs = build_icon(class_id, 0, (sx + 50, 0, 0.8))  # offset far from grid
    for o in objs:
        for c in o.users_collection: c.objects.unlink(o)
        col_showcase.objects.link(o)
        showcase_icons.append(o)

# === Cameras ===
print("=== Cameras ===")
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 80
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

showcase_cam_data = bpy.data.cameras.new("Showcase_Cam")
showcase_cam_data.lens = 50
showcase_cam = bpy.data.objects.new("Showcase_Cam", showcase_cam_data)
showcase_cam.location = (50, -7, 3.5)
showcase_cam.rotation_euler = (math.radians(70), 0, 0)
scene.collection.objects.link(showcase_cam)
link_to(showcase_cam, col_cam)

# === Lights ===
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 250
key_data.size = 3
key_data.color = (1.0, 0.95, 0.92)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.rotation_euler = (math.radians(45), math.radians(-25), 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 90
fill_data.size = 4
fill_data.color = (0.6, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.rotation_euler = (math.radians(60), math.radians(40), 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

# Showcase key + rim
sc_key = bpy.data.lights.new("ShowcaseKey", type='AREA')
sc_key.energy = 800
sc_key.size = 6
sc_key_obj = bpy.data.objects.new("ShowcaseKey", sc_key)
sc_key_obj.location = (50, -8, 8)
sc_key_obj.rotation_euler = (math.radians(50), 0, 0)
scene.collection.objects.link(sc_key_obj)
link_to(sc_key_obj, col_lights)

sc_rim = bpy.data.lights.new("ShowcaseRim", type='AREA')
sc_rim.energy = 600
sc_rim.size = 8
sc_rim.color = (0.85, 0.55, 1.0)
sc_rim_obj = bpy.data.objects.new("ShowcaseRim", sc_rim)
sc_rim_obj.location = (50, 4, 4)
sc_rim_obj.rotation_euler = (math.radians(110), 0, 0)
scene.collection.objects.link(sc_rim_obj)
link_to(sc_rim_obj, col_lights)

# World
world = bpy.data.worlds.new("World_Mod")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.08, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# === Render 40 icons ===
print("=== Rendering 40 icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

# Hide showcase
for obj in showcase_icons:
    obj.hide_render = True
# Hide showcase lights
sc_key_obj.hide_render = True
sc_rim_obj.hide_render = True

for key in all_icons.keys():
    class_id, idx = key
    objs = all_icons[key]
    # Hide all icons
    for k2, objs2 in all_icons.items():
        for o in objs2:
            o.hide_render = (k2 == key)
    # Position cam above
    cx, cy, cz = objs[0].location
    icon_cam.location = (cx, cy - 0.3, cz + 1.6)
    out_path = os.path.join(RENDER_DIR, f"module_{class_id}_{idx}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render 6 showcase frames ===
print("=== Rendering showcase frames ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False
scene.camera = showcase_cam

# Hide all grid icons
for k2, objs2 in all_icons.items():
    for o in objs2:
        o.hide_render = True
# Show only showcase
for obj in showcase_icons:
    obj.hide_render = False
sc_key_obj.hide_render = False
sc_rim_obj.hide_render = False

# Animate camera around the showcase row + rotate icons in place
import_count = 0
SHOWCASE_FRAMES = [
    {"cam_loc": (50, -7, 3.5), "cam_rot": (math.radians(75), 0, 0), "icon_rot_z": 0.0},
    {"cam_loc": (52, -6, 4.0), "cam_rot": (math.radians(72), 0, math.radians(15)), "icon_rot_z": math.radians(15)},
    {"cam_loc": (54, -5, 4.5), "cam_rot": (math.radians(70), 0, math.radians(30)), "icon_rot_z": math.radians(30)},
    {"cam_loc": (50, -4, 5.0), "cam_rot": (math.radians(65), 0, 0), "icon_rot_z": math.radians(45)},
    {"cam_loc": (48, -5, 4.5), "cam_rot": (math.radians(70), 0, math.radians(-30)), "icon_rot_z": math.radians(60)},
    {"cam_loc": (46, -6, 4.0), "cam_rot": (math.radians(72), 0, math.radians(-15)), "icon_rot_z": math.radians(75)},
]
for fi, frame in enumerate(SHOWCASE_FRAMES):
    showcase_cam.location = frame["cam_loc"]
    showcase_cam.rotation_euler = frame["cam_rot"]
    # Rotate icons (frame parts via parent — set rotation_euler.z)
    for obj in showcase_icons:
        obj.rotation_euler = (math.radians(90), 0, frame["icon_rot_z"])
    out_path = os.path.join(RENDER_DIR, f"module_showcase_{fi+1}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

print("Module icons + showcase pipeline complete.")
