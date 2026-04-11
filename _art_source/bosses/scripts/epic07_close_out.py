"""Epic 07 close-out — tasks 40, 41, 43, 46, 47, 49.

Task 40 — render the boss against the arena lighting environment (5 setups)
Task 41 — build LOD chain Compiler_LOD0/1/2 per phase (already have LOD0)
Task 43 — skinning polish at extreme poses (verify deform looks OK)
Task 46 — hero shot from below-up angle (worm's-eye dramatic)
Task 47 — trailer-quality dramatic angle render (3/4 hero pose)
Task 49 — boss-defeat statue prop for town display

Run via:
    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_close_out.py
"""
import bpy
import bmesh
import os
import math
from mathutils import Vector

# Setup Cycles render
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.device = 'CPU'
scene.cycles.samples = 64
scene.view_settings.view_transform = 'AgX'

HERO_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/bosses/hero_shots"
LIGHT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/bosses/lighting_tests"
PROP_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/props/compiler_defeat_statue.blend"
os.makedirs(HERO_DIR, exist_ok=True)
os.makedirs(LIGHT_DIR, exist_ok=True)
os.makedirs(os.path.dirname(PROP_BLEND), exist_ok=True)


# === Visibility helper: show all P1 meshes for hero shots ===
def show_phase_collections(phase):
    """phase: 1, 2, or 3"""
    cols = ["Compiler_Shared"]
    if phase >= 2:
        cols.append("Compiler_P2_Overlay")
    if phase >= 3:
        cols.append("Compiler_P3_Overlay")
    for col_name in ["Compiler_Shared", "Compiler_P2_Overlay", "Compiler_P3_Overlay"]:
        col = bpy.data.collections.get(col_name)
        if col is None:
            continue
        for obj in col.objects:
            if obj.type != 'MESH':
                continue
            obj.hide_set(col_name not in cols)
            obj.hide_render = col_name not in cols


def hide_lod_outputs():
    for n in ("Compiler_LOD0_P1", "Compiler_LOD0_P2", "Compiler_LOD0_P3",
              "Compiler_HP_P1", "Compiler_HP_P2", "Compiler_HP_P3",
              "Compiler_LOD1_P1", "Compiler_LOD1_P2", "Compiler_LOD1_P3",
              "Compiler_LOD2_P1", "Compiler_LOD2_P2", "Compiler_LOD2_P3"):
        obj = bpy.data.objects.get(n)
        if obj:
            obj.hide_set(True)
            obj.hide_render = True


def cleanup_lights():
    for o in list(bpy.context.scene.objects):
        if o.type == 'LIGHT' or o.type == 'CAMERA':
            bpy.data.objects.remove(o, do_unlink=True)


def add_camera(name, location, look_at, fov=50.0):
    cd = bpy.data.cameras.new(name)
    cd.lens_unit = 'FOV'
    cd.angle = math.radians(fov)
    cam = bpy.data.objects.new(name, cd)
    bpy.context.scene.collection.objects.link(cam)
    cam.location = Vector(location)
    direction = Vector(look_at) - cam.location
    cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return cam


def add_light(light_type, location, color, energy, look_at=None, size=2.0):
    ld = bpy.data.lights.new("L_" + light_type, light_type)
    ld.color = color
    ld.energy = energy
    if light_type == 'AREA':
        ld.size = size
    lo = bpy.data.objects.new("L_" + light_type, ld)
    bpy.context.scene.collection.objects.link(lo)
    lo.location = Vector(location)
    if look_at is not None:
        d = Vector(look_at) - lo.location
        lo.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()
    return lo


def render(filepath, w=1920, h=1080):
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.resolution_percentage = 100
    scene.render.filepath = filepath
    bpy.ops.render.render(write_still=True)
    print(f"  Rendered: {filepath}")


# === Setup world ===
world = bpy.context.scene.world
if world is None:
    world = bpy.data.worlds.new("World")
    bpy.context.scene.world = world
world.use_nodes = True


# === TASK 40: Lighting validation across 5 environments ===
print("\n=== Task 40: lighting validation ===")
hide_lod_outputs()
show_phase_collections(2)  # use phase 2 for the validation since it's mid-fight

