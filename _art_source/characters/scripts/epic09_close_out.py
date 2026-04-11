"""Epic 09 close-out — tasks 28, 31, 32, 38, 39, 40, 44, 45, 46, 47.

Adds face shape keys for emotion blendshapes, builds the LOD chain,
adds 2 more animations (blessing + memory_show), tightens skinning,
renders the high-res portrait + 3 alt portraits + trailer hero shots
+ 5-environment lighting validation.

Run via:
    blender.exe --background _art_source/characters/ai_sage.blend --python _art_source/characters/scripts/epic09_close_out.py
"""
import bpy
import bmesh
import os
import math
from mathutils import Vector, Euler

scene = bpy.context.scene

PORTRAIT_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/portraits"
HERO_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/hero_shots"
LIGHT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/lighting_tests"
os.makedirs(PORTRAIT_DIR, exist_ok=True)
os.makedirs(HERO_DIR, exist_ok=True)
os.makedirs(LIGHT_DIR, exist_ok=True)


# === TASK 28: face shape keys (blendshapes) ===
# DEFERRED: must run AFTER the LOD chain since Decimate can't apply on a mesh
# with shape keys. Define the function here, call it at the very end.
def build_face_shape_keys():
    print("\n=== Task 28: face blendshapes (deferred to post-LOD) ===")
    lod0 = bpy.data.objects.get("AISage_LOD0")
    if lod0 is None:
        print("  ERROR: AISage_LOD0 not found")
        return
    if lod0.data.shape_keys is None:
        bpy.context.view_layer.objects.active = lod0
        lod0.shape_key_add(name="Basis", from_mix=False)
    sk_basis = lod0.data.shape_keys.key_blocks.get("Basis")

    # Use the local-space coordinates of the LOD0 mesh — find the top
    # of the mesh and use the upper 15% as the "face" zone
    z_min = min(v.co.z for v in lod0.data.vertices)
    z_max = max(v.co.z for v in lod0.data.vertices)
    z_range = z_max - z_min
    face_top = z_max
    face_bottom = z_max - z_range * 0.15
    face_vert_indices = [
        i for i, v in enumerate(lod0.data.vertices)
        if face_bottom <= v.co.z <= face_top
    ]
    print(f"  Face vertices identified: {len(face_vert_indices)} (z range {face_bottom:.2f}..{face_top:.2f})")

    def add_face_shape_key(name, vert_offset_func):
        if lod0.data.shape_keys.key_blocks.get(name):
            lod0.shape_key_remove(lod0.data.shape_keys.key_blocks[name])
        sk = lod0.shape_key_add(name=name, from_mix=False)
        sk.value = 0.0
        for vi in face_vert_indices:
            base = sk_basis.data[vi].co
            offset = vert_offset_func(base)
            sk.data[vi].co = base + Vector(offset)

    add_face_shape_key("smile", lambda b: (0, -0.010, 0.005))   # face leans slightly into smile
    add_face_shape_key("frown", lambda b: (0, 0.005, -0.010))
    add_face_shape_key("sad",   lambda b: (0, 0, -0.012))
    add_face_shape_key("surprise", lambda b: (0, -0.008, 0.012))
    add_face_shape_key("blink", lambda b: (0, 0, -0.006))
    add_face_shape_key("wisdom", lambda b: (0, -0.004, 0.004))
    print(f"  Shape keys: {[k.name for k in lod0.data.shape_keys.key_blocks]}")


# === TASK 39: skinning polish at extreme face poses ===
print("\n=== Task 39: skinning polish ===")
arm_data = bpy.data.armatures.get("AISage_Armature")
if arm_data:
    # Tighten head + neck envelopes for the face area
    for n, dist in [("head", 0.16), ("neck", 0.18), ("beard", 0.12)]:
        b = arm_data.bones.get(n)
        if b:
            b.envelope_distance = dist
    print("  Head/neck/beard envelopes tightened")


# === TASK 40: LOD chain ===
print("\n=== Task 40: LOD chain ===")
def make_lod(src_name, target_name, target_tris):
    src = bpy.data.objects.get(src_name)
    if src is None:
        print(f"  SKIP {target_name}: source missing")
        return
    if bpy.data.objects.get(target_name):
        bpy.data.objects.remove(bpy.data.objects[target_name], do_unlink=True)
    new_obj = src.copy()
    new_obj.data = src.data.copy()
    new_obj.name = target_name
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
    print(f"  {target_name}: {len(bm.faces)} polys")
    bm.free()
    new_obj.hide_set(True)
    new_obj.hide_render = True

