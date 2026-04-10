"""
Expansion V3 — ROUND 3 — Epic R3-05 — Memory Leak Sculpted
==========================================================
Amorphous ooze enemy. Same R3 pipeline but with slime-specific
features carved into a single mesh:

  - Single-mesh blob from a UV sphere with per-vertex noise displacement
    to create dripping uneven silhouette (no two slimes look the same)
  - Multiple eye sockets (3-5) carved via inset_individual at random
    positions on the upper hemisphere — eyes BULGE outward like the
    glitchbug, then have a deep iris recess
  - Drooling mouth: long horizontal slit on the front, plus dripping
    tendrils extruded from the bottom edge
  - Bottom-edge drips (4 of them) extruded downward, tip-collapsed
  - Multires 2 levels for sub-organic detail
  - SSS-friendly procedural shader: translucent green base + emissive
    "leaked memory" code-glyph noise
  - Bake DIFFUSE → 1024 PNG, retopo via decimate, normal bake high→low
  - 5-bone armature: root, body, top, drip_l, drip_r
  - Ooze pulse animation: body squash/stretch + drip swing
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(305)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/v3_r3_memoryleak.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/renders"
TEX_DIR      = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/baked"
ANIM_DIR     = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/anims"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/exports"
for d in [RENDER_DIR, TEX_DIR, ANIM_DIR, EXPORT_DIR]:
    os.makedirs(d, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.cycles.device = 'CPU'
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3r3_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.04, 0.03, 1)
bg.inputs["Strength"].default_value = 0.45

# ============================================================
# STAGE 1 — SINGLE-MESH BLOB
# ============================================================
print("=== STAGE 1: Memory Leak base ===")

bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=24, radius=1.2, location=(0, 0, 1.2))
hero = bpy.context.object
hero.name = "memoryleak_hp"

bm = bmesh.new()
bm.from_mesh(hero.data)

# Slime proportions: bottom-heavy (drooping), wider than tall
for v in bm.verts:
    # Squash vertically slightly
    v.co.z *= 0.85
    # Bottom-heavy droop
    if v.co.z < 0:
        v.co.z *= 1.4
        v.co.x *= 1.2
        v.co.y *= 1.2
    # Per-vertex noise displacement so the surface is uneven, not perfect sphere
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    v.co += v.normal * random.uniform(-0.08, 0.12)

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === 4 bulging eye sockets on the upper front ===
print("Carving eye sockets (multiple)...")
EYE_TARGETS = [
    Vector((-0.55, -1.20, 0.40)),
    Vector((0.55, -1.20, 0.40)),
    Vector((-0.20, -1.30, 0.85)),
    Vector((0.20, -1.30, 0.85)),
]
for target in EYE_TARGETS:
    eye_face = closest_face(bm, target)
    if eye_face:
        # Bulge eye out
        res = bmesh.ops.inset_individual(bm, faces=[eye_face], thickness=0.12, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else eye_face
        for v in new_f.verts:
            v.co += v.normal * 0.10
        # Iris socket pushed BACK into the bulge
        res2 = bmesh.ops.inset_individual(bm, faces=[new_f], thickness=0.05, depth=0.0)
        new_f2 = res2['faces'][0] if res2.get('faces') else new_f
        for v in new_f2.verts:
            v.co -= v.normal * 0.05

# === Wide drooling mouth slit ===
print("Cutting mouth slit...")
mouth_centers = [Vector((-0.35, -1.25, -0.10)), Vector((0, -1.30, -0.10)), Vector((0.35, -1.25, -0.10))]
for target in mouth_centers:
    mf = closest_face(bm, target)
    if mf:
        res = bmesh.ops.inset_individual(bm, faces=[mf], thickness=0.10, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else mf
        for v in new_f.verts:
            v.co += Vector((0, 0.10, -0.05))  # push back into the head, slightly down

# === 4 bottom drips extruded down ===
print("Extruding bottom drips...")
DRIP_TARGETS = [
    Vector((-0.85, -0.5, -1.4)),
    Vector((0.85, -0.5, -1.4)),
    Vector((-0.85, 0.5, -1.4)),
    Vector((0.85, 0.5, -1.4)),
]
for target in DRIP_TARGETS:
    drip_face = closest_face(bm, target)
    if drip_face:
        geom = bmesh.ops.extrude_face_region(bm, geom=[drip_face])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co += Vector((0, 0, -0.30))
            v.co.x *= 0.85
            v.co.y *= 0.85
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co += Vector((0, 0, -0.40))
                v.co.x *= 0.55
                v.co.y *= 0.55
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = avg  # collapse to drip tip

# === Top antenna/horn nub ===
print("Extruding top horn...")
horn_face = closest_face(bm, Vector((0, 0, 1.30)))
if horn_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[horn_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co += Vector((0, 0, 0.30))
        v.co.x *= 0.6
        v.co.y *= 0.6
    new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
        new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts2:
            v.co += Vector((0, -0.10, 0.30))
        avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
        for v in new_verts2:
            v.co = avg

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = True

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
# STAGE 3 — SHADER (translucent green ooze + emissive code glyphs)
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
    bsdf.inputs["Roughness"].default_value = 0.10
    bsdf.inputs["Metallic"].default_value = 0.0
    bsdf.inputs["Coat Weight"].default_value = 0.9
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    bsdf.inputs["Subsurface Weight"].default_value = 0.65
    bsdf.inputs["Subsurface Radius"].default_value = (0.7, 0.9, 0.5)
    bsdf.inputs["Emission Strength"].default_value = 5.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Green ooze base
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 6.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    ooze_ramp = nodes.new("ShaderNodeValToRGB"); ooze_ramp.location = (-450, 200)
    cr = ooze_ramp.color_ramp
    cr.elements[0].position = 0.20
    cr.elements[0].color = (0.04, 0.18, 0.08, 1)   # dark green
    cr.elements[1].position = 0.80
    cr.elements[1].color = (0.20, 0.55, 0.18, 1)   # bright slime
    links.new(n.outputs["Fac"], ooze_ramp.inputs["Fac"])
    links.new(ooze_ramp.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(ooze_ramp.outputs["Color"], bsdf.inputs["Subsurface Radius"])

    # Subsurface color (more saturated)
    sss_color_node = nodes.new("ShaderNodeRGB"); sss_color_node.location = (-200, -50)
    sss_color_node.outputs[0].default_value = (0.25, 0.85, 0.35, 1)

    # Voronoi for code glyph emission
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 8.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])

    glyph_ramp = nodes.new("ShaderNodeValToRGB"); glyph_ramp.location = (-450, -100)
    glyph_ramp.color_ramp.elements[0].position = 0.0
    glyph_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    glyph_ramp.color_ramp.elements[1].position = 0.05
    glyph_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], glyph_ramp.inputs["Fac"])

    # Emission color: cyan-green
    em_color = nodes.new("ShaderNodeRGB"); em_color.location = (-450, -350)
    em_color.outputs[0].default_value = (0.30, 1.0, 0.55, 1)

    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type = 'RGBA'; em_mix.location = (100, -200)
    links.new(glyph_ramp.outputs["Color"], em_mix.inputs["Factor"])
    em_mix.inputs[6].default_value = (0, 0, 0, 1)
    links.new(em_color.outputs[0], em_mix.inputs[7])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -500)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_shader("v3r3_memoryleak_proc")
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("memoryleak_albedo_bake", width=1024, height=1024)
img_node_a = mat_proc.node_tree.nodes.new("ShaderNodeTexImage")
img_node_a.location = (1100, 400)
img_node_a.image = bake_albedo
img_node_a.select = True
mat_proc.node_tree.nodes.active = img_node_a

scene.cycles.bake_type = 'DIFFUSE'
scene.render.bake.use_pass_direct = False
scene.render.bake.use_pass_indirect = False
scene.render.bake.use_pass_color = True
scene.cycles.samples = 32

bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero

print("Baking diffuse...")
try:
    bpy.ops.object.bake(type='DIFFUSE')
    bake_path = os.path.join(TEX_DIR, "memoryleak_albedo_1024.png")
    bake_albedo.filepath_raw = bake_path
    bake_albedo.file_format = 'PNG'
    bake_albedo.save()
    print(f"Baked albedo: {bake_path}")
except Exception as e:
    print(f"Albedo bake failed: {e}")

# ============================================================
# STAGE 5 — RETOPO LOW-POLY
# ============================================================
print("=== STAGE 5: Retopo low-poly ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "memoryleak_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.18
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL MAP BAKE
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("memoryleak_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_memoryleak_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.15
bsdf_lp.inputs["Metallic"].default_value = 0.0
bsdf_lp.inputs["Coat Weight"].default_value = 0.85
bsdf_lp.inputs["Coat Roughness"].default_value = 0.05
bsdf_lp.inputs["Subsurface Weight"].default_value = 0.5
bsdf_lp.inputs["Subsurface Radius"].default_value = (0.7, 0.9, 0.5)
ntlp.links.new(bsdf_lp.outputs[0], out_lp.inputs[0])

img_alb_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_alb_lp.location = (200, 200)
img_alb_lp.image = bake_albedo
ntlp.links.new(img_alb_lp.outputs["Color"], bsdf_lp.inputs["Base Color"])

img_nrm_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_nrm_lp.location = (200, -200)
img_nrm_lp.image = bake_normal
img_nrm_lp.image.colorspace_settings.name = 'Non-Color'
nrm_node = ntlp.nodes.new("ShaderNodeNormalMap"); nrm_node.location = (550, -200)
ntlp.links.new(img_nrm_lp.outputs["Color"], nrm_node.inputs["Color"])
ntlp.links.new(nrm_node.outputs["Normal"], bsdf_lp.inputs["Normal"])

img_nrm_lp.select = True
ntlp.nodes.active = img_nrm_lp

low_poly.data.materials.clear()
low_poly.data.materials.append(mat_lp)

print("Performing selected-to-active NORMAL bake...")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
low_poly.select_set(True)
bpy.context.view_layer.objects.active = low_poly

scene.cycles.bake_type = 'NORMAL'
scene.render.bake.use_selected_to_active = True
scene.render.bake.cage_extrusion = 0.06
scene.render.bake.max_ray_distance = 0.35
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "memoryleak_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (3.5, 0, 1.2)

# ============================================================
# STAGE 7 — ARMATURE: 5-bone ooze rig
# ============================================================
print("=== STAGE 7: Armature ===")
bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "memoryleak_armature"
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

root  = add_bone("root", Vector((0, 0, 0.0)), Vector((0, 0, 0.5)))
body  = add_bone("body", Vector((0, 0, 0.5)), Vector((0, 0, 1.4)), parent=root)
top   = add_bone("top", Vector((0, 0, 1.4)), Vector((0, 0, 1.9)), parent=body)
drip_l = add_bone("drip_l", Vector((-0.85, 0, 0.0)), Vector((-0.85, 0, -0.7)), parent=root)
drip_r = add_bone("drip_r", Vector((0.85, 0, 0.0)),  Vector((0.85, 0, -0.7)),  parent=root)

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
# STAGE 8 — OOZE PULSE ANIMATION
# ============================================================
print("=== STAGE 8: Ooze pulse animation ===")
scene.frame_start = 1
scene.frame_end = 60
scene.render.fps = 30

bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

pb_body = arm.pose.bones["body"]
pb_top  = arm.pose.bones["top"]
pb_dl   = arm.pose.bones["drip_l"]
pb_dr   = arm.pose.bones["drip_r"]

for pb in [pb_body, pb_top, pb_dl, pb_dr]:
    pb.rotation_mode = 'XYZ'

# Squash-stretch on body, top wobbles, drips swing
KEYS = [
    # frame, body_sx, body_sz, top_rx, dl_rx, dr_rx
    (1,  1.00, 1.00,  0.00,  0.00,  0.00),
    (15, 1.10, 0.90,  0.10,  0.20, -0.20),
    (30, 0.92, 1.12, -0.08, -0.15,  0.15),
    (45, 1.08, 0.92,  0.08,  0.18, -0.18),
    (60, 1.00, 1.00,  0.00,  0.00,  0.00),
]
for f, bsx, bsz, trx, dlx, drx in KEYS:
    scene.frame_set(f)
    pb_body.scale = (bsx, bsx, bsz)
    pb_body.keyframe_insert(data_path="scale", frame=f)
    pb_top.rotation_euler = (trx, 0, 0); pb_top.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_dl.rotation_euler = (dlx, 0, 0); pb_dl.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_dr.rotation_euler = (drx, 0, 0); pb_dr.keyframe_insert(data_path="rotation_euler", frame=f)

bpy.ops.object.mode_set(mode='OBJECT')
print("Ooze pulse keyframes inserted")

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
# STAGE 9 — LIGHTING + RENDERS
# ============================================================
print("=== STAGE 9: Lighting + Renders ===")

bpy.ops.object.light_add(type='SPOT', location=(5, -10, 9))
key = bpy.context.object
key.data.energy = 4500; key.data.color = (0.55, 1.0, 0.65)
key.data.spot_size = math.radians(80)
direction = Vector((0, 0, 1.2)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-6, 6, 5))
rim = bpy.context.object
rim.data.energy = 1100; rim.data.color = (0.40, 1.0, 0.85); rim.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(0, -6, 3))
fill = bpy.context.object
fill.data.energy = 500; fill.data.color = (0.35, 0.55, 0.45); fill.data.size = 6

bpy.ops.mesh.primitive_plane_add(size=14, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.04, 0.06, 0.05, 1)
fbsdf.inputs["Roughness"].default_value = 0.50
fl.data.materials.append(mat_fl)

def add_cam(name, loc, target, lens=70, dof=4.0, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((0, -6, 1.6)), Vector((0, 0, 1.0)), lens=60, dof=6)
cam_lp = add_cam("cam_lp", Vector((3.5, -6, 1.6)), Vector((3.5, 0, 1.0)), lens=60, dof=6)
cam_compare = add_cam("cam_compare", Vector((1.75, -8, 2.0)), Vector((1.75, 0, 1.0)), lens=50, dof=8)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.frame_set(1)
scene.camera = cam_hp
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_memoryleak_hp_hero.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_memoryleak_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_memoryleak_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_hp
scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for f in [1, 15, 30, 45]:
    scene.frame_set(f)
    scene.render.filepath = os.path.join(ANIM_DIR, f"v3_r3_memoryleak_pulse_f{f:02d}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered anim frame: {scene.render.filepath}")

# ============================================================
# STAGE 10 — GLB EXPORT
# ============================================================
print("=== STAGE 10: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
arm.select_set(True)
bpy.context.view_layer.objects.active = arm

out_path = os.path.join(EXPORT_DIR, "memoryleak_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_animations=True, export_skins=True,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-05 Memory Leak Sculpted complete ===")
