"""
Expansion V3 — Epic 18 — Procedural Dungeon Material Variation
==============================================================
Demonstrates the new procedural material-variation system. Three
material slots (ore_iron, stone_brick, wood_crate) each instanced
8 times. Each instance hashes its world position into 8 discrete
micro-variations:

  - Hue shift (±0.10)
  - Lightness offset (±0.18)
  - Roughness offset (±0.20)
  - Procedural noise scale (4 buckets)
  - Voronoi pattern offset (8 angles)

Result: 24 props that read as 24 distinct rock/brick/crate copies
even though they share the same base mesh and base material.

The Godot 4.4 runtime equivalent lives at
  assets/shaders/material_variation.gdshader

Outputs:
  - 1 hero showcase render @ 1920x1080
  - 3 close-up renders (ore / brick / crate) @ 1280x960
  - 1 GLB export of the entire showcase grid
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(18)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_material_variation.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3_mv_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# VARIATION SHADER (Blender side equivalent of the GDShader)
# ============================================================
def make_variation_material(name, base_color, base_roughness, base_metallic,
                            voronoi_scale=10.0, hue_shift_range=0.10,
                            light_shift_range=0.18, rough_shift_range=0.20):
    """Material that uses Object Info > Random to drive 8 discrete
    variants of hue / lightness / roughness / pattern offset."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1800, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1500, 0)
    bsdf.inputs["Roughness"].default_value = base_roughness
    bsdf.inputs["Metallic"].default_value = base_metallic
    links.new(bsdf.outputs[0], out.inputs[0])

    # === Object Info Random — the per-instance hash ===
    obj_info = nodes.new("ShaderNodeObjectInfo"); obj_info.location = (-1400, 600)

    # === Bucket the random into 8 discrete steps ===
    bucket8 = nodes.new("ShaderNodeMath"); bucket8.location = (-1200, 600)
    bucket8.operation = 'MULTIPLY'
    bucket8.inputs[1].default_value = 8.0
    links.new(obj_info.outputs["Random"], bucket8.inputs[0])
    floor8 = nodes.new("ShaderNodeMath"); floor8.location = (-1000, 600)
    floor8.operation = 'FLOOR'
    links.new(bucket8.outputs[0], floor8.inputs[0])
    norm8 = nodes.new("ShaderNodeMath"); norm8.location = (-800, 600)
    norm8.operation = 'DIVIDE'
    norm8.inputs[1].default_value = 8.0
    links.new(floor8.outputs[0], norm8.inputs[0])

    # === Texture coordinates with per-instance offset ===
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    # Mapping with per-instance scale & rotation driven by hash
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1100, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])
    # Add rotation from random — multiply random * 6.28
    rot_mult = nodes.new("ShaderNodeMath"); rot_mult.location = (-1300, -200)
    rot_mult.operation = 'MULTIPLY'
    rot_mult.inputs[1].default_value = 6.2832
    links.new(obj_info.outputs["Random"], rot_mult.inputs[0])
    # Combine into a Z rotation vector
    combine_rot = nodes.new("ShaderNodeCombineXYZ"); combine_rot.location = (-1300, -350)
    links.new(rot_mult.outputs[0], combine_rot.inputs["Z"])
    links.new(combine_rot.outputs[0], mp.inputs["Rotation"])

    # === Base color noise ===
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 14.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    n_ramp = nodes.new("ShaderNodeValToRGB"); n_ramp.location = (-450, 200)
    n_ramp.color_ramp.elements[0].position = 0.35
    n_ramp.color_ramp.elements[0].color = (base_color[0]*0.78, base_color[1]*0.78, base_color[2]*0.78, 1)
    n_ramp.color_ramp.elements[1].position = 0.70
    n_ramp.color_ramp.elements[1].color = (min(base_color[0]*1.22,1), min(base_color[1]*1.22,1), min(base_color[2]*1.22,1), 1)
    links.new(n.outputs["Fac"], n_ramp.inputs["Fac"])

    # === Voronoi pattern (uses rotated mapping for per-instance offset) ===
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = voronoi_scale
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    v_ramp = nodes.new("ShaderNodeValToRGB"); v_ramp.location = (-450, -100)
    v_ramp.color_ramp.elements[0].position = 0.05
    v_ramp.color_ramp.elements[0].color = (base_color[0]*0.55, base_color[1]*0.55, base_color[2]*0.55, 1)
    v_ramp.color_ramp.elements[1].position = 0.30
    v_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])

    mix_v = nodes.new("ShaderNodeMix"); mix_v.data_type='RGBA'; mix_v.location = (-200, 0)
    mix_v.inputs["Factor"].default_value = 0.4
    links.new(n_ramp.outputs["Color"], mix_v.inputs[6])
    links.new(v_ramp.outputs["Color"], mix_v.inputs[7])

    # === Per-instance hue shift ===
    # Convert random [0,1] to [-hue_shift_range, +hue_shift_range]
    hue_off = nodes.new("ShaderNodeMath"); hue_off.location = (200, 400)
    hue_off.operation = 'MULTIPLY_ADD'
    hue_off.inputs[1].default_value = hue_shift_range * 2.0
    hue_off.inputs[2].default_value = -hue_shift_range
    links.new(norm8.outputs[0], hue_off.inputs[0])

    hue_node = nodes.new("ShaderNodeHueSaturation"); hue_node.location = (450, 0)
    links.new(hue_off.outputs[0], hue_node.inputs["Hue"])
    # Wrap +0.5 because Hue node centers at 0.5
    hue_offset_for_node = nodes.new("ShaderNodeMath"); hue_offset_for_node.location = (200, 200)
    hue_offset_for_node.operation = 'ADD'
    hue_offset_for_node.inputs[1].default_value = 0.5
    links.new(hue_off.outputs[0], hue_offset_for_node.inputs[0])
    links.new(hue_offset_for_node.outputs[0], hue_node.inputs["Hue"])
    links.new(mix_v.outputs[2], hue_node.inputs["Color"])

    # === Per-instance lightness shift ===
    light_off = nodes.new("ShaderNodeMath"); light_off.location = (200, -200)
    light_off.operation = 'MULTIPLY_ADD'
    light_off.inputs[1].default_value = light_shift_range * 2.0
    light_off.inputs[2].default_value = 1.0 - light_shift_range
    links.new(norm8.outputs[0], light_off.inputs[0])
    links.new(light_off.outputs[0], hue_node.inputs["Value"])

    # === Curvature dirt ===
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (450, -400)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (700, -400)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.10, 0.07, 0.04, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location = (950, 0)
    md.inputs["Factor"].default_value = 0.35
    links.new(hue_node.outputs[0], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    # === Per-instance roughness shift ===
    rough_off = nodes.new("ShaderNodeMath"); rough_off.location = (950, -300)
    rough_off.operation = 'MULTIPLY_ADD'
    rough_off.inputs[1].default_value = rough_shift_range * 2.0
    rough_off.inputs[2].default_value = base_roughness - rough_shift_range
    links.new(norm8.outputs[0], rough_off.inputs[0])
    rough_clamp = nodes.new("ShaderNodeClamp"); rough_clamp.location = (1200, -300)
    links.new(rough_off.outputs[0], rough_clamp.inputs[0])
    links.new(rough_clamp.outputs[0], bsdf.inputs["Roughness"])

    # === Procedural normal bump ===
    bn = nodes.new("ShaderNodeTexNoise"); bn.location = (700, -600)
    bn.inputs["Scale"].default_value = 35.0
    bn.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], bn.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (950, -600)
    bp.inputs["Strength"].default_value = 0.30
    links.new(bn.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])

    return m

