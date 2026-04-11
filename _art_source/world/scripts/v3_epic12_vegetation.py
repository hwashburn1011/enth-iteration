"""
Expansion V3 — Epic 12 — Vegetation Library Texture Pass
========================================================
Hero-quality vegetation library with 5 plant categories laid out in a
showcase scene + 5 per-category close-up renders.

Categories (28 hero models):
  TREES (6):    oak, pine, birch, willow, autumn maple, dead snag
  SHRUBS (4):   round bush, thorn bush, juniper, flowering shrub
  GRASS (5):    short tuft, tall blade, fern, reed, wheat
  FLOWERS (8):  daisy, tulip, poppy, sunflower, bell, lily, rose, lavender
  VINES (3):    creeping ivy, hanging vine, ground creeper
  + 2 mushroom varieties

Each plant uses full V3 5-layer PBR shader graph + subdivision surface +
bevel modifiers. Foliage shaders include subsurface translucency for
realistic backlit-leaf glow.

Outputs:
  - 1 hero showcase render @ 1920x1080
  - 5 category close-up renders @ 1280x960
  - 28 GLB exports (one per plant)
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(12)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_vegetation.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3_veg_world")
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
        r.color_ramp.elements[0].color = (base_color[0]*0.80, base_color[1]*0.80, base_color[2]*0.80, 1)
        r.color_ramp.elements[1].position = 0.70
        r.color_ramp.elements[1].color = (min(base_color[0]*1.20,1), min(base_color[1]*1.20,1), min(base_color[2]*1.20,1), 1)
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
        ar.color_ramp.elements[0].color = (0.15,0.10,0.06,1)
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

def make_foliage(name, base_color, secondary_color, sss_amount=0.4):
    """Foliage shader with subsurface scattering for backlit leaf glow."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Subsurface Weight"].default_value = sss_amount
    bsdf.inputs["Subsurface Radius"].default_value = (1.2, 0.4, 0.2)
    bsdf.inputs["Subsurface Scale"].default_value = 0.3
    links.new(bsdf.outputs[0], out.inputs[0])

    # color variation noise
    tc = nodes.new("ShaderNodeTexCoord"); tc.location=(-1100,0)
    mp = nodes.new("ShaderNodeMapping"); mp.location=(-900,0)
    mp.inputs["Scale"].default_value = (5,5,5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])
    n = nodes.new("ShaderNodeTexNoise"); n.location=(-650,200)
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location=(-400,200)
    ramp.color_ramp.elements[0].position = 0.30
    ramp.color_ramp.elements[0].color = (*base_color, 1)
    ramp.color_ramp.elements[1].position = 0.70
    ramp.color_ramp.elements[1].color = (*secondary_color, 1)
    links.new(n.outputs["Fac"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # Veining bump
    v = nodes.new("ShaderNodeTexVoronoi"); v.location=(-650,-200)
    v.feature='F1'; v.inputs["Scale"].default_value = 18.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location=(-400,-200)
    bp.inputs["Strength"].default_value = 0.18
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_petal(name, color, glow=0.8):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (800, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (500, 0)
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = 0.55
    bsdf.inputs["Subsurface Weight"].default_value = 0.6
    bsdf.inputs["Subsurface Radius"].default_value = (0.6, 0.4, 0.3)
    bsdf.inputs["Subsurface Scale"].default_value = 0.15
    bsdf.inputs["Emission Color"].default_value = (*color, 1)
    bsdf.inputs["Emission Strength"].default_value = glow
    links.new(bsdf.outputs[0], out.inputs[0])
    return m

# ============================================================
# MATERIALS
# ============================================================
mats = {}
# Bark variants
mats["bark_oak"] = make_pbr("v3vg_bark_oak", (0.18,0.11,0.06), 0.95,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=12.0, bump_strength=0.45, bump_scale=18.0)
mats["bark_pine"] = make_pbr("v3vg_bark_pine", (0.20,0.12,0.07), 0.95,
    noise_strength=0.30, voronoi_strength=0.50, voronoi_scale=18.0, bump_strength=0.40, bump_scale=22.0)
mats["bark_birch"] = make_pbr("v3vg_bark_birch", (0.85,0.82,0.78), 0.85,
    noise_strength=0.30, voronoi_strength=0.20, voronoi_scale=24.0, bump_strength=0.20, bump_scale=80.0)
mats["bark_willow"] = make_pbr("v3vg_bark_willow", (0.22,0.18,0.12), 0.95,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=14.0, bump_strength=0.40, bump_scale=20.0)
mats["bark_dead"] = make_pbr("v3vg_bark_dead", (0.45,0.40,0.32), 0.95,
    noise_strength=0.40, voronoi_strength=0.60, voronoi_scale=10.0, bump_strength=0.55, bump_scale=14.0)

# Foliage with SSS
mats["leaf_summer"] = make_foliage("v3vg_leaf_summer", (0.10,0.30,0.08), (0.25,0.45,0.12))
mats["leaf_pine"] = make_foliage("v3vg_leaf_pine", (0.08,0.20,0.10), (0.12,0.28,0.10), sss_amount=0.25)
mats["leaf_autumn"] = make_foliage("v3vg_leaf_autumn", (0.65,0.30,0.05), (0.85,0.45,0.10))
mats["leaf_birch"] = make_foliage("v3vg_leaf_birch", (0.40,0.55,0.18), (0.55,0.70,0.20))
mats["leaf_willow"] = make_foliage("v3vg_leaf_willow", (0.25,0.45,0.12), (0.40,0.60,0.18))
mats["fern"] = make_foliage("v3vg_fern", (0.18,0.40,0.14), (0.28,0.55,0.18))
mats["grass_short"] = make_foliage("v3vg_grass_short", (0.22,0.42,0.12), (0.30,0.55,0.16))
mats["grass_tall"] = make_foliage("v3vg_grass_tall", (0.30,0.50,0.14), (0.45,0.65,0.18))
mats["wheat"] = make_foliage("v3vg_wheat", (0.78,0.62,0.20), (0.90,0.78,0.32), sss_amount=0.5)
mats["reed"] = make_foliage("v3vg_reed", (0.25,0.40,0.16), (0.35,0.55,0.20))
mats["thorn_leaf"] = make_foliage("v3vg_thorn_leaf", (0.15,0.32,0.10), (0.22,0.40,0.14))

# Petals
mats["petal_white"] = make_petal("v3vg_petal_white", (0.95,0.95,0.92), glow=0.8)
mats["petal_yellow"] = make_petal("v3vg_petal_yellow", (1.0,0.85,0.20), glow=1.0)
mats["petal_red"] = make_petal("v3vg_petal_red", (0.95,0.18,0.20), glow=0.8)
mats["petal_orange"] = make_petal("v3vg_petal_orange", (1.0,0.55,0.10), glow=1.0)
mats["petal_purple"] = make_petal("v3vg_petal_purple", (0.65,0.25,0.85), glow=0.8)
mats["petal_pink"] = make_petal("v3vg_petal_pink", (0.95,0.60,0.75), glow=0.7)
mats["petal_blue"] = make_petal("v3vg_petal_blue", (0.30,0.45,0.95), glow=0.8)
mats["petal_lavender"] = make_petal("v3vg_petal_lavender", (0.65,0.55,0.95), glow=0.9)
mats["sunflower_seed"] = make_pbr("v3vg_sun_seed", (0.30,0.18,0.08), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=30.0, bump_strength=0.30, bump_scale=60.0)

# Stems and ground
mats["stem"] = make_foliage("v3vg_stem", (0.18,0.32,0.10), (0.25,0.40,0.12))
mats["vine"] = make_foliage("v3vg_vine", (0.20,0.38,0.12), (0.30,0.50,0.14))
mats["mushroom_red"] = make_pbr("v3vg_mush_red", (0.85,0.18,0.18), 0.65,
    emission_color=(0.95,0.30,0.25), emission_strength=0.4,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=80.0,
    curvature_dirt=False, fresnel_rim=True, bump_strength=0.20, bump_scale=80.0)
mats["mushroom_glow"] = make_pbr("v3vg_mush_glow", (0.65,0.85,1.0), 0.40,
    emission_color=(0.55,0.85,1.0), emission_strength=4.0,
    noise_strength=0.15, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05)
mats["mushroom_stem"] = make_pbr("v3vg_mush_stem", (0.85,0.78,0.65), 0.85,
    noise_strength=0.20, curvature_dirt=True, bump_strength=0.20, bump_scale=40.0)
mats["ground"] = make_pbr("v3vg_ground", (0.20,0.30,0.12), 0.95,
    noise_strength=0.30, voronoi_strength=0.30, voronoi_scale=20.0, bump_strength=0.25, bump_scale=18.0)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def cyl(name, loc, r, depth, mat, parent, verts=18, rot=(0,0,0)):
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

def ico(name, loc, r, mat, parent, sub=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=14):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.01)
    o.parent = parent
    return o

# ============================================================
# PLANT BUILDERS — each returns the parent object
# ============================================================
def plant(name, origin):
    p = bpy.data.objects.new(name, None); scene.collection.objects.link(p)
    p.location = origin
    return p

# ---------- TREES ----------
def tree_oak(origin, name="oak"):
    p = plant(f"vg_{name}", origin)
    cyl("trunk", (0,0,1.5), 0.20, 3.0, mats["bark_oak"], p)
    # main canopy
    sph("c_main", (0,0,3.4), 1.2, mats["leaf_summer"], p, segs=20)
    # secondary clumps
    for i, (dx, dy, dz, r) in enumerate([(0.7,0,0.6,0.7),(-0.6,0.2,0.4,0.65),(0.2,-0.6,0.7,0.6),(-0.3,-0.5,0.3,0.55),(0.4,0.5,0.4,0.5)]):
        sph(f"c_{i}", (dx, dy, 3.4+dz), r, mats["leaf_summer"], p)
    # branches
    for i, ang in enumerate([0.3, 1.4, 2.5, 3.8, 5.0]):
        bx = math.cos(ang)*0.25
        by = math.sin(ang)*0.25
        cyl(f"br_{i}", (bx, by, 2.7+i*0.1), 0.05, 0.8, mats["bark_oak"], p, rot=(0.5+i*0.1, 0, ang))
    return p

def tree_pine(origin, name="pine"):
    p = plant(f"vg_{name}", origin)
    cyl("trunk", (0,0,2.0), 0.18, 4.0, mats["bark_pine"], p)
    # 4 stacked cones
    for i in range(4):
        r1 = 1.4 - i*0.30
        z = 2.0 + i*0.85
        cone(f"c{i}", (0,0,z), r1, 0, 1.4, mats["leaf_pine"], p, verts=18)
    return p

def tree_birch(origin, name="birch"):
    p = plant(f"vg_{name}", origin)
    cyl("trunk", (0,0,2.0), 0.14, 4.0, mats["bark_birch"], p)
    sph("c_main", (0,0,4.4), 1.0, mats["leaf_birch"], p, segs=20)
    for i, (dx, dy, dz, r) in enumerate([(0.5,0.2,0.5,0.55),(-0.5,0,0.4,0.55),(0.1,-0.5,0.6,0.55),(-0.2,0.4,0.3,0.45)]):
        sph(f"c_{i}", (dx, dy, 4.4+dz), r, mats["leaf_birch"], p)
    return p

def tree_willow(origin, name="willow"):
    p = plant(f"vg_{name}", origin)
    cyl("trunk", (0,0,1.5), 0.22, 3.0, mats["bark_willow"], p)
    # broad drooping canopy (flatter sphere + dangling tendrils)
    c = sph("c_main", (0,0,3.0), 1.3, mats["leaf_willow"], p, segs=22)
    c.scale.z = 0.6
    # dangling tendrils
    for i in range(8):
        ang = i * (math.pi*2/8)
        tx = math.cos(ang)*1.1
        ty = math.sin(ang)*1.1
        cyl(f"td_{i}", (tx, ty, 2.0), 0.04, 1.4, mats["leaf_willow"], p, verts=8)
    return p

def tree_autumn(origin, name="autumn"):
    p = plant(f"vg_{name}", origin)
    cyl("trunk", (0,0,1.6), 0.20, 3.2, mats["bark_oak"], p)
    sph("c_main", (0,0,3.8), 1.2, mats["leaf_autumn"], p, segs=20)
    for i, (dx, dy, dz, r) in enumerate([(0.7,0,0.5,0.65),(-0.6,0.3,0.3,0.6),(0.2,-0.6,0.6,0.55),(-0.3,-0.4,0.2,0.5)]):
        sph(f"c_{i}", (dx, dy, 3.8+dz), r, mats["leaf_autumn"], p)
    return p

def tree_dead(origin, name="dead"):
    p = plant(f"vg_{name}", origin)
    cyl("trunk", (0,0,1.7), 0.22, 3.4, mats["bark_dead"], p)
    # bare branches reaching upward
    for i, ang in enumerate([0.3, 1.5, 2.7, 3.9, 5.0]):
        for j in range(2):
            bx = math.cos(ang+j*0.2)*0.15
            by = math.sin(ang+j*0.2)*0.15
            cyl(f"br_{i}_{j}", (bx, by, 3.0+j*0.2), 0.06-j*0.02, 1.0-j*0.3,
                 mats["bark_dead"], p, verts=8, rot=(0.5+j*0.3, 0, ang))
    return p

# ---------- SHRUBS ----------
def shrub_round(origin, name="bush_round"):
    p = plant(f"vg_{name}", origin)
    sph("b1", (0, 0, 0.5), 0.55, mats["leaf_summer"], p, segs=18)
    sph("b2", (0.3, 0.2, 0.45), 0.40, mats["leaf_summer"], p)
    sph("b3", (-0.3, 0.1, 0.45), 0.40, mats["leaf_summer"], p)
    sph("b4", (0.1, -0.3, 0.50), 0.45, mats["leaf_summer"], p)
    return p

def shrub_thorn(origin, name="bush_thorn"):
    p = plant(f"vg_{name}", origin)
    sph("b1", (0, 0, 0.45), 0.50, mats["thorn_leaf"], p, segs=18)
    sph("b2", (0.30, 0.15, 0.40), 0.38, mats["thorn_leaf"], p)
    sph("b3", (-0.25, 0.10, 0.40), 0.36, mats["thorn_leaf"], p)
    # protruding thorns
    for i, ang in enumerate([0.0, 1.2, 2.4, 3.6, 4.8]):
        x = math.cos(ang) * 0.55
        y = math.sin(ang) * 0.55
        cone(f"th_{i}", (x, y, 0.5), 0.04, 0.0, 0.20, mats["bark_dead"], p, verts=6)
    return p

def shrub_juniper(origin, name="bush_juniper"):
    p = plant(f"vg_{name}", origin)
    cone("c1", (0, 0, 0.7), 0.55, 0, 1.4, mats["leaf_pine"], p, verts=18)
    cone("c2", (0.20, 0.10, 0.55), 0.32, 0, 0.9, mats["leaf_pine"], p)
    cone("c3", (-0.25, 0.05, 0.55), 0.30, 0, 0.85, mats["leaf_pine"], p)
    return p

def shrub_flower(origin, name="bush_flower"):
    p = plant(f"vg_{name}", origin)
    sph("base", (0, 0, 0.45), 0.50, mats["leaf_summer"], p, segs=18)
    sph("b2", (0.25, 0.10, 0.40), 0.38, mats["leaf_summer"], p)
    sph("b3", (-0.20, 0.15, 0.42), 0.36, mats["leaf_summer"], p)
    # pink flowers scattered on top
    for i in range(7):
        ang = i * (math.pi*2/7)
        fx = math.cos(ang) * 0.40
        fy = math.sin(ang) * 0.40
        ico(f"fl_{i}", (fx, fy, 0.85), 0.10, mats["petal_pink"], p)
    return p

# ---------- GRASS ----------
def grass_short(origin, name="grass_short"):
    p = plant(f"vg_{name}", origin)
    for i in range(8):
        ang = i * (math.pi*2/8)
        x = math.cos(ang) * 0.05
        y = math.sin(ang) * 0.05
        cone(f"bl_{i}", (x, y, 0.10), 0.02, 0, 0.20, mats["grass_short"], p, verts=6)
    sph("base", (0, 0, 0.05), 0.10, mats["grass_short"], p)
    return p

def grass_tall(origin, name="grass_tall"):
    p = plant(f"vg_{name}", origin)
    for i in range(10):
        ang = i * (math.pi*2/10)
        x = math.cos(ang) * 0.06
        y = math.sin(ang) * 0.06
        cyl(f"bl_{i}", (x, y, 0.30), 0.01, 0.60, mats["grass_tall"], p, verts=6,
             rot=(0.2 * (i%3 - 1), 0.2 * (i%2 - 0.5), 0))
    return p

def grass_fern(origin, name="fern"):
    p = plant(f"vg_{name}", origin)
    # central stalk
    cyl("st", (0, 0, 0.20), 0.015, 0.40, mats["fern"], p, verts=6)
    # 8 fronds in a fan
    for i in range(8):
        ang = i * (math.pi*2/8)
        fx = math.cos(ang) * 0.04
        fy = math.sin(ang) * 0.04
        cone(f"fr_{i}", (fx*4, fy*4, 0.30), 0.06, 0, 0.50, mats["fern"], p, verts=8)
    return p

def grass_reed(origin, name="reed"):
    p = plant(f"vg_{name}", origin)
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.10
        y = math.sin(ang) * 0.10
        cyl(f"r_{i}", (x, y, 0.50), 0.02, 1.0, mats["reed"], p, verts=6)
        cone(f"top_{i}", (x, y, 1.05), 0.05, 0.0, 0.15, mats["wheat"], p, verts=6)
    return p

def grass_wheat(origin, name="wheat"):
    p = plant(f"vg_{name}", origin)
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.08
        y = math.sin(ang) * 0.08
        cyl(f"st_{i}", (x, y, 0.40), 0.015, 0.80, mats["wheat"], p, verts=6)
        # head
        cone(f"hd_{i}", (x, y, 0.90), 0.05, 0.02, 0.20, mats["wheat"], p, verts=6)
    return p

# ---------- FLOWERS ----------
def flower_daisy(origin, name="flower_daisy"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.20), 0.015, 0.40, mats["stem"], p, verts=6)
    sph("center", (0, 0, 0.42), 0.06, mats["petal_yellow"], p)
    for i in range(8):
        ang = i * (math.pi*2/8)
        x = math.cos(ang) * 0.10
        y = math.sin(ang) * 0.10
        ic = ico(f"pt_{i}", (x, y, 0.42), 0.06, mats["petal_white"], p)
        ic.scale = (1.4, 0.6, 0.3)
        ic.rotation_euler.z = ang
    return p

def flower_tulip(origin, name="flower_tulip"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.30), 0.018, 0.60, mats["stem"], p, verts=6)
    # tulip cup — 6 petals curved
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.05
        y = math.sin(ang) * 0.05
        ic = ico(f"pt_{i}", (x, y, 0.62), 0.08, mats["petal_red"], p)
        ic.scale = (0.5, 0.5, 1.4)
        ic.rotation_euler = (math.cos(ang)*0.4, math.sin(ang)*0.4, ang)
    # leaf
    cone("lf", (0.05, 0, 0.20), 0.06, 0.0, 0.40, mats["stem"], p, verts=6)
    return p

