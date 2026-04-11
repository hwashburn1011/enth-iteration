"""Epic 07 tasks 9-11 — paint phase 1, 2, 3 albedo textures.

Phase 1: clean polished gunmetal + chrome trim + cyan LED accents
Phase 2: phase 1 base + magenta cracks + RGB chromatic aberration
Phase 3: corrupted dark + crimson cracks + scrolling code rivulets

Each phase samples its own baked AO/curvature/cavity passes and procedurally
combines them with a panel grid + cyan LED detection + crack masks.

Outputs:
  assets/textures/bosses/compiler_boss_p{1,2,3}_albedo.png
  assets/textures/bosses/compiler_boss_p{2,3}_crack_mask.png
  assets/textures/bosses/compiler_boss_p3_code_rivulet.png

Run via:
    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_task10_11_paint_phase_textures.py
"""
import bpy
import os
import math
import numpy as np

TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/bosses"
W, H = 1024, 1024


def load_image(name):
    path = os.path.join(TEX_DIR, name + ".png")
    if not os.path.exists(path):
        return None
    img = bpy.data.images.load(filepath=path, check_existing=True)
    return img


def img_to_array(img):
    return np.array(img.pixels[:], dtype=np.float32).reshape(img.size[1], img.size[0], 4)


def hash_noise(x, y, freq):
    nx = np.floor(x * freq).astype(np.int32)
    ny = np.floor(y * freq).astype(np.int32)
    h = (nx * 374761393 + ny * 668265263) & 0x7fffffff
    h = (h ^ (h >> 13)) * 1274126177
    return ((h & 0x7fffffff) / 0x7fffffff).astype(np.float32)


def box_blur(arr, k=2):
    out = np.copy(arr)
    for _ in range(k):
        out = (np.roll(out, 1, 0) + np.roll(out, -1, 0) + np.roll(out, 1, 1) + np.roll(out, -1, 1) + out) / 5.0
    return out


def save_array_image(name, arr):
    img = bpy.data.images.get(name)
    if img is None:
        img = bpy.data.images.new(name, W, H, alpha=False, float_buffer=False)
    img.colorspace_settings.name = 'sRGB'
    img.pixels = arr.flatten().tolist()
    img.filepath_raw = os.path.join(TEX_DIR, name + ".png")
    img.file_format = 'PNG'
    img.save()
    print(f"  Saved {name}.png")


def save_data_image(name, arr):
    img = bpy.data.images.get(name)
    if img is None:
        img = bpy.data.images.new(name, W, H, alpha=False, float_buffer=False)
    img.colorspace_settings.name = 'Non-Color'
    img.pixels = arr.flatten().tolist()
    img.filepath_raw = os.path.join(TEX_DIR, name + ".png")
    img.file_format = 'PNG'
    img.save()
    print(f"  Saved {name}.png (data)")


# Pre-compute coordinate grids
y_coords = np.linspace(0, 1, H, dtype=np.float32)[:, None]
x_coords = np.linspace(0, 1, W, dtype=np.float32)[None, :]

# === PROCEDURAL BASE PATTERNS shared across phases ===
grid_freq = 60.0
panel_x = np.abs(np.sin(x_coords * grid_freq * 2 * math.pi))
panel_y = np.abs(np.sin(y_coords * grid_freq * 2 * math.pi))
panel_lines = np.maximum(panel_x, panel_y)
panel_lines = np.where(panel_lines > 0.92, 1.0, 0.0)

cell_noise = hash_noise(x_coords, y_coords, 28.0)
fine_noise = hash_noise(x_coords * 1.3, y_coords * 0.9, 88.0)


def paint_phase(phase_label, base_color, edge_color, led_color, do_cyan_stripes=True,
                tint_overall=(1.0, 1.0, 1.0)):
    print(f"Painting phase {phase_label} albedo...")
    ao_img = load_image(f"compiler_boss_{phase_label}_ao")
    curv_img = load_image(f"compiler_boss_{phase_label}_curvature")
    cav_img = load_image(f"compiler_boss_{phase_label}_cavity")
    if ao_img is None or curv_img is None or cav_img is None:
        print(f"  SKIP {phase_label}: missing baked maps")
        return None
    ao_arr = img_to_array(ao_img)[:, :, 0]
    curv_arr = img_to_array(curv_img)[:, :, 0]
    cav_arr = img_to_array(cav_img)[:, :, 0]

    out = np.zeros((H, W, 4), dtype=np.float32)
    out[:, :, 0] = base_color[0]
    out[:, :, 1] = base_color[1]
    out[:, :, 2] = base_color[2]
    out[:, :, 3] = 1.0

    panel_variation = 0.92 + 0.16 * cell_noise
    out[:, :, :3] *= panel_variation[:, :, None]

    seam_strength = 0.55
    out[:, :, :3] *= (1.0 - seam_strength * panel_lines[:, :, None])

    ao_factor = (1.0 - 0.85) + 0.85 * ao_arr
    out[:, :, :3] *= ao_factor[:, :, None]

    cav_factor = 0.6 + 0.4 * cav_arr
    out[:, :, :3] *= cav_factor[:, :, None]

    edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.6
    edge_strength = 0.55
    for c in range(3):
        out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * edge_strength) + edge_color[c] * (edge_mask * edge_strength)

    if do_cyan_stripes:
        alert_mask = panel_lines * (fine_noise > 0.93).astype(np.float32) * (1.0 - edge_mask)
        for c in range(3):
            out[:, :, c] = out[:, :, c] * (1.0 - alert_mask) + led_color[c] * alert_mask

    # Overall tint multiply
    out[:, :, 0] *= tint_overall[0]
    out[:, :, 1] *= tint_overall[1]
    out[:, :, 2] *= tint_overall[2]

    out = np.clip(out, 0.0, 1.0)
    save_array_image(f"compiler_boss_{phase_label}_albedo", out)
    return out


