"""
Epic 35 — Farming & Gathering Assets Pipeline
================================================
Builds in one Blender background pass:
  - Task 3: 80 crop sprites (20 crops × 4 growth stages, 256x256 PNG each)
  - Task 19: Greenhouse interior scene
  - Task 23: Orchard with 6 fruit trees
  - Task 24: 4 fruit tree growth stages
  - Task 31: Fish tank display prop
  - Task 46: Hero shot render of the farm
  - Task 49: Farm decoration items pack (8 items)

Saves:
  - _art_source/farming/farming_assets.blend
  - _art_source/farming/renders/crop_<id>_s<stage>.png   (80)
  - _art_source/farming/renders/farm_hero.png
  - _art_source/farming/renders/greenhouse_hero.png
  - _art_source/farming/renders/orchard_hero.png
  - _art_source/farming/renders/fruit_tree_stage_<i>.png (4)
  - _art_source/farming/renders/decor_<id>.png (8)
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, Matrix

random.seed(3535)
OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/farming/farming_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/farming/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
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
mat_dirt = make_pbr("farm_dirt", (0.28, 0.20, 0.13), 0.92)
mat_dirt_wet = make_pbr("farm_dirt_wet", (0.18, 0.13, 0.08), 0.85)
mat_grass = make_pbr("farm_grass", (0.18, 0.32, 0.12), 0.85)
mat_stem = make_pbr("farm_stem", (0.30, 0.45, 0.18), 0.85)
mat_stem_dark = make_pbr("farm_stem_dark", (0.20, 0.30, 0.10), 0.85)
mat_leaf = make_pbr("farm_leaf", (0.22, 0.50, 0.18), 0.8)
mat_leaf_bright = make_pbr("farm_leaf_bright", (0.30, 0.65, 0.22), 0.75)
mat_leaf_yellow = make_pbr("farm_leaf_yellow", (0.75, 0.78, 0.20), 0.8)
mat_wood = make_pbr("farm_wood", (0.40, 0.22, 0.10), 0.85)
mat_wood_dark = make_pbr("farm_wood_dark", (0.20, 0.12, 0.06), 0.85)
mat_glass = make_pbr("farm_glass", (0.85, 0.92, 1.0), 0.05, 0.0)
mat_water = make_pbr("farm_water", (0.10, 0.25, 0.40), 0.15, 0.0, (0.2, 0.4, 0.6), 0.4)
mat_metal = make_pbr("farm_metal", (0.55, 0.55, 0.60), 0.3, 0.95)
mat_clay = make_pbr("farm_clay", (0.65, 0.40, 0.25), 0.85)

# Crop fruit colors (one per crop type)
CROP_PALETTE = [
    ("data_wheat",     (0.95, 0.78, 0.30), "spike"),
    ("byte_carrot",    (0.95, 0.50, 0.10), "tap"),
    ("hex_potato",     (0.78, 0.55, 0.30), "tuber"),
    ("compile_corn",   (0.95, 0.85, 0.20), "spike"),
    ("ram_radish",     (0.85, 0.20, 0.20), "round"),
    ("cache_cabbage",  (0.40, 0.65, 0.30), "round"),
    ("loop_lettuce",   (0.55, 0.85, 0.35), "round"),
    ("array_apple",    (0.85, 0.20, 0.20), "round"),
    ("string_strawb",  (0.85, 0.15, 0.30), "berry"),
    ("vector_grape",   (0.55, 0.20, 0.65), "berry"),
    ("script_squash",  (0.95, 0.55, 0.10), "tuber"),
    ("kernel_pumpkin", (0.95, 0.45, 0.05), "round"),
    ("query_quinoa",   (0.85, 0.78, 0.55), "spike"),
    ("buffer_bean",    (0.30, 0.45, 0.18), "berry"),
    ("daemon_tomato",  (0.95, 0.18, 0.10), "round"),
    ("syntax_spinach", (0.20, 0.45, 0.18), "round"),
    ("token_turnip",   (0.85, 0.55, 0.65), "tap"),
    ("ptr_pepper",     (0.85, 0.20, 0.10), "tap"),
    ("static_sunflower", (0.95, 0.85, 0.20), "spike"),
    ("memory_melon",   (0.40, 0.75, 0.45), "round"),
]

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_crops = make_coll("Crops")
col_greenhouse = make_coll("Greenhouse")
col_orchard = make_coll("Orchard")
col_tree_stages = make_coll("FruitTreeStages")
col_fishtank = make_coll("FishTank")
col_farm = make_coll("Farm")
col_decor = make_coll("Decor")
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

# === Build crop at growth stage ===
def build_crop_stage(crop_name, fruit_color, kind, stage, position):
    """Stage 0=seedling, 1=sapling, 2=mature, 3=harvestable."""
    mat_fruit = make_pbr(f"crop_{crop_name}_fruit", fruit_color, 0.5)
    objs = []
    # Soil patch base
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.5, radius2=0.5, depth=0.06)
    objs.append(add_bm(f"{crop_name}_s{stage}_soil", bm, mat_dirt, col_crops, loc=position))

    if stage == 0:  # seedling — tiny green sprout
        bm = cyl(0.04, 0.10, 6)
        objs.append(add_bm(f"{crop_name}_s{stage}_sprout", bm, mat_stem, col_crops,
                           loc=(position[0], position[1], position[2] + 0.05)))
        bm = ico(0.06, 1)
        objs.append(add_bm(f"{crop_name}_s{stage}_leaf", bm, mat_leaf, col_crops,
                           loc=(position[0], position[1], position[2] + 0.13)))
        return objs

    if stage == 1:  # sapling — taller stem with 2 leaves
        bm = cyl(0.05, 0.30, 6)
        objs.append(add_bm(f"{crop_name}_s{stage}_stem", bm, mat_stem, col_crops,
                           loc=(position[0], position[1], position[2] + 0.05)))
        for s in [-1, 1]:
            bm = ico(0.10, 2)
            objs.append(add_bm(f"{crop_name}_s{stage}_leaf_{s}", bm, mat_leaf, col_crops,
                               loc=(position[0] + s*0.10, position[1], position[2] + 0.20)))
        return objs

    if stage == 2:  # mature — full plant, no fruit yet
        bm = cyl(0.07, 0.55, 6)
        objs.append(add_bm(f"{crop_name}_s{stage}_stem", bm, mat_stem_dark, col_crops,
                           loc=(position[0], position[1], position[2] + 0.05)))
        for s in [-1, 0, 1]:
            for h in [0.25, 0.45]:
                bm = ico(0.11, 2)
                objs.append(add_bm(f"{crop_name}_s{stage}_leaf_{s}_{h}", bm, mat_leaf_bright, col_crops,
                                   loc=(position[0] + s*0.13, position[1], position[2] + h)))
        return objs

    # stage == 3: harvestable — full plant + fruit per kind
    bm = cyl(0.07, 0.55, 6)
    objs.append(add_bm(f"{crop_name}_s{stage}_stem", bm, mat_stem_dark, col_crops,
                       loc=(position[0], position[1], position[2] + 0.05)))
    for s in [-1, 0, 1]:
        for h in [0.25, 0.45]:
            bm = ico(0.11, 2)
            objs.append(add_bm(f"{crop_name}_s{stage}_leaf_{s}_{h}", bm, mat_leaf_bright, col_crops,
                               loc=(position[0] + s*0.13, position[1], position[2] + h)))

    if kind == "round":
        bm = ico(0.18, 2)
        objs.append(add_bm(f"{crop_name}_s{stage}_fruit", bm, mat_fruit, col_crops,
                           loc=(position[0], position[1], position[2] + 0.55)))
    elif kind == "berry":
        for i in range(5):
            ang = (i / 5) * math.tau
            bm = ico(0.07, 1)
            objs.append(add_bm(f"{crop_name}_s{stage}_berry_{i}", bm, mat_fruit, col_crops,
                               loc=(position[0] + math.cos(ang)*0.12, position[1] + math.sin(ang)*0.12, position[2] + 0.50 + (i%2)*0.05)))
    elif kind == "tuber":
        bm = ico(0.20, 2)
        bmesh.ops.scale(bm, vec=(1.2, 0.9, 0.7), verts=bm.verts)
        objs.append(add_bm(f"{crop_name}_s{stage}_tuber", bm, mat_fruit, col_crops,
                           loc=(position[0], position[1], position[2] + 0.10)))
    elif kind == "tap":
        bm = cone(0.15, 0.04, 0.30)
        bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.pi, 3, 'X'), verts=bm.verts)
        objs.append(add_bm(f"{crop_name}_s{stage}_tap", bm, mat_fruit, col_crops,
                           loc=(position[0], position[1], position[2] + 0.10)))
    elif kind == "spike":
        bm = cone(0.08, 0.02, 0.40)
        objs.append(add_bm(f"{crop_name}_s{stage}_spike", bm, mat_fruit, col_crops,
                           loc=(position[0], position[1], position[2] + 0.55)))
    return objs

# === Build all 80 crop sprites (laid out in a grid) ===
print("=== Building 80 crop sprites ===")
all_crops = {}  # (crop_name, stage) → list of objs
for ci, (crop_name, fruit_color, kind) in enumerate(CROP_PALETTE):
    for stage in range(4):
        col = ci % 5
        row = ci // 5
        x_pos = col * 1.6 + stage * 0.0 - 3.5  # icon laid out sequentially
        y_pos = row * 1.6 - 3.5
        z_pos = stage * 5.0  # stack stages vertically (different heights so we can hide all but one)
        objs = build_crop_stage(crop_name, fruit_color, kind, stage, (x_pos, y_pos, z_pos))
        all_crops[(crop_name, stage)] = objs

# === Greenhouse interior ===
print("=== Greenhouse interior ===")
GHX, GHY = 30, 0
# Floor
add_bm("GH_Floor", cube(6, 4, 0.1), mat_dirt, col_greenhouse, loc=(GHX, GHY, 0))
# 4 corner posts
for sx, sy in [(-6, -4), (6, -4), (-6, 4), (6, 4)]:
    add_bm(f"GH_Post_{sx}_{sy}", cyl(0.15, 4, 8), mat_wood_dark, col_greenhouse,
           loc=(GHX + sx*0.5, sy*0.5, 0))
# Glass walls (4)
for px, py, sx, sy in [(0, -2, 6, 0.05), (0, 2, 6, 0.05), (-3, 0, 0.05, 4), (3, 0, 0.05, 4)]:
    add_bm(f"GH_Wall_{px}_{py}", cube(sx, sy, 1.8), mat_glass, col_greenhouse,
           loc=(GHX + px, GHY + py, 0.9))
# Glass roof (sloped)
add_bm("GH_RoofN", cube(6, 0.05, 2.0), mat_glass, col_greenhouse,
       loc=(GHX, GHY + 1.5, 2.5), rot=(math.radians(-30), 0, 0))
add_bm("GH_RoofS", cube(6, 0.05, 2.0), mat_glass, col_greenhouse,
       loc=(GHX, GHY - 1.5, 2.5), rot=(math.radians(30), 0, 0))
# Planter beds (3 rows)
for i in range(3):
    add_bm(f"GH_Planter_{i}", cube(5, 0.6, 0.4), mat_wood, col_greenhouse,
           loc=(GHX, GHY - 1.5 + i*1.5, 0.2))
    # Soil inside
    add_bm(f"GH_PlanterSoil_{i}", cube(4.8, 0.55, 0.05), mat_dirt_wet, col_greenhouse,
           loc=(GHX, GHY - 1.5 + i*1.5, 0.42))
    # Crop sprites in each planter
    for j in range(5):
        add_bm(f"GH_Plant_{i}_{j}_stem", cyl(0.05, 0.5, 6), mat_stem_dark, col_greenhouse,
               loc=(GHX - 2 + j*1, GHY - 1.5 + i*1.5, 0.5))
        add_bm(f"GH_Plant_{i}_{j}_fruit", ico(0.13, 2), mat_leaf_bright, col_greenhouse,
               loc=(GHX - 2 + j*1, GHY - 1.5 + i*1.5, 0.95))

# Hanging lanterns
for i in range(4):
    add_bm(f"GH_Lantern_{i}", cube(0.2, 0.2, 0.3), mat_metal, col_greenhouse,
           loc=(GHX - 2 + i*1.5, GHY, 2.4))

# === Orchard with 6 fruit trees ===
print("=== Orchard ===")
OX, OY = 50, 0
# Grass field
add_bm("Or_Floor", cube(10, 6, 0.1), mat_grass, col_orchard, loc=(OX, OY, 0))
# 6 mature fruit trees in 2 rows
fruit_palette = [(0.85, 0.20, 0.20), (0.95, 0.55, 0.20), (0.20, 0.55, 0.85), (0.85, 0.78, 0.20), (0.55, 0.20, 0.65), (0.55, 0.85, 0.30)]
for i in range(6):
    col = i % 3
    row = i // 3
    tx = OX - 6 + col * 4
    ty = OY - 2 + row * 4
    # Trunk
    add_bm(f"Or_Trunk_{i}", cyl(0.25, 2.5, 12), mat_wood_dark, col_orchard, loc=(tx, ty, 0))
    # Canopy
    add_bm(f"Or_Canopy_{i}", ico(1.4, 3), mat_leaf_bright, col_orchard, loc=(tx, ty, 3.0))
    # Fruits scattered on canopy
    fruit_color = fruit_palette[i]
    fruit_mat = make_pbr(f"or_fruit_{i}", fruit_color, 0.5)
    for f in range(8):
        ang = (f / 8) * math.tau
        h = random.uniform(2.2, 3.6)
        r = random.uniform(0.7, 1.2)
        add_bm(f"Or_Fruit_{i}_{f}", ico(0.15, 1), fruit_mat, col_orchard,
               loc=(tx + math.cos(ang)*r, ty + math.sin(ang)*r, h))

# === 4 Fruit tree growth stages ===
print("=== Fruit tree stages ===")
TSX = 70
def build_fruit_tree_stage(stage, x_off):
    objs = []
    if stage == 0:  # sapling
        objs.append(add_bm(f"FT_s0_stem", cyl(0.06, 0.5, 6), mat_stem, col_tree_stages, loc=(x_off, 0, 0)))
        objs.append(add_bm(f"FT_s0_leaf", ico(0.15, 2), mat_leaf, col_tree_stages, loc=(x_off, 0, 0.55)))
    elif stage == 1:  # young tree
        objs.append(add_bm(f"FT_s1_trunk", cyl(0.12, 1.2, 8), mat_wood, col_tree_stages, loc=(x_off, 0, 0)))
        objs.append(add_bm(f"FT_s1_canopy", ico(0.55, 2), mat_leaf, col_tree_stages, loc=(x_off, 0, 1.3)))
    elif stage == 2:  # adult, no fruit
        objs.append(add_bm(f"FT_s2_trunk", cyl(0.22, 2.2, 12), mat_wood_dark, col_tree_stages, loc=(x_off, 0, 0)))
        objs.append(add_bm(f"FT_s2_canopy", ico(1.2, 3), mat_leaf_bright, col_tree_stages, loc=(x_off, 0, 2.7)))
    else:  # fruit-bearing
        objs.append(add_bm(f"FT_s3_trunk", cyl(0.25, 2.5, 12), mat_wood_dark, col_tree_stages, loc=(x_off, 0, 0)))
        objs.append(add_bm(f"FT_s3_canopy", ico(1.4, 3), mat_leaf_bright, col_tree_stages, loc=(x_off, 0, 3.0)))
        for f in range(6):
            ang = (f / 6) * math.tau
            objs.append(add_bm(f"FT_s3_fruit_{f}", ico(0.18, 2), make_pbr(f"ft_fruit_{f}", (0.85, 0.20, 0.20), 0.5),
                               col_tree_stages, loc=(x_off + math.cos(ang)*0.9, math.sin(ang)*0.9, 3.1)))
    return objs

tree_stage_objs = {}
for stage in range(4):
    tree_stage_objs[stage] = build_fruit_tree_stage(stage, TSX + stage * 4)

# === Fish tank display ===
print("=== Fish tank display ===")
FTX, FTY = 90, 0
# Tank base
add_bm("FT_Base", cube(2.0, 1.0, 0.2), mat_wood_dark, col_fishtank, loc=(FTX, FTY, 0.1))
# Glass walls (4)
add_bm("FT_GlassN", cube(2.0, 0.04, 1.4), mat_glass, col_fishtank, loc=(FTX, FTY + 0.5, 0.9))
add_bm("FT_GlassS", cube(2.0, 0.04, 1.4), mat_glass, col_fishtank, loc=(FTX, FTY - 0.5, 0.9))
add_bm("FT_GlassE", cube(0.04, 1.0, 1.4), mat_glass, col_fishtank, loc=(FTX + 1.0, FTY, 0.9))
add_bm("FT_GlassW", cube(0.04, 1.0, 1.4), mat_glass, col_fishtank, loc=(FTX - 1.0, FTY, 0.9))
# Water inside
add_bm("FT_Water", cube(1.85, 0.85, 1.1), mat_water, col_fishtank, loc=(FTX, FTY, 0.85))
# Sand bottom
add_bm("FT_Sand", cube(1.85, 0.85, 0.05), mat_clay, col_fishtank, loc=(FTX, FTY, 0.25))
# 5 fish (small icospheres)
for i in range(5):
    fish_color = [(0.85, 0.55, 0.20), (0.30, 0.55, 0.85), (0.85, 0.35, 0.45), (0.30, 0.85, 0.55), (0.85, 0.85, 0.30)][i]
    fish_mat = make_pbr(f"FT_fish_{i}", fish_color, 0.4)
    fish = ico(0.10, 2)
    bmesh.ops.scale(fish, vec=(1.6, 0.6, 0.8), verts=fish.verts)
    add_bm(f"FT_Fish_{i}", fish, fish_mat, col_fishtank,
           loc=(FTX - 0.7 + i*0.3, FTY + (i%2)*0.2 - 0.1, 0.9 + (i%3)*0.15))
# Tank lid + light strip
add_bm("FT_Lid", cube(2.05, 1.05, 0.1), mat_wood_dark, col_fishtank, loc=(FTX, FTY, 1.65))
add_bm("FT_LightStrip", cube(1.8, 0.05, 0.05), make_pbr("FT_light", (1.0, 0.95, 0.85), 0.3, 0.0, (1.0, 0.95, 0.85), 4.0),
       col_fishtank, loc=(FTX, FTY, 1.55))

# === Farm hero scene ===
print("=== Farm hero scene ===")
FX, FY = 0, 30
# Big grass field
add_bm("Farm_Grass", cube(15, 12, 0.1), mat_grass, col_farm, loc=(FX, FY, 0))
# 5 plowed rows
for i in range(5):
    add_bm(f"Farm_Row_{i}", cube(12, 0.8, 0.1), mat_dirt, col_farm,
           loc=(FX, FY - 4 + i*2, 0.05))
    # Crops (mature)
    for j in range(8):
        add_bm(f"Farm_RowStem_{i}_{j}", cyl(0.06, 0.6, 6), mat_stem_dark, col_farm,
               loc=(FX - 5 + j*1.4, FY - 4 + i*2, 0.3))
        add_bm(f"Farm_RowFruit_{i}_{j}", ico(0.18, 2),
               make_pbr(f"farm_fruit_{i}_{j}", (0.85, 0.55, 0.20), 0.5),
               col_farm, loc=(FX - 5 + j*1.4, FY - 4 + i*2, 0.65))
# Fence (perimeter)
for i in range(8):
    add_bm(f"Farm_FencePostN_{i}", cyl(0.1, 1.2, 6), mat_wood_dark, col_farm,
           loc=(FX - 7 + i*2, FY + 6, 0.6))
    add_bm(f"Farm_FencePostS_{i}", cyl(0.1, 1.2, 6), mat_wood_dark, col_farm,
           loc=(FX - 7 + i*2, FY - 6, 0.6))
# Tool shed
add_bm("Farm_Shed", cube(1.5, 1.5, 1.8), mat_wood, col_farm, loc=(FX + 6, FY + 5, 0.9))
add_bm("Farm_ShedRoof", cube(1.7, 1.7, 0.1), mat_wood_dark, col_farm, loc=(FX + 6, FY + 5, 1.85))
# Scarecrow (center)
add_bm("Farm_Scarecrow_Pole", cyl(0.06, 1.6, 6), mat_wood_dark, col_farm, loc=(FX, FY + 1, 0.8))
add_bm("Farm_Scarecrow_Arm", cube(0.8, 0.04, 0.04), mat_wood_dark, col_farm, loc=(FX, FY + 1, 1.4))
add_bm("Farm_Scarecrow_Head", ico(0.22, 2), make_pbr("scarecrow_head", (0.85, 0.78, 0.55), 0.85),
       col_farm, loc=(FX, FY + 1, 1.85))

# === 8 farm decoration items ===
print("=== Farm decorations ===")
DX = -25
DECORS = []
# 1. Garden gnome
add_bm("Decor_Gnome_Base", cyl(0.18, 0.3, 8), make_pbr("dec_gnome_base", (0.30, 0.30, 0.35), 0.7), col_decor, loc=(DX, 0, 0.15))
add_bm("Decor_Gnome_Body", ico(0.18, 2), make_pbr("dec_gnome_body", (0.85, 0.20, 0.20), 0.5), col_decor, loc=(DX, 0, 0.45))
add_bm("Decor_Gnome_Hat", cone(0.18, 0.0, 0.35), make_pbr("dec_gnome_hat", (0.85, 0.20, 0.20), 0.5), col_decor, loc=(DX, 0, 0.65))
DECORS.append("gnome")

# 2. Bird bath
add_bm("Decor_BirdBath_Pedestal", cyl(0.15, 0.8, 12), make_pbr("dec_bird_p", (0.85, 0.83, 0.80), 0.5), col_decor, loc=(DX + 2, 0, 0.4))
add_bm("Decor_BirdBath_Bowl", cyl(0.4, 0.1, 16), make_pbr("dec_bird_b", (0.85, 0.83, 0.80), 0.5), col_decor, loc=(DX + 2, 0, 0.85))
add_bm("Decor_BirdBath_Water", cyl(0.35, 0.05, 16), mat_water, col_decor, loc=(DX + 2, 0, 0.92))
DECORS.append("bird_bath")

# 3. Wooden bench
add_bm("Decor_Bench_Seat", cube(1.0, 0.3, 0.1), mat_wood, col_decor, loc=(DX + 4, 0, 0.4))
add_bm("Decor_Bench_Back", cube(1.0, 0.05, 0.5), mat_wood, col_decor, loc=(DX + 4, 0.13, 0.65))
add_bm("Decor_Bench_LegL", cube(0.08, 0.3, 0.4), mat_wood_dark, col_decor, loc=(DX + 3.55, 0, 0.2))
add_bm("Decor_Bench_LegR", cube(0.08, 0.3, 0.4), mat_wood_dark, col_decor, loc=(DX + 4.45, 0, 0.2))
DECORS.append("bench")

# 4. Lantern post
add_bm("Decor_LanternPost", cyl(0.06, 1.4, 6), mat_metal, col_decor, loc=(DX + 6, 0, 0.7))
add_bm("Decor_LanternHead", cube(0.25, 0.25, 0.25),
       make_pbr("dec_lantern_h", (1.0, 0.85, 0.45), 0.4, 0.0, (1.0, 0.85, 0.45), 3.0),
       col_decor, loc=(DX + 6, 0, 1.55))
DECORS.append("lantern_post")

# 5. Flower pot
add_bm("Decor_Pot", cyl(0.2, 0.3, 12), make_pbr("dec_pot", (0.65, 0.40, 0.25), 0.85), col_decor, loc=(DX + 8, 0, 0.15))
add_bm("Decor_Pot_Soil", cyl(0.18, 0.04, 12), mat_dirt, col_decor, loc=(DX + 8, 0, 0.32))
add_bm("Decor_Pot_Flower", ico(0.12, 2),
       make_pbr("dec_flower", (0.95, 0.35, 0.55), 0.5),
       col_decor, loc=(DX + 8, 0, 0.45))
DECORS.append("flower_pot")

# 6. Wooden barrel
add_bm("Decor_Barrel", cyl(0.32, 0.65, 12), make_pbr("dec_barrel", (0.45, 0.25, 0.10), 0.85), col_decor, loc=(DX + 10, 0, 0.32))
add_bm("Decor_Barrel_Band1", cyl(0.33, 0.04, 12), mat_metal, col_decor, loc=(DX + 10, 0, 0.55))
add_bm("Decor_Barrel_Band2", cyl(0.33, 0.04, 12), mat_metal, col_decor, loc=(DX + 10, 0, 0.10))
DECORS.append("barrel")

# 7. Stone path tile
add_bm("Decor_PathTile", cube(0.5, 0.5, 0.05), make_pbr("dec_tile", (0.55, 0.52, 0.48), 0.85), col_decor, loc=(DX + 12, 0, 0.025))
DECORS.append("path_tile")

# 8. Wind chime
add_bm("Decor_ChimePost", cyl(0.04, 1.0, 6), mat_wood_dark, col_decor, loc=(DX + 14, 0, 0.5))
for i in range(4):
    add_bm(f"Decor_ChimeRod_{i}", cyl(0.02, 0.4, 6), mat_metal, col_decor,
           loc=(DX + 14 + (i-1.5)*0.08, 0, 0.7))
DECORS.append("wind_chime")

# === Cameras + Lights ===
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 70
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

hero_cam_data = bpy.data.cameras.new("Hero_Cam")
hero_cam_data.lens = 50
hero_cam = bpy.data.objects.new("Hero_Cam", hero_cam_data)
hero_cam.rotation_euler = (math.radians(70), 0, 0)
scene.collection.objects.link(hero_cam)
link_to(hero_cam, col_cam)

# Lights
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 1500
key_data.size = 8
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, 0, 15)
key_obj.rotation_euler = (math.radians(40), math.radians(-15), 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 350
fill_data.size = 10
fill_data.color = (0.7, 0.85, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (0, 5, 8)
fill_obj.rotation_euler = (math.radians(70), 0, 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

# World
world = bpy.data.worlds.new("World_Farm")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.55, 0.70, 0.90, 1.0)
bg.inputs['Strength'].default_value = 0.8

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# === Render 80 crop sprites ===
print("=== Rendering 80 crop sprites ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

# Hide everything else
for col in [col_greenhouse, col_orchard, col_tree_stages, col_fishtank, col_farm, col_decor]:
    for obj in col.objects:
        obj.hide_render = True

for key in all_crops.keys():
    crop_name, stage = key
    objs = all_crops[key]
    # Hide all crops
    for k2, o2_list in all_crops.items():
        for o in o2_list:
            o.hide_render = (k2 != key)
    # Center camera on this crop
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    cz = sum(o.location.z for o in objs) / len(objs)
    icon_cam.location = (cx, cy - 0.9, cz + 1.1)
    out_path = os.path.join(RENDER_DIR, f"crop_{crop_name}_s{stage}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render fruit tree stages (4) ===
print("=== Rendering fruit tree stages ===")
scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.film_transparent = True
# Hide all crops
for k2, o2_list in all_crops.items():
    for o in o2_list:
        o.hide_render = True

for stage in range(4):
    # Hide all tree stages except this one
    for s2, o2_list in tree_stage_objs.items():
        for o in o2_list:
            o.hide_render = (s2 != stage)
    cx = TSX + stage * 4
    icon_cam.location = (cx, -3.5, 2.5)
    icon_cam.rotation_euler = (math.radians(75), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"fruit_tree_stage_{stage}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render decoration items ===
print("=== Rendering decor items ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
# Hide tree stages
for s2, o2_list in tree_stage_objs.items():
    for o in o2_list:
        o.hide_render = True
# Show only decor (one at a time)
decor_groups = {}
for obj in col_decor.objects:
    key = obj.name.split("_")[1].lower()
    decor_groups.setdefault(key, []).append(obj)
for dname, objs in decor_groups.items():
    for obj in col_decor.objects:
        obj.hide_render = obj not in objs
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    icon_cam.location = (cx, cy - 1.5, 1.6)
    icon_cam.rotation_euler = (math.radians(75), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"decor_{dname.lower()}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Hero shots ===
print("=== Hero shots ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False

scene.camera = hero_cam

# Farm hero
for col in [col_crops, col_greenhouse, col_orchard, col_tree_stages, col_fishtank, col_decor]:
    for obj in col.objects:
        obj.hide_render = True
for obj in col_farm.objects:
    obj.hide_render = False
hero_cam.location = (FX + 6, FY - 16, 8)
hero_cam.rotation_euler = (math.radians(72), 0, math.radians(15))
scene.render.filepath = os.path.join(RENDER_DIR, "farm_hero.png")
bpy.ops.render.render(write_still=True)

# Greenhouse hero
for obj in col_farm.objects:
    obj.hide_render = True
for obj in col_greenhouse.objects:
    obj.hide_render = False
hero_cam.location = (GHX + 8, GHY - 6, 5)
hero_cam.rotation_euler = (math.radians(75), 0, math.radians(-30))
scene.render.filepath = os.path.join(RENDER_DIR, "greenhouse_hero.png")
bpy.ops.render.render(write_still=True)

# Orchard hero
for obj in col_greenhouse.objects:
    obj.hide_render = True
for obj in col_orchard.objects:
    obj.hide_render = False
hero_cam.location = (OX + 10, OY - 8, 6)
hero_cam.rotation_euler = (math.radians(72), 0, math.radians(-25))
scene.render.filepath = os.path.join(RENDER_DIR, "orchard_hero.png")
bpy.ops.render.render(write_still=True)

print("Farming pipeline complete.")