def flower_poppy(origin, name="flower_poppy"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.35), 0.015, 0.70, mats["stem"], p, verts=6)
    sph("center", (0, 0, 0.72), 0.05, mats["sunflower_seed"], p)
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.10
        y = math.sin(ang) * 0.10
        ic = ico(f"pt_{i}", (x, y, 0.72), 0.10, mats["petal_red"], p)
        ic.scale = (1.4, 1.0, 0.3)
        ic.rotation_euler.z = ang
    return p

def flower_sunflower(origin, name="flower_sunflower"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.50), 0.025, 1.0, mats["stem"], p, verts=8)
    sph("center", (0, 0, 1.05), 0.18, mats["sunflower_seed"], p)
    for i in range(12):
        ang = i * (math.pi*2/12)
        x = math.cos(ang) * 0.22
        y = math.sin(ang) * 0.22
        ic = ico(f"pt_{i}", (x, y, 1.05), 0.10, mats["petal_yellow"], p)
        ic.scale = (1.6, 0.8, 0.3)
        ic.rotation_euler.z = ang
    # broad leaf
    cone("lf", (0.10, 0, 0.40), 0.10, 0.0, 0.30, mats["stem"], p, verts=6)
    return p

def flower_bell(origin, name="flower_bell"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.30), 0.015, 0.60, mats["stem"], p, verts=6)
    # 4 hanging bells along stem
    for i, z in enumerate([0.40, 0.50, 0.55]):
        x = (i-1) * 0.05
        b = ico(f"bl_{i}", (x, 0.05, z), 0.06, mats["petal_blue"], p)
        b.scale = (1.0, 1.0, 1.4)
    return p