def build_crack_mask(phase_label, intensity=1.0):
    """Build a crack mask layer for P2 / P3 — visible cracks scrolling across surface."""
    print(f"Building crack mask {phase_label}...")
    cav_img = load_image(f"compiler_boss_{phase_label}_cavity")
    if cav_img is None:
        return
    cav_arr = img_to_array(cav_img)[:, :, 0]
    # Cracks bias toward cavity dark zones (where the panels meet)
    crack_seed = (1.0 - cav_arr)
    # Long thin crack pattern: combine 2 perpendicular high-freq noises
    crack_x = hash_noise(x_coords, y_coords * 0.3, 8.0)
    crack_y = hash_noise(x_coords * 0.3, y_coords, 8.0)
    crack_pattern = np.maximum(
        (crack_x > 0.92).astype(np.float32),
        (crack_y > 0.92).astype(np.float32)
    )
    # Soften
    crack_pattern = box_blur(crack_pattern, k=2)
    # Mask by cavity bias
    mask = crack_pattern * (crack_seed * 0.5 + 0.5) * intensity
    mask = np.clip(mask, 0.0, 1.0)
    out = np.zeros((H, W, 4), dtype=np.float32)
    out[:, :, 0] = mask
    out[:, :, 1] = mask
    out[:, :, 2] = mask
    out[:, :, 3] = 1.0
    save_data_image(f"compiler_boss_{phase_label}_crack_mask", out)


def build_code_rivulet():
    """Build the P3 code rivulet texture — typed ASCII characters scrolling."""
    print("Building P3 code rivulet texture...")
    out = np.zeros((H, W, 4), dtype=np.float32)
    # Sparse grid of rectangles representing characters
    char_freq = 64.0
    char_x = np.abs(np.sin(x_coords * char_freq * 2 * math.pi))
    char_y = np.abs(np.sin(y_coords * char_freq * 2 * math.pi))
    in_char_grid = (char_x > 0.85) & (char_y > 0.40)
    # Each character cell gets a random on/off via hash
    cell_on = (hash_noise(x_coords * 1.7, y_coords * 1.1, char_freq) > 0.55).astype(np.float32)
    chars = (in_char_grid.astype(np.float32) * cell_on)
    out[:, :, 0] = chars
    out[:, :, 1] = chars
    out[:, :, 2] = chars
    out[:, :, 3] = 1.0
    save_data_image("compiler_boss_p3_code_rivulet", out)


# === PHASE 1: clean polished server-rack ===
paint_phase(
    phase_label="p1",
    base_color=(0.06, 0.07, 0.10),  # gunmetal
    edge_color=(0.85, 0.86, 0.92),  # chrome
    led_color=(0.0, 0.95, 0.95),    # cyan LED
    do_cyan_stripes=True,
    tint_overall=(1.0, 1.0, 1.0),
)

# === PHASE 2: cracked + slight magenta tint ===
paint_phase(
    phase_label="p2",
    base_color=(0.05, 0.06, 0.09),
    edge_color=(0.80, 0.78, 0.88),  # slightly desaturated chrome
    led_color=(1.0, 0.10, 0.85),    # magenta cracks (will be in emission mask too)
    do_cyan_stripes=True,
    tint_overall=(1.05, 0.96, 1.02),  # subtle magenta cool
)
build_crack_mask("p2", intensity=0.85)

# === PHASE 3: corrupted dark + crimson ===
paint_phase(
    phase_label="p3",
    base_color=(0.03, 0.018, 0.025),  # dark corrupted
    edge_color=(0.45, 0.20, 0.20),    # rust brown
    led_color=(1.0, 0.10, 0.05),      # crimson
    do_cyan_stripes=True,
    tint_overall=(1.10, 0.85, 0.85),  # warm corruption
)
build_crack_mask("p3", intensity=1.4)
build_code_rivulet()

print("All phase albedo + crack masks + code rivulet textures saved")
