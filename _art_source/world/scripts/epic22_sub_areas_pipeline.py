"""Epic 22 — Town Sub-Areas pipeline (tasks 9-18, 42).

Single Blender CLI script that builds the 8 town sub-areas:
1. Outskirts (transition to wilderness)
2. Cliffs (overlook)
3. Hidden Cave (secret quest hub)
4. Sage's Garden (private)
5. Iteration Memorial (somber)
6. Underground Lounge
7. Tower Top
8. Old Ruins (pre-game lore)

Output:
  _art_source/world/town_sub_areas.blend  — single master file
"""
import bpy
import bmesh
import os
import sys
import math
import random
from mathutils import Vector, Matrix

SCRIPT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/scripts"
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from enemy_pipeline_utils import make_pbr

random.seed(22)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/town_sub_areas.blend"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS ===
mat_grass        = make_pbr("SA_Grass",       (0.30, 0.55, 0.18), 0.0, 0.80)
mat_dirt         = make_pbr("SA_Dirt",        (0.40, 0.30, 0.20), 0.0, 0.90)
mat_stone        = make_pbr("SA_Stone",       (0.55, 0.50, 0.42), 0.0, 0.85)
mat_cliff_stone  = make_pbr("SA_CliffStone",  (0.45, 0.40, 0.35), 0.0, 0.90)
mat_cave_dark    = make_pbr("SA_CaveDark",    (0.08, 0.08, 0.10), 0.0, 0.85)
mat_crystal_blue = make_pbr("SA_CrystalBlue", (0.10, 0.40, 0.85), 0.0, 0.10, (0.0, 0.85, 1.0), 6.0)
mat_garden_grass = make_pbr("SA_GardenGrass", (0.20, 0.65, 0.15), 0.0, 0.75)
mat_sage_petals  = make_pbr("SA_SagePetals",  (0.85, 0.85, 0.95), 0.0, 0.55, (0.65, 0.20, 1.0), 1.0)
mat_memorial     = make_pbr("SA_Memorial",    (0.30, 0.30, 0.35), 0.0, 0.65)
mat_memorial_glow= make_pbr("SA_MemorialGlow",(0.20, 0.10, 0.30), 0.0, 0.10, (0.65, 0.20, 1.0), 4.0)
mat_lounge_wood  = make_pbr("SA_LoungeWood",  (0.45, 0.28, 0.15), 0.0, 0.80)
mat_lounge_warm  = make_pbr("SA_LoungeWarm",  (1.0, 0.85, 0.45), 0.0, 0.10, (1.0, 0.75, 0.25), 4.0)
mat_tower_chrome = make_pbr("SA_TowerChrome", (0.85, 0.86, 0.92), 1.0, 0.10)
mat_ruin_stone   = make_pbr("SA_RuinStone",   (0.50, 0.45, 0.40), 0.0, 0.92)
mat_moss         = make_pbr("SA_Moss",        (0.20, 0.45, 0.20), 0.0, 0.85)
mat_skybox_far   = make_pbr("SA_SkyboxFar",   (0.45, 0.65, 0.95), 0.0, 0.85, (0.20, 0.45, 0.85), 1.0)


# === COLLECTIONS ===
def make_col(name):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


col_outskirts = make_col("SA_Outskirts")
col_cliffs    = make_col("SA_Cliffs")
col_cave      = make_col("SA_HiddenCave")
col_garden    = make_col("SA_SageGarden")
col_memorial  = make_col("SA_Memorial")
col_lounge    = make_col("SA_UndergroundLounge")
col_tower_top = make_col("SA_TowerTop")
col_ruins     = make_col("SA_OldRuins")


def add_to(obj, col):
    for c in obj.users_collection:
        c.objects.unlink(obj)
    col.objects.link(obj)


def cube_mesh(w, d, h):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= d * 0.5
        v.co.z *= h * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return bm


def create_mesh(name, bm, location, material, smooth=True):
    me = bpy.data.meshes.new(name + "_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    obj.location = location
    obj.data.materials.append(material)
    bpy.context.scene.collection.objects.link(obj)
    if smooth:
        for p in obj.data.polygons:
            p.use_smooth = True
    return obj


# === SUB-AREA 1: OUTSKIRTS (Task 9) ===
print("\n=== Outskirts ===")
ox = -100
oy = 0
# Transition terrain — grass becoming wild
obj = create_mesh("outskirts_grass", cube_mesh(40.0, 40.0, 0.10), (ox, oy, 0.05), mat_grass)
add_to(obj, col_outskirts)
# Worn dirt path leading away
obj = create_mesh("outskirts_path", cube_mesh(2.0, 30.0, 0.06), (ox, oy, 0.13), mat_dirt)
add_to(obj, col_outskirts)
# 5 wild rocks scattered
for i in range(5):
    angle = i * (math.tau / 5)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=0.5 + (i % 3) * 0.2)
    for v in bm.verts:
        v.co.z *= 0.6
        v.co.x *= 1.0 + random.uniform(-0.2, 0.2)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"outskirts_rock_{i+1}", bm, (ox + math.cos(angle) * 12, oy + math.sin(angle) * 12, 0.30), mat_cliff_stone)
    add_to(obj, col_outskirts)