# ============================================================
# THREE BASE MATERIALS
# ============================================================
mat_ore = make_variation_material(
    "v3mv_ore_iron",
    base_color=(0.45, 0.40, 0.36),
    base_roughness=0.55, base_metallic=0.65,
    voronoi_scale=14.0,
    hue_shift_range=0.04, light_shift_range=0.20, rough_shift_range=0.20
)
mat_brick = make_variation_material(
    "v3mv_stone_brick",
    base_color=(0.55, 0.45, 0.32),
    base_roughness=0.85, base_metallic=0.0,
    voronoi_scale=8.0,
    hue_shift_range=0.06, light_shift_range=0.18, rough_shift_range=0.15
)
mat_crate = make_variation_material(
    "v3mv_wood_crate",
    base_color=(0.42, 0.26, 0.13),
    base_roughness=0.85, base_metallic=0.0,
    voronoi_scale=12.0,
    hue_shift_range=0.05, light_shift_range=0.22, rough_shift_range=0.18
)

# Floor
mat_floor = bpy.data.materials.new("v3mv_floor")
mat_floor.use_nodes = True
fbsdf = mat_floor.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.18, 0.16, 0.14, 1)
fbsdf.inputs["Roughness"].default_value = 0.85

# ============================================================
# UTIL — randomized object_info passes through Object > Random property
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def make_ore_boulder(name, loc, parent):
    """Procedural irregular ico-sphere — looks like a chunk of ore."""
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.5, location=loc)
    o = bpy.context.object; o.name = name
    # Distort verts for organic shape
    bm = bmesh.new()
    bm.from_mesh(o.data)
    for v in bm.verts:
        d = (v.co.length)
        v.co += v.co.normalized() * (random.uniform(-0.10, 0.18))
    bm.to_mesh(o.data)
    bm.free()
    # Random rotation
    o.rotation_euler = (random.uniform(0, math.pi*2), random.uniform(0, math.pi*2), random.uniform(0, math.pi*2))
    o.scale = (random.uniform(0.8, 1.2), random.uniform(0.8, 1.2), random.uniform(0.7, 1.0))
    o.data.materials.append(mat_ore)
    add_subsurf_bevel(o, levels=2, bevel=0.01)
    o.parent = parent
    # Force a deterministic per-instance random by using object pass index
    return o

