"""
Expansion V3 — ROUND 3 — Epic R3-04 — Glitchbug Sculpted
========================================================
Insect-form enemy. Same R3 pipeline (sculpt + retopo + bake albedo +
bake normal high→low + rig + animate + GLB) but with insect-specific
features carved as REAL geometry rather than parented primitives:

  - Single-mesh body from a stretched UV sphere (thorax + abdomen)
  - 2 large compound eye sockets carved via inset_individual
  - Mandible pair extruded from real faces forward of the mouth
  - Antenna pair extruded + tip-collapsed (NOT separate cylinders)
  - 6 leg stubs extruded from the underside (we don't try to model
    full insect legs — too costly for a single mesh — but we do
    extrude real protrusions so the silhouette reads as insect)
  - Multires 2 levels (lighter than R3-03 because base mesh is denser)
  - Procedural shader: chitin (iridescent green-purple) + glitch seams
  - Bake DIFFUSE → 1024 PNG, retopo via decimate, normal bake high→low
  - 8-bone armature: root, abdomen, thorax, head, antenna_l, antenna_r,
    mandible_l, mandible_r
  - Twitch idle animation (scuttle weight shift + antenna flick + mandible chatter)
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(304)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/v3_r3_glitchbug.blend"
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
bg.inputs["Color"].default_value = (0.03, 0.05, 0.04, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# STAGE 1 — SINGLE-MESH GLITCHBUG BODY
# ============================================================
print("=== STAGE 1: Glitchbug base ===")

# UV sphere base — gives smooth chitin surface vs faceted
bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=24, radius=1.0, location=(0, 0, 1.0))
hero = bpy.context.object
hero.name = "glitchbug_hp"

bm = bmesh.new()
bm.from_mesh(hero.data)

# Insect proportions: stretched along Y, narrowing toward back (abdomen tail)
for v in bm.verts:
    # Stretch along Y axis (head→abdomen direction)
    v.co.y *= 1.6
    # Pinch the back end (high +y) into a tapered abdomen
    if v.co.y > 0.4:
        taper = 1.0 - (v.co.y - 0.4) * 0.45
        v.co.x *= max(0.55, taper)
        v.co.z *= max(0.65, taper)
    # Slightly flatten ventral side
    if v.co.z < 0:
        v.co.z *= 0.7
    # Per-vertex chitinous bumps
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    v.co += v.normal * random.uniform(-0.02, 0.04)

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Compound eyes — two big bulging sockets on the head (front, -Y) ===
print("Carving compound eye sockets...")
for offset_x in [-0.45, 0.45]:
    eye_target = Vector((offset_x, -1.5, 0.20))
    eye_face = closest_face(bm, eye_target)
    if eye_face:
        # Inset, then push OUTWARD (compound eyes bulge out, not socket-in)
        res = bmesh.ops.inset_individual(bm, faces=[eye_face], thickness=0.15, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else eye_face
        for v in new_f.verts:
            v.co += v.normal * 0.10  # bulge outward
        # Second inset for the highlight ring
        res2 = bmesh.ops.inset_individual(bm, faces=[new_f], thickness=0.06, depth=0.0)
        new_f2 = res2['faces'][0] if res2.get('faces') else new_f
        for v in new_f2.verts:
            v.co += v.normal * 0.04

# === Mandible pair — extruded forward of the mouth ===
print("Extruding mandibles...")
for offset_x in [-0.18, 0.18]:
    mand_face = closest_face(bm, Vector((offset_x, -1.55, -0.25)))
    if mand_face:
        geom = bmesh.ops.extrude_face_region(bm, geom=[mand_face])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co += Vector((offset_x * 0.6, -0.18, -0.05))
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co += Vector((offset_x * 0.4, -0.20, 0.0))
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = avg  # collapse to mandible tip

# === Antennae — extruded from top of head, tip-collapsed ===
print("Extruding antennae...")
for offset_x in [-0.30, 0.30]:
    ant_face = closest_face(bm, Vector((offset_x, -1.3, 0.85)))
    if ant_face:
        geom = bmesh.ops.extrude_face_region(bm, geom=[ant_face])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co += Vector((offset_x * 0.5, -0.25, 0.20))
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co += Vector((offset_x * 0.6, -0.20, 0.40))
            new_faces2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMFace)]
            if new_faces2:
                geom3 = bmesh.ops.extrude_face_region(bm, geom=[new_faces2[0]])
                new_verts3 = [g for g in geom3['geom'] if isinstance(g, bmesh.types.BMVert)]
                for v in new_verts3:
                    v.co += Vector((offset_x * 0.3, -0.10, 0.30))
                avg = sum((v.co for v in new_verts3), Vector()) / len(new_verts3)
                for v in new_verts3:
                    v.co = avg

# === Leg stubs — 6 short protrusions on the ventral side ===
print("Extruding leg stubs...")
LEG_TARGETS = [
    Vector((-0.95, -0.7, -0.50)),  # front-left
    Vector((0.95, -0.7, -0.50)),   # front-right
    Vector((-0.95, 0.0, -0.55)),   # mid-left
    Vector((0.95, 0.0, -0.55)),    # mid-right
    Vector((-0.85, 0.7, -0.55)),   # back-left
    Vector((0.85, 0.7, -0.55)),    # back-right
]
for target in LEG_TARGETS:
    leg_face = closest_face(bm, target)
    if leg_face:
        geom = bmesh.ops.extrude_face_region(bm, geom=[leg_face])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        side = 1.0 if target.x > 0 else -1.0
        for v in new_verts:
            v.co += Vector((side * 0.25, 0, -0.25))
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co += Vector((side * 0.10, 0, -0.30))
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = avg

# === Segmented spine ridges along the abdomen ===
print("Carving abdomen segmentation...")
for y in [0.5, 0.9, 1.3]:
    ridge_face = closest_face(bm, Vector((0, y, 0.8)))
    if ridge_face:
        res = bmesh.ops.inset_individual(bm, faces=[ridge_face], thickness=0.10, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else ridge_face
        for v in new_f.verts:
            v.co += Vector((0, 0, 0.05))

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = True

# Multires 2 levels (UV sphere base is already dense)
print("Adding multires...")
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
for _ in range(2):
    bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 2 — UV UNWRAP HIGH-POLY
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
# STAGE 3 — PROCEDURAL SHADER (iridescent chitin + glitch seams)
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
    bsdf.inputs["Roughness"].default_value = 0.15
    bsdf.inputs["Metallic"].default_value = 0.30
    bsdf.inputs["Coat Weight"].default_value = 0.8
    bsdf.inputs["Coat Roughness"].default_value = 0.08
    bsdf.inputs["Emission Strength"].default_value = 6.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Iridescent base — gradient by Z and by view-direction-style noise
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 5.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    chitin_ramp = nodes.new("ShaderNodeValToRGB"); chitin_ramp.location = (-450, 200)
    cr = chitin_ramp.color_ramp
    cr.elements[0].position = 0.0
    cr.elements[0].color = (0.04, 0.18, 0.08, 1)   # dark green
    cr.elements[1].position = 0.45
    cr.elements[1].color = (0.10, 0.45, 0.20, 1)   # mid green
    el2 = cr.elements.new(0.75)
    el2.color = (0.25, 0.10, 0.45, 1)               # purple iridescence
    el3 = cr.elements.new(1.0)
    el3.color = (0.55, 0.30, 0.70, 1)               # bright violet
    links.new(n.outputs["Fac"], chitin_ramp.inputs["Fac"])

    # Voronoi crack mask for glitch seams
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 6.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    crack_ramp = nodes.new("ShaderNodeValToRGB"); crack_ramp.location = (-450, -100)
    crack_ramp.color_ramp.elements[0].position = 0.0
    crack_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    crack_ramp.color_ramp.elements[1].position = 0.04
    crack_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], crack_ramp.inputs["Fac"])

    # Mix chitin w/ crack mask
    mix = nodes.new("ShaderNodeMix"); mix.data_type = 'RGBA'; mix.location = (-200, 100)
    links.new(crack_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(chitin_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.02, 0.04, 0.02, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Glitch emission — magenta to lime
    color_ramp = nodes.new("ShaderNodeValToRGB"); color_ramp.location = (-450, -300)
    color_ramp.color_ramp.elements[0].position = 0.20
    color_ramp.color_ramp.elements[0].color = (1.0, 0.10, 0.85, 1)  # magenta
    color_ramp.color_ramp.elements[1].position = 0.70
    color_ramp.color_ramp.elements[1].color = (0.40, 1.0, 0.20, 1)  # lime
    links.new(v.outputs["Distance"], color_ramp.inputs["Fac"])

    glow = nodes.new("ShaderNodeMix"); glow.data_type = 'RGBA'; glow.location = (100, -200)
    links.new(crack_ramp.outputs["Color"], glow.inputs["Factor"])
    glow.inputs[6].default_value = (0, 0, 0, 1)
    links.new(color_ramp.outputs["Color"], glow.inputs[7])
    links.new(glow.outputs[2], bsdf.inputs["Emission Color"])

    # Bump from chitin noise
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -500)
    bp.inputs["Strength"].default_value = 0.40
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_shader("v3r3_glitchbug_proc")
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("glitchbug_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "glitchbug_albedo_1024.png")
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
low_poly.name = "glitchbug_lp"

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
# STAGE 6 — NORMAL MAP BAKE high → low
# ============================================================
print("=== STAGE 6: Normal map bake high → low ===")
bake_normal = bpy.data.images.new("glitchbug_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_glitchbug_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.20
bsdf_lp.inputs["Metallic"].default_value = 0.30
bsdf_lp.inputs["Coat Weight"].default_value = 0.7
bsdf_lp.inputs["Coat Roughness"].default_value = 0.08
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
scene.render.bake.cage_extrusion = 0.05
scene.render.bake.max_ray_distance = 0.30
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "glitchbug_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback
    traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

# Move low-poly aside for compare render
low_poly.location = (3.5, 0, 1.0)

# ============================================================
# STAGE 7 — ARMATURE: 8-bone insect rig
# ============================================================
print("=== STAGE 7: Armature ===")
bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "glitchbug_armature"
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

root      = add_bone("root",     Vector((0, 0, 0.0)), Vector((0, 0, 0.4)))
abdomen   = add_bone("abdomen",  Vector((0, 0.4, 1.0)), Vector((0, 1.4, 1.0)), parent=root)
thorax    = add_bone("thorax",   Vector((0, -0.2, 1.0)), Vector((0, 0.4, 1.0)), parent=root)
head_b    = add_bone("head",     Vector((0, -1.0, 1.0)), Vector((0, -1.5, 1.1)), parent=thorax)
ant_l     = add_bone("antenna_l", Vector((-0.30, -1.3, 1.20)), Vector((-0.65, -1.6, 1.80)), parent=head_b)
ant_r     = add_bone("antenna_r", Vector((0.30, -1.3, 1.20)),  Vector((0.65, -1.6, 1.80)),  parent=head_b)
mand_l    = add_bone("mand_l",    Vector((-0.18, -1.55, 0.75)), Vector((-0.30, -1.85, 0.65)), parent=head_b)
mand_r    = add_bone("mand_r",    Vector((0.18, -1.55, 0.75)),  Vector((0.30, -1.85, 0.65)),  parent=head_b)

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
# STAGE 8 — TWITCH IDLE ANIMATION
# ============================================================
print("=== STAGE 8: Twitch idle animation ===")
scene.frame_start = 1
scene.frame_end = 60
scene.render.fps = 30

bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

pb_root    = arm.pose.bones["root"]
pb_abd     = arm.pose.bones["abdomen"]
pb_head    = arm.pose.bones["head"]
pb_ant_l   = arm.pose.bones["antenna_l"]
pb_ant_r   = arm.pose.bones["antenna_r"]
pb_mand_l  = arm.pose.bones["mand_l"]
pb_mand_r  = arm.pose.bones["mand_r"]

for pb in [pb_root, pb_abd, pb_head, pb_ant_l, pb_ant_r, pb_mand_l, pb_mand_r]:
    pb.rotation_mode = 'XYZ'

# Twitch keys: head jerks, antennae flick, mandibles chatter, abdomen wiggle
KEYS = [
    # frame, root_z, abd_rz, head_rx, ant_l_ry, ant_r_ry, mand_l_rz, mand_r_rz
    (1,  0.00,  0.00,  0.00,   0.00,  0.00,  0.00,  0.00),
    (10, 0.04,  0.10, -0.10,   0.30, -0.30,  0.20, -0.20),
    (20, 0.00, -0.05,  0.05,  -0.20,  0.20, -0.10,  0.10),
    (30, 0.05,  0.15, -0.15,   0.40, -0.40,  0.30, -0.30),
    (40, 0.00, -0.10,  0.10,  -0.30,  0.30, -0.20,  0.20),
    (50, 0.03,  0.05, -0.05,   0.20, -0.20,  0.15, -0.15),
    (60, 0.00,  0.00,  0.00,   0.00,  0.00,  0.00,  0.00),
]
for f, r_z, abd_z, head_x, antl_y, antr_y, mandl_z, mandr_z in KEYS:
    scene.frame_set(f)
    pb_root.location = (0, 0, r_z)
    pb_root.keyframe_insert(data_path="location", frame=f)
    pb_abd.rotation_euler  = (0, 0, abd_z);  pb_abd.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_head.rotation_euler = (head_x, 0, 0); pb_head.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_ant_l.rotation_euler = (0, antl_y, 0); pb_ant_l.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_ant_r.rotation_euler = (0, antr_y, 0); pb_ant_r.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_mand_l.rotation_euler = (0, 0, mandl_z); pb_mand_l.keyframe_insert(data_path="rotation_euler", frame=f)
    pb_mand_r.rotation_euler = (0, 0, mandr_z); pb_mand_r.keyframe_insert(data_path="rotation_euler", frame=f)

bpy.ops.object.mode_set(mode='OBJECT')
print("Twitch idle keyframes inserted")

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
key.data.energy = 4500; key.data.color = (0.65, 1.0, 0.50)
key.data.spot_size = math.radians(80)
direction = Vector((0, 0, 1.0)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-6, 6, 5))
rim = bpy.context.object
rim.data.energy = 1100; rim.data.color = (1.0, 0.40, 0.85); rim.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(0, -6, 3))
fill = bpy.context.object
fill.data.energy = 500; fill.data.color = (0.45, 0.75, 0.95); fill.data.size = 6

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

cam_hp = add_cam("cam_hp", Vector((0, -5.5, 1.6)), Vector((0, 0, 1.0)), lens=60, dof=5.5)
cam_lp = add_cam("cam_lp", Vector((3.5, -5.5, 1.6)), Vector((3.5, 0, 1.0)), lens=60, dof=5.5)
cam_compare = add_cam("cam_compare", Vector((1.75, -7.5, 2.0)), Vector((1.75, 0, 1.0)), lens=50, dof=8)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.frame_set(1)
scene.camera = cam_hp
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_glitchbug_hp_hero.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_glitchbug_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_glitchbug_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_hp
scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for f in [1, 15, 30, 45]:
    scene.frame_set(f)
    scene.render.filepath = os.path.join(ANIM_DIR, f"v3_r3_glitchbug_twitch_f{f:02d}.png")
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

out_path = os.path.join(EXPORT_DIR, "glitchbug_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_animations=True, export_skins=True,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-04 Glitchbug Sculpted complete ===")
