"""Epic 08 task 5 — Null Pointer full pipeline (sculpt + texture + rig + animate).

Per the bible: 1.6m humanoid teleport sniper. Body parts fade in and out
50% visible at any moment. Pure void black with cyan rim. 0.2s cyan flash
telegraph at destination.

Geometry approach:
- Standard humanoid silhouette with VISIBLE GAPS in the body (modeled as
  separate floating chunks at non-contiguous positions)
- Segmented body so the runtime shader can selectively fade individual
  chunks for the "fading in and out" tell

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_task05_null_pointer_pipeline.py
"""
import bpy
import bmesh
import os
import math
from mathutils import Vector, Matrix, Euler

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_null_pointer.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/enemies"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


def make_pbr(name, base_color, metallic=0.0, roughness=0.30,
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


mat_void  = make_pbr("Null_Void",     (0.005, 0.005, 0.010), 0.10, 0.50)
mat_rim   = make_pbr("Null_RimGlow",  (0.02,  0.20,  0.30 ), 0.10, 0.20, (0.0, 0.85, 1.0), 5.0)
mat_eye   = make_pbr("Null_Eye",      (0.0,   0.20,  0.30 ), 0.0,  0.05, (0.0, 0.95, 1.0), 10.0)

root = bpy.data.objects.new("NullPointer_Root", None)
bpy.context.scene.collection.objects.link(root)


def create_mesh(name, bm, location, material):
    me = bpy.data.meshes.new(name + "_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    obj.location = location
    obj.data.materials.append(material)
    bpy.context.scene.collection.objects.link(obj)
    obj.parent = root
    for p in obj.data.polygons:
        p.use_smooth = True
    return obj


# === HUMANOID GEOMETRY (segmented for fade-in/out) ===
# 1.6m total, classic humanoid silhouette but the body is split into
# 12 chunks so the shader can fade individuals. The chunks are positioned
# correctly to read as a humanoid; the gaps between them ARE the silhouette.

# Chest plate
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=0.18)
for v in bm.verts:
    v.co.y *= 0.55
    v.co.z *= 0.85
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
chest = create_mesh("null_chest", bm, (0, 0, 1.10), mat_void)
mod = chest.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1

# Hips
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=10, radius=0.16)
for v in bm.verts:
    v.co.y *= 0.55
    v.co.z *= 0.65
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("null_hips", bm, (0, 0, 0.78), mat_void)

# Head — humanoid skull
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=0.13)
for v in bm.verts:
    v.co.y *= 0.95
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
head = create_mesh("null_head", bm, (0, 0, 1.45), mat_void)
mod = head.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1

# Eye — single cyan slit
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.025)
for v in bm.verts:
    v.co.y *= 0.4
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("null_eye", bm, (0, -0.12, 1.46), mat_eye)

# Shoulder plates
for sx, label in [( 1, "R"), (-1, "L")]:
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.10)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"null_shoulder_{label}", bm, (0.22 * sx, 0, 1.20), mat_void)

# Forearm chunks (gap between shoulder and forearm — visible "missing" upper arm)
for sx, label in [( 1, "R"), (-1, "L")]:
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.06, radius2=0.05, depth=0.30, cap_ends=True)
    rot = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"null_forearm_{label}", bm, (0.30 * sx, 0, 0.78), mat_void)

# Hand chunks
for sx, label in [( 1, "R"), (-1, "L")]:
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.06)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"null_hand_{label}", bm, (0.32 * sx, 0, 0.55), mat_void)

# Thigh chunks (mid-air, gap between hips and shins)
for sx, label in [( 1, "R"), (-1, "L")]:
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.075, radius2=0.065, depth=0.32, cap_ends=True)
    rot = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"null_thigh_{label}", bm, (0.10 * sx, 0, 0.55), mat_void)

# Foot chunks
for sx, label in [( 1, "R"), (-1, "L")]:
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.07)
    for v in bm.verts:
        v.co.y *= 1.4
        v.co.z *= 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"null_foot_{label}", bm, (0.10 * sx, -0.02, 0.05), mat_void)

# Add 3 RIM accent rings (cyan glow stripes that show even when chunks fade)
for i, z_pos in enumerate([1.10, 0.85, 0.55]):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=22, radius=0.18 - i * 0.02, cap_ends=False)
    rot = Matrix.Rotation(math.radians(90), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    # Extrude into a thin ring
    bm.faces.ensure_lookup_table()
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"null_rim_{i+1}", bm, (0, 0, z_pos), mat_rim)


# === BUILD JOINED LOD0 ===
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


def build_joined_lod(name, source_objs, target_tris):
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    duplicates = []
    for obj in source_objs:
        if obj.name.startswith("NullPointer_"):
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