# Old broken fence (3 segments leaning)
for i in range(3):
    obj = create_mesh(f"outskirts_fence_{i+1}", cube_mesh(2.0, 0.10, 0.80), (ox - 8 + i * 4, oy + 5, 0.40), mat_lounge_wood)
    obj.rotation_euler = (math.radians(-5 + i * 8), 0, 0)
    add_to(obj, col_outskirts)


# === SUB-AREA 2: CLIFFS (Task 10) ===
print("=== Cliffs ===")
cx = 100
cy = 0
# Cliff edge platform
obj = create_mesh("cliffs_platform", cube_mesh(20.0, 30.0, 1.0), (cx, cy, 0.50), mat_cliff_stone)
add_to(obj, col_cliffs)
# Drop-off below
obj = create_mesh("cliffs_drop", cube_mesh(20.0, 30.0, 8.0), (cx + 15, cy, -4.0), mat_cliff_stone)
add_to(obj, col_cliffs)
# Lookout viewing pole at the edge
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=10, radius1=0.10, radius2=0.10, depth=2.5, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("cliffs_pole", bm, (cx + 8, cy, 2.25), mat_tower_chrome)
add_to(obj, col_cliffs)
# Scenic view skybox plane in the distance
obj = create_mesh("cliffs_skybox", cube_mesh(50.0, 0.20, 30.0), (cx + 50, cy, 12.0), mat_skybox_far)
add_to(obj, col_cliffs)
# 4 small cairns marking the lookout
for i in range(4):
    cairn_x = cx - 5 + i * 3
    parent = bpy.data.objects.new(f"cliffs_cairn_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_cliffs)
    for j in range(3):
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=0.20 - j * 0.05)
        for v in bm.verts:
            v.co.z *= 0.6
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"cairn_{i+1}_stone_{j+1}", bm, (cairn_x, cy - 8, 1.10 + j * 0.20), mat_cliff_stone)
        obj.parent = parent
        add_to(obj, col_cliffs)


# === SUB-AREA 3: HIDDEN CAVE (Task 11) ===
print("=== Hidden Cave ===")
hx = 0
hy = -100
# Cave floor
obj = create_mesh("cave_floor", cube_mesh(20.0, 20.0, 0.20), (hx, hy, 0.10), mat_cave_dark)
add_to(obj, col_cave)
# 4 walls forming the cave (rough, dark)
for i, (x_off, y_off, sx, sy) in enumerate([(0, -10, 20, 0.5), (0, 10, 20, 0.5), (-10, 0, 0.5, 20), (10, 0, 0.5, 20)]):
    obj = create_mesh(f"cave_wall_{i+1}", cube_mesh(sx, sy, 4.0), (hx + x_off, hy + y_off, 2.0), mat_cave_dark)
    add_to(obj, col_cave)
# Cave ceiling
obj = create_mesh("cave_ceiling", cube_mesh(20.0, 20.0, 0.30), (hx, hy, 4.05), mat_cave_dark)
add_to(obj, col_cave)
# Crystal cluster in the center (cyan glow)
parent = bpy.data.objects.new("cave_crystal_cluster", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_cave)
for i in range(7):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.20 + (i % 3) * 0.06, radius2=0.04, depth=0.50 + (i % 3) * 0.20, cap_ends=True)
    tilt = math.radians(random.uniform(-20, 20))
    rot = Matrix.Rotation(tilt, 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    angle = i * (math.tau / 7)
    obj = create_mesh(f"cave_crystal_{i+1}", bm, (hx + math.cos(angle) * 0.40, hy + math.sin(angle) * 0.40, 0.30), mat_crystal_blue)
    obj.parent = parent
    add_to(obj, col_cave)
# Hidden chest pedestal
obj = create_mesh("cave_chest_pedestal", cube_mesh(1.0, 1.0, 0.40), (hx + 5, hy, 0.30), mat_cliff_stone)
add_to(obj, col_cave)


# === SUB-AREA 4: SAGE'S GARDEN (Task 12) ===
print("=== Sage's Garden ===")
sgx = -50
sgy = 60
# Garden floor (lush grass)
obj = create_mesh("garden_grass", cube_mesh(25.0, 25.0, 0.10), (sgx, sgy, 0.05), mat_garden_grass)
add_to(obj, col_garden)
# Central meditation circle (stone tiles)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=20, radius1=4.0, radius2=4.0, depth=0.10, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("garden_meditation_circle", bm, (sgx, sgy, 0.15), mat_stone)
add_to(obj, col_garden)
# 6 sage flower clusters (white-violet emissive petals)
for i in range(6):
    angle = i * (math.tau / 6)
    fx = sgx + math.cos(angle) * 8
    fy = sgy + math.sin(angle) * 8
    parent = bpy.data.objects.new(f"garden_flower_cluster_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_garden)
    for j in range(5):
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.10)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"flower_{i+1}_{j+1}", bm,
                          (fx + random.uniform(-0.30, 0.30), fy + random.uniform(-0.30, 0.30), 0.20),
                          mat_sage_petals)
        obj.parent = parent
        add_to(obj, col_garden)
