"""
Epic 45 — Difficulty & Modifier Icons Pipeline
==================================================
Builds:
  - Task 21: 30 modifier icons (256x256 transparent PNG each)
  - Task 47: 5 difficulty showcase frames (one per difficulty tier)
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/difficulty_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 24

def make_pbr(name, base, rough=0.55, metal=0.0, emit=None, emit_strength=0.0):
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

# Type palettes (positive=blue, neutral=gold, negative=red)
mat_pos_frame = make_pbr("mod_pos_frame", (0.20, 0.40, 0.65), 0.4, 0.4)
mat_pos_accent = make_pbr("mod_pos_accent", (0.40, 0.85, 1.0), 0.3, 0.0, (0.5, 0.9, 1.0), 3.5)
mat_neutral_frame = make_pbr("mod_neutral_frame", (0.55, 0.42, 0.18), 0.4, 0.4)
mat_neutral_accent = make_pbr("mod_neutral_accent", (1.0, 0.85, 0.30), 0.3, 0.0, (1.0, 0.85, 0.30), 3.0)
mat_neg_frame = make_pbr("mod_neg_frame", (0.65, 0.20, 0.20), 0.4, 0.4)
mat_neg_accent = make_pbr("mod_neg_accent", (1.0, 0.30, 0.30), 0.3, 0.0, (1.0, 0.3, 0.3), 3.5)
mat_inner = make_pbr("mod_inner", (0.05, 0.05, 0.10), 0.7)

# Difficulty palettes
DIFF_COLORS = {
    "easy": (0.30, 0.85, 0.40),
    "normal": (0.40, 0.70, 1.0),
    "hard": (1.0, 0.85, 0.30),
    "expert": (1.0, 0.55, 0.20),
    "nightmare": (1.0, 0.20, 0.30),
}
diff_mats = {}
for did, color in DIFF_COLORS.items():
    diff_mats[did] = {
        "frame": make_pbr(f"diff_{did}_frame", (color[0]*0.4, color[1]*0.4, color[2]*0.4), 0.4, 0.4),
        "accent": make_pbr(f"diff_{did}_accent", color, 0.3, 0.0, color, 3.5),
        "dark": make_pbr(f"diff_{did}_dark", (0.05, 0.05, 0.10), 0.7),
    }

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_modifiers = make_coll("Modifiers")
col_difficulties = make_coll("Difficulties")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_bm(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    if mat is not None:
        me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

def cube(sx, sy, sz):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    return bm

def cyl(r, h, segs=12):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def cone(r1, r2, h, segs=10):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def ico(r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    return bm

# === 30 modifier symbol shapes (cycle through 6 templates × positive/neutral/negative) ===
# Each modifier index 0-29, type derived from index%3 (0=pos, 1=neutral, 2=neg),
# shape derived from index//3 (0-9 → 10 shapes, but we cycle 6 distinct ones)
SHAPE_BUILDERS_NAMES = ["arrow_up", "arrow_down", "shield", "skull", "spark", "gear",
                          "heart", "lightning", "diamond", "infinity"]

def sym_arrow_up(mat):
    parts = []
    bm = cube(0.05, 0.05, 0.30)
    parts.append((bm, mat))
    bm = cone(0.10, 0.0, 0.15)
    parts.append((bm, mat))
    return parts

def sym_arrow_down(mat):
    parts = []
    bm = cube(0.05, 0.05, 0.30)
    parts.append((bm, mat))
    bm = cone(0.10, 0.0, 0.15)
    bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.pi, 3, 'X'), verts=bm.verts)
    parts.append((bm, mat))
    return parts

def sym_shield(mat):
    parts = []
    bm = cube(0.30, 0.06, 0.40)
    parts.append((bm, mat))
    return parts

def sym_skull(mat):
    parts = []
    bm = ico(0.22, 2)
    parts.append((bm, mat))
    return parts

def sym_spark(mat):
    parts = []
    for i in range(6):
        ang = (i / 6) * math.tau
        bm = cube(0.04, 0.04, 0.18)
        bmesh.ops.rotate(bm, matrix=Matrix.Rotation(ang, 3, 'Y'), verts=bm.verts)
        parts.append((bm, mat))
    bm = ico(0.08, 2)
    parts.append((bm, mat))
    return parts

def sym_gear(mat):
    parts = []
    for i in range(8):
        ang = (i / 8) * math.tau
        bm = cube(0.05, 0.05, 0.10)
        parts.append((bm, mat))
    bm = cyl(0.18, 0.04, 16)
    parts.append((bm, mat))
    return parts

def sym_heart(mat):
    parts = []
    bm = ico(0.18, 2)
    parts.append((bm, mat))
    return parts

def sym_lightning(mat):
    parts = []
    for i in range(3):
        bm = cube(0.04, 0.04, 0.12)
        parts.append((bm, mat))
    return parts

def sym_diamond(mat):
    parts = []
    bm = ico(0.20, 1)
    bmesh.ops.scale(bm, vec=(0.7, 1, 1.4), verts=bm.verts)
    parts.append((bm, mat))
    return parts

def sym_infinity(mat):
    parts = []
    for i in range(8):
        bm = ico(0.04, 1)
        parts.append((bm, mat))
    return parts

SHAPE_BUILDERS = [sym_arrow_up, sym_arrow_down, sym_shield, sym_skull, sym_spark,
                  sym_gear, sym_heart, sym_lightning, sym_diamond, sym_infinity]

# === Build 30 modifier icons (6 cols × 5 rows) ===
print("=== Building 30 modifier icons ===")
mod_objs = {}
for i in range(30):
    type_idx = i % 3
    shape_idx = i % 10
    col_x = i % 6
    row_y = i // 6
    pos_x = (col_x - 2.5) * 1.4
    pos_y = (row_y - 2) * 1.4
    if type_idx == 0:
        frame_mat = mat_pos_frame
        accent_mat = mat_pos_accent
    elif type_idx == 1:
        frame_mat = mat_neutral_frame
        accent_mat = mat_neutral_accent
    else:
        frame_mat = mat_neg_frame
        accent_mat = mat_neg_accent
    objs = []
    # Frame
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.5, radius2=0.5, depth=0.05)
    objs.append(add_bm(f"mod_{i:02d}_frame", bm, frame_mat, col_modifiers, loc=(pos_x, pos_y, 0)))
    # Inner ring
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.46, radius2=0.46, depth=0.06)
    objs.append(add_bm(f"mod_{i:02d}_ring", bm, accent_mat, col_modifiers, loc=(pos_x, pos_y, 0.005)))
    # Inner backing
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.42, radius2=0.42, depth=0.05)
    objs.append(add_bm(f"mod_{i:02d}_inner", bm, mat_inner, col_modifiers, loc=(pos_x, pos_y, 0.01)))
    # Symbol parts (positioned above inner backing, rotated to face top-down camera)
    builder = SHAPE_BUILDERS[shape_idx]
    parts = builder(accent_mat)
    for pi, (bm, mat) in enumerate(parts):
        objs.append(add_bm(f"mod_{i:02d}_p{pi}", bm, mat, col_modifiers,
                           loc=(pos_x, pos_y, 0.06),
                           rot=(math.radians(90), 0, 0)))
    mod_objs[f"mod_{i:02d}"] = objs

# === 5 difficulty showcase scenes ===
print("=== Building 5 difficulty scenes ===")
diff_objs = {}
for i, did in enumerate(["easy", "normal", "hard", "expert", "nightmare"]):
    mats = diff_mats[did]
    pos_x = (i - 2) * 5 + 30
    objs = []
    # Pedestal
    objs.append(add_bm(f"diff_{did}_pedestal", cyl(1.2, 0.4, 16), mats["dark"], col_difficulties,
                       loc=(pos_x, 0, 0.2)))
    # Base ring
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=1.4, radius2=1.4, depth=0.05)
    objs.append(add_bm(f"diff_{did}_basering", bm, mats["accent"], col_difficulties,
                       loc=(pos_x, 0, 0.45)))
    # Floating crystal (taller for harder)
    crystal_height = 0.6 + i * 0.25
    objs.append(add_bm(f"diff_{did}_crystal", cone(0.40, 0.0, crystal_height), mats["accent"],
                       col_difficulties, loc=(pos_x, 0, 0.8)))
    # Number of orbiting shards = difficulty tier + 1
    shard_count = i + 1
    for s in range(shard_count):
        ang = (s / shard_count) * math.tau
        objs.append(add_bm(f"diff_{did}_shard_{s}", ico(0.10, 1), mats["accent"], col_difficulties,
                           loc=(pos_x + math.cos(ang)*1.0, math.sin(ang)*1.0, 1.2)))
    # Crown (only for nightmare)
    if did == "nightmare":
        for j in range(5):
            ang = (j / 5) * math.tau
            objs.append(add_bm(f"diff_{did}_crown_{j}", cone(0.05, 0.0, 0.20), mats["accent"],
                               col_difficulties,
                               loc=(pos_x + math.cos(ang)*0.30, math.sin(ang)*0.30, 1.55)))
    diff_objs[did] = objs

# === Cameras ===
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 80
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

diff_cam_data = bpy.data.cameras.new("Diff_Cam")
diff_cam_data.lens = 70
diff_cam = bpy.data.objects.new("Diff_Cam", diff_cam_data)
diff_cam.rotation_euler = (math.radians(78), 0, 0)
scene.collection.objects.link(diff_cam)
link_to(diff_cam, col_cam)

# === Lights ===
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 600
key_data.size = 8
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, -3, 6)
key_obj.rotation_euler = (math.radians(45), 0, 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 200
fill_data.size = 10
fill_data.color = (0.65, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (0, 4, 4)
fill_obj.rotation_euler = (math.radians(110), 0, 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

world = bpy.data.worlds.new("World_Diff")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render 30 modifier icons ===
print("=== Rendering 30 modifier icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

# Hide difficulty scene
for obj in col_difficulties.objects:
    obj.hide_render = True

for mod_id in mod_objs.keys():
    for k2, o2 in mod_objs.items():
        for o in o2:
            o.hide_render = (k2 != mod_id)
    objs = mod_objs[mod_id]
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    icon_cam.location = (cx, cy - 1.6, 0.0)
    icon_cam.rotation_euler = (math.radians(85), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"modifier_{mod_id}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render 5 difficulty showcase frames ===
print("=== Rendering 5 difficulty showcase frames ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False
# Hide all modifiers
for k2, o2 in mod_objs.items():
    for o in o2:
        o.hide_render = True

scene.camera = diff_cam
for did in diff_objs.keys():
    for k2, o2 in diff_objs.items():
        for o in o2:
            o.hide_render = (k2 != did)
    objs = diff_objs[did]
    cx = sum(o.location.x for o in objs) / len(objs)
    diff_cam.location = (cx, -5, 2.5)
    out_path = os.path.join(RENDER_DIR, f"difficulty_{did}_showcase.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

print("Difficulty pipeline complete.")