lod0 = build_joined_lod("NullPointer_LOD0", collect_visible_meshes(), 2200)
lod0.hide_set(False)
bpy.ops.object.select_all(action='DESELECT')
lod0.select_set(True)
bpy.context.view_layer.objects.active = lod0
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
bpy.ops.uv.pack_islands(margin=0.012, scale=True)
bpy.ops.object.mode_set(mode='OBJECT')
print(f"  NullPointer_LOD0 UVs: {len(lod0.data.uv_layers.active.uv)}")
lod0.hide_set(True)


# === HP + BAKE ===
def build_high_poly(name, source_objs):
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    duplicates = []
    for obj in source_objs:
        if obj.name.startswith("NullPointer_"):
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


hp = build_high_poly("NullPointer_HP", collect_visible_meshes())

scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.cycles.device = 'CPU'

W, H = 1024, 1024


def make_bake_image(name, color, is_data):
    img = bpy.data.images.new(name, W, H, alpha=False, float_buffer=False)
    img.generated_color = color
    img.colorspace_settings.name = 'Non-Color' if is_data else 'sRGB'
    return img


def setup_bake_target_mat(image, mat_name="Null_BakeTarget"):
    mat = bpy.data.materials.get(mat_name)
    if mat is None:
        mat = bpy.data.materials.new(mat_name)
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
    mat = bpy.data.materials.new("Null_CurvBake")
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


saved_mats = [m for m in lod0.data.materials]
while len(lod0.data.materials) > 1:
    lod0.data.materials.pop(index=1)
for poly in lod0.data.polygons:
    poly.material_index = 0

img_normal = make_bake_image("null_pointer_normal",   (0.5, 0.5, 1.0, 1.0), True)
img_ao     = make_bake_image("null_pointer_ao",       (1.0, 1.0, 1.0, 1.0), False)
img_cavity = make_bake_image("null_pointer_cavity",   (1.0, 1.0, 1.0, 1.0), True)
img_curv   = make_bake_image("null_pointer_curvature",(0.5, 0.5, 0.5, 1.0), True)


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

lod0.data.materials.clear()
for m in saved_mats:
    if m is not None:
        lod0.data.materials.append(m)
hp.hide_set(True)
hp.hide_render = True
lod0.hide_set(True)
lod0.hide_render = True


# === ALBEDO ===
import numpy as np
ao_arr = np.array(img_ao.pixels[:], dtype=np.float32).reshape(H, W, 4)[:, :, 0]
curv_arr = np.array(img_curv.pixels[:], dtype=np.float32).reshape(H, W, 4)[:, :, 0]

out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.005
out[:, :, 1] = 0.005
out[:, :, 2] = 0.010
out[:, :, 3] = 1.0
# AO multiply
out[:, :, :3] *= (0.50 + 0.50 * ao_arr[:, :, None])
# Cyan rim glow on edges (curv > 0.55)
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.5
rim_color = np.array([0.0, 0.85, 1.0], dtype=np.float32)
for c in range(3):
    out[:, :, c] += rim_color[c] * edge_mask * 0.7
out = np.clip(out, 0.0, 1.0)

img_albedo = bpy.data.images.new("null_pointer_albedo", W, H, alpha=False)
img_albedo.colorspace_settings.name = 'sRGB'
img_albedo.pixels = out.flatten().tolist()
img_albedo.filepath_raw = os.path.join(TEX_DIR, "null_pointer_albedo.png")
img_albedo.file_format = 'PNG'
img_albedo.save()
print(f"  Saved null_pointer_albedo.png")


# === RIG (humanoid 14-bone) ===
arm_data = bpy.data.armatures.new("NullPointer_Armature")
arm_obj = bpy.data.objects.new("Armature_NullPointer", arm_data)
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


root_bone = add_bone("root", (0, 0, 0), (0, 0, 0.20))
hips = add_bone("hips", (0, 0, 0.78), (0, 0, 0.95), root_bone)
spine = add_bone("spine", (0, 0, 0.95), (0, 0, 1.20), hips, True)
chest_b = add_bone("chest", (0, 0, 1.20), (0, 0, 1.35), spine, True)
neck = add_bone("neck", (0, 0, 1.35), (0, 0, 1.45), chest_b, True)
head_b = add_bone("head", (0, 0, 1.45), (0, 0, 1.60), neck, True)
# Arms
shR = add_bone("shoulder_R", (0.10, 0, 1.30), (0.22, 0, 1.20), chest_b)
faR = add_bone("forearm_R",  (0.22, 0, 1.20), (0.32, 0, 0.65), shR)
shL = add_bone("shoulder_L", (-0.10, 0, 1.30), (-0.22, 0, 1.20), chest_b)
faL = add_bone("forearm_L",  (-0.22, 0, 1.20), (-0.32, 0, 0.65), shL)
# Legs
thR = add_bone("thigh_R", ( 0.10, 0, 0.78), ( 0.10, 0, 0.45), hips)
shinR = add_bone("shin_R", ( 0.10, 0, 0.45), ( 0.10, -0.02, 0.05), thR, True)
thL = add_bone("thigh_L", (-0.10, 0, 0.78), (-0.10, 0, 0.45), hips)
shinL = add_bone("shin_L", (-0.10, 0, 0.45), (-0.10, -0.02, 0.05), thL, True)

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  NullPointer rig: {len(arm_data.bones)} bones")