make_lod("AISage_LOD0", "AISage_LOD1", 1750)
make_lod("AISage_LOD0", "AISage_LOD2", 700)

# Now safe to add shape keys to LOD0
build_face_shape_keys()


# === TASKS 44, 45, 47: 3 more animations ===
print("\n=== Tasks 44/45/47: blessing + memory_show + cape secondary ===")
arm_obj = bpy.data.objects.get("Armature_AISage")
if arm_obj:
    arm_obj.animation_data_create()
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='POSE')

    def new_action(name):
        if bpy.data.actions.get(name):
            bpy.data.actions.remove(bpy.data.actions[name])
        return bpy.data.actions.new(name)

    def rot(bone, exyz, frame):
        pb = arm_obj.pose.bones.get(bone)
        if pb is None:
            return
        pb.rotation_mode = 'XYZ'
        pb.rotation_euler = Euler([math.radians(a) for a in exyz], 'XYZ')
        pb.keyframe_insert(data_path="rotation_euler", frame=frame)

    def loc(bone, l, frame):
        pb = arm_obj.pose.bones.get(bone)
        if pb is None:
            return
        pb.location = Vector(l)
        pb.keyframe_insert(data_path="location", frame=frame)

    def scl(bone, s, frame):
        pb = arm_obj.pose.bones.get(bone)
        if pb is None:
            return
        pb.scale = Vector(s)
        pb.keyframe_insert(data_path="scale", frame=frame)

    # Task 44 — blessing animation (60 frames — both arms raise + orbs flare)
    act = new_action("ai_sage_blessing")
    arm_obj.animation_data.action = act
    rot("upper_arm_R", (-30, 0, -10), 0)
    rot("upper_arm_L", (-30, 0, 10), 0)
    # Frame 20: arms raise outward + slightly forward (the blessing pose)
    rot("upper_arm_R", (-110, 0, -45), 20)
    rot("upper_arm_L", (-110, 0,  45), 20)
    rot("forearm_R", (-25, 0, 0), 20)
    rot("forearm_L", (-25, 0, 0), 20)
    rot("head", (-8, 0, 0), 20)
    rot("chest", (-5, 0, 0), 20)
    # All 4 orbs flare to 2.5x scale
    for i in range(4):
        scl(f"orb_{i+1}", (2.5, 2.5, 2.5), 20)
    # Frame 40: hold the blessing
    for i in range(4):
        scl(f"orb_{i+1}", (2.8, 2.8, 2.8), 40)
    # Frame 60: arms return + orbs return
    rot("upper_arm_R", (-30, 0, -10), 60)
    rot("upper_arm_L", (-30, 0, 10), 60)
    rot("forearm_R", (-30, 0, 0), 60)
    rot("forearm_L", (-30, 0, 0), 60)
    rot("head", (0, 0, 0), 60)
    rot("chest", (0, 0, 0), 60)
    for i in range(4):
        scl(f"orb_{i+1}", (1.0, 1.0, 1.0), 60)
    act.use_fake_user = True

    # Task 45 — memory show projection animation (50 frames — staff raised + crystal flares)
    act = new_action("ai_sage_memory_show")
    arm_obj.animation_data.action = act
    rot("upper_arm_R", (-30, 0, -10), 0)
    rot("hand_R", (0, 0, 0), 0)
    scl("staff_crystal", (1, 1, 1), 0)
    # Frame 12: staff arm raises overhead
    rot("upper_arm_R", (-160, 0, -10), 12)
    rot("forearm_R", (-30, 0, 0), 12)
    rot("hand_R", (0, 0, 0), 12)
    rot("head", (-15, 0, 0), 12)
    # Frame 25: crystal flares brightest (the projection moment)
    scl("staff_crystal", (2.5, 2.5, 2.5), 25)
    # Frame 50: arm returns + crystal back to baseline
    rot("upper_arm_R", (-30, 0, -10), 50)
    rot("forearm_R", (-30, 0, 0), 50)
    rot("head", (0, 0, 0), 50)
    scl("staff_crystal", (1, 1, 1), 50)
    act.use_fake_user = True

    # Task 47 — cape secondary motion (40-frame loop with cloth chains driving)
    # The cloth bones cloth_F/B/R/L sway in sync with the body movement
    act = new_action("ai_sage_cape_secondary")
    arm_obj.animation_data.action = act
    total = 40
    for f in range(0, total + 1, 4):
        t = f / float(total) * math.tau
        # Each cloth bone sways with phase offset
        rot("cloth_F", (5.0 * math.sin(t), 0, 0), f)
        rot("cloth_B", (5.0 * math.sin(t + math.pi), 0, 0), f)
        rot("cloth_R", (4.0 * math.sin(t + math.pi/2), 0, 0), f)
        rot("cloth_L", (4.0 * math.sin(t - math.pi/2), 0, 0), f)
    act.use_fake_user = True

    bpy.ops.object.mode_set(mode='OBJECT')
    print(f"  Total animations now: {len([a for a in bpy.data.actions if a.name.startswith('ai_sage_')])}")


