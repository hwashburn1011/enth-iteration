"""Epic 08 task 8 — Stack Overflow full pipeline.

Per the bible: 4.5m towering vertical stack of 6-8 cubes decreasing in
size, polished chrome with cyan LED edges, immobile rooted to base,
top cube color rotates per attack type. Cannot move.

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_task08_stack_overflow_pipeline.py
"""
import bpy
import bmesh
import os
import math
import numpy as np
from mathutils import Vector, Matrix, Euler

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_stack_overflow.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/enemies"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


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


mat_chrome    = make_pbr("Stack_Chrome",   (0.85, 0.86, 0.92), 1.0, 0.10)
mat_gunmetal  = make_pbr("Stack_Gunmetal", (0.05, 0.06, 0.10), 1.0, 0.32)
mat_led_cyan  = make_pbr("Stack_LED",      (0.02, 0.20, 0.25), 0.0, 0.10, (0.0, 0.95, 0.95), 6.0)
mat_top_cube  = make_pbr("Stack_TopCube",  (0.85, 0.86, 0.92), 1.0, 0.08, (0.0, 0.95, 0.95), 5.0)

root = bpy.data.objects.new("StackOverflow_Root", None)
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


# === GEOMETRY ===
# Stack of 7 cubes decreasing in size: 0.85 → 0.40m wide
# Plus a wide gunmetal base anchor
# Plus 4 LED accent strips per cube edge (4 cubes × 4 edges = 16 LEDs total
# but we'll do 1 LED ring per cube via a thin frame)

# Wide gunmetal base
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=1.20, radius2=1.10, depth=0.40, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("stack_base", bm, (0, 0, 0.20), mat_gunmetal)

# 7 cubes stacked decreasing in size
cube_count = 7
total_height = 4.10  # from base top z=0.40 to top of stack at z=4.50
current_z = 0.40
cube_widths = [0.85, 0.78, 0.70, 0.62, 0.55, 0.48, 0.40]
cube_heights = [0.62, 0.58, 0.55, 0.52, 0.50, 0.48, 0.45]
for i, (width, height) in enumerate(zip(cube_widths, cube_heights)):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= width
        v.co.y *= width
        v.co.z *= height
    # Bevel edges so the cube looks polished, not bare
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bmesh.ops.bevel(bm, geom=list(bm.edges) + list(bm.verts), offset=0.025, segments=2, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    cube_z = current_z + height * 0.5
    # Top cube uses the special tinted material so the AI can swap its color
    mat = mat_top_cube if i == cube_count - 1 else mat_chrome
    create_mesh(f"stack_cube_{i+1}", bm, (0, 0, cube_z), mat)
    # LED accent ring at the BOTTOM seam of each cube (where it meets the cube below)
    if i > 0:
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= width + 0.03
            v.co.y *= width + 0.03
            v.co.z *= 0.012
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"stack_led_ring_{i+1}", bm, (0, 0, current_z + 0.005), mat_led_cyan)
    current_z += height

# Top antenna cluster — 3 antennas on the top cube
top_z = current_z
for i, off_x in enumerate([0.0, 0.15, -0.15]):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.025, radius2=0.005, depth=0.18, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"stack_antenna_{i+1}", bm, (off_x, 0, top_z + 0.10), mat_chrome)

# 4 anchor brace cables at the base going outward (the "rooted to floor" tell)
for i, angle in enumerate([math.pi/4, 3*math.pi/4, 5*math.pi/4, 7*math.pi/4]):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.05, radius2=0.05, depth=1.5, cap_ends=True)
    direction = Vector((math.cos(angle) * 0.7, math.sin(angle) * 0.7, -1.0)).normalized()
    zdir = Vector((0, 0, 1))
    axis = zdir.cross(direction)
    if axis.length > 1e-5:
        rot_angle = math.acos(max(-1.0, min(1.0, zdir.dot(direction))))
        rot = Matrix.Rotation(rot_angle, 4, axis.normalized())
        for v in bm.verts:
            v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    base_pos = (math.cos(angle) * 1.05, math.sin(angle) * 1.05, 0.10)
    mid_pos = (base_pos[0] + direction.x * 0.6, base_pos[1] + direction.y * 0.6, base_pos[2] + direction.z * 0.6)
    create_mesh(f"stack_anchor_{i+1}", bm, mid_pos, mat_gunmetal)


