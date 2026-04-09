"""Epic 08 task 2 — Crash Daemon full pipeline (sculpt + texture + rig + animate).

Creates a new compact .blend at _art_source/enemies/enemy_crash_daemon.blend
containing the complete Crash Daemon enemy: 1.2m quadruped low-slung body
+ coiled-spring hindquarters + wide flat skull + horizontal LED slit eye
+ charred black metal materials + crimson crack accents + hot engine vents
along the spine + 12-bone rig + 6 animations (idle, coil_windup, dash,
skid_recover, hit_react, death).

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_task02_crash_daemon_pipeline.py
"""
import bpy
import bmesh
import os
import math
from mathutils import Vector, Matrix, Euler

# Start from a clean factory state to avoid clutter
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'
bpy.context.scene.unit_settings.scale_length = 1.0

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_crash_daemon.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/enemies"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


# === MATERIALS ===
def make_pbr(name, base_color, metallic=1.0, roughness=0.30,
             emission_color=None, emission_strength=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = nt.nodes.get("Principled BSDF")
    if bsdf is None:
        for n in list(nt.nodes):
            nt.nodes.remove(n)
        bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
        out = nt.nodes.new("ShaderNodeOutputMaterial")
        nt.links.new(bsdf.outputs[0], out.inputs[0])
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission_color is not None and "Emission Color" in bsdf.inputs:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat


mat_charred = make_pbr("Daemon_Charred",     (0.025, 0.020, 0.020), 0.85, 0.55)
mat_metal   = make_pbr("Daemon_DarkMetal",   (0.05,  0.04,  0.04 ), 1.00, 0.45)
mat_crimson = make_pbr("Daemon_CrimsonCrack",(0.20,  0.0,   0.0  ), 0.0,  0.20, (1.0, 0.10, 0.05), 6.0)
mat_engine  = make_pbr("Daemon_EngineVent", (0.12,  0.04,  0.02 ), 0.40, 0.30, (1.0, 0.45, 0.10), 8.0)
mat_eye     = make_pbr("Daemon_EyeSlit",   (0.10,  0.0,   0.0  ), 0.0,  0.05, (1.0, 0.05, 0.02), 12.0)

root = bpy.data.objects.new("CrashDaemon_Root", None)
bpy.context.scene.collection.objects.link(root)


# === MESH HELPERS ===
def create_mesh(name, bm, location, material, smooth=True):
    me = bpy.data.meshes.new(name + "_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    obj.location = location
    obj.data.materials.append(material)
    bpy.context.scene.collection.objects.link(obj)
    obj.parent = root
    if smooth:
        for p in obj.data.polygons:
            p.use_smooth = True
    return obj


def rotate_to_dir(bm, direction):
    """Rotate +Z bm verts to point along direction."""
    direction = Vector(direction).normalized()
    zdir = Vector((0, 0, 1))
    if (direction - zdir).length < 1e-4:
        return
    axis = zdir.cross(direction)
    if axis.length < 1e-5:
        axis = Vector((1, 0, 0))
    angle = math.acos(max(-1.0, min(1.0, zdir.dot(direction))))
    rot = Matrix.Rotation(angle, 4, axis.normalized())
    for v in bm.verts:
        v.co = rot @ v.co


# === SCULPT BODY ===
# Crash Daemon dimensions:
#   total length: 1.5m (head to tail base)
#   total height: 1.2m at hindquarters peak (coiled springs raised)
#   shoulder height: 0.55m (low slung)
#   hindquarter height: 1.0m
# Quadruped silhouette: head low + shoulders low + spine sloping UP toward
# raised hindquarters (the coiled spring tell)

# === MAIN BODY (torso + chest) — elongated ovoid sloping back-up ===
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=0.30)
# Stretch along Y (front-back) and squash Z slightly
for v in bm.verts:
    v.co.y *= 1.50
    v.co.z *= 0.85
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
torso = create_mesh("crash_daemon_torso", bm, (0, 0, 0.55), mat_charred)
mod = torso.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1
mod.render_levels = 2

# === HINDQUARTERS — raised bulk for the coiled spring ===
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=0.32)
for v in bm.verts:
    v.co.y *= 0.85
    v.co.z *= 1.10
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
hq = create_mesh("crash_daemon_hindquarters", bm, (0, 0.55, 0.85), mat_charred)
mod = hq.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1
mod.render_levels = 2

