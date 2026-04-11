"""Epic 14 — Terrain System v2 pipeline (tasks 3-7, 14-15, 35).

Builds procedural terrain heightmap meshes + procedural rock/pebble props
for the 4 dungeon biomes + town zone + wilderness zone in a single CLI run.

Output:
  _art_source/terrain/terrain_zones.blend  — town + wilderness + 4 biome heightmaps
  _art_source/terrain/terrain_props.blend  — rocks, pebbles, twigs, debris
  assets/textures/terrain/heightmap_*.png  — per-zone heightmaps
"""
import bpy
import bmesh
import os
import sys
import math
import random
import numpy as np
from mathutils import Vector

SCRIPT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/scripts"
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from enemy_pipeline_utils import make_pbr

random.seed(14)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/terrain"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/terrain"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


# === MATERIALS ===
mat_grass    = make_pbr("Terrain_Grass",  (0.30, 0.55, 0.18), 0.0, 0.85)
mat_dirt     = make_pbr("Terrain_Dirt",   (0.40, 0.30, 0.20), 0.0, 0.90)
mat_rock     = make_pbr("Terrain_Rock",   (0.45, 0.42, 0.40), 0.0, 0.85)
mat_sand     = make_pbr("Terrain_Sand",   (0.85, 0.75, 0.55), 0.0, 0.90)
mat_snow     = make_pbr("Terrain_Snow",   (0.95, 0.96, 0.98), 0.0, 0.55)
mat_pebble   = make_pbr("Terrain_Pebble", (0.50, 0.48, 0.45), 0.0, 0.80)
mat_twig     = make_pbr("Terrain_Twig",   (0.30, 0.20, 0.10), 0.0, 0.85)


# === HEIGHTMAP GENERATION ===

def generate_heightmap_array(name, size_px, octaves, scale, amplitude, ridges=False):
    """Procedural heightmap via summed noise octaves."""
    np.random.seed(hash(name) & 0xffffffff)
    out = np.zeros((size_px, size_px), dtype=np.float32)
    x = np.linspace(0, 1, size_px, dtype=np.float32)[None, :]
    y = np.linspace(0, 1, size_px, dtype=np.float32)[:, None]
    for octave in range(octaves):
        freq = scale * (2 ** octave)
        amp = amplitude / (2 ** octave)
        # Simple hash noise
        nx = (x * freq).astype(np.int32) ^ (np.random.randint(0, 1000))
        ny = (y * freq).astype(np.int32) ^ (np.random.randint(0, 1000))
        # Use sin combination for smooth pseudo-noise
        layer = np.sin(x * freq * 2 * math.pi) * np.cos(y * freq * 2 * math.pi)
        layer += np.sin(x * freq * 1.7 * math.pi + 2.3) * np.cos(y * freq * 2.1 * math.pi + 1.7)
        layer *= amp * 0.5
        if ridges:
            layer = -np.abs(layer)
        out += layer
    # Normalize to [0, 1]
    out = (out - out.min()) / max(0.01, out.max() - out.min())
    return out


def save_heightmap_image(name, arr):
    h, w = arr.shape
    img = bpy.data.images.new(name, w, h, alpha=False, float_buffer=False)
    img.colorspace_settings.name = 'Non-Color'
    rgba = np.zeros((h, w, 4), dtype=np.float32)
    rgba[:, :, 0] = arr
    rgba[:, :, 1] = arr
    rgba[:, :, 2] = arr
    rgba[:, :, 3] = 1.0
    img.pixels = rgba.flatten().tolist()
    img.filepath_raw = os.path.join(TEX_DIR, name + ".png")
    img.file_format = 'PNG'
    img.save()
    print(f"  Saved heightmap {name}.png")
    return img


