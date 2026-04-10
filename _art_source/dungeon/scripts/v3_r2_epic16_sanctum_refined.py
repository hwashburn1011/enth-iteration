"""
Expansion V3 — ROUND 2 — Epic R2-16 — Boss Sanctum Refinement
=============================================================
Round 2 of V3-16 Boss Sanctum. Refined volcanic obsidian arena with
custom basalt-with-lava-cracks + lava pool shaders + Round 2 stack
on every prop.

Architecture (12-radius octagonal arena):
  - Octagonal volcanic basalt floor with crack glow shader
  - Outer lava moat ring (12 wedge segments)
  - Inner combat ring + lava trim torus
  - 6 obsidian pillars around perimeter w/ glow trim bands
  - Central 3-tier boss spawn platform w/ sigil rings
  - 6 lava braziers along inner ring
  - 4 hanging chains w/ skull cores + banner cloths
  - Throne at far end with crystal heart
  - 10 floating ember motes
  - NO world volumetrics

Outputs: 3 hero renders + 1 GLB.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(116)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_r2_boss_sanctum.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.cycles.use_denoising = True
scene.render.resolution_x = 1600
scene.render.resolution_y = 900
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3r2bs_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.06, 0.01, 0.005, 1)
bg.inputs["Strength"].default_value = 0.5
# NO volumetrics

# ============================================================
# CUSTOM BASALT + LAVA + ARCH SHADERS
# ============================================================
def make_basalt_lava():
    """Volcanic basalt with lava cracks via voronoi DISTANCE_TO_EDGE."""
    m = bpy.data.materials.new("v3r2bs_basalt")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Emission Strength"].default_value = 8.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    basalt_ramp = nodes.new("ShaderNodeValToRGB"); basalt_ramp.location = (-450, 200)
    basalt_ramp.color_ramp.elements[0].position = 0.30
    basalt_ramp.color_ramp.elements[0].color = (0.04, 0.03, 0.02, 1)
    basalt_ramp.color_ramp.elements[1].position = 0.70
    basalt_ramp.color_ramp.elements[1].color = (0.12, 0.08, 0.06, 1)
    links.new(n.outputs["Fac"], basalt_ramp.inputs["Fac"])

    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 5.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    crack_ramp = nodes.new("ShaderNodeValToRGB"); crack_ramp.location = (-450, -100)
    crack_ramp.color_ramp.elements[0].position = 0.0
    crack_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    crack_ramp.color_ramp.elements[1].position = 0.08
    crack_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], crack_ramp.inputs["Fac"])

    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 100)
    links.new(crack_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(basalt_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.02, 0.01, 0.01, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    glow = nodes.new("ShaderNodeMix"); glow.data_type='RGBA'; glow.location = (100, -100)
    links.new(crack_ramp.outputs["Color"], glow.inputs["Factor"])
    glow.inputs[6].default_value = (0, 0, 0, 1)
    glow.inputs[7].default_value = (1.0, 0.45, 0.10, 1)
    links.new(glow.outputs[2], bsdf.inputs["Emission Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -300)
    bp.inputs["Strength"].default_value = 0.4
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_lava_pool():
    """Flowing lava with bright emission + ring-wave normal."""
    m = bpy.data.materials.new("v3r2bs_lava")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (1.0, 0.30, 0.05, 1)
    bsdf.inputs["Roughness"].default_value = 0.20
    bsdf.inputs["Emission Color"].default_value = (1.0, 0.45, 0.10, 1)
    bsdf.inputs["Emission Strength"].default_value = 18.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-700, 0)
    mp.inputs["Scale"].default_value = (8, 8, 8)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])

    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-450, 0)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 6.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (-200, 0)
    ramp.color_ramp.elements[0].position = 0.0
    ramp.color_ramp.elements[0].color = (1.0, 0.85, 0.30, 1)
    ramp.color_ramp.elements[1].position = 0.30
    ramp.color_ramp.elements[1].color = (0.4, 0.05, 0.02, 1)
    links.new(v.outputs["Distance"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Emission Color"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -200)
    bp.inputs["Strength"].default_value = 0.5
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_arch(name, base_color, accent_color, roughness=0.85,
              metallic=0.0, voronoi_scale=10.0, bump_strength=0.30,
              emission_color=None, emission_strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission_color:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    links.new(bsdf.outputs[0], out.inputs[0])

    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

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

    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'F1'; v.inputs["Scale"].default_value = voronoi_scale
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    v_ramp = nodes.new("ShaderNodeValToRGB"); v_ramp.location = (-450, -100)
    v_ramp.color_ramp.elements[0].position = 0.05
    v_ramp.color_ramp.elements[0].color = (base_color[0]*0.55, base_color[1]*0.55, base_color[2]*0.55, 1)
    v_ramp.color_ramp.elements[1].position = 0.30
    v_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])

    vc_mix = nodes.new("ShaderNodeMix"); vc_mix.data_type = 'RGBA'; vc_mix.location = (-200, 200)
    vc_mix.inputs[6].default_value = (*base_color, 1)
    vc_mix.inputs[7].default_value = (*accent_color, 1)
    links.new(sep_vc.outputs["Red"], vc_mix.inputs["Factor"])

    nv_mix = nodes.new("ShaderNodeMix"); nv_mix.data_type = 'RGBA'; nv_mix.location = (50, 100)
    nv_mix.inputs["Factor"].default_value = 0.40
    links.new(n_ramp.outputs["Color"], nv_mix.inputs[6])
    links.new(v_ramp.outputs["Color"], nv_mix.inputs[7])

    final_mix = nodes.new("ShaderNodeMix"); final_mix.data_type = 'RGBA'; final_mix.location = (250, 100)
    final_mix.inputs["Factor"].default_value = 0.55
    links.new(vc_mix.outputs[2], final_mix.inputs[6])
    links.new(nv_mix.outputs[2], final_mix.inputs[7])

    g = nodes.new("ShaderNodeNewGeometry"); g.location = (-200, -300)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -300)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.05, 0.02, 0.01, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(g.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type = 'RGBA'; md.location = (450, 0)
    md.inputs["Factor"].default_value = 0.40
    links.new(final_mix.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (450, -350)
    bp.inputs["Strength"].default_value = bump_strength
    links.new(v.outputs["Distance"], bp.inputs["Height"])
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

def make_simple(name, color, rough, metal=0.0, em=None, em_str=0):
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
mats = {}
mats["basalt"] = make_basalt_lava()
mats["lava"]   = make_lava_pool()
mats["obsidian"] = make_arch("v3r2bs_obs", (0.05, 0.04, 0.04), (0.10, 0.08, 0.08),
                              roughness=0.20, metallic=0.50, voronoi_scale=20.0, bump_strength=0.10,
                              emission_color=(1.0, 0.30, 0.10), emission_strength=0.4)
mats["obsidian_carved"] = make_arch("v3r2bs_obs_c", (0.06, 0.04, 0.04), (0.12, 0.08, 0.08),
                                      roughness=0.30, metallic=0.55, voronoi_scale=12.0, bump_strength=0.20,
                                      emission_color=(1.0, 0.30, 0.10), emission_strength=0.6)
mats["glow_red"]   = make_emit("v3r2bs_glow_r", (1.0, 0.30, 0.10), 14.0)
mats["glow_orange"] = make_emit("v3r2bs_glow_o", (1.0, 0.55, 0.20), 16.0)
mats["chain"] = make_arch("v3r2bs_chain", (0.08, 0.07, 0.07), (0.14, 0.12, 0.12),
                           roughness=0.55, metallic=0.85, voronoi_scale=40.0, bump_strength=0.20)
mats["skull_bone"] = make_arch("v3r2bs_skull", (0.65, 0.55, 0.42), (0.78, 0.68, 0.55),
                                 roughness=0.85, voronoi_scale=40.0, bump_strength=0.20,
                                 emission_color=(1.0, 0.45, 0.10), emission_strength=0.6)
mats["brazier_metal"] = make_arch("v3r2bs_brazier", (0.10, 0.06, 0.05), (0.18, 0.12, 0.10),
                                    roughness=0.45, metallic=0.80, voronoi_scale=22.0, bump_strength=0.20,
                                    emission_color=(1.0, 0.30, 0.10), emission_strength=0.8)
mats["banner"] = make_arch("v3r2bs_banner", (0.45, 0.05, 0.05), (0.58, 0.12, 0.10),
                            roughness=0.85, voronoi_scale=50.0, bump_strength=0.20,
                            emission_color=(1.0, 0.30, 0.10), emission_strength=0.8)
mats["crystal_heart"] = make_simple("v3r2bs_heart", (1.0, 0.20, 0.30), 0.05, 0,
                                      em=(1.0, 0.30, 0.40), em_str=20.0)
mats["sigil_glow"] = make_emit("v3r2bs_sigil", (1.0, 0.45, 0.20), 18.0)
mats["ember"] = make_emit("v3r2bs_ember", (1.0, 0.55, 0.10), 20.0)

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

def add_refined_modifiers(obj, multires_level=1, bevel_segments=5):
    obj.modifiers.new("Multires", 'MULTIRES')
    bpy.context.view_layer.objects.active = obj
    for _ in range(multires_level):
        bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')
    bv = obj.modifiers.new("Bevel", 'BEVEL')
    bv.width = 0.020; bv.segments = bevel_segments; bv.profile = 0.7
    for poly in obj.data.polygons:
        poly.use_smooth = True

def refined_part(name, primitive_op, mat, parent, vc_red=0.5, vc_var=0.4, multires=1, **kwargs):
    primitive_op(**kwargs)
    o = bpy.context.object
    o.name = name
    o.data.materials.append(mat)
    o.parent = parent
    uv_unwrap(o)
    paint_vertex_color(o, base_red=vc_red, variation=vc_var)
    add_refined_modifiers(o, multires_level=multires)
    return o

def r_box(name, loc, scale, mat, parent, vc_red=0.5, vc_var=0.4, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cube_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     size=1, location=loc)
    o.scale = scale
    o.rotation_euler = rot
    return o

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=20, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=18, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cone_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_torus(name, loc, R, r, mat, parent, vc_red=0.5, vc_var=0.4, ms=24, mn=10, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_torus_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     major_segments=ms, minor_segments=mn,
                     major_radius=R, minor_radius=r, location=loc)
    o.rotation_euler = rot
    return o

# ============================================================
# ARENA LAYOUT
# ============================================================
parent = bpy.data.objects.new("v3_r2_boss_sanctum", None); scene.collection.objects.link(parent)

ARENA_R = 8.0
INNER_R = 5.5

# Octagonal floor — basalt
r_cyl("floor", (0,0,0), ARENA_R, 0.30, mats["basalt"], parent,
       vc_red=0.55, vc_var=0.30, verts=8)
r_cyl("inner_ring", (0,0,0.16), INNER_R, 0.10, mats["basalt"], parent,
       vc_red=0.55, vc_var=0.30, verts=32)
r_torus("inner_trim", (0,0,0.22), INNER_R, 0.08, mats["glow_orange"], parent, ms=48, mn=12)

# Outer lava moat — 12 wedge segments
for i in range(12):
    ang = i * (math.pi*2/12)
    x = math.cos(ang) * (ARENA_R + 1.2)
    y = math.sin(ang) * (ARENA_R + 1.2)
    r_box(f"moat_{i}", (x, y, 0.04), (1.6, 0.8, 0.05), mats["lava"], parent,
           vc_red=0.5, vc_var=0.10, rot=(0, 0, ang))

# 6 obsidian pillars around perimeter
def obsidian_pillar(name, x, y):
    r_box(f"{name}_b1", (x, y, 0.40), (1.4, 1.4, 0.40), mats["obsidian"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box(f"{name}_b2", (x, y, 0.85), (1.2, 1.2, 0.30), mats["obsidian_carved"], parent,
           vc_red=0.55, vc_var=0.30)
    r_cone(f"{name}_shaft", (x, y, 3.5), 0.55, 0.40, 4.8, mats["obsidian"], parent,
            vc_red=0.55, vc_var=0.30, verts=8)
    r_torus(f"{name}_band", (x, y, 3.5), 0.55, 0.06, mats["glow_red"], parent, ms=24, mn=10)
    for i in range(4):
        ang = i * math.pi/2
        gx = x + math.cos(ang) * 0.60
        gy = y + math.sin(ang) * 0.60
        r_sphere(f"{name}_g_{i}", (gx, gy, 3.5), 0.06, mats["sigil_glow"], parent, segs=12)
    r_cone(f"{name}_top_cap", (x, y, 6.10), 0.50, 0.0, 0.40, mats["obsidian_carved"], parent,
            vc_red=0.55, vc_var=0.30, verts=8)
    r_cone(f"{name}_top_c", (x, y, 6.50), 0.18, 0.04, 0.50, mats["crystal_heart"], parent,
            vc_red=0.5, vc_var=0.10, verts=6)

PILLAR_COUNT = 6
for i in range(PILLAR_COUNT):
    ang = i * (math.pi*2/PILLAR_COUNT) + math.pi/6
    x = math.cos(ang) * (ARENA_R - 1.1)
    y = math.sin(ang) * (ARENA_R - 1.1)
    obsidian_pillar(f"pillar_{i}", x, y)

# Central boss spawn platform
r_cyl("plat_b1", (0, 0, 0.45), 2.4, 0.30, mats["obsidian"], parent,
       vc_red=0.55, vc_var=0.30, verts=24)
r_cyl("plat_b2", (0, 0, 0.70), 2.0, 0.20, mats["obsidian_carved"], parent,
       vc_red=0.55, vc_var=0.30, verts=24)
r_cyl("plat_b3", (0, 0, 0.85), 1.6, 0.10, mats["obsidian_carved"], parent,
       vc_red=0.55, vc_var=0.30, verts=32)
# Sigil rings
r_torus("plat_sigil1", (0, 0, 0.92), 1.4, 0.05, mats["sigil_glow"], parent, ms=48, mn=10)
r_torus("plat_sigil2", (0, 0, 0.92), 1.0, 0.04, mats["sigil_glow"], parent, ms=48, mn=10)
r_torus("plat_sigil3", (0, 0, 0.92), 0.6, 0.03, mats["sigil_glow"], parent, ms=48, mn=10)
# 6 radial glyphs
for i in range(6):
    ang = i * (math.pi*2/6)
    gx = math.cos(ang) * 1.1
    gy = math.sin(ang) * 1.1
    r_sphere(f"plat_gl_{i}", (gx, gy, 0.92), 0.10, mats["glow_orange"], parent, segs=14)
# Central red point light
bpy.ops.object.light_add(type='POINT', location=(0, 0, 1.5))
cp = bpy.context.object; cp.data.energy = 800; cp.data.color = (1.0, 0.40, 0.15)

# 6 lava braziers along inner ring
def brazier(name, x, y):
    r_cyl(f"{name}_b", (x, y, 0.40), 0.30, 0.40, mats["brazier_metal"], parent, verts=18)
    r_cyl(f"{name}_p", (x, y, 0.85), 0.10, 0.50, mats["brazier_metal"], parent, verts=10)
    r_sphere(f"{name}_bowl", (x, y, 1.20), 0.32, mats["brazier_metal"], parent, segs=20)
    r_cyl(f"{name}_lava", (x, y, 1.40), 0.28, 0.04, mats["lava"], parent, verts=24)
    r_sphere(f"{name}_f1", (x, y, 1.55), 0.18, mats["glow_orange"], parent, segs=12)
    r_sphere(f"{name}_f2", (x, y, 1.70), 0.10, mats["glow_red"], parent, segs=10)

for i in range(PILLAR_COUNT):
    ang = i * (math.pi*2/PILLAR_COUNT) + math.pi/6 + math.pi/PILLAR_COUNT
    x = math.cos(ang) * (INNER_R + 0.8)
    y = math.sin(ang) * (INNER_R + 0.8)
    brazier(f"brz_{i}", x, y)

# 4 hanging chains with skull cores
def hanging_chain(name, x, y):
    for i in range(6):
        z = 6.0 - i * 0.30
        rot = (math.pi/2 if i % 2 == 0 else 0, 0, 0)
        r_torus(f"{name}_l_{i}", (x, y, z), 0.10, 0.025, mats["chain"], parent,
                 ms=14, mn=8, rot=rot)
    r_sphere(f"{name}_skull", (x, y, 4.0), 0.18, mats["skull_bone"], parent,
              vc_red=0.55, vc_var=0.20, segs=18)
    r_sphere(f"{name}_e1", (x - 0.07, y + 0.05, 4.05), 0.04, mats["glow_red"], parent, segs=10)
    r_sphere(f"{name}_e2", (x + 0.07, y + 0.05, 4.05), 0.04, mats["glow_red"], parent, segs=10)

CHAIN_POSITIONS = [(-3.5, -3.5), (3.5, -3.5), (-3.5, 3.5), (3.5, 3.5)]
for i, (cx, cy) in enumerate(CHAIN_POSITIONS):
    hanging_chain(f"chain_{i}", cx, cy)

# Throne at far end
tx, ty = 0, ARENA_R - 1.5
r_box("th_base", (tx, ty, 0.50), (3.2, 2.0, 1.0), mats["obsidian"], parent,
       vc_red=0.55, vc_var=0.30)
r_box("th_b2", (tx, ty, 1.10), (2.8, 1.6, 0.20), mats["obsidian_carved"], parent,
       vc_red=0.55, vc_var=0.30)
r_box("th_seat", (tx, ty, 1.40), (2.4, 1.4, 0.30), mats["obsidian"], parent,
       vc_red=0.55, vc_var=0.30)
r_box("th_back", (tx, ty + 0.65, 3.50), (2.8, 0.40, 4.0), mats["obsidian"], parent,
       vc_red=0.55, vc_var=0.30)
# 3 vertical glow strips
for i, dx in enumerate([-0.6, 0, 0.6]):
    r_box(f"th_st_{i}", (tx + dx, ty + 0.40, 3.50), (0.04, 0.04, 3.2), mats["glow_red"], parent)
# 5 spikes
for i, dx in enumerate([-1.2, -0.6, 0, 0.6, 1.2]):
    r_cone(f"th_sp_{i}", (tx + dx, ty + 0.65, 5.7), 0.20 - abs(i-2)*0.04, 0.0, 0.6,
            mats["obsidian_carved"], parent, vc_red=0.55, vc_var=0.30, verts=6)
# Crystal heart
r_sphere("th_heart", (tx, ty + 0.30, 3.5), 0.40, mats["crystal_heart"], parent,
          vc_red=0.5, vc_var=0.10, segs=24)
r_torus("th_heart_frame", (tx, ty + 0.30, 3.5), 0.50, 0.06, mats["glow_red"], parent,
         ms=32, mn=12, rot=(math.pi/2, 0, 0))
bpy.ops.object.light_add(type='POINT', location=(tx, ty + 0.30, 3.5))
hp = bpy.context.object; hp.data.energy = 1500; hp.data.color = (1.0, 0.30, 0.40)

# 10 floating ember motes
EMBER_POSITIONS = [
    (-2, -1, 1.6), (2, 1, 2.0), (-1, 2, 1.4),
    (3, -2, 1.8), (-3, 0, 2.4), (0, -3, 1.2),
    (1, 3, 2.2), (-2, -3, 1.6), (4, 2, 1.4), (-4, 1, 1.8),
]
for i, (x, y, z) in enumerate(EMBER_POSITIONS):
    r_sphere(f"ember_{i}", (x, y, z), 0.06, mats["ember"], parent, segs=12)

# ============================================================
# LIGHTING — strong cinematic, NO volumetrics
# ============================================================
bpy.ops.object.light_add(type='SPOT', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 5500; key.data.color = (1.0, 0.30, 0.15)
key.data.spot_size = math.radians(80); key.data.spot_blend = 0.4
direction = Vector((0, 0, 1)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-6, 10, 8))
rim = bpy.context.object
rim.data.energy = 1200; rim.data.color = (0.85, 0.20, 0.55); rim.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(0, 0, 0.5))
gl = bpy.context.object
gl.data.energy = 600; gl.data.color = (1.0, 0.45, 0.10); gl.data.size = 12
gl.rotation_euler = (math.pi, 0, 0)

bpy.ops.object.light_add(type='AREA', location=(0, ARENA_R + 2, 4))
tb = bpy.context.object
tb.data.energy = 800; tb.data.color = (1.0, 0.30, 0.15); tb.data.size = 6
tb.rotation_euler = (math.pi/2 - 0.3, 0, 0)

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=35, dof_dist=10):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.5
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_arena   = add_cam("cam_arena",   Vector((10, -12, 5.5)), Vector((0, 0, 2)), lens=32, dof_dist=14)
cam_throne  = add_cam("cam_throne",  Vector((4, 0, 3.0)), Vector((0, ARENA_R - 1.5, 3.5)), lens=50, dof_dist=8)
cam_plat    = add_cam("cam_platform", Vector((3.5, -3.5, 2.5)), Vector((0, 0, 1.0)), lens=50, dof_dist=5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("arena",    cam_arena),
    ("throne",   cam_throne),
    ("platform", cam_plat),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_sanctum_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
out_path = os.path.join(EXPORT_DIR, "boss_sanctum_r2_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-16 Boss Sanctum Refinement complete ===")
