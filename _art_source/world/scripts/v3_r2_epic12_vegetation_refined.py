"""
Expansion V3 — ROUND 2 — Epic R2-12 — Vegetation Library Refinement
===================================================================
Round 2 of V3-12 Vegetation. 8 hero plants across all categories
with full Round 2 stack (Smart UV unwrap + vertex color paint +
multires + 5-seg bevel + vertex-color-aware shaders) plus refined
SSS foliage shader.

  TREES (2):     oak (broadleaf), pine (conifer)
  FLOWERS (2):   sunflower (radial), rose (clustered petals)
  GRASS (2):     fern (8-frond fan), wheat (6-stalk w/ heads)
  SHRUB+GLOW (2): round bush, bioluminescent mushroom cluster

Outputs: 5 hero shots @ 1920x1080 + 8 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(112)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_r2_vegetation.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
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

scene.world = bpy.data.worlds.new("v3r2v_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wsky = wnt.nodes.new("ShaderNodeTexSky")
wsky.sky_type = 'HOSEK_WILKIE'
wsky.sun_direction = (0.4, -0.5, 0.55)
wsky.turbidity = 2.5
wsky.ground_albedo = 0.4
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Strength"].default_value = 1.0
wnt.links.new(wsky.outputs[0], wbg.inputs[0])
wnt.links.new(wbg.outputs[0], wout.inputs[0])

# ============================================================
# REFINED SSS-AWARE FOLIAGE SHADER (vertex color + SSS)
# ============================================================
def make_refined_foliage(name, base_color, accent_color, sss_amount=0.5):
    """SSS leaf shader with vertex color hue mix + UV-driven vein bump."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Subsurface Weight"].default_value = sss_amount
    bsdf.inputs["Subsurface Radius"].default_value = (1.5, 0.5, 0.3)
    bsdf.inputs["Subsurface Scale"].default_value = 0.30
    bsdf.inputs["Emission Color"].default_value = (base_color[0]*1.2, base_color[1]*1.4, base_color[2]*1.2, 1)
    bsdf.inputs["Emission Strength"].default_value = 0.4
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
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    n_ramp = nodes.new("ShaderNodeValToRGB"); n_ramp.location = (-450, 200)
    n_ramp.color_ramp.elements[0].position = 0.30
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
    links.new(final_mix.outputs[2], bsdf.inputs["Base Color"])

    # Vein bump from voronoi
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -200)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = 18.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-400, -200)
    bp.inputs["Strength"].default_value = 0.20
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_petal_sss(name, color, glow=0.8):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.55
    bs.inputs["Subsurface Weight"].default_value = 0.6
    bs.inputs["Subsurface Radius"].default_value = (0.6, 0.4, 0.3)
    bs.inputs["Subsurface Scale"].default_value = 0.15
    bs.inputs["Emission Color"].default_value = (*color, 1)
    bs.inputs["Emission Strength"].default_value = glow
    return m

def make_arch(name, base_color, accent_color, roughness=0.85,
              voronoi_scale=10.0, bump_strength=0.30):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = roughness
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
    ar.color_ramp.elements[0].color = (0.10, 0.07, 0.04, 1)
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
mats["bark_oak"]   = make_arch("v3r2v_bark_oak", (0.18, 0.11, 0.06), (0.28, 0.18, 0.10),
                                roughness=0.95, voronoi_scale=12.0, bump_strength=0.45)
mats["bark_pine"]  = make_arch("v3r2v_bark_pine", (0.22, 0.13, 0.07), (0.32, 0.20, 0.12),
                                roughness=0.95, voronoi_scale=18.0, bump_strength=0.40)
mats["leaf_summer"] = make_refined_foliage("v3r2v_leaf_s", (0.10, 0.30, 0.08), (0.25, 0.45, 0.12))
mats["leaf_pine"]   = make_refined_foliage("v3r2v_leaf_p", (0.08, 0.20, 0.10), (0.12, 0.28, 0.10),
                                            sss_amount=0.25)
