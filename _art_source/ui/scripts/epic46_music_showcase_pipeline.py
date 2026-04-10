"""
Epic 46 — Music Showcase Pipeline
====================================
Renders 4 frames of an audio visualizer scene representing the soundtrack:
  - 12 vertical equalizer bars at varying heights
  - Glowing waveform line behind
  - Music note glyph in the center
  - Faction-style accent ring around the whole composition

Output: 4 showcase frames at 1280x720 representing different soundtrack moods
(town / wilderness / boss / final).
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/music_showcase.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.render.resolution_x = 1280
scene.render.resolution_y = 720

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

# 4 mood palettes
MOODS = {
    "town": {"primary": (1.0, 0.85, 0.45), "accent": (1.0, 0.95, 0.65), "glow": 3.5},
    "wilderness": {"primary": (0.40, 0.85, 0.55), "accent": (0.65, 1.0, 0.75), "glow": 3.0},
    "boss": {"primary": (1.0, 0.30, 0.30), "accent": (1.0, 0.55, 0.30), "glow": 4.5},
    "final": {"primary": (0.55, 0.20, 0.95), "accent": (0.85, 0.45, 1.0), "glow": 5.0},
}
mood_mats = {}
for mid, m in MOODS.items():
    mood_mats[mid] = {
        "primary": make_pbr(f"vis_{mid}_primary", m["primary"], 0.3, 0.0, m["primary"], m["glow"]),
        "accent": make_pbr(f"vis_{mid}_accent", m["accent"], 0.3, 0.0, m["accent"], m["glow"] + 1),
        "frame": make_pbr(f"vis_{mid}_frame", (0.10, 0.10, 0.15), 0.4, 0.7),
        "dark": make_pbr(f"vis_{mid}_dark", (0.05, 0.05, 0.10), 0.7),
    }

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_visualizers = make_coll("Music_Visualizers")
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

def add_torus(name, mat, coll, loc, major=0.7, minor=0.05):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=32, radius=major, cap_ends=False)
    bm.verts.ensure_lookup_table()
    inner = bm.verts[:]
    bmesh.ops.create_circle(bm, segments=32, radius=major - minor*2, cap_ends=False)
    bm.verts.ensure_lookup_table()
    outer = bm.verts[32:64]
    for j in range(32):
        bm.faces.new([inner[j], inner[(j+1)%32], outer[(j+1)%32], outer[j]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_bm(name, bm, mat, coll, loc=loc, rot=(math.radians(90), 0, 0))

# === Build 4 visualizers (one per mood) ===
print("=== Building 4 mood visualizers ===")
mood_objs = {}
for i, (mid, _) in enumerate(MOODS.items()):
    mats = mood_mats[mid]
    pos_x = (i - 1.5) * 12
    objs = []
    # Backplate (large dark disc)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=32, radius1=4.5, radius2=4.5, depth=0.1)
    objs.append(add_bm(f"vis_{mid}_backplate", bm, mats["dark"], col_visualizers,
                       loc=(pos_x, 0, 0)))
    # Frame ring
    add_torus(f"vis_{mid}_frame_ring", mats["primary"], col_visualizers,
              (pos_x, 0.05, 0), major=4.5, minor=0.10)

    # 12 EQ bars (varying heights for each mood)
    bar_heights_by_mood = {
        "town": [0.6, 0.9, 1.2, 0.8, 1.5, 1.1, 1.4, 0.7, 1.3, 0.9, 1.0, 0.6],
        "wilderness": [0.4, 0.7, 1.1, 1.5, 1.8, 1.6, 1.2, 0.9, 0.6, 0.8, 1.1, 0.7],
        "boss": [1.5, 2.2, 1.8, 2.5, 1.9, 2.8, 2.4, 2.0, 2.6, 1.7, 2.3, 1.6],
        "final": [2.0, 2.8, 2.5, 3.2, 2.9, 3.5, 3.0, 3.3, 2.7, 3.1, 2.8, 2.4],
    }
    bar_heights = bar_heights_by_mood[mid]
    for j in range(12):
        bx = pos_x - 3.3 + j * 0.6
        bar_h = bar_heights[j]
        bm = cube(0.20, 0.05, bar_h)
        objs.append(add_bm(f"vis_{mid}_bar_{j}", bm, mats["accent"], col_visualizers,
                           loc=(bx, 0.10, -2 + bar_h/2)))

    # Central music note glyph (sphere head + stem + flag)
    objs.append(add_bm(f"vis_{mid}_note_head", ico(0.30, 2), mats["primary"], col_visualizers,
                       loc=(pos_x, 0.20, 1.2)))
    bm = cube(0.06, 0.06, 0.80)
    objs.append(add_bm(f"vis_{mid}_note_stem", bm, mats["primary"], col_visualizers,
                       loc=(pos_x + 0.20, 0.20, 1.6)))
    bm = cube(0.20, 0.06, 0.10)
    objs.append(add_bm(f"vis_{mid}_note_flag", bm, mats["primary"], col_visualizers,
                       loc=(pos_x + 0.30, 0.20, 1.95)))

    # Mood label (would be text — using a small sub-frame)
    bm = cube(2.5, 0.05, 0.4)
    objs.append(add_bm(f"vis_{mid}_label_bg", bm, mats["frame"], col_visualizers,
                       loc=(pos_x, 0.15, -3.5)))
    bm = cube(2.4, 0.05, 0.30)
    objs.append(add_bm(f"vis_{mid}_label_fg", bm, mats["accent"], col_visualizers,
                       loc=(pos_x, 0.20, -3.5)))

    mood_objs[mid] = objs

# === Camera ===
cam_data = bpy.data.cameras.new("Show_Cam")
cam_data.lens = 50
cam_obj = bpy.data.objects.new("Show_Cam", cam_data)
cam_obj.location = (0, -16, 1)
cam_obj.rotation_euler = (math.radians(85), 0, 0)
scene.collection.objects.link(cam_obj)
link_to(cam_obj, col_cam)

# Per-mood camera (for individual frames)
mood_cams = {}
for i, mid in enumerate(MOODS.keys()):
    pos_x = (i - 1.5) * 12
    mc = bpy.data.cameras.new(f"Cam_{mid}")
    mc.lens = 50
    mc_obj = bpy.data.objects.new(f"Cam_{mid}", mc)
    mc_obj.location = (pos_x, -8, 1)
    mc_obj.rotation_euler = (math.radians(85), 0, 0)
    scene.collection.objects.link(mc_obj)
    link_to(mc_obj, col_cam)
    mood_cams[mid] = mc_obj

# === Lights ===
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 600
key_data.size = 12
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, -8, 8)
key_obj.rotation_euler = (math.radians(45), 0, 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

world = bpy.data.worlds.new("World_Music")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.02, 0.02, 0.05, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render 4 mood frames ===
print("=== Rendering 4 mood frames ===")
for mid in mood_objs.keys():
    # Hide all other moods
    for k2, o2 in mood_objs.items():
        for o in o2:
            o.hide_render = (k2 != mid)
    scene.camera = mood_cams[mid]
    out_path = os.path.join(RENDER_DIR, f"music_visualizer_{mid}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# Render group shot
for mid, o2 in mood_objs.items():
    for o in o2:
        o.hide_render = False
scene.camera = cam_obj
scene.render.filepath = os.path.join(RENDER_DIR, "music_visualizer_group.png")
bpy.ops.render.render(write_still=True)

print("Music showcase pipeline complete.")
