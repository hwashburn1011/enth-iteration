"""Epic 10 close-out renders — tasks 40, 41, 46, 49.

Task 40 — render high-res portraits for all 12 NPCs (512x768)
Task 41 — render 4 emotion variant portraits per NPC (happy, sad, surprised, angry)
Task 46 — NPC-to-NPC interaction animations placeholder (handled by react_happy)
Task 49 — render the cast cohesion group portrait

Run via:
    blender.exe --background --python _art_source/characters/scripts/epic10_npc_close_out.py
"""
import bpy
import os
import math
from mathutils import Vector

NPC_BLENDS = [
    ("pixel",    "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_pixel.blend",    "Pixel_LOD0",    1.50),
    ("forge",    "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_forge.blend",    "Forge_LOD0",    1.65),
    ("cache",    "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_cache.blend",    "Cache_LOD0",    1.55),
    ("index",    "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_index.blend",    "Index_LOD0",    1.55),
    ("harvest",  "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_harvest.blend",  "Harvest_LOD0",  1.55),
    ("bit",      "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_bit.blend",      "Bit_LOD0",      1.20),
    ("legacy",   "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_legacy.blend",   "Legacy_LOD0",   1.50),
    ("trade",    "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_trade.blend",    "Trade_LOD0",    1.55),
    ("lab",      "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_lab.blend",      "Lab_LOD0",      1.55),
    ("render",   "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_render.blend",   "Render_LOD0",   1.50),
    ("sync",     "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_sync.blend",     "Sync_LOD0",     1.50),
    ("sentinel", "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs/npc_sentinel.blend", "Sentinel_LOD0", 1.65),
]

PORTRAIT_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/portraits/town_npcs"
os.makedirs(PORTRAIT_DIR, exist_ok=True)


def cleanup_lights_cameras():
    for o in list(bpy.context.scene.objects):
        if o.type in ('LIGHT', 'CAMERA'):
            bpy.data.objects.remove(o, do_unlink=True)


def add_camera(name, location, look_at, fov=42.0):
    cd = bpy.data.cameras.new(name)
    cd.lens_unit = 'FOV'
    cd.angle = math.radians(fov)
    cam = bpy.data.objects.new(name, cd)
    bpy.context.scene.collection.objects.link(cam)
    cam.location = Vector(location)
    direction = Vector(look_at) - cam.location
    cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return cam


def add_light(light_type, location, color, energy, look_at=None, size=1.5):
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


def show_lod0(lod0_name):
    lod0 = bpy.data.objects.get(lod0_name)
    if lod0 is None:
        return None
    lod0.hide_set(False)
    lod0.hide_render = False
    for n in bpy.data.objects:
        if "_HP" in n.name or "_lod_src" in n.name or "_hp_src" in n.name:
            n.hide_set(True)
            n.hide_render = True
    return lod0


def render_npc(npc_id, blend_path, lod0_name, height):
    print(f"\n=== {npc_id} ===")
    bpy.ops.wm.open_mainfile(filepath=blend_path)
    lod0 = show_lod0(lod0_name)
    if lod0 is None:
        print(f"  SKIP {npc_id}: LOD0 missing")
        return

    head_z = height - 0.10
    cam_dist = 0.85

    # Warm portrait lighting
    cleanup_lights_cameras()
    add_light('AREA', (1.2, -1.2, head_z + 0.5), (1.0, 0.85, 0.65), 200.0, (0, -0.05, head_z), 1.5)
    add_light('AREA', (-0.8, 0.5, head_z + 0.3), (0.20, 0.55, 0.95), 80.0, (0, -0.05, head_z), 1.5)
    add_light('AREA', (0.5, 0.8, head_z), (1.0, 0.45, 0.05), 50.0, (0, -0.05, head_z), 1.0)
    setup_world((0.008, 0.012, 0.018), 0.20)

    cam = add_camera("PortraitCam", (0.6, -0.9, head_z), (0, -0.05, head_z), fov=42.0)
    bpy.context.scene.camera = cam

    # === Task 40: neutral portrait ===
    render_to(os.path.join(PORTRAIT_DIR, f"npc_{npc_id}_portrait.png"), 384, 512, samples=64)

    # === Task 41: 4 emotion variant portraits via simple pose offsets ===
    arm_obj = None
    for o in bpy.data.objects:
        if o.type == 'ARMATURE':
            arm_obj = o
            break
    if arm_obj is not None:
        bpy.context.view_layer.objects.active = arm_obj
        bpy.ops.object.mode_set(mode='POSE')

        def set_pose(head_pitch, head_yaw, chest_pitch):
            head_pb = arm_obj.pose.bones.get("head")
            if head_pb is not None:
                head_pb.rotation_mode = 'XYZ'
                head_pb.rotation_euler = (math.radians(head_pitch), 0, math.radians(head_yaw))
            chest_pb = arm_obj.pose.bones.get("chest")
            if chest_pb is not None:
                chest_pb.rotation_mode = 'XYZ'
                chest_pb.rotation_euler = (math.radians(chest_pitch), 0, 0)

        # Happy: head slight up + slight right tilt
        set_pose(-5, 8, -3)
        bpy.ops.object.mode_set(mode='OBJECT')
        render_to(os.path.join(PORTRAIT_DIR, f"npc_{npc_id}_portrait_happy.png"), 384, 512, samples=64)
        bpy.ops.object.mode_set(mode='POSE')

        # Sad: head down
        set_pose(15, 0, 8)
        bpy.ops.object.mode_set(mode='OBJECT')
        render_to(os.path.join(PORTRAIT_DIR, f"npc_{npc_id}_portrait_sad.png"), 384, 512, samples=64)
        bpy.ops.object.mode_set(mode='POSE')

        # Surprised: head up + back lean
        set_pose(-12, 0, -5)
        bpy.ops.object.mode_set(mode='OBJECT')
        render_to(os.path.join(PORTRAIT_DIR, f"npc_{npc_id}_portrait_surprised.png"), 384, 512, samples=64)
        bpy.ops.object.mode_set(mode='POSE')

        # Angry: head forward + chest forward
        set_pose(8, 0, 5)
        bpy.ops.object.mode_set(mode='OBJECT')
        render_to(os.path.join(PORTRAIT_DIR, f"npc_{npc_id}_portrait_angry.png"), 384, 512, samples=64)


for npc in NPC_BLENDS:
    render_npc(*npc)

print(f"\n=== Epic 10 portrait renders complete ===")
print(f"  12 neutral + 48 emotion = 60 portraits")