mats["fern"]        = make_refined_foliage("v3r2v_fern", (0.18, 0.40, 0.14), (0.28, 0.55, 0.18))
mats["wheat"]       = make_refined_foliage("v3r2v_wheat", (0.78, 0.62, 0.20), (0.90, 0.78, 0.32),
                                             sss_amount=0.6)
mats["bush_leaf"]   = make_refined_foliage("v3r2v_bush", (0.15, 0.35, 0.10), (0.25, 0.48, 0.15))
mats["mushroom_stem"] = make_arch("v3r2v_mush_stem", (0.85, 0.78, 0.65), (0.95, 0.88, 0.75),
                                    roughness=0.85, voronoi_scale=40.0, bump_strength=0.20)
mats["mushroom_glow"] = make_simple("v3r2v_mush_glow", (0.65, 0.85, 1.0), 0.40, 0,
                                     em=(0.55, 0.85, 1.0), em_str=6.0)
mats["petal_yellow"] = make_petal_sss("v3r2v_petal_y", (1.0, 0.85, 0.20), glow=1.0)
mats["petal_red"]    = make_petal_sss("v3r2v_petal_r", (0.95, 0.18, 0.20), glow=0.8)
mats["sunflower_seed"] = make_arch("v3r2v_sun_seed", (0.30, 0.18, 0.08), (0.42, 0.25, 0.12),
                                     roughness=0.85, voronoi_scale=30.0, bump_strength=0.30)
mats["thorn"]       = make_arch("v3r2v_thorn", (0.18, 0.10, 0.04), (0.28, 0.16, 0.08),
                                  roughness=0.85, voronoi_scale=14.0, bump_strength=0.30)
mats["stem"]        = make_refined_foliage("v3r2v_stem", (0.18, 0.32, 0.10), (0.25, 0.40, 0.12))
mats["ground"]      = make_arch("v3r2v_ground", (0.20, 0.30, 0.12), (0.30, 0.40, 0.15),
                                  roughness=0.95, voronoi_scale=20.0, bump_strength=0.25)

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
    bv.width = 0.015; bv.segments = bevel_segments; bv.profile = 0.7
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

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=24, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cone_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_ico(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, sub=2, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_ico_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        subdivisions=sub, radius=r, location=loc)

# ============================================================
# PLANT BUILDERS
# ============================================================
def plant_oak(o):
    p = bpy.data.objects.new("plant_oak", None); scene.collection.objects.link(p); p.location = o
    r_cyl("trunk", (0, 0, 1.5), 0.20, 3.0, mats["bark_oak"], p, verts=14, vc_red=0.55, vc_var=0.30)
    # Main canopy
    r_sphere("c_main", (0, 0, 3.4), 1.2, mats["leaf_summer"], p, segs=28, vc_red=0.55, vc_var=0.30)
    # 5 secondary clumps for shape break-up
    for i, (dx, dy, dz, r) in enumerate([(0.7,0,0.6,0.7),(-0.6,0.2,0.4,0.65),(0.2,-0.6,0.7,0.6),(-0.3,-0.5,0.3,0.55),(0.4,0.5,0.4,0.5)]):
        r_sphere(f"c_{i}", (dx, dy, 3.4 + dz), r, mats["leaf_summer"], p, segs=18,
                  vc_red=0.55, vc_var=0.30)
    return p

def plant_pine(o):
    p = bpy.data.objects.new("plant_pine", None); scene.collection.objects.link(p); p.location = o
    r_cyl("trunk", (0, 0, 2.0), 0.18, 4.0, mats["bark_pine"], p, verts=14, vc_red=0.55, vc_var=0.30)
    # 4 stacked cones
    for i in range(4):
        r1 = 1.4 - i * 0.30
        z = 2.0 + i * 0.85
        r_cone(f"c{i}", (0, 0, z), r1, 0, 1.4, mats["leaf_pine"], p, verts=18,
                vc_red=0.55, vc_var=0.30)
    return p