# Sage's bench (where the Sage sometimes sits)
obj = create_mesh("garden_bench", cube_mesh(2.0, 0.40, 0.50), (sgx, sgy + 3, 0.50), mat_lounge_wood)
add_to(obj, col_garden)
# Reading lantern next to the bench
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=8, radius1=0.06, radius2=0.06, depth=1.5, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("garden_lantern_pole", bm, (sgx + 1.5, sgy + 3, 0.75), mat_tower_chrome)
add_to(obj, col_garden)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.18)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("garden_lantern_orb", bm, (sgx + 1.5, sgy + 3, 1.65), mat_lounge_warm)
add_to(obj, col_garden)


# === SUB-AREA 5: ITERATION MEMORIAL (Task 13) ===
print("=== Iteration Memorial ===")
mx = 50
my = 60
# Stone plaza
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=20, radius1=10.0, radius2=10.0, depth=0.20, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("memorial_plaza", bm, (mx, my, 0.10), mat_memorial)
add_to(obj, col_memorial)
# Central cenotaph (tall obelisk)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=4, radius1=0.80, radius2=0.20, depth=4.0, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("memorial_cenotaph", bm, (mx, my, 2.20), mat_memorial)
add_to(obj, col_memorial)
# Glowing seal at the top
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.30)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("memorial_seal", bm, (mx, my, 4.30), mat_memorial_glow)
add_to(obj, col_memorial)
# 9 stelae around the cenotaph (one per past iteration)
for i in range(9):
    angle = i * (math.tau / 9)
    sx = mx + math.cos(angle) * 7
    sy = my + math.sin(angle) * 7
    obj = create_mesh(f"memorial_stela_{i+1}", cube_mesh(0.40, 0.20, 1.5), (sx, sy, 0.85), mat_memorial)
    add_to(obj, col_memorial)
    # Small glowing crystal on top
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.10, radius2=0.02, depth=0.20, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"memorial_stela_crystal_{i+1}", bm, (sx, sy, 1.70), mat_memorial_glow)
    add_to(obj, col_memorial)


# === SUB-AREA 6: UNDERGROUND LOUNGE (Task 14) ===
print("=== Underground Lounge ===")
ulx = -50
uly = -60
# Floor (warm wood)
obj = create_mesh("lounge_floor", cube_mesh(20.0, 15.0, 0.20), (ulx, uly, -0.90), mat_lounge_wood)
add_to(obj, col_lounge)
# 4 walls (stone + wood paneling)
for i, (x_off, y_off, sx, sy) in enumerate([(0, -7.5, 20, 0.4), (0, 7.5, 20, 0.4), (-10, 0, 0.4, 15), (10, 0, 0.4, 15)]):
    obj = create_mesh(f"lounge_wall_{i+1}", cube_mesh(sx, sy, 3.5), (ulx + x_off, uly + y_off, 0.85), mat_stone)
    add_to(obj, col_lounge)
# Ceiling
obj = create_mesh("lounge_ceiling", cube_mesh(20.0, 15.0, 0.20), (ulx, uly, 2.70), mat_stone)
add_to(obj, col_lounge)
# Central bar counter
obj = create_mesh("lounge_bar", cube_mesh(6.0, 1.5, 1.0), (ulx, uly, -0.30), mat_lounge_wood)
add_to(obj, col_lounge)
# 3 hanging warm lanterns from the ceiling
for i in range(3):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.04, radius2=0.04, depth=0.80, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"lounge_lantern_chain_{i+1}", bm, (ulx - 4 + i * 4, uly, 2.20), mat_tower_chrome)
    add_to(obj, col_lounge)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.30)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"lounge_lantern_{i+1}", bm, (ulx - 4 + i * 4, uly, 1.50), mat_lounge_warm)
    add_to(obj, col_lounge)
