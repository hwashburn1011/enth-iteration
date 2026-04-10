"""
Expansion V3 — ROUND 2 — Epic R2-06 — Town Building Kit Refinement
==================================================================
Round 2 of V3-06 building kit. 4 hero landmark buildings with full
Round 2 stack (Smart UV unwrap + vertex color paint + multires +
5-seg bevel + vertex-color-aware shaders).

Buildings:
  SAGE'S HUT      — small mystical round home, thatched roof, chimney,
                     lantern, window, vine overgrowth
  FORGE'S SMITHY  — utility stone workshop, tiled roof, smoking chimney,
                     outdoor anvil, water barrel, hanging tools
  CACHE'S TAVERN  — 2-story timber inn, sloped roof, hanging sign,
                     balcony, lit windows, door
  LAB'S TOWER     — tall round stone tower, conical roof, multiple
                     windows, antenna, weather vane, lab gear

Each building ~30-50 mesh parts. Full Round 2 stack on every part.

Outputs: 5 hero renders @ 1920x1080 + 4 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(106)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/v3_r2_buildings.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/exports"
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

# Hosek-Wilkie sky for natural daylight on buildings
scene.world = bpy.data.worlds.new("v3r2b_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wsky = wnt.nodes.new("ShaderNodeTexSky")
wsky.sky_type = 'HOSEK_WILKIE'
wsky.sun_direction = (0.5, -0.5, 0.40)  # afternoon
wsky.turbidity = 3.0
wsky.ground_albedo = 0.4
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Strength"].default_value = 1.0
wnt.links.new(wsky.outputs[0], wbg.inputs[0])
wnt.links.new(wbg.outputs[0], wout.inputs[0])

# ============================================================
# REFINED VC-AWARE BUILDING SHADER (architectural)
# ============================================================
def make_arch_shader(name, base_color, accent_color, roughness=0.85,
                     metallic=0.0, voronoi_scale=10.0, bump_strength=0.30):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    links.new(bsdf.outputs[0], out.inputs[0])

    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    # Coarse noise for surface variation
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

    # Voronoi pattern (brick/plank/tile)
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

    # Curvature dirt
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

def make_emit(name, color, strength):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (*color, 1)
    bs.inputs["Emission Strength"].default_value = strength
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
mats["stone_warm"]   = make_arch_shader("v3r2b_stone_w", (0.62, 0.55, 0.42), (0.75, 0.65, 0.50),
                                         roughness=0.92, voronoi_scale=8.0, bump_strength=0.45)
mats["stone_grey"]   = make_arch_shader("v3r2b_stone_g", (0.45, 0.42, 0.40), (0.55, 0.52, 0.50),
                                         roughness=0.92, voronoi_scale=8.0, bump_strength=0.45)
mats["wood_dark"]    = make_arch_shader("v3r2b_wood_d", (0.18, 0.10, 0.05), (0.28, 0.16, 0.08),
                                         roughness=0.85, voronoi_scale=12.0, bump_strength=0.25)
mats["wood_med"]     = make_arch_shader("v3r2b_wood_m", (0.42, 0.26, 0.13), (0.55, 0.35, 0.18),
                                         roughness=0.85, voronoi_scale=12.0, bump_strength=0.25)
mats["wood_light"]   = make_arch_shader("v3r2b_wood_l", (0.62, 0.42, 0.22), (0.78, 0.55, 0.30),
                                         roughness=0.85, voronoi_scale=14.0, bump_strength=0.20)
mats["thatch"]       = make_arch_shader("v3r2b_thatch", (0.78, 0.62, 0.22), (0.92, 0.75, 0.32),
                                         roughness=0.95, voronoi_scale=40.0, bump_strength=0.55)
mats["roof_red"]     = make_arch_shader("v3r2b_roof_r", (0.45, 0.15, 0.10), (0.62, 0.22, 0.15),
                                         roughness=0.85, voronoi_scale=22.0, bump_strength=0.30)
mats["roof_blue"]    = make_arch_shader("v3r2b_roof_b", (0.18, 0.32, 0.55), (0.28, 0.45, 0.72),
                                         roughness=0.85, voronoi_scale=22.0, bump_strength=0.30)
mats["window_warm"]  = make_pbr_simple("v3r2b_window", (1.0, 0.78, 0.40), 0.10,
                                        em=(1.0, 0.85, 0.45), em_str=10.0)
mats["window_cool"]  = make_pbr_simple("v3r2b_window_c", (0.40, 0.85, 1.0), 0.10,
                                        em=(0.55, 0.95, 1.0), em_str=10.0)
mats["iron"]         = make_arch_shader("v3r2b_iron", (0.18, 0.18, 0.20), (0.28, 0.28, 0.32),
                                         roughness=0.45, metallic=0.85,
                                         voronoi_scale=22.0, bump_strength=0.10)
mats["brass"]        = make_arch_shader("v3r2b_brass", (0.85, 0.65, 0.20), (0.95, 0.78, 0.35),
                                         roughness=0.20, metallic=0.92,
                                         voronoi_scale=18.0, bump_strength=0.10)
mats["lantern_warm"] = make_emit("v3r2b_lantern", (1.0, 0.80, 0.40), 12.0)
mats["fire"]         = make_emit("v3r2b_fire", (1.0, 0.55, 0.10), 14.0)
mats["smoke_grey"]   = make_pbr_simple("v3r2b_smoke", (0.45, 0.45, 0.48), 0.85)
mats["water"]        = make_pbr_simple("v3r2b_water", (0.10, 0.30, 0.50), 0.05,
                                        em=(0.20, 0.45, 0.65), em_str=0.6)
mats["vine"]         = make_arch_shader("v3r2b_vine", (0.15, 0.32, 0.10), (0.25, 0.45, 0.15),
                                         roughness=0.85, voronoi_scale=30.0, bump_strength=0.30)
mats["flag_blue"]    = make_pbr_simple("v3r2b_flag_b", (0.20, 0.40, 0.85), 0.85,
                                        em=(0.30, 0.55, 1.0), em_str=0.4)
mats["sign_wood"]    = make_arch_shader("v3r2b_sign", (0.35, 0.20, 0.10), (0.50, 0.30, 0.15),
                                         roughness=0.85, voronoi_scale=14.0, bump_strength=0.20)
mats["ground"]       = make_arch_shader("v3r2b_ground", (0.32, 0.28, 0.20), (0.42, 0.36, 0.25),
                                         roughness=0.92, voronoi_scale=20.0, bump_strength=0.30)

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

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=18, rot=(0,0,0), multires=1):
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
# BUILDING 1 — SAGE'S HUT
# ============================================================
def build_sage_hut(origin):
    p = bpy.data.objects.new("hut_sage", None); scene.collection.objects.link(p); p.location = origin
    # Round walls (cylinder)
    r_cyl("walls", (0, 0, 1.20), 1.40, 2.40, mats["stone_warm"], p,
           vc_red=0.55, vc_var=0.30, verts=24, multires=2)
    # Stone foundation ring
    r_cyl("foundation", (0, 0, 0.20), 1.55, 0.30, mats["stone_grey"], p,
           vc_red=0.50, vc_var=0.25, verts=24)
    # Thatched conical roof
    r_cone("roof", (0, 0, 3.20), 1.70, 0.10, 1.40, mats["thatch"], p,
            vc_red=0.65, vc_var=0.30, verts=20, multires=1)
    # Roof rim trim
    r_torus("roof_trim", (0, 0, 2.50), 1.55, 0.06, mats["wood_dark"], p, ms=32, mn=10)
    # Chimney (off-center stone block)
    r_box("chimney", (0.5, 0, 3.40), (0.30, 0.30, 0.80), mats["stone_grey"], p,
           vc_red=0.50, vc_var=0.25)
    r_box("chimney_top", (0.5, 0, 3.85), (0.36, 0.36, 0.06), mats["stone_grey"], p)
    # Smoke wisp (3 spheres rising from chimney)
    for i in range(3):
        r_sphere(f"smoke_{i}", (0.5 + i*0.05, 0, 4.0 + i*0.18), 0.10 + i*0.02, mats["smoke_grey"], p, segs=14)
    # Door (front face)
    r_box("door_frame", (0, 1.40, 1.20), (0.55, 0.10, 1.20), mats["wood_dark"], p)
    r_box("door", (0, 1.42, 1.20), (0.45, 0.05, 1.10), mats["wood_med"], p)
    # Door handle
    r_sphere("door_handle", (0.15, 1.46, 1.20), 0.04, mats["brass"], p, segs=10)
    # 2 round windows on opposite sides
    r_cyl("window_l", (-1.30, 0.40, 1.50), 0.20, 0.05, mats["window_warm"], p, verts=20, rot=(0, math.pi/2, 0))
    r_cyl("window_r", (1.30, -0.40, 1.50), 0.20, 0.05, mats["window_warm"], p, verts=20, rot=(0, math.pi/2, 0))
    # Window frames
    r_torus("window_l_frame", (-1.30, 0.40, 1.50), 0.22, 0.02, mats["wood_dark"], p, ms=24, mn=8, rot=(0, math.pi/2, 0))
    r_torus("window_r_frame", (1.30, -0.40, 1.50), 0.22, 0.02, mats["wood_dark"], p, ms=24, mn=8, rot=(0, math.pi/2, 0))
    # Hanging lantern by door
    r_cyl("lantern_chain", (0.40, 1.50, 2.40), 0.012, 0.40, mats["iron"], p, verts=8)
    r_box("lantern_top", (0.40, 1.50, 2.18), (0.10, 0.10, 0.04), mats["iron"], p)
    r_box("lantern_body", (0.40, 1.50, 2.05), (0.10, 0.10, 0.18), mats["window_warm"], p)
    r_box("lantern_bot", (0.40, 1.50, 1.92), (0.10, 0.10, 0.04), mats["iron"], p)
    # Vine overgrowth (3 vine bundles climbing wall)
    for i, (vx, vz) in enumerate([(-0.50, 1.20),(0.30, 0.80),(-0.20, 1.80)]):
        r_sphere(f"vine_{i}", (vx, 1.40, vz), 0.18, mats["vine"], p, segs=14)
    return p

# ============================================================
# BUILDING 2 — FORGE'S SMITHY
# ============================================================
def build_forge_smithy(origin):
    p = bpy.data.objects.new("hut_forge", None); scene.collection.objects.link(p); p.location = origin
    # Square stone walls
    r_box("walls", (0, 0, 1.40), (3.50, 3.00, 2.80), mats["stone_grey"], p,
           vc_red=0.55, vc_var=0.30, multires=2)
    # Stone foundation
    r_box("foundation", (0, 0, 0.20), (3.70, 3.20, 0.40), mats["stone_grey"], p,
           vc_red=0.50, vc_var=0.25)
    # Tiled gable roof (2 sloping planes)
    r_box("roof_l", (-1.0, 0, 3.30), (2.20, 3.40, 0.10), mats["roof_red"], p,
           vc_red=0.55, vc_var=0.30, rot=(0, -0.4, 0))
    r_box("roof_r", (1.0, 0, 3.30), (2.20, 3.40, 0.10), mats["roof_red"], p,
           vc_red=0.55, vc_var=0.30, rot=(0, 0.4, 0))
    # Roof apex beam
    r_box("apex", (0, 0, 3.85), (0.20, 3.40, 0.20), mats["wood_dark"], p)
    # Tall chimney
    r_box("chimney", (-1.30, 1.10, 3.80), (0.50, 0.50, 1.20), mats["stone_grey"], p,
           vc_red=0.50, vc_var=0.25)
    r_box("chimney_top", (-1.30, 1.10, 4.45), (0.60, 0.60, 0.10), mats["stone_grey"], p)
    # Heavy chimney smoke (5 spheres)
    for i in range(5):
        r_sphere(f"smoke_{i}", (-1.30 + i*0.10, 1.10, 4.60 + i*0.20),
                  0.18 + i*0.04, mats["smoke_grey"], p, segs=14)
    # Big arched doorway (front face — south)
    r_box("door_frame", (0, 1.55, 1.20), (1.40, 0.10, 2.20), mats["wood_dark"], p)
    r_box("door_dark", (0, 1.58, 1.20), (1.20, 0.05, 2.00), mats["fire"], p)
    # 2 small high windows
    r_box("window_l", (-1.20, 1.55, 2.40), (0.30, 0.05, 0.30), mats["window_warm"], p)
    r_box("window_r", (1.20, 1.55, 2.40), (0.30, 0.05, 0.30), mats["window_warm"], p)
    # Outdoor anvil at the front
    r_box("anvil_b", (1.80, 2.40, 0.50), (0.40, 0.40, 0.60), mats["wood_dark"], p)
    r_box("anvil_top", (1.80, 2.40, 0.86), (0.50, 0.20, 0.10), mats["iron"], p)
    r_cone("anvil_horn", (2.05, 2.40, 0.86), 0.10, 0.0, 0.20, mats["iron"], p, verts=10, rot=(0, math.pi/2, 0))
    # Water barrel
    r_cyl("barrel", (-1.80, 2.40, 0.55), 0.32, 0.90, mats["wood_dark"], p, verts=18)
    r_torus("barrel_band1", (-1.80, 2.40, 0.30), 0.33, 0.025, mats["iron"], p, ms=20, mn=8)
    r_torus("barrel_band2", (-1.80, 2.40, 0.80), 0.33, 0.025, mats["iron"], p, ms=20, mn=8)
    r_cyl("barrel_water", (-1.80, 2.40, 0.99), 0.30, 0.04, mats["water"], p, verts=18)
    # Hammer hanging from wall
    r_cyl("hammer_h", (-2.20, 1.55, 1.80), 0.025, 0.40, mats["wood_med"], p, verts=10)
    r_box("hammer_head", (-2.20, 1.55, 2.05), (0.10, 0.06, 0.08), mats["iron"], p)
    return p

# ============================================================
# BUILDING 3 — CACHE'S TAVERN
# ============================================================
def build_cache_tavern(origin):
    p = bpy.data.objects.new("hut_cache", None); scene.collection.objects.link(p); p.location = origin
    # 1st floor stone base
    r_box("base", (0, 0, 1.20), (4.00, 3.50, 2.40), mats["stone_warm"], p,
           vc_red=0.55, vc_var=0.30, multires=2)
    # 2nd floor timber
    r_box("upper", (0, 0, 3.60), (4.20, 3.70, 2.20), mats["wood_med"], p,
           vc_red=0.55, vc_var=0.30, multires=2)
    # Foundation step
    r_box("foundation", (0, 0, 0.10), (4.30, 3.80, 0.20), mats["stone_grey"], p)
    # Sloped tile roof (gable)
    r_box("roof_l", (-1.30, 0, 5.20), (2.80, 4.00, 0.12), mats["roof_red"], p,
           vc_red=0.55, vc_var=0.30, rot=(0, -0.4, 0))
    r_box("roof_r", (1.30, 0, 5.20), (2.80, 4.00, 0.12), mats["roof_red"], p,
           vc_red=0.55, vc_var=0.30, rot=(0, 0.4, 0))
    r_box("apex", (0, 0, 5.85), (0.20, 4.00, 0.20), mats["wood_dark"], p)
    # Chimney
    r_box("chimney", (1.50, -1.20, 5.60), (0.40, 0.40, 1.20), mats["stone_grey"], p,
           vc_red=0.50, vc_var=0.25)
    # Front door (south face)
    r_box("door_frame", (0, 1.80, 1.20), (1.20, 0.10, 1.80), mats["wood_dark"], p)
    r_box("door", (0, 1.83, 1.20), (1.00, 0.05, 1.60), mats["wood_med"], p)
    r_sphere("door_handle", (0.30, 1.86, 1.20), 0.04, mats["brass"], p, segs=10)
    # 4 lit windows on 1st floor (2 per long side)
    for i, (wx, wy) in enumerate([(-1.50, 1.80), (1.50, 1.80), (-1.50, -1.80), (1.50, -1.80)]):
        r_box(f"win_1_{i}", (wx, wy, 1.50), (0.50, 0.05, 0.60), mats["window_warm"], p)
        r_box(f"win_1_frame_{i}", (wx, wy + 0.04 if wy > 0 else wy - 0.04, 1.50),
               (0.55, 0.04, 0.65), mats["wood_dark"], p)
    # 4 lit windows on 2nd floor
    for i, (wx, wy) in enumerate([(-1.50, 1.85), (1.50, 1.85), (-1.50, -1.85), (1.50, -1.85)]):
        r_box(f"win_2_{i}", (wx, wy, 3.80), (0.40, 0.05, 0.50), mats["window_warm"], p)
    # 2nd floor balcony (front)
    r_box("balcony", (0, 2.20, 3.20), (3.00, 0.30, 0.10), mats["wood_dark"], p)
    r_box("balcony_rail", (0, 2.40, 3.50), (3.00, 0.04, 0.50), mats["wood_dark"], p)
    for i, bx in enumerate([-1.20, -0.40, 0.40, 1.20]):
        r_cyl(f"balcony_post_{i}", (bx, 2.40, 3.45), 0.025, 0.50, mats["wood_dark"], p, verts=8)
    # Hanging tavern sign on bracket
    r_cyl("sign_arm", (-2.40, 1.80, 3.50), 0.04, 0.50, mats["iron"], p, verts=8, rot=(0, math.pi/2, 0))
    r_cyl("sign_chain1", (-2.55, 1.80, 3.40), 0.012, 0.30, mats["iron"], p, verts=6)
    r_cyl("sign_chain2", (-2.20, 1.80, 3.40), 0.012, 0.30, mats["iron"], p, verts=6)
    r_box("sign", (-2.40, 1.80, 3.10), (0.50, 0.04, 0.40), mats["sign_wood"], p)
    r_box("sign_emblem", (-2.40, 1.83, 3.10), (0.20, 0.005, 0.20), mats["brass"], p)
    return p

# ============================================================
# BUILDING 4 — LAB'S TOWER
# ============================================================
def build_lab_tower(origin):
    p = bpy.data.objects.new("hut_lab", None); scene.collection.objects.link(p); p.location = origin
    # Round stone foundation
    r_cyl("foundation", (0, 0, 0.30), 1.80, 0.60, mats["stone_grey"], p,
           vc_red=0.50, vc_var=0.25, verts=32)
    # Tall round tower (3-stage taper)
    r_cyl("tower_lower", (0, 0, 1.80), 1.60, 2.40, mats["stone_grey"], p,
           vc_red=0.55, vc_var=0.30, verts=32, multires=2)
    r_cyl("tower_mid",   (0, 0, 4.00), 1.40, 2.00, mats["stone_grey"], p,
           vc_red=0.55, vc_var=0.30, verts=28, multires=2)
    r_cyl("tower_upper", (0, 0, 5.80), 1.20, 1.60, mats["stone_grey"], p,
           vc_red=0.55, vc_var=0.30, verts=24, multires=2)
    # Conical roof
    r_cone("roof", (0, 0, 7.30), 1.40, 0.10, 1.80, mats["roof_blue"], p,
            vc_red=0.55, vc_var=0.30, verts=24)
    # Roof rim trim
    r_torus("roof_trim", (0, 0, 6.60), 1.30, 0.06, mats["wood_dark"], p, ms=32, mn=10)
    # 4 narrow windows (top floor)
    for i in range(4):
        ang = i * math.pi/2
        wx = math.cos(ang) * 1.25
        wy = math.sin(ang) * 1.25
        r_box(f"win_top_{i}", (wx, wy, 5.80), (0.20 if abs(math.cos(ang)) > 0.5 else 0.05,
                                                 0.20 if abs(math.sin(ang)) > 0.5 else 0.05,
                                                 0.40), mats["window_cool"], p)
    # 4 wider windows (mid floor)
    for i in range(4):
        ang = i * math.pi/2 + math.pi/4
        wx = math.cos(ang) * 1.45
        wy = math.sin(ang) * 1.45
        r_box(f"win_mid_{i}", (wx, wy, 4.00), (0.30 if abs(math.cos(ang)) > 0.5 else 0.05,
                                                 0.30 if abs(math.sin(ang)) > 0.5 else 0.05,
                                                 0.50), mats["window_cool"], p)
    # Front door
    r_box("door_frame", (0, 1.65, 1.30), (0.90, 0.10, 1.80), mats["wood_dark"], p)
    r_box("door", (0, 1.68, 1.30), (0.80, 0.05, 1.65), mats["wood_med"], p)
    # Antenna on top of roof
    r_cyl("antenna", (0, 0, 8.50), 0.04, 1.20, mats["iron"], p, verts=10)
    r_sphere("ant_top", (0, 0, 9.20), 0.10, mats["window_cool"], p, segs=14)
    # Weather vane (cross-shape on roof apex)
    r_cyl("vane_post", (0.6, 0.6, 8.20), 0.025, 0.40, mats["iron"], p, verts=8)
    r_cone("vane_n", (0.6, 0.65, 8.45), 0.05, 0.0, 0.15, mats["iron"], p, verts=6, rot=(math.pi/2, 0, 0))
    r_cone("vane_s", (0.6, 0.55, 8.45), 0.05, 0.0, 0.15, mats["iron"], p, verts=6, rot=(-math.pi/2, 0, 0))
    # Hanging flag from antenna
    r_box("flag", (0.20, 0, 8.80), (0.40, 0.04, 0.30), mats["flag_blue"], p)
    return p

# ============================================================
# SCENE LAYOUT — 4 buildings on a long ground plane
# ============================================================
parent = bpy.data.objects.new("v3_r2_buildings", None); scene.collection.objects.link(parent)

# Wide ground
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.10))
fl = bpy.context.object; fl.name = "r2_ground"; fl.scale = (28, 12, 0.20)
fl.data.materials.append(mats["ground"])
bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in fl.data.polygons: poly.use_smooth = True

build_sage_hut(Vector((-9, 0, 0))).parent = parent
build_forge_smithy(Vector((-2, 0, 0))).parent = parent
build_cache_tavern(Vector((6, 0, 0))).parent = parent
build_lab_tower(Vector((13, 0, 0))).parent = parent

# ============================================================
# LIGHTING — Hosek-Wilkie sun + companion
# ============================================================
bpy.ops.object.light_add(type='SUN', location=(15, -20, 25))
sun = bpy.context.object
sun.data.energy = 5.0
sun.data.color = (1.0, 0.92, 0.78)
sun.data.angle = math.radians(2)
direction = Vector((0, 0, 0)) - sun.location
sun.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-15, 15, 12))
fill = bpy.context.object
fill.data.energy = 1500; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 12

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4, fstop=4.5):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_group = add_cam("cam_group", Vector((2, -22, 8)), Vector((2, 0, 2.5)), lens=35, dof_dist=22)
cam_sage   = add_cam("cam_sage",   Vector((-9, -7, 3.0)), Vector((-9, 0, 2.0)), lens=50, dof_dist=8)
cam_forge  = add_cam("cam_forge",  Vector((-2, -8, 4.0)), Vector((-2, 0, 2.5)), lens=50, dof_dist=8)
cam_cache  = add_cam("cam_cache",  Vector((6, -10, 5.0)), Vector((6, 0, 3.0)), lens=50, dof_dist=10)
cam_lab    = add_cam("cam_lab",    Vector((13, -10, 6.0)), Vector((13, 0, 4.5)), lens=50, dof_dist=12)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("group", cam_group),
    ("sage",  cam_sage),
    ("forge", cam_forge),
    ("cache", cam_cache),
    ("lab",   cam_lab),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_building_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-building GLB exports
for name in ["sage", "forge", "cache", "lab"]:
    bpy.ops.object.select_all(action='DESELECT')
    parent_obj = bpy.data.objects.get(f"hut_{name}")
    if parent_obj:
        parent_obj.select_set(True)
        for child in parent_obj.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"building_{name}_r2_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-06 Building Kit Refinement complete ===")
