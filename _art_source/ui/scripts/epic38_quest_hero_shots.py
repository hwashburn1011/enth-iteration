"""
Epic 38 — Quest System Hero Shots Pipeline
=============================================
Renders 4 hero shots illustrating the quest system in action:
  - quest_log_open.png: open journal panel mockup with parchment + scroll
  - quest_objective_marker.png: glowing exclamation mark in a wilderness scene
  - quest_complete_celebration.png: gold burst over a hero standing
  - quest_hidden_reveal.png: violet glyph appearing on a stone

Saves:
  - _art_source/ui/quest_hero_assets.blend
  - _art_source/ui/renders/quest_log_open.png
  - _art_source/ui/renders/quest_objective_marker.png
  - _art_source/ui/renders/quest_complete_celebration.png
  - _art_source/ui/renders/quest_hidden_reveal.png
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/quest_hero_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.render.resolution_x = 1280
scene.render.resolution_y = 720

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

# Materials
mat_parchment = make_pbr("q_parchment", (0.88, 0.78, 0.58), 0.95)
mat_parchment_dark = make_pbr("q_parchment_dark", (0.65, 0.48, 0.25), 0.9)
mat_ink = make_pbr("q_ink", (0.15, 0.08, 0.04), 0.85)
mat_brass = make_pbr("q_brass", (0.72, 0.55, 0.20), 0.3, 0.95)
mat_grass = make_pbr("q_grass", (0.18, 0.32, 0.12), 0.85)
mat_stone = make_pbr("q_stone", (0.45, 0.42, 0.38), 0.85)
mat_glow_gold = make_pbr("q_glow_gold", (1.0, 0.85, 0.30), 0.3, 0.0, (1.0, 0.85, 0.30), 5.0)
mat_glow_violet = make_pbr("q_glow_violet", (0.75, 0.40, 1.0), 0.3, 0.0, (0.7, 0.4, 1.0), 5.0)
mat_glow_red = make_pbr("q_glow_red", (1.0, 0.30, 0.20), 0.3, 0.0, (1.0, 0.3, 0.2), 4.0)
mat_npc_blue = make_pbr("q_npc_blue", (0.25, 0.45, 0.75), 0.5)
mat_skin = make_pbr("q_skin", (0.85, 0.75, 0.60), 0.7)
mat_wood = make_pbr("q_wood", (0.40, 0.22, 0.10), 0.85)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_log = make_coll("Quest_Log")
col_marker = make_coll("Quest_Marker")
col_celebration = make_coll("Celebration")
col_reveal = make_coll("Hidden_Reveal")
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

# === Scene 1: Quest log open (parchment + scrolls) ===
print("=== Quest log scene ===")
LX, LY = 0, 0
# Hex parchment base
bm = bmesh.new()
bmesh.ops.create_circle(bm, segments=24, radius=4.0, cap_ends=True, cap_tris=True)
add_bm("Log_Parchment", bm, mat_parchment, col_log, loc=(LX, LY, 0))
# Dark edge ring
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=4.05, radius2=3.9, depth=0.05)
add_bm("Log_Edge", bm, mat_parchment_dark, col_log, loc=(LX, LY, 0.025))
# Ink lines (simulated text rows)
for i in range(6):
    add_bm(f"Log_Line_{i}", cube(2.5, 0.06, 0.02), mat_ink, col_log, loc=(LX, LY - 1.5 + i * 0.4, 0.06))
# Quill on top
add_bm("Log_Quill_Shaft", cyl(0.04, 1.2, 6), mat_wood, col_log, loc=(LX + 1.5, LY + 0.5, 0.06),
       rot=(math.radians(80), 0, math.radians(35)))
add_bm("Log_Quill_Tip", cone(0.05, 0.0, 0.18), mat_brass, col_log, loc=(LX + 0.6, LY + 1.4, 0.1))
# Wax seal
add_bm("Log_Seal", cyl(0.18, 0.04, 16), mat_glow_red, col_log, loc=(LX - 1.8, LY + 1.5, 0.07))

# === Scene 2: Quest objective marker (wilderness with glowing exclamation) ===
print("=== Objective marker scene ===")
MX, MY = 20, 0
# Grass field
add_bm("Mk_Floor", cube(8, 6, 0.1), mat_grass, col_marker, loc=(MX, MY, 0))
# Bushes around (icospheres)
for i in range(6):
    ang = (i / 6) * math.tau
    add_bm(f"Mk_Bush_{i}", ico(0.5, 2), mat_grass, col_marker,
           loc=(MX + math.cos(ang)*3, MY + math.sin(ang)*2, 0.4))
# Path stones
for i in range(4):
    add_bm(f"Mk_Stone_{i}", cube(0.4, 0.4, 0.05), mat_stone, col_marker,
           loc=(MX - 1.5 + i*1, MY, 0.05))
# Pedestal under exclamation mark
add_bm("Mk_Pedestal", cyl(0.5, 0.3, 12), mat_stone, col_marker, loc=(MX, MY, 0.15))
# Exclamation mark (rectangle + sphere dot)
add_bm("Mk_Excl_Bar", cube(0.15, 0.15, 0.7), mat_glow_gold, col_marker, loc=(MX, MY, 0.85))
add_bm("Mk_Excl_Dot", ico(0.18, 2), mat_glow_gold, col_marker, loc=(MX, MY, 1.40))
# Glow ring at base
add_bm("Mk_Ring", cyl(0.7, 0.04, 24), mat_glow_gold, col_marker, loc=(MX, MY, 0.32))

# === Scene 3: Quest complete celebration (gold burst over hero) ===
print("=== Celebration scene ===")
CX, CY = 40, 0
# Floor
add_bm("Cel_Floor", cube(6, 5, 0.1), mat_grass, col_celebration, loc=(CX, CY, 0))
# Hero figure
add_bm("Cel_HeroBody", ico(0.40, 2), mat_npc_blue, col_celebration, loc=(CX, CY, 0.85), scale=(1, 0.8, 1.2))
add_bm("Cel_HeroHead", ico(0.32, 2), mat_skin, col_celebration, loc=(CX, CY, 1.55))
add_bm("Cel_HeroArmL", cyl(0.10, 0.6, 8), mat_npc_blue, col_celebration, loc=(CX - 0.4, CY, 1.0),
       rot=(0, 0, math.radians(40)))
add_bm("Cel_HeroArmR", cyl(0.10, 0.6, 8), mat_npc_blue, col_celebration, loc=(CX + 0.4, CY, 1.0),
       rot=(0, 0, math.radians(-40)))
add_bm("Cel_HeroLegL", cyl(0.13, 0.6, 8), mat_wood, col_celebration, loc=(CX - 0.18, CY, 0))
add_bm("Cel_HeroLegR", cyl(0.13, 0.6, 8), mat_wood, col_celebration, loc=(CX + 0.18, CY, 0))
# Gold burst above (16 radial spheres)
for i in range(16):
    ang = (i / 16) * math.tau
    r = 1.0 + (i % 3) * 0.2
    h = 2.0 + math.sin(ang * 2) * 0.3
    add_bm(f"Cel_Spark_{i}", ico(0.10 + (i % 3) * 0.04, 1), mat_glow_gold, col_celebration,
           loc=(CX + math.cos(ang)*r, CY + math.sin(ang)*r, h))
# Big golden burst sphere at apex
add_bm("Cel_Apex", ico(0.30, 2), mat_glow_gold, col_celebration, loc=(CX, CY, 2.4))

# === Scene 4: Hidden quest reveal (violet glyph on stone) ===
print("=== Hidden reveal scene ===")
RX, RY = 60, 0
# Stone background slab
add_bm("Rev_Stone", cube(3, 0.3, 4), mat_stone, col_reveal, loc=(RX, RY, 2))
# Violet glyph (square + cross)
add_bm("Rev_Glyph_Sq", cube(0.8, 0.05, 0.8), mat_glow_violet, col_reveal, loc=(RX, RY - 0.18, 2))
add_bm("Rev_Glyph_Bar1", cube(0.05, 0.05, 1.2), mat_glow_violet, col_reveal, loc=(RX, RY - 0.20, 2))
add_bm("Rev_Glyph_Bar2", cube(1.2, 0.05, 0.05), mat_glow_violet, col_reveal, loc=(RX, RY - 0.20, 2))
# Glow particles around
for i in range(12):
    ang = (i / 12) * math.tau
    add_bm(f"Rev_Spark_{i}", ico(0.06, 1), mat_glow_violet, col_reveal,
           loc=(RX + math.cos(ang)*1.4, RY - 0.25, 2 + math.sin(ang)*1.4))

# === Cameras + lights ===
def add_camera(name, loc, rot, lens=50):
    cam_data = bpy.data.cameras.new(name)
    cam_data.lens = lens
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cam)
    return cam_obj

# Top-down for log
log_cam = add_camera("Log_Cam", (LX, LY, 8), (0, 0, 0), lens=50)
mk_cam = add_camera("Marker_Cam", (MX, MY - 7, 3), (math.radians(72), 0, 0), lens=50)
cel_cam = add_camera("Celebration_Cam", (CX, CY - 7, 2.5), (math.radians(78), 0, 0), lens=50)
rev_cam = add_camera("Reveal_Cam", (RX, RY - 4, 2), (math.radians(85), 0, 0), lens=50)

# Lights — one per scene
def add_area_light(name, loc, color, energy, size, coll):
    ld = bpy.data.lights.new(name, type='AREA')
    ld.energy = energy
    ld.size = size
    ld.color = color
    obj = bpy.data.objects.new(name, ld)
    obj.location = loc
    obj.rotation_euler = (math.radians(45), 0, 0)
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

log_key = add_area_light("Log_Key", (LX, LY - 2, 6), (1.0, 0.95, 0.85), 1500, 8, col_lights)
mk_key = add_area_light("Marker_Key", (MX, MY - 4, 6), (1.0, 0.95, 0.85), 1500, 8, col_lights)
cel_key = add_area_light("Cel_Key", (CX, CY - 4, 6), (1.0, 0.95, 0.85), 1500, 8, col_lights)
rev_key = add_area_light("Rev_Key", (RX, RY - 3, 5), (0.85, 0.7, 1.0), 1200, 6, col_lights)

world = bpy.data.worlds.new("World_Quest")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render 4 hero shots ===
all_colls = [col_log, col_marker, col_celebration, col_reveal]
all_keys = [log_key, mk_key, cel_key, rev_key]
all_cams = [log_cam, mk_cam, cel_cam, rev_cam]
out_names = ["quest_log_open", "quest_objective_marker", "quest_complete_celebration", "quest_hidden_reveal"]

for i, (col, key, cam, name) in enumerate(zip(all_colls, all_keys, all_cams, out_names)):
    # Hide all other scene cols
    for j, other_col in enumerate(all_colls):
        for obj in other_col.objects:
            obj.hide_render = (j != i)
    for j, other_key in enumerate(all_keys):
        other_key.hide_render = (j != i)
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"{name}.png")
    print(f"Rendering {name}")
    bpy.ops.render.render(write_still=True)

print("Quest hero shots pipeline complete.")
