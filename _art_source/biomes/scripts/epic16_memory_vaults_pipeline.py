"""Epic 16 — Memory Vaults Biome pipeline (tasks 2-25, 35-37, 40-46).

Single Blender CLI script that builds the entire Memory Vaults dungeon biome.

Output:
  _art_source/biomes/memory_vaults.blend  — single master file with all collections

Run via:
    blender.exe --background --python _art_source/biomes/scripts/epic16_memory_vaults_pipeline.py
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

random.seed(16)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/biomes/memory_vaults.blend"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS (gold + violet vaults palette) ===
mat_floor      = make_pbr("MV_Floor",     (0.18, 0.15, 0.10), 0.4, 0.55)
mat_inlay      = make_pbr("MV_Inlay",     (0.85, 0.65, 0.20), 1.0, 0.20, (1.0, 0.75, 0.30), 1.5)
mat_wall_stone = make_pbr("MV_WallStone", (0.20, 0.18, 0.15), 0.0, 0.75)
mat_wall_gold  = make_pbr("MV_WallGold",  (0.25, 0.20, 0.12), 0.4, 0.55)
mat_ceiling    = make_pbr("MV_Ceiling",   (0.10, 0.08, 0.06), 0.0, 0.75)
mat_chrome_gold= make_pbr("MV_ChromeGold",(0.85, 0.65, 0.20), 1.0, 0.10)
mat_dark       = make_pbr("MV_Dark",      (0.05, 0.04, 0.04), 0.4, 0.65)
mat_seal       = make_pbr("MV_Seal",      (0.45, 0.10, 0.85), 0.0, 0.20, (0.65, 0.20, 1.0), 5.0)
mat_crystal_gold   = make_pbr("MV_CrystalGold",   (0.85, 0.65, 0.20), 0.0, 0.05, (1.0, 0.75, 0.30), 8.0)
mat_crystal_violet = make_pbr("MV_CrystalViolet", (0.45, 0.10, 0.85), 0.0, 0.05, (0.65, 0.20, 1.0), 8.0)
mat_crystal_white  = make_pbr("MV_CrystalWhite",  (0.85, 0.85, 0.95), 0.0, 0.05, (0.95, 0.95, 1.0), 8.0)
mat_crystal_red    = make_pbr("MV_CrystalRed",    (0.85, 0.10, 0.10), 0.0, 0.05, (1.0, 0.10, 0.05), 8.0)
mat_orb        = make_pbr("MV_Orb",       (0.0, 0.45, 0.55), 0.0, 0.05, (0.0, 0.85, 1.0), 6.0)
mat_glyph      = make_pbr("MV_Glyph",     (0.65, 0.20, 0.85), 0.0, 0.05, (0.85, 0.30, 1.0), 4.0)
mat_laser      = make_pbr("MV_Laser",     (0.40, 0.0, 0.10),  0.0, 0.10, (1.0, 0.10, 0.05), 6.0)


# === COLLECTIONS ===
def make_col(name):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


col_tiles = make_col("MV_Tileset")
col_props = make_col("MV_Props")
col_traps = make_col("MV_Traps")
col_rooms = make_col("MV_Rooms")


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


# === TILESET (Tasks 2-5) ===

# Floor inlaid
obj = create_mesh("tile_floor_inlaid", cube_mesh(4.0, 4.0, 0.10), (0, 0, 0.05), mat_floor)
add_to(obj, col_tiles)
# Inlaid gold pattern — 2 perpendicular strips
obj = create_mesh("tile_floor_inlay_x", cube_mesh(3.6, 0.08, 0.06), (0, 0, 0.10), mat_inlay)
add_to(obj, col_tiles)
obj = create_mesh("tile_floor_inlay_y", cube_mesh(0.08, 3.6, 0.06), (0, 0, 0.10), mat_inlay)
add_to(obj, col_tiles)
# 4 corner gold studs
for sx in (-1, 1):
    for sy in (-1, 1):
        obj = create_mesh(f"tile_floor_stud_{sx}_{sy}", cube_mesh(0.20, 0.20, 0.04), (sx * 1.7, sy * 1.7, 0.10), mat_inlay)
        add_to(obj, col_tiles)

# Wall vault — reinforced with seal
obj = create_mesh("tile_wall_vault", cube_mesh(4.0, 0.40, 3.0), (5, 0, 1.5), mat_wall_stone)
add_to(obj, col_tiles)
# Reinforcement bars — 3 horizontal chrome bars
for z in (0.6, 1.5, 2.4):
    obj = create_mesh(f"tile_wall_vault_bar_{int(z*10)}", cube_mesh(3.6, 0.05, 0.08), (5, -0.22, z), mat_chrome_gold)
    add_to(obj, col_tiles)
# Central seal (violet emissive disk)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=0.30)
for v in bm.verts:
    v.co.y *= 0.20
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("tile_wall_vault_seal", bm, (5, -0.25, 1.5), mat_seal)
add_to(obj, col_tiles)

# Wall archive — shelves with crystal inserts
obj = create_mesh("tile_wall_archive", cube_mesh(4.0, 0.40, 3.0), (10, 0, 1.5), mat_wall_stone)
add_to(obj, col_tiles)
# 3 shelf rows
for z in (0.7, 1.4, 2.1):
    obj = create_mesh(f"tile_wall_archive_shelf_{int(z*10)}", cube_mesh(3.6, 0.30, 0.06), (10, -0.05, z), mat_chrome_gold)
    add_to(obj, col_tiles)
    # 5 crystal inserts per shelf
    for j in range(5):
        x = -1.6 + j * 0.8
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=6, radius1=0.10, radius2=0.04, depth=0.18, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        crystal_mat = [mat_crystal_gold, mat_crystal_violet, mat_crystal_white][j % 3]
        obj = create_mesh(f"tile_wall_archive_crystal_{int(z*10)}_{j}", bm, (10 + x, -0.10, z + 0.10), crystal_mat)
        add_to(obj, col_tiles)

# Wall blank
obj = create_mesh("tile_wall_blank", cube_mesh(4.0, 0.40, 3.0), (15, 0, 1.5), mat_wall_stone)
add_to(obj, col_tiles)

# Ceiling orb — hanging memory orbs from ceiling
obj = create_mesh("tile_ceiling_orb", cube_mesh(4.0, 4.0, 0.10), (0, 5, 3.05), mat_ceiling)
add_to(obj, col_tiles)
# 4 hanging orbs in a 2x2 grid
for i in range(2):
    for j in range(2):
        x = -1.0 + i * 2.0
        y = 5 - 1.0 + j * 2.0
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.18)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        orb_mat = [mat_crystal_gold, mat_crystal_violet, mat_crystal_white, mat_orb][i * 2 + j]
        obj = create_mesh(f"tile_ceiling_orb_{i}_{j}", bm, (x, y, 2.50), orb_mat)
        add_to(obj, col_tiles)

# Ceiling glyph
obj = create_mesh("tile_ceiling_glyph", cube_mesh(4.0, 4.0, 0.10), (5, 5, 3.05), mat_ceiling)
add_to(obj, col_tiles)
# Floating glyph — small flat plate with violet emission
for i in range(3):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.20
        v.co.y *= 0.20
        v.co.z *= 0.02
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tile_ceiling_glyph_{i}", bm, (5 + (i - 1) * 0.6, 5, 2.70), mat_glyph)
    add_to(obj, col_tiles)

# Corner trim
obj = create_mesh("tile_corner_inside", cube_mesh(0.30, 0.30, 3.0), (10, 5, 1.5), mat_chrome_gold)
add_to(obj, col_tiles)
obj = create_mesh("tile_corner_outside", cube_mesh(0.30, 0.30, 3.0), (12, 5, 1.5), mat_chrome_gold)
add_to(obj, col_tiles)

# T junction
parent = bpy.data.objects.new("tile_t_junction", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_tiles)
for i, (x, y, rot_z) in enumerate([(15, 5, 0), (15, 4, 90), (15, 6, 90)]):
    obj = create_mesh(f"tile_t_junction_arm_{i+1}", cube_mesh(2.0, 0.40, 3.0), (x, y, 1.5), mat_wall_stone)
    obj.rotation_euler = (0, 0, math.radians(rot_z))
    obj.parent = parent
    add_to(obj, col_tiles)

# X junction
parent = bpy.data.objects.new("tile_x_junction", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_tiles)
for i, rot_z in enumerate([0, 90, 180, 270]):
    obj = create_mesh(f"tile_x_junction_arm_{i+1}", cube_mesh(2.0, 0.40, 3.0), (20, 5, 1.5), mat_wall_stone)
    obj.rotation_euler = (0, 0, math.radians(rot_z))
    obj.parent = parent
    add_to(obj, col_tiles)

# Vault door blocker (massive end cap)
parent = bpy.data.objects.new("tile_vault_door_blocker", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_tiles)
obj = create_mesh("tile_vault_blocker_wall", cube_mesh(4.0, 0.60, 3.0), (25, 5, 1.5), mat_wall_stone)
obj.parent = parent
add_to(obj, col_tiles)
# Massive central seal (large violet emissive)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=0.80)
for v in bm.verts:
    v.co.y *= 0.15
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("tile_vault_blocker_seal", bm, (25, 4.65, 1.5), mat_seal)
obj.parent = parent
add_to(obj, col_tiles)

# Standard door (reinforced 2.5x3.0x0.20)
obj = create_mesh("tile_door", cube_mesh(2.5, 0.20, 3.0), (28, 5, 1.5), mat_chrome_gold)
add_to(obj, col_tiles)
# Gold accent strip
obj = create_mesh("tile_door_accent", cube_mesh(2.0, 0.10, 0.08), (28, 4.85, 2.7), mat_inlay)
add_to(obj, col_tiles)


# ===========================================================
# === HERO PROPS (Tasks 6, 9-15) ===
# ===========================================================

# 4 vault door hero variants (Task 6)
for i in range(4):
    parent = bpy.data.objects.new(f"prop_vault_door_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    # Door body
    obj = create_mesh(f"vault_door_{i+1}_body", cube_mesh(3.0, 0.40, 4.0), (i * 4 - 6, -10, 2.0), mat_wall_stone)
    obj.parent = parent
    add_to(obj, col_props)
    # Reinforcement bars (4 horizontal)
    for z in (0.6, 1.5, 2.4, 3.3):
        obj = create_mesh(f"vault_door_{i+1}_bar_{int(z*10)}", cube_mesh(2.6, 0.05, 0.10), (i * 4 - 6, -10.22, z), mat_chrome_gold)
        obj.parent = parent
        add_to(obj, col_props)
    # Central glowing seal — different color per variant
    seal_mats = [mat_seal, mat_crystal_gold, mat_crystal_violet, mat_crystal_white]
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=14, radius=0.45)
    for v in bm.verts:
        v.co.y *= 0.15
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"vault_door_{i+1}_seal", bm, (i * 4 - 6, -10.25, 2.0), seal_mats[i])
    obj.parent = parent
    add_to(obj, col_props)

# 8 memory crystal variants (Task 9)
crystal_mats = [
    mat_crystal_gold, mat_crystal_violet, mat_crystal_white, mat_crystal_red,
    mat_orb, mat_glyph, mat_seal, mat_inlay,
]
for i in range(8):
    parent = bpy.data.objects.new(f"prop_memory_crystal_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    # Floating crystal shape
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.20, radius2=0.04, depth=0.50, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"memory_crystal_{i+1}_top", bm, (10 + i * 0.8, -10, 1.30), crystal_mats[i])
    obj.parent = parent
    add_to(obj, col_props)
    # Mirrored bottom (gives the floating crystal "double cone" silhouette)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.20, radius2=0.04, depth=0.50, cap_ends=True)
    rot = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"memory_crystal_{i+1}_bot", bm, (10 + i * 0.8, -10, 0.90), crystal_mats[i])
    obj.parent = parent
    add_to(obj, col_props)

# Archive shelf prop (Task 10)
parent = bpy.data.objects.new("prop_archive_shelf", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Tall shelf body
obj = create_mesh("archive_shelf_body", cube_mesh(2.5, 0.50, 2.8), (20, -10, 1.40), mat_wall_stone)
obj.parent = parent
add_to(obj, col_props)
# 4 shelves
for z in (0.4, 1.0, 1.6, 2.2):
    obj = create_mesh(f"archive_shelf_row_{int(z*10)}", cube_mesh(2.4, 0.50, 0.04), (20, -10, z), mat_chrome_gold)
    obj.parent = parent
    add_to(obj, col_props)
    # 5 crystals per shelf
    for j in range(5):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=6, radius1=0.06, radius2=0.02, depth=0.18, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        crystal_mat = crystal_mats[(int(z*10) + j) % len(crystal_mats)]
        obj = create_mesh(f"archive_shelf_crystal_{int(z*10)}_{j}", bm, (20 + (j - 2) * 0.45, -10 + 0.05, z + 0.10), crystal_mat)
        obj.parent = parent
        add_to(obj, col_props)

# Pedestal display prop (Task 11)
parent = bpy.data.objects.new("prop_pedestal_display", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Base
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=0.45, radius2=0.35, depth=1.0, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("pedestal_base", bm, (23, -10, 0.50), mat_wall_stone)
obj.parent = parent
add_to(obj, col_props)
# Top platform
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=0.40, radius2=0.40, depth=0.10, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("pedestal_top", bm, (23, -10, 1.05), mat_chrome_gold)
obj.parent = parent
add_to(obj, col_props)
# Floating crystal on top
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=6, radius1=0.18, radius2=0.04, depth=0.40, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("pedestal_crystal", bm, (23, -10, 1.40), mat_crystal_gold)
obj.parent = parent
add_to(obj, col_props)

# Floating data orb prop (Task 12)
parent = bpy.data.objects.new("prop_floating_orb", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=0.30)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("floating_orb_sphere", bm, (25, -10, 1.5), mat_orb)
obj.parent = parent
add_to(obj, col_props)
# Ring around it
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=0.45, radius2=0.45, depth=0.04, cap_ends=False)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("floating_orb_ring", bm, (25, -10, 1.5), mat_chrome_gold)
obj.parent = parent
add_to(obj, col_props)

# Sealed sarcophagus (Task 13)
parent = bpy.data.objects.new("prop_sealed_sarcophagus", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Base box
obj = create_mesh("sarc_body", cube_mesh(1.0, 2.4, 0.80), (27, -10, 0.40), mat_wall_stone)
obj.parent = parent
add_to(obj, col_props)
# Lid (slightly larger)
obj = create_mesh("sarc_lid", cube_mesh(1.05, 2.45, 0.15), (27, -10, 0.875), mat_wall_stone)
obj.parent = parent
add_to(obj, col_props)
# Glowing cyan seal in the center
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.30
    v.co.y *= 0.50
    v.co.z *= 0.01
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("sarc_seal", bm, (27, -10, 0.96), mat_orb)
obj.parent = parent
add_to(obj, col_props)

# Forbidden seal door variant (Task 14)
parent = bpy.data.objects.new("prop_forbidden_seal_door", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
obj = create_mesh("forbidden_door_body", cube_mesh(3.0, 0.40, 4.0), (30, -10, 2.0), mat_dark)
obj.parent = parent
add_to(obj, col_props)
# 6 violet lockdown seals in a hex pattern
for i in range(6):
    angle = i * (math.tau / 6)
    x = math.cos(angle) * 0.8
    z = 2.0 + math.sin(angle) * 0.8
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.18)
    for v in bm.verts:
        v.co.y *= 0.25
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"forbidden_door_seal_{i+1}", bm, (30 + x, -10.25, z), mat_seal)
    obj.parent = parent
    add_to(obj, col_props)

# Security barrier prop (Task 15)
parent = bpy.data.objects.new("prop_security_barrier", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# 2 vertical posts
for sx in (-1, 1):
    obj = create_mesh(f"security_post_{sx}", cube_mesh(0.10, 0.10, 3.0), (33 + sx * 1.0, -10, 1.5), mat_chrome_gold)
    obj.parent = parent
    add_to(obj, col_props)
# 5 horizontal laser beams
for i, z in enumerate([0.5, 1.0, 1.5, 2.0, 2.5]):
    obj = create_mesh(f"security_laser_{i+1}", cube_mesh(2.0, 0.04, 0.04), (33, -10, z), mat_laser)
    obj.parent = parent
    add_to(obj, col_props)

# Levitating debris (Task 24) — 5 small floating chunks
for i in range(5):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.15 + (i % 3) * 0.05
        v.co.y *= 0.15 + (i % 3) * 0.05
        v.co.z *= 0.15 + (i % 3) * 0.05
    rot = Matrix.Rotation(math.radians(i * 23), 4, 'Z') @ Matrix.Rotation(math.radians(i * 17), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"prop_levitating_debris_{i+1}", bm, (35 + i * 0.8, -10, 1.5), mat_wall_stone)
    add_to(obj, col_props)

# Collapsing ceiling event prop (Task 41)
parent = bpy.data.objects.new("prop_collapsing_ceiling", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
for i in range(6):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.30
        v.co.y *= 0.30
        v.co.z *= 0.20
    rot = Matrix.Rotation(math.radians(random.randint(-20, 20)), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"collapse_chunk_{i+1}", bm, (40 + i * 0.4, -10, 2.5 + (i % 2) * 0.3), mat_wall_stone)
    obj.parent = parent
    add_to(obj, col_props)

# Floating bridge / gap puzzle prop (Task 44)
parent = bpy.data.objects.new("prop_floating_bridge", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
for i in range(5):
    obj = create_mesh(f"floating_bridge_seg_{i+1}", cube_mesh(1.5, 1.5, 0.10), (45 + i * 1.6, -10, 0.05 + (i % 2) * 0.02), mat_chrome_gold)
    obj.parent = parent
    add_to(obj, col_props)
    # Cyan emission accent strip on each segment
    obj = create_mesh(f"floating_bridge_accent_{i+1}", cube_mesh(1.4, 0.04, 0.04), (45 + i * 1.6, -10, 0.13), mat_orb)
    obj.parent = parent
    add_to(obj, col_props)

# Void leak hazard prop (Task 43)
parent = bpy.data.objects.new("prop_void_leak", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Dark circular floor crack
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=14, radius1=0.80, radius2=0.80, depth=0.08, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("void_leak_floor", bm, (52, -10, 0.04), mat_dark)
obj.parent = parent
add_to(obj, col_props)
# Violet glow inside
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.50)
for v in bm.verts:
    v.co.z *= 0.4
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("void_leak_glow", bm, (52, -10, 0.10), mat_seal)
obj.parent = parent
add_to(obj, col_props)


# ===========================================================
# === TRAPS (Task 18) ===
# ===========================================================

# Laser grid trap
parent = bpy.data.objects.new("trap_laser_grid", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_traps)
# 2 posts
for sx in (-1, 1):
    obj = create_mesh(f"laser_grid_post_{sx}", cube_mesh(0.15, 0.15, 3.0), (sx * 1.0, -15, 1.5), mat_chrome_gold)
    obj.parent = parent
    add_to(obj, col_traps)
# 6 laser bars (horizontal grid)
for i, z in enumerate([0.4, 0.8, 1.2, 1.6, 2.0, 2.4]):
    obj = create_mesh(f"laser_grid_bar_{i+1}", cube_mesh(2.0, 0.04, 0.04), (0, -15, z), mat_laser)
    obj.parent = parent
    add_to(obj, col_traps)

# Pressure plate trap
parent = bpy.data.objects.new("trap_pressure_plate", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_traps)
obj = create_mesh("pressure_plate_base", cube_mesh(1.5, 1.5, 0.06), (3, -15, 0.03), mat_dark)
obj.parent = parent
add_to(obj, col_traps)
obj = create_mesh("pressure_plate_top", cube_mesh(1.4, 1.4, 0.04), (3, -15, 0.08), mat_chrome_gold)
obj.parent = parent
add_to(obj, col_traps)
# Center stud
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=0.10)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("pressure_plate_stud", bm, (3, -15, 0.13), mat_seal)
obj.parent = parent
add_to(obj, col_traps)


# ===========================================================
# === ROOM LAYOUTS (Task 42) — 8 prebuilt rooms ===
# ===========================================================

def make_room(name, sx, sy, location, mat=mat_floor):
    floor = create_mesh(f"{name}_floor", cube_mesh(sx, sy, 0.10), location, mat)
    add_to(floor, col_rooms)
    # 4 walls
    for sy_dir in (-1, 1):
        wall = create_mesh(f"{name}_wall_y{sy_dir}", cube_mesh(sx, 0.40, 3.0),
                           (location[0], location[1] + sy_dir * sy * 0.5, 1.55), mat_wall_stone)
        add_to(wall, col_rooms)
    for sx_dir in (-1, 1):
        wall = create_mesh(f"{name}_wall_x{sx_dir}", cube_mesh(0.40, sy, 3.0),
                           (location[0] + sx_dir * sx * 0.5, location[1], 1.55), mat_wall_stone)
        add_to(wall, col_rooms)


rooms = [
    ("room_vault_corridor", 4, 16),
    ("room_hub_chamber", 12, 12),
    ("room_treasury", 8, 8),
    ("room_sarcophagus_chamber", 8, 10),
    ("room_elite_chamber", 12, 10),
    ("room_boss_entry", 8, 16),
    ("room_secret_stash", 4, 4),
    ("room_story_room", 6, 6),
]
for i, (name, sx, sy) in enumerate(rooms):
    make_room(name, sx, sy, (0, -25 - i * 22, 0))


# === SAVE ===
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"\nMemory Vaults biome complete. Total mesh objects: {total}")
print(f"Saved: {OUT_BLEND}")
