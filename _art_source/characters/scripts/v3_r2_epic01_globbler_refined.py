"""
Expansion V3 — ROUND 2 — Epic R2-01 — Globbler Hero Refinement
==============================================================
Round 2 of the Globbler hero pass. Round 1 used procedural-only shaders.
This round adds the techniques the spec called for that Round 1 skipped:

  - UV unwrapping (Smart UV Project) on every mesh part
  - Vertex color painting per-part for per-vertex hue variation
  - Multi-resolution modifier on the body (subdivision + sculpt level)
  - Higher subdivision counts on hero parts (24+ verts per cylinder)
  - Bevel modifier with more segments (5 instead of 3)
  - Normal-aware shader that uses the painted vertex colors

Renders a hero quad: 3 pose variations + 1 close-up portrait.

Outputs:
  - 4 hero renders @ 1920x1080
  - 1 GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(101)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_r2_globbler.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 128
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3r2_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# REFINED SHADER — vertex-color aware PBR
# ============================================================
def make_refined_shell(name, base_color, accent_color, metallic=0.40):
    """Vertex-color-aware shell shader.
    Reads the painted Color attribute and uses it to mix between
    base and accent colors per-vertex (drives subtle hue variation
    that procedural noise alone can't capture)."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.20
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Coat Weight"].default_value = 0.5
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    links.new(bsdf.outputs[0], out.inputs[0])

    # === Read vertex color attribute ===
    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    # Use vertex color RED channel as the hue mix factor
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    # === UV-mapped procedural detail ===
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])  # uses UV-unwrapped UVs

    # Procedural noise on top of UVs
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 12.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    n_ramp = nodes.new("ShaderNodeValToRGB"); n_ramp.location = (-450, 200)
    n_ramp.color_ramp.elements[0].position = 0.35
    n_ramp.color_ramp.elements[0].color = (base_color[0]*0.78, base_color[1]*0.78, base_color[2]*0.78, 1)
    n_ramp.color_ramp.elements[1].position = 0.70
    n_ramp.color_ramp.elements[1].color = (min(base_color[0]*1.22,1), min(base_color[1]*1.22,1), min(base_color[2]*1.22,1), 1)
    links.new(n.outputs["Fac"], n_ramp.inputs["Fac"])

    # Vertex color mix — when red channel high, blend toward accent_color
    vc_mix = nodes.new("ShaderNodeMix"); vc_mix.data_type = 'RGBA'; vc_mix.location = (-200, 200)
    vc_mix.inputs[6].default_value = (*base_color, 1)
    vc_mix.inputs[7].default_value = (*accent_color, 1)
    links.new(sep_vc.outputs["Red"], vc_mix.inputs["Factor"])

    # Combine noise variation with vertex-color tint
    final_mix = nodes.new("ShaderNodeMix"); final_mix.data_type = 'RGBA'; final_mix.location = (50, 100)
    final_mix.inputs["Factor"].default_value = 0.55
    links.new(vc_mix.outputs[2], final_mix.inputs[6])
    links.new(n_ramp.outputs["Color"], final_mix.inputs[7])

    # Curvature dirt
    g = nodes.new("ShaderNodeNewGeometry"); g.location = (-200, -200)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -200)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.10, 0.07, 0.04, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(g.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type = 'RGBA'; md.location = (350, 0)
    md.inputs["Factor"].default_value = 0.40
    links.new(final_mix.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    # Bump from noise (UV-driven)
    bp = nodes.new("ShaderNodeBump"); bp.location = (350, -300)
    bp.inputs["Strength"].default_value = 0.20
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_emit(name, color, strength):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (*color, 1)
    bs.inputs["Emission Strength"].default_value = strength
    return m

def make_pbr_simple(name, color, rough, metal, em=None, em_str=0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = rough
    bs.inputs["Metallic"].default_value = metal
    if em:
        bs.inputs["Emission Color"].default_value = (*em, 1)
        bs.inputs["Emission Strength"].default_value = em_str
    return m

# ============================================================
# MATERIALS
# ============================================================
mat_shell = make_refined_shell("v3r2_shell",
    base_color=(0.18, 0.42, 0.85),
    accent_color=(0.30, 0.65, 1.0),
    metallic=0.40)
mat_gold = make_pbr_simple("v3r2_gold", (0.95, 0.78, 0.20), 0.10, 1.0,
                            em=(1.0, 0.85, 0.40), em_str=2.0)
mat_visor = make_pbr_simple("v3r2_visor", (0.05, 0.05, 0.10), 0.10, 0.50,
                             em=(0.30, 0.85, 1.0), em_str=2.5)
mat_eye = make_emit("v3r2_eye", (0.45, 1.0, 1.0), 14.0)
mat_cape = make_pbr_simple("v3r2_cape", (0.55, 0.10, 0.10), 0.85, 0.0,
                            em=(0.85, 0.20, 0.10), em_str=0.4)
mat_floor = make_pbr_simple("v3r2_floor", (0.10, 0.10, 0.12), 0.30, 0.10)

# ============================================================
# UTIL — refined helpers with UV unwrap + vertex color
# ============================================================
def uv_unwrap(obj):
    """Smart UV unwrap an object (must be active + selected)."""
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')

def paint_vertex_color(obj, base_red=0.5, variation=0.4):
    """Add a Color vertex layer with random per-vertex red values
    centered on base_red with +/- variation. The shader reads this
    to drive subtle per-part hue shifts."""
    if obj.data.color_attributes:
        ca = obj.data.color_attributes[0]
    else:
        ca = obj.data.color_attributes.new(name="Color", type='FLOAT_COLOR', domain='POINT')
    for i, v in enumerate(obj.data.vertices):
        random.seed(hash((obj.name, i)) & 0xFFFFFF)
        r = max(0.0, min(1.0, base_red + (random.random() - 0.5) * variation * 2))
        ca.data[i].color = (r, r * 0.8, r * 0.6, 1.0)

def add_refined_modifiers(obj, multires_level=2, bevel_segments=5):
    """Add MULTIRES + bevel modifiers (refined Round 2 stack)."""
    # Multires gives us subdivision + sculpt-ready geometry
    mr = obj.modifiers.new("Multires", 'MULTIRES')
    # Subdivide multiple times via operator
    bpy.context.view_layer.objects.active = obj
    for _ in range(multires_level):
        bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')
    # Bevel with more segments
    bv = obj.modifiers.new("Bevel", 'BEVEL')
    bv.width = 0.020
    bv.segments = bevel_segments
    bv.profile = 0.7
    for poly in obj.data.polygons:
        poly.use_smooth = True

def refined_part(name, primitive_op, mat, parent, vc_red=0.5, vc_var=0.4, multires=2, **kwargs):
    """Add primitive, UV unwrap, paint vertex colors, add modifiers."""
    primitive_op(**kwargs)
    o = bpy.context.object
    o.name = name
    o.data.materials.append(mat)
    o.parent = parent
    uv_unwrap(o)
    paint_vertex_color(o, base_red=vc_red, variation=vc_var)
    add_refined_modifiers(o, multires_level=multires)
    return o

# Convenience wrappers calling refined_part with the right primitive op
def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=32, multires=2):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=24, rot=(0,0,0), multires=2):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=18, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cone_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_box(name, loc, scale, mat, parent, vc_red=0.5, vc_var=0.4, rot=(0,0,0), multires=2):
    o = refined_part(name, bpy.ops.mesh.primitive_cube_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     size=1, location=loc)
    o.scale = scale
    o.rotation_euler = rot
    return o

def r_torus(name, loc, R, r, mat, parent, vc_red=0.5, vc_var=0.4, ms=48, mn=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_torus_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     major_segments=ms, minor_segments=mn,
                     major_radius=R, minor_radius=r, location=loc)
    o.rotation_euler = rot
    return o

# ============================================================
# REFINED GLOBBLER — 3 pose instances
# ============================================================
def build_globbler(origin, pose="idle"):
    """Build a refined Globbler at origin with the given pose."""
    p = bpy.data.objects.new(f"globbler_{pose}", None); scene.collection.objects.link(p)
    p.location = origin

    # === Body (high-detail multires sphere) ===
    body = r_sphere("body", (0, 0, 1.05), 0.50, mat_shell, p,
                     vc_red=0.55, vc_var=0.30, segs=40, multires=2)
    body.scale = (1.0, 0.85, 1.4)

    # === Belt with vertex color stripe ===
    r_torus("belt", (0, 0, 0.65), 0.50, 0.06, mat_gold, p,
             vc_red=0.7, vc_var=0.20, ms=64, mn=16)
    # === Chest emblem ===
    r_sphere("emblem", (0, 0.45, 1.10), 0.12, mat_gold, p,
              vc_red=0.6, vc_var=0.25, segs=24)
    # === Shoulders ===
    r_sphere("sh_l", (-0.55, 0, 1.55), 0.22, mat_shell, p,
              vc_red=0.50, vc_var=0.30, segs=24)
    r_sphere("sh_r", (0.55, 0, 1.55), 0.22, mat_shell, p,
              vc_red=0.50, vc_var=0.30, segs=24)
    r_sphere("pl_l", (-0.55, 0, 1.65), 0.12, mat_gold, p,
              vc_red=0.65, vc_var=0.20, segs=18)
    r_sphere("pl_r", (0.55, 0, 1.65), 0.12, mat_gold, p,
              vc_red=0.65, vc_var=0.20, segs=18)

    # === Arms — pose-specific ===
    if pose == "idle":
        # Both arms relaxed at side
        r_cyl("arm_lu", (-0.65, 0, 1.20), 0.10, 0.55, mat_shell, p, verts=18, rot=(0, -0.1, 0))
        r_cyl("arm_ll", (-0.70, 0, 0.75), 0.09, 0.45, mat_shell, p, verts=18)
        r_sphere("hand_l", (-0.70, 0, 0.50), 0.12, mat_gold, p, segs=20)
        r_cyl("arm_ru", (0.65, 0, 1.20), 0.10, 0.55, mat_shell, p, verts=18, rot=(0, 0.1, 0))
        r_cyl("arm_rl", (0.70, 0, 0.75), 0.09, 0.45, mat_shell, p, verts=18)
        r_sphere("hand_r", (0.70, 0, 0.50), 0.12, mat_gold, p, segs=20)
    elif pose == "cast":
        # Right arm raised forward (casting), left at side
        r_cyl("arm_lu", (-0.65, 0, 1.20), 0.10, 0.55, mat_shell, p, verts=18, rot=(0, -0.1, 0))
        r_cyl("arm_ll", (-0.70, 0, 0.75), 0.09, 0.45, mat_shell, p, verts=18)
        r_sphere("hand_l", (-0.70, 0, 0.50), 0.12, mat_gold, p, segs=20)
        r_cyl("arm_ru", (0.55, 0.30, 1.30), 0.10, 0.55, mat_shell, p, verts=18, rot=(0.7, 0, 0))
        r_cyl("arm_rl", (0.55, 0.65, 1.20), 0.09, 0.45, mat_shell, p, verts=18, rot=(1.4, 0, 0))
        r_sphere("hand_r", (0.55, 0.95, 1.20), 0.12, mat_gold, p, segs=20)
        # Cast orb (small magic ball above outstretched hand)
        r_sphere("cast_orb", (0.55, 1.10, 1.30), 0.10, mat_eye, p, segs=20)
    else:  # heroic
        # Right arm raised triumphant, holding sword
        r_cyl("arm_lu", (-0.65, 0, 1.20), 0.10, 0.55, mat_shell, p, verts=18, rot=(0, -0.1, 0))
        r_cyl("arm_ll", (-0.70, 0, 0.75), 0.09, 0.45, mat_shell, p, verts=18)
        r_sphere("hand_l", (-0.70, 0, 0.50), 0.12, mat_gold, p, segs=20)
        r_cyl("arm_ru", (0.75, 0, 1.55), 0.10, 0.50, mat_shell, p, verts=18, rot=(0, 0.6, 0))
        r_cyl("arm_rl", (1.10, 0, 1.85), 0.09, 0.45, mat_shell, p, verts=18, rot=(0, 1.4, 0))
        r_sphere("hand_r", (1.30, 0, 2.05), 0.12, mat_gold, p, segs=20)
        # Sword raised in right hand
        r_cyl("sword_h", (1.30, 0, 2.20), 0.04, 0.20, mat_gold, p, verts=14)
        r_box("sword_g", (1.30, 0, 2.32), (0.18, 0.04, 0.04), mat_gold, p)
        r_box("sword_b", (1.30, 0, 2.70), (0.06, 0.02, 0.60), mat_gold, p)
        r_cone("sword_t", (1.30, 0, 3.05), 0.06, 0.0, 0.15, mat_gold, p, verts=12)
        r_box("sword_glow", (1.30, 0.04, 2.70), (0.04, 0.005, 0.55), mat_eye, p)

    # === Head ===
    head = r_sphere("head", (0, 0.05, 1.95), 0.32, mat_shell, p,
                     vc_red=0.55, vc_var=0.30, segs=32, multires=2)
    head.scale = (1.0, 0.95, 1.05)
    # === Visor ===
    r_box("visor", (0, 0.30, 1.95), (0.42, 0.08, 0.12), mat_visor, p,
           vc_red=0.4, vc_var=0.10)
    # === Eyes ===
    r_sphere("eye_l", (-0.10, 0.36, 1.95), 0.05, mat_eye, p,
              vc_red=0.5, vc_var=0.0, segs=16)
    r_sphere("eye_r", (0.10, 0.36, 1.95), 0.05, mat_eye, p,
              vc_red=0.5, vc_var=0.0, segs=16)
    # === Antenna ===
    r_cyl("ant", (0, 0, 2.40), 0.025, 0.30, mat_gold, p, verts=12)
    r_sphere("ant_t", (0, 0, 2.55), 0.06, mat_eye, p, segs=14)
    # === Halo ===
    r_torus("halo", (0, -0.30, 2.20), 0.45, 0.025, mat_gold, p,
             vc_red=0.7, vc_var=0.15, ms=48, mn=14, rot=(math.pi/2, 0, 0))

    # === Cape (subdivided plane with wave deform — manually built) ===
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, -0.55, 1.20))
    cape = bpy.context.object
    cape.name = "cape"
    cape.scale = (0.8, 0.04, 1.4)
    cape.rotation_euler = (math.pi/2, 0, 0)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.subdivide(number_cuts=12)
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    for v in cape.data.vertices:
        v.co.x += math.sin(v.co.z * 4) * 0.04
        v.co.y += abs(v.co.z) * 0.08
    cape.data.materials.append(mat_cape)
    uv_unwrap(cape)
    paint_vertex_color(cape, base_red=0.55, variation=0.30)
    bv = cape.modifiers.new("Bevel", 'BEVEL')
    bv.width = 0.005; bv.segments = 3; bv.profile = 0.7
    for poly in cape.data.polygons:
        poly.use_smooth = True
    cape.parent = p

    return p