def flower_lily(origin, name="flower_lily"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.40), 0.018, 0.80, mats["stem"], p, verts=6)
    # 6 long tapered petals fanning outward
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.06
        y = math.sin(ang) * 0.06
        cone(f"pt_{i}", (x, y, 0.85), 0.08, 0.0, 0.25, mats["petal_orange"], p, verts=6)
    sph("center", (0, 0, 0.82), 0.04, mats["petal_yellow"], p)
    return p

def flower_rose(origin, name="flower_rose"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.30), 0.020, 0.60, mats["stem"], p, verts=6)
    # tightly packed petals — center sphere then 5 surrounding
    sph("c", (0, 0, 0.65), 0.10, mats["petal_red"], p)
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.08
        y = math.sin(ang) * 0.08
        ic = ico(f"pt_{i}", (x, y, 0.66), 0.08, mats["petal_red"], p)
        ic.scale = (1.0, 1.0, 0.6)
        ic.rotation_euler = (math.cos(ang)*0.3, math.sin(ang)*0.3, ang)
    # thorns on stem
    cone("th1", (0.025, 0, 0.5), 0.012, 0.0, 0.04, mats["bark_dead"], p, verts=4)
    cone("th2", (-0.025, 0, 0.4), 0.012, 0.0, 0.04, mats["bark_dead"], p, verts=4)
    return p