# === BUILD JOINED LOD0 + UV + BAKE + ALBEDO + RIG + ANIMATIONS ===
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


def build_joined_lod(name, source_objs, target_tris):
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    duplicates = []
    for obj in source_objs:
        if obj.name.startswith("StackOverflow_"):
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


lod0 = build_joined_lod("StackOverflow_LOD0", collect_visible_meshes(), 2500)

# UV unwrap
lod0.hide_set(False)
bpy.ops.object.select_all(action='DESELECT')
lod0.select_set(True)
bpy.context.view_layer.objects.active = lod0
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
bpy.ops.uv.pack_islands(margin=0.012, scale=True)
bpy.ops.object.mode_set(mode='OBJECT')
print(f"  StackOverflow_LOD0 UVs: {len(lod0.data.uv_layers.active.uv)}")
lod0.hide_set(True)


# === HP + BAKE ===
def build_high_poly(name, source_objs):
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    duplicates = []
    for obj in source_objs:
        if obj.name.startswith("StackOverflow_"):
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


hp = build_high_poly("StackOverflow_HP", collect_visible_meshes())

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


def setup_bake_target_mat(image, mat_name="Stack_BakeTarget"):
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
    mat = bpy.data.materials.new("Stack_CurvBake")
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

img_normal = make_bake_image("stack_overflow_normal",   (0.5, 0.5, 1.0, 1.0), True)
img_ao     = make_bake_image("stack_overflow_ao",       (1.0, 1.0, 1.0, 1.0), False)
img_cavity = make_bake_image("stack_overflow_cavity",   (1.0, 1.0, 1.0, 1.0), True)
img_curv   = make_bake_image("stack_overflow_curvature",(0.5, 0.5, 0.5, 1.0), True)


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
ao_arr = np.array(img_ao.pixels[:], dtype=np.float32).reshape(H, W, 4)[:, :, 0]
curv_arr = np.array(img_curv.pixels[:], dtype=np.float32).reshape(H, W, 4)[:, :, 0]

# Polished chrome base — bright with subtle variation
out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.78
out[:, :, 1] = 0.80
out[:, :, 2] = 0.86
out[:, :, 3] = 1.0
# AO multiply
out[:, :, :3] *= (0.45 + 0.55 * ao_arr[:, :, None])
# Edge highlight on the bevels
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.4
edge_color = np.array([1.0, 1.0, 1.0], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.40) + edge_color[c] * (edge_mask * 0.40)
# Slight darkening in cavities
cav_mask = np.clip((0.45 - curv_arr) / 0.20, 0.0, 1.0) ** 1.2
out[:, :, :3] *= (1.0 - cav_mask[:, :, None] * 0.4)
out = np.clip(out, 0.0, 1.0)

img_albedo = bpy.data.images.new("stack_overflow_albedo", W, H, alpha=False)
img_albedo.colorspace_settings.name = 'sRGB'
img_albedo.pixels = out.flatten().tolist()
img_albedo.filepath_raw = os.path.join(TEX_DIR, "stack_overflow_albedo.png")
img_albedo.file_format = 'PNG'
img_albedo.save()
print(f"  Saved stack_overflow_albedo.png")


# === RIG (8 bones — minimal since it's mostly immobile) ===
arm_data = bpy.data.armatures.new("StackOverflow_Armature")
arm_obj = bpy.data.objects.new("Armature_StackOverflow", arm_data)
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


root_bone = add_bone("root", (0, 0, 0), (0, 0, 0.40))
# 7 cube bones — each cube is its own bone so the AI can drive subtle
# per-cube wobble during attacks
prev = root_bone
current_z = 0.40
for i, h in enumerate(cube_heights):
    cube_bone = add_bone(f"cube_{i+1}", (0, 0, current_z), (0, 0, current_z + h), prev, True)
    prev = cube_bone
    current_z += h

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  StackOverflow rig: {len(arm_data.bones)} bones")

lod0.hide_set(False)
lod0.parent = arm_obj
mod = lod0.modifiers.new("Armature", 'ARMATURE')
mod.object = arm_obj
mod.use_bone_envelopes = True
mod.use_vertex_groups = False

for bone in arm_data.bones:
    bone.envelope_distance = 0.50
    bone.head_radius = 0.30
    bone.tail_radius = 0.30


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


