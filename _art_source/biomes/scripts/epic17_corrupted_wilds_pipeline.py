"""Epic 17 — Corrupted Wilds Biome pipeline (tasks 2-25, 35-44).

Single Blender CLI script that builds the entire Corrupted Wilds dungeon biome.

Output:
  _art_source/biomes/corrupted_wilds.blend  — single master file
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

random.seed(17)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/biomes/corrupted_wilds.blend"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS (purple + sickly green corruption palette) ===
mat_floor      = make_pbr("CW_Floor",     (0.15, 0.10, 0.18), 0.0, 0.75)
mat_vein       = make_pbr("CW_Vein",      (0.45, 0.10, 0.65), 0.0, 0.40, (0.85, 0.30, 1.0), 4.0)
mat_wall_flesh = make_pbr("CW_WallFlesh", (0.20, 0.12, 0.20), 0.0, 0.85)
mat_wall_panel = make_pbr("CW_WallPanel", (0.18, 0.18, 0.22), 0.5, 0.55)
mat_ceiling    = make_pbr("CW_Ceiling",   (0.10, 0.08, 0.12), 0.0, 0.75)
mat_dark       = make_pbr("CW_Dark",      (0.05, 0.04, 0.06), 0.4, 0.65)
mat_chrome     = make_pbr("CW_Chrome",    (0.55, 0.50, 0.55), 1.0, 0.30)
mat_tendril    = make_pbr("CW_Tendril",   (0.30, 0.10, 0.25), 0.0, 0.55, (0.65, 0.20, 0.85), 1.5)
mat_pod_outer  = make_pbr("CW_PodOuter",  (0.25, 0.15, 0.20), 0.0, 0.65)
mat_pod_inner  = make_pbr("CW_PodInner",  (0.05, 0.30, 0.10), 0.0, 0.20, (0.20, 1.0, 0.30), 6.0)
mat_corruption = make_pbr("CW_Corruption",(0.20, 0.05, 0.30), 0.0, 0.05, (0.65, 0.20, 1.0), 8.0)
mat_acid       = make_pbr("CW_Acid",      (0.20, 0.55, 0.05), 0.0, 0.05, (0.30, 1.0, 0.20), 6.0)
mat_growth     = make_pbr("CW_Growth",    (0.30, 0.20, 0.30), 0.0, 0.65, (0.65, 0.20, 0.85), 0.8)
mat_crystal_corr = make_pbr("CW_CrystalCorr", (0.45, 0.20, 0.55), 0.0, 0.05, (0.85, 0.30, 1.0), 8.0)


# === COLLECTIONS ===
def make_col(name):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


col_tiles = make_col("CW_Tileset")
col_props = make_col("CW_Props")
col_traps = make_col("CW_Traps")
col_rooms = make_col("CW_Rooms")


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


# === TILESET ===

# Floor with vein pattern
obj = create_mesh("tile_floor_vein", cube_mesh(4.0, 4.0, 0.10), (0, 0, 0.05), mat_floor)
add_to(obj, col_tiles)
# 3 vein strips crossing
for i, (x, y, w, d) in enumerate([(0, 0, 3.6, 0.08), (0, 0, 0.08, 3.6), (1.0, 1.0, 0.06, 1.5)]):
    obj = create_mesh(f"tile_floor_vein_strip_{i+1}", cube_mesh(w, d, 0.06), (x, y, 0.10), mat_vein)
    add_to(obj, col_tiles)

# Wall organic - flesh-tech fusion
obj = create_mesh("tile_wall_organic", cube_mesh(4.0, 0.40, 3.0), (5, 0, 1.5), mat_wall_flesh)
add_to(obj, col_tiles)
# Vein details on the wall
for i in range(4):
    z = 0.5 + i * 0.7
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=0.10)
    for v in bm.verts:
        v.co.y *= 0.3
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tile_wall_organic_vein_{i+1}", bm, (5 + (i - 1.5) * 0.8, -0.22, z), mat_vein)
    add_to(obj, col_tiles)

# Wall tendril
obj = create_mesh("tile_wall_tendril", cube_mesh(4.0, 0.40, 3.0), (10, 0, 1.5), mat_wall_flesh)
add_to(obj, col_tiles)
# 5 hanging tendril cones
for i in range(5):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.06, radius2=0.02, depth=0.80, cap_ends=True)
    rot = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tile_wall_tendril_{i+1}", bm, (10 + (i - 2) * 0.7, -0.22, 2.5), mat_tendril)
    add_to(obj, col_tiles)

# Wall blank
obj = create_mesh("tile_wall_blank", cube_mesh(4.0, 0.30, 3.0), (15, 0, 1.5), mat_wall_panel)
add_to(obj, col_tiles)

# Ceiling tendril - hanging from ceiling
obj = create_mesh("tile_ceiling_tendril", cube_mesh(4.0, 4.0, 0.10), (0, 5, 3.05), mat_ceiling)
add_to(obj, col_tiles)
for i in range(6):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.08, radius2=0.025, depth=1.20, cap_ends=True)
    rot = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    px = -1.5 + (i % 3) * 1.5
    py = 5 - 1.0 + (i // 3) * 2.0
    obj = create_mesh(f"tile_ceiling_tendril_{i+1}", bm, (px, py, 2.40), mat_tendril)
    add_to(obj, col_tiles)

# Ceiling pod
obj = create_mesh("tile_ceiling_pod", cube_mesh(4.0, 4.0, 0.10), (5, 5, 3.05), mat_ceiling)
add_to(obj, col_tiles)
# 3 hatching pods
for i in range(3):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.30)
    for v in bm.verts:
        v.co.z *= 0.85
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tile_ceiling_pod_outer_{i+1}", bm, (5 + (i - 1) * 1.2, 5, 2.65), mat_pod_outer)
    add_to(obj, col_tiles)
    # Inner glow
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=0.18)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tile_ceiling_pod_inner_{i+1}", bm, (5 + (i - 1) * 1.2, 5, 2.65), mat_pod_inner)
    add_to(obj, col_tiles)

# Organic corner trim - curved
obj = create_mesh("tile_corner_organic", cube_mesh(0.40, 0.40, 3.0), (10, 5, 1.5), mat_wall_flesh)
add_to(obj, col_tiles)

# T junction
parent = bpy.data.objects.new("tile_t_junction", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_tiles)
for i, (x, y, rot_z) in enumerate([(15, 5, 0), (15, 4, 90), (15, 6, 90)]):
    obj = create_mesh(f"tile_t_junction_arm_{i+1}", cube_mesh(2.0, 0.40, 3.0), (x, y, 1.5), mat_wall_flesh)
    obj.rotation_euler = (0, 0, math.radians(rot_z))
    obj.parent = parent
    add_to(obj, col_tiles)

# Growth door (3x3)
parent = bpy.data.objects.new("tile_growth_door", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_tiles)
obj = create_mesh("growth_door_body", cube_mesh(3.0, 0.40, 3.0), (20, 5, 1.5), mat_wall_flesh)
obj.parent = parent
add_to(obj, col_tiles)
# Vein cross pattern
for x_off, y_off in [(0, 1.0), (0, -1.0), (1.0, 0), (-1.0, 0)]:
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=0.15)
    for v in bm.verts:
        v.co.y *= 0.3
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"growth_door_vein_{x_off}_{y_off}", bm, (20 + x_off, 4.78, 1.5 + y_off), mat_corruption)
    obj.parent = parent
    add_to(obj, col_tiles)


# === HERO PROPS ===

# 6 organic growth variants
for i in range(6):
    parent = bpy.data.objects.new(f"prop_growth_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    # Base bulge
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.30 + i * 0.05)
    for v in bm.verts:
        v.co.z *= 0.85
        v.co.x *= 1.0 + random.uniform(-0.20, 0.20)
        v.co.y *= 1.0 + random.uniform(-0.20, 0.20)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"growth_{i+1}_body", bm, (i * 1.2 - 8, -10, 0.20 + i * 0.05), mat_growth)
    obj.parent = parent
    add_to(obj, col_props)
    # 3 small protrusions
    for j in range(3):
        angle = j * (math.tau / 3)
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=6, radius1=0.08, radius2=0.02, depth=0.25, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"growth_{i+1}_protrusion_{j+1}", bm,
                          (i * 1.2 - 8 + math.cos(angle) * 0.20, -10 + math.sin(angle) * 0.20, 0.40 + i * 0.05),
                          mat_corruption)
        obj.parent = parent
        add_to(obj, col_props)

# 4 tentacle variants
for i in range(4):
    parent = bpy.data.objects.new(f"prop_tentacle_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    # 4 stacked tilted segments
    for s in range(4):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=0.10 - s * 0.015, radius2=0.085 - s * 0.015, depth=0.50, cap_ends=True)
        # Wave tilt
        tilt = math.radians(15 * math.sin(s * 0.8 + i))
        rot = Matrix.Rotation(tilt, 4, 'X')
        for v in bm.verts:
            v.co = rot @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"tentacle_{i+1}_seg_{s+1}", bm, (-2 + i * 1.0, -10, 0.25 + s * 0.50), mat_tendril)
        obj.parent = parent
        add_to(obj, col_props)

# Crystal growth
parent = bpy.data.objects.new("prop_crystal_growth", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
for i in range(7):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.10 + (i % 3) * 0.04, radius2=0.02, depth=0.45 + (i % 3) * 0.15, cap_ends=True)
    tilt = math.radians(random.uniform(-30, 30))
    rot = Matrix.Rotation(tilt, 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    angle = i * (math.tau / 7)
    obj = create_mesh(f"crystal_growth_{i+1}", bm,
                      (3 + math.cos(angle) * 0.20, -10 + math.sin(angle) * 0.20, 0.25),
                      mat_crystal_corr)
    obj.parent = parent
    add_to(obj, col_props)

# Infected terminal
parent = bpy.data.objects.new("prop_infected_terminal", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
obj = create_mesh("infected_terminal_stand", cube_mesh(0.40, 0.40, 1.0), (5, -10, 0.50), mat_dark)
obj.parent = parent
add_to(obj, col_props)
# Screen
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.40
    v.co.y *= 0.04
    v.co.z *= 0.30
rot = Matrix.Rotation(math.radians(-20), 4, 'X')
for v in bm.verts:
    v.co = rot @ v.co
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("infected_terminal_screen", bm, (5, -10, 1.10), mat_corruption)
obj.parent = parent
add_to(obj, col_props)
# Vein overgrowth on the terminal
for sx in (-1, 1):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.04, radius2=0.02, depth=0.40, cap_ends=True)
    tilt = Matrix.Rotation(math.radians(30 * sx), 4, 'Y')
    for v in bm.verts:
        v.co = tilt @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"infected_terminal_vein_{sx}", bm, (5 + sx * 0.20, -10, 1.20), mat_vein)
    obj.parent = parent
    add_to(obj, col_props)

# Corruption pool
parent = bpy.data.objects.new("prop_corruption_pool", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=18, radius1=1.20, radius2=1.10, depth=0.20, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("corruption_pool_basin", bm, (8, -10, 0.10), mat_dark)
obj.parent = parent
add_to(obj, col_props)
# Liquid surface
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=18, radius1=1.0, radius2=1.0, depth=0.04, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("corruption_pool_liquid", bm, (8, -10, 0.18), mat_corruption)
obj.parent = parent
add_to(obj, col_props)

# Hatching pod
parent = bpy.data.objects.new("prop_hatching_pod", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=14, radius=0.45)
for v in bm.verts:
    v.co.z *= 1.30
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("hatching_pod_outer", bm, (11, -10, 0.60), mat_pod_outer)
obj.parent = parent
add_to(obj, col_props)
# Inner glow visible through cracks
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.30)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("hatching_pod_inner", bm, (11, -10, 0.60), mat_pod_inner)
obj.parent = parent
add_to(obj, col_props)

# Infected statue
parent = bpy.data.objects.new("prop_infected_statue", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Statue body (simplified humanoid shape)
obj = create_mesh("infected_statue_body", cube_mesh(0.50, 0.30, 1.50), (14, -10, 0.75), mat_chrome)
obj.parent = parent
add_to(obj, col_props)
# Head
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.20)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("infected_statue_head", bm, (14, -10, 1.65), mat_chrome)
obj.parent = parent
add_to(obj, col_props)
# Vein overgrowth on body + head
for i in range(4):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.05, radius2=0.02, depth=0.35, cap_ends=True)
    tilt = Matrix.Rotation(math.radians(45 + i * 20), 4, 'X')
    for v in bm.verts:
        v.co = tilt @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"infected_statue_vein_{i+1}", bm, (14 + (i % 2 - 0.5) * 0.30, -10 - 0.20, 0.80 + i * 0.30), mat_vein)
    obj.parent = parent
    add_to(obj, col_props)

# Twisted tree
parent = bpy.data.objects.new("prop_twisted_tree", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# 4 stacked twisted trunk segments
z = 0
for i in range(4):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.30 - i * 0.04, radius2=0.25 - i * 0.04, depth=1.0, cap_ends=True)
    rot = Matrix.Rotation(math.radians((i % 2 - 0.5) * 18), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"twisted_tree_seg_{i+1}", bm, (17 + (i % 2 - 0.5) * 0.10, -10, z + 0.50), mat_growth)
    obj.parent = parent
    add_to(obj, col_props)
    z += 1.0
# 3 vein-bark accents
for i in range(3):
    angle = i * (math.tau / 3)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.04, radius2=0.02, depth=0.60, cap_ends=True)
    tilt = Matrix.Rotation(math.radians(75), 4, 'X')
    rot_z = Matrix.Rotation(angle, 4, 'Z')
    for v in bm.verts:
        v.co = rot_z @ tilt @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"twisted_tree_vein_{i+1}", bm, (17, -10, 2.0), mat_vein)
    obj.parent = parent
    add_to(obj, col_props)


# === TRAPS ===

# Acid spray trap
parent = bpy.data.objects.new("trap_acid_spray", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_traps)
# Nozzle
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=10, radius1=0.18, radius2=0.10, depth=0.30, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("acid_spray_nozzle", bm, (0, -15, 1.5), mat_dark)
obj.parent = parent
add_to(obj, col_traps)
# Glowing acid inside
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=0.10)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("acid_spray_glow", bm, (0, -14.85, 1.5), mat_acid)
obj.parent = parent
add_to(obj, col_traps)

# Root grab trap
parent = bpy.data.objects.new("trap_root_grab", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_traps)
# Floor patch with vein pattern
obj = create_mesh("root_grab_floor", cube_mesh(2.0, 2.0, 0.06), (3, -15, 0.03), mat_dark)
obj.parent = parent
add_to(obj, col_traps)
# 4 root vine cones extending up
for i, (x, y) in enumerate([(-0.5, -0.5), (0.5, -0.5), (-0.5, 0.5), (0.5, 0.5)]):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.06, radius2=0.02, depth=0.40, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"root_grab_root_{i+1}", bm, (3 + x, -15 + y, 0.20), mat_vein)
    obj.parent = parent
    add_to(obj, col_traps)

# Acid pool hazard (Task 41)
parent = bpy.data.objects.new("prop_acid_pool", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=18, radius1=1.40, radius2=1.30, depth=0.20, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("acid_pool_basin", bm, (20, -10, 0.10), mat_dark)
obj.parent = parent
add_to(obj, col_props)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=18, radius1=1.20, radius2=1.20, depth=0.04, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("acid_pool_liquid", bm, (20, -10, 0.18), mat_acid)
obj.parent = parent
add_to(obj, col_props)

# Vine grab interaction prop (Task 42)
parent = bpy.data.objects.new("prop_vine_grab", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Hanging vine that the player can grab
for i in range(5):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.04, radius2=0.04, depth=0.50, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"vine_grab_seg_{i+1}", bm, (23, -10, 2.5 - i * 0.50), mat_tendril)
    obj.parent = parent
    add_to(obj, col_props)

# Organic bridge prop set (Task 39)
parent = bpy.data.objects.new("prop_organic_bridge", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
for i in range(5):
    obj = create_mesh(f"organic_bridge_seg_{i+1}", cube_mesh(1.5, 1.5, 0.10), (26 + i * 1.6, -10, 0.05), mat_growth)
    obj.parent = parent
    add_to(obj, col_props)
    # Vein accent
    obj = create_mesh(f"organic_bridge_vein_{i+1}", cube_mesh(1.4, 0.04, 0.04), (26 + i * 1.6, -10, 0.13), mat_vein)
    obj.parent = parent
    add_to(obj, col_props)


# === ROOM LAYOUTS ===

def make_room(name, sx, sy, location, mat=mat_floor):
    floor = create_mesh(f"{name}_floor", cube_mesh(sx, sy, 0.10), location, mat)
    add_to(floor, col_rooms)
    for sy_dir in (-1, 1):
        wall = create_mesh(f"{name}_wall_y{sy_dir}", cube_mesh(sx, 0.40, 3.0),
                           (location[0], location[1] + sy_dir * sy * 0.5, 1.55), mat_wall_flesh)
        add_to(wall, col_rooms)
    for sx_dir in (-1, 1):
        wall = create_mesh(f"{name}_wall_x{sx_dir}", cube_mesh(0.40, sy, 3.0),
                           (location[0] + sx_dir * sx * 0.5, location[1], 1.55), mat_wall_flesh)
        add_to(wall, col_rooms)


rooms = [
    ("room_corrupt_corridor", 4, 16),
    ("room_chokepoint", 6, 6),
    ("room_loot_grove", 8, 8),
    ("room_elite_den", 12, 8),
    ("room_boss_entry", 8, 16),
    ("room_hidden_cave", 5, 5),
    ("room_corruption_hub", 14, 14),
    ("room_story_room", 6, 6),
]
for i, (name, sx, sy) in enumerate(rooms):
    make_room(name, sx, sy, (0, -25 - i * 24, 0))


# === SAVE ===
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"\nCorrupted Wilds biome complete. Total mesh objects: {total}")
print(f"Saved: {OUT_BLEND}")