# === SHOULDERS — small bulk for the front legs ===
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=10, radius=0.22)
for v in bm.verts:
    v.co.y *= 0.85
    v.co.z *= 0.85
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
shoulders = create_mesh("crash_daemon_shoulders", bm, (0, -0.45, 0.55), mat_charred)

# === HEAD — wide flat skull ===
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=22, v_segments=12, radius=0.22)
for v in bm.verts:
    v.co.x *= 1.10  # wide
    v.co.y *= 1.20
    v.co.z *= 0.55  # flat
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
head = create_mesh("crash_daemon_head", bm, (0, -0.78, 0.45), mat_charred)
mod = head.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1

# === EYE SLIT — single horizontal LED ===
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.18  # wide
    v.co.y *= 0.025
    v.co.z *= 0.018
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("crash_daemon_eye_slit", bm, (0, -0.96, 0.48), mat_eye)


# === LEGS ===
# Front legs: shorter, thinner. Rear legs: longer, beefier (the coiled spring).
def make_leg(name, base_pos, length_thigh, length_shin, length_paw, thigh_angle, shin_angle, mirror=1):
    """Build a 3-segment leg (thigh + shin + paw)."""
    pos = Vector(base_pos)
    # Thigh
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.085, radius2=0.065,
                          depth=length_thigh, cap_ends=True)
    direction = Vector((mirror * 0.12, 0.05, -1.0)).normalized()
    rotate_to_dir(bm, direction)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"{name}_thigh", bm, tuple(pos + direction * (length_thigh * 0.5)), mat_metal)
    pos += direction * length_thigh
    # Shin
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.06, radius2=0.05,
                          depth=length_shin, cap_ends=True)
    direction = Vector((mirror * 0.05, -0.10, -1.0)).normalized()
    rotate_to_dir(bm, direction)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"{name}_shin", bm, tuple(pos + direction * (length_shin * 0.5)), mat_metal)
    pos += direction * length_shin
    # Paw / claw — small segment angled forward
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.05, radius2=0.025,
                          depth=length_paw, cap_ends=True)
    direction = Vector((0, -0.6, -0.5)).normalized()
    rotate_to_dir(bm, direction)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"{name}_paw", bm, tuple(pos + direction * (length_paw * 0.5)), mat_metal)


# Front legs (shorter)
make_leg("front_R", ( 0.20, -0.45, 0.55), 0.30, 0.30, 0.10, 0, 0,  1)
make_leg("front_L", (-0.20, -0.45, 0.55), 0.30, 0.30, 0.10, 0, 0, -1)
# Rear legs (longer + thicker — the coiled spring)
make_leg("rear_R",  ( 0.22,  0.55, 0.85), 0.45, 0.45, 0.12, 0, 0,  1)
make_leg("rear_L",  (-0.22,  0.55, 0.85), 0.45, 0.45, 0.12, 0, 0, -1)


# === ENGINE VENTS along the spine ===
# 4 vents glowing orange, one between shoulders+hindquarters
for i, y_pos in enumerate([-0.20, 0.05, 0.30, 0.55]):
    z = 0.60 + i * 0.07  # slope up toward hindquarters
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.10
        v.co.y *= 0.05
        v.co.z *= 0.04
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"crash_daemon_vent_{i+1}", bm, (0, y_pos, z), mat_engine)


# === TAIL — short stub ===
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=10, radius1=0.10, radius2=0.025, depth=0.30, cap_ends=True)
# Rotate so it points back+up
direction = Vector((0, 0.7, 0.7)).normalized()
rotate_to_dir(bm, direction)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("crash_daemon_tail", bm, (0, 0.85, 0.95), mat_metal)


# === BUILD JOINED LOD0 + UV UNWRAP + BAKE ===
# Reuse the boss pipeline pattern
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


