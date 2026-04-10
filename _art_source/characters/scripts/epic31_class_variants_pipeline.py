"""
Epic 31 — Class Variant Globbler + Hero Portraits Pipeline
============================================================
Builds 3 class-themed visual variants of Globbler and renders:
 - Task 9: Class visual variants (Compiler/Daemon/Kernel)
 - Task 32: Class hero portraits (3 Cycles renders)
 - Task 47: Class showcase frames (3 wider trailer-style shots)

Each class variant shares the same base Globbler silhouette but with:
  - Different shell color & emission accent
  - Class-specific shoulder rig
  - Class-specific weapon prop
  - Class-specific aura ring
  - Class-specific glyph hovering above the head

Saves:
  - _art_source/characters/class_variants.blend
  - _art_source/characters/renders/class_compiler_portrait.png
  - _art_source/characters/renders/class_daemon_portrait.png
  - _art_source/characters/renders/class_kernel_portrait.png
  - _art_source/characters/renders/class_compiler_showcase.png
  - _art_source/characters/renders/class_daemon_showcase.png
  - _art_source/characters/renders/class_kernel_showcase.png
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/class_variants.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.render.resolution_x = 720
scene.render.resolution_y = 960  # portrait 3:4

def make_pbr(name, base, rough=0.55, metal=0.0, emit=None, emit_strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*base, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if emit is not None:
        bsdf.inputs['Emission Color'].default_value = (*emit, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emit_strength
    return m

# Class palettes
CLASSES = {
    "compiler": {
        "shell": (0.18, 0.42, 0.65),
        "shell_rough": 0.45,
        "accent": (1.0, 0.85, 0.35),
        "accent_emit": 3.5,
        "aura": (0.2, 0.55, 1.0),
        "weapon_kind": "balanced",  # sword + shield rune
        "shoulder_kind": "pad",
        "glyph_kind": "gear",
    },
    "daemon": {
        "shell": (0.62, 0.10, 0.20),
        "shell_rough": 0.35,
        "accent": (1.0, 0.30, 0.45),
        "accent_emit": 4.5,
        "aura": (1.0, 0.15, 0.35),
        "weapon_kind": "twin_daggers",
        "shoulder_kind": "spike",
        "glyph_kind": "blade",
    },
    "kernel": {
        "shell": (0.15, 0.30, 0.30),
        "shell_rough": 0.55,
        "accent": (0.30, 0.85, 0.85),
        "accent_emit": 3.0,
        "aura": (0.25, 0.85, 0.95),
        "weapon_kind": "tower_shield",
        "shoulder_kind": "plate",
        "glyph_kind": "fortress",
    },
}

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_compiler = make_coll("Class_Compiler")
col_daemon = make_coll("Class_Daemon")
col_kernel = make_coll("Class_Kernel")
col_lights = make_coll("Class_Lights")
col_cam = make_coll("Class_Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_bm(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    if mat is not None:
        me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot; obj.scale = scale
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

def cube(sx, sy, sz):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    return bm

def ico(r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    return bm

def cyl(r, h, segs=12):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def cone(r1, r2, h, segs=10):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def disk(r, segs=24):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=segs, radius=r, cap_ends=True, cap_tris=True)
    return bm

def add_torus(name, mat, coll, loc, major=0.7, minor=0.05):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=32, radius=major, cap_ends=False)
    bm.verts.ensure_lookup_table()
    inner = bm.verts[:]
    bmesh.ops.create_circle(bm, segments=32, radius=major - minor*2, cap_ends=False)
    bm.verts.ensure_lookup_table()
    outer = bm.verts[32:64]
    for j in range(32):
        bm.faces.new([inner[j], inner[(j+1)%32], outer[(j+1)%32], outer[j]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_bm(name, bm, mat, coll, loc=loc, rot=(math.radians(90), 0, 0))

# === Build a class variant ===
def build_class(class_id, coll, x_offset):
    spec = CLASSES[class_id]
    mat_shell = make_pbr(f"{class_id}_shell", spec["shell"], spec["shell_rough"], 0.2)
    mat_accent = make_pbr(f"{class_id}_accent", spec["accent"], 0.3, 0.0,
                          spec["accent"], spec["accent_emit"])
    mat_aura = make_pbr(f"{class_id}_aura", spec["aura"], 0.4, 0.0,
                        spec["aura"], 1.5)
    mat_metal = make_pbr(f"{class_id}_metal", (0.4, 0.4, 0.45), 0.3, 0.95)
    mat_dark = make_pbr(f"{class_id}_dark", (0.05, 0.05, 0.08), 0.65)

    # Body (rounded cube → squat blob silhouette)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.55, 0.55, 0.7), verts=bm.verts)
    # Round corners
    bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=0.18, segments=4, profile=0.5, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_bm(f"{class_id}_Body", bm, mat_shell, coll, loc=(x_offset, 0, 0.7))

    # Head
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.32)
    bmesh.ops.scale(bm, vec=(1, 0.95, 1.05), verts=bm.verts)
    add_bm(f"{class_id}_Head", bm, mat_shell, coll, loc=(x_offset, 0, 1.55))

    # Visor
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=0.22)
    bmesh.ops.scale(bm, vec=(1, 0.4, 0.5), verts=bm.verts)
    add_bm(f"{class_id}_Visor", bm, mat_accent, coll, loc=(x_offset, -0.18, 1.6))

    # Eyes (two glow points behind visor)
    add_bm(f"{class_id}_EyeL", ico(0.04, 1), mat_accent, coll, loc=(x_offset-0.08, -0.22, 1.62))
    add_bm(f"{class_id}_EyeR", ico(0.04, 1), mat_accent, coll, loc=(x_offset+0.08, -0.22, 1.62))

    # Chest emblem (large class accent)
    add_bm(f"{class_id}_ChestEmblem", ico(0.18, 2), mat_accent, coll, loc=(x_offset, -0.35, 0.95))
    # Emblem ring
    add_torus(f"{class_id}_EmblemRing", mat_accent, coll, (x_offset, -0.36, 0.95), major=0.27, minor=0.04)

    # Shoulders (per-class)
    if spec["shoulder_kind"] == "pad":  # compiler — flat broad pads
        for side in [-1, 1]:
            add_bm(f"{class_id}_Shoulder_{side}", cube(0.22, 0.32, 0.18),
                   mat_metal, coll, loc=(x_offset + side*0.55, 0, 1.25))
    elif spec["shoulder_kind"] == "spike":  # daemon — sharp upward spikes
        for side in [-1, 1]:
            add_bm(f"{class_id}_ShoulderSpike_{side}", cone(0.18, 0.02, 0.5),
                   mat_metal, coll, loc=(x_offset + side*0.55, 0, 1.25),
                   rot=(0, side*math.radians(15), 0))
    elif spec["shoulder_kind"] == "plate":  # kernel — heavy stacked plates
        for side in [-1, 1]:
            add_bm(f"{class_id}_ShoulderPlate1_{side}", cube(0.28, 0.4, 0.1),
                   mat_metal, coll, loc=(x_offset + side*0.6, 0, 1.3))
            add_bm(f"{class_id}_ShoulderPlate2_{side}", cube(0.32, 0.42, 0.08),
                   mat_metal, coll, loc=(x_offset + side*0.62, 0, 1.18))

    # Arms (cylinders + accent bands)
    for side in [-1, 1]:
        add_bm(f"{class_id}_Arm_{side}", cyl(0.13, 0.7, 8), mat_shell, coll,
               loc=(x_offset + side*0.55, 0, 0.5))
        add_bm(f"{class_id}_ArmBand_{side}", cyl(0.14, 0.06, 12), mat_accent, coll,
               loc=(x_offset + side*0.55, 0, 0.85))

    # Hands
    for side in [-1, 1]:
        add_bm(f"{class_id}_Hand_{side}", ico(0.13, 2), mat_shell, coll,
               loc=(x_offset + side*0.55, 0, 0.18))

    # Legs
    for side in [-1, 1]:
        add_bm(f"{class_id}_Leg_{side}", cyl(0.15, 0.6, 8), mat_shell, coll,
               loc=(x_offset + side*0.22, 0, 0.0))
        add_bm(f"{class_id}_Boot_{side}", cube(0.18, 0.26, 0.1), mat_dark, coll,
               loc=(x_offset + side*0.22, 0, -0.25))

    # Weapon (per-class)
    if spec["weapon_kind"] == "balanced":  # compiler — sword in right, rune-shield on left
        # Sword
        add_bm(f"{class_id}_SwordHilt", cube(0.07, 0.07, 0.18), mat_dark, coll,
               loc=(x_offset + 0.62, -0.05, 0.3))
        add_bm(f"{class_id}_SwordGuard", cube(0.22, 0.05, 0.05), mat_metal, coll,
               loc=(x_offset + 0.62, -0.05, 0.45))
        add_bm(f"{class_id}_SwordBlade", cube(0.04, 0.05, 0.55), mat_metal, coll,
               loc=(x_offset + 0.62, -0.05, 0.85))
        add_bm(f"{class_id}_SwordRune", ico(0.05, 1), mat_accent, coll,
               loc=(x_offset + 0.62, -0.10, 1.0))
        # Rune disk (shield)
        add_torus(f"{class_id}_RuneDisk", mat_accent, coll, (x_offset - 0.62, -0.18, 0.55), major=0.22, minor=0.04)
        add_bm(f"{class_id}_RuneCenter", ico(0.10, 2), mat_accent, coll, loc=(x_offset - 0.62, -0.18, 0.55))
    elif spec["weapon_kind"] == "twin_daggers":  # daemon — two daggers
        for side, offset in [(-1, -0.65), (1, 0.65)]:
            add_bm(f"{class_id}_DaggerHilt_{side}", cube(0.05, 0.05, 0.15), mat_dark, coll,
                   loc=(x_offset + offset, -0.05, 0.25))
            add_bm(f"{class_id}_DaggerBlade_{side}", cone(0.04, 0.0, 0.35),
                   mat_metal, coll, loc=(x_offset + offset, -0.05, 0.5))
            add_bm(f"{class_id}_DaggerGlow_{side}", cyl(0.02, 0.32, 6), mat_accent, coll,
                   loc=(x_offset + offset, -0.04, 0.5))
    elif spec["weapon_kind"] == "tower_shield":  # kernel — massive shield
        add_bm(f"{class_id}_ShieldBody", cube(0.08, 0.55, 1.0), mat_metal, coll,
               loc=(x_offset - 0.7, -0.25, 0.55))
        add_torus(f"{class_id}_ShieldRing", mat_accent, coll, (x_offset - 0.66, -0.25, 0.55), major=0.32, minor=0.04)
        add_bm(f"{class_id}_ShieldCore", ico(0.14, 2), mat_accent, coll, loc=(x_offset - 0.62, -0.25, 0.55))

    # Aura ring at feet
    add_torus(f"{class_id}_AuraRing", mat_aura, coll, (x_offset, 0, -0.32), major=0.85, minor=0.05)
    # Aura disk (subtle)
    add_bm(f"{class_id}_AuraDisk", disk(0.85, 24), mat_aura, coll, loc=(x_offset, 0, -0.35))

    # Glyph hovering above head (per-class)
    glyph_loc = (x_offset, 0, 2.4)
    if spec["glyph_kind"] == "gear":
        # 8-tooth gear
        for i in range(8):
            ang = (i / 8) * math.tau
            add_bm(f"{class_id}_GearTooth_{i}", cube(0.06, 0.06, 0.12), mat_accent, coll,
                   loc=(glyph_loc[0] + math.cos(ang)*0.22, glyph_loc[1] + math.sin(ang)*0.22, glyph_loc[2]),
                   rot=(0, 0, ang))
        add_bm(f"{class_id}_GearCenter", cyl(0.12, 0.04, 16), mat_accent, coll, loc=glyph_loc)
        add_bm(f"{class_id}_GearHole", cyl(0.04, 0.05, 12), mat_dark, coll, loc=(glyph_loc[0], glyph_loc[1], glyph_loc[2] + 0.005))
    elif spec["glyph_kind"] == "blade":
        # 3-blade rotor
        for i in range(3):
            ang = (i / 3) * math.tau
            add_bm(f"{class_id}_Blade_{i}", cube(0.18, 0.025, 0.04), mat_accent, coll,
                   loc=(glyph_loc[0] + math.cos(ang)*0.15, glyph_loc[1] + math.sin(ang)*0.15, glyph_loc[2]),
                   rot=(0, 0, ang))
        add_bm(f"{class_id}_BladeHub", ico(0.07, 2), mat_accent, coll, loc=glyph_loc)
    elif spec["glyph_kind"] == "fortress":
        # Square + battlements
        add_bm(f"{class_id}_FortBase", cube(0.18, 0.18, 0.06), mat_accent, coll, loc=glyph_loc)
        for x_off in [-0.1, 0.1]:
            for y_off in [-0.1, 0.1]:
                add_bm(f"{class_id}_FortMerlon_{x_off}_{y_off}", cube(0.04, 0.04, 0.08),
                       mat_accent, coll, loc=(glyph_loc[0]+x_off, glyph_loc[1]+y_off, glyph_loc[2]+0.07))

# Build all 3 classes spaced apart
build_class("compiler", col_compiler, -3)
build_class("daemon", col_daemon, 0)
build_class("kernel", col_kernel, 3)

# === Cameras (one portrait + one showcase per class) ===
print("=== Cameras ===")
def add_camera(name, loc, rot, lens=70):
    cam_data = bpy.data.cameras.new(name)
    cam_data.lens = lens
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cam)
    return cam_obj

# Portraits (close on each)
portrait_cams = {}
showcase_cams = {}
for class_id, x_off in [("compiler", -3), ("daemon", 0), ("kernel", 3)]:
    portrait_cams[class_id] = add_camera(
        f"Portrait_{class_id}", (x_off, -3.5, 1.5), (math.radians(85), 0, 0), lens=85
    )
    showcase_cams[class_id] = add_camera(
        f"Showcase_{class_id}", (x_off + 1.5, -4.5, 2.0), (math.radians(80), 0, math.radians(20)), lens=50
    )

# === Lighting ===
print("=== Lights ===")
# 3-point key
key_data = bpy.data.lights.new("Class_Key", type='AREA')
key_data.energy = 800
key_data.size = 4
key_data.color = (1.0, 0.96, 0.92)
key_obj = bpy.data.objects.new("Class_Key", key_data)
key_obj.location = (-2, -3, 4)
key_obj.rotation_euler = (math.radians(45), math.radians(-15), 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Class_Fill", type='AREA')
fill_data.energy = 250
fill_data.size = 6
fill_data.color = (0.65, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Class_Fill", fill_data)
fill_obj.location = (4, -3, 3)
fill_obj.rotation_euler = (math.radians(50), math.radians(20), 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

rim_data = bpy.data.lights.new("Class_Rim", type='AREA')
rim_data.energy = 600
rim_data.size = 5
rim_data.color = (1.0, 0.85, 0.75)
rim_obj = bpy.data.objects.new("Class_Rim", rim_data)
rim_obj.location = (0, 4, 4)
rim_obj.rotation_euler = (math.radians(120), 0, 0)
scene.collection.objects.link(rim_obj)
link_to(rim_obj, col_lights)

# World
world = bpy.data.worlds.new("Class_World")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.02, 0.03, 0.06, 1.0)
bg.inputs['Strength'].default_value = 0.4

# Save
print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# === Renders ===
all_class_colls = {"compiler": col_compiler, "daemon": col_daemon, "kernel": col_kernel}

# Portraits
scene.render.resolution_x = 720
scene.render.resolution_y = 960
for class_id, coll in all_class_colls.items():
    # Hide the others
    for other_id, other_coll in all_class_colls.items():
        for obj in other_coll.objects:
            obj.hide_render = (other_id != class_id)
    scene.camera = portrait_cams[class_id]
    out_path = os.path.join(RENDER_DIR, f"class_{class_id}_portrait.png")
    scene.render.filepath = out_path
    print(f"=== Rendering {class_id} portrait ===")
    bpy.ops.render.render(write_still=True)

# Showcase frames (wider 16:9)
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
for class_id, coll in all_class_colls.items():
    for other_id, other_coll in all_class_colls.items():
        for obj in other_coll.objects:
            obj.hide_render = (other_id != class_id)
    scene.camera = showcase_cams[class_id]
    out_path = os.path.join(RENDER_DIR, f"class_{class_id}_showcase.png")
    scene.render.filepath = out_path
    print(f"=== Rendering {class_id} showcase ===")
    bpy.ops.render.render(write_still=True)

print("Class variants pipeline complete.")
