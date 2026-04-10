"""
Expansion V3 — ROUND 2 — Epic R2-04 — Companion Refinement
==========================================================
Round 2 of V3-04 Companions. 4 companions w/ distinct build silhouettes
+ Round 2 stack (Smart UV unwrap + vertex color paint + multires + 5-seg
bevel + vertex-color-aware shaders).

  TANK    — heavy cube body, plate armor, war banner
  DPS     — lean sphere body, agile pose, dual short blades
  HEALER  — robe cone body, holy staff w/ glow orb, halo
  UTILITY — compact ico body, satchel, lock pick toolkit on belt

Outputs: 5 hero renders @ 1920x1080 + 4 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(104)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_r2_companions.blend"
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

scene.world = bpy.data.worlds.new("v3r2_comp_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# REFINED VC-AWARE SHELL SHADER
# ============================================================
def make_vc_shell(name, base_color, accent_color, metallic=0.40, rough=0.20):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Coat Weight"].default_value = 0.4
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    links.new(bsdf.outputs[0], out.inputs[0])

    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

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

    vc_mix = nodes.new("ShaderNodeMix"); vc_mix.data_type = 'RGBA'; vc_mix.location = (-200, 200)
    vc_mix.inputs[6].default_value = (*base_color, 1)
    vc_mix.inputs[7].default_value = (*accent_color, 1)
    links.new(sep_vc.outputs["Red"], vc_mix.inputs["Factor"])

    final_mix = nodes.new("ShaderNodeMix"); final_mix.data_type = 'RGBA'; final_mix.location = (50, 100)
    final_mix.inputs["Factor"].default_value = 0.55
    links.new(vc_mix.outputs[2], final_mix.inputs[6])
    links.new(n_ramp.outputs["Color"], final_mix.inputs[7])

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

    bp = nodes.new("ShaderNodeBump"); bp.location = (350, -350)
    bp.inputs["Strength"].default_value = 0.20
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_pbr_simple(name, color, rough, metal=0.0, em=None, em_str=0):
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

def make_emit(name, color, strength):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (*color, 1)
    bs.inputs["Emission Strength"].default_value = strength
    return m

# ============================================================
# COMPANION PALETTES (4 sets)
# ============================================================
PALETTES = {
    "tank": {
        "shell":  make_vc_shell("v3r2c_tank", (0.32, 0.30, 0.34), (0.45, 0.42, 0.48), 0.85, 0.30),
        "trim":   make_pbr_simple("v3r2c_tank_trim", (0.85, 0.65, 0.20), 0.20, 0.92,
                                   em=(1.0, 0.85, 0.30), em_str=1.5),
        "metal":  make_pbr_simple("v3r2c_tank_metal", (0.18, 0.20, 0.24), 0.40, 0.92),
        "fabric": make_pbr_simple("v3r2c_tank_fabric", (0.55, 0.10, 0.10), 0.85,
                                   em=(0.85, 0.20, 0.10), em_str=0.4),
        "eye":    make_emit("v3r2c_tank_eye", (1.0, 0.85, 0.30), 12.0),
        "visor":  make_pbr_simple("v3r2c_tank_visor", (0.05, 0.05, 0.10), 0.10, 0.50,
                                   em=(1.0, 0.85, 0.30), em_str=2.0),
    },
    "dps": {
        "shell":  make_vc_shell("v3r2c_dps", (0.55, 0.10, 0.30), (0.75, 0.18, 0.40), 0.40, 0.20),
        "trim":   make_pbr_simple("v3r2c_dps_trim", (0.95, 0.20, 0.10), 0.10, 0.85,
                                   em=(1.0, 0.40, 0.20), em_str=2.5),
        "metal":  make_pbr_simple("v3r2c_dps_metal", (0.30, 0.30, 0.32), 0.30, 0.92),
        "fabric": make_pbr_simple("v3r2c_dps_fabric", (0.20, 0.05, 0.10), 0.85),
        "eye":    make_emit("v3r2c_dps_eye", (1.0, 0.40, 0.20), 14.0),
        "visor":  make_pbr_simple("v3r2c_dps_visor", (0.05, 0.02, 0.04), 0.10, 0.50,
                                   em=(1.0, 0.30, 0.20), em_str=2.5),
    },
    "healer": {
        "shell":  make_vc_shell("v3r2c_heal", (0.85, 0.78, 0.62), (0.95, 0.88, 0.72), 0.10, 0.55),
        "trim":   make_pbr_simple("v3r2c_heal_trim", (0.95, 0.85, 0.55), 0.20, 0.20,
                                   em=(1.0, 0.92, 0.65), em_str=2.0),
        "metal":  make_pbr_simple("v3r2c_heal_metal", (0.95, 0.78, 0.20), 0.10, 1.0,
                                   em=(1.0, 0.85, 0.40), em_str=1.5),
        "fabric": make_pbr_simple("v3r2c_heal_fabric", (0.30, 0.50, 0.85), 0.85),
        "eye":    make_emit("v3r2c_heal_eye", (0.95, 0.95, 1.0), 14.0),
        "visor":  make_pbr_simple("v3r2c_heal_visor", (0.85, 0.85, 0.92), 0.10, 0.30,
                                   em=(1.0, 0.95, 0.85), em_str=2.5),
    },
    "utility": {
        "shell":  make_vc_shell("v3r2c_util", (0.18, 0.32, 0.18), (0.28, 0.45, 0.25), 0.20, 0.55),
        "trim":   make_pbr_simple("v3r2c_util_trim", (0.32, 0.55, 0.32), 0.30, 0.20,
                                   em=(0.45, 0.85, 0.45), em_str=1.0),
        "metal":  make_pbr_simple("v3r2c_util_metal", (0.42, 0.42, 0.45), 0.30, 0.85),
        "fabric": make_pbr_simple("v3r2c_util_fabric", (0.22, 0.16, 0.10), 0.85),
        "eye":    make_emit("v3r2c_util_eye", (0.45, 1.0, 0.45), 14.0),
        "visor":  make_pbr_simple("v3r2c_util_visor", (0.05, 0.10, 0.05), 0.10, 0.40,
                                   em=(0.30, 0.85, 0.30), em_str=2.0),
    },
}

mat_floor = make_pbr_simple("v3r2c_floor", (0.10, 0.10, 0.12), 0.30, 0.10)

# ============================================================
# UTIL — refined helpers
# ============================================================
def uv_unwrap(obj):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')

def paint_vertex_color(obj, base_red=0.5, variation=0.4):
    if obj.data.color_attributes:
        ca = obj.data.color_attributes[0]
    else:
        ca = obj.data.color_attributes.new(name="Color", type='FLOAT_COLOR', domain='POINT')
    for i, v in enumerate(obj.data.vertices):
        random.seed(hash((obj.name, i)) & 0xFFFFFF)
        r = max(0.0, min(1.0, base_red + (random.random() - 0.5) * variation * 2))
        ca.data[i].color = (r, r * 0.8, r * 0.6, 1.0)

def add_refined_modifiers(obj, multires_level=2, bevel_segments=5):
    obj.modifiers.new("Multires", 'MULTIRES')
    bpy.context.view_layer.objects.active = obj
    for _ in range(multires_level):
        bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')
    bv = obj.modifiers.new("Bevel", 'BEVEL')
    bv.width = 0.020; bv.segments = bevel_segments; bv.profile = 0.7
    for poly in obj.data.polygons:
        poly.use_smooth = True

def refined_part(name, primitive_op, mat, parent, vc_red=0.5, vc_var=0.4, multires=2, **kwargs):
    primitive_op(**kwargs)
    o = bpy.context.object
    o.name = name
    o.data.materials.append(mat)
    o.parent = parent
    uv_unwrap(o)
    paint_vertex_color(o, base_red=vc_red, variation=vc_var)
    add_refined_modifiers(o, multires_level=multires)
    return o

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

def r_ico(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, sub=2, multires=2):
    o = refined_part(name, bpy.ops.mesh.primitive_ico_sphere_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     subdivisions=sub, radius=r, location=loc)
    return o

# ============================================================
# COMPANION BUILDERS — distinct silhouettes per role
# ============================================================
def build_tank(origin):
    p = bpy.data.objects.new("comp_tank", None); scene.collection.objects.link(p)
    p.location = origin
    pal = PALETTES["tank"]
    # HEAVY CUBE BODY — wide stance, blocky chest
    body = r_box("body", (0, 0, 1.10), (1.10, 0.85, 1.30), pal["shell"], p,
                  vc_red=0.55, vc_var=0.30)
    # Chest plate trim
    r_box("chest_plate", (0, 0.42, 1.20), (0.95, 0.06, 0.85), pal["metal"], p)
    # Center emblem
    r_sphere("emblem", (0, 0.48, 1.20), 0.14, pal["trim"], p, vc_red=0.7, vc_var=0.20, segs=20)
    # Heavy pauldrons
    r_box("pl_l", (-0.70, 0, 1.65), (0.50, 0.55, 0.30), pal["metal"], p,
           vc_red=0.55, vc_var=0.20, rot=(0, -0.2, 0))
    r_box("pl_r", (0.70, 0, 1.65), (0.50, 0.55, 0.30), pal["metal"], p,
           vc_red=0.55, vc_var=0.20, rot=(0, 0.2, 0))
    r_sphere("pl_l_top", (-0.85, 0, 1.78), 0.12, pal["trim"], p, segs=16)
    r_sphere("pl_r_top", (0.85, 0, 1.78), 0.12, pal["trim"], p, segs=16)
    # Helmet (boxy)
    r_box("head", (0, 0.05, 1.95), (0.50, 0.45, 0.40), pal["shell"], p,
           vc_red=0.55, vc_var=0.30)
    r_box("visor", (0, 0.30, 1.92), (0.42, 0.04, 0.10), pal["visor"], p)
    r_sphere("eye_l", (-0.10, 0.34, 1.92), 0.05, pal["eye"], p, segs=14)
    r_sphere("eye_r", (0.10, 0.34, 1.92), 0.05, pal["eye"], p, segs=14)
    # Helmet crest (3 spikes)
    for i, dx in enumerate([-0.12, 0, 0.12]):
        r_box(f"crest_{i}", (dx, -0.05, 2.20), (0.04, 0.06, 0.18), pal["trim"], p)
    # Massive arms folded across chest (wide stance)
    r_cyl("arm_lu", (-0.65, 0.10, 1.30), 0.14, 0.50, pal["shell"], p, verts=20, rot=(0, -0.3, 0))
    r_cyl("arm_ll", (-0.45, 0.40, 1.10), 0.13, 0.50, pal["shell"], p, verts=20, rot=(0.6, 0, 0.5))
    r_box("hand_l", (-0.20, 0.50, 1.10), (0.18, 0.20, 0.15), pal["metal"], p)
    r_cyl("arm_ru", (0.65, 0.10, 1.30), 0.14, 0.50, pal["shell"], p, verts=20, rot=(0, 0.3, 0))
    r_cyl("arm_rl", (0.45, 0.40, 1.10), 0.13, 0.50, pal["shell"], p, verts=20, rot=(0.6, 0, -0.5))
    r_box("hand_r", (0.20, 0.50, 1.10), (0.18, 0.20, 0.15), pal["metal"], p)
    # Heavy boots (stubby legs visible at base)
    r_box("leg_l", (-0.30, 0, 0.30), (0.30, 0.30, 0.40), pal["shell"], p)
    r_box("leg_r", (0.30, 0, 0.30), (0.30, 0.30, 0.40), pal["shell"], p)
    r_box("boot_l", (-0.30, 0.05, 0.06), (0.34, 0.40, 0.10), pal["metal"], p)
    r_box("boot_r", (0.30, 0.05, 0.06), (0.34, 0.40, 0.10), pal["metal"], p)
    # War banner on back (planted between shoulders)
    r_cyl("banner_pole", (0, -0.55, 1.85), 0.04, 1.40, pal["metal"], p, verts=10)
    r_box("banner_flag", (0.20, -0.55, 2.20), (0.40, 0.02, 0.55), pal["fabric"], p)
    return p

def build_dps(origin):
    p = bpy.data.objects.new("comp_dps", None); scene.collection.objects.link(p)
    p.location = origin
    pal = PALETTES["dps"]
    # LEAN SPHERE BODY — agile, narrow shoulders
    body = r_sphere("body", (0, 0, 1.05), 0.40, pal["shell"], p,
                     vc_red=0.55, vc_var=0.30, segs=32)
    body.scale = (0.85, 0.75, 1.5)
    # Belt with knife sheaths
    r_torus("belt", (0, 0, 0.55), 0.42, 0.05, pal["trim"], p, vc_red=0.7, vc_var=0.20)
    # 3 small dagger sheaths on belt
    for i, ang in enumerate([0.4, 0.0, -0.4]):
        bx = math.cos(ang) * 0.42
        by = math.sin(ang) * 0.42
        r_cyl(f"sheath_{i}", (bx, by + 0.20, 0.40), 0.025, 0.20, pal["fabric"], p, verts=10)
        r_sphere(f"sheath_top_{i}", (bx, by + 0.20, 0.50), 0.025, pal["trim"], p, segs=10)
    # Slim shoulders
    r_sphere("sh_l", (-0.42, 0, 1.40), 0.16, pal["shell"], p, segs=20)
    r_sphere("sh_r", (0.42, 0, 1.40), 0.16, pal["shell"], p, segs=20)
    # Thin pauldron blades
    r_cone("pl_l", (-0.42, 0, 1.55), 0.10, 0.0, 0.20, pal["trim"], p, verts=8, rot=(0, -0.4, 0))
    r_cone("pl_r", (0.42, 0, 1.55), 0.10, 0.0, 0.20, pal["trim"], p, verts=8, rot=(0, 0.4, 0))
    # Head w/ hood-like cowl
    head = r_sphere("head", (0, 0.05, 1.85), 0.27, pal["shell"], p, segs=24)
    head.scale = (1.0, 0.95, 1.10)
    # Cowl (dark sphere over head)
    cowl = r_sphere("cowl", (0, -0.05, 1.95), 0.32, pal["fabric"], p, segs=24)
    cowl.scale = (1.05, 1.10, 0.85)
    r_box("visor", (0, 0.25, 1.85), (0.38, 0.06, 0.10), pal["visor"], p)
    r_sphere("eye_l", (-0.08, 0.30, 1.85), 0.04, pal["eye"], p, segs=12)
    r_sphere("eye_r", (0.08, 0.30, 1.85), 0.04, pal["eye"], p, segs=12)
    # Lean arms — both forward holding daggers
    r_cyl("arm_lu", (-0.45, 0.20, 1.15), 0.08, 0.50, pal["shell"], p, verts=18, rot=(0.6, 0, 0))
    r_cyl("arm_ll", (-0.45, 0.55, 0.90), 0.07, 0.45, pal["shell"], p, verts=18, rot=(1.2, 0, 0))
    r_sphere("hand_l", (-0.45, 0.85, 0.90), 0.08, pal["metal"], p, segs=16)
    r_cyl("arm_ru", (0.45, 0.20, 1.15), 0.08, 0.50, pal["shell"], p, verts=18, rot=(0.6, 0, 0))
    r_cyl("arm_rl", (0.45, 0.55, 0.90), 0.07, 0.45, pal["shell"], p, verts=18, rot=(1.2, 0, 0))
    r_sphere("hand_r", (0.45, 0.85, 0.90), 0.08, pal["metal"], p, segs=16)
    # 2 short blades (one per hand)
    for side in [-1, 1]:
        sx = side * 0.45
        r_cyl(f"blade_h_{side}", (sx, 0.95, 0.90), 0.025, 0.10, pal["trim"], p, verts=10)
        r_box(f"blade_b_{side}", (sx, 1.20, 0.90), (0.04, 0.02, 0.40), pal["metal"], p)
        r_cone(f"blade_t_{side}", (sx, 1.45, 0.90), 0.04, 0.0, 0.10, pal["metal"], p, verts=8)
        r_box(f"blade_g_{side}", (sx, 1.20, 0.94), (0.025, 0.005, 0.36), pal["trim"], p)
    # Slim legs (visible boots)
    r_cyl("leg_l", (-0.18, 0, 0.30), 0.10, 0.50, pal["shell"], p, verts=14)
    r_cyl("leg_r", (0.18, 0, 0.30), 0.10, 0.50, pal["shell"], p, verts=14)
    r_box("boot_l", (-0.18, 0.05, 0.06), (0.20, 0.30, 0.08), pal["metal"], p)
    r_box("boot_r", (0.18, 0.05, 0.06), (0.20, 0.30, 0.08), pal["metal"], p)
    return p

def build_healer(origin):
    p = bpy.data.objects.new("comp_healer", None); scene.collection.objects.link(p)
    p.location = origin
    pal = PALETTES["healer"]
    # ROBE CONE BODY
    r_cone("robe", (0, 0, 0.60), 0.85, 0.45, 1.20, pal["fabric"], p,
            vc_red=0.55, vc_var=0.25, verts=32, multires=2)
    # Body sphere on top of robe
    body = r_sphere("body", (0, 0, 1.30), 0.38, pal["shell"], p,
                     vc_red=0.55, vc_var=0.25, segs=32)
    body.scale = (1.0, 0.85, 1.10)
    # Gold sash crossing chest
    r_box("sash", (0, 0.32, 1.30), (0.85, 0.04, 0.20), pal["trim"], p, rot=(0, 0, 0.3))
    # Belt
    r_torus("belt", (0, 0, 0.95), 0.50, 0.05, pal["trim"], p, vc_red=0.7, vc_var=0.20)
    # Soft shoulders (no rigid pauldrons, just sphere caps)
    r_sphere("sh_l", (-0.45, 0, 1.55), 0.18, pal["fabric"], p, segs=20)
    r_sphere("sh_r", (0.45, 0, 1.55), 0.18, pal["fabric"], p, segs=20)
    # Hood
    hood = r_sphere("hood", (0, 0, 1.85), 0.32, pal["fabric"], p, segs=24)
    hood.scale = (1.10, 1.10, 1.10)
    # Inner face (lighter shell)
    r_sphere("face", (0, 0.08, 1.82), 0.24, pal["shell"], p, segs=24)
    r_sphere("eye_l", (-0.08, 0.25, 1.85), 0.04, pal["eye"], p, segs=12)
    r_sphere("eye_r", (0.08, 0.25, 1.85), 0.04, pal["eye"], p, segs=12)
    # Hood golden trim
    r_torus("hood_trim", (0, 0, 1.65), 0.34, 0.018, pal["trim"], p, ms=32, mn=10)
    # Arms — right holds staff, left palm-up channeling
    r_cyl("arm_lu", (-0.55, 0.10, 1.30), 0.10, 0.55, pal["fabric"], p, verts=18, rot=(0.4, 0, 0))
    r_cyl("arm_ll", (-0.55, 0.45, 1.05), 0.09, 0.45, pal["fabric"], p, verts=18, rot=(1.0, 0, 0))
    r_sphere("hand_l", (-0.55, 0.75, 1.05), 0.10, pal["shell"], p, segs=18)
    # Healing orb floating above left palm
    r_sphere("heal_orb", (-0.55, 0.75, 1.30), 0.12, pal["eye"], p, segs=20)
    r_torus("heal_ring", (-0.55, 0.75, 1.30), 0.18, 0.012, pal["eye"], p, ms=24, mn=8)
    # Right arm holds tall staff
    r_cyl("arm_ru", (0.55, 0, 1.30), 0.10, 0.55, pal["fabric"], p, verts=18, rot=(0, 0.1, 0))
    r_cyl("arm_rl", (0.65, 0, 0.85), 0.09, 0.45, pal["fabric"], p, verts=18)
    r_sphere("hand_r", (0.65, 0, 0.60), 0.10, pal["shell"], p, segs=18)
    r_cyl("staff", (0.65, 0, 1.40), 0.04, 2.20, pal["metal"], p, verts=14)
    # Staff top — radiant gem in 4-claw cradle
    r_sphere("staff_gem", (0.65, 0, 2.40), 0.12, pal["eye"], p, segs=20)
    for j in range(4):
        ang = j * math.pi / 2
        cx = 0.65 + math.cos(ang) * 0.12
        cy = math.sin(ang) * 0.12
        r_cone(f"staff_claw_{j}", (cx, cy, 2.30), 0.025, 0.0, 0.20, pal["trim"], p, verts=8,
                rot=(math.cos(ang)*0.8, math.sin(ang)*0.8, ang))
    # Halo behind head
    r_torus("halo", (0, -0.30, 2.15), 0.42, 0.02, pal["trim"], p, ms=48, mn=12, rot=(math.pi/2, 0, 0))
    return p

def build_utility(origin):
    p = bpy.data.objects.new("comp_utility", None); scene.collection.objects.link(p)
    p.location = origin
    pal = PALETTES["utility"]
    # COMPACT ICO BODY — short, geometric
    body = r_ico("body", (0, 0, 0.95), 0.45, pal["shell"], p,
                  vc_red=0.55, vc_var=0.30, sub=3)
    body.scale = (1.0, 0.85, 1.10)
    # Belt with tools
    r_torus("belt", (0, 0, 0.55), 0.45, 0.05, pal["trim"], p, vc_red=0.7, vc_var=0.20)
    # Lock pick toolkit on belt (3 tiny pick boxes hanging)
    for i, ang in enumerate([0.3, 0.0, -0.3]):
        bx = math.cos(ang) * 0.45
        by = math.sin(ang) * 0.45 + 0.20
        r_box(f"pick_{i}", (bx, by, 0.40), (0.06, 0.04, 0.18), pal["metal"], p)
    # Satchel on left side
    r_box("satchel_b", (-0.50, 0.10, 0.65), (0.20, 0.30, 0.30), pal["fabric"], p,
           vc_red=0.55, vc_var=0.25)
    r_box("satchel_lid", (-0.50, 0.10, 0.82), (0.20, 0.30, 0.05), pal["fabric"], p)
    r_sphere("satchel_clasp", (-0.50, 0.27, 0.78), 0.025, pal["trim"], p, segs=10)
    # Belt strap from shoulder to satchel
    r_box("strap", (-0.30, 0.20, 1.10), (0.06, 0.04, 0.50), pal["fabric"], p, rot=(0, 0.4, 0))
    # Slim shoulders
    r_sphere("sh_l", (-0.42, 0, 1.30), 0.15, pal["shell"], p, segs=20)
    r_sphere("sh_r", (0.42, 0, 1.30), 0.15, pal["shell"], p, segs=20)
    # Head — slightly wider w/ goggles
    head = r_sphere("head", (0, 0.05, 1.65), 0.28, pal["shell"], p, segs=24)
    head.scale = (1.0, 0.95, 1.05)
    # Goggles (2 round disc lenses + strap)
    r_cyl("goggle_l", (-0.10, 0.25, 1.68), 0.07, 0.04, pal["visor"], p, verts=14, rot=(math.pi/2, 0, 0))
    r_cyl("goggle_r", (0.10, 0.25, 1.68), 0.07, 0.04, pal["visor"], p, verts=14, rot=(math.pi/2, 0, 0))
    r_torus("goggle_strap", (0, 0, 1.68), 0.30, 0.015, pal["fabric"], p, ms=24, mn=8, rot=(math.pi/2, 0, 0))
    r_sphere("eye_l", (-0.10, 0.28, 1.68), 0.025, pal["eye"], p, segs=12)
    r_sphere("eye_r", (0.10, 0.28, 1.68), 0.025, pal["eye"], p, segs=12)
    # Antennae on top
    r_cyl("ant_l", (-0.06, 0, 1.95), 0.012, 0.20, pal["metal"], p, verts=8)
    r_cyl("ant_r", (0.06, 0, 1.95), 0.012, 0.20, pal["metal"], p, verts=8)
    r_sphere("ant_l_t", (-0.06, 0, 2.10), 0.025, pal["eye"], p, segs=10)
    r_sphere("ant_r_t", (0.06, 0, 2.10), 0.025, pal["eye"], p, segs=10)
    # Compact arms holding small device
    r_cyl("arm_lu", (-0.50, 0.10, 1.05), 0.09, 0.40, pal["shell"], p, verts=16, rot=(0.5, 0, 0))
    r_cyl("arm_ll", (-0.50, 0.40, 0.85), 0.08, 0.35, pal["shell"], p, verts=16, rot=(1.0, 0, 0))
    r_sphere("hand_l", (-0.50, 0.65, 0.85), 0.09, pal["metal"], p, segs=16)
    r_cyl("arm_ru", (0.50, 0.10, 1.05), 0.09, 0.40, pal["shell"], p, verts=16, rot=(0.5, 0, 0))
    r_cyl("arm_rl", (0.50, 0.40, 0.85), 0.08, 0.35, pal["shell"], p, verts=16, rot=(1.0, 0, 0))
    r_sphere("hand_r", (0.50, 0.65, 0.85), 0.09, pal["metal"], p, segs=16)
    # Small device held between hands (utility tool)
    r_box("device", (0, 0.70, 0.85), (0.20, 0.10, 0.12), pal["metal"], p)
    r_sphere("device_glow", (0, 0.78, 0.85), 0.04, pal["eye"], p, segs=12)
    # Stubby legs
    r_cyl("leg_l", (-0.18, 0, 0.30), 0.10, 0.40, pal["shell"], p, verts=14)
    r_cyl("leg_r", (0.18, 0, 0.30), 0.10, 0.40, pal["shell"], p, verts=14)
    r_box("boot_l", (-0.18, 0.05, 0.06), (0.20, 0.30, 0.08), pal["metal"], p)
    r_box("boot_r", (0.18, 0.05, 0.06), (0.20, 0.30, 0.08), pal["metal"], p)
    return p

# ============================================================
# SCENE LAYOUT
# ============================================================
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "r2_floor"; fl.scale = (14, 4, 0.10)
fl.data.materials.append(mat_floor)
bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in fl.data.polygons: poly.use_smooth = True

build_tank(Vector((-4.5, 0, 0)))
build_dps(Vector((-1.5, 0, 0)))
build_healer(Vector((1.5, 0, 0)))
build_utility(Vector((4.5, 0, 0)))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -10, 10))
key = bpy.context.object
key.data.energy = 2200; key.data.color = (1.0, 0.78, 0.45); key.data.size = 10

bpy.ops.object.light_add(type='AREA', location=(-8, 8, 8))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.45, 0.55, 0.95); fill.data.size = 10

bpy.ops.object.light_add(type='AREA', location=(0, 10, 5))
rim = bpy.context.object
rim.data.energy = 1100; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 8

# ============================================================
# CAMERAS
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

cam_group = add_cam("cam_group",   Vector((0, -8, 3.0)), Vector((0, 0, 1.4)), lens=32, dof_dist=10)
cam_tank  = add_cam("cam_tank",    Vector((-4.5, -3, 2.0)), Vector((-4.5, 0, 1.4)), lens=70, dof_dist=3.5, fstop=3.5)
cam_dps   = add_cam("cam_dps",     Vector((-1.5, -3, 2.0)), Vector((-1.5, 0, 1.4)), lens=70, dof_dist=3.5, fstop=3.5)
cam_heal  = add_cam("cam_healer",  Vector((1.5, -3, 2.0)),  Vector((1.5, 0, 1.4)),  lens=70, dof_dist=3.5, fstop=3.5)
cam_util  = add_cam("cam_utility", Vector((4.5, -3, 2.0)),  Vector((4.5, 0, 1.4)),  lens=70, dof_dist=3.5, fstop=3.5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("group",   cam_group),
    ("tank",    cam_tank),
    ("dps",     cam_dps),
    ("healer",  cam_heal),
    ("utility", cam_util),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_companion_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-companion GLB
for cn in ["tank", "dps", "healer", "utility"]:
    bpy.ops.object.select_all(action='DESELECT')
    parent = bpy.data.objects.get(f"comp_{cn}")
    if parent:
        parent.select_set(True)
        for child in parent.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"companion_{cn}_r2_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-04 Companion Refinement complete ===")