def build_joined_lod(name, source_objs, target_tris):
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    duplicates = []
    for obj in source_objs:
        if obj.name.startswith("CrashDaemon_") or obj.name.endswith("_LOD0"):
            continue
        new_obj = obj.copy()
        new_obj.data = obj.data.copy()
        new_obj.name = obj.name + "_lod_src"
        new_obj.parent = None
        new_obj.matrix_world = obj.matrix_world.copy()
        bpy.context.scene.collection.objects.link(new_obj)
        duplicates.append(new_obj)
    for obj in duplicates:
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                obj.modifiers.remove(mod)
    if not duplicates:
        return None
    bpy.ops.object.select_all(action='DESELECT')
    for obj in duplicates:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = duplicates[0]
    bpy.ops.object.join()
    joined = bpy.context.view_layer.objects.active
    joined.name = name
    bm = bmesh.new()
    bm.from_mesh(joined.data)
    bmesh.ops.triangulate(bm, faces=bm.faces)
    pre = len(bm.faces)
    bm.to_mesh(joined.data)
    bm.free()
    if pre > target_tris:
        ratio = target_tris / pre
        mod = joined.modifiers.new("Decimate", 'DECIMATE')
        mod.decimate_type = 'COLLAPSE'
        mod.ratio = ratio
        mod.use_collapse_triangulate = True
        bpy.context.view_layer.objects.active = joined
        bpy.ops.object.modifier_apply(modifier="Decimate")
    bm = bmesh.new()
    bm.from_mesh(joined.data)
    print(f"  {name}: {len(bm.faces)} polys")
    bm.free()
    return joined


lod0 = build_joined_lod("CrashDaemon_LOD0", collect_visible_meshes(), 2000)
lod0.hide_set(True)
lod0.hide_render = True

# UV unwrap
bpy.ops.object.select_all(action='DESELECT')
lod0.hide_set(False)
lod0.select_set(True)
bpy.context.view_layer.objects.active = lod0
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02, area_weight=0.0,
                         correct_aspect=True, scale_to_bounds=False)
bpy.ops.uv.pack_islands(margin=0.012, scale=True)
bpy.ops.object.mode_set(mode='OBJECT')
print(f"  CrashDaemon_LOD0 UVs: {len(lod0.data.uv_layers.active.uv)}")
lod0.hide_set(True)


# === BUILD HIGH-POLY + BAKE 4 MAPS ===
def build_high_poly(name, source_objs):
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    duplicates = []
    for obj in source_objs:
        if obj.name.startswith("CrashDaemon_"):
            continue
        new_obj = obj.copy()
        new_obj.data = obj.data.copy()
        new_obj.name = obj.name + "_hp_src"
        new_obj.parent = None
        new_obj.matrix_world = obj.matrix_world.copy()
        bpy.context.scene.collection.objects.link(new_obj)
        duplicates.append(new_obj)
    for obj in duplicates:
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                obj.modifiers.remove(mod)
        # Add subsurf for hp
        ss = obj.modifiers.new("HP_Subsurf", 'SUBSURF')
        ss.levels = 2
        try:
            bpy.ops.object.modifier_apply(modifier="HP_Subsurf")
        except RuntimeError:
            obj.modifiers.remove(ss)
    if not duplicates:
        return None
    bpy.ops.object.select_all(action='DESELECT')
    for obj in duplicates:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = duplicates[0]
    bpy.ops.object.join()
    hp = bpy.context.view_layer.objects.active
    hp.name = name
    return hp


hp = build_high_poly("CrashDaemon_HP", collect_visible_meshes())

# Setup Cycles
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.cycles.device = 'CPU'

W, H = 1024, 1024


def make_bake_image(name, color, is_data):
    img = bpy.data.images.get(name)
    if img is None:
        img = bpy.data.images.new(name, W, H, alpha=False, float_buffer=False)
    img.generated_color = color
    img.colorspace_settings.name = 'Non-Color' if is_data else 'sRGB'
    return img


def setup_bake_target_mat(image):
    name = "Daemon_BakeTarget"
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.select = True
    nt.nodes.active = tex
    nt.links.new(bsdf.outputs[0], out.inputs[0])
    return mat