def flower_lavender(origin, name="flower_lavender"):
    p = plant(f"vg_{name}", origin)
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.06
        y = math.sin(ang) * 0.06
        cyl(f"st_{i}", (x, y, 0.30), 0.012, 0.60, mats["stem"], p, verts=6)
        # spike of small purple buds
        for j in range(5):
            bz = 0.50 + j * 0.06
            ic = ico(f"bd_{i}_{j}", (x, y, bz), 0.025, mats["petal_lavender"], p)
            ic.scale = (1.0, 1.0, 0.6)
    return p

# ---------- VINES ----------
def vine_creeping(origin, name="vine_creeping"):
    p = plant(f"vg_{name}", origin)
    # winding tube along ground in zig-zag
    for i in range(8):
        x = -0.4 + i * 0.12
        y = 0.05 * math.sin(i)
        cyl(f"v_{i}", (x, y, 0.05), 0.025, 0.16, mats["vine"], p, verts=6, rot=(0, math.pi/2, math.sin(i)*0.5))
        if i % 2 == 0:
            ico(f"lf_{i}", (x, y, 0.10), 0.08, mats["leaf_summer"], p)
    return p

def vine_hanging(origin, name="vine_hanging"):
    p = plant(f"vg_{name}", origin)
    cyl("anch", (0, 0, 1.0), 0.04, 0.10, mats["bark_dead"], p)
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.10
        y = math.sin(ang) * 0.10
        cyl(f"v_{i}", (x, y, 0.5), 0.025, 1.0, mats["vine"], p, verts=6)
        for j in range(3):
            ico(f"lf_{i}_{j}", (x*1.5, y*1.5, 0.85 - j*0.30), 0.07, mats["leaf_summer"], p)
    return p

