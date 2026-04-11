"""
Expansion V3 — ROUND 2 — Epic R2-07 — Town District Refinement
==============================================================
Round 2 of V3-07 Town Districts. 3 hero districts at trailer-grade
with full Round 2 stack (Smart UV unwrap + vertex color paint +
multires + 5-seg bevel + vertex-color-aware shaders).

Districts:
  CENTRAL  — marble plaza w/ 3-tier fountain + 4 benches + 4 brass
              lampposts + central hero statue
  MARKET   — wood plank floor w/ 4 stalls (counter+canvas awning+
              wares) + 3 walking lanterns + corner crates + barrels
  COMMONS  — grass field w/ 4 corner trees + central small fountain
              + 4 wooden benches + scattered flower patches

Each district ~50-70 mesh parts. Per-district hero camera.

Outputs: 4 hero renders @ 1920x1080 + 3 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(107)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_r2_districts.blend"
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

scene.world = bpy.data.worlds.new("v3r2d_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wsky = wnt.nodes.new("ShaderNodeTexSky")
wsky.sky_type = 'HOSEK_WILKIE'
wsky.sun_direction = (0.5, -0.5, 0.40)
wsky.turbidity = 3.0
wsky.ground_albedo = 0.4
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Strength"].default_value = 1.0
wnt.links.new(wsky.outputs[0], wbg.inputs[0])
wnt.links.new(wbg.outputs[0], wout.inputs[0])

# ============================================================
# REFINED VC-AWARE SHADER (architectural)
# ============================================================
def make_arch_shader(name, base_color, accent_color, roughness=0.85,
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
mats["marble_white"] = make_arch_shader("v3r2d_marble_w", (0.85, 0.83, 0.80), (0.95, 0.93, 0.88),
                                         roughness=0.30, voronoi_scale=8.0, bump_strength=0.10)
mats["marble_dark"]  = make_arch_shader("v3r2d_marble_d", (0.55, 0.52, 0.48), (0.65, 0.62, 0.58),
                                         roughness=0.40, voronoi_scale=10.0, bump_strength=0.12)
mats["wood_planks"]  = make_arch_shader("v3r2d_planks", (0.45, 0.28, 0.12), (0.58, 0.38, 0.18),
                                         roughness=0.85, voronoi_scale=10.0, bump_strength=0.20)
mats["wood_dark"]    = make_arch_shader("v3r2d_wood_d", (0.18, 0.10, 0.05), (0.28, 0.16, 0.08),
                                         roughness=0.85, voronoi_scale=12.0, bump_strength=0.20)
mats["grass"]        = make_arch_shader("v3r2d_grass", (0.18, 0.32, 0.12), (0.28, 0.45, 0.18),
                                         roughness=0.92, voronoi_scale=22.0, bump_strength=0.25)
mats["grass_dark"]   = make_arch_shader("v3r2d_grass_d", (0.10, 0.22, 0.08), (0.18, 0.32, 0.12),
                                         roughness=0.92, voronoi_scale=22.0, bump_strength=0.25)
mats["water"]        = make_pbr_simple("v3r2d_water", (0.10, 0.30, 0.50), 0.05, 0,
                                        em=(0.20, 0.50, 0.75), em_str=0.6)
mats["brass"]        = make_arch_shader("v3r2d_brass", (0.85, 0.65, 0.20), (0.95, 0.78, 0.35),
                                         roughness=0.20, metallic=0.92, voronoi_scale=18.0, bump_strength=0.10,
                                         emission_color=(1.0, 0.85, 0.30), emission_strength=0.5)
mats["iron"]         = make_arch_shader("v3r2d_iron", (0.18, 0.18, 0.20), (0.28, 0.28, 0.32),
                                         roughness=0.45, metallic=0.85, voronoi_scale=22.0, bump_strength=0.10)
mats["lantern_warm"] = make_emit("v3r2d_lantern", (1.0, 0.80, 0.40), 12.0)
mats["canvas_red"]   = make_arch_shader("v3r2d_canvas_r", (0.65, 0.20, 0.15), (0.78, 0.30, 0.22),
                                         roughness=0.85, voronoi_scale=30.0, bump_strength=0.20)
mats["canvas_blue"]  = make_arch_shader("v3r2d_canvas_b", (0.15, 0.30, 0.55), (0.25, 0.42, 0.70),
                                         roughness=0.85, voronoi_scale=30.0, bump_strength=0.20)
mats["bark"]         = make_arch_shader("v3r2d_bark", (0.18, 0.10, 0.05), (0.28, 0.16, 0.08),
                                         roughness=0.95, voronoi_scale=12.0, bump_strength=0.45)
mats["canopy_warm"]  = make_arch_shader("v3r2d_canopy", (0.15, 0.32, 0.10), (0.25, 0.42, 0.15),
                                         roughness=0.85, voronoi_scale=30.0, bump_strength=0.30)
mats["fruit_red"]    = make_pbr_simple("v3r2d_fruit_r", (0.85, 0.20, 0.15), 0.40,
                                        em=(1.0, 0.40, 0.20), em_str=0.6)
mats["fruit_yellow"] = make_pbr_simple("v3r2d_fruit_y", (0.95, 0.85, 0.20), 0.40,
                                        em=(1.0, 0.92, 0.30), em_str=0.6)
mats["bread"]        = make_pbr_simple("v3r2d_bread", (0.85, 0.62, 0.32), 0.85)
mats["flower_red"]   = make_pbr_simple("v3r2d_flw_r", (0.95, 0.18, 0.20), 0.65,
                                        em=(1.0, 0.30, 0.30), em_str=0.5)
mats["flower_yellow"] = make_pbr_simple("v3r2d_flw_y", (1.0, 0.85, 0.20), 0.65,
                                         em=(1.0, 0.95, 0.40), em_str=0.5)

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

# ============================================================
# DISTRICT BUILDERS
# ============================================================
def build_central(origin):
    p = bpy.data.objects.new("dist_central", None); scene.collection.objects.link(p); p.location = origin
    # Marble plaza floor (inset cross-pattern)
    r_box("plaza", (0, 0, 0), (10, 10, 0.10), mats["marble_white"], p,
           vc_red=0.55, vc_var=0.20)
    # Darker marble cross inlay
    r_box("inlay_h", (0, 0, 0.06), (8, 0.40, 0.02), mats["marble_dark"], p)
    r_box("inlay_v", (0, 0, 0.06), (0.40, 8, 0.02), mats["marble_dark"], p)
    # Outer marble border
    r_box("border_n", (0, 4.95, 0.06), (10, 0.10, 0.04), mats["marble_dark"], p)
    r_box("border_s", (0, -4.95, 0.06), (10, 0.10, 0.04), mats["marble_dark"], p)
    r_box("border_e", (4.95, 0, 0.06), (0.10, 10, 0.04), mats["marble_dark"], p)
    r_box("border_w", (-4.95, 0, 0.06), (0.10, 10, 0.04), mats["marble_dark"], p)
    # 3-tier central fountain
    r_cyl("fount_b1", (0, 0, 0.20), 1.80, 0.30, mats["marble_white"], p, verts=32)
    r_cyl("fount_b2", (0, 0, 0.50), 1.50, 0.20, mats["marble_white"], p, verts=32)
    r_cyl("fount_water1", (0, 0, 0.62), 1.40, 0.06, mats["water"], p, verts=32)
    r_cyl("fount_b3", (0, 0, 0.80), 0.90, 0.20, mats["marble_white"], p, verts=24)
    r_cyl("fount_water2", (0, 0, 0.92), 0.80, 0.06, mats["water"], p, verts=24)
    # Central spout
    r_cyl("fount_spout", (0, 0, 1.20), 0.20, 0.40, mats["brass"], p, verts=18)
    r_sphere("fount_top", (0, 0, 1.45), 0.12, mats["brass"], p, segs=18)
    # Water jet
    r_cyl("water_jet", (0, 0, 1.85), 0.05, 0.50, mats["water"], p, verts=10)
    # 4 brass lampposts at corners
    for i, (lx, ly) in enumerate([(-3.5, -3.5), (3.5, -3.5), (-3.5, 3.5), (3.5, 3.5)]):
        r_cyl(f"lamp_post_{i}", (lx, ly, 1.50), 0.12, 3.00, mats["brass"], p, verts=18)
        r_cyl(f"lamp_top_{i}", (lx, ly, 3.10), 0.18, 0.10, mats["brass"], p, verts=18)
        r_box(f"lamp_globe_{i}", (lx, ly, 3.30), (0.25, 0.25, 0.30), mats["lantern_warm"], p)
        r_cyl(f"lamp_cap_{i}", (lx, ly, 3.50), 0.18, 0.10, mats["brass"], p, verts=18)
    # 4 marble benches around plaza
    for i, (bx, by, rot) in enumerate([(0, -3.0, 0),(0, 3.0, 0),(-3.0, 0, math.pi/2),(3.0, 0, math.pi/2)]):
        r_box(f"bench_{i}_seat", (bx, by, 0.40), (1.20, 0.40, 0.10), mats["marble_white"], p, rot=(0, 0, rot))
        r_box(f"bench_{i}_l1", (bx + (0.5 if rot == 0 else 0), by + (0 if rot == 0 else 0.5), 0.20),
               (0.10, 0.30, 0.40), mats["marble_white"], p, rot=(0, 0, rot))
        r_box(f"bench_{i}_l2", (bx - (0.5 if rot == 0 else 0), by - (0 if rot == 0 else 0.5), 0.20),
               (0.10, 0.30, 0.40), mats["marble_white"], p, rot=(0, 0, rot))
    return p

def build_market(origin):
    p = bpy.data.objects.new("dist_market", None); scene.collection.objects.link(p); p.location = origin
    # Wood plank floor
    r_box("planks", (0, 0, 0), (10, 10, 0.10), mats["wood_planks"], p,
           vc_red=0.55, vc_var=0.30)
    # 4 stalls in corners
    def stall(name, x, y, awning_color):
        # Counter
        r_box(f"{name}_counter", (x, y, 0.50), (1.50, 0.80, 1.00), mats["wood_dark"], p,
               vc_red=0.55, vc_var=0.25)
        r_box(f"{name}_counter_top", (x, y, 1.05), (1.55, 0.85, 0.10), mats["wood_planks"], p)
        # 4 awning posts
        for j, (dx, dy) in enumerate([(-0.7, -0.4), (0.7, -0.4), (-0.7, 0.4), (0.7, 0.4)]):
            r_cyl(f"{name}_post_{j}", (x + dx, y + dy, 1.40), 0.06, 1.80, mats["wood_dark"], p, verts=10)
        # Sloped canvas awning (single sloped box)
        r_box(f"{name}_awning", (x, y - 0.20, 2.55), (1.80, 1.20, 0.06), awning_color, p, rot=(-0.3, 0, 0))
        # Awning trim (5 hanging pennants)
        for j in range(5):
            px = x - 0.70 + j * 0.35
            r_box(f"{name}_pen_{j}", (px, y - 0.55, 2.00), (0.10, 0.04, 0.20), awning_color, p)
        # 5 ware items on counter
        items = [mats["fruit_red"], mats["fruit_yellow"], mats["fruit_red"], mats["bread"], mats["fruit_yellow"]]
        for j, item_mat in enumerate(items):
            ix = x - 0.50 + j * 0.25
            r_sphere(f"{name}_ware_{j}", (ix, y, 1.20), 0.10, item_mat, p, segs=14)

    stall("stall_nw", -3.5,  3.0, mats["canvas_red"])
    stall("stall_ne",  3.5,  3.0, mats["canvas_blue"])
    stall("stall_sw", -3.5, -3.0, mats["canvas_blue"])
    stall("stall_se",  3.5, -3.0, mats["canvas_red"])

    # 3 walking lanterns on iron poles in middle of street
    for i, (lx, ly) in enumerate([(0, 4), (0, 0), (0, -4)]):
        r_cyl(f"walk_post_{i}", (lx, ly, 1.20), 0.06, 2.40, mats["iron"], p, verts=12)
        r_cyl(f"walk_arm_{i}", (lx + 0.30, ly, 2.30), 0.04, 0.30, mats["iron"], p, verts=8, rot=(0, math.pi/2, 0))
        r_box(f"walk_box_{i}", (lx + 0.40, ly, 2.10), (0.16, 0.16, 0.20), mats["lantern_warm"], p)
    # Corner stacked crates
    for i, (cx, cy) in enumerate([(-4.5, 4.5), (4.5, -4.5)]):
        r_box(f"crate_{i}_a", (cx, cy, 0.30), (0.60, 0.60, 0.60), mats["wood_dark"], p)
        r_box(f"crate_{i}_b", (cx + 0.10, cy + 0.05, 0.90), (0.55, 0.55, 0.55), mats["wood_dark"], p, rot=(0, 0, 0.2))
    # Barrels
    for i, (bx, by) in enumerate([(4.5, 4.5), (-4.5, -4.5)]):
        r_cyl(f"barrel_{i}", (bx, by, 0.50), 0.32, 0.90, mats["wood_dark"], p, verts=18)
        r_torus(f"barrel_{i}_band1", (bx, by, 0.25), 0.33, 0.025, mats["iron"], p, ms=20, mn=8)
        r_torus(f"barrel_{i}_band2", (bx, by, 0.75), 0.33, 0.025, mats["iron"], p, ms=20, mn=8)
    return p

def build_commons(origin):
    p = bpy.data.objects.new("dist_commons", None); scene.collection.objects.link(p); p.location = origin
    # Grass field
    r_box("grass_main", (0, 0, 0), (10, 10, 0.10), mats["grass"], p,
           vc_red=0.55, vc_var=0.30)
    # Darker grass border
    for ax, ay in [(0, 4.95), (0, -4.95), (4.95, 0), (-4.95, 0)]:
        if ax == 0:
            r_box("grass_b", (ax, ay, 0.06), (10, 0.20, 0.02), mats["grass_dark"], p)
        else:
            r_box("grass_b", (ax, ay, 0.06), (0.20, 10, 0.02), mats["grass_dark"], p)
    # 4 corner trees
    def make_tree(name, x, y):
        # Trunk
        r_cyl(f"{name}_trunk", (x, y, 1.40), 0.30, 2.80, mats["bark"], p, verts=14, vc_red=0.55, vc_var=0.30)
        # Canopy clumps
        r_sphere(f"{name}_canopy_main", (x, y, 3.40), 1.40, mats["canopy_warm"], p, segs=24)
        r_sphere(f"{name}_canopy_a", (x + 0.60, y + 0.20, 3.20), 0.80, mats["canopy_warm"], p, segs=18)
        r_sphere(f"{name}_canopy_b", (x - 0.60, y + 0.20, 3.20), 0.80, mats["canopy_warm"], p, segs=18)
        r_sphere(f"{name}_canopy_c", (x, y - 0.60, 3.20), 0.85, mats["canopy_warm"], p, segs=18)
        r_sphere(f"{name}_canopy_d", (x, y + 0.60, 3.50), 0.75, mats["canopy_warm"], p, segs=18)
    make_tree("tree_nw", -3.8,  3.8)
    make_tree("tree_ne",  3.8,  3.8)
    make_tree("tree_sw", -3.8, -3.8)
    make_tree("tree_se",  3.8, -3.8)

    # Central small fountain (single tier)
    r_cyl("fount_b", (0, 0, 0.20), 1.20, 0.30, mats["marble_white"], p, verts=24)
    r_cyl("fount_water", (0, 0, 0.40), 1.10, 0.04, mats["water"], p, verts=24)
    r_cyl("fount_spout", (0, 0, 0.60), 0.10, 0.20, mats["brass"], p, verts=14)
    r_sphere("fount_top", (0, 0, 0.78), 0.08, mats["brass"], p, segs=14)
    r_cyl("water_jet", (0, 0, 1.05), 0.04, 0.30, mats["water"], p, verts=8)
    # 4 wooden benches around fountain
    for i, (bx, by, rot) in enumerate([(0, -2.0, 0),(0, 2.0, 0),(-2.0, 0, math.pi/2),(2.0, 0, math.pi/2)]):
        r_box(f"bench_{i}_seat", (bx, by, 0.40), (1.20, 0.35, 0.08), mats["wood_dark"], p, rot=(0, 0, rot))
        r_box(f"bench_{i}_back", (bx + (0 if rot == 0 else -0.20), by + (0.20 if rot == 0 else 0), 0.65),
               (1.20 if rot == 0 else 0.04, 0.04 if rot == 0 else 1.20, 0.50), mats["wood_dark"], p)
        r_cyl(f"bench_{i}_l1", (bx + (0.50 if rot == 0 else 0), by + (0 if rot == 0 else 0.50), 0.18),
               0.025, 0.36, mats["iron"], p, verts=8)
        r_cyl(f"bench_{i}_l2", (bx - (0.50 if rot == 0 else 0), by - (0 if rot == 0 else 0.50), 0.18),
               0.025, 0.36, mats["iron"], p, verts=8)
    # Scattered flower patches
    for i in range(8):
        ang = i * (math.pi*2/8) + 0.3
        fx = math.cos(ang) * 4.0
        fy = math.sin(ang) * 4.0
        if (fx, fy) in [(-3.8, 3.8), (3.8, 3.8), (-3.8, -3.8), (3.8, -3.8)]:
            continue
        r_sphere(f"flw_{i}", (fx, fy, 0.15), 0.08, [mats["flower_red"], mats["flower_yellow"]][i % 2], p, segs=12)
    return p

# ============================================================
# SCENE LAYOUT — 3 districts spaced apart
# ============================================================
build_central(Vector((0, 0, 0)))
build_market(Vector((25, 0, 0)))
build_commons(Vector((50, 0, 0)))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='SUN', location=(15, -25, 30))
sun = bpy.context.object
sun.data.energy = 5.0
sun.data.color = (1.0, 0.92, 0.78)
sun.data.angle = math.radians(2)
direction = Vector((25, 0, 0)) - sun.location
sun.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-10, 15, 12))
fill = bpy.context.object
fill.data.energy = 1500; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 14

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=14, fstop=5.6):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_central = add_cam("cam_central", Vector((6, -10, 5)), Vector((0, 0, 1.0)), lens=35, dof_dist=12)
cam_market  = add_cam("cam_market",  Vector((31, -10, 5)), Vector((25, 0, 1.5)), lens=35, dof_dist=12)
cam_commons = add_cam("cam_commons", Vector((56, -10, 5)), Vector((50, 0, 2.5)), lens=35, dof_dist=12)
cam_overview = add_cam("cam_overview", Vector((25, -28, 14)), Vector((25, 0, 2.0)), lens=40, dof_dist=30)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("overview", cam_overview),
    ("central",  cam_central),
    ("market",   cam_market),
    ("commons",  cam_commons),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_district_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-district GLB
for name in ["central", "market", "commons"]:
    bpy.ops.object.select_all(action='DESELECT')
    parent_obj = bpy.data.objects.get(f"dist_{name}")
    if parent_obj:
        parent_obj.select_set(True)
        for child in parent_obj.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"district_{name}_r2_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-07 District Refinement complete ===")