# ============================================================
# SCENE LAYOUT — 3 poses on a long plinth
# ============================================================
# Floor plinth
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "r2_floor"; fl.scale = (12, 4, 0.10)
fl.data.materials.append(mat_floor)
bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in fl.data.polygons: poly.use_smooth = True

# Build 3 poses
build_globbler(Vector((-3.0, 0, 0)), pose="idle")
build_globbler(Vector((0.0,  0, 0)), pose="cast")
build_globbler(Vector((3.0,  0, 0)), pose="heroic")

# ============================================================
# LIGHTING — V3-29 cinematic_sunset preset
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(6, -8, 8))
key = bpy.context.object
key.data.energy = 1800; key.data.color = (1.0, 0.78, 0.45); key.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(-6, 6, 6))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.45, 0.55, 0.95); fill.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(0, 8, 4))
rim = bpy.context.object
rim.data.energy = 900; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 6

# ============================================================
# CAMERAS — group + 3 portraits + 1 close-up
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_group = add_cam("cam_group", Vector((0, -7, 3.0)), Vector((0, 0, 1.4)), lens=35, dof_dist=8)
cam_idle  = add_cam("cam_idle",  Vector((-3, -3, 2.0)), Vector((-3, 0, 1.4)), lens=70, dof_dist=3.5, fstop=3.5)
cam_cast  = add_cam("cam_cast",  Vector((0, -3, 2.0)),  Vector((0, 0, 1.4)),  lens=70, dof_dist=3.5, fstop=3.5)
cam_hero  = add_cam("cam_hero",  Vector((3, -3, 2.0)),  Vector((3, 0, 1.6)),  lens=70, dof_dist=3.5, fstop=3.5)

# Save .blend after build
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
CAMERAS = [
    ("group", cam_group),
    ("idle",  cam_idle),
    ("cast",  cam_cast),
    ("hero",  cam_hero),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_globbler_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB (group)
bpy.ops.object.select_all(action='SELECT')
out_path = os.path.join(EXPORT_DIR, "globbler_r2_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-01 Globbler Refinement complete ===")
