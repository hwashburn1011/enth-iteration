"""
Expansion V3 — ROUND 2 — Epic R2-09 — Wilderness Refinement
===========================================================
Round 2 of V3-09 Wilderness. Focus on QUALITY over scale — 40x40
plot instead of R1's 60x60, but every element gets the Round 2
stack (UV unwrap + vertex color paint + multires + 5-seg bevel +
vertex-color-aware shaders).

Scene contents:
  - Displaced heightmap terrain (40x40 plane, 100 cuts) with
    multi-octave noise + carved central river valley + raised
    mountain edges
  - Vertex-color-painted terrain biome variation (random hash per
    vertex drives slope shader bias toward grass/rock/dirt)
  - Slope-blended PBR shader: rock on slope (Z<0.55), grass on
    flat (Z>0.85), dirt in mid (0.55-0.85)
  - 12 multires trees (smaller forest, each tree higher quality)
  - Flowing river plane with refined ripple shader
  - Stone ruins (broken obelisk + arch + 3 fallen blocks)
  - Background mountain silhouette ridge (5 distance peaks)
  - 24 wildflowers along riverbank
  - 8 path stones from foreground to riverbank
  - Hosek-Wilkie sky + 5W sun + cool fill (NO world volumetrics)

Outputs: 4 hero shots @ 1920x1080 + 1 GLB.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, noise as bnoise

random.seed(109)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_r2_wilderness.blend"
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

# Hosek-Wilkie sky — afternoon sun
scene.world = bpy.data.worlds.new("v3r2w_world")
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
# REFINED VC-AWARE SLOPE TERRAIN SHADER
# ============================================================
def make_slope_terrain():
    """Slope-blended terrain shader — rock on slopes, grass on flats,
    dirt in mid-slope. Reads vertex Color attribute to add per-vertex
    bias (red channel pushes toward grass, low red toward rock)."""
    m = bpy.data.materials.new("v3r2w_terrain")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1800, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1500, 0)
    bsdf.inputs["Roughness"].default_value = 0.85
    links.new(bsdf.outputs[0], out.inputs[0])

    # Vertex color attribute (per-vertex biome bias)
    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1600, 600)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1400, 600)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1600, 0)
    map_node = nodes.new("ShaderNodeMapping"); map_node.location = (-1400, 0)
    map_node.inputs["Scale"].default_value = (0.25, 0.25, 0.25)
    links.new(tc.outputs["Generated"], map_node.inputs["Vector"])

    # GRASS LAYER
    grass_n = nodes.new("ShaderNodeTexNoise"); grass_n.location = (-1100, 600)
    grass_n.inputs["Scale"].default_value = 30.0
    grass_n.inputs["Detail"].default_value = 6.0
    links.new(map_node.outputs["Vector"], grass_n.inputs["Vector"])
    grass_ramp = nodes.new("ShaderNodeValToRGB"); grass_ramp.location = (-800, 600)
    grass_ramp.color_ramp.elements[0].position = 0.30
    grass_ramp.color_ramp.elements[0].color = (0.10, 0.22, 0.06, 1)
    grass_ramp.color_ramp.elements[1].position = 0.75
    grass_ramp.color_ramp.elements[1].color = (0.22, 0.40, 0.12, 1)
    links.new(grass_n.outputs["Fac"], grass_ramp.inputs["Fac"])

    # ROCK LAYER
    rock_n = nodes.new("ShaderNodeTexNoise"); rock_n.location = (-1100, 200)
    rock_n.inputs["Scale"].default_value = 10.0
    rock_n.inputs["Detail"].default_value = 8.0
    links.new(map_node.outputs["Vector"], rock_n.inputs["Vector"])
    rock_ramp = nodes.new("ShaderNodeValToRGB"); rock_ramp.location = (-800, 200)
    rock_ramp.color_ramp.elements[0].position = 0.10
    rock_ramp.color_ramp.elements[0].color = (0.18, 0.16, 0.13, 1)
    rock_ramp.color_ramp.elements[1].position = 0.70
    rock_ramp.color_ramp.elements[1].color = (0.45, 0.42, 0.38, 1)
    links.new(rock_n.outputs["Fac"], rock_ramp.inputs["Fac"])

    # DIRT LAYER
    dirt_v = nodes.new("ShaderNodeTexVoronoi"); dirt_v.location = (-1100, -100)
    dirt_v.feature = 'F1'
    dirt_v.inputs["Scale"].default_value = 6.0
    links.new(map_node.outputs["Vector"], dirt_v.inputs["Vector"])
    dirt_ramp = nodes.new("ShaderNodeValToRGB"); dirt_ramp.location = (-800, -100)
    dirt_ramp.color_ramp.elements[0].position = 0.30
    dirt_ramp.color_ramp.elements[0].color = (0.20, 0.13, 0.06, 1)
    dirt_ramp.color_ramp.elements[1].position = 0.70
    dirt_ramp.color_ramp.elements[1].color = (0.35, 0.22, 0.10, 1)
    links.new(dirt_v.outputs["Distance"], dirt_ramp.inputs["Fac"])

    # SLOPE MASK from geometry normal Z
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-1100, -400)
    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-900, -400)
    links.new(geo.outputs["Normal"], sep.inputs["Vector"])

    # Bias slope by vertex color (add red channel × 0.10 to slope)
    vc_bias = nodes.new("ShaderNodeMath"); vc_bias.location = (-700, -400)
    vc_bias.operation = 'MULTIPLY_ADD'
    vc_bias.inputs[1].default_value = 0.10
    links.new(sep_vc.outputs["Red"], vc_bias.inputs[0])
    links.new(sep.outputs["Z"], vc_bias.inputs[2])

    slope_ramp = nodes.new("ShaderNodeValToRGB"); slope_ramp.location = (-500, -400)
    slope_ramp.color_ramp.elements[0].position = 0.55
    slope_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)  # rock
    slope_ramp.color_ramp.elements[1].position = 0.85
    slope_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)  # grass
    links.new(vc_bias.outputs[0], slope_ramp.inputs["Fac"])

    # MIX rock -> grass via slope
    mix1 = nodes.new("ShaderNodeMix"); mix1.data_type = 'RGBA'; mix1.location = (-200, 400)
    links.new(slope_ramp.outputs["Color"], mix1.inputs["Factor"])
    links.new(rock_ramp.outputs["Color"], mix1.inputs[6])
    links.new(grass_ramp.outputs["Color"], mix1.inputs[7])

    # Add dirt patches at mid-slope (0.55-0.85 band)
    dirt_mask = nodes.new("ShaderNodeValToRGB"); dirt_mask.location = (-500, -700)
    dirt_mask.color_ramp.interpolation = 'B_SPLINE'
    dirt_mask.color_ramp.elements[0].position = 0.55
    dirt_mask.color_ramp.elements[0].color = (0,0,0,1)
    dirt_mask.color_ramp.elements[1].position = 0.72
    dirt_mask.color_ramp.elements[1].color = (1,1,1,1)
    links.new(sep.outputs["Z"], dirt_mask.inputs["Fac"])
    dirt_mask2 = nodes.new("ShaderNodeValToRGB"); dirt_mask2.location = (-500, -900)
    dirt_mask2.color_ramp.interpolation = 'B_SPLINE'
    dirt_mask2.color_ramp.elements[0].position = 0.78
    dirt_mask2.color_ramp.elements[0].color = (1,1,1,1)
    dirt_mask2.color_ramp.elements[1].position = 0.92
    dirt_mask2.color_ramp.elements[1].color = (0,0,0,1)
    links.new(sep.outputs["Z"], dirt_mask2.inputs["Fac"])
    dirt_combine = nodes.new("ShaderNodeMath"); dirt_combine.location = (-250, -800)
    dirt_combine.operation = 'MULTIPLY'
    links.new(dirt_mask.outputs["Color"], dirt_combine.inputs[0])
    links.new(dirt_mask2.outputs["Color"], dirt_combine.inputs[1])
    mix2 = nodes.new("ShaderNodeMix"); mix2.data_type = 'RGBA'; mix2.location = (200, 0)
    links.new(dirt_combine.outputs[0], mix2.inputs["Factor"])
    links.new(mix1.outputs[2], mix2.inputs[6])
    links.new(dirt_ramp.outputs["Color"], mix2.inputs[7])

    # Curvature dirt — pointiness
    geo2 = nodes.new("ShaderNodeNewGeometry"); geo2.location = (-200, -1100)
    ao_ramp = nodes.new("ShaderNodeValToRGB"); ao_ramp.location = (50, -1100)
    ao_ramp.color_ramp.elements[0].position = 0.30
    ao_ramp.color_ramp.elements[0].color = (0.05, 0.04, 0.02, 1)
    ao_ramp.color_ramp.elements[1].position = 0.70
    ao_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo2.outputs["Pointiness"], ao_ramp.inputs["Fac"])
    mix3 = nodes.new("ShaderNodeMix"); mix3.data_type = 'RGBA'; mix3.location = (450, -200)
    mix3.inputs["Factor"].default_value = 0.30
    links.new(mix2.outputs[2], mix3.inputs[6])
    links.new(ao_ramp.outputs["Color"], mix3.inputs[7])

    # Bump from rock noise
    bump = nodes.new("ShaderNodeBump"); bump.location = (1100, -400)
    bump.inputs["Strength"].default_value = 0.4
    links.new(rock_n.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

    links.new(mix3.outputs[2], bsdf.inputs["Base Color"])
    return m

# ============================================================
# REFINED RIVER SHADER w/ ripples
# ============================================================
def make_river_shader():
    m = bpy.data.materials.new("v3r2w_river")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (0.05, 0.18, 0.28, 1)
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["Transmission Weight"].default_value = 0.7
    bsdf.inputs["IOR"].default_value = 1.33
    bsdf.inputs["Emission Color"].default_value = (0.10, 0.30, 0.45, 1)
    bsdf.inputs["Emission Strength"].default_value = 0.4
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1000, 0)
    map1 = nodes.new("ShaderNodeMapping"); map1.location = (-800, 100)
    map1.inputs["Scale"].default_value = (8, 2, 1)
    links.new(tc.outputs["Object"], map1.inputs["Vector"])
    n1 = nodes.new("ShaderNodeTexNoise"); n1.location = (-550, 100)
    n1.inputs["Scale"].default_value = 5.0
    n1.inputs["Detail"].default_value = 8.0
    n1.inputs["Roughness"].default_value = 0.7
    links.new(map1.outputs["Vector"], n1.inputs["Vector"])
    bump = nodes.new("ShaderNodeBump"); bump.location = (-300, 0)
    bump.inputs["Strength"].default_value = 0.30
    links.new(n1.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    return m

# ============================================================
# OTHER SHADERS
# ============================================================
def make_arch_shader(name, base_color, accent_color, roughness=0.85,
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
    v.feature = 'F1'
    v.inputs["Scale"].default_value = voronoi_scale
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

# ============================================================
# MATERIALS
# ============================================================
mats = {}
mats["terrain"] = make_slope_terrain()
mats["river"]   = make_river_shader()
mats["bark_oak"]   = make_arch_shader("v3r2w_bark_oak", (0.18, 0.11, 0.06), (0.28, 0.18, 0.10),
                                       roughness=0.95, voronoi_scale=12.0, bump_strength=0.45)
mats["bark_pine"]  = make_arch_shader("v3r2w_bark_pine", (0.22, 0.13, 0.07), (0.32, 0.20, 0.12),
                                       roughness=0.95, voronoi_scale=18.0, bump_strength=0.40)
mats["canopy_summer"] = make_arch_shader("v3r2w_canopy_s", (0.15, 0.32, 0.10), (0.25, 0.45, 0.15),
                                           roughness=0.85, voronoi_scale=30.0, bump_strength=0.30)
mats["canopy_pine"]   = make_arch_shader("v3r2w_canopy_p", (0.10, 0.22, 0.10), (0.18, 0.32, 0.15),
                                           roughness=0.85, voronoi_scale=35.0, bump_strength=0.35)
mats["ruin_stone"] = make_arch_shader("v3r2w_ruin", (0.50, 0.46, 0.40), (0.62, 0.58, 0.50),
                                        roughness=0.92, voronoi_scale=8.0, bump_strength=0.50)
mats["path_stone"] = make_arch_shader("v3r2w_path", (0.55, 0.50, 0.42), (0.68, 0.62, 0.52),
                                        roughness=0.85, voronoi_scale=10.0, bump_strength=0.30)
mats["mountain"]   = make_arch_shader("v3r2w_mountain", (0.32, 0.30, 0.32), (0.42, 0.40, 0.42),
                                        roughness=0.95, voronoi_scale=10.0, bump_strength=0.50)
mats["flower_red"]    = make_pbr_simple("v3r2w_flw_r", (0.85, 0.20, 0.20), 0.65,
                                         em=(0.95, 0.30, 0.25), em_str=0.5)
mats["flower_yellow"] = make_pbr_simple("v3r2w_flw_y", (0.95, 0.85, 0.20), 0.65,
                                         em=(1.0, 0.92, 0.30), em_str=0.5)
mats["flower_blue"]   = make_pbr_simple("v3r2w_flw_b", (0.30, 0.45, 0.85), 0.65,
                                         em=(0.40, 0.55, 1.0), em_str=0.5)
mats["stem"] = make_pbr_simple("v3r2w_stem", (0.18, 0.32, 0.10), 0.85)

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

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=18, rot=(0,0,0), multires=1):
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

def r_ico(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, sub=2, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_ico_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        subdivisions=sub, radius=r, location=loc)

# ============================================================
# TERRAIN — 40x40 displaced plane with vertex color biome bias
# ============================================================
parent = bpy.data.objects.new("v3_r2_wilderness", None); scene.collection.objects.link(parent)

TERRAIN_SIZE = 40
TERRAIN_SUB  = 100  # safe size, no volumetrics

bpy.ops.mesh.primitive_plane_add(size=TERRAIN_SIZE, location=(0, 0, 0))
terrain = bpy.context.object
terrain.name = "wild_terrain"
bm = bmesh.new()
bm.from_mesh(terrain.data)
bmesh.ops.subdivide_edges(bm, edges=bm.edges, cuts=TERRAIN_SUB, use_grid_fill=True)
bm.to_mesh(terrain.data)
bm.free()
terrain.data.update()

# Heightmap displacement
for v in terrain.data.vertices:
    x, y = v.co.x, v.co.y
    h  = bnoise.noise(Vector((x*0.06, y*0.06, 0)))*3.0
    h += bnoise.noise(Vector((x*0.15, y*0.15, 5)))*1.0
    h += bnoise.noise(Vector((x*0.30, y*0.30, 10)))*0.4
    valley = max(0.0, 1.0 - (abs(x) / 5.0) ** 2)
    h -= valley * 4.0
    edge = (abs(x) + abs(y)) / TERRAIN_SIZE
    h += edge * 5.0
    v.co.z = h

# Paint terrain vertex colors (biome bias hash)
ca = terrain.data.color_attributes.new(name="Color", type='FLOAT_COLOR', domain='POINT')
for i, v in enumerate(terrain.data.vertices):
    # Bias toward grass on flat valley areas, rock on highlands
    elevation_bias = max(0.0, min(1.0, (v.co.z + 2.0) / 6.0))
    random.seed(hash(("terrain", i)) & 0xFFFFFF)
    noise_var = (random.random() - 0.5) * 0.30
    r = max(0.0, min(1.0, (1.0 - elevation_bias) * 0.7 + noise_var))
    ca.data[i].color = (r, r * 0.8, r * 0.6, 1.0)

terrain.data.materials.append(mats["terrain"])
for poly in terrain.data.polygons: poly.use_smooth = True
terrain.parent = parent

# Helper to sample terrain height
def terrain_h(x, y):
    h  = bnoise.noise(Vector((x*0.06, y*0.06, 0)))*3.0
    h += bnoise.noise(Vector((x*0.15, y*0.15, 5)))*1.0
    h += bnoise.noise(Vector((x*0.30, y*0.30, 10)))*0.4
    valley = max(0.0, 1.0 - (abs(x) / 5.0) ** 2)
    h -= valley * 4.0
    edge = (abs(x) + abs(y)) / TERRAIN_SIZE
    h += edge * 5.0
    return h

# ============================================================
# RIVER PLANE
# ============================================================
bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 0, -3.0))
river = bpy.context.object; river.name = "wild_river"
river.scale = (4.0, TERRAIN_SIZE*0.5, 1)
river.data.materials.append(mats["river"])
uv_unwrap(river)
paint_vertex_color(river, base_red=0.5, variation=0.10)
bv = river.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in river.data.polygons: poly.use_smooth = True
river.parent = parent

# ============================================================
# 12 REFINED TREES (smaller forest, higher quality each)
# ============================================================
def refined_tree(name, x, y, kind):
    base_z = terrain_h(x, y)
    if kind == "oak":
        bark = mats["bark_oak"]; canopy = mats["canopy_summer"]
        trunk_h = random.uniform(2.4, 3.4)
        trunk_r = random.uniform(0.18, 0.26)
        cap_r = random.uniform(1.1, 1.6)
    else:
        bark = mats["bark_pine"]; canopy = mats["canopy_pine"]
        trunk_h = random.uniform(3.0, 4.4)
        trunk_r = random.uniform(0.16, 0.24)
        cap_r = random.uniform(0.9, 1.3)
    # Trunk
    r_cyl(f"{name}_trunk", (x, y, base_z + trunk_h/2), trunk_r, trunk_h, bark, parent,
           vc_red=0.55, vc_var=0.30, verts=14)
    if kind == "oak":
        # Main canopy + 4 secondary clumps (refined w/ more poly)
        r_sphere(f"{name}_cap_main", (x, y, base_z + trunk_h + cap_r*0.3), cap_r, canopy, parent,
                  vc_red=0.55, vc_var=0.30, segs=24)
        for j in range(4):
            ang = j * math.pi/2
            cx = x + math.cos(ang) * cap_r * 0.6
            cy = y + math.sin(ang) * cap_r * 0.6
            cz = base_z + trunk_h + cap_r * 0.5
            r_sphere(f"{name}_cl_{j}", (cx, cy, cz), cap_r * 0.55, canopy, parent,
                      vc_red=0.55, vc_var=0.30, segs=18)
    else:  # pine
        for j in range(4):
            r1 = cap_r * (1.0 - j*0.22)
            cz = base_z + trunk_h + j * cap_r * 0.7
            r_cone(f"{name}_c_{j}", (x, y, cz), r1, 0, cap_r * 1.4, canopy, parent,
                    vc_red=0.55, vc_var=0.30, verts=18)

# 12 trees scattered in 2 quadrants
TREE_POSITIONS = [
    (8, 8, "oak"), (12, 6, "oak"), (10, 13, "pine"), (15, 10, "oak"),
    (6, 14, "pine"), (14, 14, "oak"),
    (-8, -8, "oak"), (-12, -6, "pine"), (-10, -13, "oak"),
    (-15, -10, "pine"), (-6, -14, "oak"), (-14, -14, "pine"),
]
for i, (tx, ty, kind) in enumerate(TREE_POSITIONS):
    refined_tree(f"tree_{i}", tx, ty, kind)

# ============================================================
# RUINS — broken obelisk + arch + 3 fallen blocks
# ============================================================
ox, oy = -10, 12
oz = terrain_h(ox, oy)
r_box("ruin_ped", (ox, oy, oz + 0.6), (1.6, 1.6, 1.2), mats["ruin_stone"], parent,
       vc_red=0.55, vc_var=0.30)
r_box("ruin_obe", (ox, oy, oz + 3.0), (0.6, 0.6, 4.0), mats["ruin_stone"], parent,
       vc_red=0.55, vc_var=0.30)
r_cone("ruin_top", (ox, oy, oz + 5.4), 0.42, 0, 0.7, mats["ruin_stone"], parent,
        vc_red=0.55, vc_var=0.30, verts=4, rot=(0, 0, math.pi/4))

# Broken arch nearby
ax, ay = -7, 9
az = terrain_h(ax, ay)
for i, dx in enumerate([-1.6, 1.6]):
    r_cyl(f"arch_p_{i}", (ax + dx, ay, az + 1.8), 0.40, 3.6, mats["ruin_stone"], parent,
           vc_red=0.55, vc_var=0.30, verts=14)
r_box("arch_beam", (ax, ay, az + 3.8), (3.8, 0.5, 0.4), mats["ruin_stone"], parent,
       vc_red=0.55, vc_var=0.30, rot=(0, 0.08, 0))

# 3 fallen blocks scattered
for i, (fx, fy) in enumerate([(-9, 7), (-5, 11), (-12, 8)]):
    fz = terrain_h(fx, fy)
    r_box(f"fallen_{i}", (fx, fy, fz + 0.4), (1.0, 0.6, 0.5), mats["ruin_stone"], parent,
           vc_red=0.55, vc_var=0.30, rot=(random.uniform(-0.2, 0.2), random.uniform(-0.2, 0.2), random.uniform(0, math.pi*2)))

# ============================================================
# 8 PATH STONES from foreground to riverbank
# ============================================================
for i in range(8):
    px = -1.0 + i * 0.40
    py = -8.0 + i * 1.4
    pz = terrain_h(px, py) + 0.20
    r_box(f"path_{i}", (px, py, pz), (0.7, 0.5, 0.18), mats["path_stone"], parent,
           vc_red=0.55, vc_var=0.30, rot=(0, 0, i * 0.4))

# ============================================================
# 24 WILDFLOWERS along riverbank
# ============================================================
for i in range(24):
    side = -1 if i % 2 == 0 else 1
    fx = side * random.uniform(2.0, 3.2)
    fy = random.uniform(-15, 15)
    fz = terrain_h(fx, fy) + 0.10
    color = [mats["flower_red"], mats["flower_yellow"], mats["flower_blue"]][i % 3]
    r_ico(f"flw_{i}", (fx, fy, fz + 0.10), 0.08, color, parent,
           vc_red=0.55, vc_var=0.30, sub=2)
    r_cyl(f"flw_st_{i}", (fx, fy, fz), 0.012, 0.20, mats["stem"], parent,
           vc_red=0.55, vc_var=0.30, verts=6)

# ============================================================
# BACKGROUND MOUNTAIN SILHOUETTE — 5 distance peaks
# ============================================================
mtn_parent = bpy.data.objects.new("wild_mountains", None); scene.collection.objects.link(mtn_parent)
mtn_parent.parent = parent
for i, (mx, my, mz, sx, sz) in enumerate([
    (-25, 25, 0, 8, 12),
    (-10, 28, 0, 6, 10),
    (5, 30, 0, 7, 14),
    (18, 27, 0, 6, 11),
    (28, 25, 0, 8, 13),
]):
    r_cone(f"mtn_{i}", (mx, my, mz + sz/2), sx, sx*0.10, sz, mats["mountain"], mtn_parent,
            vc_red=0.55, vc_var=0.30, verts=12)

# ============================================================
# LIGHTING — Hosek-Wilkie sun + cool fill (NO volumetrics)
# ============================================================
bpy.ops.object.light_add(type='SUN', location=(20, -25, 30))
sun = bpy.context.object
sun.data.energy = 5.0
sun.data.color = (1.0, 0.92, 0.78)
sun.data.angle = math.radians(2)
direction = Vector((0, 0, 0)) - sun.location
sun.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-15, 15, 12))
fill = bpy.context.object
fill.data.energy = 1500; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 14

# ============================================================
# CAMERAS — 4 hero shots
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

cam_overview = add_cam("cam_overview", Vector((25, -25, 18)), Vector((0, 0, 1)), lens=35, dof_dist=18)
cam_valley   = add_cam("cam_valley",   Vector((6, -18, 4)),   Vector((0, 5, -2)), lens=50, dof_dist=14)
cam_forest   = add_cam("cam_forest",   Vector((22, 4, 8)),    Vector((10, 12, 1)), lens=50, dof_dist=10)
cam_ruins    = add_cam("cam_ruins",    Vector((-3, 0, 6)),    Vector((-9, 11, 2)), lens=70, dof_dist=10)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("overview", cam_overview),
    ("valley",   cam_valley),
    ("forest",   cam_forest),
    ("ruins",    cam_ruins),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_wilderness_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.data.objects:
    if o.type == 'MESH':
        o.select_set(True)
out_path = os.path.join(EXPORT_DIR, "wilderness_r2_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-09 Wilderness Refinement complete ===")
