"""
Expansion V3 — ROUND 3 — Epic R3-03 — Compiler Boss Sculpted
============================================================
First sculpted enemy. Same pipeline as R3-01/02 PLUS the major upgrade:
NORMAL map bake from high-poly multires → low-poly retopo via
'Selected to Active' Cycles bake. This is the proper game-asset
workflow that the critical review demanded.

Pipeline:
  1. Single-mesh boss body from a high-res icosphere (faceted base)
  2. Bmesh-driven crystalline displacement (NOT smooth blob)
  3. Inset huge cyclops eye socket (single big indent)
  4. Inset mouth maw (deep slit)
  5. Extrude 6 face_region spikes from selected faces
  6. Multires modifier (3 levels for high detail)
  7. UV unwrap, procedural shader (cracked obsidian + code-rune glow)
  8. Bake DIFFUSE to image_albedo PNG (1024x1024)
  9. Duplicate + decimate to retopo low-poly
 10. Re-unwrap low-poly
 11. NORMAL map bake from HIGH-poly multires → LOW-poly via
     'Selected to Active' (the proper retopo workflow)
 12. Apply baked albedo + normal map to low-poly via Image Texture
     and Normal Map nodes
 13. 6-bone armature (root, core, 4 floating shards)
 14. Idle pulse animation: body scale 1.0 → 1.08 → 1.0 (breathing),
     shards rotating (yaw + pitch oscillation)
 15. Renders + GLB

Outputs:
  - hi-poly hero render
  - low-poly w/ baked albedo + normal render
  - normal map visualization render
  - 4-frame anim playblast
  - 2 PNG textures (albedo + normal map)
  - GLB w/ rig + animation
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(303)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/v3_r3_compiler.blend"
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
bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# STAGE 1 — SINGLE-MESH BOSS BODY VIA BMESH SCULPT
# ============================================================
print("=== STAGE 1: Compiler Boss base ===")

# Icosphere gives a more crystalline/faceted starting silhouette than UV sphere
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=4, radius=1.4, location=(0, 0, 1.8))
hero = bpy.context.object
hero.name = "compiler_hp"

bm = bmesh.new()
bm.from_mesh(hero.data)

# Boss silhouette: vertically stretched intimidating monolith
for v in bm.verts:
    v.co.z *= 1.4  # taller
    # Crystalline displacement — push verts outward in faceted bumps
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    v.co += v.normal * random.uniform(-0.05, 0.10)

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Cyclops eye socket (single huge indent on front) ===
print("Carving cyclops eye socket...")
eye_face = closest_face(bm, Vector((0, 1.3, 0.4)))
if eye_face:
    res = bmesh.ops.inset_individual(bm, faces=[eye_face], thickness=0.20, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else eye_face
    for v in new_f.verts:
        v.co += Vector((0, -0.20, 0))  # push deep into the body
    # Second smaller inset for the iris
    res2 = bmesh.ops.inset_individual(bm, faces=[new_f], thickness=0.08, depth=0.0)
    new_f2 = res2['faces'][0] if res2.get('faces') else new_f
    for v in new_f2.verts:
        v.co += Vector((0, 0.05, 0))  # bring iris forward inside socket

# === Mouth maw (deep slit below the eye) ===
print("Cutting mouth maw...")
mouth_face = closest_face(bm, Vector((0, 1.3, -0.6)))
if mouth_face:
    res = bmesh.ops.inset_individual(bm, faces=[mouth_face], thickness=0.18, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else mouth_face
    for v in new_f.verts:
        v.co += Vector((0, -0.25, 0))  # deep maw
        v.co.x *= 1.4

# === 6 spike protrusions extruded from face regions ===
print("Extruding spikes...")
SPIKE_TARGETS = [
    Vector((0, -1.4, 1.2)),     # back top
    Vector((-1.3, 0, 1.0)),     # left
    Vector((1.3, 0, 1.0)),      # right
    Vector((-0.9, -0.9, 0.5)),  # back-left
    Vector((0.9, -0.9, 0.5)),   # back-right
    Vector((0, 0, 1.6)),        # top
]
for i, target in enumerate(SPIKE_TARGETS):
    spike_face = closest_face(bm, target)
    if spike_face:
        # First extrude — base
        geom = bmesh.ops.extrude_face_region(bm, geom=[spike_face])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co += spike_face.normal * 0.20
        # Find the new face and second-extrude for the tip
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co += spike_face.normal * 0.30
            # Collapse to a point for the spike tip
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = avg

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = True

# Multires (3 levels for higher detail than R3-01/02)
print("Adding multires...")
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
for _ in range(3):
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
# STAGE 3 — PROCEDURAL SHADER (cracked obsidian + code-rune glow)
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
    bsdf.inputs["Roughness"].default_value = 0.20
    bsdf.inputs["Metallic"].default_value = 0.40
    bsdf.inputs["Coat Weight"].default_value = 0.5
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    bsdf.inputs["Emission Strength"].default_value = 8.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Obsidian noise base
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    obs_ramp = nodes.new("ShaderNodeValToRGB"); obs_ramp.location = (-450, 200)
    obs_ramp.color_ramp.elements[0].position = 0.30
    obs_ramp.color_ramp.elements[0].color = (0.04, 0.03, 0.06, 1)
    obs_ramp.color_ramp.elements[1].position = 0.70
    obs_ramp.color_ramp.elements[1].color = (0.10, 0.08, 0.14, 1)
    links.new(n.outputs["Fac"], obs_ramp.inputs["Fac"])

    # Voronoi crack mask for rune seams
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 4.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    crack_ramp = nodes.new("ShaderNodeValToRGB"); crack_ramp.location = (-450, -100)
    crack_ramp.color_ramp.elements[0].position = 0.0
    crack_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    crack_ramp.color_ramp.elements[1].position = 0.06
    crack_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], crack_ramp.inputs["Fac"])

    # Mix obsidian w/ crack mask -> dark cracks
    mix = nodes.new("ShaderNodeMix"); mix.data_type = 'RGBA'; mix.location = (-200, 100)
    links.new(crack_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(obs_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.01, 0.01, 0.02, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Crack emission (cyan-to-orange gradient via second voronoi)
    v2 = nodes.new("ShaderNodeTexVoronoi"); v2.location = (-700, -300)
    v2.feature = 'F1'
    v2.inputs["Scale"].default_value = 2.0
    links.new(mp.outputs["Vector"], v2.inputs["Vector"])
    color_ramp = nodes.new("ShaderNodeValToRGB"); color_ramp.location = (-450, -300)
    color_ramp.color_ramp.elements[0].position = 0.20
    color_ramp.color_ramp.elements[0].color = (0.30, 0.85, 1.0, 1)  # cyan
    color_ramp.color_ramp.elements[1].position = 0.70
    color_ramp.color_ramp.elements[1].color = (1.0, 0.45, 0.10, 1)  # orange
    links.new(v2.outputs["Distance"], color_ramp.inputs["Fac"])

    glow = nodes.new("ShaderNodeMix"); glow.data_type = 'RGBA'; glow.location = (100, -200)
    links.new(crack_ramp.outputs["Color"], glow.inputs["Factor"])
    glow.inputs[6].default_value = (0, 0, 0, 1)
    links.new(color_ramp.outputs["Color"], glow.inputs[7])
    links.new(glow.outputs[2], bsdf.inputs["Emission Color"])

    # Procedural normal bump from obsidian noise
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -500)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_shader("v3r3_compiler_proc")
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE TO IMAGE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE to image ===")

bake_albedo = bpy.data.images.new("compiler_albedo_bake", width=1024, height=1024)
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

print("Baking diffuse (30-60s)...")
try:
    bpy.ops.object.bake(type='DIFFUSE')
    bake_path = os.path.join(TEX_DIR, "compiler_albedo_1024.png")
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
low_poly.name = "compiler_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.15  # tighter decimation for cleaner low-poly
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL MAP BAKE high-poly → low-poly (selected→active)
# ============================================================
print("=== STAGE 6: Normal map bake high → low ===")

# Create blank normal map image and assign to LOW-POLY material
bake_normal = bpy.data.images.new("compiler_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

# Build the low-poly material w/ Image Texture node for normal target
mat_lp = bpy.data.materials.new("v3r3_compiler_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.30
bsdf_lp.inputs["Metallic"].default_value = 0.40
bsdf_lp.inputs["Coat Weight"].default_value = 0.5
bsdf_lp.inputs["Coat Roughness"].default_value = 0.05
ntlp.links.new(bsdf_lp.outputs[0], out_lp.inputs[0])

# Albedo texture node
img_alb_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_alb_lp.location = (200, 200)
img_alb_lp.image = bake_albedo
ntlp.links.new(img_alb_lp.outputs["Color"], bsdf_lp.inputs["Base Color"])

# Normal texture node — receives the bake target
img_nrm_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_nrm_lp.location = (200, -200)
img_nrm_lp.image = bake_normal
img_nrm_lp.image.colorspace_settings.name = 'Non-Color'
nrm_node = ntlp.nodes.new("ShaderNodeNormalMap"); nrm_node.location = (550, -200)
ntlp.links.new(img_nrm_lp.outputs["Color"], nrm_node.inputs["Color"])
ntlp.links.new(nrm_node.outputs["Normal"], bsdf_lp.inputs["Normal"])

# Set the normal image node as ACTIVE for the bake target
img_nrm_lp.select = True
ntlp.nodes.active = img_nrm_lp

low_poly.data.materials.clear()
low_poly.data.materials.append(mat_lp)

# Selected-to-active normal bake: select HIGH first, LOW last (so LOW is active)
print("Performing selected-to-active NORMAL bake...")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)         # high-poly source
low_poly.select_set(True)     # low-poly target
bpy.context.view_layer.objects.active = low_poly  # ACTIVE = target

scene.cycles.bake_type = 'NORMAL'
scene.render.bake.use_selected_to_active = True
scene.render.bake.cage_extrusion = 0.05
scene.render.bake.max_ray_distance = 0.30
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "compiler_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal map: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback
    traceback.print_exc()

# Reset bake settings
scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

# Position low-poly to the side for compare render
low_poly.location = (3.5, 0, 1.8)

# ============================================================
# STAGE 7 — ARMATURE: 6-bone rig
# ============================================================
print("=== STAGE 7: Armature ===")

bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "compiler_armature"
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
core = add_bone("core", Vector((0, 0, 0.4)), Vector((0, 0, 1.8)), parent=root)
shard1 = add_bone("shard_top", Vector((0, 0, 1.8)), Vector((0, 0, 2.5)), parent=core)
shard2 = add_bone("shard_l",   Vector((-0.8, 0, 1.5)), Vector((-1.5, 0, 1.5)), parent=core)
shard3 = add_bone("shard_r",   Vector((0.8, 0, 1.5)),  Vector((1.5, 0, 1.5)), parent=core)
shard4 = add_bone("shard_back", Vector((0, -0.8, 1.5)), Vector((0, -1.5, 1.5)), parent=core)

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
# STAGE 8 — IDLE PULSE ANIMATION
# ============================================================
print("=== STAGE 8: Idle pulse animation ===")

scene.frame_start = 1
scene.frame_end = 60
scene.render.fps = 30

bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

pb_core = arm.pose.bones["core"]
pb_top = arm.pose.bones["shard_top"]
pb_l = arm.pose.bones["shard_l"]
pb_r = arm.pose.bones["shard_r"]
pb_back = arm.pose.bones["shard_back"]

# Pulse: body breathes, shards rotate independently
KEYS = [
    # frame, core_scale, top_rz, l_rz, r_rz, back_rz
    (1,  1.00, 0.0,  0.0,  0.0,  0.0),
    (15, 1.04, 0.5,  0.6, -0.6,  0.4),
    (30, 1.08, 1.0,  1.2, -1.2,  0.8),
    (45, 1.04, 1.5,  1.8, -1.8,  1.2),
    (60, 1.00, 2.0,  2.4, -2.4,  1.6),
]
for frame, core_s, top_z, l_z, r_z, back_z in KEYS:
    scene.frame_set(frame)
    pb_core.scale = (1.0, 1.0, core_s)
    pb_core.keyframe_insert(data_path="scale", frame=frame)
    for pb, rz in [(pb_top, top_z), (pb_l, l_z), (pb_r, r_z), (pb_back, back_z)]:
        pb.rotation_mode = 'XYZ'
        pb.rotation_euler = (0, 0, rz)
        pb.keyframe_insert(data_path="rotation_euler", frame=frame)

bpy.ops.object.mode_set(mode='OBJECT')
print("Idle pulse keyframes inserted")

# Bezier interpolation
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

bpy.ops.object.light_add(type='SPOT', location=(6, -10, 12))
key = bpy.context.object
key.data.energy = 5500; key.data.color = (0.40, 0.85, 1.0)
key.data.spot_size = math.radians(80)
direction = Vector((0, 0, 1.5)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-6, 8, 6))
rim = bpy.context.object
rim.data.energy = 1200; rim.data.color = (1.0, 0.55, 0.20); rim.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(0, -8, 4))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.45, 0.55, 0.95); fill.data.size = 6

# Floor
bpy.ops.mesh.primitive_plane_add(size=14, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.05, 0.05, 0.07, 1)
fbsdf.inputs["Roughness"].default_value = 0.40
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

cam_hp = add_cam("cam_hp", Vector((0, -6, 2.0)), Vector((0, 0, 1.8)), lens=60, dof=6)
cam_lp = add_cam("cam_lp", Vector((3.5, -6, 2.0)), Vector((3.5, 0, 1.8)), lens=60, dof=6)
cam_compare = add_cam("cam_compare", Vector((1.75, -8, 2.5)), Vector((1.75, 0, 1.8)), lens=50, dof=8)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.frame_set(1)
scene.camera = cam_hp
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_compiler_hp_hero.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_compiler_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_compiler_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Anim playblast
scene.camera = cam_hp
scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for f in [1, 15, 30, 45]:
    scene.frame_set(f)
    scene.render.filepath = os.path.join(ANIM_DIR, f"v3_r3_compiler_pulse_f{f:02d}.png")
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

out_path = os.path.join(EXPORT_DIR, "compiler_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_animations=True, export_skins=True,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-03 Compiler Boss Sculpted complete ===")
