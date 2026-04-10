"""
Expansion V3 — ROUND 3 — Epic R3-18 — Hero Loot Chest
=====================================================
Sculpted treasure chest. Two single-mesh objects (body + lid) so the
lid can be hinge-rigged. Pipeline:
  - Body: subdivided cube w/ carved plank seam grooves on each face,
    3 horizontal iron banding strips extruded outward, lock plate
    extruded forward, keyhole inset
  - Lid: half-cylinder over the body's top opening (real curved
    silhouette, not a flat plane); plank seams + iron banding
  - Multires 1, smart UV unwrap
  - Iron+wood Pointiness PBR shader baked
  - 2-bone armature (root + lid bone hinging on the back top edge)
  - 60-frame open animation: lid rotates back ~90 degrees
  - GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(318)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_loot_chest.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/renders"
TEX_DIR      = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/baked"
ANIM_DIR     = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/anims"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/exports"
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
bg.inputs["Color"].default_value = (0.04, 0.04, 0.06, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# HELPERS
# ============================================================
def closest_face_normal(bm, target, normal_dir):
    best, best_d = None, 1e9
    for f in bm.faces:
        if f.normal.dot(normal_dir) < 0.5:
            continue
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# ============================================================
# STAGE 1A — CHEST BODY
# ============================================================
print("=== STAGE 1A: Chest body ===")
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.4))
body = bpy.context.object
body.name = "loot_chest_body_hp"
body.scale = (0.9, 0.55, 0.4)  # 1.8m wide, 1.1m deep, 0.8m tall body
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# Subdivide for plank + band placement
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(4):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(body.data)

# === Carve plank seams: every other column on the front + back ===
print("Carving plank seams...")
front_faces = [f for f in bm.faces if f.normal.y < -0.5]
back_faces = [f for f in bm.faces if f.normal.y > 0.5]

# Group front faces by X column
def column_groups(faces):
    cols = {}
    for f in faces:
        x = round(f.calc_center_median().x, 2)
        cols.setdefault(x, []).append(f)
    return cols

front_cols = column_groups(front_faces)
back_cols = column_groups(back_faces)

front_x = sorted(front_cols.keys())
back_x = sorted(back_cols.keys())

# Carve every other column as a recessed seam
seam_targets = []
for i, x in enumerate(front_x):
    if i % 2 == 1:
        seam_targets.extend(front_cols[x])
for i, x in enumerate(back_x):
    if i % 2 == 1:
        seam_targets.extend(back_cols[x])

if seam_targets:
    res = bmesh.ops.inset_individual(bm, faces=seam_targets, thickness=0.015, depth=0.0)
    for f in res.get('faces', []):
        for v in f.verts:
            v.co.y += -0.015 if v.co.y < 0 else 0.015

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Iron banding: 2 horizontal strips extruded outward on front+back ===
print("Extruding iron bands...")
for normal_dir, sign in [(Vector((0, -1, 0)), -1), (Vector((0, 1, 0)), 1)]:
    for z in [0.15, 0.65]:
        # Find 2 adjacent faces in a horizontal strip at this Z
        candidates = []
        for f in bm.faces:
            if f.normal.dot(normal_dir) < 0.5:
                continue
            c = f.calc_center_median()
            if abs(c.z - z) < 0.06:
                candidates.append(f)
        if candidates:
            geom = bmesh.ops.extrude_face_region(bm, geom=candidates)
            new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts:
                v.co.y += sign * 0.025

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Lock plate extruded forward ===
print("Extruding lock plate...")
lock_face = closest_face_normal(bm, Vector((0, -0.55, 0.55)), Vector((0, -1, 0)))
if lock_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[lock_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.y -= 0.04
    new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        # Inset for keyhole
        res = bmesh.ops.inset_individual(bm, faces=[new_faces[0]], thickness=0.02, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else new_faces[0]
        for v in new_f.verts:
            v.co.y += 0.025  # keyhole recess

bm.normal_update()
bm.to_mesh(body.data)
bm.free()
body.data.update()
for poly in body.data.polygons:
    poly.use_smooth = False

bev = body.modifiers.new("Bevel", 'BEVEL'); bev.width = 0.012; bev.segments = 2
# Multires added AFTER UV unwrap (Stage 2.5) to avoid smart_project poll failures

# ============================================================
# STAGE 1B — CHEST LID (curved cylinder, full mesh)
# ============================================================
print("=== STAGE 1B: Chest lid ===")
# Cylinder rotated on Y so caps face left/right; the side surface
# faces up (curved silhouette over the chest body). Bottom half of
# the curved surface tucks inside the body so the user only sees
# the upper half — same visual as a half-cylinder but with a closed
# manifold mesh that survives bake operations.
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.55, depth=1.8, location=(0, 0, 0.85))
lid = bpy.context.object
lid.name = "loot_chest_lid_hp"
lid.rotation_euler = (0, math.radians(90), 0)
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

# Subdivide for detail
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.subdivide()
bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

for poly in lid.data.polygons:
    poly.use_smooth = True

# === Iron bands on the lid (extruded ridge along arc) ===
bm = bmesh.new()
bm.from_mesh(lid.data)
print("Extruding lid bands...")
band_targets = []
for f in bm.faces:
    c = f.calc_center_median()
    # Top arc only (z > 0.85), pick faces near x = -0.45 and x = 0.45
    if c.z > 0.86 and (abs(c.x - 0.45) < 0.07 or abs(c.x + 0.45) < 0.07):
        band_targets.append(f)

if band_targets:
    geom = bmesh.ops.extrude_face_region(bm, geom=band_targets)
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        outward = Vector((0, v.co.y, v.co.z - 0.85))
        if outward.length > 0:
            outward.normalize()
            v.co += outward * 0.025

bm.normal_update()
bm.to_mesh(lid.data)
bm.free()
lid.data.update()

bev2 = lid.modifiers.new("Bevel", 'BEVEL'); bev2.width = 0.010; bev2.segments = 2
# Multires added AFTER UV unwrap (Stage 2.5)

# ============================================================
# STAGE 2 — UV UNWRAP (use cube_project — no viewport context needed)
# ============================================================
print("=== STAGE 2: UV unwrap ===")
for obj in [body, lid]:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    try:
        bpy.ops.uv.cube_project(cube_size=2.0)
    except Exception as e:
        print(f"cube_project failed for {obj.name}: {e}, trying smart_project...")
        try:
            bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
        except Exception as e2:
            print(f"smart_project also failed: {e2}")
    bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 2.5 — Add multires AFTER UV unwrap (avoid poll fails)
# ============================================================
print("=== STAGE 2.5: Add multires ===")
for obj in [body, lid]:
    obj.modifiers.new("Multires", 'MULTIRES')
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 3 — IRON + WOOD PBR SHADER (Pointiness-driven)
# ============================================================
print("=== STAGE 3: Iron + wood shader ===")

def make_chest_shader():
    m = bpy.data.materials.new("v3r3_chest_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.65
    bsdf.inputs["Metallic"].default_value = 0.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (5.0, 4.0, 3.0)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    grain = nodes.new("ShaderNodeTexNoise"); grain.location = (-900, 200)
    grain.inputs["Scale"].default_value = 16.0
    grain.inputs["Detail"].default_value = 10.0
    links.new(mp.outputs["Vector"], grain.inputs["Vector"])

    wood_ramp = nodes.new("ShaderNodeValToRGB"); wood_ramp.location = (-650, 200)
    cr = wood_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.12, 0.06, 0.03, 1)
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.32, 0.18, 0.10, 1)
    el2 = cr.elements.new(0.85)
    el2.color = (0.50, 0.30, 0.16, 1)
    links.new(grain.outputs["Fac"], wood_ramp.inputs["Fac"])

    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-900, -200)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-650, -200)
    pointy_ramp.color_ramp.elements[0].position = 0.55
    pointy_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.70
    pointy_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    iron_color = nodes.new("ShaderNodeRGB"); iron_color.location = (-650, -350)
    iron_color.outputs[0].default_value = (0.20, 0.20, 0.22, 1)

    iron_mix = nodes.new("ShaderNodeMix"); iron_mix.data_type = 'RGBA'; iron_mix.location = (100, 0)
    links.new(pointy_ramp.outputs["Color"], iron_mix.inputs["Factor"])
    links.new(wood_ramp.outputs["Color"], iron_mix.inputs[6])
    links.new(iron_color.outputs[0], iron_mix.inputs[7])
    links.new(iron_mix.outputs[2], bsdf.inputs["Base Color"])

    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (100, -200)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.85, 0.85, 0.85, 1)
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.30, 0.30, 0.30, 1)
    links.new(pointy_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    metal_ramp = nodes.new("ShaderNodeValToRGB"); metal_ramp.location = (100, -400)
    metal_ramp.color_ramp.elements[0].position = 0.0
    metal_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    metal_ramp.color_ramp.elements[1].position = 1.0
    metal_ramp.color_ramp.elements[1].color = (0.95, 0.95, 0.95, 1)
    links.new(pointy_ramp.outputs["Color"], metal_ramp.inputs["Fac"])
    links.new(metal_ramp.outputs["Color"], bsdf.inputs["Metallic"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.40
    links.new(grain.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_body = make_chest_shader()
body.data.materials.clear()
body.data.materials.append(mat_body)

mat_lid = make_chest_shader()
lid.data.materials.clear()
lid.data.materials.append(mat_lid)

# ============================================================
# STAGE 4 — BAKE DIFFUSE (body + lid)
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")

def bake_diffuse(obj, mat, name):
    img = bpy.data.images.new(f"{name}_albedo_bake", width=1024, height=1024)
    img_node = mat.node_tree.nodes.new("ShaderNodeTexImage")
    img_node.location = (1100, 400)
    img_node.image = img
    img_node.select = True
    mat.node_tree.nodes.active = img_node

    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj

    scene.cycles.bake_type = 'DIFFUSE'
    scene.render.bake.use_pass_direct = False
    scene.render.bake.use_pass_indirect = False
    scene.render.bake.use_pass_color = True
    scene.cycles.samples = 32
    print(f"Baking {name} diffuse...")
    try:
        bpy.ops.object.bake(type='DIFFUSE')
        path = os.path.join(TEX_DIR, f"{name}_albedo_1024.png")
        img.filepath_raw = path
        img.file_format = 'PNG'
        img.save()
        print(f"Baked: {path}")
    except Exception as e:
        print(f"Bake failed: {e}")
    return img

body_albedo = bake_diffuse(body, mat_body, "loot_chest_body")
lid_albedo = bake_diffuse(lid, mat_lid, "loot_chest_lid")

# ============================================================
# STAGE 5 — RETOPO LOW-POLY (both)
# ============================================================
print("=== STAGE 5: Retopo low-poly ===")

def make_low_poly(obj, name):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.duplicate()
    lp = bpy.context.object
    lp.name = f"{name}_lp"
    for mod in list(lp.modifiers):
        lp.modifiers.remove(mod)
    dec = lp.modifiers.new("Decimate", 'DECIMATE')
    dec.ratio = 0.25
    bpy.ops.object.modifier_apply(modifier="Decimate")
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')
    print(f"{name}_lp: {len(lp.data.polygons)} faces")
    return lp

body_lp = make_low_poly(body, "loot_chest_body")
lid_lp = make_low_poly(lid, "loot_chest_lid")

# ============================================================
# STAGE 6 — NORMAL BAKES
# ============================================================
print("=== STAGE 6: Normal bakes high → low ===")

def bake_normal(hp, lp, alb_img, name):
    nrm = bpy.data.images.new(f"{name}_normal_bake", width=1024, height=1024,
                               alpha=False, float_buffer=False)
    nrm.colorspace_settings.name = 'Non-Color'

    mat_lp_baked = bpy.data.materials.new(f"v3r3_{name}_baked")
    mat_lp_baked.use_nodes = True
    nt = mat_lp_baked.node_tree
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bs = nt.nodes.new("ShaderNodeBsdfPrincipled"); bs.location = (900, 0)
    nt.links.new(bs.outputs[0], out.inputs[0])
    img_a = nt.nodes.new("ShaderNodeTexImage"); img_a.location = (200, 200)
    img_a.image = alb_img
    nt.links.new(img_a.outputs["Color"], bs.inputs["Base Color"])
    img_n = nt.nodes.new("ShaderNodeTexImage"); img_n.location = (200, -200)
    img_n.image = nrm
    img_n.image.colorspace_settings.name = 'Non-Color'
    nm = nt.nodes.new("ShaderNodeNormalMap"); nm.location = (550, -200)
    nt.links.new(img_n.outputs["Color"], nm.inputs["Color"])
    nt.links.new(nm.outputs["Normal"], bs.inputs["Normal"])
    img_n.select = True
    nt.nodes.active = img_n

    lp.data.materials.clear()
    lp.data.materials.append(mat_lp_baked)

    bpy.ops.object.select_all(action='DESELECT')
    hp.select_set(True)
    lp.select_set(True)
    bpy.context.view_layer.objects.active = lp

    scene.cycles.bake_type = 'NORMAL'
    scene.render.bake.use_selected_to_active = True
    scene.render.bake.cage_extrusion = 0.04
    scene.render.bake.max_ray_distance = 0.20
    scene.cycles.samples = 16
    try:
        bpy.ops.object.bake(type='NORMAL')
        path = os.path.join(TEX_DIR, f"{name}_normal_1024.png")
        nrm.filepath_raw = path
        nrm.file_format = 'PNG'
        nrm.save()
        print(f"Baked normal: {path}")
    except Exception as e:
        print(f"Normal bake failed: {e}")
        import traceback; traceback.print_exc()
    scene.render.bake.use_selected_to_active = False
    scene.cycles.samples = 96
    return mat_lp_baked

bake_normal(body, body_lp, body_albedo, "loot_chest_body")
bake_normal(lid, lid_lp, lid_albedo, "loot_chest_lid")

# Reposition low-polys for compare camera
body_lp.location = (3.5, 0, 0.4)
lid_lp.location = (3.5, 0, 0.85)

# ============================================================
# STAGE 7 — ARMATURE: 2-bone hinge rig
# ============================================================
print("=== STAGE 7: Armature ===")
bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "loot_chest_armature"
arm.show_in_front = True

bpy.ops.object.mode_set(mode='EDIT')
ed_bones = arm.data.edit_bones
ed_bones.remove(ed_bones["Bone"])

# Hinge axis: back-top edge of body (y = +0.55, z = 0.80)
root = ed_bones.new("root")
root.head = Vector((0, 0, 0))
root.tail = Vector((0, 0, 0.4))

lid_b = ed_bones.new("lid")
lid_b.head = Vector((0, 0.55, 0.85))
lid_b.tail = Vector((0, 0.55, 1.40))
lid_b.parent = root
lid_b.use_connect = False

bpy.ops.object.mode_set(mode='OBJECT')

print("Parenting lid w/ automatic weights...")
bpy.ops.object.select_all(action='DESELECT')
lid.select_set(True)
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
try:
    bpy.ops.object.parent_set(type='ARMATURE_AUTO')
    print("Auto-weights succeeded")
except Exception as e:
    print(f"Auto-weights failed: {e}")
    bpy.ops.object.parent_set(type='ARMATURE')

# ============================================================
# STAGE 8 — OPEN ANIMATION
# ============================================================
print("=== STAGE 8: Open animation ===")
scene.frame_start = 1
scene.frame_end = 60
scene.render.fps = 30

bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

pb_lid = arm.pose.bones["lid"]
pb_lid.rotation_mode = 'XYZ'

# Open: rotate lid back ~95 degrees (X axis) over 60 frames
KEYS = [
    (1,  0.0),
    (15, -0.30),
    (30, -0.85),
    (45, -1.40),
    (60, -1.65),
]
for f, rx in KEYS:
    scene.frame_set(f)
    pb_lid.rotation_euler = (rx, 0, 0)
    pb_lid.keyframe_insert(data_path="rotation_euler", frame=f)

bpy.ops.object.mode_set(mode='OBJECT')
print("Open keyframes inserted")

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

bpy.ops.object.light_add(type='SPOT', location=(2, -5, 4))
key = bpy.context.object
key.data.energy = 2200; key.data.color = (1.0, 0.85, 0.55)
key.data.spot_size = math.radians(80)
direction = Vector((0, 0, 0.5)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-5, 5, 4))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.45, 0.55, 0.85); fill.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(0, -5, 5))
rim = bpy.context.object
rim.data.energy = 800; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 4

bpy.ops.mesh.primitive_plane_add(size=12, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.06, 0.05, 0.04, 1)
fbsdf.inputs["Roughness"].default_value = 0.85
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

cam_hp = add_cam("cam_hp", Vector((0, -3.5, 1.5)), Vector((0, 0, 0.6)), lens=50, dof=4)
cam_lp = add_cam("cam_lp", Vector((3.5, -3.5, 1.5)), Vector((3.5, 0, 0.6)), lens=50, dof=4)
cam_compare = add_cam("cam_compare", Vector((1.75, -5, 2.0)), Vector((1.75, 0, 0.6)), lens=42, dof=6)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render at frame 30 (lid mid-open) for hero shots
scene.frame_set(30)
scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_loot_chest_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_loot_chest_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_loot_chest_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Anim playblast
scene.camera = cam_hp
scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for f in [1, 15, 30, 45]:
    scene.frame_set(f)
    scene.render.filepath = os.path.join(ANIM_DIR, f"v3_r3_loot_chest_open_f{f:02d}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered anim frame: {scene.render.filepath}")

# ============================================================
# STAGE 10 — GLB EXPORT
# ============================================================
print("=== STAGE 10: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
body_lp.select_set(True)
lid_lp.select_set(True)
arm.select_set(True)
bpy.context.view_layer.objects.active = arm

out_path = os.path.join(EXPORT_DIR, "loot_chest_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_animations=True, export_skins=True,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-18 Loot Chest complete ===")