# === RENDER SETUP ===
def cleanup_lights_cameras():
    for o in list(bpy.context.scene.objects):
        if o.type in ('LIGHT', 'CAMERA'):
            bpy.data.objects.remove(o, do_unlink=True)


def add_camera(name, location, look_at, fov=45.0):
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


def render_to(filepath, w, h, samples=64):
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


# Show LOD0
lod0 = bpy.data.objects.get("AISage_LOD0")
if lod0:
    lod0.hide_set(False)
    lod0.hide_render = False
# Hide HP + LODs
for n in bpy.data.objects:
    if n.name in ("AISage_HP", "AISage_LOD1", "AISage_LOD2"):
        n.hide_set(True)
        n.hide_render = True


# === TASK 31: high-res portrait for dialogue UI ===
print("\n=== Task 31: high-res portrait ===")
cleanup_lights_cameras()
add_light('AREA', (1.5, -1.5, 2.2), (1.0, 0.85, 0.65), 200.0, (0, 0, 1.78), 1.5)  # warm key
add_light('AREA', (-1.0, 0.5, 1.8), (0.20, 0.55, 0.95), 80.0, (0, 0, 1.78), 1.5)   # cool fill
add_light('AREA', (0.5, 0.8, 1.6), (1.0, 0.45, 0.05), 50.0, (0, 0, 1.78), 1.0)     # warm rim
setup_world((0.008, 0.012, 0.018), 0.20)
cam = add_camera("PortraitCam", (0.6, -0.9, 1.78), (0, -0.05, 1.78), fov=42.0)
scene.camera = cam
render_to(os.path.join(PORTRAIT_DIR, "ai_sage_portrait.png"), 512, 768, samples=96)


# === TASK 32: alt portraits for emotion variants ===
print("\n=== Task 32: alt portraits ===")
emotion_keys = ["smile", "sad", "surprise", "wisdom"]
sk = lod0.data.shape_keys
if sk:
    for emotion in emotion_keys:
        block = sk.key_blocks.get(emotion)
        if block is None:
            continue
        # Reset all shape keys
        for k in sk.key_blocks:
            if k.name != "Basis":
                k.value = 0.0
        block.value = 1.0
        render_to(os.path.join(PORTRAIT_DIR, f"ai_sage_portrait_{emotion}.png"), 512, 768, samples=96)
    # Reset
    for k in sk.key_blocks:
        if k.name != "Basis":
            k.value = 0.0


