"""
Epic 34 — Crafting Materials, Stations & Gather Props Pipeline
================================================================
Builds in one Blender background pass:
  - Task 3: 20 crafting material icon meshes (each rendered as 256x256 PNG)
  - Task 6 + 32: 5 crafting station prop variants × 3 upgrade tiers = 15
    station meshes (Forge / Workbench / Alchemy / Cooking / Smelting)
  - Task 35: Ore deposit gather prop
  - Task 36: Wood gather prop (stump + axe)
  - Task 37: Herb gather prop (3 herb clusters)
  - Task 17: Craft success VFX placeholder mesh (gold sparks ring)
  - Task 18: Craft failure VFX placeholder mesh (red smoke puff)
  - Task 48: Hero shot render of forge station

Saves:
  - _art_source/crafting/crafting_assets.blend
  - _art_source/crafting/renders/material_<id>.png         (20)
  - _art_source/crafting/renders/station_<kind>_t<tier>.png (15)
  - _art_source/crafting/renders/forge_hero.png
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, Matrix

random.seed(3434)
OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/crafting/crafting_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/crafting/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.render.film_transparent = False

def make_pbr(name, base, rough=0.65, metal=0.0, emit=None, emit_strength=0.0):
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

# === Materials palette ===
mat_iron = make_pbr("mat_iron", (0.45, 0.45, 0.50), 0.4, 0.95)
mat_copper = make_pbr("mat_copper", (0.75, 0.40, 0.20), 0.3, 0.95)
mat_gold = make_pbr("mat_gold", (0.85, 0.65, 0.20), 0.2, 1.0)
mat_silver = make_pbr("mat_silver", (0.88, 0.88, 0.92), 0.2, 1.0)
mat_obsidian = make_pbr("mat_obsidian", (0.05, 0.05, 0.10), 0.2, 0.85)
mat_wood = make_pbr("mat_wood", (0.40, 0.22, 0.10), 0.85)
mat_wood_dark = make_pbr("mat_wood_dark", (0.20, 0.12, 0.06), 0.85)
mat_stone = make_pbr("mat_stone", (0.45, 0.42, 0.38), 0.85)
mat_stone_dark = make_pbr("mat_stone_dark", (0.20, 0.20, 0.22), 0.9)
mat_brick = make_pbr("mat_brick", (0.55, 0.30, 0.20), 0.85)

mat_herb = make_pbr("mat_herb", (0.18, 0.42, 0.15), 0.85, 0.0, (0.3, 0.6, 0.2), 0.3)
mat_crystal_blue = make_pbr("mat_crystal_blue", (0.30, 0.55, 0.85), 0.2, 0.0, (0.4, 0.7, 1.0), 2.5)
mat_crystal_red = make_pbr("mat_crystal_red", (0.85, 0.20, 0.20), 0.2, 0.0, (1.0, 0.3, 0.2), 2.5)
mat_crystal_violet = make_pbr("mat_crystal_violet", (0.55, 0.20, 0.85), 0.2, 0.0, (0.7, 0.3, 1.0), 3.0)
mat_glow_orange = make_pbr("mat_glow_orange", (1.0, 0.55, 0.10), 0.3, 0.0, (1.0, 0.6, 0.15), 4.5)
mat_glow_cyan = make_pbr("mat_glow_cyan", (0.20, 0.85, 0.95), 0.3, 0.0, (0.3, 0.9, 1.0), 3.5)
mat_glow_red = make_pbr("mat_glow_red", (1.0, 0.30, 0.20), 0.3, 0.0, (1.0, 0.3, 0.2), 3.5)
mat_smoke_red = make_pbr("mat_smoke_red", (0.55, 0.15, 0.15), 0.95, 0.0, (0.7, 0.2, 0.15), 0.7)
mat_dirt = make_pbr("mat_dirt", (0.28, 0.20, 0.13), 0.9)

# Material icon palette: 20 distinct material colors
MATERIAL_PALETTE = [
    ("iron_ingot", (0.55, 0.55, 0.60), 0.3, 0.95, None, 0),
    ("copper_ore", (0.75, 0.40, 0.20), 0.7, 0.0, None, 0),
    ("gold_nugget", (0.95, 0.78, 0.25), 0.2, 1.0, None, 0),
    ("silver_bar", (0.92, 0.92, 0.95), 0.2, 1.0, None, 0),
    ("obsidian_shard", (0.10, 0.08, 0.15), 0.2, 0.85, None, 0),
    ("oak_log", (0.45, 0.25, 0.10), 0.85, 0.0, None, 0),
    ("yew_log", (0.25, 0.15, 0.08), 0.85, 0.0, None, 0),
    ("granite_block", (0.55, 0.52, 0.48), 0.85, 0.0, None, 0),
    ("marble_block", (0.92, 0.90, 0.85), 0.4, 0.0, None, 0),
    ("clay_lump", (0.72, 0.45, 0.30), 0.9, 0.0, None, 0),
    ("herb_leaf", (0.30, 0.60, 0.20), 0.8, 0.0, (0.3, 0.6, 0.2), 0.4),
    ("blue_crystal", (0.35, 0.60, 0.95), 0.15, 0.0, (0.4, 0.7, 1.0), 2.5),
    ("red_crystal", (0.95, 0.30, 0.30), 0.15, 0.0, (1.0, 0.3, 0.2), 2.5),
    ("violet_crystal", (0.70, 0.30, 0.95), 0.15, 0.0, (0.7, 0.3, 1.0), 3.0),
    ("ember_dust", (1.0, 0.55, 0.10), 0.4, 0.0, (1.0, 0.6, 0.2), 3.0),
    ("frost_dust", (0.65, 0.85, 1.0), 0.4, 0.0, (0.5, 0.85, 1.0), 2.0),
    ("data_shard", (0.30, 0.85, 0.55), 0.3, 0.0, (0.4, 1.0, 0.6), 2.5),
    ("memory_chip", (0.85, 0.65, 0.20), 0.3, 0.85, (0.95, 0.7, 0.2), 0.6),
    ("void_essence", (0.20, 0.10, 0.30), 0.2, 0.0, (0.6, 0.2, 1.0), 4.0),
    ("compiler_ink", (0.15, 0.30, 0.55), 0.4, 0.0, (0.2, 0.5, 1.0), 1.5),
]

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_materials = make_coll("Materials")
col_stations = make_coll("Stations")
col_gather = make_coll("Gather")
col_vfx = make_coll("VFX")
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

# === Build 20 material icons ===
print("=== Building 20 material icons ===")
material_icons = {}
for idx, (name, base, rough, metal, emit, emit_str) in enumerate(MATERIAL_PALETTE):
    mat = make_pbr(f"icon_mat_{name}", base, rough, metal, emit, emit_str)
    px = (idx % 5) * 1.6 - 3.2
    py = (idx // 5) * 1.6 - 2.4
    # Each material gets a unique shape
    if "ingot" in name or "bar" in name:
        bm = cube(0.30, 0.16, 0.10)
    elif "ore" in name or "nugget" in name or "lump" in name:
        bm = ico(0.28, 2)
    elif "log" in name:
        bm = cyl(0.22, 0.55, 12)
    elif "block" in name:
        bm = cube(0.30, 0.30, 0.30)
    elif "leaf" in name:
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.25)
        bmesh.ops.scale(bm, vec=(1.4, 0.3, 0.9), verts=bm.verts)
    elif "crystal" in name:
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=4, radius1=0.20, radius2=0.0, depth=0.6)
    elif "shard" in name:
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=4, radius1=0.18, radius2=0.0, depth=0.5)
    elif "dust" in name:
        bm = ico(0.22, 2)
    elif "chip" in name:
        bm = cube(0.30, 0.05, 0.20)
    elif "essence" in name:
        bm = bmesh.new()
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.22)
        bmesh.ops.scale(bm, vec=(1, 1.4, 1), verts=bm.verts)
    elif "ink" in name:
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.22)
        bmesh.ops.scale(bm, vec=(1, 1.5, 1), verts=bm.verts)
    else:
        bm = ico(0.25, 2)
    obj = add_bm(f"material_{name}", bm, mat, col_materials, loc=(px, py, 0))
    material_icons[name] = obj

# === Build 5 station kinds × 3 upgrade tiers ===
print("=== Building 15 stations ===")

def build_forge(tier, x_off):
    """Forge: stone block + chimney + anvil + glow."""
    objs = []
    # Base stone block
    objs.append(add_bm(f"forge_t{tier}_base", cube(1.5, 1.5, 1.2 + 0.1*tier), mat_stone, col_stations,
                       loc=(x_off, 0, 0.6 + 0.05*tier)))
    # Chimney
    objs.append(add_bm(f"forge_t{tier}_chimney", cube(0.8, 0.8, 1.2 + 0.3*tier), mat_brick, col_stations,
                       loc=(x_off, 0.0, 1.8 + 0.05*tier)))
    # Anvil in front
    objs.append(add_bm(f"forge_t{tier}_anvil_base", cyl(0.35, 0.6, 8), mat_wood_dark, col_stations,
                       loc=(x_off + 1.4, 0, 0.3)))
    objs.append(add_bm(f"forge_t{tier}_anvil_top", cube(0.7, 0.3, 0.3), mat_iron, col_stations,
                       loc=(x_off + 1.4, 0, 0.75)))
    # Glow ember (more for higher tier)
    glow_mat = mat_glow_orange if tier == 0 else (mat_glow_cyan if tier == 2 else mat_glow_red)
    objs.append(add_bm(f"forge_t{tier}_ember", cube(0.6, 0.6, 0.4), glow_mat, col_stations,
                       loc=(x_off, -0.6, 1.0)))
    # Tier 2: Add gold trim
    if tier >= 1:
        objs.append(add_bm(f"forge_t{tier}_trim1", cube(1.6, 0.05, 0.05), mat_gold, col_stations,
                           loc=(x_off, 0.78, 1.2)))
        objs.append(add_bm(f"forge_t{tier}_trim2", cube(1.6, 0.05, 0.05), mat_gold, col_stations,
                           loc=(x_off, -0.78, 1.2)))
    # Tier 3: Add crystal core
    if tier >= 2:
        objs.append(add_bm(f"forge_t{tier}_crystal", ico(0.18, 2), mat_crystal_violet, col_stations,
                           loc=(x_off, 0, 2.6)))
    return objs

def build_workbench(tier, x_off):
    objs = []
    # Top
    objs.append(add_bm(f"bench_t{tier}_top", cube(2.0, 0.7, 0.1), mat_wood, col_stations,
                       loc=(x_off, 0, 0.95)))
    # Legs
    for sx in [-1, 1]:
        for sy in [-1, 1]:
            objs.append(add_bm(f"bench_t{tier}_leg_{sx}_{sy}", cube(0.08, 0.08, 0.9), mat_wood_dark, col_stations,
                               loc=(x_off + sx*0.85, sy*0.3, 0.45)))
    # Vise
    objs.append(add_bm(f"bench_t{tier}_vise", cube(0.25, 0.15, 0.18), mat_iron, col_stations,
                       loc=(x_off + 0.7, 0, 1.13)))
    # Tools rack
    if tier >= 1:
        objs.append(add_bm(f"bench_t{tier}_rack", cube(2.0, 0.05, 0.6), mat_wood_dark, col_stations,
                           loc=(x_off, 0.4, 1.65)))
        for i in range(4):
            objs.append(add_bm(f"bench_t{tier}_tool_{i}", cube(0.04, 0.04, 0.4), mat_iron, col_stations,
                               loc=(x_off - 0.6 + i*0.4, 0.35, 1.6)))
    if tier >= 2:
        objs.append(add_bm(f"bench_t{tier}_lamp_post", cyl(0.04, 0.6, 6), mat_iron, col_stations,
                           loc=(x_off - 0.8, 0.2, 1.3)))
        objs.append(add_bm(f"bench_t{tier}_lamp", ico(0.15, 2), mat_glow_orange, col_stations,
                           loc=(x_off - 0.8, 0.2, 1.95)))
    return objs

def build_alchemy(tier, x_off):
    objs = []
    # Cauldron
    objs.append(add_bm(f"alch_t{tier}_caul_base", cyl(0.5, 0.6, 12), mat_iron, col_stations,
                       loc=(x_off, 0, 0.3)))
    objs.append(add_bm(f"alch_t{tier}_caul_liquid", cyl(0.45, 0.05, 12), mat_glow_cyan, col_stations,
                       loc=(x_off, 0, 0.65)))
    # Tripod legs
    for i in range(3):
        ang = (i / 3) * math.tau
        objs.append(add_bm(f"alch_t{tier}_leg_{i}", cyl(0.04, 0.6, 6), mat_iron, col_stations,
                           loc=(x_off + math.cos(ang)*0.45, math.sin(ang)*0.45, 0.2),
                           rot=(0, math.radians(15), ang)))
    # Bottle shelf
    if tier >= 1:
        objs.append(add_bm(f"alch_t{tier}_shelf", cube(1.2, 0.2, 0.05), mat_wood_dark, col_stations,
                           loc=(x_off, -0.7, 1.2)))
        for i in range(4):
            objs.append(add_bm(f"alch_t{tier}_bottle_{i}", cyl(0.07, 0.25, 8),
                               [mat_glow_cyan, mat_glow_orange, mat_glow_red, mat_crystal_violet][i],
                               col_stations,
                               loc=(x_off - 0.4 + i*0.27, -0.7, 1.35)))
    if tier >= 2:
        objs.append(add_bm(f"alch_t{tier}_floating_orb", ico(0.18, 2), mat_crystal_violet, col_stations,
                           loc=(x_off, 0, 1.6)))
    return objs

def build_cooking(tier, x_off):
    objs = []
    # Counter base
    objs.append(add_bm(f"cook_t{tier}_counter", cube(1.6, 0.8, 0.95), mat_wood, col_stations,
                       loc=(x_off, 0, 0.475)))
    # Stove top
    objs.append(add_bm(f"cook_t{tier}_stove", cube(0.8, 0.6, 0.1), mat_iron, col_stations,
                       loc=(x_off - 0.3, 0, 1.0)))
    # Burners
    for i in range(2):
        objs.append(add_bm(f"cook_t{tier}_burner_{i}", cyl(0.18, 0.04, 12), mat_glow_orange, col_stations,
                           loc=(x_off - 0.5 + i*0.4, 0, 1.06)))
    # Pot
    objs.append(add_bm(f"cook_t{tier}_pot", cyl(0.22, 0.25, 12), mat_iron, col_stations,
                       loc=(x_off - 0.5, 0, 1.18)))
    if tier >= 1:
        # Hanging utensil rack
        objs.append(add_bm(f"cook_t{tier}_rack", cube(1.0, 0.05, 0.05), mat_iron, col_stations,
                           loc=(x_off, 0.35, 2.0)))
        for i in range(3):
            objs.append(add_bm(f"cook_t{tier}_utensil_{i}", cyl(0.03, 0.4, 6), mat_iron, col_stations,
                               loc=(x_off - 0.4 + i*0.4, 0.35, 1.75)))
    if tier >= 2:
        # Spice shelf with jars
        objs.append(add_bm(f"cook_t{tier}_spice_shelf", cube(1.2, 0.15, 0.05), mat_wood_dark, col_stations,
                           loc=(x_off, 0.45, 1.4)))
        for i in range(5):
            objs.append(add_bm(f"cook_t{tier}_jar_{i}", cyl(0.06, 0.18, 8), mat_brick, col_stations,
                               loc=(x_off - 0.5 + i*0.25, 0.45, 1.5)))
    return objs

def build_smelting(tier, x_off):
    objs = []
    # Crucible base
    objs.append(add_bm(f"smelt_t{tier}_base", cyl(0.7, 1.2, 12), mat_brick, col_stations,
                       loc=(x_off, 0, 0.6)))
    # Crucible top opening
    objs.append(add_bm(f"smelt_t{tier}_opening", cyl(0.55, 0.05, 12), mat_glow_orange, col_stations,
                       loc=(x_off, 0, 1.22)))
    # Bellows on side
    objs.append(add_bm(f"smelt_t{tier}_bellows", cube(0.6, 0.4, 0.25), mat_wood, col_stations,
                       loc=(x_off + 0.85, 0, 0.6)))
    if tier >= 1:
        # Iron bands around crucible
        for h in [0.3, 0.7, 1.05]:
            objs.append(add_bm(f"smelt_t{tier}_band_{int(h*10)}", cyl(0.72, 0.06, 12), mat_iron, col_stations,
                               loc=(x_off, 0, h)))
    if tier >= 2:
        # Floating ember above
        objs.append(add_bm(f"smelt_t{tier}_ember", ico(0.2, 2), mat_glow_red, col_stations,
                           loc=(x_off, 0, 1.8)))
    return objs

STATION_BUILDERS = [
    ("forge", build_forge),
    ("workbench", build_workbench),
    ("alchemy", build_alchemy),
    ("cooking", build_cooking),
    ("smelting", build_smelting),
]

station_objs = {}  # (kind, tier) → list of objects
for si, (kind, builder) in enumerate(STATION_BUILDERS):
    for tier in range(3):
        x_off = (si - 2) * 5 + 30  # offset far from material icons
        z_off = tier * 5 - 5  # stack tiers vertically
        objs = builder(tier, x_off)
        # Y-shift by tier so they don't overlap
        for o in objs:
            o.location.y += tier * 4 - 4
        station_objs[(kind, tier)] = objs

# === Gather props (35, 36, 37) ===
print("=== Gather props ===")
# Ore deposit
ore_objs = []
ore_objs.append(add_bm("gather_ore_base", ico(0.8, 2), mat_stone, col_gather, loc=(60, -8, 0)))
for i in range(5):
    ang = (i / 5) * math.tau
    ore_objs.append(add_bm(f"gather_ore_chunk_{i}", ico(0.25, 1), mat_iron, col_gather,
                           loc=(60 + math.cos(ang)*0.5, -8 + math.sin(ang)*0.5, 0.5)))

# Wood gather (stump + axe)
wood_objs = []
wood_objs.append(add_bm("gather_wood_stump", cyl(0.55, 0.6, 16), mat_wood, col_gather, loc=(63, -8, 0)))
wood_objs.append(add_bm("gather_wood_top", cyl(0.55, 0.05, 16), mat_wood_dark, col_gather, loc=(63, -8, 0.62)))
# Axe
wood_objs.append(add_bm("gather_wood_axe_handle", cyl(0.05, 0.7, 6), mat_wood_dark, col_gather,
                        loc=(63.4, -8, 0.5), rot=(math.radians(80), 0, math.radians(35))))
wood_objs.append(add_bm("gather_wood_axe_head", cube(0.15, 0.05, 0.18), mat_iron, col_gather,
                        loc=(63.7, -8, 0.85)))

# Herb cluster
herb_objs = []
for i in range(3):
    ang = (i / 3) * math.tau
    px = 66 + math.cos(ang) * 0.4
    py = -8 + math.sin(ang) * 0.4
    herb_objs.append(add_bm(f"gather_herb_stem_{i}", cyl(0.04, 0.4, 6), mat_wood_dark, col_gather,
                            loc=(px, py, 0.2)))
    herb_objs.append(add_bm(f"gather_herb_leaf_{i}", ico(0.18, 2), mat_herb, col_gather,
                            loc=(px, py, 0.5)))

# === Craft VFX placeholders ===
print("=== Craft VFX ===")
# Success: ring of gold sparks
for i in range(8):
    ang = (i / 8) * math.tau
    add_bm(f"vfx_success_{i}", ico(0.08, 1), mat_gold, col_vfx,
           loc=(70 + math.cos(ang)*0.5, -8 + math.sin(ang)*0.5, 0.5))
# Failure: red smoke puff
add_bm("vfx_fail_puff", ico(0.4, 2), mat_smoke_red, col_vfx, loc=(73, -8, 0.5))

# === Camera + lights ===
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 80
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

# Hero camera for forge close-up
hero_cam_data = bpy.data.cameras.new("Hero_Cam")
hero_cam_data.lens = 50
hero_cam = bpy.data.objects.new("Hero_Cam", hero_cam_data)
hero_cam.location = (33, -7, 2.5)  # forge tier 0 location
hero_cam.rotation_euler = (math.radians(78), 0, 0)
scene.collection.objects.link(hero_cam)
link_to(hero_cam, col_cam)

# Station camera (top-down to capture all 3 tiers of one kind)
station_cam_data = bpy.data.cameras.new("Station_Cam")
station_cam_data.lens = 50
station_cam = bpy.data.objects.new("Station_Cam", station_cam_data)
station_cam.rotation_euler = (math.radians(70), 0, 0)
scene.collection.objects.link(station_cam)
link_to(station_cam, col_cam)

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
fill_data.color = (0.6, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.rotation_euler = (math.radians(60), math.radians(40), 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

# Hero key (for forge close-up)
hero_key_data = bpy.data.lights.new("HeroKey", type='AREA')
hero_key_data.energy = 1500
hero_key_data.size = 6
hero_key_data.color = (1.0, 0.85, 0.6)
hero_key_obj = bpy.data.objects.new("HeroKey", hero_key_data)
hero_key_obj.location = (28, -8, 5)
hero_key_obj.rotation_euler = (math.radians(50), math.radians(-15), 0)
scene.collection.objects.link(hero_key_obj)
link_to(hero_key_obj, col_lights)

# World
world = bpy.data.worlds.new("World_Craft")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.08, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# === Render 20 material icons ===
print("=== Rendering 20 material icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

# Hide everything except material icons
for col in [col_stations, col_gather, col_vfx]:
    for obj in col.objects:
        obj.hide_render = True
hero_key_obj.hide_render = True

for name, obj in material_icons.items():
    # Hide all material icons except this one
    for n2, o2 in material_icons.items():
        o2.hide_render = (n2 != name)
    cx, cy, cz = obj.location
    icon_cam.location = (cx, cy - 0.3, cz + 1.6)
    out_path = os.path.join(RENDER_DIR, f"material_{name}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render 15 station thumbnails ===
print("=== Rendering 15 station thumbnails ===")
scene.render.resolution_x = 512
scene.render.resolution_y = 384
scene.render.film_transparent = True
scene.camera = station_cam

for name, obj in material_icons.items():
    obj.hide_render = True

for (kind, tier), objs in station_objs.items():
    # Hide all stations
    for k2, o2_list in station_objs.items():
        for o in o2_list:
            o.hide_render = (k2 != (kind, tier))
    # Center camera on this station
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    station_cam.location = (cx, cy - 4.5, 3.0)
    station_cam.rotation_euler = (math.radians(70), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"station_{kind}_t{tier}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render forge hero shot ===
print("=== Rendering forge hero shot ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False
scene.camera = hero_cam

# Show only forge tier 0
for k2, o2_list in station_objs.items():
    for o in o2_list:
        o.hide_render = (k2 != ("forge", 0))
hero_key_obj.hide_render = False

# Recenter hero camera on forge tier 0 actual position
forge_objs = station_objs[("forge", 0)]
fx = sum(o.location.x for o in forge_objs) / len(forge_objs)
fy = sum(o.location.y for o in forge_objs) / len(forge_objs)
hero_cam.location = (fx + 0.5, fy - 5.5, 2.8)
hero_cam.rotation_euler = (math.radians(75), 0, 0)
hero_key_obj.location = (fx, fy - 3, 5)

out_path = os.path.join(RENDER_DIR, "forge_hero.png")
scene.render.filepath = out_path
bpy.ops.render.render(write_still=True)

print("Crafting pipeline complete.")