def vine_creeper(origin, name="vine_creeper"):
    p = plant(f"vg_{name}", origin)
    # ground patch with mossy clumps
    for i in range(8):
        ang = i * (math.pi*2/8)
        x = math.cos(ang) * 0.30
        y = math.sin(ang) * 0.30
        ic = ico(f"cl_{i}", (x, y, 0.05), 0.12, mats["leaf_summer"], p)
        ic.scale.z = 0.4
    ic = ico("center", (0, 0, 0.05), 0.18, mats["leaf_summer"], p)
    ic.scale.z = 0.4
    return p

# ---------- MUSHROOMS ----------
def mushroom_red(origin, name="mushroom_red"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.20), 0.06, 0.40, mats["mushroom_stem"], p, verts=12)
    s = sph("cap", (0, 0, 0.50), 0.18, mats["mushroom_red"], p, segs=20)
    s.scale.z = 0.7
    # white spots on cap
    for i, (dx, dy) in enumerate([(0.08,0),(0,0.08),(-0.08,0),(0.05,0.05),(-0.05,-0.05)]):
        ic = ico(f"sp_{i}", (dx, dy, 0.60), 0.025, mats["petal_white"], p)
        ic.scale.z = 0.4
    return p

def mushroom_glow(origin, name="mushroom_glow"):
    p = plant(f"vg_{name}", origin)
    cyl("st", (0, 0, 0.18), 0.04, 0.36, mats["mushroom_stem"], p, verts=10)
    cone("cap", (0, 0, 0.46), 0.14, 0.04, 0.20, mats["mushroom_glow"], p, verts=18)
    return p