def plant_sunflower(o):
    p = bpy.data.objects.new("plant_sunflower", None); scene.collection.objects.link(p); p.location = o
    r_cyl("st", (0, 0, 0.50), 0.025, 1.0, mats["stem"], p, verts=10, vc_red=0.55, vc_var=0.30)
    # Center seed disc
    r_sphere("center", (0, 0, 1.05), 0.18, mats["sunflower_seed"], p, segs=24,
              vc_red=0.55, vc_var=0.30)
    # 12 yellow petals radiating
    for i in range(12):
        ang = i * (math.pi*2/12)
        x = math.cos(ang) * 0.22
        y = math.sin(ang) * 0.22
        ic = r_ico(f"pt_{i}", (x, y, 1.05), 0.10, mats["petal_yellow"], p)
        ic.scale = (1.6, 0.8, 0.3)
        ic.rotation_euler.z = ang
    # Broad base leaf
    r_cone("lf", (0.10, 0, 0.40), 0.10, 0.0, 0.30, mats["stem"], p, verts=8,
            vc_red=0.55, vc_var=0.30)
    return p

def plant_rose(o):
    p = bpy.data.objects.new("plant_rose", None); scene.collection.objects.link(p); p.location = o
    r_cyl("st", (0, 0, 0.30), 0.020, 0.60, mats["stem"], p, verts=8, vc_red=0.55, vc_var=0.30)
    # Center bud + 5 wrapping petals
    r_sphere("c", (0, 0, 0.65), 0.10, mats["petal_red"], p, segs=18, vc_red=0.55, vc_var=0.20)
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.08
        y = math.sin(ang) * 0.08
        ic = r_ico(f"pt_{i}", (x, y, 0.66), 0.08, mats["petal_red"], p)
        ic.scale = (1.0, 1.0, 0.6)
        ic.rotation_euler = (math.cos(ang)*0.3, math.sin(ang)*0.3, ang)
    # Thorns on stem
    r_cone("th1", (0.025, 0, 0.5), 0.012, 0.0, 0.04, mats["thorn"], p, verts=6)
    r_cone("th2", (-0.025, 0, 0.4), 0.012, 0.0, 0.04, mats["thorn"], p, verts=6)
    return p

def plant_fern(o):
    p = bpy.data.objects.new("plant_fern", None); scene.collection.objects.link(p); p.location = o
    # Central stalk
    r_cyl("st", (0, 0, 0.20), 0.015, 0.40, mats["fern"], p, verts=8, vc_red=0.55, vc_var=0.30)
    # 8 fronds radiating
    for i in range(8):
        ang = i * (math.pi*2/8)
        fx = math.cos(ang) * 0.04
        fy = math.sin(ang) * 0.04
        r_cone(f"fr_{i}", (fx*4, fy*4, 0.30), 0.06, 0, 0.50, mats["fern"], p, verts=10,
                vc_red=0.55, vc_var=0.30)
    return p

def plant_wheat(o):
    p = bpy.data.objects.new("plant_wheat", None); scene.collection.objects.link(p); p.location = o
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.08
        y = math.sin(ang) * 0.08
        r_cyl(f"st_{i}", (x, y, 0.40), 0.015, 0.80, mats["wheat"], p, verts=8,
               vc_red=0.55, vc_var=0.30)
        # Seed head cone
        r_cone(f"hd_{i}", (x, y, 0.90), 0.05, 0.02, 0.20, mats["wheat"], p, verts=10,
                vc_red=0.55, vc_var=0.30)
    return p

def plant_bush(o):
    p = bpy.data.objects.new("plant_bush", None); scene.collection.objects.link(p); p.location = o
    r_sphere("b1", (0, 0, 0.5), 0.55, mats["bush_leaf"], p, segs=24, vc_red=0.55, vc_var=0.30)
    r_sphere("b2", (0.3, 0.2, 0.45), 0.40, mats["bush_leaf"], p, segs=20)
    r_sphere("b3", (-0.3, 0.1, 0.45), 0.40, mats["bush_leaf"], p, segs=20)
    r_sphere("b4", (0.1, -0.3, 0.50), 0.45, mats["bush_leaf"], p, segs=20)
    return p