def scl(bone, s, frame):
    pb = arm_obj.pose.bones.get(bone)
    if pb is None:
        return
    pb.scale = Vector(s)
    pb.keyframe_insert(data_path="scale", frame=frame)


# 1. stack_overflow_idle (90-frame loop, ominous slow rotation per cube)
act = new_action("stack_overflow_idle")
arm_obj.animation_data.action = act
total = 90
for f in range(0, total + 1, 6):
    t = f / float(total) * math.tau
    for i in range(7):
        # Each cube rotates slightly out of phase
        phase = i * 0.6
        yaw = 1.5 * math.sin(t + phase)
        rot(f"cube_{i+1}", (0, 0, yaw), f)
act.use_fake_user = True

# 2. stack_overflow_telegraph (24-frame — top cube flares + cubes lean toward target)
act = new_action("stack_overflow_telegraph")
arm_obj.animation_data.action = act
# Frames 0-12: telegraph build — top cube grows + lean
scl("cube_7", (1, 1, 1), 0)
for i in range(7):
    rot(f"cube_{i+1}", (-3 * (i + 1) / 7, 0, 0), 12)
scl("cube_7", (1.15, 1.15, 1.15), 12)
# Frames 12-24: hold telegraph
scl("cube_7", (1.20, 1.20, 1.20), 24)
act.use_fake_user = True

# 3. stack_overflow_fire (16-frame — top cube fires downward)
act = new_action("stack_overflow_fire")
arm_obj.animation_data.action = act
# Frame 0: end of telegraph
scl("cube_7", (1.20, 1.20, 1.20), 0)
for i in range(7):
    rot(f"cube_{i+1}", (-3 * (i + 1) / 7, 0, 0), 0)
# Frame 4: violent shake at fire moment
scl("cube_7", (1.30, 1.30, 1.30), 4)
for i in range(7):
    rot(f"cube_{i+1}", (-5, 0, 5 * (i % 2 - 0.5) * 2), 4)
# Frame 16: settle
scl("cube_7", (1.0, 1.0, 1.0), 16)
for i in range(7):
    rot(f"cube_{i+1}", (0, 0, 0), 16)
act.use_fake_user = True

# 4. stack_overflow_hit_react (12-frame — wobble through the stack)
act = new_action("stack_overflow_hit_react")
arm_obj.animation_data.action = act
for i in range(7):
    rot(f"cube_{i+1}", (0, 0, 0), 0)
# Frame 4: wobble peak (bottom barely moves, top swings most)
for i in range(7):
    yaw = 4.0 * ((i + 1) / 7) * 1.2
    rot(f"cube_{i+1}", (0, 0, yaw), 4)
# Frame 8: counter-wobble
for i in range(7):
    yaw = -2.5 * ((i + 1) / 7)
    rot(f"cube_{i+1}", (0, 0, yaw), 8)
# Frame 12: settle
for i in range(7):
    rot(f"cube_{i+1}", (0, 0, 0), 12)
act.use_fake_user = True

# 5. stack_overflow_death (50-frame — collapse from top cube down)
act = new_action("stack_overflow_death")
arm_obj.animation_data.action = act
# Frame 0: alive
for i in range(7):
    rot(f"cube_{i+1}", (0, 0, 0), 0)
    scl(f"cube_{i+1}", (1, 1, 1), 0)
# Frames 0-15: top cube tilts and slips off
rot("cube_7", (15, 5, 0), 15)
scl("cube_7", (0.95, 0.95, 0.95), 15)
# Frames 15-30: cubes 6, 5, 4 each lean outward in different directions
rot("cube_6", (-12, 0, 8), 25)
rot("cube_5", (10, 0, -10), 30)
rot("cube_4", (-8, 0, 5), 35)
# Frames 30-45: lower cubes stay but slump
for i in [3, 2, 1]:
    rot(f"cube_{i}", (5, 0, (i - 2) * 4), 40)
# Frame 50: final settle — entire stack listing to one side
for i in range(7):
    final_lean = -5 - (i * 3)
    rot(f"cube_{i+1}", (final_lean, 0, 0), 50)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("stack_overflow_")])
print(f"  StackOverflow animations: {anim_count}")

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("Stack Overflow full pipeline complete")
