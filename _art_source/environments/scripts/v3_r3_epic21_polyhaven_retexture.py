"""
Expansion V3 — ROUND 3 — Epic R3-21 — Polyhaven PBR Re-Texture Pass
===================================================================
Directly addresses critical-review point: "No image textures —
everything procedural. Polyhaven was never wired in (MCP issues)."

This script DOWNLOADED real Polyhaven CC0 PBR textures via curl
(diffuse + normal_gl + roughness, 1k each) BEFORE running. The
textures live at:
  _art_source/textures/polyhaven/rough_block_wall_*_1k.png
  _art_source/textures/polyhaven/weathered_planks_*_1k.png

This script builds a 2-asset hero diorama where each asset has
its real Polyhaven PBR maps wired into the Principled BSDF via
Image Texture nodes — albedo from diff, normal via NormalMap from
nor_gl, roughness from rough. UVs are real cube_project unwraps,
not procedural triplanar.

Outputs:
  - v3_r3_polyhaven_diorama.blend
  - 1 hero render w/ both assets side-by-side under 3-point lighting
  - GLB export of the dual-mesh diorama
"""
import bpy, bmesh, math, os
from mathutils import Vector

POLYHAVEN_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/polyhaven"
OUTPUT_BLEND  = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_polyhaven_diorama.blend"
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
bg.inputs["Color"].default_value = (0.18, 0.20, 0.25, 1)
bg.inputs["Strength"].default_value = 0.6

# ============================================================
# STAGE 1 — TWO HERO SLABS (carved geometry, not flat planes)
# ============================================================
print("=== STAGE 1: Build hero slabs ===")