def plant_glow_mushroom(o):
    p = bpy.data.objects.new("plant_glow_mush", None); scene.collection.objects.link(p); p.location = o
    # 5 mushrooms in cluster
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.12
        y = math.sin(ang) * 0.12
        h = 0.25 + (i % 2) * 0.08
        r_cyl(f"st_{i}", (x, y, h/2 + 0.06), 0.05, h, mats["mushroom_stem"], p, verts=12,
               vc_red=0.55, vc_var=0.20)
        cap = r_sphere(f"cap_{i}", (x, y, h + 0.08), 0.13, mats["mushroom_glow"], p, segs=18)
        cap.scale.z = 0.7
    # Tall central glow mushroom
    r_cyl("center_st", (0, 0, 0.30), 0.06, 0.60, mats["mushroom_stem"], p, verts=14,
           vc_red=0.55, vc_var=0.20)
    cap = r_sphere("center_cap", (0, 0, 0.70), 0.18, mats["mushroom_glow"], p, segs=20)
    cap.scale.z = 0.7
    return p

# ============================================================
# LAYOUT — 8 plants in 4×2 grid
# ============================================================
parent = bpy.data.objects.new("v3_r2_vegetation", None); scene.collection.objects.link(parent)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "r2_ground"; fl.scale = (16, 8, 0.10)
fl.data.materials.append(mats["ground"])
uv_unwrap(fl); paint_vertex_color(fl, base_red=0.55, variation=0.30)
bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in fl.data.polygons: poly.use_smooth = True
fl.parent = parent

PLANTS = [
    ("oak",        plant_oak,        Vector((-6, 1.5, 0))),
    ("pine",       plant_pine,       Vector((-2, 1.5, 0))),
    ("sunflower",  plant_sunflower,  Vector(( 2, 1.5, 0))),
    ("rose",       plant_rose,       Vector(( 6, 1.5, 0))),
    ("fern",       plant_fern,       Vector((-6, -1.5, 0))),
    ("wheat",      plant_wheat,      Vector((-2, -1.5, 0))),
    ("bush",       plant_bush,       Vector(( 2, -1.5, 0))),
    ("glow_mush",  plant_glow_mushroom, Vector(( 6, -1.5, 0))),
]

PLANT_OBJS = []
for name, builder, origin in PLANTS:
    obj = builder(origin)
    obj.parent = parent
    PLANT_OBJS.append((name, obj, origin))

# ============================================================
# LIGHTING — Hosek-Wilkie sun + cool fill
# ============================================================
bpy.ops.object.light_add(type='SUN', location=(8, -10, 15))
sun = bpy.context.object
sun.data.energy = 5.0
sun.data.color = (1.0, 0.92, 0.78)
sun.data.angle = math.radians(2)
direction = Vector((0, 0, 0)) - sun.location
sun.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-8, 8, 8))
fill = bpy.context.object
fill.data.energy = 800; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 8

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

cam_grid = add_cam("cam_grid", Vector((0, -10, 6)), Vector((0, 0, 1.5)), lens=32, dof_dist=12)
cam_trees = add_cam("cam_trees", Vector((-4, -3, 3.5)), Vector((-4, 1.5, 2.5)), lens=70, dof_dist=5)
cam_flowers = add_cam("cam_flowers", Vector((4, -3, 1.6)), Vector((4, 1.5, 0.8)), lens=85, dof_dist=4)
cam_grass = add_cam("cam_grass", Vector((-4, -3, 1.5)), Vector((-4, -1.5, 0.5)), lens=85, dof_dist=4)
cam_glow = add_cam("cam_glow", Vector((6, -3, 1.5)), Vector((6, -1.5, 0.5)), lens=85, dof_dist=4)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("grid", cam_grid),
    ("trees", cam_trees),
    ("flowers", cam_flowers),
    ("grass", cam_grass),
    ("glow", cam_glow),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_veg_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-plant GLB
for name, obj, _ in PLANT_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"plant_{name}_r2_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )

print("=== V3 Round 2 Epic R2-12 Vegetation Refinement complete ===")
