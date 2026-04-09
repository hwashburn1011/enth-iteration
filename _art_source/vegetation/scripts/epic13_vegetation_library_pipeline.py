"""Epic 13 — Vegetation & Foliage Library pipeline (tasks 2-6, 11-31, 35, 38-39).

Single Blender CLI script that builds the entire vegetation library:
- 4 tree variants (oak / birch / gnarled / digital crystal)
- 4 bush variants (round / spiky / flowering / glitch)
- 4 flower variants (digital lily / data tulip / memory rose / binary daisy)
- 4 grass clump variants
- 3 fern variants
- 4 mushroom variants (some glowing)
- Vine prop + hanging moss + root system
- Dead/burnt trees + crystal vegetation
- Seaweed + farm crops
- Large hero tree

Output:
  _art_source/vegetation/vegetation_library.blend  (single master file)

Run via:
    blender.exe --background --python _art_source/vegetation/scripts/epic13_vegetation_library_pipeline.py
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

random.seed(13)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/vegetation/vegetation_library.blend"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS ===
mat_bark_oak     = make_pbr("Veg_BarkOak",     (0.22, 0.14, 0.06), 0.0, 0.85)
mat_bark_birch   = make_pbr("Veg_BarkBirch",   (0.92, 0.92, 0.85), 0.0, 0.75)
mat_bark_gnarled = make_pbr("Veg_BarkGnarled", (0.15, 0.10, 0.05), 0.0, 0.90)
mat_bark_burnt   = make_pbr("Veg_BarkBurnt",   (0.05, 0.04, 0.03), 0.0, 0.85)
mat_crystal_blue = make_pbr("Veg_CrystalBlue", (0.10, 0.40, 0.85), 0.0, 0.10, (0.0, 0.85, 1.0), 5.0)
mat_crystal_violet = make_pbr("Veg_CrystalViolet", (0.45, 0.10, 0.85), 0.0, 0.10, (0.65, 0.20, 1.0), 5.0)
mat_leaf_oak     = make_pbr("Veg_LeafOak",     (0.18, 0.45, 0.12), 0.0, 0.80)
mat_leaf_birch   = make_pbr("Veg_LeafBirch",   (0.45, 0.65, 0.20), 0.0, 0.75)
mat_leaf_dark    = make_pbr("Veg_LeafDark",    (0.10, 0.25, 0.08), 0.0, 0.85)
mat_leaf_glitch  = make_pbr("Veg_LeafGlitch",  (0.25, 0.55, 0.30), 0.0, 0.70, (0.0, 0.95, 0.50), 1.5)
mat_grass        = make_pbr("Veg_Grass",       (0.30, 0.55, 0.18), 0.0, 0.80)
mat_grass_dry    = make_pbr("Veg_GrassDry",    (0.55, 0.50, 0.22), 0.0, 0.85)
mat_flower_lily  = make_pbr("Veg_FlowerLily",  (0.95, 0.95, 0.95), 0.0, 0.55, (0.0, 0.85, 1.0), 1.0)
mat_flower_tulip = make_pbr("Veg_FlowerTulip", (0.85, 0.10, 0.45), 0.0, 0.55)
mat_flower_rose  = make_pbr("Veg_FlowerRose",  (0.85, 0.05, 0.20), 0.0, 0.55, (1.0, 0.10, 0.05), 0.5)
mat_flower_daisy = make_pbr("Veg_FlowerDaisy", (1.0, 0.95, 0.55), 0.0, 0.55, (0.0, 0.85, 1.0), 0.5)
mat_mushroom_red = make_pbr("Veg_MushroomRed", (0.85, 0.10, 0.05), 0.0, 0.45)
mat_mushroom_glow= make_pbr("Veg_MushroomGlow",(0.20, 0.55, 0.85), 0.0, 0.10, (0.0, 0.95, 1.0), 6.0)
mat_mushroom_brown=make_pbr("Veg_MushroomBrown",(0.55, 0.35, 0.18),0.0, 0.65)
mat_stem_white   = make_pbr("Veg_Stem",        (0.92, 0.88, 0.78), 0.0, 0.50)
mat_vine         = make_pbr("Veg_Vine",        (0.20, 0.40, 0.15), 0.0, 0.75)
mat_moss         = make_pbr("Veg_Moss",        (0.18, 0.45, 0.20), 0.0, 0.85)
mat_water_plant  = make_pbr("Veg_WaterPlant",  (0.10, 0.50, 0.40), 0.0, 0.55, (0.0, 0.85, 0.65), 0.8)
mat_pumpkin      = make_pbr("Veg_Pumpkin",     (0.85, 0.45, 0.10), 0.0, 0.65)
mat_carrot       = make_pbr("Veg_Carrot",      (0.85, 0.40, 0.10), 0.0, 0.55)
mat_corn         = make_pbr("Veg_Corn",        (0.95, 0.85, 0.30), 0.0, 0.55)


# === COLLECTIONS ===
def make_col(name):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


col_trees = make_col("Veg_Trees")
col_bushes = make_col("Veg_Bushes")
col_flowers = make_col("Veg_Flowers")
col_grass = make_col("Veg_Grass")
col_ferns = make_col("Veg_Ferns")
col_mushrooms = make_col("Veg_Mushrooms")
col_vines = make_col("Veg_Vines")
col_crystals = make_col("Veg_Crystals")
col_water = make_col("Veg_Water")
col_crops = make_col("Veg_Crops")
col_hero = make_col("Veg_Hero")
col_burnt = make_col("Veg_Burnt")


def add_to_col(obj, col):
    for c in obj.users_collection:
        c.objects.unlink(obj)
    col.objects.link(obj)


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


# ===========================================================
# === TREES (Tasks 2-5) ===
# ===========================================================

def build_tree_oak(name, x_offset):
    """Large oak: thick trunk + 5 chunky leaf clusters."""
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_trees)
    # Trunk
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=14, radius1=0.45, radius2=0.30, depth=4.5, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_trunk", bm, (x_offset, 0, 2.25), mat_bark_oak)
    obj.parent = parent
    add_to_col(obj, col_trees)
    # 5 leaf clusters in a ball arrangement on top
    for i in range(5):
        angle = i * (math.tau / 5)
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=1.20)
        for v in bm.verts:
            v.co.x *= 1.0 + random.uniform(-0.10, 0.10)
            v.co.y *= 1.0 + random.uniform(-0.10, 0.10)
            v.co.z *= 0.85
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        leaf_pos = (x_offset + math.cos(angle) * 0.6, math.sin(angle) * 0.6, 5.2)
        l_obj = create_mesh(f"{name}_leaves_{i+1}", bm, leaf_pos, mat_leaf_oak)
        l_obj.parent = parent
        add_to_col(l_obj, col_trees)
    return parent


def build_tree_birch(name, x_offset):
    """Slim birch: tall thin trunk + sparse leaf clusters."""
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_trees)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.18, radius2=0.10, depth=6.0, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_trunk", bm, (x_offset, 0, 3.0), mat_bark_birch)
    obj.parent = parent
    add_to_col(obj, col_trees)
    # 4 sparse leaf clusters
    for i, z in enumerate([4.5, 5.2, 5.8, 6.3]):
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.85)
        for v in bm.verts:
            v.co.z *= 0.7
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        l_obj = create_mesh(f"{name}_leaves_{i+1}", bm, (x_offset + (i % 2 - 0.5) * 0.4, 0, z), mat_leaf_birch)
        l_obj.parent = parent
        add_to_col(l_obj, col_trees)
    return parent


def build_tree_gnarled(name, x_offset):
    """Gnarled ancient tree: thick twisted trunk + dark dense canopy."""
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_trees)
    # Twisted trunk built from 4 stacked tilted segments
    z = 0
    for i in range(4):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.55 - i * 0.06, radius2=0.50 - i * 0.06, depth=1.30, cap_ends=True)
        # Tilt slightly
        rot = Matrix.Rotation(math.radians((i % 2 - 0.5) * 12), 4, 'X')
        for v in bm.verts:
            v.co = rot @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"{name}_trunk_{i+1}", bm, (x_offset + (i % 2 - 0.5) * 0.10, 0, z + 0.65), mat_bark_gnarled)
        obj.parent = parent
        add_to_col(obj, col_trees)
        z += 1.20
    # Dark dense canopy (3 large clusters)
    for i in range(3):
        angle = i * (math.tau / 3)
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=1.40)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        l_obj = create_mesh(f"{name}_canopy_{i+1}", bm,
                            (x_offset + math.cos(angle) * 0.5, math.sin(angle) * 0.5, 5.50),
                            mat_leaf_dark)
        l_obj.parent = parent
        add_to_col(l_obj, col_trees)
    return parent


def build_tree_crystal(name, x_offset):
    """Digital crystal tree: angular crystal trunk + crystal cluster top."""
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_trees)
    # Hexagonal trunk
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.30, radius2=0.18, depth=3.5, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_trunk", bm, (x_offset, 0, 1.75), mat_crystal_blue)
    obj.parent = parent
    add_to_col(obj, col_trees)
    # 7 crystal shards at the top in a starburst
    for i in range(7):
        angle = i * (math.tau / 7)
        elev = math.radians(30 + i * 5)
        dx = math.cos(angle) * math.cos(elev) * 0.5
        dy = math.sin(angle) * math.cos(elev) * 0.5
        dz = math.sin(elev) * 0.8
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=6, radius1=0.20, radius2=0.02, depth=1.20, cap_ends=True)
        # Tilt to direction
        zdir = Vector((0, 0, 1))
        target = Vector((dx, dy, dz)).normalized()
        if (target - zdir).length > 1e-4:
            axis = zdir.cross(target)
            if axis.length < 1e-5:
                axis = Vector((1, 0, 0))
            ang = math.acos(max(-1.0, min(1.0, zdir.dot(target))))
            rot = Matrix.Rotation(ang, 4, axis.normalized())
            for v in bm.verts:
                v.co = rot @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        s_obj = create_mesh(f"{name}_shard_{i+1}", bm,
                            (x_offset + dx + target.x * 0.6, dy + target.y * 0.6, 3.5 + dz + target.z * 0.6),
                            mat_crystal_violet if i % 2 == 0 else mat_crystal_blue)
        s_obj.parent = parent
        add_to_col(s_obj, col_trees)
    return parent


build_tree_oak("tree_oak", 0)
build_tree_birch("tree_birch", 6)
build_tree_gnarled("tree_gnarled", 12)
build_tree_crystal("tree_crystal", 18)


# ===========================================================
# === BUSHES (Tasks 11-15) ===
# ===========================================================

def build_bush(name, x_offset, y_offset, mat, radius, count, spike=False, flower=False):
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_bushes)
    for i in range(count):
        bm = bmesh.new()
        if spike:
            bmesh.ops.create_cone(bm, segments=8, radius1=0.18, radius2=0.02, depth=0.45, cap_ends=True)
        else:
            bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=radius)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        offset_x = random.uniform(-0.25, 0.25)
        offset_y = random.uniform(-0.25, 0.25)
        offset_z = radius * 0.7 + random.uniform(0, 0.10)
        obj = create_mesh(f"{name}_part_{i+1}", bm,
                          (x_offset + offset_x, y_offset + offset_y, offset_z), mat)
        obj.parent = parent
        add_to_col(obj, col_bushes)
    if flower:
        # Add 3 flower spheres on top
        for i in range(3):
            bm = bmesh.new()
            bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=0.06)
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            angle = i * (math.tau / 3)
            f_obj = create_mesh(f"{name}_flower_{i+1}", bm,
                                (x_offset + math.cos(angle) * 0.20,
                                 y_offset + math.sin(angle) * 0.20,
                                 radius + 0.10),
                                mat_flower_tulip)
            f_obj.parent = parent
            add_to_col(f_obj, col_bushes)


build_bush("bush_round", 0, 5, mat_leaf_oak, 0.30, 6)
build_bush("bush_spiky", 3, 5, mat_leaf_dark, 0.25, 8, spike=True)
build_bush("bush_flowering", 6, 5, mat_leaf_birch, 0.32, 6, flower=True)
build_bush("bush_glitch", 9, 5, mat_leaf_glitch, 0.30, 6)


# ===========================================================
# === FLOWERS (Tasks 16-19) ===
# ===========================================================

def build_flower(name, x_offset, mat_petal, petal_count, height=0.30):
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_flowers)
    # Stem
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.012, radius2=0.012, depth=height, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_stem", bm, (x_offset, 0, height * 0.5), mat_grass)
    obj.parent = parent
    add_to_col(obj, col_flowers)
    # Petals
    for i in range(petal_count):
        angle = i * (math.tau / petal_count)
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=0.05)
        for v in bm.verts:
            v.co.z *= 0.4
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        p_obj = create_mesh(f"{name}_petal_{i+1}", bm,
                            (x_offset + math.cos(angle) * 0.06, math.sin(angle) * 0.06, height + 0.02),
                            mat_petal)
        p_obj.parent = parent
        add_to_col(p_obj, col_flowers)


build_flower("flower_digital_lily", 0, mat_flower_lily, 6, height=0.35)
build_flower("flower_data_tulip", 1, mat_flower_tulip, 5, height=0.30)
build_flower("flower_memory_rose", 2, mat_flower_rose, 8, height=0.32)
build_flower("flower_binary_daisy", 3, mat_flower_daisy, 10, height=0.28)


# ===========================================================
# === GRASS (Task 20) — 4 variants of grass clumps ===
# ===========================================================

def build_grass_clump(name, x_offset, mat, blade_count):
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_grass)
    for i in range(blade_count):
        bm = bmesh.new()
        # Single blade as a thin tall cone
        bmesh.ops.create_cone(bm, segments=4, radius1=0.012, radius2=0.001, depth=0.18 + random.uniform(-0.05, 0.05), cap_ends=True)
        # Tilt slightly
        tilt = random.uniform(-0.20, 0.20)
        rot = Matrix.Rotation(tilt, 4, 'X') @ Matrix.Rotation(random.uniform(0, math.tau), 4, 'Z')
        for v in bm.verts:
            v.co = rot @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        offset_x = random.uniform(-0.10, 0.10)
        offset_y = random.uniform(-0.10, 0.10)
        obj = create_mesh(f"{name}_blade_{i+1}", bm, (x_offset + offset_x, offset_y, 0.09), mat)
        obj.parent = parent
        add_to_col(obj, col_grass)


build_grass_clump("grass_clump_lush", 0, mat_grass, 12)
build_grass_clump("grass_clump_dry", 1, mat_grass_dry, 10)
build_grass_clump("grass_clump_dense", 2, mat_grass, 16)
build_grass_clump("grass_clump_tuft", 3, mat_grass, 8)


# ===========================================================
# === FERNS (Task 23) ===
# ===========================================================

def build_fern(name, x_offset, mat):
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_ferns)
    # 6 fronds emerging from a central point
    for i in range(6):
        angle = i * (math.tau / 6)
        bm = bmesh.new()
        # Frond: thin elongated cone
        bmesh.ops.create_cone(bm, segments=6, radius1=0.04, radius2=0.005, depth=0.45, cap_ends=True)
        # Tilt outward
        tilt_angle = math.radians(45)
        rot = Matrix.Rotation(tilt_angle, 4, 'X')
        for v in bm.verts:
            v.co = rot @ v.co
        # Then rotate around Z to splay
        rot2 = Matrix.Rotation(angle, 4, 'Z')
        for v in bm.verts:
            v.co = rot2 @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        f_obj = create_mesh(f"{name}_frond_{i+1}", bm, (x_offset, 0, 0.05), mat)
        f_obj.parent = parent
        add_to_col(f_obj, col_ferns)


build_fern("fern_small", 0, mat_leaf_oak)
build_fern("fern_medium", 1, mat_leaf_dark)
build_fern("fern_large", 2, mat_leaf_glitch)


# ===========================================================
# === MUSHROOMS (Task 24) — 4 variants, some glow ===
# ===========================================================

def build_mushroom(name, x_offset, cap_mat, stem_mat, glow=False):
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_mushrooms)
    # Stem
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.05, radius2=0.04, depth=0.18, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_stem", bm, (x_offset, 0, 0.09), stem_mat)
    obj.parent = parent
    add_to_col(obj, col_mushrooms)
    # Cap (flattened sphere)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.10)
    for v in bm.verts:
        if v.co.z < 0:
            v.co.z *= 0.2
        v.co.z *= 0.7
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_cap", bm, (x_offset, 0, 0.20), cap_mat)
    obj.parent = parent
    add_to_col(obj, col_mushrooms)


build_mushroom("mushroom_red_dotted", 0, mat_mushroom_red, mat_stem_white)
build_mushroom("mushroom_brown", 1, mat_mushroom_brown, mat_stem_white)
build_mushroom("mushroom_glow_blue", 2, mat_mushroom_glow, mat_stem_white, glow=True)
build_mushroom("mushroom_glow_purple", 3, mat_crystal_violet, mat_stem_white, glow=True)


# ===========================================================
# === VINES + MOSS + ROOTS (Tasks 25-27) ===
# ===========================================================
# Vine
parent = bpy.data.objects.new("vine_climbing", None)
bpy.context.scene.collection.objects.link(parent)
add_to_col(parent, col_vines)
for i in range(8):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.04, radius2=0.03, depth=0.30, cap_ends=True)
    # Wavy tilt
    tilt = math.radians(10 * math.sin(i * 0.5))
    rot = Matrix.Rotation(tilt, 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"vine_seg_{i+1}", bm, (0 + math.sin(i * 0.5) * 0.15, 0, 0.15 + i * 0.30), mat_vine)
    obj.parent = parent
    add_to_col(obj, col_vines)
    # Add a leaf cluster every 2 segments
    if i % 2 == 0:
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=0.10)
        for v in bm.verts:
            v.co.z *= 0.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        l_obj = create_mesh(f"vine_leaf_{i+1}", bm,
                            (math.sin(i * 0.5) * 0.15 + 0.10, 0, 0.15 + i * 0.30),
                            mat_leaf_oak)
        l_obj.parent = parent
        add_to_col(l_obj, col_vines)

# Hanging moss
parent = bpy.data.objects.new("moss_hanging", None)
bpy.context.scene.collection.objects.link(parent)
add_to_col(parent, col_vines)
for i in range(12):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=4, radius1=0.025, radius2=0.001, depth=0.50, cap_ends=True)
    rot = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    offset_x = random.uniform(-0.30, 0.30)
    offset_y = random.uniform(-0.10, 0.10)
    obj = create_mesh(f"moss_strand_{i+1}", bm, (offset_x, offset_y, 0.25), mat_moss)
    obj.parent = parent
    add_to_col(obj, col_vines)

# Root system (above-ground roots)
parent = bpy.data.objects.new("roots_visible", None)
bpy.context.scene.collection.objects.link(parent)
add_to_col(parent, col_vines)
for i in range(5):
    angle = i * (math.tau / 5)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.08, radius2=0.04, depth=0.60, cap_ends=True)
    rot = Matrix.Rotation(math.radians(75), 4, 'X')
    rot2 = Matrix.Rotation(angle, 4, 'Z')
    for v in bm.verts:
        v.co = rot2 @ rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"root_{i+1}", bm,
                      (math.cos(angle) * 0.30, math.sin(angle) * 0.30, 0.12), mat_bark_oak)
    obj.parent = parent
    add_to_col(obj, col_vines)


# ===========================================================
# === DEAD/BURNT TREE + CRYSTAL VEGETATION (Tasks 28-30) ===
# ===========================================================

# Burnt tree
parent = bpy.data.objects.new("tree_burnt", None)
bpy.context.scene.collection.objects.link(parent)
add_to_col(parent, col_burnt)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=10, radius1=0.30, radius2=0.20, depth=3.0, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("burnt_trunk", bm, (0, 0, 1.5), mat_bark_burnt)
obj.parent = parent
add_to_col(obj, col_burnt)
# 3 broken branches
for i in range(3):
    angle = i * (math.tau / 3)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.10, radius2=0.03, depth=0.80, cap_ends=True)
    tilt = Matrix.Rotation(math.radians(50), 4, 'X')
    rot = Matrix.Rotation(angle, 4, 'Z')
    for v in bm.verts:
        v.co = rot @ tilt @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    b_obj = create_mesh(f"burnt_branch_{i+1}", bm,
                        (math.cos(angle) * 0.30, math.sin(angle) * 0.30, 2.7), mat_bark_burnt)
    b_obj.parent = parent
    add_to_col(b_obj, col_burnt)

# Crystal vegetation cluster
parent = bpy.data.objects.new("crystal_cluster", None)
bpy.context.scene.collection.objects.link(parent)
add_to_col(parent, col_crystals)
for i in range(7):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.10 + (i % 3) * 0.04, radius2=0.02, depth=0.40 + (i % 3) * 0.15, cap_ends=True)
    tilt = math.radians(random.uniform(-25, 25))
    rot = Matrix.Rotation(tilt, 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    angle = i * (math.tau / 7)
    obj = create_mesh(f"crystal_{i+1}", bm,
                      (math.cos(angle) * 0.20, math.sin(angle) * 0.20, 0.20),
                      mat_crystal_blue if i % 2 == 0 else mat_crystal_violet)
    obj.parent = parent
    add_to_col(obj, col_crystals)


# ===========================================================
# === WATER PLANTS (Task 31) ===
# ===========================================================
parent = bpy.data.objects.new("water_seaweed", None)
bpy.context.scene.collection.objects.link(parent)
add_to_col(parent, col_water)
for i in range(6):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.06, radius2=0.015, depth=0.80, cap_ends=True)
    tilt = math.radians(20 * math.sin(i * 0.7))
    rot = Matrix.Rotation(tilt, 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"seaweed_{i+1}", bm, (math.sin(i * 0.5) * 0.20, math.cos(i * 0.4) * 0.15, 0.40), mat_water_plant)
    obj.parent = parent
    add_to_col(obj, col_water)


# ===========================================================
# === FARM CROPS (Tasks 38-39) ===
# ===========================================================

def build_pumpkin(name, x_offset):
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_crops)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.20)
    for v in bm.verts:
        v.co.z *= 0.85
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_body", bm, (x_offset, 0, 0.18), mat_pumpkin)
    obj.parent = parent
    add_to_col(obj, col_crops)
    # Stem
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.025, radius2=0.015, depth=0.08, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_stem", bm, (x_offset, 0, 0.36), mat_grass)
    obj.parent = parent
    add_to_col(obj, col_crops)


def build_carrot_row(name, x_offset):
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_crops)
    for i in range(4):
        # Carrot top (green leaves)
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.06)
        for v in bm.verts:
            v.co.z *= 0.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        l_obj = create_mesh(f"{name}_leaves_{i}", bm, (x_offset + i * 0.15, 0, 0.08), mat_grass)
        l_obj.parent = parent
        add_to_col(l_obj, col_crops)


def build_corn_stalk(name, x_offset):
    parent = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(parent)
    add_to_col(parent, col_crops)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.04, radius2=0.02, depth=1.2, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"{name}_stalk", bm, (x_offset, 0, 0.6), mat_grass)
    obj.parent = parent
    add_to_col(obj, col_crops)
    # Corn cobs
    for cob_z in (0.5, 0.85):
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.08)
        for v in bm.verts:
            v.co.z *= 1.6
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        c_obj = create_mesh(f"{name}_cob_{int(cob_z*100)}", bm, (x_offset + 0.10, 0, cob_z), mat_corn)
        c_obj.parent = parent
        add_to_col(c_obj, col_crops)


build_pumpkin("crop_pumpkin_1", 0)
build_pumpkin("crop_pumpkin_2", 0.6)
build_carrot_row("crop_carrot_row", 1.5)
build_corn_stalk("crop_corn_1", 3.0)
build_corn_stalk("crop_corn_2", 3.5)


# ===========================================================
# === HERO TREE (Task 35) ===
# ===========================================================
parent = bpy.data.objects.new("hero_tree_centerpiece", None)
bpy.context.scene.collection.objects.link(parent)
add_to_col(parent, col_hero)
# Massive trunk
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=18, radius1=1.20, radius2=0.80, depth=8.0, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("hero_trunk", bm, (0, 0, 4.0), mat_bark_oak)
obj.parent = parent
add_to_col(obj, col_hero)
# 8 huge leaf clusters
for i in range(8):
    angle = i * (math.tau / 8)
    elev = math.radians(45)
    dx = math.cos(angle) * 1.5
    dy = math.sin(angle) * 1.5
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=2.20)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    l_obj = create_mesh(f"hero_canopy_{i+1}", bm, (dx, dy, 9.5 + (i % 3) * 0.40), mat_leaf_oak)
    l_obj.parent = parent
    add_to_col(l_obj, col_hero)
# Add a cyan accent emission ring around the base (the in-universe "structured data" hint)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=1.40, radius2=1.40, depth=0.10, cap_ends=False)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
ring_obj = create_mesh("hero_base_ring", bm, (0, 0, 0.05), mat_crystal_blue)
ring_obj.parent = parent
add_to_col(ring_obj, col_hero)


# === SAVE ===
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"\nVegetation library complete. Total mesh objects: {total}")
print(f"Saved: {OUT_BLEND}")
