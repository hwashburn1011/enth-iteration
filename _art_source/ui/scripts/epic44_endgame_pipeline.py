"""
Epic 44 — Endgame Modes Pipeline
====================================
Builds:
  - Task 8: Tower entry NPC (Blender model)
  - Task 29: 5 mode hero icons (Challenge Tower, Infinite, Boss Rush, Daily, Hardcore)
  - Task 44: 5 endgame showcase frames + tower entry hero shot
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/endgame_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32

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

# Mode palettes
MODE_COLORS = {
    "tower": {"primary": (0.55, 0.42, 0.18), "accent": (1.0, 0.85, 0.30), "glow": 3.0},
    "infinite": {"primary": (0.20, 0.55, 0.85), "accent": (0.50, 0.85, 1.0), "glow": 3.5},
    "boss_rush": {"primary": (0.85, 0.20, 0.30), "accent": (1.0, 0.55, 0.30), "glow": 4.0},
    "daily": {"primary": (0.30, 0.85, 0.40), "accent": (0.85, 1.0, 0.55), "glow": 2.5},
    "hardcore": {"primary": (0.10, 0.10, 0.15), "accent": (1.0, 0.20, 0.20), "glow": 4.5},
}

mode_mats = {}
for mid, data in MODE_COLORS.items():
    mode_mats[mid] = {
        "primary": make_pbr(f"mode_{mid}_primary", data["primary"], 0.4, 0.4),
        "accent": make_pbr(f"mode_{mid}_accent", data["accent"], 0.3, 0.0, data["accent"], data["glow"]),
        "metal": make_pbr(f"mode_{mid}_metal", (0.55, 0.55, 0.60), 0.3, 0.95),
        "dark": make_pbr(f"mode_{mid}_dark", (0.05, 0.05, 0.08), 0.7),
    }

mat_skin = make_pbr("eg_skin", (0.85, 0.75, 0.60), 0.7)
mat_wood = make_pbr("eg_wood", (0.40, 0.22, 0.10), 0.85)
mat_npc_robe = make_pbr("eg_npc_robe", (0.30, 0.20, 0.45), 0.85)
mat_npc_accent = make_pbr("eg_npc_accent", (1.0, 0.85, 0.30), 0.3, 0.0, (1.0, 0.85, 0.30), 2.5)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_icons = make_coll("Mode_Icons")
col_npc = make_coll("Tower_NPC")
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

# === Mode icon symbol builders ===
def sym_tower(mats):
    parts = []
    # Tall tower pyramid: stack of cubes shrinking
    for i in range(4):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(0.32 - i*0.06, 0.06, 0.10), verts=bm.verts)
        bmesh.ops.translate(bm, vec=(0, 0, -0.16 + i*0.10), verts=bm.verts)
        parts.append((bm, mats["accent"]))
    return parts

def sym_infinite(mats):
    parts = []
    # Infinity loop (8 small spheres in figure-8)
    for i in range(8):
        ang = (i / 8) * math.tau
        x = math.sin(ang * 2) * 0.18
        z = math.sin(ang) * 0.15
        bm = ico(0.05, 1)
        parts.append((bm, mats["accent"]))
        # Mark position with offset (will be applied externally via locations)
    return parts

def sym_boss_rush(mats):
    parts = []
    # Skull silhouette: round + 2 eye cubes
    bm = ico(0.22, 2)
    parts.append((bm, mats["accent"]))
    return parts

def sym_daily(mats):
    parts = []
    # Calendar grid (3x3 of small cubes)
    for ix in range(3):
        for iz in range(3):
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            bmesh.ops.scale(bm, vec=(0.06, 0.04, 0.06), verts=bm.verts)
            parts.append((bm, mats["accent"]))
    return parts

def sym_hardcore(mats):
    parts = []
    # Skull-and-crossbones: round head + 2 crossed bars
    bm = ico(0.20, 2)
    parts.append((bm, mats["accent"]))
    return parts

# Build icons (with frame)
print("=== Building 5 mode icons ===")
icon_objs = {}
for i, mid in enumerate(["tower", "infinite", "boss_rush", "daily", "hardcore"]):
    mats = mode_mats[mid]
    pos_x = (i - 2) * 1.6
    objs = []
    # Frame
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.5, radius2=0.5, depth=0.05)
    objs.append(add_bm(f"mode_{mid}_frame", bm, mats["primary"], col_icons, loc=(pos_x, 0, 0)))
    # Inner ring
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.46, radius2=0.46, depth=0.06)
    objs.append(add_bm(f"mode_{mid}_ring", bm, mats["accent"], col_icons, loc=(pos_x, 0, 0.005)))
    # Inner backing
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.42, radius2=0.42, depth=0.05)
    objs.append(add_bm(f"mode_{mid}_inner", bm, mats["dark"], col_icons, loc=(pos_x, 0, 0.01)))
    # Symbol
    if mid == "tower":
        # 4 stacked decreasing cubes
        for j in range(4):
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            bmesh.ops.scale(bm, vec=(0.30 - j*0.06, 0.04, 0.06), verts=bm.verts)
            objs.append(add_bm(f"mode_{mid}_block_{j}", bm, mats["accent"], col_icons,
                               loc=(pos_x, 0.06, -0.20 + j*0.10)))
    elif mid == "infinite":
        # Figure-8 infinity loop (16 small spheres in a horizontal lemniscate)
        for j in range(16):
            t = (j / 16) * math.tau
            x_off = math.sin(t * 2) * 0.18
            z_off = math.sin(t) * 0.15
            bm = ico(0.04, 1)
            objs.append(add_bm(f"mode_{mid}_dot_{j}", bm, mats["accent"], col_icons,
                               loc=(pos_x + x_off, 0.06, z_off)))
    elif mid == "boss_rush":
        # Skull head + 2 eye sockets
        bm = ico(0.22, 2)
        objs.append(add_bm(f"mode_{mid}_skull", bm, mats["accent"], col_icons,
                           loc=(pos_x, 0.06, 0)))
        for sx in [-0.07, 0.07]:
            bm = ico(0.04, 1)
            objs.append(add_bm(f"mode_{mid}_eye_{sx}", bm, mats["dark"], col_icons,
                               loc=(pos_x + sx, 0.04, 0.02)))
    elif mid == "daily":
        # 3x3 calendar grid
        for ix in range(3):
            for iz in range(3):
                bm = bmesh.new()
                bmesh.ops.create_cube(bm, size=1.0)
                bmesh.ops.scale(bm, vec=(0.06, 0.04, 0.06), verts=bm.verts)
                objs.append(add_bm(f"mode_{mid}_cell_{ix}_{iz}", bm, mats["accent"], col_icons,
                                   loc=(pos_x - 0.16 + ix*0.16, 0.06, -0.16 + iz*0.16)))
    elif mid == "hardcore":
        # Death heart: large red sphere + 2 crossbones
        bm = ico(0.20, 2)
        objs.append(add_bm(f"mode_{mid}_heart", bm, mats["accent"], col_icons,
                           loc=(pos_x, 0.06, 0)))
        for ang in [math.radians(45), math.radians(-45)]:
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            bmesh.ops.scale(bm, vec=(0.05, 0.04, 0.30), verts=bm.verts)
            objs.append(add_bm(f"mode_{mid}_bone_{ang}", bm, mats["dark"], col_icons,
                               loc=(pos_x, 0.07, 0),
                               rot=(0, ang, 0)))
    icon_objs[mid] = objs

# === Tower entry NPC (cloaked figure with key staff) ===
print("=== Tower NPC ===")
NX = 8
# Body
add_bm("npc_body", ico(0.40, 2), mat_npc_robe, col_npc, loc=(NX, 0, 1.0))
# Head
add_bm("npc_head", ico(0.32, 2), mat_skin, col_npc, loc=(NX, 0, 1.65))
# Hood
add_bm("npc_hood", cone(0.36, 0.05, 0.45), mat_npc_robe, col_npc, loc=(NX, 0, 1.85))
# Robe (cone)
add_bm("npc_robe", cone(0.45, 0.65, 1.4), mat_npc_robe, col_npc, loc=(NX, 0, 0.5))
# Eye glow
add_bm("npc_eye", ico(0.05, 1), mat_npc_accent, col_npc, loc=(NX, -0.30, 1.65))
# Key staff in right hand
add_bm("npc_staff", cyl(0.04, 1.6, 6), mat_wood, col_npc, loc=(NX + 0.5, 0, 0.0))
# Staff key head (like a tower icon)
for i in range(3):
    add_bm(f"npc_staff_key_{i}", cube(0.10 - i*0.025, 0.04, 0.06), mat_npc_accent, col_npc,
           loc=(NX + 0.5, 0, 1.7 + i*0.08))
# Aura ring at feet
bm = bmesh.new()
bmesh.ops.create_circle(bm, segments=24, radius=0.7, cap_ends=False)
bm.verts.ensure_lookup_table()
inner = bm.verts[:]
bmesh.ops.create_circle(bm, segments=24, radius=0.62, cap_ends=False)
bm.verts.ensure_lookup_table()
outer = bm.verts[24:48]
for j in range(24):
    bm.faces.new([inner[j], inner[(j+1)%24], outer[(j+1)%24], outer[j]])
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_bm("npc_aura", bm, mat_npc_accent, col_npc, loc=(NX, 0, -0.3), rot=(math.radians(90), 0, 0))

# === Cameras ===
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 80
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

npc_cam_data = bpy.data.cameras.new("NPC_Cam")
npc_cam_data.lens = 50
npc_cam = bpy.data.objects.new("NPC_Cam", npc_cam_data)
npc_cam.location = (NX, -4, 1.5)
npc_cam.rotation_euler = (math.radians(85), 0, 0)
scene.collection.objects.link(npc_cam)
link_to(npc_cam, col_cam)

# Lights
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 600
key_data.size = 5
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, -3, 5)
key_obj.rotation_euler = (math.radians(45), 0, 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 200
fill_data.size = 6
fill_data.color = (0.7, 0.85, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (0, 4, 4)
fill_obj.rotation_euler = (math.radians(110), 0, 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

world = bpy.data.worlds.new("World_Eg")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render 5 mode icons ===
print("=== Rendering 5 mode icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

# Hide NPC
for obj in col_npc.objects:
    obj.hide_render = True

for mid in icon_objs.keys():
    for k2, o2 in icon_objs.items():
        for o in o2:
            o.hide_render = (k2 != mid)
    objs = icon_objs[mid]
    cx = sum(o.location.x for o in objs) / len(objs)
    icon_cam.location = (cx, -1.6, 0.0)
    icon_cam.rotation_euler = (math.radians(85), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"endgame_mode_{mid}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render NPC ===
print("=== Rendering tower NPC ===")
scene.render.resolution_x = 512
scene.render.resolution_y = 768
# Hide all icons
for k2, o2 in icon_objs.items():
    for o in o2:
        o.hide_render = True
# Show NPC
for obj in col_npc.objects:
    obj.hide_render = False
scene.camera = npc_cam
out_path = os.path.join(RENDER_DIR, "tower_entry_npc.png")
scene.render.filepath = out_path
bpy.ops.render.render(write_still=True)

# === Render endgame showcase video frames (4 frames showing modes lined up) ===
print("=== Rendering showcase frames ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False

# Show all icons in line + NPC behind
for k2, o2 in icon_objs.items():
    for o in o2:
        o.hide_render = False
for obj in col_npc.objects:
    obj.hide_render = True

# 4 camera angles
showcase_cam_data = bpy.data.cameras.new("Showcase_Cam")
showcase_cam_data.lens = 50
showcase_cam = bpy.data.objects.new("Showcase_Cam", showcase_cam_data)
scene.collection.objects.link(showcase_cam)
link_to(showcase_cam, col_cam)
scene.camera = showcase_cam

ANGLES = [
    {"loc": (0, -4, 1), "rot": (math.radians(85), 0, 0)},
    {"loc": (-2, -3.5, 1), "rot": (math.radians(85), 0, math.radians(15))},
    {"loc": (2, -3.5, 1), "rot": (math.radians(85), 0, math.radians(-15))},
    {"loc": (0, -3.0, 1.5), "rot": (math.radians(80), 0, 0)},
]
for fi, angle in enumerate(ANGLES):
    showcase_cam.location = angle["loc"]
    showcase_cam.rotation_euler = angle["rot"]
    out_path = os.path.join(RENDER_DIR, f"endgame_showcase_{fi+1}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

print("Endgame pipeline complete.")
