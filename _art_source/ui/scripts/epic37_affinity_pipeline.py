"""
Epic 37 — NPC Affinity & Relationship Assets Pipeline
========================================================
Builds in one Blender background pass:
  - Task 11: 5 affinity heart icons (Stranger / Friend / Confidant / Bond /
    Soul-Linked) with progressive fill + glow
  - Task 32: Gift wrap visual prop (3 wrap variants)
  - Task 16: Relationship cinematic scene (2 NPCs facing each other with
    blossom particles + warm bloom backdrop)
  - Task 42: 3 hero shots of relationship moments (gift_moment, max_affinity,
    festival_dance)

Saves:
  - _art_source/ui/affinity_assets.blend
  - _art_source/ui/renders/heart_<level>.png            (5 hearts)
  - _art_source/ui/renders/gift_wrap_<variant>.png      (3 variants)
  - _art_source/ui/renders/relationship_gift_moment.png
  - _art_source/ui/renders/relationship_max_affinity.png
  - _art_source/ui/renders/relationship_festival_dance.png
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/affinity_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32

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

# Affinity colors
mat_heart_grey = make_pbr("heart_grey", (0.45, 0.42, 0.42), 0.7)
mat_heart_pink = make_pbr("heart_pink", (0.95, 0.55, 0.65), 0.5, 0.0, (1.0, 0.55, 0.65), 1.0)
mat_heart_red = make_pbr("heart_red", (0.95, 0.20, 0.30), 0.4, 0.0, (1.0, 0.30, 0.35), 2.0)
mat_heart_violet = make_pbr("heart_violet", (0.85, 0.30, 0.95), 0.3, 0.0, (0.95, 0.40, 1.0), 3.0)
mat_heart_gold = make_pbr("heart_gold", (1.0, 0.85, 0.30), 0.2, 0.0, (1.0, 0.95, 0.40), 4.5)
mat_frame = make_pbr("heart_frame", (0.30, 0.30, 0.35), 0.5, 0.7)

# Gift wrap colors
mat_wrap_red = make_pbr("wrap_red", (0.85, 0.20, 0.25), 0.55)
mat_wrap_blue = make_pbr("wrap_blue", (0.20, 0.45, 0.85), 0.55)
mat_wrap_violet = make_pbr("wrap_violet", (0.55, 0.25, 0.85), 0.55)
mat_ribbon_gold = make_pbr("ribbon_gold", (1.0, 0.85, 0.30), 0.3, 0.0, (1.0, 0.85, 0.30), 0.6)

# Cinematic scene materials
mat_floor = make_pbr("rel_floor", (0.65, 0.55, 0.45), 0.75)
mat_skin = make_pbr("rel_skin", (0.85, 0.75, 0.60), 0.7)
mat_npc_blue = make_pbr("rel_npc_blue", (0.25, 0.45, 0.75), 0.5)
mat_npc_red = make_pbr("rel_npc_red", (0.85, 0.25, 0.30), 0.5)
mat_blossom = make_pbr("rel_blossom", (1.0, 0.75, 0.85), 0.5, 0.0, (1.0, 0.75, 0.85), 1.5)
mat_warm_bg = make_pbr("rel_warm_bg", (0.95, 0.55, 0.30), 0.85, 0.0, (1.0, 0.5, 0.25), 0.6)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_hearts = make_coll("Hearts")
col_wraps = make_coll("Gift_Wraps")
col_cinematic = make_coll("Cinematic")
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

def ico(r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    return bm

def cone(r1, r2, h, segs=10):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

# === Build a 3D heart shape ===
def build_heart(material, position, scale=1.0):
    """Build a simple 3D heart from 2 spheres + a triangular bottom."""
    objs = []
    # Two top lobes
    for sx in [-1, 1]:
        bm = ico(0.30 * scale, 2)
        objs.append(add_bm(f"heart_lobe_{sx}", bm, material, col_hearts,
                           loc=(position[0] + sx*0.22*scale, position[1], position[2] + 0.15*scale)))
    # Bottom point (triangular pyramid)
    bm = cone(0.50 * scale, 0.0, 0.55 * scale)
    bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.pi, 3, 'X'), verts=bm.verts)
    objs.append(add_bm("heart_point", bm, material, col_hearts,
                       loc=(position[0], position[1], position[2] - 0.15*scale)))
    return objs

# === 5 affinity hearts ===
print("=== Building 5 affinity hearts ===")
heart_levels = [
    ("stranger", mat_heart_grey, 1.0),
    ("friend", mat_heart_pink, 1.0),
    ("confidant", mat_heart_red, 1.0),
    ("bond", mat_heart_violet, 1.0),
    ("soul_linked", mat_heart_gold, 1.0),
]
heart_objs = {}
for i, (level_id, mat, scale) in enumerate(heart_levels):
    pos = (i * 1.6 - 3.2, 0, 0)
    objs = build_heart(mat, pos, scale)
    # Frame ring around heart for soul_linked + bond (extra polish)
    if level_id in ("bond", "soul_linked"):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=24, radius1=0.55, radius2=0.55, depth=0.04)
        objs.append(add_bm(f"heart_{level_id}_ring", bm, mat_frame, col_hearts,
                           loc=(pos[0], pos[1], pos[2] - 0.05),
                           rot=(math.radians(90), 0, 0)))
        # Sparks around for soul_linked
        if level_id == "soul_linked":
            for j in range(8):
                ang = (j / 8) * math.tau
                bm = ico(0.05, 1)
                objs.append(add_bm(f"heart_{level_id}_spark_{j}", bm, mat_heart_gold, col_hearts,
                                   loc=(pos[0] + math.cos(ang)*0.7, pos[1], pos[2] + math.sin(ang)*0.7)))
    heart_objs[level_id] = objs

# === 3 gift wraps ===
print("=== Building 3 gift wraps ===")
wrap_variants = [
    ("red", mat_wrap_red),
    ("blue", mat_wrap_blue),
    ("violet", mat_wrap_violet),
]
wrap_objs = {}
for i, (variant_id, mat) in enumerate(wrap_variants):
    pos = (10 + i * 2, 0, 0)
    objs = []
    # Box body
    objs.append(add_bm(f"wrap_{variant_id}_box", cube(0.6, 0.6, 0.5), mat, col_wraps, loc=(pos[0], pos[1], pos[2] + 0.25)))
    # Ribbon vertical
    objs.append(add_bm(f"wrap_{variant_id}_ribbon_v", cube(0.10, 0.62, 0.51), mat_ribbon_gold, col_wraps,
                       loc=(pos[0], pos[1], pos[2] + 0.25)))
    # Ribbon horizontal
    objs.append(add_bm(f"wrap_{variant_id}_ribbon_h", cube(0.62, 0.10, 0.51), mat_ribbon_gold, col_wraps,
                       loc=(pos[0], pos[1], pos[2] + 0.25)))
    # Bow on top (4 small spheres)
    for sx, sy in [(-0.12, 0), (0.12, 0), (0, -0.12), (0, 0.12)]:
        objs.append(add_bm(f"wrap_{variant_id}_bow_{sx}_{sy}", ico(0.08, 2), mat_ribbon_gold, col_wraps,
                           loc=(pos[0] + sx, pos[1] + sy, pos[2] + 0.55)))
    wrap_objs[variant_id] = objs

# === Cinematic scene: 2 NPCs facing each other ===
print("=== Building cinematic scene ===")
CX, CY = 30, 0
# Floor
add_bm("Cin_Floor", cube(8, 6, 0.1), mat_floor, col_cinematic, loc=(CX, CY, 0))
# Backdrop wall (warm sunset)
add_bm("Cin_Backdrop", cube(15, 0.1, 8), mat_warm_bg, col_cinematic, loc=(CX, CY + 3, 4))

# NPC A (Globbler-like, blue)
def build_relationship_npc(name_prefix, body_color, x_off, facing_z_rot=0.0):
    add_bm(f"{name_prefix}_body", ico(0.40, 2), body_color, col_cinematic, loc=(CX + x_off, CY, 0.85), scale=(1, 0.8, 1.2))
    add_bm(f"{name_prefix}_head", ico(0.32, 2), mat_skin, col_cinematic, loc=(CX + x_off, CY, 1.55))
    # Arms reaching forward
    add_bm(f"{name_prefix}_arm_l", cyl(0.10, 0.5, 8), body_color, col_cinematic,
           loc=(CX + x_off - 0.40, CY - 0.20, 0.95), rot=(math.radians(-30), 0, 0))
    add_bm(f"{name_prefix}_arm_r", cyl(0.10, 0.5, 8), body_color, col_cinematic,
           loc=(CX + x_off + 0.40, CY - 0.20, 0.95), rot=(math.radians(-30), 0, 0))
    # Legs
    add_bm(f"{name_prefix}_leg_l", cyl(0.13, 0.6, 8), make_pbr(f"{name_prefix}_pants", (0.20, 0.15, 0.10)), col_cinematic, loc=(CX + x_off - 0.18, CY, 0))
    add_bm(f"{name_prefix}_leg_r", cyl(0.13, 0.6, 8), make_pbr(f"{name_prefix}_pants_r", (0.20, 0.15, 0.10)), col_cinematic, loc=(CX + x_off + 0.18, CY, 0))

build_relationship_npc("npc_A", mat_npc_blue, -1.0)
build_relationship_npc("npc_B", mat_npc_red, 1.0)

# Floating blossom particles between them
for i in range(20):
    angle = (i / 20) * math.tau
    radius = 0.6 + (i % 3) * 0.3
    add_bm(f"Cin_Blossom_{i}", ico(0.06, 1), mat_blossom, col_cinematic,
           loc=(CX + math.cos(angle) * radius, CY, 1.5 + (i % 4) * 0.3))

# Glowing heart between them (used for max_affinity shot)
heart_center = build_heart(mat_heart_gold, (CX, CY, 1.8), scale=0.5)
for o in heart_center:
    for c in o.users_collection: c.objects.unlink(o)
    col_cinematic.objects.link(o)

# === Cameras + lights ===
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 70
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

hero_cam_data = bpy.data.cameras.new("Hero_Cam")
hero_cam_data.lens = 50
hero_cam = bpy.data.objects.new("Hero_Cam", hero_cam_data)
hero_cam.rotation_euler = (math.radians(75), 0, 0)
scene.collection.objects.link(hero_cam)
link_to(hero_cam, col_cam)

# Lights
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 600
key_data.size = 5
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.rotation_euler = (math.radians(45), math.radians(-25), 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 200
fill_data.size = 6
fill_data.color = (1.0, 0.65, 0.5)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.rotation_euler = (math.radians(60), math.radians(40), 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

# Hero key for cinematic shots (warm sunset)
hero_key_data = bpy.data.lights.new("HeroKey", type='AREA')
hero_key_data.energy = 1500
hero_key_data.size = 8
hero_key_data.color = (1.0, 0.75, 0.55)
hero_key_obj = bpy.data.objects.new("HeroKey", hero_key_data)
hero_key_obj.location = (CX - 6, CY - 2, 5)
hero_key_obj.rotation_euler = (math.radians(55), math.radians(-25), 0)
scene.collection.objects.link(hero_key_obj)
link_to(hero_key_obj, col_lights)

world = bpy.data.worlds.new("World_Affinity")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.05, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# === Render heart icons ===
print("=== Rendering heart icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

# Hide everything except hearts
for col in [col_wraps, col_cinematic]:
    for obj in col.objects:
        obj.hide_render = True
hero_key_obj.hide_render = True

for level_id, objs in heart_objs.items():
    for k2, o2 in heart_objs.items():
        for o in o2:
            o.hide_render = (k2 != level_id)
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    cz = sum(o.location.z for o in objs) / len(objs)
    icon_cam.location = (cx, cy - 1.8, cz + 0.2)
    icon_cam.rotation_euler = (math.radians(85), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"heart_{level_id}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render gift wraps ===
print("=== Rendering gift wraps ===")
for k2, o2 in heart_objs.items():
    for o in o2:
        o.hide_render = True

for variant_id, objs in wrap_objs.items():
    for k2, o2 in wrap_objs.items():
        for o in o2:
            o.hide_render = (k2 != variant_id)
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    icon_cam.location = (cx, cy - 1.8, 1.4)
    icon_cam.rotation_euler = (math.radians(75), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"gift_wrap_{variant_id}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render 3 hero relationship moments ===
print("=== Rendering relationship hero shots ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False
scene.camera = hero_cam

# Hide all wraps
for k2, o2 in wrap_objs.items():
    for o in o2:
        o.hide_render = True
# Show cinematic
for obj in col_cinematic.objects:
    obj.hide_render = False
hero_key_obj.hide_render = False

# Shot 1: gift_moment — wide framing of both NPCs with blossoms
hero_cam.location = (CX, CY - 7, 2.5)
hero_cam.rotation_euler = (math.radians(78), 0, 0)
scene.render.filepath = os.path.join(RENDER_DIR, "relationship_gift_moment.png")
bpy.ops.render.render(write_still=True)

# Shot 2: max_affinity — close on both NPCs with golden heart between
hero_cam.location = (CX, CY - 4.5, 1.8)
hero_cam.rotation_euler = (math.radians(82), 0, 0)
scene.render.filepath = os.path.join(RENDER_DIR, "relationship_max_affinity.png")
bpy.ops.render.render(write_still=True)

# Shot 3: festival_dance — slight angle, 3/4 view with bigger framing
hero_cam.location = (CX - 4, CY - 6, 3.0)
hero_cam.rotation_euler = (math.radians(80), 0, math.radians(20))
scene.render.filepath = os.path.join(RENDER_DIR, "relationship_festival_dance.png")
bpy.ops.render.render(write_still=True)

print("Affinity pipeline complete.")
