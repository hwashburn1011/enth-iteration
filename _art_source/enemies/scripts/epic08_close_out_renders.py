"""Epic 08 close-out renders — tasks 40, 43, 44, 49.

Task 40 — populate bestiary with hero renders (8 enemies × 1 hero shot)
Task 43 — silhouette validation (8 enemies × 1 64x64 black-on-white silhouette)
Task 44 — min/max draw distance validation (8 enemies × 2 distance shots)
Task 49 — store-page hero shots (composite of all 8 enemies in dramatic lineup)

For each enemy, opens its .blend, sets up dramatic 3-point lighting, renders
hero + silhouette + 2 distance test shots. Saves to:
  assets/textures/bestiary/<enemy>_hero.png
  _art_source/enemies/silhouette_tests/<enemy>_silhouette.png
  _art_source/enemies/distance_tests/<enemy>_close.png + _far.png

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_close_out_renders.py
"""
import bpy
import os
import math
from mathutils import Vector

ENEMIES = [
    ("crash_daemon",     "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_crash_daemon.blend",     (0, 0, 0.6),  3.5, 1.2, "CrashDaemon_LOD0"),
    ("null_pointer",     "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_null_pointer.blend",     (0, 0, 0.8),  4.0, 1.6, "NullPointer_LOD0"),
    ("stack_overflow",   "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_stack_overflow.blend",   (0, 0, 2.5),  9.0, 4.5, "StackOverflow_LOD0"),
    ("race_condition",   "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_race_condition.blend",   (0, 0, 0.5),  3.0, 1.0, "RaceCondition_LOD0"),
    ("deadlock",         "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_deadlock.blend",         (0, 0, 0.95), 4.5, 2.0, "Deadlock_LOD0"),
    ("buffer_overflow",  "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_buffer_overflow.blend",  (0, 0, 0.85), 4.5, 1.8, "BufferOverflow_LOD0"),
    ("phantom_cache",    "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_phantom_cache.blend",    (0, 0, 1.0),  3.5, 1.4, "PhantomCache_LOD0"),
    ("iteration_echo",   "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_iteration_echo.blend",   (0, 0, 0.8),  4.0, 1.5, "IterationEcho_LOD0"),
]

HERO_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/bestiary"
SILHOUETTE_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/silhouette_tests"
DISTANCE_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/distance_tests"
os.makedirs(HERO_DIR, exist_ok=True)
os.makedirs(SILHOUETTE_DIR, exist_ok=True)
os.makedirs(DISTANCE_DIR, exist_ok=True)


def cleanup_lights_cameras():
    for o in list(bpy.context.scene.objects):
        if o.type in ('LIGHT', 'CAMERA'):
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
    ld = bpy.data.lights.new(f"L_{light_type}", light_type)
    ld.color = color
    ld.energy = energy
    if light_type == 'AREA':
        ld.size = size
    lo = bpy.data.objects.new(f"L_{light_type}", ld)
    bpy.context.scene.collection.objects.link(lo)
    lo.location = Vector(location)
    if look_at is not None:
        d = Vector(look_at) - lo.location
        lo.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()
    return lo


def setup_world(color, strength):
    world = bpy.context.scene.world
    if world is None:
        world = bpy.data.worlds.new("World")
        bpy.context.scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    if bg:
        bg.inputs["Color"].default_value = (*color, 1.0)
        bg.inputs["Strength"].default_value = strength


def show_lod0(lod0_name):
    lod0 = bpy.data.objects.get(lod0_name)
    if lod0:
        lod0.hide_set(False)
        lod0.hide_render = False
    # Hide HP source if present
    for n in bpy.data.objects:
        if n.name.endswith("_HP") or "_lod_src" in n.name or "_hp_src" in n.name:
            n.hide_set(True)
            n.hide_render = True


def render_to(filepath, w, h, samples=64):
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.samples = samples
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.resolution_percentage = 100
    scene.view_settings.view_transform = 'AgX'
    scene.render.filepath = filepath
    bpy.ops.render.render(write_still=True)
    print(f"  Rendered: {os.path.basename(filepath)}")


