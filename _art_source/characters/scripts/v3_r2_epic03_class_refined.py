"""
Expansion V3 — ROUND 2 — Epic R2-03 — Class Variants Refinement
================================================================
Round 2 of the V3-03 Class Variants pass. 3 classes built on the same
Globbler base with Round 2 technique stack:
  - Smart UV Project unwrapping
  - Vertex color painting (deterministic per-vertex hash)
  - Multi-resolution modifier (2 levels)
  - Bevel 5 segments
  - Vertex-color-aware shaders
  - Higher subdivision counts

Classes:
  COMPILER — balanced. Blue palette. Sword + kite shield. Gear glyph.
  DAEMON   — agile. Red/black palette. Twin daggers. Blade rotor glyph.
  KERNEL   — tank. Grey/iron palette. Tower shield. Fortress glyph.

Outputs: 4 hero renders @ 1920x1080 + 3 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(103)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_r2_classes.blend"
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

scene.world = bpy.data.worlds.new("v3r2_class_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# REFINED VC-AWARE SHELL SHADER (parameterized per class)
# ============================================================
def make_class_shell(name, base_color, accent_color, metallic=0.40):
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
# CLASS PALETTES (3 sets of 6 mats each)
# ============================================================
CLASSES = {
    "compiler": {
        "shell":   make_class_shell("v3r2_comp_shell", (0.18, 0.42, 0.85), (0.30, 0.65, 1.0), 0.40),
        "trim":    make_pbr_simple("v3r2_comp_trim", (0.95, 0.78, 0.20), 0.10, 1.0,
                                    em=(1.0, 0.85, 0.40), em_str=2.0),
        "weapon":  make_pbr_simple("v3r2_comp_weapon", (0.55, 0.58, 0.62), 0.20, 0.95,
                                    em=(0.40, 0.85, 1.0), em_str=0.6),
        "weapon_glow": make_emit("v3r2_comp_weapon_g", (0.40, 0.85, 1.0), 8.0),
        "visor":   make_pbr_simple("v3r2_comp_visor", (0.05, 0.05, 0.10), 0.10, 0.50,
                                    em=(0.30, 0.85, 1.0), em_str=2.5),
        "eye":     make_emit("v3r2_comp_eye", (0.45, 1.0, 1.0), 14.0),
    },
    "daemon": {
        "shell":   make_class_shell("v3r2_daem_shell", (0.45, 0.05, 0.10), (0.65, 0.15, 0.20), 0.55),
        "trim":    make_pbr_simple("v3r2_daem_trim", (0.85, 0.10, 0.10), 0.20, 0.85,
                                    em=(1.0, 0.30, 0.15), em_str=2.5),
        "weapon":  make_pbr_simple("v3r2_daem_weapon", (0.20, 0.18, 0.20), 0.30, 0.92,
                                    em=(1.0, 0.30, 0.15), em_str=0.5),
        "weapon_glow": make_emit("v3r2_daem_weapon_g", (1.0, 0.30, 0.15), 10.0),
        "visor":   make_pbr_simple("v3r2_daem_visor", (0.05, 0.02, 0.02), 0.10, 0.50,
                                    em=(1.0, 0.20, 0.10), em_str=2.5),
        "eye":     make_emit("v3r2_daem_eye", (1.0, 0.30, 0.15), 14.0),
    },
    "kernel": {
        "shell":   make_class_shell("v3r2_kern_shell", (0.30, 0.32, 0.36), (0.42, 0.45, 0.50), 0.85),
        "trim":    make_pbr_simple("v3r2_kern_trim", (0.55, 0.58, 0.62), 0.20, 0.95,
                                    em=(0.85, 0.92, 1.0), em_str=1.0),
        "weapon":  make_pbr_simple("v3r2_kern_weapon", (0.18, 0.20, 0.24), 0.40, 0.90,
                                    em=(0.55, 0.75, 0.95), em_str=0.4),
        "weapon_glow": make_emit("v3r2_kern_weapon_g", (0.55, 0.75, 0.95), 7.0),
        "visor":   make_pbr_simple("v3r2_kern_visor", (0.05, 0.05, 0.08), 0.10, 0.60,
                                    em=(0.55, 0.75, 0.95), em_str=2.0),
        "eye":     make_emit("v3r2_kern_eye", (0.55, 0.85, 1.0), 14.0),
    },
}

mat_floor = make_pbr_simple("v3r2_floor", (0.10, 0.10, 0.12), 0.30, 0.10)

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

# ============================================================
# CLASS-AGNOSTIC GLOBBLER BASE BUILDER
# ============================================================
def globbler_base(parent, mats):
    """Build the standard Globbler body using a class palette."""
    body = r_sphere("body", (0, 0, 1.05), 0.50, mats["shell"], parent,
                     vc_red=0.55, vc_var=0.30, segs=40, multires=2)
    body.scale = (1.0, 0.85, 1.4)
    r_torus("belt", (0, 0, 0.65), 0.50, 0.06, mats["trim"], parent,
             vc_red=0.7, vc_var=0.20, ms=64, mn=16)
    r_sphere("emblem", (0, 0.45, 1.10), 0.12, mats["trim"], parent,
              vc_red=0.6, vc_var=0.25, segs=24)
    r_sphere("sh_l", (-0.55, 0, 1.55), 0.22, mats["shell"], parent,
              vc_red=0.50, vc_var=0.30, segs=24)
    r_sphere("sh_r", (0.55, 0, 1.55), 0.22, mats["shell"], parent,
              vc_red=0.50, vc_var=0.30, segs=24)
    head = r_sphere("head", (0, 0.05, 1.95), 0.32, mats["shell"], parent,
                     vc_red=0.55, vc_var=0.30, segs=32, multires=2)
    head.scale = (1.0, 0.95, 1.05)
    r_box("visor", (0, 0.30, 1.95), (0.42, 0.08, 0.12), mats["visor"], parent,
           vc_red=0.4, vc_var=0.10)
    r_sphere("eye_l", (-0.10, 0.36, 1.95), 0.05, mats["eye"], parent, segs=16)
    r_sphere("eye_r", (0.10, 0.36, 1.95), 0.05, mats["eye"], parent, segs=16)
    r_cyl("ant", (0, 0, 2.40), 0.025, 0.30, mats["trim"], parent, verts=12)
    r_sphere("ant_t", (0, 0, 2.55), 0.06, mats["eye"], parent, segs=14)

# ============================================================
# CLASS-SPECIFIC SHOULDER RIGS
# ============================================================
def compiler_pads(parent, mats):
    """Compiler — broad rounded gold pauldron caps."""
    r_sphere("pl_l", (-0.55, 0, 1.65), 0.13, mats["trim"], parent,
              vc_red=0.65, vc_var=0.20, segs=20)
    r_sphere("pl_r", (0.55, 0, 1.65), 0.13, mats["trim"], parent,
              vc_red=0.65, vc_var=0.20, segs=20)

def daemon_spikes(parent, mats):
    """Daemon — 3 pointed spikes per shoulder."""
    for side in [-1, 1]:
        for i, ang in enumerate([-0.35, 0, 0.35]):
            sx = side * 0.55
            sz = 1.65 + i * 0.05
            r_cone(f"spike_{side}_{i}", (sx, math.sin(ang)*0.20, sz),
                    0.04, 0.0, 0.30, mats["trim"], parent, verts=8,
                    rot=(0, side * 0.3, ang))

def kernel_plates(parent, mats):
    """Kernel — heavy boxy plate pauldrons."""
    for side in [-1, 1]:
        r_box(f"plate_top_{side}", (side * 0.55, 0, 1.78), (0.40, 0.40, 0.10),
               mats["trim"], parent, vc_red=0.6, vc_var=0.20)
        r_box(f"plate_side_{side}", (side * 0.70, 0, 1.55), (0.10, 0.40, 0.30),
               mats["trim"], parent, vc_red=0.6, vc_var=0.20, rot=(0, side*0.2, 0))

# ============================================================
# CLASS-SPECIFIC WEAPONS
# ============================================================
def compiler_loadout(parent, mats):
    """Sword in right hand + kite shield in left."""
    # Right arm raised holding sword
    r_cyl("arm_ru", (0.65, 0, 1.20), 0.10, 0.55, mats["shell"], parent, verts=18, rot=(0, 0.3, 0))
    r_cyl("arm_rl", (0.85, 0, 0.90), 0.09, 0.45, mats["shell"], parent, verts=18, rot=(0, 0.6, 0))
    r_sphere("hand_r", (1.00, 0, 0.70), 0.12, mats["trim"], parent, segs=18)
    # Sword
    r_cyl("sword_h", (1.00, 0, 0.50), 0.04, 0.20, mats["trim"], parent, verts=12)
    r_box("sword_g", (1.00, 0, 0.36), (0.18, 0.04, 0.04), mats["trim"], parent)
    r_box("sword_b", (1.00, 0, 0.00), (0.06, 0.02, 0.60), mats["weapon"], parent)
    r_cone("sword_t", (1.00, 0, -0.32), 0.06, 0.0, 0.15, mats["weapon"], parent, verts=10)
    r_box("sword_glow", (1.00, 0.04, 0.00), (0.04, 0.005, 0.55), mats["weapon_glow"], parent)
    # Left arm down holding shield
    r_cyl("arm_lu", (-0.65, 0, 1.20), 0.10, 0.55, mats["shell"], parent, verts=18, rot=(0, -0.1, 0))
    r_cyl("arm_ll", (-0.70, 0, 0.75), 0.09, 0.45, mats["shell"], parent, verts=18)
    r_sphere("hand_l", (-0.70, 0, 0.50), 0.12, mats["trim"], parent, segs=18)
    # Kite shield (vertical box w/ rounded top)
    r_box("shield_b", (-0.85, 0.10, 0.85), (0.45, 0.06, 0.80), mats["weapon"], parent,
           vc_red=0.55, vc_var=0.25)
    r_box("shield_trim_t", (-0.85, 0.13, 1.22), (0.45, 0.04, 0.04), mats["trim"], parent)
    r_box("shield_trim_b", (-0.85, 0.13, 0.48), (0.45, 0.04, 0.04), mats["trim"], parent)
    r_sphere("shield_emblem", (-0.85, 0.14, 0.85), 0.10, mats["trim"], parent, segs=14)
    # Gear glyph (4 spokes around emblem)
    for i in range(4):
        ang = i * math.pi/2
        gx = -0.85 + math.cos(ang) * 0.15
        gz = 0.85 + math.sin(ang) * 0.15
        r_box(f"shield_gear_{i}", (gx, 0.16, gz), (0.04, 0.005, 0.04),
               mats["weapon_glow"], parent, rot=(0, 0, ang))

def daemon_loadout(parent, mats):
    """Twin daggers — both arms forward with daggers."""
    r_cyl("arm_lu", (-0.55, 0.20, 1.20), 0.10, 0.55, mats["shell"], parent, verts=18, rot=(0.5, 0, 0))
    r_cyl("arm_ll", (-0.55, 0.55, 0.95), 0.09, 0.45, mats["shell"], parent, verts=18, rot=(1.0, 0, 0))
    r_sphere("hand_l", (-0.55, 0.85, 0.95), 0.10, mats["trim"], parent, segs=18)
    r_cyl("arm_ru", (0.55, 0.20, 1.20), 0.10, 0.55, mats["shell"], parent, verts=18, rot=(0.5, 0, 0))
    r_cyl("arm_rl", (0.55, 0.55, 0.95), 0.09, 0.45, mats["shell"], parent, verts=18, rot=(1.0, 0, 0))
    r_sphere("hand_r", (0.55, 0.85, 0.95), 0.10, mats["trim"], parent, segs=18)
    # Twin daggers (one per hand)
    for side in [-1, 1]:
        sx = side * 0.55
        r_cyl(f"dagger_h_{side}", (sx, 0.95, 0.95), 0.04, 0.15, mats["trim"], parent, verts=10)
        r_box(f"dagger_g_{side}", (sx, 1.05, 0.95), (0.10, 0.04, 0.04), mats["trim"], parent)
        r_box(f"dagger_b_{side}", (sx, 1.30, 0.95), (0.04, 0.02, 0.40), mats["weapon"], parent)
        r_cone(f"dagger_t_{side}", (sx, 1.55, 0.95), 0.04, 0.0, 0.10, mats["weapon"], parent, verts=8)
        r_box(f"dagger_glow_{side}", (sx, 1.30, 0.99), (0.025, 0.005, 0.36), mats["weapon_glow"], parent)
    # Blade rotor glyph on chest (3 spinning blades)
    r_torus("rotor_ring", (0, 0.45, 1.30), 0.13, 0.012, mats["trim"], parent, ms=24, mn=8)
    for i in range(3):
        ang = i * (math.pi*2/3)
        bx = math.cos(ang) * 0.12
        bz = 1.30 + math.sin(ang) * 0.12
        r_box(f"rotor_b_{i}", (bx, 0.46, bz), (0.10, 0.005, 0.02), mats["weapon_glow"], parent,
               rot=(0, 0, ang))

def kernel_loadout(parent, mats):
    """Tower shield in left + war hammer in right."""
    r_cyl("arm_lu", (-0.65, 0.10, 1.20), 0.10, 0.55, mats["shell"], parent, verts=18, rot=(0, -0.1, 0))
    r_cyl("arm_ll", (-0.70, 0.10, 0.75), 0.09, 0.45, mats["shell"], parent, verts=18)
    r_sphere("hand_l", (-0.70, 0.10, 0.50), 0.12, mats["trim"], parent, segs=18)
    # Tower shield (massive vertical wall)
    r_box("ts_body", (-0.95, 0.20, 1.10), (0.55, 0.10, 1.40), mats["weapon"], parent,
           vc_red=0.55, vc_var=0.20)
    r_box("ts_top", (-0.95, 0.18, 1.85), (0.55, 0.06, 0.10), mats["trim"], parent)
    r_box("ts_bot", (-0.95, 0.18, 0.35), (0.55, 0.06, 0.10), mats["trim"], parent)
    r_box("ts_strip", (-0.95, 0.22, 1.10), (0.06, 0.04, 1.30), mats["trim"], parent)
    r_sphere("ts_emblem", (-0.95, 0.25, 1.10), 0.12, mats["trim"], parent, segs=16)
    # Fortress glyph (4 corner battlements around emblem)
    for i in range(4):
        ang = i * math.pi/2 + math.pi/4
        cx = -0.95 + math.cos(ang) * 0.18
        cz = 1.10 + math.sin(ang) * 0.18
        r_box(f"ts_batt_{i}", (cx, 0.27, cz), (0.04, 0.005, 0.06), mats["weapon_glow"], parent)
    # Right arm down holding war hammer
    r_cyl("arm_ru", (0.65, 0, 1.20), 0.10, 0.55, mats["shell"], parent, verts=18, rot=(0, 0.1, 0))
    r_cyl("arm_rl", (0.70, 0, 0.75), 0.09, 0.45, mats["shell"], parent, verts=18)
    r_sphere("hand_r", (0.70, 0, 0.50), 0.12, mats["trim"], parent, segs=18)
    # Hammer
    r_cyl("hammer_h", (0.70, 0, 0.30), 0.04, 0.50, mats["trim"], parent, verts=12)
    r_box("hammer_head", (0.70, 0, 0.05), (0.20, 0.12, 0.20), mats["weapon"], parent,
           vc_red=0.55, vc_var=0.20)
    r_box("hammer_glow", (0.70, 0.13, 0.05), (0.16, 0.02, 0.04), mats["weapon_glow"], parent)

# ============================================================
# CLASS BUILDER
# ============================================================
def build_class(origin, class_name):
    p = bpy.data.objects.new(f"class_{class_name}", None); scene.collection.objects.link(p)
    p.location = origin
    cls_mats = CLASSES[class_name]
    globbler_base(p, cls_mats)
    if class_name == "compiler":
        compiler_pads(p, cls_mats)
        compiler_loadout(p, cls_mats)
    elif class_name == "daemon":
        daemon_spikes(p, cls_mats)
        daemon_loadout(p, cls_mats)
    else:  # kernel
        kernel_plates(p, cls_mats)
        kernel_loadout(p, cls_mats)
    # Halo behind
    r_torus("halo", (0, -0.30, 2.20), 0.45, 0.025, cls_mats["trim"], p,
             vc_red=0.7, vc_var=0.15, ms=48, mn=14, rot=(math.pi/2, 0, 0))
    return p

# ============================================================
# SCENE LAYOUT
# ============================================================
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "r2_floor"; fl.scale = (12, 4, 0.10)
fl.data.materials.append(mat_floor)
bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in fl.data.polygons: poly.use_smooth = True

build_class(Vector((-3.2, 0, 0)), "compiler")
build_class(Vector((0.0,  0, 0)), "daemon")
build_class(Vector((3.2,  0, 0)), "kernel")

# ============================================================
# LIGHTING — V3-29 cinematic_sunset
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(6, -8, 8))
key = bpy.context.object
key.data.energy = 1900; key.data.color = (1.0, 0.78, 0.45); key.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(-6, 6, 6))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.45, 0.55, 0.95); fill.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(0, 8, 4))
rim = bpy.context.object
rim.data.energy = 950; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 6

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

cam_group   = add_cam("cam_group",    Vector((0, -7, 3.0)), Vector((0, 0, 1.4)), lens=35, dof_dist=8)
cam_comp    = add_cam("cam_compiler", Vector((-3.2, -3, 2.0)), Vector((-3.2, 0, 1.4)), lens=70, dof_dist=3.5, fstop=3.5)
cam_daem    = add_cam("cam_daemon",   Vector((0, -3, 2.0)),  Vector((0, 0, 1.4)),  lens=70, dof_dist=3.5, fstop=3.5)
cam_kern    = add_cam("cam_kernel",   Vector((3.2, -3, 2.0)),  Vector((3.2, 0, 1.4)),  lens=70, dof_dist=3.5, fstop=3.5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("group",    cam_group),
    ("compiler", cam_comp),
    ("daemon",   cam_daem),
    ("kernel",   cam_kern),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_class_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-class GLB exports
for class_name in ["compiler", "daemon", "kernel"]:
    bpy.ops.object.select_all(action='DESELECT')
    parent = bpy.data.objects.get(f"class_{class_name}")
    if parent:
        parent.select_set(True)
        for child in parent.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"class_{class_name}_r2_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-03 Class Variants Refinement complete ===")
