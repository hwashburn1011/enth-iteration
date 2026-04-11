"""
Expansion V3 — ROUND 2 — Epic R2-17 — Floor Detailing Refinement
================================================================
Round 2 of V3-17. 3 hero dungeon floor archetypes with full Round 2
stack (Smart UV unwrap + vertex color paint + multires + 5-seg bevel
+ vertex-color-aware shaders).

Floors:
  HUB & SPOKE     — central rotunda + 8 marble pillars + 4 spoke
                     openings + glow rune disc + spoke corridor stub
  PROCESSIONAL    — 16-unit corridor w/ red carpet + carved walls
                     + 12 sconces + hanging banners + 2 statues
  BOSS APPROACH   — 14-unit wide hall w/ 8 massive pillars + glow
                     bands + throne silhouette w/ crystal heart

Outputs: 4 hero shots @ 1920x1080 + 3 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(117)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_r2_floors.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
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

scene.world = bpy.data.worlds.new("v3r2fl_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.02, 0.03, 1)
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
    ar.color_ramp.elements[0].color = (0.12, 0.08, 0.04, 1)
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
mats["floor_tile"]     = make_arch("v3r2fl_tile", (0.42, 0.38, 0.32), (0.52, 0.48, 0.40),
                                     roughness=0.85, voronoi_scale=8.0, bump_strength=0.30)
mats["floor_polished"] = make_arch("v3r2fl_polish", (0.30, 0.28, 0.25), (0.40, 0.38, 0.34),
                                     roughness=0.20, metallic=0.05, voronoi_scale=6.0, bump_strength=0.10)
mats["wall_brick"]     = make_arch("v3r2fl_brick", (0.55, 0.45, 0.32), (0.68, 0.55, 0.40),
                                     roughness=0.92, voronoi_scale=10.0, bump_strength=0.40)
mats["wall_carved"]    = make_arch("v3r2fl_carved", (0.50, 0.42, 0.30), (0.62, 0.52, 0.38),
                                     roughness=0.85, voronoi_scale=10.0, bump_strength=0.30,
                                     emission_color=(1.0, 0.65, 0.20), emission_strength=0.4)
mats["wall_stone"]     = make_arch("v3r2fl_stone", (0.40, 0.38, 0.34), (0.50, 0.48, 0.42),
                                     roughness=0.92, voronoi_scale=6.0, bump_strength=0.35)
mats["pillar_marble"]  = make_arch("v3r2fl_marble", (0.78, 0.74, 0.65), (0.88, 0.85, 0.78),
                                     roughness=0.30, voronoi_scale=8.0, bump_strength=0.10)
mats["wood_dark"]      = make_arch("v3r2fl_wood", (0.18, 0.10, 0.05), (0.28, 0.16, 0.08),
                                     roughness=0.85, voronoi_scale=12.0, bump_strength=0.20)
mats["iron"]           = make_arch("v3r2fl_iron", (0.18, 0.18, 0.20), (0.28, 0.28, 0.32),
                                     roughness=0.45, metallic=0.85, voronoi_scale=22.0, bump_strength=0.10)
mats["banner_red"]     = make_arch("v3r2fl_banner_r", (0.55, 0.10, 0.10), (0.68, 0.18, 0.15),
                                     roughness=0.85, voronoi_scale=40.0, bump_strength=0.20,
                                     emission_color=(0.85, 0.30, 0.10), emission_strength=0.4)
mats["torch_fire"]     = make_emit("v3r2fl_fire", (1.0, 0.55, 0.20), 18.0)
mats["sconce_glow"]    = make_emit("v3r2fl_sconce", (1.0, 0.78, 0.40), 12.0)
mats["rune_glow"]      = make_emit("v3r2fl_rune", (1.0, 0.78, 0.30), 14.0)
mats["chain"]          = make_arch("v3r2fl_chain", (0.10, 0.10, 0.12), (0.18, 0.18, 0.22),
                                     roughness=0.55, metallic=0.85, voronoi_scale=40.0, bump_strength=0.20)

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

# Reusable wall sconce
def wall_sconce(name, x, y, z, normal_dir, parent):
    nx, ny = {'left': (1, 0), 'right': (-1, 0), 'back': (0, -1), 'front': (0, 1)}[normal_dir]
    r_box(f"{name}_plate", (x, y, z),
           (0.20 if abs(ny)>0 else 0.04, 0.04 if abs(ny)>0 else 0.20, 0.30), mats["iron"], parent)
    r_cyl(f"{name}_arm", (x + nx*0.10, y + ny*0.10, z), 0.025, 0.25, mats["iron"], parent, verts=8,
           rot=(0, math.pi/2 if abs(nx)>0 else 0, math.pi/2 if abs(ny)>0 else 0))
    r_cyl(f"{name}_bowl", (x + nx*0.20, y + ny*0.20, z + 0.05), 0.10, 0.06, mats["iron"], parent, verts=14)
    r_sphere(f"{name}_f", (x + nx*0.20, y + ny*0.20, z + 0.16), 0.10, mats["torch_fire"], parent, segs=12)
    bpy.ops.object.light_add(type='POINT', location=(x + nx*0.30, y + ny*0.30, z + 0.20))
    lt = bpy.context.object
    lt.data.energy = 250; lt.data.color = (1.0, 0.65, 0.30)

# ============================================================
# FLOOR 1: HUB & SPOKE
# ============================================================
def floor_hub_spoke(origin):
    parent = bpy.data.objects.new("fl_hub_spoke", None); scene.collection.objects.link(parent)
    parent.location = origin
    HUB_R = 4.0
    # Central rotunda floor
    r_cyl("hs_floor", (0, 0, 0), HUB_R, 0.10, mats["floor_tile"], parent,
           vc_red=0.55, vc_var=0.20, verts=32)
    # Inlay rings
    r_torus("hs_ring1", (0, 0, 0.05), HUB_R - 0.5, 0.04, mats["rune_glow"], parent, ms=64, mn=10)
    r_torus("hs_ring2", (0, 0, 0.05), HUB_R - 1.5, 0.03, mats["rune_glow"], parent, ms=48, mn=10)
    r_cyl("hs_disc", (0, 0, 0.06), 1.2, 0.02, mats["rune_glow"], parent, verts=32)
    # 8 marble pillars around hub
    for i in range(8):
        ang = i * math.pi/4
        x = math.cos(ang) * (HUB_R - 0.6)
        y = math.sin(ang) * (HUB_R - 0.6)
        r_box(f"hs_p_{i}_b", (x, y, 0.30), (0.6, 0.6, 0.40), mats["wall_carved"], parent,
               vc_red=0.55, vc_var=0.30)
        r_cyl(f"hs_p_{i}_s", (x, y, 2.5), 0.22, 4.0, mats["pillar_marble"], parent,
               vc_red=0.55, vc_var=0.30, verts=16)
        r_box(f"hs_p_{i}_c", (x, y, 4.65), (0.6, 0.6, 0.30), mats["wall_carved"], parent,
               vc_red=0.55, vc_var=0.30)
        r_torus(f"hs_p_{i}_band", (x, y, 2.5), 0.26, 0.04, mats["rune_glow"], parent, ms=20, mn=8)
    # 4-spoke wall openings (8 wedge segments leaving 4 gaps)
    SEG = 8
    for i in range(SEG):
        if i % 2 == 0:
            continue
        ang = i * (math.pi*2/SEG)
        wx = math.cos(ang) * (HUB_R + 0.5)
        wy = math.sin(ang) * (HUB_R + 0.5)
        r_box(f"hs_w_{i}", (wx, wy, 1.5), (1.4, 0.4, 3.0), mats["wall_brick"], parent,
               vc_red=0.55, vc_var=0.30, rot=(0, 0, ang + math.pi/2))
    # Spoke corridor stub on +X
    r_box("hs_sp_floor", (HUB_R + 1.5, 0, 0), (3.0, 1.6, 0.10), mats["floor_tile"], parent,
           vc_red=0.55, vc_var=0.20)
    r_box("hs_sp_w1", (HUB_R + 1.5, 0.85, 1.5), (3.0, 0.10, 3.0), mats["wall_brick"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box("hs_sp_w2", (HUB_R + 1.5, -0.85, 1.5), (3.0, 0.10, 3.0), mats["wall_brick"], parent,
           vc_red=0.55, vc_var=0.30)
    wall_sconce("hs_sc1", HUB_R + 0.8, 0.78, 1.8, 'back', parent)
    wall_sconce("hs_sc2", HUB_R + 2.2, 0.78, 1.8, 'back', parent)
    return parent

# ============================================================
# FLOOR 2: PROCESSIONAL HALL
# ============================================================
def floor_processional(origin):
    parent = bpy.data.objects.new("fl_processional", None); scene.collection.objects.link(parent)
    parent.location = origin
    LEN = 16
    r_box("pr_floor", (0, 0, 0), (4.0, LEN, 0.10), mats["floor_polished"], parent,
           vc_red=0.55, vc_var=0.20)
    # Carpet runner
    r_box("pr_carpet", (0, 0, 0.06), (1.2, LEN - 0.2, 0.01), mats["banner_red"], parent,
           vc_red=0.55, vc_var=0.20)
    # Walls
    r_box("pr_wL", (-2.1, 0, 2.0), (0.20, LEN, 4.0), mats["wall_carved"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box("pr_wR", (2.1, 0, 2.0), (0.20, LEN, 4.0), mats["wall_carved"], parent,
           vc_red=0.55, vc_var=0.30)
    # 6 sconces per side
    for i in range(6):
        y = -6.5 + i * 2.6
        wall_sconce(f"pr_scL_{i}", -1.95, y, 2.2, 'left', parent)
        wall_sconce(f"pr_scR_{i}", 1.95, y, 2.2, 'right', parent)
    # 4 banners per side
    for i, y in enumerate([-5, -1.5, 1.5, 5]):
        r_box(f"pr_bnL_{i}", (-1.95, y, 3.2), (0.04, 0.4, 1.0), mats["banner_red"], parent,
               vc_red=0.55, vc_var=0.30)
        r_box(f"pr_bnR_{i}", (1.95, y, 3.2), (0.04, 0.4, 1.0), mats["banner_red"], parent,
               vc_red=0.55, vc_var=0.30)
    # 2 statues at far end
    for i, x in enumerate([-1.2, 1.2]):
        r_cyl(f"pr_stat_b_{i}", (x, 7.2, 0.40), 0.40, 0.80, mats["wall_stone"], parent,
               vc_red=0.55, vc_var=0.30, verts=14)
        r_cyl(f"pr_stat_t_{i}", (x, 7.2, 1.6), 0.30, 1.6, mats["pillar_marble"], parent,
               vc_red=0.55, vc_var=0.30, verts=14)
        r_sphere(f"pr_stat_h_{i}", (x, 7.2, 2.7), 0.30, mats["pillar_marble"], parent,
                  vc_red=0.55, vc_var=0.30)
    return parent

# ============================================================
# FLOOR 3: BOSS APPROACH
# ============================================================
def floor_boss_approach(origin):
    parent = bpy.data.objects.new("fl_boss_approach", None); scene.collection.objects.link(parent)
    parent.location = origin
    LEN = 14
    WID = 7
    r_box("ba_floor", (0, 0, 0), (WID, LEN, 0.10), mats["floor_polished"], parent,
           vc_red=0.55, vc_var=0.20)
    # Center sigil strip
    r_box("ba_strip", (0, 0, 0.06), (1.5, LEN - 1, 0.01), mats["rune_glow"], parent)
    # Walls
    r_box("ba_wL", (-WID/2, 0, 3.0), (0.20, LEN, 6.0), mats["wall_carved"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box("ba_wR", (WID/2, 0, 3.0), (0.20, LEN, 6.0), mats["wall_carved"], parent,
           vc_red=0.55, vc_var=0.30)
    # 8 massive pillars (4 pairs)
    for i, y in enumerate([-5, -1.5, 1.5, 5]):
        for sx in [-WID/2 + 0.7, WID/2 - 0.7]:
            r_box(f"ba_pl_b_{i}_{sx}", (sx, y, 0.50), (1.0, 1.0, 1.0), mats["wall_carved"], parent,
                   vc_red=0.55, vc_var=0.30)
            r_cyl(f"ba_pl_s_{i}_{sx}", (sx, y, 3.5), 0.40, 5.0, mats["pillar_marble"], parent,
                   vc_red=0.55, vc_var=0.30, verts=20)
            r_torus(f"ba_pl_band_{i}_{sx}", (sx, y, 3.5), 0.45, 0.06, mats["rune_glow"], parent,
                     ms=24, mn=10)
            r_box(f"ba_pl_c_{i}_{sx}", (sx, y, 6.10), (1.1, 1.1, 0.30), mats["wall_carved"], parent,
                   vc_red=0.55, vc_var=0.30)
    # Throne silhouette at far end
    r_box("ba_throne_b", (0, 6.5, 0.50), (3.0, 1.4, 1.0), mats["wall_stone"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box("ba_throne_seat", (0, 6.5, 1.20), (2.4, 1.2, 0.30), mats["wall_stone"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box("ba_throne_back", (0, 7.0, 3.5), (2.6, 0.30, 4.0), mats["wall_stone"], parent,
           vc_red=0.55, vc_var=0.30)
    r_sphere("ba_throne_heart", (0, 6.85, 3.0), 0.30, mats["torch_fire"], parent,
              vc_red=0.5, vc_var=0.10, segs=20)
    bpy.ops.object.light_add(type='POINT', location=(origin[0], origin[1] + 6.85, origin[2] + 3.0))
    hp = bpy.context.object
    hp.data.energy = 1500; hp.data.color = (1.0, 0.45, 0.20)
    # 4 hanging chains
    for i, (cx, cy) in enumerate([(-2, -3),(2, -3),(-2, 2),(2, 2)]):
        for j in range(5):
            r_torus(f"ba_ch_{i}_{j}", (cx, cy, 5.5 - j*0.30), 0.10, 0.025, mats["chain"], parent,
                     ms=12, mn=8, rot=(math.pi/2 if j%2==0 else 0, 0, 0))
    # 6 sconces
    for i, y in enumerate([-4, 0, 4]):
        wall_sconce(f"ba_scL_{i}", -WID/2 + 0.15, y, 2.5, 'left', parent)
        wall_sconce(f"ba_scR_{i}", WID/2 - 0.15, y, 2.5, 'right', parent)
    return parent

# ============================================================
# LAYOUT
# ============================================================
FLOORS = [
    ("hub_spoke",    floor_hub_spoke,     Vector((0, 0, 0))),
    ("processional", floor_processional,  Vector((28, 0, 0))),
    ("boss_approach", floor_boss_approach, Vector((56, 0, 0))),
]

CAMERAS = []
for name, builder, origin in FLOORS:
    builder(origin)
    bpy.ops.object.light_add(type='AREA', location=(origin[0] + 4, origin[1] - 6, origin[2] + 6))
    k = bpy.context.object; k.data.energy = 1200; k.data.color = (1.0, 0.78, 0.45); k.data.size = 6
    bpy.ops.object.light_add(type='AREA', location=(origin[0] - 4, origin[1] + 4, origin[2] + 5))
    f = bpy.context.object; f.data.energy = 400; f.data.color = (0.45, 0.55, 0.85); f.data.size = 6
    bpy.ops.object.camera_add(location=(origin[0] + 5, origin[1] - 8, origin[2] + 4))
    cam = bpy.context.object; cam.name = f"cam_{name}"
    cam.data.lens = 32
    cam.data.dof.use_dof = True
    cam.data.dof.aperture_fstop = 4.5
    cam.data.dof.focus_distance = 12
    target = origin + Vector((0, 2, 1.6))
    direction = target - cam.location
    cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    CAMERAS.append((name, cam))

# Group overview camera
bpy.ops.object.camera_add(location=(28, -18, 14))
cam_g = bpy.context.object; cam_g.name = "cam_group"
cam_g.data.lens = 35
cam_g.data.dof.use_dof = True; cam_g.data.dof.aperture_fstop = 6.3
cam_g.data.dof.focus_distance = 25
direction = Vector((28, 0, 1)) - cam_g.location
cam_g.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render group + per-floor
scene.camera = cam_g
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r2_floors_group.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_floor_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-floor GLB
for name, _, _ in FLOORS:
    bpy.ops.object.select_all(action='DESELECT')
    parent_obj = bpy.data.objects.get(f"fl_{name}")
    if parent_obj:
        parent_obj.select_set(True)
        for child in parent_obj.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"floor_{name}_r2_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )

print("=== V3 Round 2 Epic R2-17 Floor Detailing Refinement complete ===")
