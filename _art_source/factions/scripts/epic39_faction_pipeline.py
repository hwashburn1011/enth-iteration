"""
Epic 39 — Faction System Assets Pipeline
==========================================
Builds in one Blender background pass:
  - Task 10: 4 faction emblem icons (Optimizers/Glitchers/Archivists/Dreamers)
  - Task 12: 4 faction headquarters scenes
  - Task 21: Faction rank-up cinematic placeholder mesh
  - Task 27: Faction war event placeholder scene
  - Task 28: 4 faction-aligned NPC variants
  - Task 29: 4 faction-aligned enemy variants
  - Task 40: 4 HQ hero shots
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/factions/faction_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/factions/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32

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

# Per-faction palettes
FACTIONS = {
    "optimizers": {"primary": (0.18, 0.42, 0.65), "accent": (1.0, 0.85, 0.35), "glow": 2.0, "ideology": "order"},
    "glitchers": {"primary": (0.62, 0.10, 0.85), "accent": (0.30, 1.0, 0.55), "glow": 3.5, "ideology": "chaos"},
    "archivists": {"primary": (0.45, 0.30, 0.10), "accent": (1.0, 0.75, 0.20), "glow": 1.5, "ideology": "preservation"},
    "dreamers": {"primary": (0.85, 0.55, 0.85), "accent": (0.55, 0.85, 1.0), "glow": 2.5, "ideology": "creativity"},
}

faction_mats = {}
for fid, fdata in FACTIONS.items():
    faction_mats[fid] = {
        "primary": make_pbr(f"f_{fid}_primary", fdata["primary"], 0.5, 0.3),
        "accent": make_pbr(f"f_{fid}_accent", fdata["accent"], 0.3, 0.0, fdata["accent"], fdata["glow"]),
        "metal": make_pbr(f"f_{fid}_metal", (0.55, 0.55, 0.60), 0.3, 0.95),
        "stone": make_pbr(f"f_{fid}_stone", (0.40, 0.40, 0.45), 0.85),
        "dark": make_pbr(f"f_{fid}_dark", (0.05, 0.05, 0.08), 0.7),
    }

mat_skin = make_pbr("f_skin", (0.85, 0.75, 0.60), 0.7)
mat_wood = make_pbr("f_wood", (0.40, 0.22, 0.10), 0.85)
mat_grass = make_pbr("f_grass", (0.18, 0.32, 0.12), 0.85)
mat_floor = make_pbr("f_floor", (0.65, 0.55, 0.45), 0.75)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_emblems = make_coll("Emblems")
col_hqs = make_coll("HQs")
col_npcs = make_coll("NPCs")
col_enemies = make_coll("Enemies")
col_rankup = make_coll("RankUp")
col_war = make_coll("WarEvent")
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

# === Build 4 faction emblems ===
# Each: backing disc + accent ring + unique central symbol
print("=== Building 4 emblems ===")
emblem_objs = {}
for i, (fid, fdata) in enumerate(FACTIONS.items()):
    mats = faction_mats[fid]
    pos_x = i * 2.5 - 3.75
    objs = []
    # Backing disc
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.6, radius2=0.6, depth=0.05)
    objs.append(add_bm(f"emblem_{fid}_disc", bm, mats["primary"], col_emblems, loc=(pos_x, 0, 0)))
    # Accent ring
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.55, radius2=0.55, depth=0.06)
    objs.append(add_bm(f"emblem_{fid}_ring", bm, mats["accent"], col_emblems, loc=(pos_x, 0, 0.005)))
    # Inner backing
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.50, radius2=0.50, depth=0.05)
    objs.append(add_bm(f"emblem_{fid}_inner", bm, mats["dark"], col_emblems, loc=(pos_x, 0, 0.01)))
    # Symbol per faction (rotated 90° about X to face camera)
    if fid == "optimizers":
        # 8-tooth gear
        for j in range(8):
            ang = (j / 8) * math.tau
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            bmesh.ops.scale(bm, vec=(0.06, 0.06, 0.10), verts=bm.verts)
            objs.append(add_bm(f"emblem_{fid}_gear_{j}", bm, mats["accent"], col_emblems,
                               loc=(pos_x + math.cos(ang)*0.30, 0.06, math.sin(ang)*0.30)))
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.18, radius2=0.18, depth=0.04)
        bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'X'), verts=bm.verts)
        objs.append(add_bm(f"emblem_{fid}_hub", bm, mats["accent"], col_emblems, loc=(pos_x, 0.07, 0)))
    elif fid == "glitchers":
        # Lightning bolt (zigzag of cubes)
        for j in range(4):
            offset = [(-0.1, 0.2), (0.05, 0.05), (-0.05, -0.1), (0.1, -0.25)][j]
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            bmesh.ops.scale(bm, vec=(0.06, 0.04, 0.10), verts=bm.verts)
            bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(20 if j % 2 == 0 else -20), 3, 'Y'), verts=bm.verts)
            objs.append(add_bm(f"emblem_{fid}_bolt_{j}", bm, mats["accent"], col_emblems,
                               loc=(pos_x + offset[0], 0.07, offset[1])))
    elif fid == "archivists":
        # Open book (2 cubes meeting at angle)
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(0.20, 0.04, 0.30), verts=bm.verts)
        objs.append(add_bm(f"emblem_{fid}_page_l", bm, mats["accent"], col_emblems,
                           loc=(pos_x - 0.20, 0.07, 0), rot=(0, math.radians(15), 0)))
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(0.20, 0.04, 0.30), verts=bm.verts)
        objs.append(add_bm(f"emblem_{fid}_page_r", bm, mats["accent"], col_emblems,
                           loc=(pos_x + 0.20, 0.07, 0), rot=(0, math.radians(-15), 0)))
        # Spine
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(0.04, 0.06, 0.32), verts=bm.verts)
        objs.append(add_bm(f"emblem_{fid}_spine", bm, mats["metal"], col_emblems, loc=(pos_x, 0.075, 0)))
    elif fid == "dreamers":
        # Crescent moon + 3 stars
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.30, radius2=0.30, depth=0.08)
        bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'X'), verts=bm.verts)
        objs.append(add_bm(f"emblem_{fid}_moon_outer", bm, mats["accent"], col_emblems, loc=(pos_x - 0.05, 0.07, 0)))
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.22, radius2=0.22, depth=0.10)
        bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'X'), verts=bm.verts)
        objs.append(add_bm(f"emblem_{fid}_moon_cut", bm, mats["dark"], col_emblems, loc=(pos_x + 0.05, 0.075, 0)))
        # 3 stars
        for j, (sx, sz) in enumerate([(0.30, 0.25), (0.35, -0.05), (-0.30, -0.30)]):
            bm = bmesh.new()
            bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.06)
            objs.append(add_bm(f"emblem_{fid}_star_{j}", bm, mats["accent"], col_emblems, loc=(pos_x + sx, 0.08, sz)))
    emblem_objs[fid] = objs

# === Build 4 HQ scenes ===
print("=== Building HQs ===")
hq_objs = {}
for i, (fid, fdata) in enumerate(FACTIONS.items()):
    mats = faction_mats[fid]
    HX, HY = 20 + i * 15, 0
    objs = []
    # Floor
    objs.append(add_bm(f"hq_{fid}_floor", cube(8, 6, 0.1), mat_floor, col_hqs, loc=(HX, HY, 0)))
    # Walls (3-sided room)
    objs.append(add_bm(f"hq_{fid}_wallN", cube(8, 0.2, 4), mats["stone"], col_hqs, loc=(HX, HY + 3, 2)))
    objs.append(add_bm(f"hq_{fid}_wallE", cube(0.2, 6, 4), mats["stone"], col_hqs, loc=(HX + 4, HY, 2)))
    objs.append(add_bm(f"hq_{fid}_wallW", cube(0.2, 6, 4), mats["stone"], col_hqs, loc=(HX - 4, HY, 2)))
    # Faction-themed centerpiece
    if fid == "optimizers":
        # Ordered grid of pillars
        for j in range(6):
            row, col = j // 3, j % 3
            objs.append(add_bm(f"hq_{fid}_pillar_{j}", cyl(0.25, 3.5, 12), mats["primary"], col_hqs,
                               loc=(HX - 1.5 + col*1.5, HY - 1 + row*2, 0)))
            objs.append(add_bm(f"hq_{fid}_pillarcap_{j}", ico(0.30, 2), mats["accent"], col_hqs,
                               loc=(HX - 1.5 + col*1.5, HY - 1 + row*2, 3.7)))
        # Central terminal
        objs.append(add_bm(f"hq_{fid}_terminal", cube(1.0, 0.5, 1.4), mats["metal"], col_hqs, loc=(HX, HY, 0.7)))
        objs.append(add_bm(f"hq_{fid}_screen", cube(0.9, 0.05, 0.6), mats["accent"], col_hqs, loc=(HX, HY - 0.28, 1.4)))
    elif fid == "glitchers":
        # Chaotic angled spires
        for j in range(7):
            ang = (j / 7) * math.tau
            x_off = math.cos(ang) * 2.5
            y_off = math.sin(ang) * 1.8
            tilt = (j % 3) * 0.15 - 0.15
            objs.append(add_bm(f"hq_{fid}_spire_{j}", cone(0.30, 0.05, 3.0 + (j % 4)*0.4),
                               mats["primary"], col_hqs, loc=(HX + x_off, HY + y_off, 0),
                               rot=(tilt, 0, ang*0.3)))
            objs.append(add_bm(f"hq_{fid}_spire_glow_{j}", ico(0.20, 2), mats["accent"], col_hqs,
                               loc=(HX + x_off, HY + y_off, 3.0)))
    elif fid == "archivists":
        # Tall bookshelves on 3 walls
        for wall, (wx, wy, sx, sy) in enumerate([(0, 2.8, 7, 0.3), (3.8, 0, 0.3, 5.5), (-3.8, 0, 0.3, 5.5)]):
            objs.append(add_bm(f"hq_{fid}_shelf_{wall}", cube(sx, sy, 3.0), mats["primary"], col_hqs,
                               loc=(HX + wx, HY + wy, 1.5)))
        # Central reading table with floating tome
        objs.append(add_bm(f"hq_{fid}_table", cyl(1.2, 0.8, 16), mat_wood, col_hqs, loc=(HX, HY, 0.4)))
        objs.append(add_bm(f"hq_{fid}_tome", cube(0.6, 0.4, 0.1), mats["accent"], col_hqs, loc=(HX, HY, 1.4)))
    elif fid == "dreamers":
        # Floating platforms with crystal cores
        for j in range(5):
            x_off = (j - 2) * 1.4
            h = 0.5 + (j % 2) * 0.8
            objs.append(add_bm(f"hq_{fid}_platform_{j}", cyl(0.6, 0.1, 16), mats["primary"], col_hqs,
                               loc=(HX + x_off, HY, h)))
            objs.append(add_bm(f"hq_{fid}_orb_{j}", ico(0.20, 2), mats["accent"], col_hqs,
                               loc=(HX + x_off, HY, h + 0.4)))
        # Central ceiling skylight (glowing disk)
        objs.append(add_bm(f"hq_{fid}_skylight", cyl(1.2, 0.05, 24), mats["accent"], col_hqs,
                           loc=(HX, HY, 3.8)))
    hq_objs[fid] = objs

# === 4 faction-aligned NPCs (humanoid + faction-color cloak) ===
print("=== Faction NPCs ===")
def build_faction_npc(name, mat_primary, mat_accent, x_off, coll):
    add_bm(f"{name}_body", ico(0.40, 2), mat_primary, coll, loc=(x_off, 0, 1.0), scale=(1, 0.8, 1.2))
    add_bm(f"{name}_head", ico(0.32, 2), mat_skin, coll, loc=(x_off, 0, 1.65))
    # Cloak (hanging cone)
    add_bm(f"{name}_cloak", cone(0.45, 0.55, 1.4), mat_primary, coll, loc=(x_off, 0.1, 0.5))
    # Hood
    add_bm(f"{name}_hood", cone(0.34, 0.05, 0.40), mat_primary, coll, loc=(x_off, 0, 1.8))
    # Faction emblem on chest
    add_bm(f"{name}_emblem", ico(0.10, 2), mat_accent, coll, loc=(x_off, -0.32, 1.0))

faction_npc_x = {"optimizers": 80, "glitchers": 84, "archivists": 88, "dreamers": 92}
for fid, x_off in faction_npc_x.items():
    mats = faction_mats[fid]
    build_faction_npc(f"npc_{fid}", mats["primary"], mats["accent"], x_off, col_npcs)

# === 4 faction-aligned enemies ===
print("=== Faction enemies ===")
def build_faction_enemy(name, mat_primary, mat_accent, x_off, coll):
    add_bm(f"{name}_body", ico(0.50, 2), mat_primary, coll, loc=(x_off, 0, 0.9), scale=(1.2, 0.7, 1))
    add_bm(f"{name}_eye_l", ico(0.06, 1), mat_accent, coll, loc=(x_off - 0.20, -0.4, 1.05))
    add_bm(f"{name}_eye_r", ico(0.06, 1), mat_accent, coll, loc=(x_off + 0.20, -0.4, 1.05))
    # 4 spikes on back
    for j, sx in enumerate([-0.25, -0.10, 0.10, 0.25]):
        add_bm(f"{name}_spike_{j}", cone(0.06, 0.0, 0.35), mat_accent, coll,
               loc=(x_off + sx, 0.1, 1.4))
    # 2 legs
    add_bm(f"{name}_leg_l", cyl(0.10, 0.6, 8), mat_primary, coll, loc=(x_off - 0.18, 0, 0))
    add_bm(f"{name}_leg_r", cyl(0.10, 0.6, 8), mat_primary, coll, loc=(x_off + 0.18, 0, 0))

faction_enemy_x = {"optimizers": 80, "glitchers": 84, "archivists": 88, "dreamers": 92}
for fid, x_off in faction_enemy_x.items():
    mats = faction_mats[fid]
    build_faction_enemy(f"enemy_{fid}", mats["dark"], mats["accent"], x_off, col_enemies)
    # Move enemies to a different y row
    for obj in col_enemies.objects:
        if obj.name.startswith(f"enemy_{fid}"):
            obj.location.y += 5

# === Faction war event placeholder scene ===
print("=== Faction war event ===")
WX, WY = 110, 0
add_bm("War_Floor", cube(8, 6, 0.1), mat_grass, col_war, loc=(WX, WY, 0))
# 4 banner posts (one per faction)
for i, (fid, fdata) in enumerate(FACTIONS.items()):
    mats = faction_mats[fid]
    px = WX - 3 + (i * 2)
    add_bm(f"War_Pole_{fid}", cyl(0.05, 3.0, 6), mat_wood, col_war, loc=(px, WY, 1.5))
    add_bm(f"War_Banner_{fid}", cube(0.05, 0.4, 1.0), mats["primary"], col_war, loc=(px + 0.25, WY, 2.4))
    add_bm(f"War_Emblem_{fid}", ico(0.15, 2), mats["accent"], col_war, loc=(px + 0.25, WY - 0.05, 2.4))

# === Rank-up cinematic mesh ===
print("=== Rank-up cinematic ===")
RUX, RUY = 130, 0
add_bm("RU_Pedestal", cyl(1.0, 0.4, 16), mat_floor, col_rankup, loc=(RUX, RUY, 0.2))
add_bm("RU_Hero_Body", ico(0.40, 2), faction_mats["optimizers"]["primary"], col_rankup, loc=(RUX, RUY, 1.5), scale=(1, 0.8, 1.2))
add_bm("RU_Hero_Head", ico(0.32, 2), mat_skin, col_rankup, loc=(RUX, RUY, 2.15))
# 12 light beams radiating up
for i in range(12):
    ang = (i / 12) * math.tau
    add_bm(f"RU_Beam_{i}", cone(0.05, 0.02, 1.5), faction_mats["optimizers"]["accent"], col_rankup,
           loc=(RUX + math.cos(ang)*0.5, RUY + math.sin(ang)*0.5, 3.0),
           rot=(math.radians(15), 0, ang))

# === Cameras + lights ===
def add_camera(name, loc, rot, lens=70):
    cam_data = bpy.data.cameras.new(name)
    cam_data.lens = lens
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cam)
    return cam_obj

emblem_cam = add_camera("Emblem_Cam", (0, -2.5, 0.4), (math.radians(85), 0, 0), 70)

hq_cams = {}
for i, fid in enumerate(FACTIONS.keys()):
    HX = 20 + i * 15
    hq_cams[fid] = add_camera(f"HQ_{fid}_Cam", (HX + 6, -8, 4.5), (math.radians(72), 0, math.radians(35)), 50)

npc_cam = add_camera("NPC_Cam", (86, -4, 1.5), (math.radians(80), 0, 0), 60)
enemy_cam = add_camera("Enemy_Cam", (86, 1, 1.8), (math.radians(80), 0, 0), 60)

# Lights
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 800
key_data.size = 6
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, -3, 5)
key_obj.rotation_euler = (math.radians(45), 0, 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

# Per-HQ key lights
hq_keys = {}
for i, fid in enumerate(FACTIONS.keys()):
    HX = 20 + i * 15
    ld = bpy.data.lights.new(f"HQKey_{fid}", type='AREA')
    ld.energy = 1200
    ld.size = 8
    ld.color = (1.0, 0.95, 0.85)
    obj = bpy.data.objects.new(f"HQKey_{fid}", ld)
    obj.location = (HX, 0, 8)
    obj.rotation_euler = (0, 0, 0)
    scene.collection.objects.link(obj)
    link_to(obj, col_lights)
    hq_keys[fid] = obj

# NPC + enemy fill light
fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 350
fill_data.size = 8
fill_data.color = (0.7, 0.85, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (86, -3, 4)
fill_obj.rotation_euler = (math.radians(50), 0, 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

world = bpy.data.worlds.new("World_Faction")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render emblems (256x256 transparent) ===
print("=== Rendering emblems ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = emblem_cam

# Hide everything else
for col in [col_hqs, col_npcs, col_enemies, col_war, col_rankup]:
    for obj in col.objects:
        obj.hide_render = True
for obj in hq_keys.values():
    obj.hide_render = True
fill_obj.hide_render = True

for fid, objs in emblem_objs.items():
    # Hide all emblems
    for k2, o2 in emblem_objs.items():
        for o in o2:
            o.hide_render = (k2 != fid)
    cx = sum(o.location.x for o in objs) / len(objs)
    emblem_cam.location = (cx, -2.5, 0.0)
    out_path = os.path.join(RENDER_DIR, f"emblem_{fid}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render HQ hero shots (1280x720) ===
print("=== Rendering HQ hero shots ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False

# Hide all emblems
for k2, o2 in emblem_objs.items():
    for o in o2:
        o.hide_render = True

for fid, objs in hq_objs.items():
    # Hide all HQs
    for k2, o2 in hq_objs.items():
        for o in o2:
            o.hide_render = (k2 != fid)
    for kc, k_obj in hq_keys.items():
        k_obj.hide_render = (kc != fid)
    scene.camera = hq_cams[fid]
    out_path = os.path.join(RENDER_DIR, f"hq_{fid}_hero.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render NPC + enemy strip (one shot showing all 4 faction NPCs/enemies) ===
print("=== Rendering NPCs + enemies ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
for k2, o2 in hq_objs.items():
    for o in o2:
        o.hide_render = True
for k_obj in hq_keys.values():
    k_obj.hide_render = True
fill_obj.hide_render = False

# NPCs
for obj in col_npcs.objects:
    obj.hide_render = False
for obj in col_enemies.objects:
    obj.hide_render = True
scene.camera = npc_cam
scene.render.filepath = os.path.join(RENDER_DIR, "faction_npcs_lineup.png")
bpy.ops.render.render(write_still=True)

# Enemies
for obj in col_npcs.objects:
    obj.hide_render = True
for obj in col_enemies.objects:
    obj.hide_render = False
scene.camera = enemy_cam
scene.render.filepath = os.path.join(RENDER_DIR, "faction_enemies_lineup.png")
bpy.ops.render.render(write_still=True)

print("Faction pipeline complete.")