def setup_curvature_mat(image):
    name = "Daemon_CurvBake"
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    geom = nt.nodes.new("ShaderNodeNewGeometry")
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].position = 0.40
    ramp.color_ramp.elements[1].position = 0.60
    em = nt.nodes.new("ShaderNodeEmission")
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.select = True
    nt.nodes.active = tex
    nt.links.new(geom.outputs["Pointiness"], ramp.inputs[0])
    nt.links.new(ramp.outputs[0], em.inputs[0])
    nt.links.new(em.outputs[0], out.inputs[0])
    return mat


# Save LOD0 mats then collapse to single bake target
saved_mats = [m for m in lod0.data.materials]
while len(lod0.data.materials) > 1:
    lod0.data.materials.pop(index=1)
for poly in lod0.data.polygons:
    poly.material_index = 0

img_normal = make_bake_image("crash_daemon_normal",   (0.5, 0.5, 1.0, 1.0), True)
img_ao     = make_bake_image("crash_daemon_ao",       (1.0, 1.0, 1.0, 1.0), False)
img_cavity = make_bake_image("crash_daemon_cavity",   (1.0, 1.0, 1.0, 1.0), True)
img_curv   = make_bake_image("crash_daemon_curvature",(0.5, 0.5, 0.5, 1.0), True)


def bake(image, bake_type, ray_dist=0.10, custom_mat_for_hp=None):
    if custom_mat_for_hp is not None:
        while len(hp.data.materials) > 1:
            hp.data.materials.pop(index=1)
        if hp.data.materials:
            hp.data.materials[0] = custom_mat_for_hp
        else:
            hp.data.materials.append(custom_mat_for_hp)
        for poly in hp.data.polygons:
            poly.material_index = 0
    target = setup_bake_target_mat(image)
    if lod0.data.materials:
        lod0.data.materials[0] = target
    else:
        lod0.data.materials.append(target)
    bpy.ops.object.select_all(action='DESELECT')
    lod0.hide_set(False)
    lod0.hide_render = False
    hp.hide_set(False)
    hp.hide_render = False
    hp.select_set(True)
    lod0.select_set(True)
    bpy.context.view_layer.objects.active = lod0
    scene.cycles.bake_type = bake_type
    scene.render.bake.use_selected_to_active = True
    scene.render.bake.cage_extrusion = 0.05
    scene.render.bake.max_ray_distance = ray_dist
    scene.render.bake.margin = 8
    if bake_type == 'NORMAL':
        scene.render.bake.normal_space = 'TANGENT'
    bpy.ops.object.bake(type=bake_type)
    image.save_render(filepath=os.path.join(TEX_DIR, image.name + ".png"))
    print(f"  Saved {image.name}.png")


bake(img_normal, 'NORMAL', 0.10)
bake(img_ao,     'AO',     0.10)
bake(img_cavity, 'AO',     0.020)
bake(img_curv,   'EMIT',   0.10, custom_mat_for_hp=setup_curvature_mat(img_curv))

# Restore LOD0 mats
lod0.data.materials.clear()
for m in saved_mats:
    if m is not None:
        lod0.data.materials.append(m)
hp.hide_set(True)
hp.hide_render = True
lod0.hide_set(True)
lod0.hide_render = True


# === PROCEDURAL ALBEDO ===
import numpy as np
ao_arr = np.array(img_ao.pixels[:], dtype=np.float32).reshape(H, W, 4)[:, :, 0]
curv_arr = np.array(img_curv.pixels[:], dtype=np.float32).reshape(H, W, 4)[:, :, 0]
cav_arr = np.array(img_cavity.pixels[:], dtype=np.float32).reshape(H, W, 4)[:, :, 0]

y = np.linspace(0, 1, H, dtype=np.float32)[:, None]
x = np.linspace(0, 1, W, dtype=np.float32)[None, :]

