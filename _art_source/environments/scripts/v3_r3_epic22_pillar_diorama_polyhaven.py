"""
Expansion V3 — ROUND 3 — Epic R3-22 — Boss Arena Pillar Diorama
================================================================
Builds a sculpted boss arena pillar with carved fluting + base + capital,
sitting on a stone tile floor. Both objects use REAL Polyhaven CC0 PBR
textures applied via Image Texture nodes through cube_project UVs.

Polyhaven assets used (downloaded via curl from dl.polyhaven.org):
  - castle_brick_07 (pillar shaft + base + capital)
  - cobblestone_floor_04 (arena floor)

Pipeline:
  1. Pillar: high-poly cylinder (32-vertex) w/ vertical fluting grooves
     carved via inset_individual on every other side face strip,
     extruded base block + extruded capital block w/ inset trim
  2. Floor: large subdivided plane
  3. UV unwrap (cube_project for pillar, smart unwrap for floor)
  4. Polyhaven PBR shaders applied via Image Texture nodes
  5. 3-light boss arena moodboard (warm rim + cool fill + back-rim)
  6. 3-camera renders (full diorama, pillar closeup, floor closeup)
  7. GLB export with embedded textures
"""
import bpy, bmesh, math, os
from mathutils import Vector

POLYHAVEN_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/polyhaven"
OUTPUT_BLEND  = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_pillar_diorama.blend"
RENDER_DIR    = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/renders"
EXPORT_DIR    = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/exports"
for d in [RENDER_DIR, EXPORT_DIR]:
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
bg.inputs["Color"].default_value = (0.04, 0.04, 0.06, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# STAGE 1 — PILLAR (single mesh sculpted from cylinder)
# ============================================================
print("=== STAGE 1: Pillar sculpt ===")

bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.55, depth=4.0, location=(0, 0, 2.0))
pillar = bpy.context.object
pillar.name = "boss_pillar_hp"

# Subdivide rings for fluting placement
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(pillar.data)

# === Carve vertical fluting grooves: every 4th column of side faces ===
print("Carving fluting grooves...")
side_faces = [f for f in bm.faces if abs(f.normal.z) < 0.5]  # not top/bottom caps
# Group by approximate angular position
def angle_of(f):
    c = f.calc_center_median()
    return math.atan2(c.y, c.x)

side_faces.sort(key=lambda f: (round(angle_of(f), 1), f.calc_center_median().z))

# Pick faces in vertical strips at 8 evenly-spaced angles
import math as _m
groove_strips = []
for theta in [i * (_m.tau / 16) for i in range(16)]:
    strip = []
    for f in side_faces:
        c = f.calc_center_median()
        face_theta = _m.atan2(c.y, c.x)
        d = abs(((face_theta - theta) + _m.pi) % _m.tau - _m.pi)
        if d < 0.06 and 0.4 < c.z < 3.6:
            strip.append(f)
    if strip:
        groove_strips.append(strip)

# Take alternating strips for grooves (every other one)
groove_targets = []
for i, strip in enumerate(groove_strips):
    if i % 2 == 0:
        groove_targets.extend(strip)

if groove_targets:
    res = bmesh.ops.inset_individual(bm, faces=groove_targets, thickness=0.012, depth=0.0)
    for f in res.get('faces', []):
        for v in f.verts:
            # Push inward toward axis
            horiz = Vector((v.co.x, v.co.y, 0))
            if horiz.length > 0:
                horiz.normalize()
                v.co -= horiz * 0.025

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Extrude base block ===
print("Extruding base block...")
bottom_faces = [f for f in bm.faces if f.normal.z < -0.5]
if bottom_faces:
    geom = bmesh.ops.extrude_face_region(bm, geom=bottom_faces)
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.z -= 0.30
        # Flare base outward
        horiz = Vector((v.co.x, v.co.y, 0))
        if horiz.length > 0:
            horiz.normalize()
            v.co += horiz * 0.20

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Extrude capital block ===
print("Extruding capital block...")
top_faces = [f for f in bm.faces if f.normal.z > 0.5 and f.calc_center_median().z > 3.5]
if top_faces:
    geom = bmesh.ops.extrude_face_region(bm, geom=top_faces)
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.z += 0.30
        # Flare capital outward
        horiz = Vector((v.co.x, v.co.y, 0))
        if horiz.length > 0:
            horiz.normalize()
            v.co += horiz * 0.25

bm.normal_update()
bm.to_mesh(pillar.data)
bm.free()
pillar.data.update()
for poly in pillar.data.polygons:
    poly.use_smooth = True

bev = pillar.modifiers.new("Bevel", 'BEVEL')
bev.width = 0.012
bev.segments = 2

# ============================================================
# STAGE 2 — FLOOR (large subdivided plane for tile detail)
# ============================================================
print("=== STAGE 2: Floor plane ===")
bpy.ops.mesh.primitive_plane_add(size=10, location=(0, 0, 0))
floor = bpy.context.object
floor.name = "arena_floor"
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — UV UNWRAP
# ============================================================
print("=== STAGE 3: UV unwrap ===")
for obj, scale in [(pillar, 2.0), (floor, 4.0)]:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.cube_project(cube_size=scale)
    bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 4 — POLYHAVEN PBR MATERIALS
