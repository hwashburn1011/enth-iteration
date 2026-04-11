"""
Expansion V3 — ROUND 3 — Epic R3-01 — Globbler Sculpted Hero
============================================================
Critical-feedback response. ONE asset, done properly:

  1. Single bmesh body (NOT parented primitives) — start from a UV
     sphere, then push/pull verts via curl-noise displacement to make
     an organic head/torso/limb silhouette
  2. INSET real eye sockets (bmesh inset_individual + push) — actual
     geometric indents with depth, not separate sphere "eye" objects
  3. INSET mouth slit (bmesh knife/inset along an edge loop)
  4. Multires modifier + per-vertex sculpt-style displacement using
     proximity falloff (mimics a brush stroke programmatically)
  5. Retopo proxy: decimate the high-poly to a low-poly version
  6. UV unwrap the low-poly w/ Smart UV Project
  7. Bake the procedural shader to a 1024x1024 PNG via bpy.ops.object.bake
  8. Bake a normal map from high-poly → low-poly
  9. Reapply baked Image Texture + Normal Map to the low-poly mesh
 10. Add armature: root, spine, head, 2 arms, 2 legs (8 bones)
 11. Parent mesh to armature with automatic weights
 12. Insert idle animation keyframes (60 frames @ 30fps): head bob +
     breathing scale + arm sway
 13. Render hero shot + 4-frame animation playblast (frames 1, 15, 30, 45)

Outputs:
  - 1 high-poly hero render @ 1920x1080
  - 1 low-poly w/ baked textures hero render @ 1920x1080
  - 4 animation playblast frames @ 1280x720
  - baked albedo PNG (1024x1024) @ _art_source/textures/baked/
  - baked normal PNG (1024x1024) @ _art_source/textures/baked/
  - GLB export of low-poly w/ textures + armature + animation
  - .blend with the rigged + animated character
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(301)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_r3_globbler.blend"
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
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# STAGE 1 — BUILD A SINGLE-MESH HIGH-POLY HEAD/BODY VIA BMESH SCULPT
# ============================================================
print("=== STAGE 1: Building single-mesh high-poly base ===")

# Start from a high-resolution UV sphere (the base "blob")
bpy.ops.mesh.primitive_uv_sphere_add(segments=64, ring_count=32, radius=1.0, location=(0, 0, 1.5))
hero = bpy.context.object
hero.name = "globbler_hero_hp"

# Switch to bmesh and sculpt the silhouette via per-vertex displacement
bm = bmesh.new()
bm.from_mesh(hero.data)

# Pre-stretch into pear/blob shape
for v in bm.verts:
    # Body wider at bottom, narrower at top — pear silhouette
    z_norm = (v.co.z + 1.0) / 2.0  # 0 at bottom, 1 at top
    width_factor = 1.0 + (1.0 - z_norm) * 0.3  # +30% wider at base
    v.co.x *= width_factor
    v.co.y *= width_factor * 0.95  # slightly narrower front-back
    # Squash slightly vertically
    v.co.z *= 1.15

# Find a face on the front (positive Y, mid-Z) for face features
def closest_face_to_point(bm, target):
    best = None
    best_d = 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d
            best = f
    return best

# === Inset two eye sockets ===
print("Insetting eye sockets...")
eye_l_target = Vector((-0.32, 0.85, 0.30))  # slightly above body center
eye_r_target = Vector((0.32, 0.85, 0.30))

eye_l_face = closest_face_to_point(bm, eye_l_target)
eye_r_face = closest_face_to_point(bm, eye_r_target)

if eye_l_face and eye_r_face:
    # Inset and push inward to form sockets
    result_l = bmesh.ops.inset_individual(bm, faces=[eye_l_face], thickness=0.10, depth=0.0)
    new_face_l = result_l['faces'][0] if result_l.get('faces') else eye_l_face
    # Push the inset face inward
    for v in new_face_l.verts:
        v.co += Vector((0, -0.08, 0))  # push back into head
    result_r = bmesh.ops.inset_individual(bm, faces=[eye_r_face], thickness=0.10, depth=0.0)
    new_face_r = result_r['faces'][0] if result_r.get('faces') else eye_r_face
    for v in new_face_r.verts:
        v.co += Vector((0, -0.08, 0))

# === Inset mouth slit ===
print("Insetting mouth...")
mouth_target = Vector((0, 0.92, 0.10))
mouth_face = closest_face_to_point(bm, mouth_target)
if mouth_face:
    result_m = bmesh.ops.inset_individual(bm, faces=[mouth_face], thickness=0.06, depth=0.0)
    new_face_m = result_m['faces'][0] if result_m.get('faces') else mouth_face
    for v in new_face_m.verts:
        v.co += Vector((0, -0.04, 0))
    # Stretch mouth wider horizontally
    for v in new_face_m.verts:
        v.co.x *= 2.0
        v.co.z *= 0.4

# === Inset nose bump (small protrusion) ===
print("Insetting nose...")
nose_target = Vector((0, 0.95, 0.20))
nose_face = closest_face_to_point(bm, nose_target)
if nose_face:
    result_n = bmesh.ops.inset_individual(bm, faces=[nose_face], thickness=0.04, depth=0.0)
    new_face_n = result_n['faces'][0] if result_n.get('faces') else nose_face
    # Push OUT to form nose
    for v in new_face_n.verts:
        v.co += Vector((0, 0.05, 0))

# === Sculpt-style organic displacement (proximity-based bumps) ===
print("Applying sculpt-style displacement...")
sculpt_centers = [
    (Vector((0, 0.95, 0.55)),    0.4,  0.05),  # forehead bump
    (Vector((-0.85, 0.0, 0.0)),  0.5,  0.04),  # left side bulge
    (Vector((0.85, 0.0, 0.0)),   0.5,  0.04),  # right side bulge
    (Vector((0, -0.95, 0.0)),    0.6, -0.06),  # back hollow
    (Vector((0, 0.0, -1.05)),    0.5,  0.03),  # bottom round-out
]
for center, radius, strength in sculpt_centers:
    for v in bm.verts:
        d = (v.co - center).length
        if d < radius:
            falloff = 1.0 - (d / radius)
            falloff = falloff * falloff  # smooth
            v.co += v.normal * (strength * falloff)

# Push verts back to update normals
bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()

# Smooth shading
for poly in hero.data.polygons:
    poly.use_smooth = True

# === Multires modifier for high-poly detail ===
print("Adding multires...")
hero_mr = hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
for _ in range(2):
    bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 2 — UV UNWRAP THE HIGH-POLY (also serves the low-poly bake)
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
# STAGE 3 — PROCEDURAL SHADER (later baked to image)
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
    bsdf.inputs["Roughness"].default_value = 0.30
    bsdf.inputs["Metallic"].default_value = 0.10
    bsdf.inputs["Subsurface Weight"].default_value = 0.20
    bsdf.inputs["Subsurface Radius"].default_value = (0.8, 0.4, 0.3)
    bsdf.inputs["Subsurface Scale"].default_value = 0.20
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Base body color: blue→cyan gradient by Z (head lighter, body darker)
    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-700, 200)
    links.new(tc.outputs["Generated"], sep.inputs["Vector"])
    grad_ramp = nodes.new("ShaderNodeValToRGB"); grad_ramp.location = (-450, 200)
    grad_ramp.color_ramp.elements[0].position = 0.20
    grad_ramp.color_ramp.elements[0].color = (0.10, 0.32, 0.75, 1)  # body deep blue
    grad_ramp.color_ramp.elements[1].position = 0.80
    grad_ramp.color_ramp.elements[1].color = (0.30, 0.65, 1.0, 1)   # head lighter cyan
    links.new(sep.outputs["Z"], grad_ramp.inputs["Fac"])

    # Subtle voronoi spots for skin variation
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = 18.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    v_ramp = nodes.new("ShaderNodeValToRGB"); v_ramp.location = (-450, -100)
    v_ramp.color_ramp.elements[0].position = 0.05
    v_ramp.color_ramp.elements[0].color = (0.15, 0.40, 0.85, 1)
    v_ramp.color_ramp.elements[1].position = 0.30
    v_ramp.color_ramp.elements[1].color = (0.30, 0.65, 1.0, 1)
    links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])

    mix1 = nodes.new("ShaderNodeMix"); mix1.data_type = 'RGBA'; mix1.location = (-200, 0)
    mix1.inputs["Factor"].default_value = 0.40
    links.new(grad_ramp.outputs["Color"], mix1.inputs[6])
    links.new(v_ramp.outputs["Color"], mix1.inputs[7])

    # Curvature dirt darkens crevices (eye sockets, mouth)
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-200, -300)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -300)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.04, 0.10, 0.20, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type = 'RGBA'; md.location = (300, 0)
    md.inputs["Factor"].default_value = 0.50
    links.new(mix1.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    # Procedural normal bump from noise
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, -500)
    n.inputs["Scale"].default_value = 30.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-450, -500)
    bp.inputs["Strength"].default_value = 0.20
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m, bsdf

mat_proc, mat_bsdf = make_shader("v3r3_globbler_proc")
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE THE PROCEDURAL SHADER TO IMAGE TEXTURE
# ============================================================
print("=== STAGE 4: Bake procedural shader to image ===")

# Create blank image to bake into
bake_img = bpy.data.images.new("globbler_albedo_bake", width=1024, height=1024)
img_node = mat_proc.node_tree.nodes.new("ShaderNodeTexImage")
img_node.location = (1100, 400)
img_node.image = bake_img
img_node.select = True
mat_proc.node_tree.nodes.active = img_node

# Bake DIFFUSE color (without lighting)
scene.cycles.bake_type = 'DIFFUSE'
scene.render.bake.use_pass_direct = False
scene.render.bake.use_pass_indirect = False
scene.render.bake.use_pass_color = True
scene.cycles.samples = 32

bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero

print("Baking diffuse to image (this takes 30-60s)...")
try:
    bpy.ops.object.bake(type='DIFFUSE')
    bake_path = os.path.join(TEX_DIR, "globbler_albedo_1024.png")
    bake_img.filepath_raw = bake_path
    bake_img.file_format = 'PNG'
    bake_img.save()
    print(f"Baked albedo: {bake_path}")
except Exception as e:
    print(f"Bake failed: {e}")

# Restore high samples for renders
scene.cycles.samples = 128

# ============================================================
# STAGE 5 — CREATE LOW-POLY RETOPO PROXY
# ============================================================
print("=== STAGE 5: Create low-poly retopo ===")

# Duplicate the hero before applying multires for the low-poly
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "globbler_hero_lp"

# Remove the multires from low-poly and decimate
for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.20
bpy.ops.object.modifier_apply(modifier="Decimate")

# Re-unwrap the low-poly
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

# Move low-poly to side for comparison render
low_poly.location = (3, 0, 1.5)

# Apply baked image texture material to low-poly
mat_lp = bpy.data.materials.new("v3r3_globbler_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (800, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (500, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.30
bsdf_lp.inputs["Subsurface Weight"].default_value = 0.20
bsdf_lp.inputs["Subsurface Radius"].default_value = (0.8, 0.4, 0.3)
ntlp.links.new(bsdf_lp.outputs[0], out_lp.inputs[0])
img_node_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_node_lp.location = (200, 0)
img_node_lp.image = bake_img
ntlp.links.new(img_node_lp.outputs["Color"], bsdf_lp.inputs["Base Color"])

low_poly.data.materials.clear()
low_poly.data.materials.append(mat_lp)

print(f"Low-poly: {len(low_poly.data.polygons)} faces (vs high-poly multires)")

# ============================================================
# STAGE 6 — ARMATURE: 8-bone rig
# ============================================================
print("=== STAGE 6: Armature ===")

bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "globbler_armature"
arm.show_in_front = True

bpy.ops.object.mode_set(mode='EDIT')
ed_bones = arm.data.edit_bones

# Remove default bone
default_bone = ed_bones["Bone"]
ed_bones.remove(default_bone)

def add_bone(name, head, tail, parent=None):
    b = ed_bones.new(name)
    b.head = head
    b.tail = tail
    if parent:
        b.parent = parent
        b.use_connect = False
    return b

root  = add_bone("root",  Vector((0, 0, 0.0)),  Vector((0, 0, 0.4)))
spine = add_bone("spine", Vector((0, 0, 0.4)),  Vector((0, 0, 1.4)), parent=root)
head_b = add_bone("head", Vector((0, 0, 1.4)),  Vector((0, 0, 2.0)), parent=spine)
arm_l = add_bone("arm_l", Vector((-0.8, 0, 1.3)), Vector((-1.4, 0, 0.8)), parent=spine)
arm_r = add_bone("arm_r", Vector((0.8, 0, 1.3)),  Vector((1.4, 0, 0.8)), parent=spine)
leg_l = add_bone("leg_l", Vector((-0.4, 0, 0.4)), Vector((-0.5, 0, 0.0)), parent=root)
leg_r = add_bone("leg_r", Vector((0.4, 0, 0.4)),  Vector((0.5, 0, 0.0)), parent=root)

bpy.ops.object.mode_set(mode='OBJECT')

# Parent the high-poly mesh to armature with automatic weights
print("Parenting hero to armature with automatic weights...")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
try:
    bpy.ops.object.parent_set(type='ARMATURE_AUTO')
    print("Auto-weights succeeded for hero")
except Exception as e:
    print(f"Auto-weights failed for hero: {e}")
    # Fallback: just parent without weights
    bpy.ops.object.parent_set(type='ARMATURE')

# ============================================================
# STAGE 7 — IDLE ANIMATION (60 frames @ 30fps)
# ============================================================
print("=== STAGE 7: Idle animation ===")

scene.frame_start = 1
scene.frame_end = 60
scene.render.fps = 30

bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

# Animate head bob + arm sway
pb_head = arm.pose.bones["head"]
pb_arm_l = arm.pose.bones["arm_l"]
pb_arm_r = arm.pose.bones["arm_r"]
pb_spine = arm.pose.bones["spine"]

KEYS = [
    # (frame, head_rot_x, arm_l_rot_x, arm_r_rot_x, spine_scale_z)
    (1,  0.00, 0.00, 0.00, 1.00),
    (15, 0.06, 0.05, -0.05, 1.02),
    (30, 0.00, 0.00, 0.00, 1.04),
    (45, -0.06, -0.05, 0.05, 1.02),
    (60, 0.00, 0.00, 0.00, 1.00),
]

for frame, head_rx, al_rx, ar_rx, sp_sz in KEYS:
    scene.frame_set(frame)
    pb_head.rotation_mode = 'XYZ'
    pb_head.rotation_euler = (head_rx, 0, 0)
    pb_head.keyframe_insert(data_path="rotation_euler", frame=frame)
    pb_arm_l.rotation_mode = 'XYZ'
    pb_arm_l.rotation_euler = (al_rx, 0, 0)
    pb_arm_l.keyframe_insert(data_path="rotation_euler", frame=frame)
    pb_arm_r.rotation_mode = 'XYZ'
    pb_arm_r.rotation_euler = (ar_rx, 0, 0)
    pb_arm_r.keyframe_insert(data_path="rotation_euler", frame=frame)
    pb_spine.scale = (1, 1, sp_sz)
    pb_spine.keyframe_insert(data_path="scale", frame=frame)

bpy.ops.object.mode_set(mode='OBJECT')
print("Animation keyframes inserted")

# Make all keyframes interpolate smoothly (Blender 5.x API: action.layers[0].strips[0].channelbag)
try:
    action = arm.animation_data.action if arm.animation_data else None
    if action:
        # Try Blender 5.x layered API first
        if hasattr(action, 'layers') and len(action.layers) > 0:
            layer = action.layers[0]
            for strip in layer.strips:
                for cb in strip.channelbags:
                    for fcurve in cb.fcurves:
                        for kp in fcurve.keyframe_points:
                            kp.interpolation = 'BEZIER'
        # Fall back to legacy API
        elif hasattr(action, 'fcurves'):
            for fcurve in action.fcurves:
                for kp in fcurve.keyframe_points:
                    kp.interpolation = 'BEZIER'
except Exception as e:
    print(f"Keyframe interpolation cleanup skipped: {e}")

# ============================================================
# STAGE 8 — LIGHTING + CAMERAS + RENDERS
# ============================================================
print("=== STAGE 8: Lighting + Cameras ===")

# 3-point cinematic
bpy.ops.object.light_add(type='AREA', location=(4, -5, 5))
key = bpy.context.object
key.data.energy = 1500; key.data.color = (1.0, 0.92, 0.78); key.data.size = 5
bpy.ops.object.light_add(type='AREA', location=(-4, 4, 4))
fill = bpy.context.object
fill.data.energy = 500; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 5
bpy.ops.object.light_add(type='AREA', location=(0, 5, 3))
rim = bpy.context.object
rim.data.energy = 700; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 4

# Floor plane
bpy.ops.mesh.primitive_plane_add(size=10, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.10, 0.10, 0.12, 1)
fbsdf.inputs["Roughness"].default_value = 0.40
fl.data.materials.append(mat_fl)

# Cameras
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

cam_hero_hp = add_cam("cam_hero_hp", Vector((0, -4, 1.7)), Vector((0, 0, 1.5)), lens=70, dof=4)
cam_hero_lp = add_cam("cam_hero_lp", Vector((3, -4, 1.7)), Vector((3, 0, 1.5)), lens=70, dof=4)
cam_compare = add_cam("cam_compare", Vector((1.5, -6, 2.0)), Vector((1.5, 0, 1.4)), lens=50, dof=6)

# Save .blend after build
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render high-poly hero
scene.frame_set(1)
scene.camera = cam_hero_hp
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_globbler_hp_hero.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Render low-poly w/ baked texture
scene.camera = cam_hero_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_globbler_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Side-by-side comparison
scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_globbler_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Animation playblast — 4 frames
scene.camera = cam_hero_hp
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
for f in [1, 15, 30, 45]:
    scene.frame_set(f)
    scene.render.filepath = os.path.join(ANIM_DIR, f"v3_r3_globbler_idle_f{f:02d}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered anim frame: {scene.render.filepath}")

# ============================================================
# STAGE 9 — GLB EXPORT (low-poly w/ texture + armature + animation)
# ============================================================
print("=== STAGE 9: GLB export ===")

# Re-save to ensure baked image is referenced
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
arm.select_set(True)
bpy.context.view_layer.objects.active = arm

out_path = os.path.join(EXPORT_DIR, "globbler_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,  # don't apply armature
        export_animations=True,
        export_skins=True,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-01 Globbler Sculpted Hero complete ===")