def hash_noise(xv, yv, freq):
    nx = np.floor(xv * freq).astype(np.int32)
    ny = np.floor(yv * freq).astype(np.int32)
    h = (nx * 374761393 + ny * 668265263) & 0x7fffffff
    h = (h ^ (h >> 13)) * 1274126177
    return ((h & 0x7fffffff) / 0x7fffffff).astype(np.float32)

cell_noise = hash_noise(x, y, 32.0)
fine_noise = hash_noise(x * 1.4, y * 0.85, 95.0)

# Charred base — dark with slight variation
out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.025
out[:, :, 1] = 0.020
out[:, :, 2] = 0.020
out[:, :, 3] = 1.0
# Variation
out[:, :, :3] *= (0.85 + 0.30 * cell_noise[:, :, None])
# AO multiply
out[:, :, :3] *= (0.55 + 0.45 * ao_arr[:, :, None])
# Crimson cracks via curvature concave detection (curv < 0.45)
crack_mask = np.clip((0.45 - curv_arr) / 0.20, 0.0, 1.0) ** 1.4
crack_color = np.array([0.85, 0.05, 0.02], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - crack_mask * 0.85) + crack_color[c] * (crack_mask * 0.85)
# Edge highlight via curvature convex (curv > 0.55)
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.6
edge_color = np.array([0.18, 0.16, 0.16], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.55) + edge_color[c] * (edge_mask * 0.55)
# Sparse hot spot specks via fine noise
spec_mask = (fine_noise > 0.97).astype(np.float32) * 0.6
out[:, :, 0] += spec_mask * 0.6
out[:, :, 1] += spec_mask * 0.20
out[:, :, 2] += spec_mask * 0.05
out = np.clip(out, 0.0, 1.0)

img_albedo = bpy.data.images.new("crash_daemon_albedo", W, H, alpha=False, float_buffer=False)
img_albedo.colorspace_settings.name = 'sRGB'
img_albedo.pixels = out.flatten().tolist()
img_albedo.filepath_raw = os.path.join(TEX_DIR, "crash_daemon_albedo.png")
img_albedo.file_format = 'PNG'
img_albedo.save()
print(f"  Saved crash_daemon_albedo.png")


# === RIG ===
arm_data = bpy.data.armatures.new("CrashDaemon_Armature")
arm_obj = bpy.data.objects.new("Armature_CrashDaemon", arm_data)
bpy.context.scene.collection.objects.link(arm_obj)
arm_obj.show_in_front = True
bpy.context.view_layer.objects.active = arm_obj
bpy.ops.object.mode_set(mode='EDIT')
eb = arm_data.edit_bones


def add_bone(name, head, tail, parent=None, connect=False):
    b = eb.new(name)
    b.head = Vector(head)
    b.tail = Vector(tail)
    if parent is not None:
        b.parent = parent
        b.use_connect = connect
    return b


# 12-bone quadruped rig
root_bone = add_bone("root", (0, 0, 0), (0, 0, 0.20))                    # 1
spine = add_bone("spine", (0, 0.10, 0.55), (0, 0.55, 0.85), root_bone)   # 2 — slopes up to hindquarters
neck = add_bone("neck", (0, -0.45, 0.55), (0, -0.78, 0.50), spine)       # 3
head_b = add_bone("head", (0, -0.78, 0.50), (0, -0.96, 0.48), neck, True)  # 4
# Front legs (2 segments each)
front_R_t = add_bone("front_thigh_R", ( 0.20, -0.45, 0.55), ( 0.22, -0.40, 0.25), spine)  # 5
front_R_s = add_bone("front_shin_R",  ( 0.22, -0.40, 0.25), ( 0.22, -0.50, 0.0), front_R_t, True)  # 6
front_L_t = add_bone("front_thigh_L", (-0.20, -0.45, 0.55), (-0.22, -0.40, 0.25), spine)  # 7
front_L_s = add_bone("front_shin_L",  (-0.22, -0.40, 0.25), (-0.22, -0.50, 0.0), front_L_t, True)  # 8
# Rear legs (2 segments each, longer)
rear_R_t = add_bone("rear_thigh_R", ( 0.22, 0.55, 0.85), ( 0.24, 0.60, 0.40), spine)  # 9
rear_R_s = add_bone("rear_shin_R",  ( 0.24, 0.60, 0.40), ( 0.24, 0.50, 0.0), rear_R_t, True)  # 10
rear_L_t = add_bone("rear_thigh_L", (-0.22, 0.55, 0.85), (-0.24, 0.60, 0.40), spine)  # 11
rear_L_s = add_bone("rear_shin_L",  (-0.24, 0.60, 0.40), (-0.24, 0.50, 0.0), rear_L_t, True)  # 12

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  CrashDaemon rig: {len(arm_data.bones)} bones")