# 4 stools in front of the bar
for i in range(4):
    obj = create_mesh(f"lounge_stool_{i+1}", cube_mesh(0.40, 0.40, 1.0), (ulx - 2.5 + i * 1.5, uly + 1.2, -0.30), mat_lounge_wood)
    add_to(obj, col_lounge)


# === SUB-AREA 7: TOWER TOP (Task 15) ===
print("=== Tower Top ===")
ttx = 0
tty = 100
# Top platform of the Compaction Tower
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=20, radius1=4.0, radius2=4.0, depth=0.20, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("tower_top_platform", bm, (ttx, tty, 18.0), mat_tower_chrome)
add_to(obj, col_tower_top)
# Railing around the platform
for i in range(12):
    angle = i * (math.tau / 12)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.05, radius2=0.05, depth=1.2, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tower_top_railing_{i+1}", bm, (ttx + math.cos(angle) * 3.8, tty + math.sin(angle) * 3.8, 18.70), mat_tower_chrome)
    add_to(obj, col_tower_top)
# Central spire with red status light
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=8, radius1=0.15, radius2=0.02, depth=2.5, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("tower_top_spire", bm, (ttx, tty, 19.35), mat_tower_chrome)
add_to(obj, col_tower_top)
# Red blinking light at the top
red_mat = make_pbr("SA_TowerRed", (0.85, 0.05, 0.05), 0.0, 0.10, (1.0, 0.10, 0.05), 8.0)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.10)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("tower_top_status_light", bm, (ttx, tty, 20.65), red_mat)
add_to(obj, col_tower_top)
# 2 telescope props for the lookout
for i, sx in enumerate((-1, 1)):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.10, radius2=0.04, depth=0.80, cap_ends=True)
    rot = Matrix.Rotation(math.radians(60), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tower_telescope_{i+1}", bm, (ttx + sx * 2.0, tty + 1.5, 18.45), mat_tower_chrome)
    add_to(obj, col_tower_top)


# === SUB-AREA 8: OLD RUINS (Task 16) ===
print("=== Old Ruins ===")
rx = 0
ry = -150
# Ruined floor (cracked stone, partial)
obj = create_mesh("ruins_floor", cube_mesh(30.0, 30.0, 0.10), (rx, ry, 0.05), mat_ruin_stone)
add_to(obj, col_ruins)
# 4 broken pillars (varying heights, fallen sections)
for i in range(4):
    angle = i * (math.tau / 4)
    px = rx + math.cos(angle) * 8
    py = ry + math.sin(angle) * 8
    height = random.uniform(2.0, 5.0)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.55, radius2=0.50, depth=height, cap_ends=True)
    # Slight tilt
    rot = Matrix.Rotation(math.radians(random.uniform(-15, 15)), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"ruins_pillar_{i+1}", bm, (px, py, height * 0.5), mat_ruin_stone)
    add_to(obj, col_ruins)
# 2 fallen pillar segments lying on the ground
for i in range(2):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.55, radius2=0.50, depth=3.0, cap_ends=True)
    rot = Matrix.Rotation(math.radians(80), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"ruins_fallen_{i+1}", bm, (rx + i * 4 - 2, ry + 5, 0.55), mat_ruin_stone)
    add_to(obj, col_ruins)
# Central ancient altar
obj = create_mesh("ruins_altar", cube_mesh(2.5, 2.5, 1.2), (rx, ry, 0.60), mat_ruin_stone)
add_to(obj, col_ruins)
# Moss growing on the altar (small green patches)
for i in range(4):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.30)
    for v in bm.verts:
        v.co.z *= 0.3
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    angle = i * (math.tau / 4)
    obj = create_mesh(f"ruins_moss_{i+1}", bm, (rx + math.cos(angle) * 0.8, ry + math.sin(angle) * 0.8, 1.20), mat_moss)
    add_to(obj, col_ruins)
# Lore tablet on the altar
obj = create_mesh("ruins_lore_tablet", cube_mesh(0.60, 0.04, 0.40), (rx, ry, 1.40), mat_memorial_glow)
add_to(obj, col_ruins)


# === SAVE ===
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"\nSub-Areas pipeline complete. Total mesh objects: {total}")
print(f"Saved: {OUT_BLEND}")
