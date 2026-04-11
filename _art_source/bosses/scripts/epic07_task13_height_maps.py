"""Epic 07 task 13 — generate per-phase heightmaps for the displacement shader.

For each phase, derive a heightmap from the existing baked AO + curvature
passes. Heightmap = curvature centered on 0.5 (so concave is below, convex
is above) inverted-AO weighted (cavities push down, exposed surfaces push up).

Outputs:
  assets/textures/bosses/compiler_boss_p{1,2,3}_height.png

Run via:
    blender.exe --background --python _art_source/bosses/scripts/epic07_task13_height_maps.py
"""
import bpy
import os
import numpy as np

TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/bosses"
W, H = 1024, 1024


def load_image(name):
    path = os.path.join(TEX_DIR, name + ".png")
    if not os.path.exists(path):
        return None
    return bpy.data.images.load(filepath=path, check_existing=True)


def img_to_array(img):
    return np.array(img.pixels[:], dtype=np.float32).reshape(img.size[1], img.size[0], 4)


def save_data_image(name, arr):
    img = bpy.data.images.get(name)
    if img is None:
        img = bpy.data.images.new(name, W, H, alpha=False, float_buffer=False)
    img.colorspace_settings.name = 'Non-Color'
    img.pixels = arr.flatten().tolist()
    img.filepath_raw = os.path.join(TEX_DIR, name + ".png")
    img.file_format = 'PNG'
    img.save()
    print(f"  Saved {name}.png")


def build_heightmap(phase_label):
    print(f"Building height map {phase_label}...")
    ao_img = load_image(f"compiler_boss_{phase_label}_ao")
    curv_img = load_image(f"compiler_boss_{phase_label}_curvature")
    if ao_img is None or curv_img is None:
        print(f"  SKIP {phase_label}: missing maps")
        return
    ao_arr = img_to_array(ao_img)[:, :, 0]
    curv_arr = img_to_array(curv_img)[:, :, 0]

    # Curvature is centered around 0.5 (>0.5 = convex/raised, <0.5 = concave/recessed)
    # Convert to signed displacement: (curvature - 0.5) gives [-0.5, 0.5]
    curv_signed = (curv_arr - 0.5) * 2.0  # now [-1, 1]
    # Weight by AO so deep cavities push further down
    inv_ao = 1.0 - ao_arr
    height = curv_signed * (0.7 + 0.3 * inv_ao)
    # Remap back to [0, 1] for storage
    height_stored = (height + 1.0) * 0.5
    height_stored = np.clip(height_stored, 0.0, 1.0)

    out = np.zeros((H, W, 4), dtype=np.float32)
    out[:, :, 0] = height_stored
    out[:, :, 1] = height_stored
    out[:, :, 2] = height_stored
    out[:, :, 3] = 1.0
    save_data_image(f"compiler_boss_{phase_label}_height", out)


build_heightmap("p1")
build_heightmap("p2")
build_heightmap("p3")
print("Heightmap generation complete")
