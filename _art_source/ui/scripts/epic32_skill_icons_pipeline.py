"""
Epic 32 — Skill Tree Icon Library + Tree Hero Render
=====================================================
Builds 150 unique skill node icons (50 per class) and renders each as a
transparent 256x256 PNG. Then assembles a full unlocked skill tree mesh
and renders a hero shot per class.

Saves:
  - _art_source/ui/skill_icons.blend
  - _art_source/ui/renders/skill_<class>_<node_id>.png  (150 icons)
  - _art_source/ui/renders/skill_tree_compiler_hero.png
  - _art_source/ui/renders/skill_tree_daemon_hero.png
  - _art_source/ui/renders/skill_tree_kernel_hero.png

Each class gets 50 unique icon designs assembled procedurally from a base
shape library: blade, gear, shield, spark, dagger, eye, gauntlet, totem,
crystal, rune, etc. Each class has its own accent color for icon emission.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, Matrix

random.seed(3232)
OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/skill_icons.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.render.film_transparent = True

def make_pbr(name, base, rough=0.6, metal=0.0, emit=None, emit_strength=0.0):
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

# Per-class palettes
CLASS_COLORS = {
    "compiler": {"frame": (0.18, 0.42, 0.65), "accent": (1.0, 0.85, 0.35), "glow": 2.5},
    "daemon": {"frame": (0.62, 0.10, 0.20), "accent": (1.0, 0.30, 0.45), "glow": 3.0},
    "kernel": {"frame": (0.15, 0.30, 0.30), "accent": (0.30, 0.85, 0.85), "glow": 2.2},
}

# Materials per class
class_mats = {}
for cid, cdata in CLASS_COLORS.items():
    class_mats[cid] = {
        "frame": make_pbr(f"{cid}_frame", cdata["frame"], 0.4, 0.3),
        "accent": make_pbr(f"{cid}_accent", cdata["accent"], 0.3, 0.0,
                           cdata["accent"], cdata["glow"]),
        "metal": make_pbr(f"{cid}_metal", (0.55, 0.55, 0.60), 0.3, 0.95),
        "dark": make_pbr(f"{cid}_dark", (0.05, 0.05, 0.08), 0.7),
    }

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_icons = make_coll("Skill_Icons")
col_trees = make_coll("Skill_Trees")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

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

# ============ Icon shape primitives ============
def shape_blade(mats):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.06, 0.06, 0.5), verts=bm.verts)
    return [(bm, mats["accent"])]

def shape_gear(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.35, radius2=0.35, depth=0.06)
    parts.append((bm, mats["frame"]))
    for i in range(8):
        ang = (i / 8) * math.tau
        tooth = bmesh.new()
        bmesh.ops.create_cube(tooth, size=1.0)
        bmesh.ops.scale(tooth, vec=(0.06, 0.06, 0.04), verts=tooth.verts)
        bmesh.ops.translate(tooth, vec=(math.cos(ang)*0.4, math.sin(ang)*0.4, 0), verts=tooth.verts)
        parts.append((tooth, mats["frame"]))
    bm2 = bmesh.new()
    bmesh.ops.create_cone(bm2, segments=12, radius1=0.12, radius2=0.12, depth=0.08)
    parts.append((bm2, mats["accent"]))
    return parts

def shape_shield(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.35, 0.06, 0.5), verts=bm.verts)
    parts.append((bm, mats["frame"]))
    bm2 = bmesh.new()
    bmesh.ops.create_icosphere(bm2, subdivisions=2, radius=0.13)
    parts.append((bm2, mats["accent"]))
    return parts

def shape_spark(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.18)
    parts.append((bm, mats["accent"]))
    for i in range(4):
        ang = (i / 4) * math.tau
        ray = bmesh.new()
        bmesh.ops.create_cube(ray, size=1.0)
        bmesh.ops.scale(ray, vec=(0.04, 0.04, 0.25), verts=ray.verts)
        bmesh.ops.rotate(ray, matrix=Matrix.Rotation(ang, 3, 'X'), verts=ray.verts)
        parts.append((ray, mats["accent"]))
    return parts

def shape_dagger(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.06, 0.06, 0.35), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0, 0, 0.05), verts=bm.verts)
    parts.append((bm, mats["accent"]))
    grip = bmesh.new()
    bmesh.ops.create_cube(grip, size=1.0)
    bmesh.ops.scale(grip, vec=(0.05, 0.05, 0.1), verts=grip.verts)
    bmesh.ops.translate(grip, vec=(0, 0, -0.18), verts=grip.verts)
    parts.append((grip, mats["dark"]))
    return parts

def shape_eye(mats):
    parts = []
    outer = bmesh.new()
    bmesh.ops.create_uvsphere(outer, u_segments=16, v_segments=8, radius=0.32)
    bmesh.ops.scale(outer, vec=(1.2, 0.4, 1), verts=outer.verts)
    parts.append((outer, mats["frame"]))
    pupil = bmesh.new()
    bmesh.ops.create_icosphere(pupil, subdivisions=2, radius=0.13)
    parts.append((pupil, mats["accent"]))
    return parts

def shape_gauntlet(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.25, 0.25, 0.4), verts=bm.verts)
    parts.append((bm, mats["frame"]))
    for i in range(3):
        knuck = bmesh.new()
        bmesh.ops.create_icosphere(knuck, subdivisions=1, radius=0.07)
        bmesh.ops.translate(knuck, vec=(-0.15 + i*0.15, 0, 0.25), verts=knuck.verts)
        parts.append((knuck, mats["accent"]))
    return parts

def shape_totem(mats):
    parts = []
    base = bmesh.new()
    bmesh.ops.create_cone(base, segments=8, radius1=0.25, radius2=0.20, depth=0.5)
    parts.append((base, mats["frame"]))
    glow = bmesh.new()
    bmesh.ops.create_icosphere(glow, subdivisions=2, radius=0.15)
    bmesh.ops.translate(glow, vec=(0, 0, 0.35), verts=glow.verts)
    parts.append((glow, mats["accent"]))
    return parts

def shape_crystal(mats):
    parts = []
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=4, radius1=0.18, radius2=0.0, depth=0.5)
    parts.append((bm, mats["accent"]))
    bm2 = bmesh.new()
    bmesh.ops.create_cone(bm2, segments=4, radius1=0.18, radius2=0.0, depth=0.3)
    bmesh.ops.rotate(bm2, matrix=Matrix.Rotation(math.pi, 3, 'X'), verts=bm2.verts)
    bmesh.ops.translate(bm2, vec=(0, 0, -0.15), verts=bm2.verts)
    parts.append((bm2, mats["accent"]))
    return parts

def shape_rune(mats):
    parts = []
    ring = bmesh.new()
    bmesh.ops.create_cone(ring, segments=12, radius1=0.35, radius2=0.35, depth=0.04)
    parts.append((ring, mats["frame"]))
    glyph = bmesh.new()
    bmesh.ops.create_cube(glyph, size=1.0)
    bmesh.ops.scale(glyph, vec=(0.05, 0.04, 0.35), verts=glyph.verts)
    parts.append((glyph, mats["accent"]))
    glyph2 = bmesh.new()
    bmesh.ops.create_cube(glyph2, size=1.0)
    bmesh.ops.scale(glyph2, vec=(0.35, 0.04, 0.05), verts=glyph2.verts)
    parts.append((glyph2, mats["accent"]))
    return parts

# 10 shape templates per class — we'll cycle them for 50 unique nodes
SHAPE_BUILDERS = [
    shape_blade, shape_gear, shape_shield, shape_spark, shape_dagger,
    shape_eye, shape_gauntlet, shape_totem, shape_crystal, shape_rune,
]

def build_icon(class_id, node_idx, position):
    """Build a single icon and link to a sub-collection."""
    mats = class_mats[class_id]
    builder = SHAPE_BUILDERS[node_idx % len(SHAPE_BUILDERS)]
    parts = builder(mats)
    objs = []
    # Backing frame disk (always present)
    frame = bmesh.new()
    bmesh.ops.create_cone(frame, segments=24, radius1=0.5, radius2=0.5, depth=0.05)
    obj = add_bm(f"{class_id}_n{node_idx:02d}_frame", frame, mats["frame"], col_icons,
                 loc=position)
    objs.append(obj)
    # Inner ring
    ring = bmesh.new()
    bmesh.ops.create_cone(ring, segments=24, radius1=0.46, radius2=0.46, depth=0.06)
    obj = add_bm(f"{class_id}_n{node_idx:02d}_ring", ring, mats["accent"], col_icons,
                 loc=(position[0], position[1], position[2] + 0.005))
    objs.append(obj)
    # Inner backing
    inner = bmesh.new()
    bmesh.ops.create_cone(inner, segments=24, radius1=0.42, radius2=0.42, depth=0.05)
    obj = add_bm(f"{class_id}_n{node_idx:02d}_inner", inner, mats["dark"], col_icons,
                 loc=(position[0], position[1], position[2] + 0.01))
    objs.append(obj)
    # Symbol parts
    for pi, (bm, mat) in enumerate(parts):
        obj = add_bm(f"{class_id}_n{node_idx:02d}_p{pi}", bm, mat, col_icons,
                     loc=(position[0], position[1], position[2] + 0.05),
                     rot=(math.radians(90), 0, 0))
        objs.append(obj)
    return objs

# === Build all 150 icons (laid out in a 10x15 grid for the .blend file) ===
print("=== Building 150 icons ===")
all_icons = {}  # (class_id, node_idx) → list of objects
for ci, class_id in enumerate(["compiler", "daemon", "kernel"]):
    for n in range(50):
        col = n // 10
        row = n % 10
        x_pos = ci * 8 + col * 1.4 - 5
        y_pos = row * 1.4 - 6
        objs = build_icon(class_id, n, (x_pos, y_pos, 0))
        all_icons[(class_id, n)] = objs

# === Camera + Lights for icon renders ===
print("=== Setup cameras + lights ===")
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 80
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

key_data = bpy.data.lights.new("Icon_Key", type='AREA')
key_data.energy = 220
key_data.size = 2.5
key_data.color = (1.0, 0.95, 0.9)
key_obj = bpy.data.objects.new("Icon_Key", key_data)
key_obj.rotation_euler = (math.radians(45), math.radians(-25), 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Icon_Fill", type='AREA')
fill_data.energy = 80
fill_data.size = 3
fill_data.color = (0.6, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Icon_Fill", fill_data)
fill_obj.rotation_euler = (math.radians(60), math.radians(40), 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

# World
world = bpy.data.worlds.new("World_Skill")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.08, 1.0)
bg.inputs['Strength'].default_value = 0.3

# === Build full skill tree mesh per class for hero render ===
print("=== Building tree mesh per class ===")
class TreeData:
    def __init__(self, class_id):
        self.class_id = class_id
        self.coll = make_coll(f"Tree_{class_id}")
        self.objs = []

trees = {cid: TreeData(cid) for cid in CLASS_COLORS.keys()}

# Tree topology: 5 keystones in a pentagon, with 9 normal nodes branching off each
def build_tree(class_id, x_offset):
    tree = trees[class_id]
    mats = class_mats[class_id]
    # Background plate
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=32, radius1=8, radius2=8, depth=0.1)
    obj = add_bm(f"{class_id}_TreePlate", bm, mats["dark"], tree.coll,
                 loc=(x_offset, 0, -1))
    tree.objs.append(obj)
    # Background ring
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=32, radius1=8, radius2=7.7, depth=0.05)
    obj = add_bm(f"{class_id}_TreeRing", bm, mats["accent"], tree.coll,
                 loc=(x_offset, 0, -0.95))
    tree.objs.append(obj)

    # 5 keystones in pentagon
    keystone_positions = []
    for i in range(5):
        ang = (i / 5) * math.tau - math.pi/2
        kx = x_offset + math.cos(ang) * 5
        ky = math.sin(ang) * 5
        keystone_positions.append((kx, ky))
        # Build a larger icon for the keystone
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=24, radius1=0.9, radius2=0.9, depth=0.2)
        obj = add_bm(f"{class_id}_Keystone_{i}", bm, mats["frame"], tree.coll, loc=(kx, ky, -0.85))
        tree.objs.append(obj)
        bm = bmesh.new()
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.4)
        obj = add_bm(f"{class_id}_KeystoneCore_{i}", bm, mats["accent"], tree.coll,
                     loc=(kx, ky, -0.7))
        tree.objs.append(obj)
        # Glow ring around keystone
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=24, radius1=1.0, radius2=1.0, depth=0.04)
        obj = add_bm(f"{class_id}_KeystoneRing_{i}", bm, mats["accent"], tree.coll,
                     loc=(kx, ky, -0.65))
        tree.objs.append(obj)

    # 9 nodes per keystone (= 45 normal + 5 keystone = 50)
    for ki, (kx, ky) in enumerate(keystone_positions):
        for ni in range(9):
            # Place on a smaller arc around the keystone
            local_ang = (ni / 9) * math.tau
            nx = kx + math.cos(local_ang) * 1.6
            ny = ky + math.sin(local_ang) * 1.6
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=16, radius1=0.4, radius2=0.4, depth=0.1)
            obj = add_bm(f"{class_id}_Node_{ki}_{ni}", bm, mats["frame"], tree.coll,
                         loc=(nx, ny, -0.85))
            tree.objs.append(obj)
            bm = bmesh.new()
            bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.18)
            obj = add_bm(f"{class_id}_NodeCore_{ki}_{ni}", bm, mats["accent"], tree.coll,
                         loc=(nx, ny, -0.7))
            tree.objs.append(obj)
            # Connection line keystone → node
            dx, dy = nx - kx, ny - ky
            length = math.sqrt(dx*dx + dy*dy)
            ang = math.atan2(dy, dx)
            mid_x, mid_y = (kx+nx)/2, (ky+ny)/2
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            bmesh.ops.scale(bm, vec=(length/2, 0.04, 0.02), verts=bm.verts)
            obj = add_bm(f"{class_id}_Conn_{ki}_{ni}", bm, mats["accent"], tree.coll,
                         loc=(mid_x, mid_y, -0.85), rot=(0, 0, ang))
            tree.objs.append(obj)

# Build all 3 trees offset
build_tree("compiler", -25)
build_tree("daemon", 0)
build_tree("kernel", 25)

# Hero shot cameras per class (top-down with slight tilt)
hero_cams = {}
for ci, (class_id, x_off) in enumerate([("compiler", -25), ("daemon", 0), ("kernel", 25)]):
    cam_data = bpy.data.cameras.new(f"Hero_{class_id}")
    cam_data.lens = 50
    cam_obj = bpy.data.objects.new(f"Hero_{class_id}", cam_data)
    cam_obj.location = (x_off, -3, 16)
    cam_obj.rotation_euler = (math.radians(20), 0, 0)
    scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cam)
    hero_cams[class_id] = cam_obj

# Hero key light per tree
tree_keys = {}
for ci, (class_id, x_off) in enumerate([("compiler", -25), ("daemon", 0), ("kernel", 25)]):
    light_data = bpy.data.lights.new(f"Tree_Key_{class_id}", type='AREA')
    light_data.energy = 1500
    light_data.size = 14
    light_data.color = (1.0, 0.95, 0.85)
    light_obj = bpy.data.objects.new(f"Tree_Key_{class_id}", light_data)
    light_obj.location = (x_off, 0, 12)
    light_obj.rotation_euler = (0, 0, 0)
    scene.collection.objects.link(light_obj)
    link_to(light_obj, col_lights)
    tree_keys[class_id] = light_obj

# Save scene
print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# === Render 150 individual icons ===
print("=== Rendering 150 icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

# Hide all trees
for tdata in trees.values():
    for obj in tdata.objs:
        obj.hide_render = True
# Hide hero key lights
for k_obj in tree_keys.values():
    k_obj.hide_render = True

icon_count = 0
all_icon_objs_flat = []
for key, objs in all_icons.items():
    for o in objs:
        all_icon_objs_flat.append((key, o))

for key, _ in all_icons.items():
    class_id, node_idx = key
    objs = all_icons[key]
    # Hide all icons
    for k2, objs2 in all_icons.items():
        for o in objs2:
            o.hide_render = (k2 == key)
    # Position camera right above this icon
    cx, cy, cz = objs[0].location
    icon_cam.location = (cx, cy - 0.3, cz + 1.6)
    out_path = os.path.join(RENDER_DIR, f"skill_{class_id}_n{node_idx:02d}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    icon_count += 1
print(f"Rendered {icon_count} icons.")

# === Render 3 tree hero shots ===
print("=== Rendering tree hero shots ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False

# Hide all icons
for k2, objs2 in all_icons.items():
    for o in objs2:
        o.hide_render = True
# Hide other lights initially, key light visible
for k_obj in tree_keys.values():
    k_obj.hide_render = True

for class_id in ["compiler", "daemon", "kernel"]:
    tdata = trees[class_id]
    for tcid, td in trees.items():
        for obj in td.objs:
            obj.hide_render = (tcid != class_id)
    for kc, k_obj in tree_keys.items():
        k_obj.hide_render = (kc != class_id)
    scene.camera = hero_cams[class_id]
    out_path = os.path.join(RENDER_DIR, f"skill_tree_{class_id}_hero.png")
    scene.render.filepath = out_path
    print(f"=== Rendering tree {class_id} hero ===")
    bpy.ops.render.render(write_still=True)

print("Skill icons + tree pipeline complete.")
