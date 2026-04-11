"""
Expansion V3 — ROUND 2 — Epic R2-14 — Memory Vaults Refinement
==============================================================
Round 2 of V3-14 Memory Vaults. Refined cathedral hall with custom
inscription tile + brass-with-patina shaders + Round 2 stack.

Architecture (12x6 hall):
  - Inscription tile floor (brick + gold mortar emission)
  - Vaulted arches (3) across ceiling
  - 4 weathered stone pillars w/ gold inscription bands
  - 2 wall niches with brass urns
  - Central altar w/ brazier + crystal heart relief on backwall
  - 4 floating glowing scrolls
  - NO world volumetrics

Outputs: 3 hero renders + 1 GLB export.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(114)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_r2_memory_vaults.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3r2mv_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.025, 0.015, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# REFINED VC-AWARE SHADER (architectural)
# ============================================================
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
    ar.color_ramp.elements[0].color = (0.15, 0.10, 0.06, 1)
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

def make_inscription_tile():
    """Sandstone tile w/ gold mortar seam emission."""
    m = bpy.data.materials.new("v3r2mv_floor")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Emission Strength"].default_value = 0.6
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    brick = nodes.new("ShaderNodeTexBrick"); brick.location = (-700, 100)
    brick.inputs["Scale"].default_value = 4.0
    brick.inputs["Color1"].default_value = (0.62, 0.50, 0.32, 1)
    brick.inputs["Color2"].default_value = (0.55, 0.42, 0.25, 1)
    brick.inputs["Mortar"].default_value = (0.85, 0.65, 0.20, 1)
    brick.inputs["Mortar Size"].default_value = 0.018
    brick.inputs["Bias"].default_value = 0.0
    links.new(mp.outputs["Vector"], brick.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, -100)
    n.inputs["Scale"].default_value = 18.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    nr = nodes.new("ShaderNodeValToRGB"); nr.location = (-450, -100)
    nr.color_ramp.elements[0].position = 0.40
    nr.color_ramp.elements[0].color = (0.50, 0.40, 0.22, 1)
    nr.color_ramp.elements[1].position = 0.70
    nr.color_ramp.elements[1].color = (0.70, 0.55, 0.32, 1)
    links.new(n.outputs["Fac"], nr.inputs["Fac"])

    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 0)
    mix.blend_type = 'MULTIPLY'
    mix.inputs["Factor"].default_value = 0.4
    links.new(brick.outputs["Color"], mix.inputs[6])
    links.new(nr.outputs["Color"], mix.inputs[7])

    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-200, -300)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -300)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.15, 0.10, 0.05, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location = (300, 0)
    md.inputs["Factor"].default_value = 0.40
    links.new(mix.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    glow_mix = nodes.new("ShaderNodeMix"); glow_mix.data_type='RGBA'; glow_mix.location = (550, 200)
    glow_mix.inputs[6].default_value = (0, 0, 0, 1)
    glow_mix.inputs[7].default_value = (1.0, 0.78, 0.30, 1)
    links.new(brick.outputs["Fac"], glow_mix.inputs["Factor"])
    links.new(glow_mix.outputs[2], bsdf.inputs["Emission Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (550, -300)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_brass_patina():
    """Brass with verdigris patina in crevices via curvature mask."""
    m = bpy.data.materials.new("v3r2mv_brass_patina")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Roughness"].default_value = 0.35
    bsdf.inputs["Metallic"].default_value = 0.92
    bsdf.inputs["Emission Color"].default_value = (1.0, 0.80, 0.30, 1)
    bsdf.inputs["Emission Strength"].default_value = 0.6
    links.new(bsdf.outputs[0], out.inputs[0])

    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-600, -100)
    inv = nodes.new("ShaderNodeMath"); inv.location = (-400, -100)
    inv.operation = 'SUBTRACT'
    inv.inputs[0].default_value = 1.0
    links.new(geo.outputs["Pointiness"], inv.inputs[1])
    patina_ramp = nodes.new("ShaderNodeValToRGB"); patina_ramp.location = (-200, -100)
    patina_ramp.color_ramp.elements[0].position = 0.50
    patina_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    patina_ramp.color_ramp.elements[1].position = 0.85
    patina_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(inv.outputs[0], patina_ramp.inputs["Fac"])

    brass_color = nodes.new("ShaderNodeRGB"); brass_color.location = (-200, 200)
    brass_color.outputs[0].default_value = (0.78, 0.55, 0.18, 1)
    patina_color = nodes.new("ShaderNodeRGB"); patina_color.location = (-200, 0)
    patina_color.outputs[0].default_value = (0.20, 0.55, 0.45, 1)

    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (100, 100)
    links.new(patina_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(brass_color.outputs[0], mix.inputs[6])
    links.new(patina_color.outputs[0], mix.inputs[7])
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    rough_mix = nodes.new("ShaderNodeMix"); rough_mix.location = (100, -150)
    rough_mix.inputs[2].default_value = 0.85
    rough_mix.inputs[3].default_value = 0.30
    links.new(patina_ramp.outputs["Color"], rough_mix.inputs[0])
    links.new(rough_mix.outputs[0], bsdf.inputs["Roughness"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, -400)
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, -400)
    n.inputs["Scale"].default_value = 25.0
    links.new(tc.outputs["Object"], n.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-400, -400)
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
mats["floor"] = make_inscription_tile()
mats["pillar"] = make_arch("v3r2mv_pillar", (0.65, 0.55, 0.40), (0.78, 0.65, 0.50),
                            roughness=0.85, voronoi_scale=8.0, bump_strength=0.30)
mats["pillar_glow"] = make_simple("v3r2mv_pillar_glow", (0.85, 0.65, 0.20), 0.30, 0.85,
                                    em=(1.0, 0.80, 0.30), em_str=4.0)
mats["wall"] = make_arch("v3r2mv_wall", (0.55, 0.45, 0.32), (0.65, 0.55, 0.40),
                          roughness=0.92, voronoi_scale=8.0, bump_strength=0.40)
mats["ceiling"] = make_arch("v3r2mv_ceiling", (0.45, 0.36, 0.25), (0.55, 0.45, 0.32),
                             roughness=0.92, voronoi_scale=10.0, bump_strength=0.35)
mats["brass_patina"] = make_brass_patina()
mats["scroll_paper"] = make_simple("v3r2mv_scroll", (0.92, 0.80, 0.55), 0.85, 0,
                                     em=(1.0, 0.85, 0.45), em_str=2.5)
mats["glyph_glow"] = make_emit("v3r2mv_glyph", (1.0, 0.85, 0.40), 8.0)
mats["crystal"] = make_simple("v3r2mv_crystal", (0.30, 0.55, 0.95), 0.10, 0,
                                em=(0.40, 0.75, 1.0), em_str=4.0)
mats["fire"] = make_emit("v3r2mv_fire", (1.0, 0.55, 0.20), 14.0)
mats["candle_wax"] = make_simple("v3r2mv_wax", (0.92, 0.88, 0.78), 0.40, 0,
                                   em=(1.0, 0.85, 0.55), em_str=4.5)
mats["gold_relief"] = make_simple("v3r2mv_relief", (1.0, 0.85, 0.30), 0.20, 1.0,
                                    em=(1.0, 0.85, 0.40), em_str=2.5)

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

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=20, multires=1):
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
# HALL LAYOUT
# ============================================================
parent = bpy.data.objects.new("v3_r2_memory_vaults", None); scene.collection.objects.link(parent)

HALL_LEN = 12
HALL_WID = 6
CEIL_H = 5.0

# Floor
r_box("floor", (0, 0, 0), (HALL_WID, HALL_LEN, 0.10), mats["floor"], parent,
       vc_red=0.55, vc_var=0.20)
# Walls
r_box("wall_L", (-HALL_WID/2 - 0.10, 0, CEIL_H/2), (0.20, HALL_LEN, CEIL_H), mats["wall"], parent,
       vc_red=0.55, vc_var=0.30)
r_box("wall_R", (HALL_WID/2 + 0.10, 0, CEIL_H/2), (0.20, HALL_LEN, CEIL_H), mats["wall"], parent,
       vc_red=0.55, vc_var=0.30)
# Far altar wall
r_box("wall_back", (0, HALL_LEN/2 + 0.10, CEIL_H/2), (HALL_WID, 0.20, CEIL_H), mats["wall"], parent,
       vc_red=0.55, vc_var=0.30)

# Vaulted ceiling — 3 arch keystones
for i, ay in enumerate([-4, 0, 4]):
    r_box(f"arch_{i}_keystone", (0, ay, CEIL_H + 0.10), (HALL_WID, 0.40, 0.40), mats["ceiling"], parent,
           vc_red=0.55, vc_var=0.30)

# 4 weathered stone pillars (2/side)
def build_pillar(name, x, y):
    # Base
    r_box(f"{name}_base", (x, y, 0.30), (1.0, 1.0, 0.40), mats["pillar"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box(f"{name}_b2", (x, y, 0.65), (0.85, 0.85, 0.30), mats["pillar"], parent,
           vc_red=0.55, vc_var=0.30)
    # Shaft
    r_cyl(f"{name}_shaft", (x, y, 2.5), 0.32, 3.6, mats["pillar"], parent, verts=24,
           vc_red=0.55, vc_var=0.30)
    # Gold inscription bands (top + bottom)
    r_torus(f"{name}_band1", (x, y, 1.5), 0.36, 0.06, mats["pillar_glow"], parent, ms=32, mn=12)
    r_torus(f"{name}_band2", (x, y, 3.5), 0.36, 0.06, mats["pillar_glow"], parent, ms=32, mn=12)
    # 8 glyph studs around lower band
    for i in range(8):
        ang = i * math.pi/4
        gx = x + math.cos(ang) * 0.40
        gy = y + math.sin(ang) * 0.40
        r_sphere(f"{name}_g_{i}", (gx, gy, 1.5), 0.05, mats["glyph_glow"], parent, segs=12)
    # Capital
    r_box(f"{name}_c1", (x, y, 4.45), (0.85, 0.85, 0.30), mats["pillar"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box(f"{name}_c2", (x, y, 4.80), (1.0, 1.0, 0.40), mats["pillar"], parent,
           vc_red=0.55, vc_var=0.30)

for i, py in enumerate([-3, 3]):
    build_pillar(f"pl_L_{i}", -2.0, py)
    build_pillar(f"pl_R_{i}", 2.0, py)

# 2 wall niches with brass urns
def wall_niche(name, x, y, z):
    r_box(f"{name}_shelf", (x, y, z), (0.6, 0.4, 0.10), mats["pillar"], parent)
    r_box(f"{name}_back", (x + (0.20 if x > 0 else -0.20), y, z + 0.50), (0.04, 0.5, 1.0),
           mats["pillar_glow"], parent)
    # Small urn
    r_cyl(f"{name}_urn_b", (x, y, z + 0.18), 0.20, 0.08, mats["brass_patina"], parent, verts=20)
    r_sphere(f"{name}_urn_body", (x, y, z + 0.40), 0.22, mats["brass_patina"], parent, segs=22)
    r_cyl(f"{name}_urn_neck", (x, y, z + 0.65), 0.12, 0.10, mats["brass_patina"], parent, verts=16)

wall_niche("nch_L", -2.8, 0, 1.5)
wall_niche("nch_R",  2.8, 0, 1.5)

# 4 brass urns scattered along walls
for i, (ux, uy) in enumerate([(-2.5, -4), (2.5, -4), (-2.5, 4), (2.5, 4)]):
    r_cyl(f"urn_{i}_b", (ux, uy, 0.10), 0.28, 0.10, mats["brass_patina"], parent, verts=20)
    r_sphere(f"urn_{i}_body", (ux, uy, 0.45), 0.32, mats["brass_patina"], parent, segs=24)
    r_cyl(f"urn_{i}_neck", (ux, uy, 0.85), 0.18, 0.16, mats["brass_patina"], parent, verts=16)
    r_torus(f"urn_{i}_h1", (ux + 0.30, uy, 0.55), 0.10, 0.025, mats["brass_patina"], parent,
             ms=12, mn=8)
    r_torus(f"urn_{i}_h2", (ux - 0.30, uy, 0.55), 0.10, 0.025, mats["brass_patina"], parent,
             ms=12, mn=8)

# 4 floating glowing scrolls
def floating_scroll(name, x, y, z):
    r_cyl(f"{name}_body", (x, y, z), 0.10, 0.50, mats["scroll_paper"], parent, verts=18,
           rot=(0, math.pi/2, 0))
    r_cyl(f"{name}_r1", (x - 0.30, y, z), 0.12, 0.10, mats["scroll_paper"], parent, verts=14,
           rot=(0, math.pi/2, 0))
    r_cyl(f"{name}_r2", (x + 0.30, y, z), 0.12, 0.10, mats["scroll_paper"], parent, verts=14,
           rot=(0, math.pi/2, 0))
    r_sphere(f"{name}_seal", (x, y + 0.12, z), 0.06, mats["glyph_glow"], parent, segs=12)

floating_scroll("sc_0", -1.0, -2, 2.4)
floating_scroll("sc_1",  1.0,  1, 2.6)
floating_scroll("sc_2", -0.5,  3, 2.2)
floating_scroll("sc_3",  0.5, -1, 2.8)

# Central altar at far end
r_box("alt_base", (0, 5.0, 0.30), (1.6, 0.6, 0.60), mats["pillar"], parent,
       vc_red=0.55, vc_var=0.30)
r_box("alt_top",  (0, 5.0, 0.65), (1.8, 0.8, 0.10), mats["pillar_glow"], parent)
# Brazier
r_cyl("brz_b", (0, 5.0, 0.85), 0.50, 0.30, mats["brass_patina"], parent, verts=24)
r_sphere("brz_bowl", (0, 5.0, 1.05), 0.50, mats["brass_patina"], parent, segs=24)
r_cyl("brz_water", (0, 5.0, 1.20), 0.45, 0.06, mats["fire"], parent, verts=24)
# Fire flames
r_sphere("flame_1", (0, 5.0, 1.45), 0.20, mats["fire"], parent, segs=14)
r_sphere("flame_2", (-0.10, 5.0, 1.55), 0.12, mats["fire"], parent, segs=12)
r_sphere("flame_3", (0.10, 5.0, 1.55), 0.12, mats["fire"], parent, segs=12)

# Brazier point light
bpy.ops.object.light_add(type='POINT', location=(0, 5.0, 1.6))
bp = bpy.context.object; bp.data.energy = 1500; bp.data.color = (1.0, 0.55, 0.20)

# Sun glyph relief on back wall
r_torus("relief_outer", (0, HALL_LEN/2 + 0.05, 3.5), 1.2, 0.10, mats["gold_relief"], parent,
         ms=48, mn=14)
r_torus("relief_inner", (0, HALL_LEN/2 + 0.05, 3.5), 0.8, 0.06, mats["gold_relief"], parent,
         ms=36, mn=12)
for i in range(8):
    ang = i * math.pi/4
    rx = math.cos(ang) * 1.5
    rz = 3.5 + math.sin(ang) * 1.5
    r_box(f"relief_ray_{i}", (rx, HALL_LEN/2 + 0.05, rz), (0.10, 0.04, 0.35),
           mats["gold_relief"], parent, rot=(0, ang + math.pi/2, 0))
r_sphere("relief_center", (0, HALL_LEN/2 + 0.05, 3.5), 0.22, mats["glyph_glow"], parent, segs=18)

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='SPOT', location=(0, -6, CEIL_H + 1))
key = bpy.context.object
key.data.energy = 5000; key.data.color = (1.0, 0.78, 0.40)
key.data.spot_size = math.radians(70); key.data.spot_blend = 0.35
key.rotation_euler = (math.pi - 0.2, 0, 0)

bpy.ops.object.light_add(type='AREA', location=(-5, 0, 4))
fl = bpy.context.object
fl.data.energy = 600; fl.data.color = (1.0, 0.65, 0.35); fl.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(5, 0, 4))
fr = bpy.context.object
fr.data.energy = 400; fr.data.color = (0.45, 0.55, 0.85); fr.data.size = 8

bpy.ops.object.light_add(type='POINT', location=(0, HALL_LEN/2 - 0.5, 3.5))
br = bpy.context.object
br.data.energy = 600; br.data.color = (1.0, 0.85, 0.40)

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=35, dof_dist=10):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.0
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hall   = add_cam("cam_hall",   Vector((0, -7, 2.0)), Vector((0, 5, 2.5)), lens=32, dof_dist=12)
cam_pillar = add_cam("cam_pillar", Vector((0, -2.5, 1.6)), Vector((-2.0, 0, 2.0)), lens=70, dof_dist=4)
cam_altar  = add_cam("cam_altar",  Vector((0, 2, 1.8)),  Vector((0, 5.0, 1.6)), lens=60, dof_dist=4)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("hall",   cam_hall),
    ("pillar", cam_pillar),
    ("altar",  cam_altar),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_vault_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
out_path = os.path.join(EXPORT_DIR, "memory_vaults_r2_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-14 Memory Vaults Refinement complete ===")