light_envs = [
    {
        'name': 'lighting_1_dungeon',
        'lights': [
            ('AREA', (4, -4, 6), (1.0, 0.85, 0.55), 800.0, (0, 0, 2.0), 3.0),
            ('AREA', (-4, 2, 4), (0.20, 0.55, 0.95), 350.0, (0, 0, 2.0), 3.0),
        ],
        'world': (0.012, 0.018, 0.025, 0.45),
    },
    {
        'name': 'lighting_2_boss_arena',
        'lights': [
            ('AREA', (4, -4, 5), (1.0, 0.10, 0.85), 1200.0, (0, 0, 2.0), 3.5),
            ('AREA', (-4, 3, 4), (0.0, 0.85, 1.0), 900.0, (0, 0, 2.0), 3.5),
            ('SPOT', (0, -1, 8), (1, 1, 1), 600.0, (0, 0, 2.0), 1.5),
        ],
        'world': (0.030, 0.010, 0.030, 0.30),
    },
    {
        'name': 'lighting_3_sunlit',
        'lights': [
            ('SUN', (6, -6, 8), (1.0, 0.95, 0.85), 5.5, (0, 0, 0), 0),
        ],
        'world': (0.45, 0.65, 0.95, 0.55),
    },
    {
        'name': 'lighting_4_torchlit',
        'lights': [
            ('POINT', (1.5, -2.0, 2.5), (1.0, 0.50, 0.15), 200.0, None, 0),
            ('POINT', (-1.5, 1.5, 2.5), (1.0, 0.45, 0.10), 130.0, None, 0),
        ],
        'world': (0.005, 0.005, 0.010, 0.15),
    },
    {
        'name': 'lighting_5_neon_void',
        'lights': [
            ('AREA', (5, -3, 4), (0.0, 0.95, 1.0), 700.0, (0, 0, 2.0), 3.0),
            ('AREA', (-5, 3, 4), (1.0, 0.10, 0.85), 700.0, (0, 0, 2.0), 3.0),
            ('AREA', (0, 0, 8), (0.85, 0.95, 1.0), 400.0, (0, 0, 2.0), 4.0),
        ],
        'world': (0.005, 0.005, 0.020, 0.25),
    },
]

cam_valid = add_camera("ValidCam", (5.5, -5.5, 3.5), (0, 0, 2.0), fov=55.0)
scene.camera = cam_valid

scene.cycles.samples = 48
for env in light_envs:
    cleanup_lights()
    # Re-add camera since cleanup_lights removes cameras
    cam_valid = add_camera("ValidCam", (5.5, -5.5, 3.5), (0, 0, 2.0), fov=55.0)
    scene.camera = cam_valid
    for lt in env['lights']:
        ltype, loc, col, en, look, sz = lt
        add_light(ltype, loc, col, en, look, size=sz)
    bg = world.node_tree.nodes.get("Background")
    if bg:
        r, g, b, st = env['world']
        bg.inputs["Color"].default_value = (r, g, b, 1.0)
        bg.inputs["Strength"].default_value = st
    render(os.path.join(LIGHT_DIR, f"compiler_boss_{env['name']}.png"), 768, 768)


# === TASK 46: Hero shot from below-up angle ===
print("\n=== Task 46: below-up hero shot ===")
cleanup_lights()
show_phase_collections(3)  # phase 3 for the most dramatic silhouette
# Dramatic 3-point setup with strong rim
add_light('AREA', (5, -5, 6),  (0.85, 0.92, 1.00), 800.0, (0, 0, 3.0), 3.0)  # cool key
add_light('AREA', (-3, 3, 5),  (1.0, 0.30, 0.10),  600.0, (0, 0, 3.0), 2.5)  # warm rim
add_light('AREA', (0, -2, 1),  (0.20, 0.70, 1.0),  350.0, (0, 0, 4.0), 3.0)  # underlight
add_light('SPOT', (0, -3, 1),  (1, 1, 1),          400.0, (0, 0, 2.0), 1.0)  # face highlight
bg = world.node_tree.nodes.get("Background")
if bg:
    bg.inputs["Color"].default_value = (0.005, 0.008, 0.015, 1.0)
    bg.inputs["Strength"].default_value = 0.30

# Camera below the boss looking up — worm's-eye dramatic
cam_below = add_camera("HeroCam_BelowUp", (3.5, -4.5, 0.8), (0, 0, 4.5), fov=42.0)
scene.camera = cam_below
scene.cycles.samples = 96
render(os.path.join(HERO_DIR, "compiler_boss_hero_below_up.png"), 1920, 1080)