# ============================================================
print("=== STAGE 4: Polyhaven PBR materials ===")

def make_polyhaven_material(name, asset_name, uv_scale=(1.0, 1.0, 1.0), normal_strength=1.2):
    diff_path = os.path.join(POLYHAVEN_DIR, f"{asset_name}_diff_1k.png")
    nor_path = os.path.join(POLYHAVEN_DIR, f"{asset_name}_nor_gl_1k.png")
    rough_path = os.path.join(POLYHAVEN_DIR, f"{asset_name}_rough_1k.png")
    for p in [diff_path, nor_path, rough_path]:
        if not os.path.exists(p):
            raise FileNotFoundError(f"Missing Polyhaven texture: {p}")
        print(f"  loading {os.path.basename(p)}")

    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Metallic"].default_value = 0.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-700, 0)
    mp.inputs["Scale"].default_value = uv_scale
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    img_diff = nodes.new("ShaderNodeTexImage"); img_diff.location = (-300, 200)
    img_diff.image = bpy.data.images.load(diff_path, check_existing=True)
    img_diff.image.colorspace_settings.name = 'sRGB'
    links.new(mp.outputs["Vector"], img_diff.inputs["Vector"])
    links.new(img_diff.outputs["Color"], bsdf.inputs["Base Color"])

    img_rough = nodes.new("ShaderNodeTexImage"); img_rough.location = (-300, -50)
    img_rough.image = bpy.data.images.load(rough_path, check_existing=True)
    img_rough.image.colorspace_settings.name = 'Non-Color'
    links.new(mp.outputs["Vector"], img_rough.inputs["Vector"])
    links.new(img_rough.outputs["Color"], bsdf.inputs["Roughness"])

    img_nor = nodes.new("ShaderNodeTexImage"); img_nor.location = (-300, -300)
    img_nor.image = bpy.data.images.load(nor_path, check_existing=True)
    img_nor.image.colorspace_settings.name = 'Non-Color'
    links.new(mp.outputs["Vector"], img_nor.inputs["Vector"])
    nrm = nodes.new("ShaderNodeNormalMap"); nrm.location = (0, -300)
    nrm.inputs["Strength"].default_value = normal_strength
    links.new(img_nor.outputs["Color"], nrm.inputs["Color"])
    links.new(nrm.outputs["Normal"], bsdf.inputs["Normal"])

    return m

mat_pillar = make_polyhaven_material("v3r3_polyhaven_castle_brick",
                                      "castle_brick_07",
                                      uv_scale=(2.5, 2.5, 2.5),
                                      normal_strength=1.4)
mat_floor = make_polyhaven_material("v3r3_polyhaven_cobblestone",
                                     "cobblestone_floor_04",
                                     uv_scale=(3.0, 3.0, 3.0),
                                     normal_strength=1.6)

pillar.data.materials.clear(); pillar.data.materials.append(mat_pillar)
floor.data.materials.clear(); floor.data.materials.append(mat_floor)

# ============================================================
# STAGE 5 — LIGHTING (boss arena mood)
# ============================================================
print("=== STAGE 5: Lighting ===")

# Warm dramatic key from forward-left
bpy.ops.object.light_add(type='SPOT', location=(-4, -6, 7))
key = bpy.context.object
key.data.energy = 4500; key.data.color = (1.0, 0.65, 0.30)
key.data.spot_size = math.radians(80)
direction = Vector((0, 0, 2.5)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# Cool fill from forward-right
bpy.ops.object.light_add(type='AREA', location=(5, -4, 5))
fill = bpy.context.object
fill.data.energy = 800; fill.data.color = (0.40, 0.55, 0.95); fill.data.size = 6

# Cyan back rim
bpy.ops.object.light_add(type='AREA', location=(0, 6, 5))
rim = bpy.context.object
rim.data.energy = 1200; rim.data.color = (0.30, 0.85, 1.0); rim.data.size = 6

# ============================================================
# STAGE 6 — RENDERS
# ============================================================
print("=== STAGE 6: Renders ===")

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

cam_wide = add_cam("cam_wide", Vector((-3, -7, 3.5)), Vector((0, 0, 2.0)), lens=42, dof=8)
cam_pillar = add_cam("cam_pillar", Vector((-1, -3.5, 2.5)), Vector((0, 0, 2.0)), lens=70, dof=4)
cam_floor = add_cam("cam_floor", Vector((-1, -2, 0.8)), Vector((0, 0.5, 0)), lens=60, dof=2.5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_wide
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_pillar_diorama_wide.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_pillar
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_pillar_diorama_pillar_closeup.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_floor
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_pillar_diorama_floor_closeup.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 7 — GLB EXPORT
# ============================================================
print("=== STAGE 7: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
pillar.select_set(True)
floor.select_set(True)
bpy.context.view_layer.objects.active = pillar

out_path = os.path.join(EXPORT_DIR, "pillar_diorama_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_image_format='AUTO',
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-22 Pillar Diorama complete ===")
