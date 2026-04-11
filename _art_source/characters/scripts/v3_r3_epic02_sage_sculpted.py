"""
Expansion V3 — ROUND 3 — Epic R3-02 — AI Sage Sculpted Hero
============================================================
Same 9-stage pipeline as R3-01: ONE asset, single-mesh sculpted base,
no parented primitives. This time the AI Sage with a robed silhouette,
hood with real opening cut, beard extruded from the face, baked SSS
skin texture, 10-bone rig, cast-spell animation loop.

  1. Single-mesh body from a UV sphere — bmesh deformed into a robed
     pyramid (wide skirt → narrow head). Eye sockets, mouth, nose all
     inset directly into the geometry.
  2. Hood opening cut: select the front face of the head + inset to
     create a real cowl rim
  3. Beard extruded from the chin face (bmesh extrude_face_region) —
     real geometry, not separate cones
  4. Sculpt-style displacement on robe folds (proximity drag along
     vertical line)
  5. Multires + Z-gradient procedural shader (warm robe → tan skin)
  6. Bake to 1024² PNG image
  7. Retopo via Decimate 0.20
  8. 10-bone armature: root, spine_lower, spine_upper, head, arm_l,
     arm_r, forearm_l, forearm_r, leg_l, leg_r
  9. Cast-spell animation: 60 frames, arms raise overhead, robe sway,
     head tilt up at the spell apex

Outputs: hi-poly + low-poly + compare renders, 4 anim frames, baked
PNG, GLB w/ rig+animation.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(302)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_r3_sage.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/renders"
TEX_DIR      = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/baked"
ANIM_DIR     = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/anims"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/exports"
for d in [RENDER_DIR, TEX_DIR, ANIM_DIR, EXPORT_DIR]:
    os.makedirs(d, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 128
scene.cycles.use_denoising = True
scene.cycles.device = 'CPU'
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3r3_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.05, 0.04, 0.06, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# STAGE 1 — SINGLE-MESH SAGE BODY VIA BMESH SCULPT
# ============================================================
print("=== STAGE 1: Sage single-mesh base ===")

bpy.ops.mesh.primitive_uv_sphere_add(segments=64, ring_count=32, radius=1.0, location=(0, 0, 1.4))
hero = bpy.context.object
hero.name = "sage_hero_hp"

bm = bmesh.new()
bm.from_mesh(hero.data)

# Sage silhouette: tall, narrower at top, wider robe at bottom
for v in bm.verts:
    z_norm = (v.co.z + 1.0) / 2.0  # 0 bottom, 1 top
    # Robe pyramid widening at bottom
    width_factor = 1.0 + (1.0 - z_norm) * 0.8
    v.co.x *= width_factor
    v.co.y *= width_factor
    # Stretch vertically
    v.co.z *= 1.4

# Helper to find face nearest a target point
def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Inset eye sockets ===
print("Insetting sage face features...")
eye_l_face = closest_face(bm, Vector((-0.18, 0.85, 0.85)))
eye_r_face = closest_face(bm, Vector((0.18, 0.85, 0.85)))
if eye_l_face:
    res = bmesh.ops.inset_individual(bm, faces=[eye_l_face], thickness=0.08, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else eye_l_face
    for v in new_f.verts:
        v.co += Vector((0, -0.06, 0))
if eye_r_face:
    res = bmesh.ops.inset_individual(bm, faces=[eye_r_face], thickness=0.08, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else eye_r_face
    for v in new_f.verts:
        v.co += Vector((0, -0.06, 0))

# === Inset mouth slit (small, hidden under beard) ===
mouth_face = closest_face(bm, Vector((0, 0.92, 0.55)))
if mouth_face:
    res = bmesh.ops.inset_individual(bm, faces=[mouth_face], thickness=0.04, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else mouth_face
    for v in new_f.verts:
        v.co += Vector((0, -0.03, 0))
        v.co.x *= 1.6
        v.co.z *= 0.5

# === Inset nose bump ===
nose_face = closest_face(bm, Vector((0, 0.96, 0.70)))
if nose_face:
    res = bmesh.ops.inset_individual(bm, faces=[nose_face], thickness=0.04, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else nose_face
    for v in new_f.verts:
        v.co += Vector((0, 0.05, 0))

# === Inset hood opening cut (back of head) ===
print("Cutting hood opening...")
hood_face = closest_face(bm, Vector((0, -0.95, 1.10)))
if hood_face:
    res = bmesh.ops.inset_individual(bm, faces=[hood_face], thickness=0.20, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else hood_face
    for v in new_f.verts:
        v.co += Vector((0, -0.10, 0))  # extrude back

# === Beard region: select faces below mouth and extrude forward into beard ===
print("Building beard...")
# Find the chin region — face nearest (0, 0.85, 0.30)
chin_face = closest_face(bm, Vector((0, 0.88, 0.30)))
if chin_face:
    # Extrude this face forward into a beard cone
    geom = bmesh.ops.extrude_face_region(bm, geom=[chin_face])
    new_geom = geom['geom']
    new_verts = [g for g in new_geom if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co += Vector((0, 0.18, -0.20))  # forward and down
        v.co.x *= 1.4
    # Second extrude for tip
    new_faces = [g for g in new_geom if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
        new_geom2 = geom2['geom']
        for v in [g for g in new_geom2 if isinstance(g, bmesh.types.BMVert)]:
            v.co += Vector((0, 0.10, -0.18))
            v.co.x *= 0.5

# === Sculpt-style robe folds (vertical proximity falloff) ===
print("Sculpting robe folds...")
fold_centers = [
    (Vector((-0.6, 0.8, -0.4)), 0.4, -0.05),  # left front fold
    (Vector((0.6, 0.8, -0.4)),  0.4, -0.05),  # right front fold
    (Vector((-0.4, 0.85, -0.8)), 0.3, -0.04),
    (Vector((0.4, 0.85, -0.8)),  0.3, -0.04),
    (Vector((0.0, 0.95, -0.6)), 0.4, 0.05),   # forward bulge of robe front
]
for center, radius, strength in fold_centers:
    for v in bm.verts:
        d = (v.co - center).length
        if d < radius:
            falloff = 1.0 - (d / radius)
            falloff = falloff * falloff
            v.co += v.normal * (strength * falloff)

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = True

# Multires
print("Adding multires...")
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
for _ in range(2):
    bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 2 — UV UNWRAP
# ============================================================
print("=== STAGE 2: UV unwrap ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — PROCEDURAL SHADER (warm robe + tan skin gradient)
# ============================================================
print("=== STAGE 3: Procedural shader ===")

def make_shader(name):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.65
    bsdf.inputs["Subsurface Weight"].default_value = 0.25
    bsdf.inputs["Subsurface Radius"].default_value = (1.2, 0.5, 0.3)
    bsdf.inputs["Subsurface Scale"].default_value = 0.25
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Z gradient: blue robe at bottom, white beard mid, tan skin top
    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-700, 200)
    links.new(tc.outputs["Generated"], sep.inputs["Vector"])

    grad = nodes.new("ShaderNodeValToRGB"); grad.location = (-450, 200)
    grad.color_ramp.elements[0].position = 0.10
    grad.color_ramp.elements[0].color = (0.18, 0.30, 0.62, 1)  # deep blue robe
    e_mid = grad.color_ramp.elements.new(0.55)
    e_mid.color = (0.92, 0.88, 0.82, 1)  # white beard
    e_top = grad.color_ramp.elements.new(0.75)
    e_top.color = (0.85, 0.72, 0.55, 1)  # tan skin
    grad.color_ramp.elements[3].position = 0.95
    grad.color_ramp.elements[3].color = (0.30, 0.40, 0.78, 1)  # blue hood top
    links.new(sep.outputs["Z"], grad.inputs["Fac"])

    # Voronoi for fabric weave
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = 60.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    v_ramp = nodes.new("ShaderNodeValToRGB"); v_ramp.location = (-450, -100)
    v_ramp.color_ramp.elements[0].position = 0.05
    v_ramp.color_ramp.elements[0].color = (0.4, 0.3, 0.2, 1)
    v_ramp.color_ramp.elements[1].position = 0.30
    v_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])

    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 100)
    mix.inputs["Factor"].default_value = 0.30
    links.new(grad.outputs["Color"], mix.inputs[6])
    links.new(v_ramp.outputs["Color"], mix.inputs[7])

    # Curvature dirt
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-200, -300)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -300)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.10, 0.07, 0.04, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location = (300, 0)
    md.inputs["Factor"].default_value = 0.50
    links.new(mix.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    # Procedural normal bump
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, -500)
    n.inputs["Scale"].default_value = 25.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-450, -500)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_shader("v3r3_sage_proc")
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE PROCEDURAL TO IMAGE
# ============================================================
print("=== STAGE 4: Bake procedural to image ===")

bake_img = bpy.data.images.new("sage_albedo_bake", width=1024, height=1024)
img_node = mat_proc.node_tree.nodes.new("ShaderNodeTexImage")
img_node.location = (1100, 400)
img_node.image = bake_img
img_node.select = True
mat_proc.node_tree.nodes.active = img_node

scene.cycles.bake_type = 'DIFFUSE'
scene.render.bake.use_pass_direct = False
scene.render.bake.use_pass_indirect = False
scene.render.bake.use_pass_color = True
scene.cycles.samples = 32

bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero

print("Baking sage albedo (30-60s)...")
try:
    bpy.ops.object.bake(type='DIFFUSE')
    bake_path = os.path.join(TEX_DIR, "sage_albedo_1024.png")
    bake_img.filepath_raw = bake_path
    bake_img.file_format = 'PNG'
    bake_img.save()
    print(f"Baked: {bake_path}")
except Exception as e:
    print(f"Bake failed: {e}")

scene.cycles.samples = 128

# ============================================================
# STAGE 5 — RETOPO LOW-POLY
# ============================================================
print("=== STAGE 5: Retopo low-poly ===")

bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "sage_hero_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.20
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

low_poly.location = (3, 0, 1.4)

mat_lp = bpy.data.materials.new("v3r3_sage_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (800, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (500, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.65
bsdf_lp.inputs["Subsurface Weight"].default_value = 0.25
bsdf_lp.inputs["Subsurface Radius"].default_value = (1.2, 0.5, 0.3)
ntlp.links.new(bsdf_lp.outputs[0], out_lp.inputs[0])
img_node_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_node_lp.location = (200, 0)
img_node_lp.image = bake_img
ntlp.links.new(img_node_lp.outputs["Color"], bsdf_lp.inputs["Base Color"])

low_poly.data.materials.clear()
low_poly.data.materials.append(mat_lp)
print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — ARMATURE: 10-bone rig
# ============================================================
print("=== STAGE 6: Armature ===")

bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "sage_armature"
arm.show_in_front = True

bpy.ops.object.mode_set(mode='EDIT')
ed_bones = arm.data.edit_bones
ed_bones.remove(ed_bones["Bone"])

def add_bone(name, head, tail, parent=None):
    b = ed_bones.new(name)
    b.head = head
    b.tail = tail
    if parent:
        b.parent = parent
        b.use_connect = False
    return b

root = add_bone("root", Vector((0, 0, 0.0)), Vector((0, 0, 0.4)))
spine_lower = add_bone("spine_lower", Vector((0, 0, 0.4)), Vector((0, 0, 1.0)), parent=root)
spine_upper = add_bone("spine_upper", Vector((0, 0, 1.0)), Vector((0, 0, 1.6)), parent=spine_lower)
head_b = add_bone("head", Vector((0, 0, 1.6)), Vector((0, 0, 2.2)), parent=spine_upper)
arm_l = add_bone("arm_l", Vector((-0.7, 0, 1.5)), Vector((-1.0, 0, 1.0)), parent=spine_upper)
forearm_l = add_bone("forearm_l", Vector((-1.0, 0, 1.0)), Vector((-1.3, 0, 0.6)), parent=arm_l)
arm_r = add_bone("arm_r", Vector((0.7, 0, 1.5)), Vector((1.0, 0, 1.0)), parent=spine_upper)
forearm_r = add_bone("forearm_r", Vector((1.0, 0, 1.0)), Vector((1.3, 0, 0.6)), parent=arm_r)
leg_l = add_bone("leg_l", Vector((-0.4, 0, 0.4)), Vector((-0.5, 0, 0.0)), parent=root)
leg_r = add_bone("leg_r", Vector((0.4, 0, 0.4)), Vector((0.5, 0, 0.0)), parent=root)

bpy.ops.object.mode_set(mode='OBJECT')

print("Parenting w/ automatic weights...")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
try:
    bpy.ops.object.parent_set(type='ARMATURE_AUTO')
    print("Auto-weights succeeded")
except Exception as e:
    print(f"Auto-weights failed: {e}")
    bpy.ops.object.parent_set(type='ARMATURE')

# ============================================================
# STAGE 7 — CAST SPELL ANIMATION
# ============================================================
print("=== STAGE 7: Cast spell animation ===")

scene.frame_start = 1
scene.frame_end = 60
scene.render.fps = 30

bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

pb_head = arm.pose.bones["head"]
pb_arm_l = arm.pose.bones["arm_l"]
pb_arm_r = arm.pose.bones["arm_r"]
pb_forearm_l = arm.pose.bones["forearm_l"]
pb_forearm_r = arm.pose.bones["forearm_r"]
pb_spine_upper = arm.pose.bones["spine_upper"]

# Cast spell pose progression:
# f1: idle pose
# f15: arms beginning to raise, head tilting up
# f30: arms overhead at apex, head fully tilted up
# f45: arms holding overhead, slight forward push
# f60: return to idle
KEYS = [
    # frame, head_rx, arm_l_rx, arm_l_ry, arm_r_rx, arm_r_ry, fa_l_rx, fa_r_rx, spine_rx
    (1,  0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
    (15, -0.10, -0.50, -0.30, -0.50, 0.30, -0.40, -0.40, -0.05),
    (30, -0.20, -1.20, -0.50, -1.20, 0.50, -0.80, -0.80, -0.10),
    (45, -0.18, -1.30, -0.45, -1.30, 0.45, -0.70, -0.70, -0.08),
    (60, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
]

for frame, h_rx, al_rx, al_ry, ar_rx, ar_ry, fl_rx, fr_rx, sp_rx in KEYS:
    scene.frame_set(frame)
    pb_head.rotation_mode = 'XYZ'
    pb_head.rotation_euler = (h_rx, 0, 0)
    pb_head.keyframe_insert(data_path="rotation_euler", frame=frame)

    pb_arm_l.rotation_mode = 'XYZ'
    pb_arm_l.rotation_euler = (al_rx, al_ry, 0)
    pb_arm_l.keyframe_insert(data_path="rotation_euler", frame=frame)

    pb_arm_r.rotation_mode = 'XYZ'
    pb_arm_r.rotation_euler = (ar_rx, ar_ry, 0)
    pb_arm_r.keyframe_insert(data_path="rotation_euler", frame=frame)

    pb_forearm_l.rotation_mode = 'XYZ'
    pb_forearm_l.rotation_euler = (fl_rx, 0, 0)
    pb_forearm_l.keyframe_insert(data_path="rotation_euler", frame=frame)

    pb_forearm_r.rotation_mode = 'XYZ'
    pb_forearm_r.rotation_euler = (fr_rx, 0, 0)
    pb_forearm_r.keyframe_insert(data_path="rotation_euler", frame=frame)

    pb_spine_upper.rotation_mode = 'XYZ'
    pb_spine_upper.rotation_euler = (sp_rx, 0, 0)
    pb_spine_upper.keyframe_insert(data_path="rotation_euler", frame=frame)

bpy.ops.object.mode_set(mode='OBJECT')
print("Cast spell keyframes inserted")

# Bezier interpolation (Blender 5.x layered API w/ legacy fallback)
try:
    action = arm.animation_data.action if arm.animation_data else None
    if action:
        if hasattr(action, 'layers') and len(action.layers) > 0:
            for layer in action.layers:
                for strip in layer.strips:
                    for cb in strip.channelbags:
                        for fcurve in cb.fcurves:
                            for kp in fcurve.keyframe_points:
                                kp.interpolation = 'BEZIER'
        elif hasattr(action, 'fcurves'):
            for fcurve in action.fcurves:
                for kp in fcurve.keyframe_points:
                    kp.interpolation = 'BEZIER'
except Exception as e:
    print(f"Keyframe smoothing skipped: {e}")

# ============================================================
# STAGE 8 — LIGHTING + RENDERS
# ============================================================
print("=== STAGE 8: Lighting + Renders ===")

bpy.ops.object.light_add(type='AREA', location=(4, -5, 5))
key = bpy.context.object
key.data.energy = 1500; key.data.color = (1.0, 0.92, 0.78); key.data.size = 5
bpy.ops.object.light_add(type='AREA', location=(-4, 4, 4))
fill = bpy.context.object
fill.data.energy = 500; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 5
bpy.ops.object.light_add(type='AREA', location=(0, 5, 3))
rim = bpy.context.object
rim.data.energy = 700; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 4

bpy.ops.mesh.primitive_plane_add(size=10, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.10, 0.10, 0.12, 1)
fbsdf.inputs["Roughness"].default_value = 0.40
fl.data.materials.append(mat_fl)

def add_cam(name, loc, target, lens=70, dof=4.0, fstop=3.5):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((0, -5, 1.7)), Vector((0, 0, 1.4)), lens=70, dof=5)
cam_lp = add_cam("cam_lp", Vector((3, -5, 1.7)), Vector((3, 0, 1.4)), lens=70, dof=5)
cam_compare = add_cam("cam_compare", Vector((1.5, -7, 2.0)), Vector((1.5, 0, 1.4)), lens=50, dof=7)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Hi-poly hero render
scene.frame_set(1)
scene.camera = cam_hp
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_sage_hp_hero.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Low-poly w/ baked texture
scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_sage_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Side-by-side compare
scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_sage_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Cast-spell anim playblast frames
scene.camera = cam_hp
scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for f in [1, 15, 30, 45]:
    scene.frame_set(f)
    scene.render.filepath = os.path.join(ANIM_DIR, f"v3_r3_sage_cast_f{f:02d}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered anim frame: {scene.render.filepath}")

# ============================================================
# STAGE 9 — GLB EXPORT
# ============================================================
print("=== STAGE 9: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
arm.select_set(True)
bpy.context.view_layer.objects.active = arm

out_path = os.path.join(EXPORT_DIR, "sage_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_animations=True, export_skins=True,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-02 AI Sage Sculpted Hero complete ===")