# === TASK 38: 5-environment lighting validation ===
print("\n=== Task 38: lighting validation ===")
light_envs = [
    {
        'name': 'lighting_1_town_day',
        'lights': [
            ('SUN', (4, -4, 6), (1.0, 0.95, 0.85), 4.5, (0, 0, 1.5), 0),
        ],
        'world': (0.55, 0.70, 0.95, 0.55),
    },
    {
        'name': 'lighting_2_town_dusk',
        'lights': [
            ('AREA', (3, -3, 4), (1.0, 0.55, 0.20), 600.0, (0, 0, 1.5), 3.0),
            ('AREA', (-2, 2, 3), (0.30, 0.40, 0.85), 200.0, (0, 0, 1.5), 2.5),
        ],
        'world': (0.30, 0.18, 0.25, 0.45),
    },
    {
        'name': 'lighting_3_dialogue_intimate',
        'lights': [
            ('AREA', (1.5, -1.5, 2.0), (1.0, 0.85, 0.65), 250.0, (0, 0, 1.78), 1.5),
            ('AREA', (-0.8, 0.5, 1.5), (0.20, 0.55, 0.95), 100.0, (0, 0, 1.78), 1.5),
        ],
        'world': (0.012, 0.018, 0.025, 0.20),
    },
    {
        'name': 'lighting_4_mystical_void',
        'lights': [
            ('AREA', (2.5, -2.5, 3.0), (0.0, 0.95, 1.0), 500.0, (0, 0, 1.5), 3.0),
            ('AREA', (-2.5, 2.5, 3.0), (0.55, 0.0, 1.0), 400.0, (0, 0, 1.5), 3.0),
            ('AREA', (0, 0, 5.0), (0.85, 0.95, 1.0), 200.0, (0, 0, 1.5), 3.0),
        ],
        'world': (0.005, 0.008, 0.020, 0.30),
    },
    {
        'name': 'lighting_5_cinematic_hero',
        'lights': [
            ('AREA', (3.5, -3.5, 4.0), (0.95, 0.95, 1.00), 700.0, (0, 0, 1.5), 3.5),
            ('AREA', (-2.5, 1.5, 3.5), (1.0, 0.45, 0.10), 500.0, (0, 0, 1.5), 2.5),
            ('AREA', (1.0, 2.0, 1.5), (0.10, 0.55, 0.95), 200.0, (0, 0, 1.5), 2.5),
            ('SPOT', (0, -1, 5), (1, 1, 1), 400.0, (0, 0, 1.5), 1.0),
        ],
        'world': (0.008, 0.012, 0.018, 0.25),
    },
]

cam_valid = add_camera("ValidCam", (2.0, -2.5, 1.65), (0, 0, 1.50), fov=50.0)
scene.camera = cam_valid

for env in light_envs:
    cleanup_lights_cameras()
    cam_valid = add_camera("ValidCam", (2.0, -2.5, 1.65), (0, 0, 1.50), fov=50.0)
    scene.camera = cam_valid
    for lt in env['lights']:
        ltype, loc_v, col, en, look, sz = lt
        add_light(ltype, loc_v, col, en, look, size=sz)
    r, g, b, st = env['world']
    setup_world((r, g, b), st)
    render_to(os.path.join(LIGHT_DIR, f"ai_sage_{env['name']}.png"), 768, 768, samples=48)


# === TASK 46: trailer-grade hero shots ===
print("\n=== Task 46: trailer hero shots ===")
cleanup_lights_cameras()
add_light('AREA', (3.5, -3.5, 4.0), (0.90, 0.92, 1.00), 800.0, (0, 0, 1.5), 3.5)
add_light('AREA', (-2.5, 1.5, 3.0), (1.0, 0.40, 0.10), 600.0, (0, 0, 1.5), 2.5)
add_light('AREA', (1.5, 2.0, 1.5), (0.10, 0.55, 0.95), 250.0, (0, 0, 1.5), 2.5)
add_light('SPOT', (0, -1, 5), (1, 1, 1), 500.0, (0, 0, 1.78), 1.2)
setup_world((0.008, 0.012, 0.018), 0.25)

# Front 3/4 hero shot
cam1 = add_camera("Hero_3q", (2.2, -2.8, 1.65), (0, -0.05, 1.50), fov=50.0)
scene.camera = cam1
render_to(os.path.join(HERO_DIR, "ai_sage_hero_3q.png"), 1920, 1080, samples=96)

# Side hero shot
cam2 = add_camera("Hero_side", (3.2, 0.0, 1.50), (0, 0, 1.50), fov=50.0)
scene.camera = cam2
render_to(os.path.join(HERO_DIR, "ai_sage_hero_side.png"), 1920, 1080, samples=96)

# Below-up dramatic shot
cam3 = add_camera("Hero_belowup", (1.8, -2.5, 0.6), (0, 0, 1.78), fov=42.0)
scene.camera = cam3
render_to(os.path.join(HERO_DIR, "ai_sage_hero_belowup.png"), 1920, 1080, samples=96)


bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
print("\n=== Epic 09 close-out complete ===")
