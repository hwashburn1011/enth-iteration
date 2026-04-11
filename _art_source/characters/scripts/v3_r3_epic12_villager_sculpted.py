"""
Expansion V3 — ROUND 3 — Epic R3-12 — Hero Villager NPC
=======================================================
First sculpted townsperson NPC. Single-mesh humanoid (head + torso
joined as one mesh, not parented primitives) carved from a stretched
UV sphere. Real face: 2 eye sockets, nose protrusion (extrude), mouth
slit, 2 ears extruded from sides. 9-bone armature, 60-frame idle
animation (breathing + slight head turn lookaround).

Pipeline:
  1. UV sphere base, stretched into head+torso form via Z-zone scaling
  2. Eye sockets carved via inset push-in
  3. Mouth slit carved
  4. Nose extruded forward (face_region 2-stage)
  5. Ears extruded from sides
  6. Arms extruded from shoulders (real geometry, not separate cylinders)
  7. Multires 2 levels
  8. UV unwrap, skin+tunic procedural shader (Z-zoned color stops)
  9. Bake DIFFUSE → 1024 PNG, decimate, normal bake high→low
 10. 9-bone armature: root, spine, chest, head, arm_l, forearm_l,
     arm_r, forearm_r, neck
 11. Idle animation: head bob, breathing chest scale, head Y-rotate
 12. GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(312)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_r3_villager.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/renders"
TEX_DIR      = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/baked"
ANIM_DIR     = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/anims"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/exports"
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
bg.inputs["Color"].default_value = (0.50, 0.55, 0.60, 1)
bg.inputs["Strength"].default_value = 1.2

# ============================================================
# STAGE 1 — VILLAGER BASE MESH
# ============================================================
print("=== STAGE 1: Villager base ===")

bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=32, radius=0.50, location=(0, 0, 0.85))
hero = bpy.context.object
hero.name = "villager_hp"

bm = bmesh.new()
bm.from_mesh(hero.data)

# Stretch into head + torso form via Z-zone
for v in bm.verts:
    z_local = v.co.z  # local Z (sphere center at origin)
    # Head zone (top): z > 0.30
    if z_local > 0.30:
        v.co.z += 0.30  # lift head
    # Neck pinch: 0.10 < z < 0.30
    elif 0.10 < z_local <= 0.30:
        v.co.x *= 0.55
        v.co.y *= 0.55
        v.co.z += 0.18
    # Torso: -0.40 < z < 0.10
    elif -0.40 < z_local <= 0.10:
        v.co.x *= 1.45
        v.co.y *= 1.20
        v.co.z *= 1.30
    # Hips: z < -0.40
    else:
        v.co.x *= 1.20
        v.co.y *= 1.05
        v.co.z *= 1.35

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Eye sockets (carved into head front) ===
print("Carving eye sockets...")
for offset_x in [-0.18, 0.18]:
    eye_target = Vector((offset_x, -0.42, 1.18))
    ef = closest_face(bm, eye_target)
    if ef:
        res = bmesh.ops.inset_individual(bm, faces=[ef], thickness=0.06, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else ef
        for v in new_f.verts:
            v.co.y += 0.04  # push back into head
        # Inner inset for iris (slight forward bump)
        res2 = bmesh.ops.inset_individual(bm, faces=[new_f], thickness=0.025, depth=0.0)
        new_f2 = res2['faces'][0] if res2.get('faces') else new_f
        for v in new_f2.verts:
            v.co.y -= 0.01  # iris slightly forward inside socket

# === Mouth slit ===
print("Cutting mouth slit...")
for x in [-0.06, 0, 0.06]:
    mf = closest_face(bm, Vector((x, -0.45, 0.95)))
    if mf:
        res = bmesh.ops.inset_individual(bm, faces=[mf], thickness=0.04, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else mf
        for v in new_f.verts:
            v.co.y += 0.03
            v.co.z -= 0.01

# === Nose extruded forward ===
print("Extruding nose...")
nose_face = closest_face(bm, Vector((0, -0.48, 1.05)))
if nose_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[nose_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.y -= 0.06
    new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
        new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts2:
            v.co.y -= 0.05
            v.co.z -= 0.02
        # Slight pinch
        avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
        for v in new_verts2:
            v.co = v.co.lerp(avg, 0.4)

# === Ears extruded from sides ===
print("Extruding ears...")
for side in [-1, 1]:
    ear_face = closest_face(bm, Vector((side * 0.45, 0, 1.10)))
    if ear_face:
        geom = bmesh.ops.extrude_face_region(bm, geom=[ear_face])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co.x += side * 0.06
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co.x += side * 0.03
                v.co.y += 0.01
            # Slight inward pinch on the tip
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = v.co.lerp(avg, 0.3)

# === Arms extruded from shoulders ===
print("Extruding arms...")
for side in [-1, 1]:
    shoulder_face = closest_face(bm, Vector((side * 0.55, 0, 0.55)))
    if shoulder_face:
        # First extrude — upper arm
        geom = bmesh.ops.extrude_face_region(bm, geom=[shoulder_face])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co.x += side * 0.20
            v.co.z -= 0.05
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            # Second — forearm
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co.x += side * 0.18
                v.co.z -= 0.20
            # Slight taper
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = v.co.lerp(avg, 0.20)
            new_faces2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMFace)]
            if new_faces2:
                # Third — hand stub
                geom3 = bmesh.ops.extrude_face_region(bm, geom=[new_faces2[0]])
                new_verts3 = [g for g in geom3['geom'] if isinstance(g, bmesh.types.BMVert)]
                for v in new_verts3:
                    v.co.x += side * 0.05
                    v.co.z -= 0.15
                avg3 = sum((v.co for v in new_verts3), Vector()) / len(new_verts3)
                for v in new_verts3:
                    v.co = v.co.lerp(avg3, 0.45)

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
# STAGE 3 — SKIN + TUNIC SHADER (Z-zoned)
# ============================================================
print("=== STAGE 3: Skin + tunic shader ===")

def make_shader():
    m = bpy.data.materials.new("v3r3_villager_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.55
    bsdf.inputs["Metallic"].default_value = 0.0
    bsdf.inputs["Subsurface Weight"].default_value = 0.20
    bsdf.inputs["Subsurface Radius"].default_value = (1.0, 0.4, 0.3)
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (3.0, 3.0, 3.0)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-1200, -300)
    links.new(tc.outputs["Object"], sep.inputs["Vector"])

    # Z-zoned color ramp:
    # < 0.30 = boots (dark brown)
    # 0.30-0.85 = tunic (warm red-brown)
    # 0.85-1.05 = skin (warm pink-tan)
    # 1.05+ = hair (dark brown)
    col_ramp = nodes.new("ShaderNodeValToRGB"); col_ramp.location = (-650, 100)
    cr = col_ramp.color_ramp
    cr.elements[0].position = 0.0
    cr.elements[0].color = (0.10, 0.06, 0.04, 1)   # boots
    cr.elements[1].position = 0.30
    cr.elements[1].color = (0.45, 0.15, 0.08, 1)   # tunic red
    el2 = cr.elements.new(0.65)
    el2.color = (0.60, 0.25, 0.12, 1)               # tunic warm
    el3 = cr.elements.new(0.78)
    el3.color = (0.85, 0.55, 0.35, 1)               # skin tan
    el4 = cr.elements.new(0.92)
    el4.color = (0.10, 0.06, 0.03, 1)               # hair dark
    links.new(sep.outputs["Z"], col_ramp.inputs["Fac"])

    # Texture variation noise
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-900, -100)
    n.inputs["Scale"].default_value = 12.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    # Mix noise into the color (subtle variation)
    mix = nodes.new("ShaderNodeMix"); mix.data_type = 'RGBA'; mix.location = (-200, 100)
    mix.inputs["Factor"].default_value = 0.20
    links.new(n.outputs["Fac"], mix.inputs["Factor"])
    links.new(col_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.05, 0.03, 0.02, 1)

    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -500)
    bp.inputs["Strength"].default_value = 0.20
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("villager_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "villager_albedo_1024.png")
    bake_albedo.filepath_raw = bake_path
    bake_albedo.file_format = 'PNG'
    bake_albedo.save()
    print(f"Baked albedo: {bake_path}")
except Exception as e:
    print(f"Bake failed: {e}")

# ============================================================
# STAGE 5 — RETOPO
# ============================================================
print("=== STAGE 5: Retopo low-poly ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "villager_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.20
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL BAKE
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("villager_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_villager_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.55
bsdf_lp.inputs["Subsurface Weight"].default_value = 0.15
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
scene.render.bake.cage_extrusion = 0.04
scene.render.bake.max_ray_distance = 0.20
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "villager_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (2.5, 0, 0.85)

# ============================================================
# STAGE 7 — ARMATURE: 9-bone humanoid rig
# ============================================================
print("=== STAGE 7: Armature ===")
bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "villager_armature"
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

root      = add_bone("root",     Vector((0, 0, 0.0)),  Vector((0, 0, 0.30)))
spine     = add_bone("spine",    Vector((0, 0, 0.30)), Vector((0, 0, 0.65)), parent=root)
chest     = add_bone("chest",    Vector((0, 0, 0.65)), Vector((0, 0, 0.95)), parent=spine)
neck      = add_bone("neck",     Vector((0, 0, 0.95)), Vector((0, 0, 1.05)), parent=chest)
head_b    = add_bone("head",     Vector((0, 0, 1.05)), Vector((0, 0, 1.40)), parent=neck)
arm_l     = add_bone("arm_l",    Vector((-0.55, 0, 0.85)), Vector((-0.78, 0, 0.65)), parent=chest)
forearm_l = add_bone("forearm_l",Vector((-0.78, 0, 0.65)), Vector((-0.96, 0, 0.40)), parent=arm_l)
arm_r     = add_bone("arm_r",    Vector((0.55, 0, 0.85)),  Vector((0.78, 0, 0.65)),  parent=chest)
forearm_r = add_bone("forearm_r",Vector((0.78, 0, 0.65)),  Vector((0.96, 0, 0.40)),  parent=arm_r)

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
# STAGE 8 — IDLE ANIMATION (breathing + lookaround)
# ============================================================
print("=== STAGE 8: Idle animation ===")
scene.frame_start = 1
scene.frame_end = 60
scene.render.fps = 30

bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

pb_chest = arm.pose.bones["chest"]
pb_head  = arm.pose.bones["head"]
pb_arm_l = arm.pose.bones["arm_l"]
pb_arm_r = arm.pose.bones["arm_r"]

for pb in [pb_chest, pb_head, pb_arm_l, pb_arm_r]:
    pb.rotation_mode = 'XYZ'

KEYS = [
    # frame, chest_sx, head_rz, arm_l_rz, arm_r_rz
    (1,  1.00,  0.00,  0.00,  0.00),
    (15, 1.03,  0.20,  0.05, -0.05),
    (30, 1.06,  0.00,  0.10, -0.10),
    (45, 1.03, -0.20,  0.05, -0.05),
    (60, 1.00,  0.00,  0.00,  0.00),
]
for f, csx, hrz, alrz, arrz in KEYS:
    scene.frame_set(f)
    pb_chest.scale = (csx, 1.0, csx)
    pb_chest.keyframe_insert(data_path="scale", frame=f)
    pb_head.rotation_euler = (0, 0, hrz); pb_head.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_arm_l.rotation_euler = (0, 0, alrz); pb_arm_l.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_arm_r.rotation_euler = (0, 0, arrz); pb_arm_r.keyframe_insert(data_path="rotation_euler", frame=f)

bpy.ops.object.mode_set(mode='OBJECT')
print("Idle keyframes inserted")

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
# STAGE 9 — LIGHTING + RENDERS (golden hour town setting)
# ============================================================
print("=== STAGE 9: Lighting + Renders ===")

bpy.ops.object.light_add(type='SUN', location=(0, 0, 12))
sun = bpy.context.object
sun.data.energy = 4.0
sun.data.color = (1.0, 0.92, 0.78)
sun.rotation_euler = (math.radians(45), math.radians(15), 0)

bpy.ops.object.light_add(type='AREA', location=(-6, 6, 6))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.55, 0.70, 0.95); fill.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(6, -3, 4))
rim = bpy.context.object
rim.data.energy = 400; rim.data.color = (1.0, 0.85, 0.55); rim.data.size = 5

bpy.ops.mesh.primitive_plane_add(size=20, location=(0, 0, 0))
gnd = bpy.context.object; gnd.name = "ground"
mat_g = bpy.data.materials.new("ground")
mat_g.use_nodes = True
gbsdf = mat_g.node_tree.nodes["Principled BSDF"]
gbsdf.inputs["Base Color"].default_value = (0.20, 0.18, 0.12, 1)
gbsdf.inputs["Roughness"].default_value = 0.85
gnd.data.materials.append(mat_g)

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

cam_hp = add_cam("cam_hp", Vector((0, -3.5, 1.5)), Vector((0, 0, 1.0)), lens=70, dof=3.5)
cam_lp = add_cam("cam_lp", Vector((2.5, -3.5, 1.5)), Vector((2.5, 0, 1.0)), lens=70, dof=3.5)
cam_compare = add_cam("cam_compare", Vector((1.25, -5, 1.5)), Vector((1.25, 0, 1.0)), lens=50, dof=5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.frame_set(1)
scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_villager_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_villager_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_villager_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Anim playblast
scene.camera = cam_hp
scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for f in [1, 15, 30, 45]:
    scene.frame_set(f)
    scene.render.filepath = os.path.join(ANIM_DIR, f"v3_r3_villager_idle_f{f:02d}.png")
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

out_path = os.path.join(EXPORT_DIR, "villager_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_animations=True, export_skins=True,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-12 Villager NPC complete ===")
