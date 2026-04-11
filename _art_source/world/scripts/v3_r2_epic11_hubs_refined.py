"""
Expansion V3 — ROUND 2 — Epic R2-11 — Hub Interior Refinement
=============================================================
Round 2 of V3-11 Hub Interiors. 4 most-narrative interiors with full
Round 2 stack (Smart UV unwrap + vertex color paint + multires + 5-seg
bevel + vertex-color-aware shaders).

Interiors:
  SAGE'S STUDY  — bookshelf wall, writing desk w/ scroll, candle
  LIBRARY       — tall bookcase wall, reading table, globe, open book
  LOUNGE BAR    — lacquered bar, liquor wall, stools, hanging lamp
  COOKING       — hearth fire, cauldron, spice rack, cutting board

Each interior = corner room (floor + back wall + side wall) + ~30
hero props. Each prop gets the Round 2 stack.

Outputs: 5 hero shots @ 1920x1080 + 4 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(111)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_r2_hubs.blend"
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

scene.world = bpy.data.worlds.new("v3r2h_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.04, 0.06, 1)
bg.inputs["Strength"].default_value = 0.5

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
mats["wood_dark"]   = make_arch("v3r2h_wood_d", (0.18, 0.10, 0.05), (0.28, 0.16, 0.08),
                                 roughness=0.65, metallic=0.05, voronoi_scale=10.0, bump_strength=0.20)
mats["wood_med"]    = make_arch("v3r2h_wood_m", (0.42, 0.26, 0.13), (0.55, 0.35, 0.18),
                                 roughness=0.85, voronoi_scale=12.0, bump_strength=0.20)
mats["leather_red"] = make_arch("v3r2h_leather_r", (0.45, 0.10, 0.08), (0.58, 0.18, 0.12),
                                 roughness=0.55, voronoi_scale=80.0, bump_strength=0.20)
mats["leather_brown"] = make_arch("v3r2h_leather_b", (0.30, 0.16, 0.08), (0.42, 0.22, 0.12),
                                   roughness=0.55, voronoi_scale=80.0, bump_strength=0.20)
mats["fabric_blue"] = make_arch("v3r2h_fab_b", (0.15, 0.30, 0.55), (0.25, 0.42, 0.70),
                                 roughness=0.85, voronoi_scale=50.0, bump_strength=0.20)
mats["stone"]       = make_arch("v3r2h_stone", (0.50, 0.48, 0.45), (0.62, 0.58, 0.52),
                                 roughness=0.85, voronoi_scale=10.0, bump_strength=0.25)
mats["paper"]       = make_arch("v3r2h_paper", (0.92, 0.86, 0.72), (0.98, 0.92, 0.80),
                                 roughness=0.85, voronoi_scale=80.0, bump_strength=0.10)
mats["iron"]        = make_arch("v3r2h_iron", (0.18, 0.18, 0.20), (0.28, 0.28, 0.32),
                                 roughness=0.45, metallic=0.85, voronoi_scale=22.0, bump_strength=0.10)
mats["brass"]       = make_arch("v3r2h_brass", (0.85, 0.65, 0.20), (0.95, 0.78, 0.35),
                                 roughness=0.20, metallic=0.92, voronoi_scale=18.0, bump_strength=0.10,
                                 emission_color=(1.0, 0.85, 0.30), emission_strength=0.5)
mats["gold"]        = make_simple("v3r2h_gold", (0.95, 0.78, 0.20), 0.10, 1.0,
                                   em=(1.0, 0.85, 0.40), em_str=1.0)
mats["bottle_green"] = make_simple("v3r2h_bot_g", (0.10, 0.35, 0.15), 0.10, 0,
                                    em=(0.20, 0.55, 0.30), em_str=0.4)
mats["bottle_amber"] = make_simple("v3r2h_bot_a", (0.65, 0.35, 0.10), 0.10, 0,
                                    em=(0.95, 0.55, 0.20), em_str=0.4)
mats["bottle_blue"]  = make_simple("v3r2h_bot_b", (0.10, 0.30, 0.55), 0.10, 0,
                                    em=(0.30, 0.55, 0.95), em_str=0.4)
mats["lamp_warm"]   = make_emit("v3r2h_lamp", (1.0, 0.80, 0.40), 8.0)
mats["candle_flame"] = make_emit("v3r2h_candle", (1.0, 0.85, 0.50), 10.0)
mats["fire"]        = make_emit("v3r2h_fire", (1.0, 0.55, 0.10), 14.0)
mats["water"]       = make_simple("v3r2h_water", (0.10, 0.30, 0.50), 0.10, 0,
                                   em=(0.20, 0.45, 0.65), em_str=0.4)

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

def r_torus(name, loc, R, r, mat, parent, vc_red=0.5, vc_var=0.4, ms=24, mn=10, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_torus_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     major_segments=ms, minor_segments=mn,
                     major_radius=R, minor_radius=r, location=loc)
    o.rotation_euler = rot
    return o

def floor_walls(parent, floor_mat, wall_mat, sx=6, sy=5):
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0,0,0))
    f = bpy.context.object; f.name = "fl"; f.scale = (sx, sy, 1)
    f.data.materials.append(floor_mat)
    uv_unwrap(f); paint_vertex_color(f, base_red=0.55, variation=0.30)
    bv = f.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
    for poly in f.data.polygons: poly.use_smooth = True
    f.parent = parent

    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, sy/2, 1.6))
    bw = bpy.context.object; bw.name = "bw"; bw.scale = (sx, 3.2, 1)
    bw.rotation_euler = (math.pi/2, 0, 0)
    bw.data.materials.append(wall_mat)
    uv_unwrap(bw); paint_vertex_color(bw, base_red=0.55, variation=0.30)
    bv = bw.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
    for poly in bw.data.polygons: poly.use_smooth = True
    bw.parent = parent

    bpy.ops.mesh.primitive_plane_add(size=1, location=(-sx/2, 0, 1.6))
    sw = bpy.context.object; sw.name = "sw"; sw.scale = (sy, 3.2, 1)
    sw.rotation_euler = (math.pi/2, 0, math.pi/2)
    sw.data.materials.append(wall_mat)
    uv_unwrap(sw); paint_vertex_color(sw, base_red=0.55, variation=0.30)
    bv = sw.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
    for poly in sw.data.polygons: poly.use_smooth = True
    sw.parent = parent

# ============================================================
# 4 INTERIORS
# ============================================================
def hub_study(p, o):
    floor_walls(p, mats["wood_med"], mats["leather_brown"])
    # Bookshelf wall (3 shelves x 10 books)
    for s in range(3):
        z = 0.4 + s * 0.7
        r_box(f"sh_{s}", (-1.8, 2.1, z + 0.30), (3.2, 0.30, 0.05), mats["wood_dark"], p,
               vc_red=0.55, vc_var=0.25)
        for j in range(10):
            x = -3.30 + j * 0.30
            color = [mats["leather_red"], mats["leather_brown"], mats["fabric_blue"]][j % 3]
            r_box(f"bk_{s}_{j}", (x, 2.1, z + 0.55), (0.10, 0.22, 0.45), color, p,
                   vc_red=0.55, vc_var=0.30)
    # Writing desk
    r_box("desk", (1.0, 0.0, 0.45), (1.6, 0.8, 0.06), mats["wood_dark"], p)
    for cx, cy in [(0.3, -0.3), (1.7, -0.3), (0.3, 0.3), (1.7, 0.3)]:
        r_box(f"desk_l_{cx}_{cy}", (cx, cy, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    # Scroll on desk
    r_cyl("scroll", (0.6, -0.2, 0.50), 0.05, 0.40, mats["paper"], p, verts=14, rot=(0, math.pi/2, 0))
    # Ink pot + quill
    r_cyl("ink", (1.4, 0.1, 0.52), 0.06, 0.10, mats["iron"], p, verts=12)
    r_cyl("quill", (1.45, 0.1, 0.62), 0.005, 0.20, mats["paper"], p, verts=6, rot=(0.3, 0, 0))
    # Candle
    r_cyl("candle", (0.0, -0.2, 0.55), 0.04, 0.20, mats["paper"], p, verts=12)
    r_sphere("flame", (0.0, -0.2, 0.70), 0.05, mats["candle_flame"], p, segs=14)

def hub_library(p, o):
    floor_walls(p, mats["wood_dark"], mats["wood_med"])
    # Tall bookcase wall (5 shelves x 18 books)
    for s in range(5):
        z = 0.30 + s * 0.55
        r_box(f"lb_sh_{s}", (0, 2.1, z + 0.27), (5.5, 0.30, 0.05), mats["wood_dark"], p,
               vc_red=0.55, vc_var=0.25)
        for j in range(18):
            x = -2.65 + j * 0.30
            color = [mats["leather_red"], mats["leather_brown"], mats["fabric_blue"], mats["leather_red"]][j % 4]
            r_box(f"lb_b_{s}_{j}", (x, 2.1, z + 0.50), (0.10, 0.22, 0.42), color, p,
                   vc_red=0.55, vc_var=0.30)
    # Reading table
    r_box("lb_tab", (0, -0.2, 0.45), (1.4, 0.9, 0.06), mats["wood_dark"], p)
    for cx, cy in [(-0.65, -0.6), (0.65, -0.6), (-0.65, 0.2), (0.65, 0.2)]:
        r_box(f"lb_l_{cx}_{cy}", (cx, cy, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    # Globe on table
    r_sphere("gl", (1.4, 0.6, 0.65), 0.18, mats["leather_brown"], p, segs=24)
    r_cyl("gl_p", (1.4, 0.6, 0.45), 0.05, 0.30, mats["brass"], p, verts=12)
    r_cyl("gl_b", (1.4, 0.6, 0.30), 0.18, 0.04, mats["wood_dark"], p, verts=20)
    # Open book
    r_box("op_l", (-0.20, -0.2, 0.50), (0.18, 0.24, 0.02), mats["paper"], p, rot=(0, 0.05, 0))
    r_box("op_r", (0.20, -0.2, 0.50), (0.18, 0.24, 0.02), mats["paper"], p, rot=(0, -0.05, 0))

def hub_lounge(p, o):
    floor_walls(p, mats["wood_dark"], mats["wood_med"])
    # Bar counter
    r_box("bar", (0, 1.0, 0.6), (3.0, 0.6, 1.2), mats["wood_dark"], p, vc_red=0.55, vc_var=0.25)
    r_box("bar_top", (0, 1.0, 1.22), (3.05, 0.65, 0.05), mats["wood_dark"], p)
    # Liquor wall (2 shelves x 6 bottles)
    for i in range(2):
        z = 1.9 + i * 0.5
        r_box(f"shelf_{i}", (0, 2.35, z), (2.6, 0.18, 0.04), mats["wood_med"], p)
        for j in range(6):
            x = -1.1 + j * 0.45
            color = [mats["bottle_green"], mats["bottle_amber"], mats["bottle_blue"]][j % 3]
            r_cyl(f"bot_{i}_{j}", (x, 2.35, z + 0.20), 0.06, 0.36, color, p, verts=14)
    # 3 bar stools
    for i, x in enumerate([-1.0, 0, 1.0]):
        r_cyl(f"st_top_{i}", (x, 0.0, 0.50), 0.18, 0.08, mats["wood_med"], p, verts=18)
        r_cyl(f"st_p_{i}",   (x, 0.0, 0.22), 0.04, 0.42, mats["iron"], p, verts=10)
    # Hanging lamp
    r_cyl("lamp_chain", (0, 0.5, 2.4), 0.02, 0.8, mats["iron"], p, verts=8)
    r_sphere("lamp", (0, 0.5, 1.85), 0.18, mats["lamp_warm"], p, segs=20)

def hub_cooking(p, o):
    floor_walls(p, mats["stone"], mats["stone"])
    # Hearth on back wall
    r_box("h_base", (0, 1.8, 0.4), (2.0, 0.7, 0.8), mats["stone"], p, vc_red=0.55, vc_var=0.25)
    r_box("h_top",  (0, 1.8, 1.5), (2.4, 0.9, 0.4), mats["stone"], p, vc_red=0.55, vc_var=0.25)
    r_box("h_arch", (0, 1.8, 1.0), (1.4, 0.4, 0.6), mats["wood_dark"], p)
    r_box("h_fire", (0, 1.6, 0.85), (1.0, 0.05, 0.30), mats["fire"], p)
    # Cauldron
    r_cyl("cd_b", (0, 0.3, 0.40), 0.45, 0.10, mats["iron"], p, verts=24)
    r_sphere("cd", (0, 0.3, 0.65), 0.42, mats["iron"], p, segs=24)
    r_cyl("cd_top", (0, 0.3, 0.95), 0.40, 0.05, mats["water"], p, verts=24)
    # Spice rack on side wall
    r_box("sr_v1", (-2.0, 1.0, 1.6), (0.04, 0.04, 1.4), mats["wood_dark"], p)
    r_box("sr_v2", (-2.0, 1.0, 2.4), (0.04, 0.04, 1.4), mats["wood_dark"], p)
    r_box("sr_h1", (-2.0, 1.0, 1.4), (0.5, 0.20, 0.05), mats["wood_med"], p)
    r_box("sr_h2", (-2.0, 1.0, 1.8), (0.5, 0.20, 0.05), mats["wood_med"], p)
    for i in range(4):
        r_cyl(f"jar_{i}",  (-2.0 + (i - 1.5) * 0.12, 1.0, 1.55), 0.05, 0.18, mats["bottle_amber"], p, verts=12)
        r_cyl(f"jar2_{i}", (-2.0 + (i - 1.5) * 0.12, 1.0, 1.95), 0.05, 0.18, mats["bottle_green"], p, verts=12)
    # Cutting board + knife
    r_box("cb",      (1.6, 0, 0.30), (0.6, 0.4, 0.04), mats["wood_med"], p)
    r_box("knife_h", (1.5, 0, 0.34), (0.06, 0.04, 0.06), mats["wood_dark"], p)
    r_box("knife_b", (1.7, 0, 0.34), (0.20, 0.06, 0.04), mats["iron"], p)

# ============================================================
# LAYOUT
# ============================================================
HUBS = [
    ("study",   hub_study),
    ("library", hub_library),
    ("lounge",  hub_lounge),
    ("cooking", hub_cooking),
]

CAMERAS = []
for i, (name, builder) in enumerate(HUBS):
    col = i % 2
    row = i // 2
    origin = Vector((col * 18, row * 18, 0))
    parent = bpy.data.objects.new(f"hub_{name}", None)
    scene.collection.objects.link(parent)
    parent.location = origin
    builder(parent, origin)
    bpy.ops.object.camera_add(location=(origin[0] + 4.0, origin[1] - 3.5, origin[2] + 2.5))
    cam = bpy.context.object; cam.name = f"cam_{name}"
    cam.data.lens = 35
    cam.data.dof.use_dof = True
    cam.data.dof.aperture_fstop = 4.0
    cam.data.dof.focus_distance = 6
    target = origin + Vector((0, 0.5, 1.2))
    direction = target - cam.location
    cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    CAMERAS.append((name, cam))

# Group overview camera
bpy.ops.object.camera_add(location=(9, -10, 14))
cam_g = bpy.context.object; cam_g.name = "cam_group"
cam_g.data.lens = 32
direction = Vector((9, 9, 1)) - cam_g.location
cam_g.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# Per-hub key+fill lighting
for i, (name, _) in enumerate(HUBS):
    col = i % 2; row = i // 2
    ox = col * 18; oy = row * 18
    bpy.ops.object.light_add(type='AREA', location=(ox + 3, oy - 3, 5))
    k = bpy.context.object; k.data.energy = 1100; k.data.color = (1.0, 0.78, 0.45); k.data.size = 5
    bpy.ops.object.light_add(type='AREA', location=(ox - 3, oy + 2, 4))
    f = bpy.context.object; f.data.energy = 350; f.data.color = (0.45, 0.55, 0.85); f.data.size = 5

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
scene.camera = cam_g
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r2_hubs_group.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_hub_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-hub GLB exports
for name, _ in HUBS:
    bpy.ops.object.select_all(action='DESELECT')
    parent_obj = bpy.data.objects.get(f"hub_{name}")
    if parent_obj:
        parent_obj.select_set(True)
        for child in parent_obj.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"hub_{name}_r2_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-11 Hub Interior Refinement complete ===")