# ============================================================
# LAYOUT — 5x6 grid of 28 plants on a ground plane
# ============================================================
ground_p = plant("vg_ground_holder", Vector((0,0,0)))
bpy.ops.mesh.primitive_plane_add(size=24, location=(0,0,0))
gnd = bpy.context.object; gnd.name = "vg_ground"
gnd.data.materials.append(mats["ground"]); add_subsurf_bevel(gnd, levels=1, bevel=0.002)
gnd.parent = ground_p

PLANTS = [
    # TREES — back row, big
    ("oak",       tree_oak,    Vector((-9, 6, 0))),
    ("pine",      tree_pine,   Vector((-5, 6, 0))),
    ("birch",     tree_birch,  Vector((-1, 6, 0))),
    ("willow",    tree_willow, Vector(( 3, 6, 0))),
    ("autumn",    tree_autumn, Vector(( 7, 6, 0))),
    ("dead",      tree_dead,   Vector((10, 6, 0))),
    # SHRUBS — second row
    ("bush_round",   shrub_round,   Vector((-9, 2, 0))),
    ("bush_thorn",   shrub_thorn,   Vector((-6, 2, 0))),
    ("bush_juniper", shrub_juniper, Vector((-3, 2, 0))),
    ("bush_flower",  shrub_flower,  Vector(( 0, 2, 0))),
    # FLOWERS — third row
    ("flower_daisy",     flower_daisy,     Vector((-9, -1, 0))),
    ("flower_tulip",     flower_tulip,     Vector((-7, -1, 0))),
    ("flower_poppy",     flower_poppy,     Vector((-5, -1, 0))),
    ("flower_sunflower", flower_sunflower, Vector((-2, -1, 0))),
    ("flower_bell",      flower_bell,      Vector(( 1, -1, 0))),
    ("flower_lily",      flower_lily,      Vector(( 3, -1, 0))),
    ("flower_rose",      flower_rose,      Vector(( 5, -1, 0))),
    ("flower_lavender",  flower_lavender,  Vector(( 7, -1, 0))),
    # GRASS — fourth row
    ("grass_short", grass_short, Vector((-9, -3.5, 0))),
    ("grass_tall",  grass_tall,  Vector((-7, -3.5, 0))),
    ("fern",        grass_fern,  Vector((-5, -3.5, 0))),
    ("reed",        grass_reed,  Vector((-3, -3.5, 0))),
    ("wheat",       grass_wheat, Vector((-1, -3.5, 0))),
    # VINES — front row
    ("vine_creeping", vine_creeping, Vector((1, -3.5, 0))),
    ("vine_hanging",  vine_hanging,  Vector((3, -3.5, 0))),
    ("vine_creeper",  vine_creeper,  Vector((5, -3.5, 0))),
    # MUSHROOMS
    ("mushroom_red",  mushroom_red,  Vector((7, -3.5, 0))),
    ("mushroom_glow", mushroom_glow, Vector((9, -3.5, 0))),
]

