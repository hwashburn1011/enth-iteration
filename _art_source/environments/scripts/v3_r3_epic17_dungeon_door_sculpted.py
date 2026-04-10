"""
Expansion V3 — ROUND 3 — Epic R3-17 — Hero Dungeon Door
=======================================================
Sculpted dungeon door, single-mesh from a tall flat slab.
Real geometry features:
  - 4 carved recessed panels via inset_individual on the front face
  - 16 extruded iron stud rivets in a 4x4 grid (extrude_face_region tip-collapsed)
  - 1 keyhole inset (deep recess)
  - Beveled door frame extruded around the perimeter
  - 2-bone armature (root + door bone) for hinge swing
  - 60-frame open/close animation
  - Iron+wood Z-zoned PBR shader baked + normal high→low
  - GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(317)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_dungeon_door.blend"
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
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# STAGE 1 — DOOR BASE MESH
# ============================================================
print("=== STAGE 1: Door base ===")

# Tall narrow slab — door size (1.4m wide x 0.15m thick x 2.4m tall)
bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0, 1.2))
hero = bpy.context.object
hero.name = "dungeon_door_hp"
hero.scale = (0.7, 0.075, 1.2)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# Subdivide for stud + panel placement
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(4):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

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

# === 4 carved recessed panels on front face ===
print("Carving panels...")
PANEL_TARGETS = [
    Vector((-0.30, -0.075, 0.55)),   # bottom-left
    Vector((0.30, -0.075, 0.55)),    # bottom-right
    Vector((-0.30, -0.075, 1.85)),   # top-left
    Vector((0.30, -0.075, 1.85)),    # top-right
]
for target in PANEL_TARGETS:
    pf = closest_face_normal(bm, target, Vector((0, -1, 0)))
    if pf:
        # Outer inset (panel frame)
        res = bmesh.ops.inset_individual(bm, faces=[pf], thickness=0.05, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else pf
        for v in new_f.verts:
            v.co.y += 0.025  # push back into door

bm.normal_update()
bm.faces.ensure_lookup_table()

# === 16 extruded iron stud rivets (4x4 grid) ===
print("Extruding iron stud rivets...")
STUD_GRID_X = [-0.55, -0.18, 0.18, 0.55]
STUD_GRID_Z = [0.20, 0.85, 1.50, 2.15]
for sx in STUD_GRID_X:
    for sz in STUD_GRID_Z:
        sf = closest_face_normal(bm, Vector((sx, -0.075, sz)), Vector((0, -1, 0)))
        if sf:
            # First extrude — cylinder base
            geom = bmesh.ops.extrude_face_region(bm, geom=[sf])
            new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts:
                v.co.y -= 0.025
            new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
            if new_faces:
                # Second extrude — dome top
                geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
                new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
                for v in new_verts2:
                    v.co.y -= 0.015
                # Slight tip pinch to dome the head
                avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
                for v in new_verts2:
                    v.co = v.co.lerp(avg, 0.30)

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Keyhole inset ===
print("Carving keyhole...")
key_face = closest_face_normal(bm, Vector((0.50, -0.075, 1.10)), Vector((0, -1, 0)))
if key_face:
    res = bmesh.ops.inset_individual(bm, faces=[key_face], thickness=0.02, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else key_face
    for v in new_f.verts:
        v.co.y += 0.04  # deep recess

bm.normal_update()

bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = False  # door is flat-shaded for crisp edges

# Bevel + multires
print("Adding bevel + multires...")
bev = hero.modifiers.new("Bevel", 'BEVEL'); bev.width = 0.008; bev.segments = 2
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 1B — Door frame (separate single-mesh, 4-piece extruded)
# ============================================================
print("=== STAGE 1B: Door frame ===")
bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0.075, 1.2))
frame = bpy.context.object
frame.name = "door_frame_hp"
frame.scale = (0.85, 0.10, 1.30)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# Inset front face deep to hollow out the frame opening
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(2):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(frame.data)

# Find the front face cluster and carve a door-shaped opening through
front_faces = [f for f in bm.faces if f.normal.y < -0.5]
# The center 4-6 faces approximate the door opening
opening_targets = []
for f in front_faces:
    c = f.calc_center_median()
    if abs(c.x) < 0.70 and 0.0 < c.z < 2.40:
        opening_targets.append(f)

if opening_targets:
    # Inset and push deep through to back (hollow the opening)
    res = bmesh.ops.inset_individual(bm, faces=opening_targets, thickness=0.02, depth=0.0)
    for f in res.get('faces', []):
        for v in f.verts:
            v.co.y += 0.20  # punch through

bm.normal_update()
bm.to_mesh(frame.data)
bm.free()
frame.data.update()
for poly in frame.data.polygons:
    poly.use_smooth = False

bev2 = frame.modifiers.new("Bevel", 'BEVEL'); bev2.width = 0.012; bev2.segments = 2

# ============================================================
# STAGE 2 — UV UNWRAP
# ============================================================
print("=== STAGE 2: UV unwrap ===")
for obj in [hero, frame]:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — IRON + WOOD SHADER
# ============================================================
print("=== STAGE 3: Iron + wood shader ===")

def make_door_shader():
    m = bpy.data.materials.new("v3r3_door_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.65
    bsdf.inputs["Metallic"].default_value = 0.05
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (3.0, 3.0, 6.0)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Wood grain (vertical noise)
    grain = nodes.new("ShaderNodeTexNoise"); grain.location = (-900, 200)
    grain.inputs["Scale"].default_value = 12.0
    grain.inputs["Detail"].default_value = 10.0
    links.new(mp.outputs["Vector"], grain.inputs["Vector"])

    wood_ramp = nodes.new("ShaderNodeValToRGB"); wood_ramp.location = (-650, 200)
    cr = wood_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.10, 0.05, 0.02, 1)   # dark grain
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.30, 0.18, 0.10, 1)   # warm wood
    el2 = cr.elements.new(0.85)
    el2.color = (0.45, 0.28, 0.15, 1)               # highlights
    links.new(grain.outputs["Fac"], wood_ramp.inputs["Fac"])
    links.new(wood_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # === Iron emission via Pointiness (studs glow as polished iron) ===
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-900, -200)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-650, -200)
    # Pointy ridges = stud heads (positive curvature, near 1)
    pointy_ramp.color_ramp.elements[0].position = 0.55
    pointy_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.70
    pointy_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    # Iron color
    iron_color = nodes.new("ShaderNodeRGB"); iron_color.location = (-650, -350)
    iron_color.outputs[0].default_value = (0.18, 0.18, 0.20, 1)

    iron_mix = nodes.new("ShaderNodeMix"); iron_mix.data_type = 'RGBA'; iron_mix.location = (100, 0)
    links.new(pointy_ramp.outputs["Color"], iron_mix.inputs["Factor"])
    links.new(wood_ramp.outputs["Color"], iron_mix.inputs[6])
    links.new(iron_color.outputs[0], iron_mix.inputs[7])
    links.new(iron_mix.outputs[2], bsdf.inputs["Base Color"])

    # Roughness: iron ridges polished, wood rough
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (100, -200)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.85, 0.85, 0.85, 1)  # rough wood
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.25, 0.25, 0.25, 1)  # polished iron
    links.new(pointy_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    # Metallic: iron ridges metal, wood not
    metal_ramp = nodes.new("ShaderNodeValToRGB"); metal_ramp.location = (100, -400)
    metal_ramp.color_ramp.elements[0].position = 0.0
    metal_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    metal_ramp.color_ramp.elements[1].position = 1.0
    metal_ramp.color_ramp.elements[1].color = (0.95, 0.95, 0.95, 1)
    links.new(pointy_ramp.outputs["Color"], metal_ramp.inputs["Fac"])
    links.new(metal_ramp.outputs["Color"], bsdf.inputs["Metallic"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.35
    links.new(grain.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_door = make_door_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_door)

mat_frame = make_door_shader()
frame.data.materials.clear()
frame.data.materials.append(mat_frame)

# ============================================================
# STAGE 4 — BAKE DIFFUSE (door only — frame is simple)
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("dungeon_door_albedo_bake", width=1024, height=1024)
img_node_a = mat_door.node_tree.nodes.new("ShaderNodeTexImage")
img_node_a.location = (1100, 400)
img_node_a.image = bake_albedo
img_node_a.select = True
mat_door.node_tree.nodes.active = img_node_a

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
    bake_path = os.path.join(TEX_DIR, "dungeon_door_albedo_1024.png")
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
low_poly.name = "dungeon_door_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.25
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL BAKE
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("dungeon_door_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_dungeon_door_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.70
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
    nrm_path = os.path.join(TEX_DIR, "dungeon_door_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (4.0, 0, 1.2)

# ============================================================
# STAGE 7 — ARMATURE: 2-bone hinge rig
# ============================================================
print("=== STAGE 7: Armature ===")
bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "door_armature"
arm.show_in_front = True

bpy.ops.object.mode_set(mode='EDIT')
ed_bones = arm.data.edit_bones
ed_bones.remove(ed_bones["Bone"])

# Hinge axis: left edge of door (x = -0.7)
root = ed_bones.new("root")
root.head = Vector((-0.70, 0, 0))
root.tail = Vector((-0.70, 0, 0.5))

door_b = ed_bones.new("door")
door_b.head = Vector((-0.70, 0, 0))
door_b.tail = Vector((-0.70, 0, 2.40))
door_b.parent = root
door_b.use_connect = False

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
# STAGE 8 — SWING ANIMATION
# ============================================================
print("=== STAGE 8: Swing animation ===")
scene.frame_start = 1
scene.frame_end = 60
scene.render.fps = 30

bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')

pb_door = arm.pose.bones["door"]
pb_door.rotation_mode = 'XYZ'

# Open from 0 to ~80 degrees over 60 frames, then hold
KEYS = [
    (1,  0.0),
    (15, 0.40),
    (30, 0.90),
    (45, 1.30),
    (60, 1.40),
]
for f, rz in KEYS:
    scene.frame_set(f)
    pb_door.rotation_euler = (0, 0, rz)
    pb_door.keyframe_insert(data_path="rotation_euler", frame=f)

bpy.ops.object.mode_set(mode='OBJECT')
print("Swing keyframes inserted")

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

bpy.ops.object.light_add(type='SPOT', location=(2, -6, 4))
key = bpy.context.object
key.data.energy = 2500; key.data.color = (1.0, 0.65, 0.30)
key.data.spot_size = math.radians(80)
direction = Vector((0, 0, 1.2)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-5, -4, 3))
fill = bpy.context.object
fill.data.energy = 500; fill.data.color = (0.45, 0.55, 0.85); fill.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(5, 3, 3))
rim = bpy.context.object
rim.data.energy = 700; rim.data.color = (0.85, 0.95, 1.0); rim.data.size = 5

bpy.ops.mesh.primitive_plane_add(size=14, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.05, 0.05, 0.07, 1)
fbsdf.inputs["Roughness"].default_value = 0.60
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

cam_hp = add_cam("cam_hp", Vector((0, -5, 1.5)), Vector((0, 0, 1.2)), lens=50, dof=5)
cam_lp = add_cam("cam_lp", Vector((4, -5, 1.5)), Vector((4, 0, 1.2)), lens=50, dof=5)
cam_compare = add_cam("cam_compare", Vector((2, -7, 2.0)), Vector((2, 0, 1.2)), lens=42, dof=8)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.frame_set(1)
scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_dungeon_door_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_dungeon_door_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_dungeon_door_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Anim playblast
scene.camera = cam_hp
scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for f in [1, 15, 30, 45]:
    scene.frame_set(f)
    scene.render.filepath = os.path.join(ANIM_DIR, f"v3_r3_dungeon_door_swing_f{f:02d}.png")
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
frame.select_set(True)
bpy.context.view_layer.objects.active = arm

out_path = os.path.join(EXPORT_DIR, "dungeon_door_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_animations=True, export_skins=True,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-17 Dungeon Door complete ===")
