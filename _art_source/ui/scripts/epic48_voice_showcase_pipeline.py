"""
Epic 48 — Voice Showcase Pipeline
====================================
Renders 14 character voice cards (Globbler + Sage + 12 NPCs) showing
their pitch range as a vertical bar height + character avatar silhouette.
Plus a group hero shot showing all 14 cards.
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/voice_showcase.blend"
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

# 14 characters, each with their own color + pitch offset (semitones)
CHARACTERS = [
    ("globbler",  (0.30, 0.55, 0.95),  0),   # neutral
    ("ai_sage",   (0.85, 0.65, 0.20), -3),   # warm low
    ("pixel",     (1.0, 0.85, 0.30),  4),    # bright high
    ("forge",     (0.85, 0.45, 0.20), -4),   # gruff low
    ("cache",     (0.95, 0.55, 0.65),  2),   # warm
    ("index",     (0.45, 0.65, 0.85),  1),   # calm
    ("harvest",   (0.55, 0.85, 0.30), -1),   # earthy
    ("bit",       (1.0, 0.55, 0.95),  7),    # child high
    ("legacy",    (0.55, 0.45, 0.30), -5),   # elder low
    ("trade",     (0.85, 0.65, 0.20), -2),   # smooth
    ("lab",       (0.30, 0.95, 0.55),  3),   # excited
    ("render",    (0.85, 0.55, 0.95),  1),   # dreamy
    ("sync",      (0.55, 0.85, 0.95),  2),   # musical
    ("sentinel",  (0.55, 0.55, 0.65), -6),   # gruff military
]

mat_inner = make_pbr("v_inner", (0.05, 0.05, 0.10), 0.7)
mat_frame = make_pbr("v_frame", (0.20, 0.20, 0.30), 0.4, 0.7)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_cards = make_coll("Voice_Cards")
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

def ico(r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    return bm

# === Build 14 voice cards in a 7x2 grid ===
print("=== Building 14 voice cards ===")
card_objs = {}
for i, (char_name, color, pitch_offset) in enumerate(CHARACTERS):
    col_x = i % 7
    row_y = i // 7
    pos_x = (col_x - 3) * 1.6
    pos_y = (row_y - 0.5) * 2.4
    accent_mat = make_pbr(f"v_{char_name}_accent", color, 0.3, 0.0, color, 3.0)
    objs = []
    # Card backing
    bm = cube(0.7, 0.04, 1.0)
    objs.append(add_bm(f"v_{char_name}_back", bm, mat_inner, col_cards,
                       loc=(pos_x, pos_y, 0)))
    # Frame ring (top + bottom + sides)
    for sx, sz, fx, fz in [(0, 0.52, 0.7, 0.04), (0, -0.52, 0.7, 0.04),
                            (-0.34, 0, 0.04, 1.0), (0.34, 0, 0.04, 1.0)]:
        bm = cube(fx, 0.05, fz)
        objs.append(add_bm(f"v_{char_name}_frame_{sx}_{sz}", bm, accent_mat, col_cards,
                           loc=(pos_x + sx, pos_y, sz)))
    # Avatar head silhouette (icosphere)
    objs.append(add_bm(f"v_{char_name}_avatar", ico(0.20, 2), accent_mat, col_cards,
                       loc=(pos_x, pos_y - 0.06, 0.30)))
    # Pitch bar — height varies with pitch_offset
    bar_height = 0.40 + (pitch_offset / 12.0) * 0.30
    bm = cube(0.05, 0.05, bar_height)
    objs.append(add_bm(f"v_{char_name}_pitch_bar", bm, accent_mat, col_cards,
                       loc=(pos_x, pos_y - 0.06, -0.20 + bar_height/2)))
    card_objs[char_name] = objs

# === Camera ===
cam_data = bpy.data.cameras.new("Show_Cam")
cam_data.lens = 35
cam_obj = bpy.data.objects.new("Show_Cam", cam_data)
cam_obj.location = (0, -10, 0.5)
cam_obj.rotation_euler = (math.radians(85), 0, 0)
scene.collection.objects.link(cam_obj)
link_to(cam_obj, col_cam)

# === Lights ===
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 600
key_data.size = 12
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, -5, 6)
key_obj.rotation_euler = (math.radians(45), 0, 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 300
fill_data.size = 10
fill_data.color = (0.65, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (0, 4, 4)
fill_obj.rotation_euler = (math.radians(110), 0, 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

world = bpy.data.worlds.new("World_V")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.02, 0.02, 0.05, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render group showcase ===
print("=== Rendering voice showcase ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.camera = cam_obj
scene.render.filepath = os.path.join(RENDER_DIR, "voice_showcase_group.png")
bpy.ops.render.render(write_still=True)

print("Voice showcase pipeline complete.")