lod0.hide_set(False)
lod0.parent = arm_obj
mod = lod0.modifiers.new("Armature", 'ARMATURE')
mod.object = arm_obj
mod.use_bone_envelopes = True
mod.use_vertex_groups = False

for bone in arm_data.bones:
    bone.envelope_distance = 0.30
    bone.head_radius = 0.15
    bone.tail_radius = 0.15
head_b_data = arm_data.bones.get("head")
if head_b_data:
    head_b_data.envelope_distance = 0.18


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


def scl(bone, s, frame):
    pb = arm_obj.pose.bones.get(bone)
    if pb is None:
        return
    pb.scale = Vector(s)
    pb.keyframe_insert(data_path="scale", frame=frame)


# 1. null_pointer_idle (60-frame loop, eerie hover)
act = new_action("null_pointer_idle")
arm_obj.animation_data.action = act
total = 60
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    loc("root", (0, 0, 0.025 * math.sin(t)), f)
    rot("chest", (1.5 * math.sin(t * 0.5), 0, 0), f)
    rot("head", (0, 0, 4.0 * math.sin(t * 0.4)), f)
act.use_fake_user = True

# 2. null_pointer_teleport_out (8 frames — fade compress)
act = new_action("null_pointer_teleport_out")
arm_obj.animation_data.action = act
scl("root", (1, 1, 1), 0)
scl("root", (0.6, 1.4, 0.6), 4)
scl("root", (0.1, 0.2, 0.1), 8)
act.use_fake_user = True

# 3. null_pointer_teleport_in (8 frames — fade expand)
act = new_action("null_pointer_teleport_in")
arm_obj.animation_data.action = act
scl("root", (0.1, 0.2, 0.1), 0)
scl("root", (0.6, 1.4, 0.6), 4)
scl("root", (1, 1, 1), 8)
act.use_fake_user = True

# 4. null_pointer_charge_shot (45 frames — extends arm forward + holds aim)
act = new_action("null_pointer_charge_shot")
arm_obj.animation_data.action = act
rot("shoulder_R", (0, 0, 0), 0)
rot("forearm_R", (0, 0, 0), 0)
rot("chest", (0, 0, 0), 0)
# Frame 8: arm raises forward
rot("shoulder_R", (-90, 0, -25), 8)
rot("forearm_R", (-30, 0, 0), 8)
rot("chest", (-5, 0, 0), 8)
rot("head", (-3, 0, -10), 8)
# Frames 8-40: HOLD aim
rot("shoulder_R", (-90, 0, -25), 40)
rot("forearm_R", (-30, 0, 0), 40)
rot("chest", (-5, 0, 0), 40)
# Frame 45: settle
rot("shoulder_R", (0, 0, 0), 45)
rot("forearm_R", (0, 0, 0), 45)
rot("chest", (0, 0, 0), 45)
rot("head", (0, 0, 0), 45)
act.use_fake_user = True

# 5. null_pointer_fire (4 frames — sharp recoil)
act = new_action("null_pointer_fire")
arm_obj.animation_data.action = act
rot("shoulder_R", (-90, 0, -25), 0)
rot("forearm_R", (-30, 0, 0), 0)
rot("shoulder_R", (-50, 0, -40), 4)
rot("forearm_R", (-15, 0, 0), 4)
rot("chest", (-12, 0, 0), 4)
act.use_fake_user = True

# 6. null_pointer_hit_react (12 frames)
act = new_action("null_pointer_hit_react")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
loc("root", (0, 0.05, 0.02), 3)
rot("chest", (-10, 4, 0), 3)
rot("head", (-15, -3, 0), 3)
loc("root", (0, 0, 0), 12)
rot("chest", (0, 0, 0), 12)
rot("head", (0, 0, 0), 12)
act.use_fake_user = True

# 7. null_pointer_death (35 frames — implosion)
act = new_action("null_pointer_death")
arm_obj.animation_data.action = act
scl("root", (1, 1, 1), 0)
scl("root", (0.8, 0.8, 0.8), 8)
scl("root", (1.3, 1.3, 1.3), 14)  # bulge
scl("root", (0.05, 0.05, 0.05), 22)  # implode
loc("root", (0, 0, -0.20), 35)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("null_pointer_")])
print(f"  NullPointer animations: {anim_count}")

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("Null Pointer full pipeline complete")
