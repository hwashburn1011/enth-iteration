"""
Expansion V3 — ROUND 3 — Epic R3-06 — Town Hero Building (sculpt + PBR bake)
============================================================================
First non-character R3 asset. Hero town building (Globbler's home /
the village inn) built as a SINGLE-MESH carved structure rather than
50 cubes parented together. Pipeline:

  1. Single mesh from a tall cube subdivided 4x in each axis
  2. bmesh inset_individual to carve windows (real recessed openings)
  3. bmesh inset to carve a door
  4. extrude_face_region for the roof gable peak (real geometry, not
     a separate triangle prism)
  5. extrude for an attached chimney
  6. extrude for a small awning over the door
  7. Multires 1 level (architecture doesn't need much subdiv)
  8. UV unwrap, procedural shader: weathered wood beams + plaster +
     stone foundation, color zones driven by Z gradient
  9. Bake DIFFUSE → 1024 PNG, retopo via decimate, normal bake high→low
 10. Two renders (HP wide hero shot, LP baked detail), GLB export
 11. NO rig (architecture is static)
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(306)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_town_hero_building.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/renders"
TEX_DIR      = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/baked"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/exports"
for d in [RENDER_DIR, TEX_DIR, EXPORT_DIR]:
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
bg.inputs["Color"].default_value = (0.45, 0.55, 0.70, 1)
bg.inputs["Strength"].default_value = 1.5

# ============================================================
# STAGE 1 — SINGLE-MESH BUILDING BODY
# ============================================================
print("=== STAGE 1: Town hero building base ===")

# Subdivided cube — gives us enough faces to carve windows/door from
bpy.ops.mesh.primitive_cube_add(size=4.0, location=(0, 0, 2.0))
hero = bpy.context.object
hero.name = "town_building_hp"

# Subdivide for window placement
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

# Stretch into a building shape (taller than wide, deeper Y)
for v in bm.verts:
    v.co.z *= 1.4   # taller
    v.co.y *= 1.10  # slightly deeper
    # Tiny per-vertex jitter to break perfect-cube look
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    v.co += v.normal * random.uniform(-0.015, 0.015)

def closest_face_normal(bm, target, normal_dir):
    """Find closest face whose normal aligns with normal_dir."""
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

# === Carve windows on the front face (-Y) ===
print("Carving windows...")
WINDOW_TARGETS_FRONT = [
    Vector((-1.4, -2.20, 1.2)),  # ground floor left
    Vector((1.4, -2.20, 1.2)),   # ground floor right
    Vector((-1.4, -2.20, 3.4)),  # upper left
    Vector((1.4, -2.20, 3.4)),   # upper right
    Vector((0, -2.20, 4.6)),     # attic small
]
for target in WINDOW_TARGETS_FRONT:
    win_face = closest_face_normal(bm, target, Vector((0, -1, 0)))
    if win_face:
        res = bmesh.ops.inset_individual(bm, faces=[win_face], thickness=0.10, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else win_face
        # Push back into building (real window recess)
        for v in new_f.verts:
            v.co += Vector((0, 0.20, 0))

# Side windows (left = -X)
WINDOW_TARGETS_LEFT = [
    Vector((-2.20, -0.8, 1.2)),
    Vector((-2.20, 0.8, 1.2)),
    Vector((-2.20, 0, 3.4)),
]
for target in WINDOW_TARGETS_LEFT:
    win_face = closest_face_normal(bm, target, Vector((-1, 0, 0)))
    if win_face:
        res = bmesh.ops.inset_individual(bm, faces=[win_face], thickness=0.10, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else win_face
        for v in new_f.verts:
            v.co += Vector((0.20, 0, 0))

# Right side windows (+X)
WINDOW_TARGETS_RIGHT = [
    Vector((2.20, -0.8, 1.2)),
    Vector((2.20, 0.8, 1.2)),
    Vector((2.20, 0, 3.4)),
]
for target in WINDOW_TARGETS_RIGHT:
    win_face = closest_face_normal(bm, target, Vector((1, 0, 0)))
    if win_face:
        res = bmesh.ops.inset_individual(bm, faces=[win_face], thickness=0.10, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else win_face
        for v in new_f.verts:
            v.co += Vector((-0.20, 0, 0))

# === Carve door (front center, ground level) ===
print("Carving door...")
door_face = closest_face_normal(bm, Vector((0, -2.20, 0.6)), Vector((0, -1, 0)))
if door_face:
    res = bmesh.ops.inset_individual(bm, faces=[door_face], thickness=0.15, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else door_face
    for v in new_f.verts:
        v.co += Vector((0, 0.25, 0))  # deeper recess for door

# === Roof gable: extrude top face up to a peak ===
print("Extruding roof gable...")
# Find top face(s) — those with strong +Z normal
top_faces = [f for f in bm.faces if f.normal.z > 0.7 and f.calc_center_median().z > 2.0]
if top_faces:
    geom = bmesh.ops.extrude_face_region(bm, geom=top_faces)
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.z += 1.0
        # Pinch to a ridge along Y axis (peak runs front-to-back)
        v.co.x *= 0.05
    # The new top is now a thin ridge — gable formed

# === Chimney: extrude a small face on the roof side ===
print("Extruding chimney...")
chim_face = closest_face(bm, Vector((1.0, 0.8, 4.5)))
if chim_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[chim_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.z += 1.4

# === Awning over the door: extrude a strip above the door ===
print("Extruding door awning...")
awn_face = closest_face_normal(bm, Vector((0, -2.20, 1.3)), Vector((0, -1, 0)))
if awn_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[awn_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co += Vector((0, -0.45, 0))
        # Slight downward slope for the awning underside
        if v.co.z < 1.5:
            v.co.z -= 0.10

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = False  # architecture should be flat-shaded for hard edges

# Bevel + multires
print("Adding bevel + multires...")
bev = hero.modifiers.new("Bevel", 'BEVEL')
bev.width = 0.025
bev.segments = 2

hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
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
bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — PROCEDURAL SHADER (weathered wood + plaster + stone)
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
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Metallic"].default_value = 0.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (2.5, 2.5, 2.5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Z-position separator for height-based zoning
    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-1200, -300)
    links.new(tc.outputs["Object"], sep.inputs["Vector"])

    # Stone foundation noise (low Z)
    stone_n = nodes.new("ShaderNodeTexNoise"); stone_n.location = (-900, 200)
    stone_n.inputs["Scale"].default_value = 12.0
    stone_n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], stone_n.inputs["Vector"])
    stone_ramp = nodes.new("ShaderNodeValToRGB"); stone_ramp.location = (-650, 200)
    stone_ramp.color_ramp.elements[0].position = 0.30
    stone_ramp.color_ramp.elements[0].color = (0.25, 0.22, 0.20, 1)  # dark stone
    stone_ramp.color_ramp.elements[1].position = 0.70
    stone_ramp.color_ramp.elements[1].color = (0.45, 0.40, 0.35, 1)  # mid stone
    links.new(stone_n.outputs["Fac"], stone_ramp.inputs["Fac"])

    # Plaster mid-zone
    plaster_n = nodes.new("ShaderNodeTexNoise"); plaster_n.location = (-900, 0)
    plaster_n.inputs["Scale"].default_value = 8.0
    plaster_n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], plaster_n.inputs["Vector"])
    plaster_ramp = nodes.new("ShaderNodeValToRGB"); plaster_ramp.location = (-650, 0)
    plaster_ramp.color_ramp.elements[0].position = 0.40
    plaster_ramp.color_ramp.elements[0].color = (0.85, 0.75, 0.60, 1)  # cream plaster
    plaster_ramp.color_ramp.elements[1].position = 0.65
    plaster_ramp.color_ramp.elements[1].color = (0.95, 0.85, 0.70, 1)  # bright plaster
    links.new(plaster_n.outputs["Fac"], plaster_ramp.inputs["Fac"])

    # Wood roof (high Z) — striped grain via second noise
    wood_n = nodes.new("ShaderNodeTexNoise"); wood_n.location = (-900, -200)
    wood_n.inputs["Scale"].default_value = 18.0
    wood_n.inputs["Detail"].default_value = 4.0
    links.new(mp.outputs["Vector"], wood_n.inputs["Vector"])
    wood_ramp = nodes.new("ShaderNodeValToRGB"); wood_ramp.location = (-650, -200)
    wood_ramp.color_ramp.elements[0].position = 0.30
    wood_ramp.color_ramp.elements[0].color = (0.20, 0.10, 0.05, 1)  # dark beam
    wood_ramp.color_ramp.elements[1].position = 0.70
    wood_ramp.color_ramp.elements[1].color = (0.45, 0.25, 0.12, 1)  # warm wood
    links.new(wood_n.outputs["Fac"], wood_ramp.inputs["Fac"])

    # Z-based mix factors
    # stone (z<1) → plaster (1<z<3.5) → wood (z>3.5)
    z_to_plaster = nodes.new("ShaderNodeMath"); z_to_plaster.location = (-900, -450)
    z_to_plaster.operation = 'MAP_RANGE' if 'MAP_RANGE' in [op for op in ['ADD','SUBTRACT']] else 'GREATER_THAN'
    z_to_plaster.operation = 'GREATER_THAN'
    z_to_plaster.inputs[1].default_value = 0.8
    links.new(sep.outputs["Z"], z_to_plaster.inputs[0])

    z_to_wood = nodes.new("ShaderNodeMath"); z_to_wood.location = (-900, -600)
    z_to_wood.operation = 'GREATER_THAN'
    z_to_wood.inputs[1].default_value = 3.5
    links.new(sep.outputs["Z"], z_to_wood.inputs[0])

    # Mix stone → plaster
    mix1 = nodes.new("ShaderNodeMix"); mix1.data_type = 'RGBA'; mix1.location = (-300, 100)
    links.new(z_to_plaster.outputs[0], mix1.inputs["Factor"])
    links.new(stone_ramp.outputs["Color"], mix1.inputs[6])
    links.new(plaster_ramp.outputs["Color"], mix1.inputs[7])

    # Mix (stone+plaster) → wood
    mix2 = nodes.new("ShaderNodeMix"); mix2.data_type = 'RGBA'; mix2.location = (0, 0)
    links.new(z_to_wood.outputs[0], mix2.inputs["Factor"])
    links.new(mix1.outputs[2], mix2.inputs[6])
    links.new(wood_ramp.outputs["Color"], mix2.inputs[7])

    links.new(mix2.outputs[2], bsdf.inputs["Base Color"])

    # Bump from combined noise
    bp = nodes.new("ShaderNodeBump"); bp.location = (-300, -500)
    bp.inputs["Strength"].default_value = 0.40
    links.new(stone_n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])

    # Roughness map: rougher in cracks
    rough_n = nodes.new("ShaderNodeTexNoise"); rough_n.location = (-700, -700)
    rough_n.inputs["Scale"].default_value = 5.0
    links.new(mp.outputs["Vector"], rough_n.inputs["Vector"])
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (-450, -700)
    rough_ramp.color_ramp.elements[0].position = 0.35
    rough_ramp.color_ramp.elements[0].color = (0.7, 0.7, 0.7, 1)
    rough_ramp.color_ramp.elements[1].position = 0.75
    rough_ramp.color_ramp.elements[1].color = (1.0, 1.0, 1.0, 1)
    links.new(rough_n.outputs["Fac"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])
    return m

mat_proc = make_shader("v3r3_town_building_proc")
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("town_building_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "town_building_albedo_1024.png")
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
low_poly.name = "town_building_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.25  # architecture needs slightly more faces preserved
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL MAP BAKE
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("town_building_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_town_building_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.80
bsdf_lp.inputs["Metallic"].default_value = 0.0
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
scene.render.bake.max_ray_distance = 0.40
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "town_building_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (8.0, 0, 0)

# ============================================================
# STAGE 7 — LIGHTING + RENDERS
# ============================================================
print("=== STAGE 7: Lighting + Renders ===")

# Sun
bpy.ops.object.light_add(type='SUN', location=(0, 0, 12))
sun = bpy.context.object
sun.data.energy = 4.0
sun.data.color = (1.0, 0.92, 0.78)
sun.rotation_euler = (math.radians(45), math.radians(20), 0)

# Sky fill
bpy.ops.object.light_add(type='AREA', location=(-8, 8, 8))
fill = bpy.context.object
fill.data.energy = 600
fill.data.color = (0.55, 0.70, 0.95)
fill.data.size = 8

# Warm window glow (key)
bpy.ops.object.light_add(type='AREA', location=(0, -8, 4))
win = bpy.context.object
win.data.energy = 250
win.data.color = (1.0, 0.75, 0.40)
win.data.size = 5

# Ground plane — grass-ish
bpy.ops.mesh.primitive_plane_add(size=30, location=(0, 0, 0))
gnd = bpy.context.object; gnd.name = "ground"
mat_g = bpy.data.materials.new("ground")
mat_g.use_nodes = True
gbsdf = mat_g.node_tree.nodes["Principled BSDF"]
gbsdf.inputs["Base Color"].default_value = (0.20, 0.25, 0.10, 1)
gbsdf.inputs["Roughness"].default_value = 0.85
gnd.data.materials.append(mat_g)

def add_cam(name, loc, target, lens=70, dof=8.0, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((-5, -10, 4)), Vector((0, 0, 2.5)), lens=42, dof=10)
cam_lp = add_cam("cam_lp", Vector((4, -10, 4)), Vector((8, 0, 2.5)), lens=42, dof=10)
cam_compare = add_cam("cam_compare", Vector((4, -14, 5)), Vector((4, 0, 2.5)), lens=35, dof=14)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_town_hero_building_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_town_hero_building_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_town_hero_building_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 8 — GLB EXPORT (low-poly only, baked PBR)
# ============================================================
print("=== STAGE 8: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "town_hero_building_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-06 Town Hero Building complete ===")
