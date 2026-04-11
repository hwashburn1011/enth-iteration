"""
Expansion V3 — Epic 26 — Farming & Gathering Props Texture Pass
================================================================
30+ farming and gathering props in a showcase grid:

  CROPS w/ GROWTH STAGES (4 × 3 = 12):
    carrot, wheat, tomato, cabbage — sprout / mid / mature

  FRUIT TREES (4):
    apple, lemon, cherry, peach (each: trunk + canopy + 5 fruits)

  GATHERING NODES (6):
    iron ore node, copper ore node, gold ore node, herb cluster,
    log pile, mushroom cluster

  FISHING GEAR (5):
    fishing rod, net, tackle box, bait jar, fish basket

  TOOLS (4):
    pickaxe, woodaxe, hoe, sickle

Crops use leaf SSS w/ growth-stage color tints. Fruits use SSS skin
with bright translucent emission. Iridescent fish scale via fresnel
color shift. Tool wear via curvature dirt.

Outputs:
  - 1 grid hero render @ 1920x1080
  - 5 category close-ups @ 1280x720
  - 31 GLB exports
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(26)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_farming.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3_fm_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.06, 0.07, 0.10, 1)
bg.inputs["Strength"].default_value = 0.6

# ============================================================
# SHADER HELPERS
# ============================================================
def make_pbr(name, base_color, roughness=0.65, metallic=0.0,
             emission_color=None, emission_strength=0.0,
             noise_strength=0.20, voronoi_strength=0.0, voronoi_scale=22.0,
             curvature_dirt=True, fresnel_rim=False,
             bump_strength=0.10, bump_scale=35.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    output = nodes.new("ShaderNodeOutputMaterial"); output.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission_color is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    links.new(bsdf.outputs[0], output.inputs[0])
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5,5,5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])
    if noise_strength > 0:
        n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
        n.inputs["Scale"].default_value = 14.0
        n.inputs["Detail"].default_value = 8.0
        links.new(mp.outputs["Vector"], n.inputs["Vector"])
        r = nodes.new("ShaderNodeValToRGB"); r.location = (-450, 200)
        r.color_ramp.elements[0].position = 0.35
        r.color_ramp.elements[0].color = (base_color[0]*0.78, base_color[1]*0.78, base_color[2]*0.78, 1)
        r.color_ramp.elements[1].position = 0.70
        r.color_ramp.elements[1].color = (min(base_color[0]*1.22,1), min(base_color[1]*1.22,1), min(base_color[2]*1.22,1), 1)
        links.new(n.outputs["Fac"], r.inputs["Fac"])
        mx = nodes.new("ShaderNodeMix"); mx.data_type='RGBA'; mx.location=(-200,100)
        mx.inputs["Factor"].default_value = noise_strength
        mx.inputs[6].default_value = (*base_color, 1)
        links.new(r.outputs["Color"], mx.inputs[7])
        base_out = mx.outputs[2]
    else:
        rgb = nodes.new("ShaderNodeRGB"); rgb.location=(-200,100)
        rgb.outputs[0].default_value = (*base_color, 1)
        base_out = rgb.outputs[0]
    if voronoi_strength > 0:
        v = nodes.new("ShaderNodeTexVoronoi"); v.location=(-700,-100)
        v.feature='F1'; v.inputs["Scale"].default_value = voronoi_scale
        links.new(mp.outputs["Vector"], v.inputs["Vector"])
        vr = nodes.new("ShaderNodeValToRGB"); vr.location=(-450,-100)
        vr.color_ramp.elements[0].position = 0.05
        vr.color_ramp.elements[0].color = (base_color[0]*0.55, base_color[1]*0.55, base_color[2]*0.55, 1)
        vr.color_ramp.elements[1].position = 0.30
        vr.color_ramp.elements[1].color = (1,1,1,1)
        links.new(v.outputs["Distance"], vr.inputs["Fac"])
        mv = nodes.new("ShaderNodeMix"); mv.data_type='RGBA'; mv.location=(50,50)
        mv.inputs["Factor"].default_value = voronoi_strength
        links.new(base_out, mv.inputs[6])
        links.new(vr.outputs["Color"], mv.inputs[7])
        base_out = mv.outputs[2]
    if curvature_dirt:
        g = nodes.new("ShaderNodeNewGeometry"); g.location=(-700,-350)
        ar = nodes.new("ShaderNodeValToRGB"); ar.location=(-450,-350)
        ar.color_ramp.elements[0].position = 0.30
        ar.color_ramp.elements[0].color = (0.10,0.07,0.04,1)
        ar.color_ramp.elements[1].position = 0.70
        ar.color_ramp.elements[1].color = (1,1,1,1)
        links.new(g.outputs["Pointiness"], ar.inputs["Fac"])
        md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location=(300,0)
        md.inputs["Factor"].default_value = 0.40
        links.new(base_out, md.inputs[6])
        links.new(ar.outputs["Color"], md.inputs[7])
        base_out = md.outputs[2]
    if fresnel_rim and emission_color is not None:
        fr = nodes.new("ShaderNodeFresnel"); fr.location=(300,300)
        fr.inputs["IOR"].default_value = 1.45
        rc = nodes.new("ShaderNodeRGB"); rc.location=(300,450)
        rc.outputs[0].default_value = (*emission_color, 1)
        mr = nodes.new("ShaderNodeMix"); mr.data_type='RGBA'; mr.location=(550,350)
        mr.inputs[6].default_value = (0,0,0,1)
        links.new(fr.outputs["Fac"], mr.inputs["Factor"])
        links.new(rc.outputs[0], mr.inputs[7])
        links.new(mr.outputs[2], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = max(emission_strength, 1.5)
    bn = nodes.new("ShaderNodeTexNoise"); bn.location=(-700,-550)
    bn.inputs["Scale"].default_value = bump_scale
    bn.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], bn.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location=(-450,-550)
    bp.inputs["Strength"].default_value = bump_strength
    links.new(bn.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    links.new(base_out, bsdf.inputs["Base Color"])
    return m

def make_leaf_sss(name, color, sss_amount=0.5):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.85
    bs.inputs["Subsurface Weight"].default_value = sss_amount
    bs.inputs["Subsurface Radius"].default_value = (1.5, 0.5, 0.3)
    bs.inputs["Subsurface Scale"].default_value = 0.30
    bs.inputs["Emission Color"].default_value = (color[0]*1.2, color[1]*1.4, color[2]*1.2, 1)
    bs.inputs["Emission Strength"].default_value = 0.4
    return m

def make_fruit_skin(name, color):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.40
    bs.inputs["Subsurface Weight"].default_value = 0.6
    bs.inputs["Subsurface Radius"].default_value = (1.0, 0.4, 0.3)
    bs.inputs["Subsurface Scale"].default_value = 0.20
    bs.inputs["Coat Weight"].default_value = 0.5
    bs.inputs["Coat Roughness"].default_value = 0.10
    bs.inputs["Emission Color"].default_value = (color[0]*1.3, color[1]*1.3, color[2]*1.3, 1)
    bs.inputs["Emission Strength"].default_value = 0.5
    return m

def make_iridescent_fish():
    """Iridescent fish scale: fresnel-driven hue shift."""
    m = bpy.data.materials.new("v3fm_fish")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Roughness"].default_value = 0.20
    bsdf.inputs["Metallic"].default_value = 0.50
    bsdf.inputs["Coat Weight"].default_value = 0.6
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    links.new(bsdf.outputs[0], out.inputs[0])

    fr = nodes.new("ShaderNodeFresnel"); fr.location = (-400, 0)
    fr.inputs["IOR"].default_value = 1.4
    color_ramp = nodes.new("ShaderNodeValToRGB"); color_ramp.location = (-200, 0)
    color_ramp.color_ramp.elements[0].position = 0.0
    color_ramp.color_ramp.elements[0].color = (0.20, 0.45, 0.95, 1)  # body blue
    e2 = color_ramp.color_ramp.elements.new(0.5)
    e2.color = (0.30, 0.85, 0.55, 1)  # green
    color_ramp.color_ramp.elements[2].position = 1.0
    color_ramp.color_ramp.elements[2].color = (0.95, 0.30, 0.55, 1)  # pink edge
    links.new(fr.outputs["Fac"], color_ramp.inputs["Fac"])
    links.new(color_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # Scale bump
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-700, -200)
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-500, -200)
    v.feature = 'F1'; v.inputs["Scale"].default_value = 30.0
    links.new(tc.outputs["Generated"], v.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -200)
    bp.inputs["Strength"].default_value = 0.30
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

# ============================================================
# MATERIALS
# ============================================================
mats = {}
# Soil
mats["soil"]      = make_pbr("v3fm_soil", (0.22, 0.14, 0.08), 0.95,
    noise_strength=0.40, voronoi_strength=0.30, voronoi_scale=20.0, bump_strength=0.30, bump_scale=20.0)
mats["soil_dry"]  = make_pbr("v3fm_soil_d", (0.40, 0.28, 0.16), 0.95,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=18.0, bump_strength=0.25, bump_scale=20.0)
# Crops
mats["leaf_sprout"]   = make_leaf_sss("v3fm_leaf_sprt", (0.45, 0.65, 0.20))
mats["leaf_mid"]      = make_leaf_sss("v3fm_leaf_mid",  (0.22, 0.50, 0.12))
mats["leaf_mature"]   = make_leaf_sss("v3fm_leaf_mat",  (0.18, 0.42, 0.10))
mats["wheat_mature"]  = make_leaf_sss("v3fm_wheat",     (0.85, 0.70, 0.20), sss_amount=0.6)
mats["carrot_orange"] = make_fruit_skin("v3fm_carrot", (0.95, 0.55, 0.10))
mats["tomato_red"]    = make_fruit_skin("v3fm_tomato", (0.90, 0.20, 0.15))
mats["cabbage_green"] = make_leaf_sss("v3fm_cabbage", (0.30, 0.60, 0.20), sss_amount=0.7)
# Fruits
mats["apple"]   = make_fruit_skin("v3fm_apple", (0.92, 0.18, 0.20))
mats["lemon"]   = make_fruit_skin("v3fm_lemon", (1.0, 0.92, 0.20))
mats["cherry"]  = make_fruit_skin("v3fm_cherry", (0.78, 0.10, 0.20))
mats["peach"]   = make_fruit_skin("v3fm_peach", (0.95, 0.65, 0.45))
mats["blossom"] = make_fruit_skin("v3fm_blossom", (1.0, 0.78, 0.85))
# Bark
mats["bark"]    = make_pbr("v3fm_bark", (0.20, 0.12, 0.06), 0.95,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=12.0, bump_strength=0.45, bump_scale=18.0)
mats["canopy"]  = make_leaf_sss("v3fm_canopy", (0.12, 0.30, 0.10))
# Ores
mats["ore_iron"]   = make_pbr("v3fm_ore_iron", (0.45, 0.42, 0.40), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=10.0, bump_strength=0.40, bump_scale=14.0)
mats["ore_iron_v"] = make_pbr("v3fm_ore_iron_v", (0.65, 0.62, 0.60), 0.30, 0.95,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["ore_copper"]   = make_pbr("v3fm_ore_copper", (0.40, 0.32, 0.25), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=10.0, bump_strength=0.40, bump_scale=14.0)
mats["ore_copper_v"] = make_pbr("v3fm_ore_copper_v", (0.85, 0.45, 0.20), 0.30, 0.92,
    emission_color=(1.0, 0.55, 0.25), emission_strength=0.6,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["ore_gold"]   = make_pbr("v3fm_ore_gold", (0.45, 0.40, 0.30), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=10.0, bump_strength=0.40, bump_scale=14.0)
mats["ore_gold_v"] = make_pbr("v3fm_ore_gold_v", (0.95, 0.78, 0.20), 0.10, 1.0,
    emission_color=(1.0, 0.85, 0.40), emission_strength=1.5,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
# Wood/log
mats["wood_log"]   = make_pbr("v3fm_wood_log", (0.35, 0.22, 0.10), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=8.0, bump_strength=0.30, bump_scale=12.0)
mats["wood_cut"]   = make_pbr("v3fm_wood_cut", (0.65, 0.50, 0.30), 0.85,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=18.0, bump_strength=0.20, bump_scale=14.0)
# Mushrooms
mats["mushroom_red"] = make_pbr("v3fm_mush_red", (0.85, 0.18, 0.18), 0.65,
    emission_color=(0.95, 0.30, 0.25), emission_strength=0.5,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=80.0,
    curvature_dirt=False, fresnel_rim=True, bump_strength=0.20, bump_scale=80.0)
mats["mushroom_stem"] = make_pbr("v3fm_mush_stem", (0.85, 0.78, 0.65), 0.85,
    noise_strength=0.20, curvature_dirt=True, bump_strength=0.20, bump_scale=40.0)
# Tools
mats["iron"]    = make_pbr("v3fm_iron", (0.18, 0.18, 0.20), 0.45, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["wood_handle"] = make_pbr("v3fm_handle", (0.35, 0.20, 0.10), 0.55,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=20.0, bump_strength=0.15, bump_scale=22.0)
mats["leather"] = make_pbr("v3fm_leather", (0.30, 0.16, 0.08), 0.55,
    noise_strength=0.25, voronoi_strength=0.20, voronoi_scale=80.0, bump_strength=0.20, bump_scale=80.0)
mats["fish"] = make_iridescent_fish()
mats["water_jar"] = make_pbr("v3fm_water", (0.30, 0.55, 0.85), 0.10, 0,
    emission_color=(0.40, 0.65, 0.95), emission_strength=0.6,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["glass"] = make_pbr("v3fm_glass", (0.85, 0.92, 0.95), 0.05, 0.0,
    emission_color=(0.95, 0.98, 1.0), emission_strength=0.4,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
# Floor
mats["floor"] = make_pbr("v3fm_floor", (0.10, 0.10, 0.12), 0.30, 0.10,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def make_parent(name, origin):
    p = bpy.data.objects.new(name, None); scene.collection.objects.link(p); p.location = origin
    return p

def box(name, loc, scale, mat, parent, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = scale; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o)
    o.parent = parent
    return o

def cyl(name, loc, r, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def sph(name, loc, r, mat, parent, segs=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def ico(name, loc, r, mat, parent, sub=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def soil_patch(name, origin, parent):
    """Small soil patch beneath a crop."""
    bpy.ops.mesh.primitive_cylinder_add(vertices=18, radius=0.30, depth=0.06, location=(origin.x, origin.y, 0.03))
    o = bpy.context.object; o.name = name
    o.data.materials.append(mats["soil"])
    add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent

# ============================================================
# CROPS WITH GROWTH STAGES
# ============================================================
def crop_carrot(o, stage):
    p = make_parent(f"crop_carrot_s{stage}", o)
    soil_patch("soil", o, p)
    if stage == 0:  # sprout
        for i in range(3):
            x = (i - 1) * 0.04
            cyl(f"sprt_{i}", (x, 0, 0.10), 0.008, 0.10, mats["leaf_sprout"], p, verts=6)
    elif stage == 1:  # mid
        for i in range(5):
            ang = i * (math.pi*2/5)
            x = math.cos(ang) * 0.03
            y = math.sin(ang) * 0.03
            cyl(f"l_{i}", (x, y, 0.18), 0.012, 0.30, mats["leaf_mid"], p, verts=6)
        ico("body", (0, 0, 0.06), 0.05, mats["carrot_orange"], p)
    else:  # mature
        for i in range(7):
            ang = i * (math.pi*2/7)
            x = math.cos(ang) * 0.05
            y = math.sin(ang) * 0.05
            cyl(f"l_{i}", (x, y, 0.32), 0.015, 0.50, mats["leaf_mature"], p, verts=6)
        body = ico("body", (0, 0, 0.10), 0.08, mats["carrot_orange"], p)
        body.scale = (1.0, 1.0, 1.6)
    return p

def crop_wheat(o, stage):
    p = make_parent(f"crop_wheat_s{stage}", o)
    soil_patch("soil", o, p)
    h = [0.15, 0.40, 0.70][stage]
    color = [mats["leaf_sprout"], mats["leaf_mid"], mats["wheat_mature"]][stage]
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.06
        y = math.sin(ang) * 0.06
        cyl(f"st_{i}", (x, y, h/2 + 0.06), 0.010, h, color, p, verts=6)
        if stage == 2:
            cone(f"head_{i}", (x, y, h + 0.10), 0.04, 0.015, 0.12, color, p, verts=6)
    return p

def crop_tomato(o, stage):
    p = make_parent(f"crop_tomato_s{stage}", o)
    soil_patch("soil", o, p)
    if stage == 0:
        ico("sprt", (0, 0, 0.08), 0.04, mats["leaf_sprout"], p)
    elif stage == 1:
        cyl("st", (0, 0, 0.20), 0.015, 0.40, mats["leaf_mid"], p, verts=6)
        for i, (dx, dy, dz) in enumerate([(0.06, 0, 0.10),(-0.06, 0, 0.20),(0, 0.06, 0.30)]):
            ic = ico(f"l_{i}", (dx, dy, 0.18 + dz*0.5), 0.06, mats["leaf_mid"], p)
            ic.scale = (1.0, 0.6, 0.3)
    else:  # mature with fruits
        cyl("st", (0, 0, 0.30), 0.020, 0.60, mats["leaf_mature"], p, verts=6)
        for i, (dx, dy, dz) in enumerate([(0.10, 0, 0.10),(-0.10, 0.05, 0.20),(0.05, -0.10, 0.30),(-0.05, -0.05, 0.40)]):
            ic = ico(f"l_{i}", (dx, dy, 0.18 + dz*0.6), 0.08, mats["leaf_mature"], p)
            ic.scale = (1.0, 0.6, 0.3)
        # 3 tomatoes
        for i, (fx, fy, fz) in enumerate([(0.08, 0.08, 0.40),(-0.08, 0.06, 0.30),(0.05, -0.05, 0.50)]):
            sph(f"tom_{i}", (fx, fy, fz), 0.07, mats["tomato_red"], p, segs=14)
    return p

def crop_cabbage(o, stage):
    p = make_parent(f"crop_cabbage_s{stage}", o)
    soil_patch("soil", o, p)
    if stage == 0:
        for i in range(3):
            ic = ico(f"l_{i}", ((i-1)*0.04, 0, 0.06), 0.04, mats["leaf_sprout"], p)
            ic.scale = (1.0, 0.7, 0.3)
    elif stage == 1:
        for i in range(6):
            ang = i * (math.pi*2/6)
            x = math.cos(ang) * 0.10
            y = math.sin(ang) * 0.10
            ic = ico(f"l_{i}", (x, y, 0.10), 0.10, mats["leaf_mid"], p)
            ic.scale = (1.0, 0.6, 0.4)
            ic.rotation_euler = (math.cos(ang)*0.5, math.sin(ang)*0.5, ang)
    else:
        sph("center", (0, 0, 0.18), 0.18, mats["cabbage_green"], p, segs=20)
        for i in range(8):
            ang = i * (math.pi*2/8)
            x = math.cos(ang) * 0.20
            y = math.sin(ang) * 0.20
            ic = ico(f"outer_{i}", (x, y, 0.12), 0.13, mats["cabbage_green"], p)
            ic.scale = (1.2, 0.7, 0.5)
            ic.rotation_euler = (math.cos(ang)*0.6, math.sin(ang)*0.6, ang)
    return p

# ============================================================
# FRUIT TREES
# ============================================================
def fruit_tree(o, name, fruit_mat, blossom=False):
    p = make_parent(name, o)
    cyl("trunk", (0, 0, 0.70), 0.10, 1.40, mats["bark"], p, verts=14)
    canopy = sph("canopy", (0, 0, 1.55), 0.55, mats["canopy"], p, segs=24)
    canopy.scale = (1.0, 1.0, 0.85)
    # 5 fruits hanging from canopy
    for i in range(5):
        ang = i * (math.pi*2/5)
        fx = math.cos(ang) * 0.45
        fy = math.sin(ang) * 0.45
        fz = 1.45 + math.sin(i*1.5) * 0.15
        sph(f"fruit_{i}", (fx, fy, fz), 0.08, fruit_mat, p, segs=14)
    # Optional cherry blossoms
    if blossom:
        for i in range(8):
            ang = i * (math.pi*2/8) + 0.3
            bx = math.cos(ang) * 0.50
            by = math.sin(ang) * 0.50
            bz = 1.65 + math.sin(i) * 0.10
            ic = ico(f"bl_{i}", (bx, by, bz), 0.06, mats["blossom"], p)
            ic.scale = (1.2, 1.2, 0.4)
    return p

# ============================================================
# GATHERING NODES
# ============================================================
def gathering_iron(o):
    p = make_parent("gather_iron", o)
    # Boulder base
    body = ico("rock", (0, 0, 0.20), 0.30, mats["ore_iron"], p)
    body.scale = (1.2, 0.95, 0.85)
    # 4 protruding ore chunks
    for i in range(4):
        ang = i * math.pi/2 + 0.2
        rx = math.cos(ang) * 0.20
        ry = math.sin(ang) * 0.20
        rz = 0.20 + math.sin(i)*0.10
        ico(f"vein_{i}", (rx, ry, rz + 0.10), 0.10, mats["ore_iron_v"], p)
    return p

def gathering_copper(o):
    p = make_parent("gather_copper", o)
    body = ico("rock", (0, 0, 0.20), 0.30, mats["ore_copper"], p)
    body.scale = (1.0, 1.1, 0.85)
    for i in range(5):
        ang = i * (math.pi*2/5)
        rx = math.cos(ang) * 0.18
        ry = math.sin(ang) * 0.18
        ico(f"vein_{i}", (rx, ry, 0.30), 0.09, mats["ore_copper_v"], p)
    return p

def gathering_gold(o):
    p = make_parent("gather_gold", o)
    body = ico("rock", (0, 0, 0.20), 0.30, mats["ore_gold"], p)
    body.scale = (1.0, 1.0, 0.95)
    for i in range(6):
        ang = i * (math.pi*2/6)
        rx = math.cos(ang) * 0.20
        ry = math.sin(ang) * 0.20
        rz = 0.20 + (i % 2) * 0.10
        cone(f"vein_{i}", (rx, ry, rz + 0.10), 0.06, 0.0, 0.18, mats["ore_gold_v"], p, verts=6,
             rot=(math.cos(ang)*0.4, math.sin(ang)*0.4, ang))
    return p

def gathering_herb(o):
    p = make_parent("gather_herb", o)
    soil_patch("soil", o, p)
    for i in range(7):
        ang = i * (math.pi*2/7)
        x = math.cos(ang) * 0.08
        y = math.sin(ang) * 0.08
        cyl(f"st_{i}", (x, y, 0.20), 0.012, 0.40, mats["leaf_mature"], p, verts=6)
        ic = ico(f"lf_{i}", (x*1.5, y*1.5, 0.40), 0.08, mats["leaf_mature"], p)
        ic.scale = (1.2, 0.7, 0.4)
    # Center flower
    sph("flw", (0, 0, 0.45), 0.06, mats["tomato_red"], p, segs=12)
    return p

def gathering_log_pile(o):
    p = make_parent("gather_log_pile", o)
    # 3 base logs
    for i, (lx, ly, lz, rot_z) in enumerate([(0, -0.10, 0.10, 0), (0, 0.10, 0.10, 0.1), (0, 0.0, 0.30, 0.05)]):
        cyl(f"log_{i}", (lx, ly, lz), 0.10, 0.50, mats["wood_log"], p, verts=14, rot=(0, math.pi/2, rot_z))
        # End cap with concentric rings
        cyl(f"log_{i}_end", (0.25, ly, lz), 0.10, 0.01, mats["wood_cut"], p, verts=14, rot=(0, math.pi/2, rot_z))
    return p

def gathering_mushrooms(o):
    p = make_parent("gather_mushrooms", o)
    soil_patch("soil", o, p)
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.10
        y = math.sin(ang) * 0.10
        h = 0.20 + (i % 2) * 0.06
        cyl(f"st_{i}", (x, y, h/2 + 0.06), 0.04, h, mats["mushroom_stem"], p, verts=10)
        cap = sph(f"cap_{i}", (x, y, h + 0.06), 0.10, mats["mushroom_red"], p, segs=14)
        cap.scale.z = 0.7
    return p

# ============================================================
# FISHING GEAR
# ============================================================
def fishing_rod(o):
    p = make_parent("fish_rod", o)
    cyl("handle", (0, 0, 0.15), 0.025, 0.30, mats["leather"], p, verts=10)
    cyl("rod", (0, 0, 0.85), 0.012, 1.20, mats["wood_handle"], p, verts=10, rot=(0, 0.3, 0))
    cyl("line", (0.18, 0, 1.20), 0.003, 0.40, mats["fish"], p, verts=4)
    sph("bobber", (0.18, 0, 0.80), 0.04, mats["tomato_red"], p, segs=10)
    return p

def fishing_net(o):
    p = make_parent("fish_net", o)
    cyl("handle", (0, 0, 0.30), 0.025, 0.60, mats["wood_handle"], p, verts=10)
    cyl("rim", (0, 0, 0.60), 0.18, 0.02, mats["iron"], p, verts=20)
    sph("netbody", (0, 0, 0.50), 0.18, mats["leather"], p, segs=18)
    return p

def fishing_tackle(o):
    p = make_parent("fish_tackle", o)
    box("body", (0, 0, 0.15), (0.40, 0.25, 0.30), mats["wood_handle"], p)
    box("lid", (0, 0, 0.32), (0.40, 0.25, 0.04), mats["wood_log"], p)
    cyl("handle", (0, 0, 0.36), 0.02, 0.10, mats["iron"], p, verts=8, rot=(0, math.pi/2, 0))
    box("clasp", (0, 0.13, 0.32), (0.04, 0.04, 0.05), mats["iron"], p)
    return p

def fishing_bait_jar(o):
    p = make_parent("fish_bait_jar", o)
    cyl("body", (0, 0, 0.15), 0.10, 0.30, mats["glass"], p, verts=18)
    cyl("lid", (0, 0, 0.32), 0.10, 0.04, mats["iron"], p, verts=18)
    sph("knob", (0, 0, 0.36), 0.025, mats["iron"], p, segs=10)
    # Worms inside (visible through glass)
    for i in range(4):
        ang = i * math.pi/2
        sph(f"worm_{i}", (math.cos(ang)*0.04, math.sin(ang)*0.04, 0.10 + i*0.04), 0.025, mats["leather"], p, segs=10)
    return p

def fishing_basket(o):
    p = make_parent("fish_basket", o)
    cyl("body", (0, 0, 0.15), 0.20, 0.30, mats["wood_handle"], p, verts=18)
    cyl("rim", (0, 0, 0.31), 0.21, 0.02, mats["wood_log"], p, verts=18)
    # 3 fish inside
    for i, (fx, fy, fz) in enumerate([(-0.05, 0.05, 0.30),(0.06, -0.04, 0.32),(0.0, 0.08, 0.28)]):
        f = sph(f"fish_{i}", (fx, fy, fz), 0.07, mats["fish"], p, segs=14)
        f.scale = (1.6, 0.8, 0.5)
        f.rotation_euler = (0, 0, i*0.7)
    return p

# ============================================================
# TOOLS
# ============================================================
def tool_pickaxe(o):
    p = make_parent("tool_pickaxe", o)
    cyl("handle", (0, 0, 0.40), 0.03, 0.80, mats["wood_handle"], p, verts=10)
    box("head_b", (0, 0, 0.85), (0.10, 0.06, 0.10), mats["iron"], p)
    cone("pick_l", (-0.20, 0, 0.85), 0.04, 0.0, 0.30, mats["iron"], p, verts=8, rot=(0, -math.pi/2, 0))
    cone("pick_r", (0.20, 0, 0.85), 0.04, 0.0, 0.30, mats["iron"], p, verts=8, rot=(0, math.pi/2, 0))
    return p

def tool_woodaxe(o):
    p = make_parent("tool_woodaxe", o)
    cyl("handle", (0, 0, 0.40), 0.03, 0.80, mats["wood_handle"], p, verts=10)
    box("head", (0.08, 0, 0.85), (0.18, 0.06, 0.20), mats["iron"], p)
    box("blade", (0.18, 0, 0.85), (0.04, 0.06, 0.30), mats["iron"], p)
    return p

def tool_hoe(o):
    p = make_parent("tool_hoe", o)
    cyl("handle", (0, 0, 0.45), 0.025, 0.90, mats["wood_handle"], p, verts=10)
    box("head", (0.10, 0, 0.92), (0.20, 0.04, 0.06), mats["iron"], p, rot=(0, 0.3, 0))
    box("blade", (0.20, 0, 0.85), (0.04, 0.10, 0.18), mats["iron"], p)
    return p

def tool_sickle(o):
    p = make_parent("tool_sickle", o)
    cyl("handle", (0, 0, 0.20), 0.025, 0.40, mats["wood_handle"], p, verts=10)
    # Curved blade approximation: 3 segments forming an arc
    for i, ang in enumerate([0.0, math.pi/4, math.pi/2]):
        x = math.cos(ang) * 0.15
        z = 0.40 + math.sin(ang) * 0.15
        box(f"bl_{i}", (x, 0, z), (0.10, 0.04, 0.04), mats["iron"], p, rot=(0, ang, 0))
    return p

# ============================================================
# LAYOUT — grid arrangement
# ============================================================
parent = bpy.data.objects.new("v3_farming", None); scene.collection.objects.link(parent)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "fm_floor"; fl.scale = (24, 14, 0.10)
fl.data.materials.append(mats["floor"]); add_subsurf_bevel(fl, levels=1, bevel=0.005)

# Build all items with positions in grid
ALL_ITEMS = []
COL_SP = 1.6
ROW_SP = 2.5

# Row 0: 12 crops (4 crops × 3 stages)
crops = [
    ("carrot",  crop_carrot),
    ("wheat",   crop_wheat),
    ("tomato",  crop_tomato),
    ("cabbage", crop_cabbage),
]
for ci, (cname, builder) in enumerate(crops):
    for stage in range(3):
        col = ci * 3 + stage
        x = -9 + col * COL_SP
        y = -5
        obj = builder(Vector((x, y, 0)), stage)
        obj.parent = parent
        ALL_ITEMS.append((f"crop_{cname}_s{stage}", obj))

# Row 1: 4 fruit trees (with 6 empty slots)
fruit_trees_list = [
    ("apple",  mats["apple"],  False),
    ("lemon",  mats["lemon"],  False),
    ("cherry", mats["cherry"], True),
    ("peach",  mats["peach"],  False),
]
for ci, (tname, fmat, bloss) in enumerate(fruit_trees_list):
    x = -9 + ci * (COL_SP * 2.4)
    y = -5 + ROW_SP
    obj = fruit_tree(Vector((x, y, 0)), f"tree_{tname}", fmat, blossom=bloss)
    obj.parent = parent
    ALL_ITEMS.append((f"tree_{tname}", obj))

# Row 2: 6 gathering nodes
gather_nodes = [
    ("iron",      gathering_iron),
    ("copper",    gathering_copper),
    ("gold",      gathering_gold),
    ("herb",      gathering_herb),
    ("log_pile",  gathering_log_pile),
    ("mushroom",  gathering_mushrooms),
]
for ci, (gname, builder) in enumerate(gather_nodes):
    x = -9 + ci * (COL_SP * 1.8)
    y = -5 + ROW_SP * 2
    obj = builder(Vector((x, y, 0)))
    obj.parent = parent
    ALL_ITEMS.append((f"gather_{gname}", obj))

# Row 3: 5 fishing gear
fishing_items = [
    ("rod",     fishing_rod),
    ("net",     fishing_net),
    ("tackle",  fishing_tackle),
    ("bait",    fishing_bait_jar),
    ("basket",  fishing_basket),
]
for ci, (fname, builder) in enumerate(fishing_items):
    x = -9 + ci * (COL_SP * 2.2)
    y = -5 + ROW_SP * 3
    obj = builder(Vector((x, y, 0)))
    obj.parent = parent
    ALL_ITEMS.append((f"fish_{fname}", obj))

# Row 4: 4 tools
tools = [
    ("pickaxe", tool_pickaxe),
    ("woodaxe", tool_woodaxe),
    ("hoe",     tool_hoe),
    ("sickle",  tool_sickle),
]
for ci, (tname, builder) in enumerate(tools):
    x = -9 + ci * (COL_SP * 2.4)
    y = -5 + ROW_SP * 4
    obj = builder(Vector((x, y, 0)))
    obj.parent = parent
    ALL_ITEMS.append((f"tool_{tname}", obj))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -12, 14))
key = bpy.context.object
key.data.energy = 2200; key.data.color = (1.0, 0.95, 0.85); key.data.size = 14

bpy.ops.object.light_add(type='AREA', location=(-8, 12, 12))
fill = bpy.context.object
fill.data.energy = 900; fill.data.color = (0.65, 0.78, 1.0); fill.data.size = 14

bpy.ops.object.light_add(type='AREA', location=(0, 14, 6))
rim = bpy.context.object
rim.data.energy = 600; rim.data.color = (1.0, 0.85, 0.55); rim.data.size = 12

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 6.3
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_grid = add_cam("cam_grid", Vector((0, -16, 14)), Vector((0, 0, 0.5)), lens=28, dof_dist=20)

CAT_NAMES = ["crops", "trees", "gathering", "fishing", "tools"]
CAT_CAMS = []
for r, name in enumerate(CAT_NAMES):
    y = -5 + r * ROW_SP
    cam = add_cam(f"cam_{name}", Vector((0, y - 4, 2.5)), Vector((0, y, 0.6)), lens=50, dof_dist=6)
    CAT_CAMS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
scene.camera = cam_grid
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_farming_grid.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for name, cam in CAT_CAMS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_farming_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-item GLB
for name, obj in ALL_ITEMS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"farm_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )

print("=== V3 Epic 26 Farming & Gathering complete ===")