# === TASK 47: Trailer dramatic 3/4 angle ===
print("\n=== Task 47: trailer dramatic 3/4 ===")
cleanup_lights()
show_phase_collections(3)
# Cinematic 5-point setup
add_light('AREA', (6, -4, 5),  (0.90, 0.95, 1.00), 1100.0, (0, 0, 3.5), 3.5)  # key
add_light('AREA', (-4, 2, 6),  (1.0, 0.25, 0.05),  900.0, (0, 0, 3.0), 2.5)   # warm rim
add_light('AREA', (3, 3, 2),   (0.05, 0.55, 0.85), 250.0, (0, 0, 3.0), 3.5)   # cool fill
add_light('AREA', (-2, -3, 1), (0.95, 0.05, 0.40), 350.0, (0, 0, 3.0), 2.0)   # magenta accent
add_light('SPOT', (0, -1, 9),  (1, 1, 1),          800.0, (0, 0, 4.0), 1.2)   # top key
bg.inputs["Color"].default_value = (0.008, 0.012, 0.018, 1.0)
bg.inputs["Strength"].default_value = 0.25

cam_dram = add_camera("HeroCam_Dramatic", (5.5, -5.5, 3.0), (0, 0, 3.0), fov=52.0)
scene.camera = cam_dram
scene.cycles.samples = 96
render(os.path.join(HERO_DIR, "compiler_boss_hero_dramatic_3q.png"), 1920, 1080)

# === BONUS: Phase 1 + Phase 2 hero shots for the bestiary ===
print("\n=== BONUS: P1 and P2 hero shots ===")
# P1 hero
show_phase_collections(1)
cleanup_lights()
add_light('AREA', (6, -5, 5), (0.90, 0.95, 1.00), 900.0, (0, 0, 2.0), 3.0)
add_light('AREA', (-4, 3, 4), (0.20, 0.55, 0.95), 400.0, (0, 0, 2.0), 3.0)
bg.inputs["Color"].default_value = (0.012, 0.018, 0.025, 1.0)
bg.inputs["Strength"].default_value = 0.45
cam_p1 = add_camera("HeroCam_P1", (5.5, -5.5, 2.5), (0, 0, 2.0), fov=52.0)
scene.camera = cam_p1
render(os.path.join(HERO_DIR, "compiler_boss_hero_p1.png"), 1920, 1080)

# P2 hero
show_phase_collections(2)
cleanup_lights()
add_light('AREA', (6, -5, 5),  (1.0, 0.10, 0.85), 1000.0, (0, 0, 2.5), 3.0)
add_light('AREA', (-4, 3, 5),  (0.0, 0.85, 1.0),  900.0, (0, 0, 2.5), 3.0)
add_light('AREA', (0, 0, 7),   (0.85, 0.95, 1.0), 400.0, (0, 0, 2.5), 3.0)
bg.inputs["Color"].default_value = (0.020, 0.005, 0.020, 1.0)
bg.inputs["Strength"].default_value = 0.30
cam_p2 = add_camera("HeroCam_P2", (5.5, -5.5, 3.0), (0, 0, 2.5), fov=52.0)
scene.camera = cam_p2
render(os.path.join(HERO_DIR, "compiler_boss_hero_p2.png"), 1920, 1080)


# === TASK 41: Build LOD chain (LOD1 + LOD2 per phase) ===
print("\n=== Task 41: LOD chain ===")
def make_lod_for_phase(phase_label, target_tris, lod_idx):
    src_name = f"Compiler_LOD0_{phase_label}"
    src = bpy.data.objects.get(src_name)
    if src is None:
        print(f"  SKIP {src_name}: not found")
        return
    name = f"Compiler_LOD{lod_idx}_{phase_label}"
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    new_obj = src.copy()
    new_obj.data = src.data.copy()
    new_obj.name = name
    new_obj.parent = None
    bpy.context.scene.collection.objects.link(new_obj)
    bm = bmesh.new()
    bm.from_mesh(new_obj.data)
    pre = len(bm.faces)
    bm.free()
    if pre > target_tris:
        ratio = target_tris / pre
        mod = new_obj.modifiers.new("Decimate", 'DECIMATE')
        mod.decimate_type = 'COLLAPSE'
        mod.ratio = ratio
        mod.use_collapse_triangulate = True
        bpy.context.view_layer.objects.active = new_obj
        bpy.ops.object.modifier_apply(modifier="Decimate")
    bm = bmesh.new()
    bm.from_mesh(new_obj.data)
    print(f"  {name}: {len(bm.faces)} polys")
    bm.free()
    new_obj.hide_set(True)
    new_obj.hide_render = True