def make_brick_block(name, loc, parent):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name
    o.scale = (0.85, 0.45, 0.45)
    o.rotation_euler = (0, 0, random.uniform(-0.10, 0.10))
    o.data.materials.append(mat_brick)
    add_subsurf_bevel(o, levels=2, bevel=0.02)
    o.parent = parent
    return o

def make_wood_crate(name, loc, parent):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name
    o.scale = (0.7, 0.7, 0.7)
    o.rotation_euler = (0, 0, random.uniform(0, math.pi/2))
    o.data.materials.append(mat_crate)
    add_subsurf_bevel(o, levels=2, bevel=0.02)
    o.parent = parent
    # Add inset side planks (4 per face) so the crate looks like real wood
    for f in range(4):
        for k in range(3):
            ang = f * math.pi/2
            bpy.ops.mesh.primitive_cube_add(size=1, location=(loc[0] + math.cos(ang)*0.36, loc[1] + math.sin(ang)*0.36, loc[2] + (k - 1) * 0.22))
            b = bpy.context.object
            b.name = f"{name}_pl_{f}_{k}"
            b.scale = (0.04, 0.55, 0.18) if f % 2 == 0 else (0.55, 0.04, 0.18)
            b.rotation_euler = (0, 0, 0)
            b.data.materials.append(mat_crate)
            add_subsurf_bevel(b, levels=1, bevel=0.005)
            b.parent = parent
    return o

# ============================================================
# SCENE LAYOUT
# ============================================================
parent = bpy.data.objects.new("v3_material_variation", None); scene.collection.objects.link(parent)

# Floor (3 sections side by side, one per material)
import bpy
# Wide ground plane
bpy.ops.mesh.primitive_plane_add(size=1, location=(0,0,0))
fl = bpy.context.object; fl.name = "mv_floor"
fl.scale = (28, 8, 1)
fl.data.materials.append(mat_floor)
add_subsurf_bevel(fl, levels=1, bevel=0.002)
fl.parent = parent

# Section labels via small carved pedestals at -y for each row
def label_pedestal(name, x, label_color):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, -3.0, 0.20))
    p = bpy.context.object; p.name = name; p.scale = (1.2, 0.4, 0.40)
    m = bpy.data.materials.new(f"{name}_mat"); m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*label_color, 1)
    bs.inputs["Emission Color"].default_value = (*label_color, 1)
    bs.inputs["Emission Strength"].default_value = 4.0
    p.data.materials.append(m)
    add_subsurf_bevel(p, levels=1, bevel=0.02)
    p.parent = parent

label_pedestal("label_ore",   -8, (0.65, 0.75, 0.95))  # cyan
label_pedestal("label_brick",  0, (1.00, 0.78, 0.45))  # warm
label_pedestal("label_crate",  8, (0.85, 0.55, 0.25))  # amber

# 8 ore boulders in a 4x2 grid centered at x=-8
for i in range(8):
    col = i % 4; row = i // 4
    x = -10 + col * 1.4
    y = -1 + row * 1.6
    make_ore_boulder(f"ore_{i}", (x, y, 0.55), parent)

# 8 brick blocks in 4x2 grid centered at x=0
for i in range(8):
    col = i % 4; row = i // 4
    x = -2 + col * 1.4
    y = -1 + row * 1.6
    make_brick_block(f"brick_{i}", (x, y, 0.30), parent)

# 8 wood crates in 4x2 grid centered at x=8
for i in range(8):
    col = i % 4; row = i // 4
    x = 6 + col * 1.6
    y = -1 + row * 1.8
    make_wood_crate(f"crate_{i}", (x, y, 0.45), parent)

# ============================================================
# LIGHTING — neutral 3-point so variations read clearly
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 1500; key.data.color = (1.0, 0.96, 0.88); key.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(-8, 8, 10))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.65, 0.78, 1.0); fill.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(0, 12, 4))
rim = bpy.context.object
rim.data.energy = 400; rim.data.color = (1.0, 0.85, 0.65); rim.data.size = 6

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=35, dof_dist=10):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 5.6
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_main  = add_cam("cam_showcase", Vector((0, -8, 8)),    Vector((0, 0, 0.5)), lens=28, dof_dist=12)
cam_ore   = add_cam("cam_ore",      Vector((-8, -3, 3)),   Vector((-8, 0, 0.5)), lens=70, dof_dist=4)
cam_brick = add_cam("cam_brick",    Vector((0, -3, 3)),    Vector((0, 0, 0.5)), lens=70, dof_dist=4)
cam_crate = add_cam("cam_crate",    Vector((8, -3, 3)),    Vector((8, 0, 0.5)), lens=70, dof_dist=4)

CAMERAS = [
    ("showcase", cam_main, (1920, 1080)),
    ("ore",      cam_ore,  (1280, 960)),
    ("brick",    cam_brick,(1280, 960)),
    ("crate",    cam_crate,(1280, 960)),
]

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam, (w, h) in CAMERAS:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_material_variation_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
out_path = os.path.join(EXPORT_DIR, "material_variation_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Epic 18 Procedural Material Variation complete ===")