def build_carved_slab(name, location, size, num_pockets=3):
    """Build a sculpted slab with real geometry features so the
    Polyhaven texture lands on actual carved 3D detail, not a
    flat poly. Returns the mesh object."""
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    # Subdivide front face for pocket placement
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    for _ in range(3):
        bpy.ops.mesh.subdivide()
    bpy.ops.object.mode_set(mode='OBJECT')

    bm = bmesh.new()
    bm.from_mesh(obj.data)

    # Carve N recessed pockets on the front face (-Y normal)
    front_faces = [f for f in bm.faces if f.normal.y < -0.5]
    front_faces.sort(key=lambda f: (f.calc_center_median().x, f.calc_center_median().z))
    if num_pockets > 0 and len(front_faces) > num_pockets * 4:
        # Pick spaced pockets
        step = max(1, len(front_faces) // num_pockets)
        pockets = [front_faces[i * step] for i in range(num_pockets)]
        res = bmesh.ops.inset_individual(bm, faces=pockets, thickness=0.04, depth=0.0)
        for f in res.get('faces', []):
            for v in f.verts:
                v.co.y += 0.04

    bm.normal_update()
    bm.to_mesh(obj.data)
    bm.free()
    obj.data.update()
    for poly in obj.data.polygons:
        poly.use_smooth = False

    bev = obj.modifiers.new("Bevel", 'BEVEL')
    bev.width = 0.008
    bev.segments = 2

    return obj

wall_slab = build_carved_slab("polyhaven_wall_slab", (-1.6, 0, 1.0), (0.8, 0.10, 1.0), num_pockets=3)
plank_slab = build_carved_slab("polyhaven_plank_slab", (1.6, 0, 1.0), (0.8, 0.10, 1.0), num_pockets=4)

# ============================================================
# STAGE 2 — UV UNWRAP (cube_project)
# ============================================================
print("=== STAGE 2: UV unwrap ===")
for obj in [wall_slab, plank_slab]:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.cube_project(cube_size=2.0)
    bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — POLYHAVEN PBR MATERIAL BUILDER
# ============================================================
print("=== STAGE 3: Polyhaven PBR materials ===")

def make_polyhaven_material(name, asset_name):
    """Build a Principled BSDF material wired to real Polyhaven
    diff/normal/roughness PNGs via Image Texture nodes."""
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
    mp.inputs["Scale"].default_value = (2.0, 2.0, 2.0)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    # Diffuse → Base Color
    img_diff = nodes.new("ShaderNodeTexImage"); img_diff.location = (-300, 200)
    img_diff.image = bpy.data.images.load(diff_path, check_existing=True)
    img_diff.image.colorspace_settings.name = 'sRGB'
    links.new(mp.outputs["Vector"], img_diff.inputs["Vector"])
    links.new(img_diff.outputs["Color"], bsdf.inputs["Base Color"])

    # Roughness map → Roughness (Non-Color)
    img_rough = nodes.new("ShaderNodeTexImage"); img_rough.location = (-300, -50)
    img_rough.image = bpy.data.images.load(rough_path, check_existing=True)
    img_rough.image.colorspace_settings.name = 'Non-Color'
    links.new(mp.outputs["Vector"], img_rough.inputs["Vector"])
    links.new(img_rough.outputs["Color"], bsdf.inputs["Roughness"])

    # Normal map → NormalMap node → Normal (Non-Color)
    img_nor = nodes.new("ShaderNodeTexImage"); img_nor.location = (-300, -300)
    img_nor.image = bpy.data.images.load(nor_path, check_existing=True)
    img_nor.image.colorspace_settings.name = 'Non-Color'
    links.new(mp.outputs["Vector"], img_nor.inputs["Vector"])
    nrm = nodes.new("ShaderNodeNormalMap"); nrm.location = (0, -300)
    nrm.inputs["Strength"].default_value = 1.2
    links.new(img_nor.outputs["Color"], nrm.inputs["Color"])
    links.new(nrm.outputs["Normal"], bsdf.inputs["Normal"])

    return m

mat_wall = make_polyhaven_material("v3r3_polyhaven_rough_block_wall", "rough_block_wall")
mat_planks = make_polyhaven_material("v3r3_polyhaven_weathered_planks", "weathered_planks")

wall_slab.data.materials.clear()
wall_slab.data.materials.append(mat_wall)

plank_slab.data.materials.clear()
plank_slab.data.materials.append(mat_planks)

# ============================================================
# STAGE 4 — LIGHTING + RENDER
# ============================================================
print("=== STAGE 4: Lighting + Render ===")

bpy.ops.object.light_add(type='AREA', location=(3, -5, 4))
key = bpy.context.object
key.data.energy = 1500; key.data.color = (1.0, 0.92, 0.78); key.data.size = 4

bpy.ops.object.light_add(type='AREA', location=(-5, 4, 4))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.55, 0.70, 0.95); fill.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(0, -3, 0.3))
rim = bpy.context.object
rim.data.energy = 350; rim.data.color = (1.0, 0.65, 0.25); rim.data.size = 3

# Floor
bpy.ops.mesh.primitive_plane_add(size=10, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.06, 0.06, 0.07, 1)
fbsdf.inputs["Roughness"].default_value = 0.55
fl.data.materials.append(mat_fl)

bpy.ops.object.camera_add(location=(0, -5, 1.6))
cam = bpy.context.object
cam.name = "cam_hero"
cam.data.lens = 50
cam.data.dof.use_dof = True
cam.data.dof.aperture_fstop = 4.0
cam.data.dof.focus_distance = 5.0
direction = Vector((0, 0, 1.0)) - cam.location
cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_polyhaven_diorama.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Close-up of each slab
cam.location = (-1.6, -2.5, 1.4)
direction = Vector((-1.6, 0, 1.0)) - cam.location
cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_polyhaven_wall_closeup.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

cam.location = (1.6, -2.5, 1.4)
direction = Vector((1.6, 0, 1.0)) - cam.location
cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_polyhaven_planks_closeup.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 5 — GLB EXPORT
# ============================================================
print("=== STAGE 5: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
wall_slab.select_set(True)
plank_slab.select_set(True)
bpy.context.view_layer.objects.active = wall_slab

out_path = os.path.join(EXPORT_DIR, "polyhaven_diorama_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
        export_image_format='AUTO',
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-21 Polyhaven re-texture complete ===")