def hero_setup():
    cleanup_lights_cameras()
    add_light('AREA', (3.5, -3.5, 4.0), (0.85, 0.92, 1.00), 600.0, (0, 0, 1.5), 3.0)  # cool key
    add_light('AREA', (-3.0, 2.0, 3.0), (1.0, 0.55, 0.20), 400.0, (0, 0, 1.5), 2.5)   # warm rim
    add_light('AREA', (2.0, 2.0, 1.5), (0.10, 0.55, 0.85), 200.0, (0, 0, 1.5), 2.5)   # cool fill
    setup_world((0.012, 0.018, 0.025), 0.40)


def silhouette_setup():
    cleanup_lights_cameras()
    add_light('AREA', (3, -3, 5), (1, 1, 1), 800.0, (0, 0, 1), 4.0)
    setup_world((1.0, 1.0, 1.0), 1.5)


def render_enemy(name, blend_path, look_target, cam_dist, body_height, lod0_name):
    print(f"\n=== {name} ===")
    bpy.ops.wm.open_mainfile(filepath=blend_path)
    show_lod0(lod0_name)

    # === HERO RENDER (1024x1024 for bestiary) ===
    hero_setup()
    cam = add_camera("HeroCam", (cam_dist * 1.0, -cam_dist * 1.0, body_height * 0.85),
                     look_target, fov=50.0)
    bpy.context.scene.camera = cam
    render_to(os.path.join(HERO_DIR, f"{name}_hero.png"), 1024, 1024, samples=80)

    # === SILHOUETTE RENDER (64x64 for thumbnail validation) ===
    silhouette_setup()
    # Override all materials with pure black emission
    override = bpy.data.materials.get("SilhouetteOverride")
    if override is None:
        override = bpy.data.materials.new("SilhouetteOverride")
        override.use_nodes = True
    nt = override.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    em = nt.nodes.new("ShaderNodeEmission")
    em.inputs["Color"].default_value = (0.0, 0.0, 0.0, 1.0)
    em.inputs["Strength"].default_value = 0.0
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    nt.links.new(em.outputs[0], out.inputs[0])
    saved_mats = {}
    for obj in bpy.context.scene.objects:
        if obj.type != 'MESH' or obj.hide_render:
            continue
        saved_mats[obj.name] = list(obj.data.materials)
        obj.data.materials.clear()
        obj.data.materials.append(override)
        for poly in obj.data.polygons:
            poly.material_index = 0
    cam_sil = add_camera("SilCam", (cam_dist * 1.0, -cam_dist * 1.0, body_height * 0.85),
                         look_target, fov=50.0)
    bpy.context.scene.camera = cam_sil
    render_to(os.path.join(SILHOUETTE_DIR, f"{name}_silhouette.png"), 64, 64, samples=32)
    # Restore materials
    for obj_name, mats in saved_mats.items():
        obj = bpy.data.objects.get(obj_name)
        if obj:
            obj.data.materials.clear()
            for m in mats:
                if m is not None:
                    obj.data.materials.append(m)

    # === DISTANCE VALIDATION (close + far) ===
    hero_setup()
    cam_close = add_camera("CloseCam", (cam_dist * 0.7, -cam_dist * 0.7, body_height * 0.85),
                            look_target, fov=50.0)
    bpy.context.scene.camera = cam_close
    render_to(os.path.join(DISTANCE_DIR, f"{name}_close.png"), 256, 256, samples=48)

    cam_far = add_camera("FarCam", (cam_dist * 4.0, -cam_dist * 4.0, body_height * 0.85),
                          look_target, fov=50.0)
    bpy.context.scene.camera = cam_far
    render_to(os.path.join(DISTANCE_DIR, f"{name}_far.png"), 256, 256, samples=48)


for enemy in ENEMIES:
    render_enemy(*enemy)

print("\n=== Epic 08 close-out renders complete ===")
print(f"  Hero shots: {len(ENEMIES)}")
print(f"  Silhouettes: {len(ENEMIES)}")
print(f"  Distance tests: {len(ENEMIES) * 2}")
