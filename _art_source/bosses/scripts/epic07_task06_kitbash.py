"""Epic 07 task 6 — kit-bash modular parts so phases share geometry.

Reorganizes the existing 81 meshes in compiler_boss_master.blend into
3 phase collections (Compiler_Shared, Compiler_P2_Overlay,
Compiler_P3_Overlay) plus a Kit_Bash_Library collection of reusable
modular parts. Run via:

    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_task06_kitbash.py
"""
import bpy
import bmesh
import math
from mathutils import Vector, Matrix


def get_or_create_collection(name, parent_col):
    coll = bpy.data.collections.get(name)
    if coll is None:
        coll = bpy.data.collections.new(name)
        parent_col.children.link(coll)
    return coll


def move_to_collection(obj, target_col):
    for col in list(obj.users_collection):
        col.objects.unlink(obj)
    target_col.objects.link(obj)


scene = bpy.context.scene
scene_col = scene.collection

shared_col = get_or_create_collection("Compiler_Shared", scene_col)
p2_col     = get_or_create_collection("Compiler_P2_Overlay", scene_col)
p3_col     = get_or_create_collection("Compiler_P3_Overlay", scene_col)
kit_col    = get_or_create_collection("Kit_Bash_Library", scene_col)

# Classify each existing mesh by name prefix
classified_count = {'shared': 0, 'p2': 0, 'p3': 0, 'kit': 0, 'other': 0}
for obj in list(bpy.context.scene.objects):
    if obj.type != 'MESH':
        continue
    name = obj.name
    if name.startswith("compiler_p2_debris"):
        move_to_collection(obj, p2_col)
        classified_count['p2'] += 1
    elif name.startswith("compiler_p1_"):
        move_to_collection(obj, shared_col)
        classified_count['shared'] += 1
    elif name.startswith("compiler_p2_"):
        move_to_collection(obj, p2_col)
        classified_count['p2'] += 1
    elif name.startswith("compiler_p3_"):
        move_to_collection(obj, p3_col)
        classified_count['p3'] += 1
    else:
        classified_count['other'] += 1

print(f"Classification: {classified_count}")

# === KIT-BASH LIBRARY ===
# Reusable parameterized templates parented to a kit_root empty 15m
# offset from the boss for clarity. These are LINKABLE into other
# Blender scenes for boss variations.

kit_root = bpy.data.objects.get("Kit_Root")
if kit_root is None:
    kit_root = bpy.data.objects.new("Kit_Root", None)
    kit_col.objects.link(kit_root)
    kit_root.location = (15, 0, 0)

mat_chrome = bpy.data.materials.get("Compiler_Chrome_P1")
mat_gunmetal = bpy.data.materials.get("Compiler_Gunmetal_P1")
mat_led = bpy.data.materials.get("Compiler_LED_Cyan")
mat_thruster = bpy.data.materials.get("Compiler_Thruster_Housing") if bpy.data.materials.get("Compiler_Thruster_Housing") else mat_chrome


def create_kit_mesh(name, bm, location, material):
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    me = bpy.data.meshes.new(name + "_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    obj.location = location
    if material is not None:
        obj.data.materials.append(material)
    kit_col.objects.link(obj)
    obj.parent = kit_root
    for p in obj.data.polygons:
        p.use_smooth = True
    return obj


# === KIT 1: tapered arm segment (reusable for any boss arm) ===
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=14, radius1=0.18, radius2=0.14, depth=0.50, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_kit_mesh("kit_arm_segment_template", bm, (0, 0, 0), mat_chrome)

# === KIT 2: 3-finger manipulator hand template ===
bm = bmesh.new()
center = Vector((0, 0, 1))
for i in range(3):
    finger_angle = (i - 1) * math.radians(40)
    finger_dir = Vector((math.sin(finger_angle), -0.5, -0.8)).normalized()
    sub = bmesh.new()
    bmesh.ops.create_cone(sub, segments=10, radius1=0.05, radius2=0.025, depth=0.18, cap_ends=True)
    zdir = Vector((0, 0, 1))
    if (finger_dir - zdir).length > 1e-4:
        axis = zdir.cross(finger_dir)
        if axis.length < 1e-5:
            axis = Vector((1, 0, 0))
        angle = math.acos(max(-1.0, min(1.0, zdir.dot(finger_dir))))
        rot = Matrix.Rotation(angle, 4, axis.normalized())
        for v in sub.verts:
            v.co = rot @ v.co
    for v in sub.verts:
        v.co += center + finger_dir * 0.10
    verts_map = {}
    for v in sub.verts:
        verts_map[v] = bm.verts.new(v.co)
    bm.verts.ensure_lookup_table()
    for f in sub.faces:
        try:
            bm.faces.new([verts_map[v] for v in f.verts])
        except ValueError:
            pass
    sub.free()
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_kit_mesh("kit_manipulator_hand_template", bm, (0, 0, 0), mat_chrome)

# === KIT 3: LED accent strip (reusable seam light) ===
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 1.0
    v.co.y *= 0.012
    v.co.z *= 0.012
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_kit_mesh("kit_led_strip_template", bm, (0, -0.5, 0), mat_led)

# === KIT 4: chrome ball joint (reusable shoulder/elbow) ===
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=10, radius=0.30)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_kit_mesh("kit_ball_joint_template", bm, (0, -1.0, 0), mat_chrome)

# === KIT 5: cooling fin (reusable heat-radiator silhouette) ===
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.05
    v.co.y *= 0.18
    v.co.z *= 1.10
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_kit_mesh("kit_cooling_fin_template", bm, (0, -1.5, 0), mat_chrome)

# === KIT 6: panel module (reusable boxy plate) ===
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.6
    v.co.y *= 0.08
    v.co.z *= 0.4
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
bmesh.ops.bevel(bm, geom=list(bm.edges) + list(bm.verts), offset=0.01, segments=2, affect='EDGES')
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_kit_mesh("kit_panel_module_template", bm, (0, -2.0, 0), mat_gunmetal)

# === KIT 7: chest core recess (reusable boss face plate) ===
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=20, radius1=0.42, radius2=0.42, depth=0.10, cap_ends=True)
rot = Matrix.Rotation(math.radians(90), 4, 'X')
for v in bm.verts:
    v.co = rot @ v.co
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_kit_mesh("kit_chest_core_recess_template", bm, (0, -2.5, 0), mat_gunmetal)

# === KIT 8: tether cable (reusable ground anchor cable) ===
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=8, radius1=0.06, radius2=0.06, depth=2.5, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_kit_mesh("kit_tether_cable_template", bm, (0, -3.0, 0), mat_chrome)

bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)

# Verify
shared_count = len([o for o in shared_col.objects])
p2_count = len([o for o in p2_col.objects])
p3_count = len([o for o in p3_col.objects])
kit_count = len([o for o in kit_col.objects])
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"Collections — Shared: {shared_count}, P2: {p2_count}, P3: {p3_count}, Kit: {kit_count}")
print(f"Total mesh count: {total}")
print(f"Kit-bash library has 8 reusable templates")