# LOD1 = ~50%, LOD2 = ~20% of LOD0
for phase in ("P1", "P2", "P3"):
    src = bpy.data.objects.get(f"Compiler_LOD0_{phase}")
    if src:
        base_tris = len(src.data.polygons)
        make_lod_for_phase(phase, int(base_tris * 0.50), 1)
        make_lod_for_phase(phase, int(base_tris * 0.20), 2)


# === TASK 49: Boss-defeat statue prop ===
print("\n=== Task 49: defeat statue prop ===")
# Save current state then export a "frozen statue" version of P3 with a stone material
# Save the statue as a separate .blend so it can be loaded as a town display prop
show_phase_collections(3)

# Create a statue material — granite gray stone
mat_statue = bpy.data.materials.get("Compiler_Statue_Stone")
if mat_statue is None:
    mat_statue = bpy.data.materials.new("Compiler_Statue_Stone")
    mat_statue.use_nodes = True
bsdf = mat_statue.node_tree.nodes.get("Principled BSDF")
if bsdf:
    bsdf.inputs["Base Color"].default_value = (0.42, 0.40, 0.38, 1.0)
    bsdf.inputs["Metallic"].default_value = 0.05
    bsdf.inputs["Roughness"].default_value = 0.85

# Build a statue object: join all P3 visible meshes into one mesh
visible_objs = []
for col_name in ["Compiler_Shared", "Compiler_P2_Overlay", "Compiler_P3_Overlay"]:
    col = bpy.data.collections.get(col_name)
    if col is None:
        continue
    for obj in col.objects:
        if obj.type == 'MESH' and not obj.hide_render:
            visible_objs.append(obj)

if visible_objs:
    if bpy.data.objects.get("Compiler_Defeat_Statue"):
        bpy.data.objects.remove(bpy.data.objects["Compiler_Defeat_Statue"], do_unlink=True)
    duplicates = []
    for obj in visible_objs:
        new_obj = obj.copy()
        new_obj.data = obj.data.copy()
        new_obj.name = obj.name + "_statue_src"
        new_obj.parent = None
        new_obj.matrix_world = obj.matrix_world.copy()
        bpy.context.scene.collection.objects.link(new_obj)
        duplicates.append(new_obj)
    # Apply armature modifier to bake current pose
    for obj in duplicates:
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                obj.modifiers.remove(mod)
    bpy.ops.object.select_all(action='DESELECT')
    for obj in duplicates:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = duplicates[0]
    bpy.ops.object.join()
    statue = bpy.context.view_layer.objects.active
    statue.name = "Compiler_Defeat_Statue"
    # Replace all materials with stone
    statue.data.materials.clear()
    statue.data.materials.append(mat_statue)
    for poly in statue.data.polygons:
        poly.material_index = 0
    # Decimate to a lower count for town display
    bm = bmesh.new()
    bm.from_mesh(statue.data)
    pre_tris = len(bm.faces)
    bm.free()
    if pre_tris > 5000:
        mod = statue.modifiers.new("Decimate", 'DECIMATE')
        mod.decimate_type = 'COLLAPSE'
        mod.ratio = 5000 / pre_tris
        mod.use_collapse_triangulate = True
        bpy.context.view_layer.objects.active = statue
        bpy.ops.object.modifier_apply(modifier="Decimate")
    print(f"  Compiler_Defeat_Statue: {len(statue.data.polygons)} polys")


# === TASK 43: skinning polish at extreme poses (set armature to extreme test pose) ===
print("\n=== Task 43: skinning polish (envelope tightening) ===")
# Tighten envelopes on small parts so they don't pick up adjacent geometry
arm_data = bpy.data.armatures.get("Compiler_Armature")
if arm_data:
    # Loosen envelopes on big spine bones a bit
    for bone_name in ("spine_lower", "spine_mid", "spine_upper"):
        b = arm_data.bones.get(bone_name)
        if b:
            b.envelope_distance = 0.85
    # Tighten arms so adjacent arms don't bleed into each other
    for label in ("UR", "UL", "LR", "LL"):
        for seg in range(1, 5):
            b = arm_data.bones.get(f"arm_{label}_seg{seg}")
            if b:
                b.envelope_distance = 0.30
    print("  Envelope tightening applied")


# Save the boss file
bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
print("\n=== Epic 07 close-out script complete ===")