# Bind LOD0 with envelope skinning
lod0.hide_set(False)
saved_mw = lod0.matrix_world.copy()
lod0.parent = arm_obj
lod0.matrix_world = saved_mw
mod = lod0.modifiers.new("Armature", 'ARMATURE')
mod.object = arm_obj
mod.use_bone_envelopes = True
mod.use_vertex_groups = False

# Generous envelopes
for bone in arm_data.bones:
    bone.envelope_distance = 0.45
    bone.head_radius = 0.20
    bone.tail_radius = 0.20

# Tighter eyeslit area (head bone)
head_bone = arm_data.bones.get("head")
if head_bone:
    head_bone.envelope_distance = 0.30


# === ANIMATIONS ===
arm_obj.animation_data_create()
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


# === 1. crash_daemon_idle (60-frame loop) ===
act = new_action("crash_daemon_idle")
arm_obj.animation_data.action = act
total = 60
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    breath = 1.5 * math.sin(t)  # subtle body bob
    loc("root", (0, 0, 0.012 * math.sin(t)), f)
    rot("spine", (1.0 * math.sin(t * 0.5), 0, 0), f)
    rot("head", (2.0 * math.sin(t * 0.7), 0, 3.0 * math.sin(t * 0.3)), f)
act.use_fake_user = True


# === 2. crash_daemon_coil_windup (12 frames — the dodge tell) ===
act = new_action("crash_daemon_coil_windup")
arm_obj.animation_data.action = act
# Frame 0: neutral
loc("root", (0, 0, 0), 0)
rot("spine", (0, 0, 0), 0)
rot("head", (0, 0, 0), 0)
# Frame 6: lean back, raise hindquarters higher (coiled spring)
loc("root", (0, 0.10, 0.05), 6)
rot("spine", (-12, 0, 0), 6)  # lean back
rot("head", (-15, 0, 0), 6)
rot("rear_thigh_R", (35, 0, 0), 6)  # crouch hindquarters
rot("rear_thigh_L", (35, 0, 0), 6)
rot("rear_shin_R",  (-25, 0, 0), 6)
rot("rear_shin_L",  (-25, 0, 0), 6)
rot("front_thigh_R", (-15, 0, 0), 6)  # straighten front legs
rot("front_thigh_L", (-15, 0, 0), 6)
# Frame 12: hold the coil
loc("root", (0, 0.10, 0.05), 12)
rot("spine", (-12, 0, 0), 12)
rot("rear_thigh_R", (35, 0, 0), 12)
rot("rear_thigh_L", (35, 0, 0), 12)
act.use_fake_user = True


# === 3. crash_daemon_dash (16-frame burst) ===
act = new_action("crash_daemon_dash")
arm_obj.animation_data.action = act
# Frame 0: end of coil
loc("root", (0, 0.10, 0.05), 0)
rot("spine", (-12, 0, 0), 0)
# Frame 4: launch — body extends + hindquarters fire
loc("root", (0, -0.10, 0.10), 4)
rot("spine", (5, 0, 0), 4)
rot("head", (-3, 0, 0), 4)
rot("rear_thigh_R", (-30, 0, 0), 4)
rot("rear_thigh_L", (-30, 0, 0), 4)
rot("rear_shin_R",  (15, 0, 0), 4)
rot("rear_shin_L",  (15, 0, 0), 4)
rot("front_thigh_R", (40, 0, 0), 4)  # front legs swing forward
rot("front_thigh_L", (40, 0, 0), 4)
# Frames 4-12: dash forward, body stretched
for fi in range(2):
    f = 6 + fi * 3
    loc("root", (0, -0.10 - 0.05 * fi, 0.08), f)
    rot("spine", (5, 0, 0), f)