PLANT_OBJS = []
for name, builder, origin in PLANTS:
    obj = builder(origin, name=name)
    PLANT_OBJS.append((name, obj, origin))

# ============================================================
# LIGHTING — sunlit + warm fill + cool back rim
# ============================================================
bpy.ops.object.light_add(type='SUN', location=(8, -10, 15))
sun = bpy.context.object
sun.data.energy = 4.0
sun.data.color = (1.0, 0.92, 0.78)
sun.data.angle = math.radians(2)
direction = Vector((0,0,0)) - sun.location
sun.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-8, -8, 8))
fill = bpy.context.object
fill.data.energy = 800; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 8

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=None):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.0
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_overview = add_cam("cam_overview", Vector((0, -16, 9)), Vector((0, 0, 2)), lens=35)
cam_trees   = add_cam("cam_trees",     Vector((0, -3, 4)),  Vector((0, 6, 3)), lens=50)
cam_shrubs  = add_cam("cam_shrubs",    Vector((-4, -2, 2)), Vector((-4, 2, 0.5)), lens=70)
cam_flowers = add_cam("cam_flowers",   Vector((-2, -4, 1.5)), Vector((-2, -1, 0.6)), lens=85)
cam_grass   = add_cam("cam_grass",     Vector((-4, -6, 1)),  Vector((-4, -3.5, 0.4)), lens=85)
cam_vine    = add_cam("cam_vine",      Vector((4, -6, 1)),   Vector((4, -3.5, 0.4)), lens=85)

CAMERAS = [
    ("overview", cam_overview, (1920,1080)),
    ("trees",    cam_trees,    (1280, 960)),
    ("shrubs",   cam_shrubs,   (1280, 960)),
    ("flowers",  cam_flowers,  (1280, 960)),
    ("grass",    cam_grass,    (1280, 960)),
    ("vines",    cam_vine,     (1280, 960)),
]

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam, (w, h) in CAMERAS:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_vegetation_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-plant GLB exports
for name, obj, _ in PLANT_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"plant_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )
    print(f"Exported: {out_path}")

print("=== V3 Epic 12 Vegetation Library complete ===")
