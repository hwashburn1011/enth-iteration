"""
Epic 36 — Town Building & Decoration Pipeline
================================================
Builds in one Blender background pass:
  - Tasks 11-14: 50 decoration meshes (15 small + 15 medium + 10 large + 10 interactive)
  - Task 10: 50 decoration icon renders (256x256 PNGs)
  - Task 9: Plot purchase NPC mesh
  - Task 21: Decor shop NPC mesh
  - Task 40: Decor showcase NPC mesh
  - Task 24: Seasonal decor variant materials
  - Task 33: Lighting placement props (5 lamp variants)
  - Task 34: Ambient effect placeholder meshes (smoke, fire, water)
  - Task 41: Decor showcase area scene
  - Task 42: Hero shot render of decorated home

Saves:
  - _art_source/decor/decor_assets.blend
  - _art_source/decor/renders/decor_<id>.png   (50)
  - _art_source/decor/renders/npc_plot.png
  - _art_source/decor/renders/npc_shop.png
  - _art_source/decor/renders/npc_showcase.png
  - _art_source/decor/renders/showcase_area.png
  - _art_source/decor/renders/decorated_home_hero.png
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, Matrix

random.seed(3636)
OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/decor/decor_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/decor/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 24
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

# Materials
mat_wood = make_pbr("dec_wood", (0.42, 0.24, 0.10), 0.85)
mat_wood_dark = make_pbr("dec_wood_dark", (0.20, 0.12, 0.06), 0.85)
mat_wood_light = make_pbr("dec_wood_light", (0.65, 0.45, 0.22), 0.85)
mat_metal = make_pbr("dec_metal", (0.55, 0.55, 0.60), 0.3, 0.95)
mat_brass = make_pbr("dec_brass", (0.72, 0.55, 0.20), 0.3, 0.95)
mat_iron = make_pbr("dec_iron", (0.30, 0.30, 0.32), 0.4, 0.85)
mat_stone = make_pbr("dec_stone", (0.45, 0.42, 0.38), 0.85)
mat_marble = make_pbr("dec_marble", (0.85, 0.83, 0.80), 0.4)
mat_clay = make_pbr("dec_clay", (0.65, 0.40, 0.25), 0.85)
mat_fabric_red = make_pbr("dec_fabric_red", (0.65, 0.18, 0.18), 0.85)
mat_fabric_blue = make_pbr("dec_fabric_blue", (0.18, 0.35, 0.65), 0.85)
mat_fabric_green = make_pbr("dec_fabric_green", (0.18, 0.55, 0.30), 0.85)
mat_fabric_purple = make_pbr("dec_fabric_purple", (0.45, 0.20, 0.65), 0.85)
mat_fabric_gold = make_pbr("dec_fabric_gold", (0.85, 0.65, 0.20), 0.6)
mat_glass = make_pbr("dec_glass", (0.85, 0.92, 1.0), 0.05, 0.0)
mat_water = make_pbr("dec_water", (0.10, 0.25, 0.40), 0.15, 0.0, (0.2, 0.4, 0.6), 0.4)
mat_glow_warm = make_pbr("dec_glow_warm", (1.0, 0.85, 0.45), 0.4, 0.0, (1.0, 0.85, 0.45), 4.0)
mat_glow_cool = make_pbr("dec_glow_cool", (0.50, 0.78, 1.0), 0.4, 0.0, (0.4, 0.7, 1.0), 3.5)
mat_glow_violet = make_pbr("dec_glow_violet", (0.75, 0.40, 1.0), 0.4, 0.0, (0.7, 0.4, 1.0), 4.5)
mat_glow_red = make_pbr("dec_glow_red", (1.0, 0.30, 0.20), 0.4, 0.0, (1.0, 0.3, 0.2), 4.0)
mat_smoke = make_pbr("dec_smoke", (0.78, 0.80, 0.82), 0.95)
mat_grass = make_pbr("dec_grass", (0.18, 0.32, 0.12), 0.85)
mat_dirt = make_pbr("dec_dirt", (0.28, 0.20, 0.13), 0.92)
mat_skin = make_pbr("dec_skin", (0.85, 0.75, 0.60), 0.7)
mat_compiler_blue = make_pbr("dec_npc_blue", (0.25, 0.45, 0.75), 0.6)
mat_npc_red = make_pbr("dec_npc_red", (0.70, 0.20, 0.25), 0.6)
mat_npc_green = make_pbr("dec_npc_green", (0.20, 0.55, 0.30), 0.6)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_decor = make_coll("Decor")
col_npcs = make_coll("NPCs")
col_lights_props = make_coll("LightingProps")
col_ambient = make_coll("AmbientProps")
col_showcase = make_coll("ShowcaseArea")
col_home = make_coll("DecoratedHome")
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

# === Helper: build a multi-mesh group at a location, return list of objs ===
def add_group(name, parts, position):
    """parts is a list of (sub_name, build_callable, material) tuples.
    Each build callable returns a bmesh, plus optional (offset_vec, rot_euler).
    Returns list of the created objects."""
    objs = []
    for i, part in enumerate(parts):
        if len(part) == 3:
            sub, builder, mat = part
            offset = Vector((0, 0, 0))
            rot = (0, 0, 0)
        elif len(part) == 4:
            sub, builder, mat, offset = part
            rot = (0, 0, 0)
        else:
            sub, builder, mat, offset, rot = part
        bm = builder()
        loc = (position[0] + offset[0], position[1] + offset[1], position[2] + offset[2])
        objs.append(add_bm(f"{name}_{sub}", bm, mat, col_decor, loc=loc, rot=rot))
    return objs

# === 50 decor recipes ===
all_decor_groups = {}  # decor_id → list of objects

def grid_pos(idx, cols=10, spacing=2.0, x_off=-9.0, y_off=-5.0):
    col = idx % cols
    row = idx // cols
    return (x_off + col * spacing, y_off + row * spacing, 0)

# === SMALL DECOR (15) ===
small_recipes = [
    ("flower_pot", lambda: [
        ("pot", lambda: cyl(0.18, 0.25, 12), mat_clay, (0,0,0.125)),
        ("soil", lambda: cyl(0.16, 0.04, 12), mat_dirt, (0,0,0.27)),
        ("flower", lambda: ico(0.10, 2), mat_npc_red, (0,0,0.40)),
    ]),
    ("candle", lambda: [
        ("base", lambda: cyl(0.07, 0.20, 8), mat_brass, (0,0,0.10)),
        ("wax", lambda: cyl(0.05, 0.30, 8), make_pbr("c_wax", (0.95, 0.92, 0.85)), (0,0,0.35)),
        ("flame", lambda: ico(0.04, 1), mat_glow_warm, (0,0,0.55)),
    ]),
    ("incense", lambda: [
        ("holder", lambda: cyl(0.10, 0.05, 12), mat_brass, (0,0,0.025)),
        ("stick", lambda: cyl(0.01, 0.35, 6), mat_wood_dark, (0,0,0.18)),
        ("smoke_tip", lambda: ico(0.04, 1), mat_smoke, (0,0,0.36)),
    ]),
    ("teacup", lambda: [
        ("saucer", lambda: cyl(0.10, 0.02, 12), mat_marble, (0,0,0.01)),
        ("cup", lambda: cyl(0.06, 0.08, 12), mat_marble, (0,0,0.06)),
    ]),
    ("snowglobe", lambda: [
        ("base", lambda: cyl(0.10, 0.05, 12), mat_wood, (0,0,0.025)),
        ("globe", lambda: ico(0.10, 2), mat_glass, (0,0,0.15)),
    ]),
    ("mini_cactus", lambda: [
        ("pot", lambda: cyl(0.08, 0.10, 8), mat_clay, (0,0,0.05)),
        ("body", lambda: cyl(0.06, 0.20, 8), mat_npc_green, (0,0,0.20)),
    ]),
    ("hourglass", lambda: [
        ("frame_top", lambda: cyl(0.08, 0.02, 8), mat_wood_dark, (0,0,0.21)),
        ("glass_top", lambda: cone(0.07, 0.02, 0.10), mat_glass, (0,0,0.10)),
        ("glass_bot", lambda: cone(0.07, 0.02, 0.10), mat_glass, (0,0,0.10), (math.pi, 0, 0)),
        ("frame_bot", lambda: cyl(0.08, 0.02, 8), mat_wood_dark, (0,0,0.01)),
    ]),
    ("globe_chess", lambda: [
        ("base", lambda: cyl(0.12, 0.04, 12), mat_wood_dark, (0,0,0.02)),
        ("globe", lambda: ico(0.10, 2), mat_compiler_blue, (0,0,0.15)),
    ]),
    ("scroll", lambda: [
        ("scroll", lambda: cyl(0.05, 0.30, 8), make_pbr("scroll_p", (0.95, 0.85, 0.65)), (0,0,0.025), (0, math.radians(90), 0)),
    ]),
    ("ink_pot", lambda: [
        ("pot", lambda: cyl(0.07, 0.10, 12), mat_iron, (0,0,0.05)),
        ("ink", lambda: cyl(0.06, 0.02, 12), mat_compiler_blue, (0,0,0.11)),
        ("quill", lambda: cyl(0.01, 0.15, 6), mat_wood_dark, (0,0,0.18), (math.radians(15), 0, 0)),
    ]),
    ("seashell", lambda: [
        ("shell", lambda: ico(0.10, 2), make_pbr("shell_m", (0.95, 0.78, 0.65)), (0,0,0.05)),
    ]),
    ("bell", lambda: [
        ("base", lambda: cyl(0.10, 0.02, 12), mat_wood_dark, (0,0,0.01)),
        ("bell", lambda: cone(0.10, 0.02, 0.18), mat_brass, (0,0,0.02)),
    ]),
    ("crystal_shard", lambda: [
        ("base", lambda: cyl(0.08, 0.02, 12), mat_stone, (0,0,0.01)),
        ("crystal", lambda: cone(0.06, 0.0, 0.25), mat_glow_violet, (0,0,0.15)),
    ]),
    ("origami_crane", lambda: [
        ("body", lambda: cube(0.15, 0.08, 0.04), mat_fabric_gold, (0,0,0.02)),
        ("wing_l", lambda: cube(0.04, 0.12, 0.02), mat_fabric_gold, (-0.06, 0, 0.06)),
        ("wing_r", lambda: cube(0.04, 0.12, 0.02), mat_fabric_gold, (0.06, 0, 0.06)),
    ]),
    ("dice_set", lambda: [
        ("die_1", lambda: cube(0.07, 0.07, 0.07), mat_wood_light, (-0.10, 0, 0.035)),
        ("die_2", lambda: cube(0.07, 0.07, 0.07), mat_wood_light, (0.10, 0, 0.035)),
        ("die_3", lambda: cube(0.07, 0.07, 0.07), mat_wood_light, (0, 0.08, 0.035)),
    ]),
]

print("=== Building 15 small decor ===")
for idx, (name, builder) in enumerate(small_recipes):
    pos = grid_pos(idx, cols=15, spacing=1.5, x_off=-10.5, y_off=-10)
    parts = builder()
    objs = add_group(name, parts, pos)
    all_decor_groups[name] = objs

# === MEDIUM DECOR (15) ===
medium_recipes = [
    ("wooden_chair", lambda: [
        ("seat", lambda: cube(0.4, 0.4, 0.05), mat_wood, (0,0,0.45)),
        ("back", lambda: cube(0.4, 0.05, 0.5), mat_wood, (0,0.18,0.7)),
        ("leg_a", lambda: cube(0.05, 0.05, 0.45), mat_wood_dark, (-0.17,-0.17,0.225)),
        ("leg_b", lambda: cube(0.05, 0.05, 0.45), mat_wood_dark, (0.17,-0.17,0.225)),
        ("leg_c", lambda: cube(0.05, 0.05, 0.45), mat_wood_dark, (-0.17,0.17,0.225)),
        ("leg_d", lambda: cube(0.05, 0.05, 0.45), mat_wood_dark, (0.17,0.17,0.225)),
    ]),
    ("side_table", lambda: [
        ("top", lambda: cube(0.5, 0.5, 0.05), mat_wood_light, (0,0,0.65)),
        ("leg", lambda: cyl(0.05, 0.65, 8), mat_wood_dark, (0,0,0)),
    ]),
    ("rug_round", lambda: [
        ("rug", lambda: cyl(0.7, 0.03, 24), mat_fabric_red, (0,0,0.015)),
        ("trim", lambda: cyl(0.72, 0.04, 24), mat_fabric_gold, (0,0,0.005)),
    ]),
    ("painting_small", lambda: [
        ("frame", lambda: cube(0.6, 0.04, 0.45), mat_brass, (0,0,0.85)),
        ("canvas", lambda: cube(0.55, 0.02, 0.4), mat_compiler_blue, (0,0.025,0.85)),
    ]),
    ("bookcase_short", lambda: [
        ("top", lambda: cube(0.6, 0.25, 0.04), mat_wood_dark, (0,0,1.05)),
        ("bottom", lambda: cube(0.6, 0.25, 0.04), mat_wood_dark, (0,0,0.05)),
        ("back", lambda: cube(0.6, 0.04, 1.0), mat_wood_dark, (0,0.105,0.55)),
        ("shelf1", lambda: cube(0.55, 0.22, 0.04), mat_wood_dark, (0,0,0.4)),
        ("shelf2", lambda: cube(0.55, 0.22, 0.04), mat_wood_dark, (0,0,0.75)),
        ("books_a", lambda: cube(0.45, 0.18, 0.25), mat_fabric_red, (0,0,0.18)),
        ("books_b", lambda: cube(0.45, 0.18, 0.25), mat_fabric_blue, (0,0,0.55)),
        ("books_c", lambda: cube(0.45, 0.18, 0.25), mat_fabric_green, (0,0,0.90)),
    ]),
    ("vase_tall", lambda: [
        ("base", lambda: cyl(0.18, 0.05, 16), mat_clay, (0,0,0.025)),
        ("body", lambda: cyl(0.13, 0.55, 16), mat_clay, (0,0,0.32)),
        ("neck", lambda: cyl(0.08, 0.10, 16), mat_clay, (0,0,0.65)),
    ]),
    ("plant_stand", lambda: [
        ("top", lambda: cyl(0.18, 0.04, 12), mat_wood_dark, (0,0,0.85)),
        ("post", lambda: cyl(0.05, 0.85, 8), mat_iron, (0,0,0)),
        ("pot", lambda: cyl(0.16, 0.18, 12), mat_clay, (0,0,0.97)),
        ("plant", lambda: ico(0.20, 2), mat_npc_green, (0,0,1.20)),
    ]),
    ("clock_wall", lambda: [
        ("frame", lambda: cyl(0.30, 0.04, 24), mat_brass, (0,0,1.2), (math.radians(90), 0, 0)),
        ("face", lambda: cyl(0.25, 0.02, 24), mat_marble, (0,0.025,1.2), (math.radians(90), 0, 0)),
    ]),
    ("trophy_small", lambda: [
        ("base", lambda: cube(0.25, 0.25, 0.05), mat_wood_dark, (0,0,0.025)),
        ("cup", lambda: cyl(0.10, 0.30, 12), mat_brass, (0,0,0.20)),
    ]),
    ("globe_stand", lambda: [
        ("post", lambda: cyl(0.04, 0.4, 6), mat_wood_dark, (0,0,0.2)),
        ("base", lambda: cube(0.18, 0.18, 0.04), mat_wood_dark, (0,0,0.02)),
        ("globe", lambda: ico(0.20, 3), mat_compiler_blue, (0,0,0.6)),
    ]),
    ("stool_padded", lambda: [
        ("seat", lambda: cyl(0.20, 0.10, 16), mat_fabric_red, (0,0,0.45)),
        ("legs", lambda: cyl(0.05, 0.45, 8), mat_iron, (0,0,0)),
    ]),
    ("lamp_floor", lambda: [
        ("base", lambda: cyl(0.18, 0.04, 16), mat_iron, (0,0,0.02)),
        ("post", lambda: cyl(0.04, 1.4, 8), mat_iron, (0,0,0.7)),
        ("shade", lambda: cone(0.25, 0.18, 0.20), mat_fabric_gold, (0,0,1.45)),
        ("bulb", lambda: ico(0.10, 2), mat_glow_warm, (0,0,1.50)),
    ]),
    ("rug_runner", lambda: [
        ("rug", lambda: cube(0.4, 1.4, 0.03), mat_fabric_purple, (0,0,0.015)),
    ]),
    ("crate", lambda: [
        ("box", lambda: cube(0.4, 0.4, 0.4), mat_wood, (0,0,0.2)),
    ]),
    ("barrel_small", lambda: [
        ("body", lambda: cyl(0.20, 0.55, 16), mat_wood, (0,0,0.275)),
        ("band1", lambda: cyl(0.21, 0.04, 16), mat_iron, (0,0,0.45)),
        ("band2", lambda: cyl(0.21, 0.04, 16), mat_iron, (0,0,0.10)),
    ]),
]

print("=== Building 15 medium decor ===")
for idx, (name, builder) in enumerate(medium_recipes):
    pos = grid_pos(idx, cols=15, spacing=1.8, x_off=-12.6, y_off=-7)
    parts = builder()
    objs = add_group(name, parts, pos)
    all_decor_groups[name] = objs

# === LARGE DECOR (10) ===
large_recipes = [
    ("dining_table", lambda: [
        ("top", lambda: cube(1.5, 0.8, 0.06), mat_wood, (0,0,0.75)),
        ("leg_a", lambda: cube(0.08, 0.08, 0.7), mat_wood_dark, (-0.65,-0.32,0.35)),
        ("leg_b", lambda: cube(0.08, 0.08, 0.7), mat_wood_dark, (0.65,-0.32,0.35)),
        ("leg_c", lambda: cube(0.08, 0.08, 0.7), mat_wood_dark, (-0.65,0.32,0.35)),
        ("leg_d", lambda: cube(0.08, 0.08, 0.7), mat_wood_dark, (0.65,0.32,0.35)),
    ]),
    ("bed_double", lambda: [
        ("base", lambda: cube(1.5, 1.0, 0.3), mat_wood_dark, (0,0,0.15)),
        ("mattress", lambda: cube(1.45, 0.95, 0.18), mat_fabric_blue, (0,0,0.39)),
        ("pillow", lambda: cube(0.5, 0.25, 0.08), make_pbr("p_w", (0.95, 0.92, 0.85)), (0,-0.3,0.50)),
        ("headboard", lambda: cube(1.5, 0.05, 0.6), mat_wood_dark, (0,0.5,0.45)),
    ]),
    ("wardrobe", lambda: [
        ("body", lambda: cube(0.8, 0.4, 1.6), mat_wood, (0,0,0.8)),
        ("door_l", lambda: cube(0.38, 0.04, 1.5), mat_wood_dark, (-0.20,-0.21,0.8)),
        ("door_r", lambda: cube(0.38, 0.04, 1.5), mat_wood_dark, (0.20,-0.21,0.8)),
        ("knob_l", lambda: ico(0.04, 1), mat_brass, (-0.10,-0.24,0.8)),
        ("knob_r", lambda: ico(0.04, 1), mat_brass, (0.10,-0.24,0.8)),
    ]),
    ("piano", lambda: [
        ("body", lambda: cube(1.5, 0.7, 1.0), mat_wood_dark, (0,0,0.5)),
        ("keys", lambda: cube(1.4, 0.18, 0.04), make_pbr("p_keys", (0.95, 0.92, 0.85)), (0,-0.42,0.92)),
        ("top", lambda: cube(1.4, 0.5, 0.05), mat_wood_dark, (0,0.05,1.025)),
    ]),
    ("statue_classical", lambda: [
        ("base", lambda: cube(0.5, 0.5, 0.2), mat_marble, (0,0,0.1)),
        ("body", lambda: cyl(0.18, 1.4, 12), mat_marble, (0,0,0.9)),
        ("head", lambda: ico(0.20, 2), mat_marble, (0,0,1.75)),
    ]),
    ("fountain_basin", lambda: [
        ("basin", lambda: cyl(0.85, 0.30, 24), mat_stone, (0,0,0.15)),
        ("inner", lambda: cyl(0.7, 0.25, 24), mat_water, (0,0,0.18)),
        ("center", lambda: cyl(0.10, 0.5, 12), mat_marble, (0,0,0.5)),
        ("top", lambda: ico(0.15, 2), mat_marble, (0,0,0.85)),
    ]),
    ("aquarium_large", lambda: [
        ("base", lambda: cube(1.4, 0.5, 0.10), mat_wood_dark, (0,0,0.05)),
        ("glass", lambda: cube(1.35, 0.45, 0.7), mat_glass, (0,0,0.45)),
        ("water", lambda: cube(1.30, 0.42, 0.65), mat_water, (0,0,0.45)),
        ("light", lambda: cube(1.35, 0.45, 0.05), mat_glow_cool, (0,0,0.85)),
    ]),
    ("chandelier", lambda: [
        ("disc", lambda: cyl(0.50, 0.05, 24), mat_brass, (0,0,1.95)),
        ("chain", lambda: cyl(0.04, 0.4, 6), mat_iron, (0,0,2.1)),
        ("bulb_a", lambda: ico(0.08, 2), mat_glow_warm, (-0.30,0,1.85)),
        ("bulb_b", lambda: ico(0.08, 2), mat_glow_warm, (0.30,0,1.85)),
        ("bulb_c", lambda: ico(0.08, 2), mat_glow_warm, (0,0.30,1.85)),
        ("bulb_d", lambda: ico(0.08, 2), mat_glow_warm, (0,-0.30,1.85)),
    ]),
    ("display_case", lambda: [
        ("base", lambda: cube(0.8, 0.5, 0.12), mat_wood_dark, (0,0,0.06)),
        ("glass", lambda: cube(0.75, 0.45, 1.0), mat_glass, (0,0,0.62)),
        ("artifact", lambda: ico(0.18, 2), mat_glow_violet, (0,0,0.5)),
    ]),
    ("throne_chair", lambda: [
        ("seat", lambda: cube(0.8, 0.7, 0.15), mat_fabric_purple, (0,0,0.55)),
        ("back", lambda: cube(0.8, 0.10, 1.4), mat_fabric_purple, (0,0.30,1.3)),
        ("arm_l", lambda: cube(0.10, 0.7, 0.5), mat_fabric_purple, (-0.45,0,0.85)),
        ("arm_r", lambda: cube(0.10, 0.7, 0.5), mat_fabric_purple, (0.45,0,0.85)),
        ("base", lambda: cube(0.85, 0.75, 0.15), mat_wood_dark, (0,0,0.075)),
    ]),
]

print("=== Building 10 large decor ===")
for idx, (name, builder) in enumerate(large_recipes):
    pos = grid_pos(idx, cols=10, spacing=2.5, x_off=-11.25, y_off=-3)
    parts = builder()
    objs = add_group(name, parts, pos)
    all_decor_groups[name] = objs

# === INTERACTIVE DECOR (10) ===
interactive_recipes = [
    ("music_box", lambda: [
        ("body", lambda: cube(0.40, 0.30, 0.20), mat_wood, (0,0,0.10)),
        ("crank", lambda: cyl(0.03, 0.10, 6), mat_brass, (0.20,0,0.15), (0, math.radians(90), 0)),
        ("notes", lambda: ico(0.06, 2), mat_glow_warm, (0,0,0.30)),
    ]),
    ("game_board", lambda: [
        ("board", lambda: cube(0.50, 0.50, 0.04), mat_wood_light, (0,0,0.42)),
        ("piece_w", lambda: cyl(0.04, 0.04, 12), make_pbr("gp_w", (0.95, 0.92, 0.85)), (-0.15,-0.15,0.46)),
        ("piece_b", lambda: cyl(0.04, 0.04, 12), make_pbr("gp_b", (0.10, 0.10, 0.10)), (0.15,0.15,0.46)),
        ("legs", lambda: cube(0.5, 0.5, 0.4), mat_wood_dark, (0,0,0.2)),
    ]),
    ("workbench_decor", lambda: [
        ("top", lambda: cube(0.8, 0.4, 0.05), mat_wood, (0,0,0.85)),
        ("legs", lambda: cube(0.8, 0.4, 0.8), mat_wood_dark, (0,0,0.4)),
        ("hammer", lambda: cube(0.05, 0.20, 0.04), mat_iron, (-0.20,0,0.92)),
        ("nails", lambda: ico(0.04, 1), mat_iron, (0.20,0,0.92)),
    ]),
    ("training_dummy", lambda: [
        ("post", lambda: cyl(0.10, 1.5, 8), mat_wood_dark, (0,0,0)),
        ("body", lambda: ico(0.30, 2), mat_fabric_gold, (0,0,1.0)),
        ("head", lambda: ico(0.20, 2), mat_skin, (0,0,1.5)),
    ]),
    ("tarot_table", lambda: [
        ("top", lambda: cyl(0.45, 0.04, 24), mat_fabric_purple, (0,0,0.78)),
        ("post", lambda: cyl(0.05, 0.78, 8), mat_wood_dark, (0,0,0)),
        ("base", lambda: cyl(0.30, 0.04, 24), mat_wood_dark, (0,0,0.02)),
        ("orb", lambda: ico(0.12, 3), mat_glow_violet, (0,0,0.92)),
    ]),
    ("memory_terminal", lambda: [
        ("base", lambda: cube(0.40, 0.30, 0.20), mat_iron, (0,0,0.10)),
        ("screen", lambda: cube(0.36, 0.04, 0.30), mat_glow_cool, (0,0.13,0.35)),
        ("keys", lambda: cube(0.36, 0.20, 0.04), mat_iron, (0,0,0.22)),
    ]),
    ("phonograph", lambda: [
        ("base", lambda: cube(0.40, 0.40, 0.08), mat_wood_dark, (0,0,0.04)),
        ("disc", lambda: cyl(0.18, 0.02, 24), make_pbr("p_disc", (0.10, 0.10, 0.10)), (0,0,0.09)),
        ("horn", lambda: cone(0.20, 0.05, 0.30), mat_brass, (0,-0.10,0.30), (math.radians(15), 0, 0)),
    ]),
    ("punching_bag", lambda: [
        ("chain", lambda: cyl(0.03, 0.30, 6), mat_iron, (0,0,1.5)),
        ("bag", lambda: cyl(0.18, 0.7, 12), mat_fabric_red, (0,0,1.0)),
    ]),
    ("crystal_well", lambda: [
        ("base", lambda: cyl(0.50, 0.30, 16), mat_stone, (0,0,0.15)),
        ("inner", lambda: cyl(0.40, 0.25, 16), make_pbr("cw_inner", (0.05, 0.05, 0.10)), (0,0,0.18)),
        ("crystal", lambda: ico(0.20, 2), mat_glow_violet, (0,0,0.50)),
    ]),
    ("automaton", lambda: [
        ("base", lambda: cube(0.30, 0.30, 0.10), mat_iron, (0,0,0.05)),
        ("torso", lambda: cube(0.30, 0.20, 0.40), mat_brass, (0,0,0.30)),
        ("head", lambda: ico(0.18, 2), mat_brass, (0,0,0.65)),
        ("eye", lambda: ico(0.04, 1), mat_glow_red, (0,-0.15,0.65)),
    ]),
]

print("=== Building 10 interactive decor ===")
for idx, (name, builder) in enumerate(interactive_recipes):
    pos = grid_pos(idx, cols=10, spacing=2.5, x_off=-11.25, y_off=1)
    parts = builder()
    objs = add_group(name, parts, pos)
    all_decor_groups[name] = objs

# === Lighting placement props (5) ===
print("=== Lighting props ===")
lighting_recipes = [
    ("torch_wall", [
        ("bracket", lambda: cube(0.08, 0.08, 0.30), mat_iron, (0,0,0.15)),
        ("flame", lambda: ico(0.15, 2), mat_glow_warm, (0,-0.15,0.25)),
    ]),
    ("brazier", [
        ("bowl", lambda: cyl(0.30, 0.10, 16), mat_iron, (0,0,0.55)),
        ("legs", lambda: cyl(0.04, 0.50, 8), mat_iron, (0,0,0.25)),
        ("flame", lambda: ico(0.20, 2), mat_glow_warm, (0,0,0.75)),
    ]),
    ("lantern_post", [
        ("post", lambda: cyl(0.05, 1.6, 6), mat_iron, (0,0,0.8)),
        ("head", lambda: cube(0.20, 0.20, 0.20), mat_glow_warm, (0,0,1.7)),
    ]),
    ("crystal_lamp", [
        ("base", lambda: cyl(0.12, 0.05, 12), mat_brass, (0,0,0.025)),
        ("crystal", lambda: ico(0.18, 2), mat_glow_cool, (0,0,0.30)),
    ]),
    ("data_orb", [
        ("base", lambda: cyl(0.10, 0.04, 12), mat_iron, (0,0,0.02)),
        ("orb", lambda: ico(0.15, 3), mat_glow_violet, (0,0,0.20)),
    ]),
]
for idx, (name, parts_data) in enumerate(lighting_recipes):
    pos = (50 + idx * 1.5, -8, 0)
    parts = [(sub, builder, mat, off) for sub, builder, mat, off in parts_data]
    objs = []
    for part in parts:
        sub, builder, mat, offset = part
        bm = builder()
        loc = (pos[0] + offset[0], pos[1] + offset[1], pos[2] + offset[2])
        objs.append(add_bm(f"light_{name}_{sub}", bm, mat, col_lights_props, loc=loc))
    all_decor_groups[f"lighting_{name}"] = objs

# === Ambient effect props (3) ===
print("=== Ambient props ===")
# Smoke prop (vertical stack of grey ico)
for i in range(4):
    add_bm(f"ambient_smoke_{i}", ico(0.10 + i*0.05, 2), mat_smoke, col_ambient,
           loc=(60, -8, 0.15 + i * 0.20))
# Fire prop (orange icospheres)
for i in range(3):
    add_bm(f"ambient_fire_{i}", ico(0.15 - i*0.03, 2), mat_glow_warm, col_ambient,
           loc=(62, -8, 0.10 + i * 0.15))
# Water prop (blue cyl + ripple ring)
add_bm("ambient_water_basin", cyl(0.30, 0.05, 16), mat_water, col_ambient, loc=(64, -8, 0.025))
add_bm("ambient_water_ring", cyl(0.32, 0.02, 16), mat_glow_cool, col_ambient, loc=(64, -8, 0.06))

# === NPCs (3) ===
print("=== NPCs ===")
def build_npc(name, body_color, accent_color, hat_color, x_off, coll):
    """Build a simple humanoid NPC and link to coll."""
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.35)
    bmesh.ops.scale(bm, vec=(1, 0.7, 1.2), verts=bm.verts)
    add_bm(f"{name}_body", bm, body_color, coll, loc=(x_off, 0, 1.0))
    add_bm(f"{name}_head", ico(0.30, 2), mat_skin, coll, loc=(x_off, 0, 1.65))
    # Hat
    add_bm(f"{name}_hat", cone(0.32, 0.05, 0.40), hat_color, coll, loc=(x_off, 0, 1.95))
    # Arms
    add_bm(f"{name}_arm_l", cyl(0.10, 0.6, 8), body_color, coll, loc=(x_off - 0.45, 0, 0.9))
    add_bm(f"{name}_arm_r", cyl(0.10, 0.6, 8), body_color, coll, loc=(x_off + 0.45, 0, 0.9))
    # Legs
    add_bm(f"{name}_leg_l", cyl(0.13, 0.6, 8), mat_wood_dark, coll, loc=(x_off - 0.18, 0, 0.0))
    add_bm(f"{name}_leg_r", cyl(0.13, 0.6, 8), mat_wood_dark, coll, loc=(x_off + 0.18, 0, 0.0))
    # Accent emblem on chest
    add_bm(f"{name}_emblem", ico(0.10, 2), accent_color, coll, loc=(x_off, -0.32, 1.05))

build_npc("plot_npc", mat_compiler_blue, mat_brass, mat_npc_red, 70, col_npcs)
build_npc("shop_npc", mat_npc_green, mat_glow_warm, mat_brass, 73, col_npcs)
build_npc("showcase_npc", mat_fabric_purple, mat_glow_violet, mat_fabric_gold, 76, col_npcs)

# === Showcase area scene ===
print("=== Showcase area ===")
SAX, SAY = 90, 0
# Floor (marble)
add_bm("SA_Floor", cube(8, 6, 0.1), mat_marble, col_showcase, loc=(SAX, SAY, 0))
# Pedestals (4) with decor on top
for i, decor_name in enumerate(["statue_classical", "fountain_basin", "throne_chair", "display_case"]):
    px = SAX - 3 + (i % 2) * 6
    py = SAY - 2 + (i // 2) * 4
    add_bm(f"SA_Pedestal_{i}", cyl(0.8, 0.3, 16), mat_stone, col_showcase, loc=(px, py, 0.15))
# Velvet ropes
for i in range(8):
    ang = (i / 8) * math.tau
    add_bm(f"SA_RopePost_{i}", cyl(0.06, 0.8, 8), mat_brass, col_showcase,
           loc=(SAX + math.cos(ang)*3.8, SAY + math.sin(ang)*2.8, 0.4))
# Banner
add_bm("SA_Banner", cube(6, 0.05, 0.6), mat_fabric_purple, col_showcase, loc=(SAX, SAY + 3.5, 2.5))

# === Decorated home scene ===
print("=== Decorated home ===")
DHX, DHY = 110, 0
# Floor + walls (interior shell)
add_bm("DH_Floor", cube(6, 5, 0.1), mat_wood_light, col_home, loc=(DHX, DHY, 0))
add_bm("DH_WallN", cube(6, 0.15, 3), mat_wood_dark, col_home, loc=(DHX, DHY + 2.5, 1.5))
add_bm("DH_WallE", cube(0.15, 5, 3), mat_wood_dark, col_home, loc=(DHX + 3, DHY, 1.5))
add_bm("DH_WallW", cube(0.15, 5, 3), mat_wood_dark, col_home, loc=(DHX - 3, DHY, 1.5))
# Bed (corner)
add_bm("DH_Bed_Base", cube(1.6, 1.0, 0.3), mat_wood_dark, col_home, loc=(DHX - 1.5, DHY + 1.5, 0.15))
add_bm("DH_Bed_Mattress", cube(1.55, 0.95, 0.18), mat_fabric_blue, col_home, loc=(DHX - 1.5, DHY + 1.5, 0.39))
add_bm("DH_Bed_Pillow", cube(0.5, 0.25, 0.08), make_pbr("dh_pillow", (0.95, 0.92, 0.85)), col_home, loc=(DHX - 1.5, DHY + 1.2, 0.50))
# Side table + lamp
add_bm("DH_SideTable", cube(0.5, 0.5, 0.05), mat_wood, col_home, loc=(DHX - 1.5, DHY + 0.4, 0.65))
add_bm("DH_SideTable_Leg", cyl(0.05, 0.65, 8), mat_wood_dark, col_home, loc=(DHX - 1.5, DHY + 0.4, 0))
add_bm("DH_Lamp_Base", cyl(0.10, 0.15, 12), mat_brass, col_home, loc=(DHX - 1.5, DHY + 0.4, 0.75))
add_bm("DH_Lamp_Bulb", ico(0.10, 2), mat_glow_warm, col_home, loc=(DHX - 1.5, DHY + 0.4, 0.95))
# Bookshelf wall
add_bm("DH_Bookshelf", cube(2.0, 0.4, 2.5), mat_wood_dark, col_home, loc=(DHX + 1.5, DHY + 2.0, 1.25))
for i in range(8):
    book_color = [mat_fabric_red, mat_fabric_blue, mat_fabric_green, mat_fabric_purple][i % 4]
    add_bm(f"DH_Book_{i}", cube(0.18, 0.20, 0.30), book_color, col_home,
           loc=(DHX + 0.7 + (i % 4) * 0.4, DHY + 1.8, 0.7 + (i // 4) * 0.7))
# Round rug center
add_bm("DH_Rug", cyl(1.4, 0.03, 24), mat_fabric_red, col_home, loc=(DHX, DHY - 0.3, 0.015))
# Dining set (chairs)
add_bm("DH_DiningTable", cube(1.0, 0.6, 0.04), mat_wood, col_home, loc=(DHX, DHY - 0.3, 0.7))
add_bm("DH_TableLeg", cyl(0.05, 0.7, 8), mat_wood_dark, col_home, loc=(DHX, DHY - 0.3, 0))
for sx in [-1, 1]:
    add_bm(f"DH_Chair_{sx}", cube(0.30, 0.30, 0.05), mat_wood, col_home, loc=(DHX + sx*0.7, DHY - 0.3, 0.45))
    add_bm(f"DH_ChairBack_{sx}", cube(0.30, 0.04, 0.5), mat_wood, col_home, loc=(DHX + sx*0.7, DHY - 0.45, 0.7))
# Painting on wall
add_bm("DH_Painting", cube(0.7, 0.04, 0.5), mat_brass, col_home, loc=(DHX, DHY + 2.4, 1.8))
add_bm("DH_PaintingCanvas", cube(0.65, 0.02, 0.45), mat_compiler_blue, col_home, loc=(DHX, DHY + 2.38, 1.8))
# Chandelier
add_bm("DH_ChandelierDisc", cyl(0.4, 0.05, 24), mat_brass, col_home, loc=(DHX, DHY - 0.3, 2.6))
for i in range(4):
    ang = (i / 4) * math.tau
    add_bm(f"DH_ChandelierBulb_{i}", ico(0.10, 2), mat_glow_warm, col_home,
           loc=(DHX + math.cos(ang)*0.3, DHY - 0.3 + math.sin(ang)*0.3, 2.5))

# === Cameras + lights ===
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 75
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

hero_cam_data = bpy.data.cameras.new("Hero_Cam")
hero_cam_data.lens = 50
hero_cam = bpy.data.objects.new("Hero_Cam", hero_cam_data)
hero_cam.rotation_euler = (math.radians(72), 0, 0)
scene.collection.objects.link(hero_cam)
link_to(hero_cam, col_cam)

# Lights
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 600
key_data.size = 5
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, 0, 12)
key_obj.rotation_euler = (math.radians(40), 0, 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 220
fill_data.size = 8
fill_data.color = (0.7, 0.85, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (0, -8, 6)
fill_obj.rotation_euler = (math.radians(60), 0, 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

# Hero key light (for home + showcase shots)
hero_key_data = bpy.data.lights.new("HeroKey", type='AREA')
hero_key_data.energy = 1500
hero_key_data.size = 8
hero_key_data.color = (1.0, 0.95, 0.85)
hero_key_obj = bpy.data.objects.new("HeroKey", hero_key_data)
scene.collection.objects.link(hero_key_obj)
link_to(hero_key_obj, col_lights)

world = bpy.data.worlds.new("World_Decor")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.06, 0.07, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# === Render 50 decor icons ===
print("=== Rendering 50 decor icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

# Hide everything except col_decor
for col in [col_npcs, col_lights_props, col_ambient, col_showcase, col_home]:
    for obj in col.objects:
        obj.hide_render = True
hero_key_obj.hide_render = True

decor_keys_50 = [name for name, _ in (small_recipes + medium_recipes + large_recipes + interactive_recipes)]
for decor_id in decor_keys_50:
    objs = all_decor_groups.get(decor_id, [])
    if not objs: continue
    # Hide all decor groups
    for k2 in decor_keys_50:
        for o in all_decor_groups.get(k2, []):
            o.hide_render = (k2 != decor_id)
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    cz = sum(o.location.z for o in objs) / len(objs)
    icon_cam.location = (cx, cy - 1.4, cz + 1.6)
    out_path = os.path.join(RENDER_DIR, f"decor_{decor_id}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render 3 NPCs ===
print("=== Rendering NPCs ===")
scene.render.resolution_x = 512
scene.render.resolution_y = 768
# Hide all decor
for k2 in decor_keys_50:
    for o in all_decor_groups.get(k2, []):
        o.hide_render = True

npc_groups = {"plot": ("plot_npc", 70), "shop": ("shop_npc", 73), "showcase": ("showcase_npc", 76)}
for label, (prefix, x_off) in npc_groups.items():
    # Hide all NPCs
    for obj in col_npcs.objects:
        obj.hide_render = not obj.name.startswith(prefix)
    icon_cam.location = (x_off, -3.5, 1.8)
    icon_cam.rotation_euler = (math.radians(75), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"npc_{label}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Hero shots (showcase + home) ===
print("=== Rendering hero shots ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False
scene.camera = hero_cam

# Showcase hero
for obj in col_npcs.objects:
    obj.hide_render = True
for obj in col_showcase.objects:
    obj.hide_render = False
hero_key_obj.location = (SAX, SAY, 8)
hero_key_obj.hide_render = False
hero_cam.location = (SAX + 6, SAY - 8, 5)
hero_cam.rotation_euler = (math.radians(72), 0, math.radians(25))
scene.render.filepath = os.path.join(RENDER_DIR, "showcase_area.png")
bpy.ops.render.render(write_still=True)

# Decorated home hero
for obj in col_showcase.objects:
    obj.hide_render = True
for obj in col_home.objects:
    obj.hide_render = False
hero_key_obj.location = (DHX, DHY - 2, 6)
hero_cam.location = (DHX + 4, DHY - 5.5, 3.5)
hero_cam.rotation_euler = (math.radians(70), 0, math.radians(35))
scene.render.filepath = os.path.join(RENDER_DIR, "decorated_home_hero.png")
bpy.ops.render.render(write_still=True)

print("Decor pipeline complete.")