# Frame 16: contact pose (body straight, legs extended)
loc("root", (0, -0.20, 0.05), 16)
rot("spine", (8, 0, 0), 16)
rot("rear_thigh_R", (-15, 0, 0), 16)
rot("rear_thigh_L", (-15, 0, 0), 16)
rot("front_thigh_R", (45, 0, 0), 16)
rot("front_thigh_L", (45, 0, 0), 16)
act.use_fake_user = True


# === 4. crash_daemon_skid_recover (30 frames — the punish window) ===
act = new_action("crash_daemon_skid_recover")
arm_obj.animation_data.action = act
# Frame 0: post-dash skid
loc("root", (0, -0.20, 0.05), 0)
rot("spine", (8, 0, 0), 0)
# Frames 0-12: skid backward (legs splay, body wobbles)
loc("root", (0, -0.15, 0.02), 12)
rot("spine", (10, 2, 0), 12)
rot("front_thigh_R", (50, 0, 10), 12)
rot("front_thigh_L", (50, 0, -10), 12)
rot("rear_thigh_R", (-10, 0, 5), 12)
rot("rear_thigh_L", (-10, 0, -5), 12)
# Frames 12-22: shake off
loc("root", (0, -0.05, 0.0), 22)
rot("spine", (3, -1, 0), 22)
rot("head", (5, 0, 3), 22)
# Frames 22-30: return to neutral
loc("root", (0, 0, 0), 30)
rot("spine", (0, 0, 0), 30)
rot("head", (0, 0, 0), 30)
rot("front_thigh_R", (0, 0, 0), 30)
rot("front_thigh_L", (0, 0, 0), 30)
rot("rear_thigh_R", (0, 0, 0), 30)
rot("rear_thigh_L", (0, 0, 0), 30)
act.use_fake_user = True


# === 5. crash_daemon_hit_react (12 frames) ===
act = new_action("crash_daemon_hit_react")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
rot("spine", (0, 0, 0), 0)
loc("root", (0, 0.06, 0.03), 3)
rot("spine", (-10, -3, 0), 3)
rot("head", (-12, 4, 0), 3)
loc("root", (0, -0.02, 0.01), 7)
rot("spine", (3, 1, 0), 7)
loc("root", (0, 0, 0), 12)
rot("spine", (0, 0, 0), 12)
rot("head", (0, 0, 0), 12)
act.use_fake_user = True


# === 6. crash_daemon_death (40 frames — engines blow + collapse) ===
act = new_action("crash_daemon_death")
arm_obj.animation_data.action = act
# Frame 0: alive
loc("root", (0, 0, 0), 0)
rot("spine", (0, 0, 0), 0)
# Frame 4: violent jolt as engines overload
loc("root", (0, 0, 0.08), 4)
rot("spine", (-15, 5, 0), 4)
rot("head", (-20, 0, 0), 4)
# Frame 12: body slams down
loc("root", (0, 0, -0.15), 12)
rot("spine", (15, 0, 0), 12)
rot("head", (25, 0, 0), 12)
rot("front_thigh_R", (45, 0, 15), 12)
rot("front_thigh_L", (45, 0, -15), 12)
rot("rear_thigh_R", (15, 0, 0), 12)
rot("rear_thigh_L", (15, 0, 0), 12)
# Frame 25: legs splay out
rot("front_thigh_R", (50, 0, 25), 25)
rot("front_thigh_L", (50, 0, -25), 25)
rot("rear_thigh_R", (15, 0, 15), 25)
rot("rear_thigh_L", (15, 0, -15), 25)
# Frame 40: final settle
loc("root", (0, 0, -0.20), 40)
rot("spine", (12, 0, 0), 40)
rot("head", (30, 0, 3), 40)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("crash_daemon_")])
print(f"  CrashDaemon animations: {anim_count}")

# Save the file
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("Crash Daemon full pipeline complete")