def build_terrain_mesh(name, heightmap_arr, world_size_m, height_scale_m, location, material):
    """Build a terrain mesh from a heightmap array."""
    h, w = heightmap_arr.shape
    bm = bmesh.new()
    # Generate verts
    verts = []
    for j in range(h):
        row = []
        for i in range(w):
            x = (i / (w - 1) - 0.5) * world_size_m
            y = (j / (h - 1) - 0.5) * world_size_m
            z = heightmap_arr[j, i] * height_scale_m
            v = bm.verts.new((x, y, z))
            row.append(v)
        verts.append(row)
    bm.verts.ensure_lookup_table()
    # Generate faces
    for j in range(h - 1):
        for i in range(w - 1):
            bm.faces.new([verts[j][i], verts[j][i+1], verts[j+1][i+1], verts[j+1][i]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name + "_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    obj.location = location
    obj.data.materials.append(material)
    bpy.context.scene.collection.objects.link(obj)
    for p in obj.data.polygons:
        p.use_smooth = True
    return obj


# === ZONE 1: TOWN HEIGHTMAP (Tasks 3-4) ===
# Gentle hills, flat in the center for the town square
print("\n=== Town heightmap ===")
town_arr = generate_heightmap_array("town", 64, octaves=3, scale=4, amplitude=0.3)
# Flatten the center (radius 0.3 of size, the town square)
cy, cx = 32, 32
for j in range(64):
    for i in range(64):
        dist = math.sqrt((i - cx) ** 2 + (j - cy) ** 2)
        if dist < 16:
            falloff = max(0, 1 - dist / 16) ** 2
            town_arr[j, i] *= (1 - falloff * 0.95)
save_heightmap_image("heightmap_town", town_arr)
build_terrain_mesh("terrain_town", town_arr, world_size_m=80.0, height_scale_m=4.0, location=(0, 0, 0), material=mat_grass)


# === ZONE 2: WILDERNESS HEIGHTMAP (Tasks 5-6) ===
print("\n=== Wilderness heightmap ===")
wild_arr = generate_heightmap_array("wilderness", 64, octaves=4, scale=3, amplitude=0.8)
save_heightmap_image("heightmap_wilderness", wild_arr)
build_terrain_mesh("terrain_wilderness", wild_arr, world_size_m=120.0, height_scale_m=12.0, location=(150, 0, 0), material=mat_grass)


# === ZONE 3: 4 DUNGEON BIOMES (Task 7) ===
biomes = [
    ("server_room", 64, 3, 6, 0.4, mat_dirt, False),     # mostly flat with subtle bumps
    ("memory_garden", 64, 4, 4, 0.6, mat_grass, False),  # rolling hills
    ("ice_cavern", 64, 4, 5, 0.7, mat_snow, True),       # ridged
    ("corruption_pit", 64, 5, 6, 1.0, mat_rock, True),   # jagged ridges
]
for biome_id, size, octaves, scale, amp, mat, ridges in biomes:
    print(f"\n=== Biome heightmap: {biome_id} ===")
    arr = generate_heightmap_array(biome_id, size, octaves=octaves, scale=scale, amplitude=amp, ridges=ridges)
    save_heightmap_image(f"heightmap_{biome_id}", arr)
    build_terrain_mesh(f"terrain_{biome_id}", arr, world_size_m=60.0, height_scale_m=8.0,
                       location=(300 + biomes.index((biome_id, size, octaves, scale, amp, mat, ridges)) * 80, 0, 0),
                       material=mat)


# === GROUND PROPS (Task 14, 15, 35) ===
print("\n=== Ground props ===")
props_col = bpy.data.collections.new("Terrain_Props")
bpy.context.scene.collection.children.link(props_col)


def add_to_props(obj):
    for c in obj.users_collection:
        c.objects.unlink(obj)
    props_col.objects.link(obj)


# Rocks (5 sizes)
for i in range(5):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=0.20 + i * 0.15)
    for v in bm.verts:
        v.co.x *= 1.0 + random.uniform(-0.20, 0.20)
        v.co.y *= 1.0 + random.uniform(-0.20, 0.20)
        v.co.z *= 0.6 + random.uniform(-0.10, 0.20)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(f"rock_{i+1}_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(f"rock_{i+1}", me)
    obj.location = (500 + i * 1.5, 0, 0)
    obj.data.materials.append(mat_rock)
    bpy.context.scene.collection.objects.link(obj)
    add_to_props(obj)
    for p in obj.data.polygons:
        p.use_smooth = True

# Pebbles (3 small variants)
for i in range(3):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=0.05 + i * 0.02)
    for v in bm.verts:
        v.co.z *= 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(f"pebble_{i+1}_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(f"pebble_{i+1}", me)
    obj.location = (510 + i * 0.4, 0, 0)
    obj.data.materials.append(mat_pebble)
    bpy.context.scene.collection.objects.link(obj)
    add_to_props(obj)

# Twigs (3 lengths)
for i in range(3):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=5, radius1=0.012, radius2=0.008, depth=0.25 + i * 0.10, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(f"twig_{i+1}_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(f"twig_{i+1}", me)
    obj.location = (515 + i * 0.4, 0, 0)
    obj.rotation_euler = (math.radians(85), 0, 0)
    obj.data.materials.append(mat_twig)
    bpy.context.scene.collection.objects.link(obj)
    add_to_props(obj)

# Save terrain zones blend
bpy.ops.wm.save_as_mainfile(filepath=f"{OUT_DIR}/terrain_zones.blend")
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"\nTerrain pipeline complete. Total mesh objects: {total}")
print(f"Saved: {OUT_DIR}/terrain_zones.blend")
