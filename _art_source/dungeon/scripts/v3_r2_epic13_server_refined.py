"""
Expansion V3 — ROUND 2 — Epic R2-13 — Server Room Biome Refinement
==================================================================
Round 2 of V3-13 Server Room. Smaller, denser, more refined corridor
with full Round 2 stack (Smart UV unwrap + vertex color paint +
multires + 5-seg bevel + vertex-color-aware shaders).

Layout: 12-unit deep corridor with:
  - Tiled metal grate floor + emissive trim runners
  - 4 server racks per side (8 total) w/ vent slits, LED bays,
    cable ports, corner screws
  - 2 wall-mounted scrolling-data screens (1 per side)
  - 3 ceiling pipes w/ valves + condensation drips
  - 2 cable bundle drops
  - Floor puddle reflecting rack glow
  - NO world volumetrics (Round 2 multires + volumetrics = too slow)

Outputs: 3 hero renders + 1 GLB export.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(113)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_r2_server_room.blend"
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

scene.world = bpy.data.worlds.new("v3r2sr_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.01, 0.02, 0.04, 1)
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
    ar.color_ramp.elements[0].color = (0.05, 0.05, 0.05, 1)
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

def make_screen_shader():
    """Animated scrolling-data screen shader."""
    m = bpy.data.materials.new("v3r2sr_screen")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.05, 0.10, 0.20, 1)
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["Emission Strength"].default_value = 5.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-700, 0)
    mp.inputs["Scale"].default_value = (12, 24, 1)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])

    brick = nodes.new("ShaderNodeTexBrick"); brick.location = (-450, 100)
    brick.inputs["Scale"].default_value = 1.0
    brick.inputs["Color1"].default_value = (0.05, 0.40, 0.85, 1)
    brick.inputs["Color2"].default_value = (0.20, 0.85, 1.0, 1)
    brick.inputs["Mortar"].default_value = (0.02, 0.05, 0.10, 1)
    brick.inputs["Mortar Size"].default_value = 0.02
    brick.inputs["Bias"].default_value = 0.0
    links.new(mp.outputs["Vector"], brick.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-450, -200)
    n.inputs["Scale"].default_value = 30.0
    n.inputs["Detail"].default_value = 4.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 0)
    mix.blend_type = 'MULTIPLY'
    mix.inputs["Factor"].default_value = 0.5
    links.new(brick.outputs["Color"], mix.inputs[6])
    links.new(n.outputs["Color"], mix.inputs[7])

    links.new(mix.outputs[2], bsdf.inputs["Base Color"])
    links.new(mix.outputs[2], bsdf.inputs["Emission Color"])
    return m

def make_grate_shader():
    """Floor grate w/ checker + voronoi rivets + curvature AO."""
    m = bpy.data.materials.new("v3r2sr_grate")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.55
    bsdf.inputs["Metallic"].default_value = 0.85
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (8, 8, 8)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    check = nodes.new("ShaderNodeTexChecker"); check.location = (-700, 200)
    check.inputs["Scale"].default_value = 24.0
    check.inputs["Color1"].default_value = (0.20, 0.22, 0.26, 1)
    check.inputs["Color2"].default_value = (0.10, 0.12, 0.16, 1)
    links.new(mp.outputs["Vector"], check.inputs["Vector"])

    vor = nodes.new("ShaderNodeTexVoronoi"); vor.location = (-700, -100)
    vor.feature = 'F1'
    vor.inputs["Scale"].default_value = 20.0
    links.new(mp.outputs["Vector"], vor.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-450, -100)
    bp.inputs["Strength"].default_value = 0.6
    links.new(vor.outputs["Distance"], bp.inputs["Height"])

    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-700, -300)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (-450, -300)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.02, 0.02, 0.02, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location = (200, 0)
    md.inputs["Factor"].default_value = 0.40
    links.new(check.outputs["Color"], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])
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
mats["grate"]    = make_grate_shader()
mats["rack"]     = make_arch("v3r2sr_rack", (0.10, 0.11, 0.13), (0.18, 0.20, 0.24),
                              roughness=0.30, metallic=0.85, voronoi_scale=18.0, bump_strength=0.10)
mats["rack_door"] = make_arch("v3r2sr_door", (0.06, 0.08, 0.10), (0.14, 0.16, 0.20),
                               roughness=0.40, metallic=0.85, voronoi_scale=18.0, bump_strength=0.10)
mats["led_cyan"]  = make_emit("v3r2sr_led_c", (0.40, 0.95, 1.0), 14.0)
mats["led_red"]   = make_emit("v3r2sr_led_r", (1.0, 0.30, 0.30), 10.0)
mats["led_green"] = make_emit("v3r2sr_led_g", (0.30, 1.0, 0.40), 10.0)
mats["cable_b"]   = make_arch("v3r2sr_cable_b", (0.04, 0.04, 0.04), (0.10, 0.10, 0.10),
                                roughness=0.45, metallic=0.10, voronoi_scale=80.0, bump_strength=0.20)
mats["cable_bl"]  = make_arch("v3r2sr_cable_bl", (0.10, 0.20, 0.55), (0.18, 0.30, 0.68),
                                roughness=0.45, voronoi_scale=80.0, bump_strength=0.20)
mats["cable_r"]   = make_arch("v3r2sr_cable_r", (0.55, 0.10, 0.10), (0.68, 0.18, 0.18),
                                roughness=0.45, voronoi_scale=80.0, bump_strength=0.20)
mats["pipe"]      = make_arch("v3r2sr_pipe", (0.55, 0.58, 0.62), (0.68, 0.70, 0.75),
                                roughness=0.30, metallic=0.95, voronoi_scale=22.0, bump_strength=0.10)
mats["valve"]     = make_arch("v3r2sr_valve", (0.85, 0.55, 0.18), (0.95, 0.68, 0.28),
                                roughness=0.30, metallic=0.92, voronoi_scale=18.0, bump_strength=0.10,
                                emission_color=(1.0, 0.65, 0.20), emission_strength=0.5)
mats["water_drop"] = make_simple("v3r2sr_drop", (0.15, 0.40, 0.55), 0.05, 0,
                                   em=(0.30, 0.65, 0.85), em_str=2.0)
mats["screen"]    = make_screen_shader()
mats["screen_frame"] = make_arch("v3r2sr_scr_frame", (0.05, 0.05, 0.07), (0.12, 0.12, 0.16),
                                   roughness=0.30, metallic=0.95, voronoi_scale=18.0, bump_strength=0.10,
                                   emission_color=(0.30, 0.85, 1.0), emission_strength=1.5)
mats["trim"]      = make_emit("v3r2sr_trim", (0.30, 0.85, 1.0), 10.0)
mats["puddle"]    = make_simple("v3r2sr_puddle", (0.05, 0.10, 0.18), 0.05, 0.50,
                                  em=(0.20, 0.45, 0.75), em_str=0.6)
mats["ceiling"]   = make_arch("v3r2sr_ceiling", (0.06, 0.07, 0.09), (0.14, 0.16, 0.20),
                                roughness=0.40, metallic=0.85, voronoi_scale=22.0, bump_strength=0.10)
mats["screw"]     = make_simple("v3r2sr_screw", (0.40, 0.42, 0.45), 0.30, 0.95)

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

def r_torus(name, loc, R, r, mat, parent, vc_red=0.5, vc_var=0.4, ms=24, mn=10, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_torus_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     major_segments=ms, minor_segments=mn,
                     major_radius=R, minor_radius=r, location=loc)
    o.rotation_euler = rot
    return o

# ============================================================
# CORRIDOR LAYOUT
# ============================================================
parent = bpy.data.objects.new("v3_r2_server_room", None); scene.collection.objects.link(parent)

CORRIDOR_LEN = 12
CORRIDOR_WID = 5
CEIL_H = 4.0

# Floor
r_box("floor", (0, 0, 0), (CORRIDOR_WID, CORRIDOR_LEN, 0.05), mats["grate"], parent,
       vc_red=0.55, vc_var=0.20)
# Puddle
r_box("puddle", (0, 2, 0.03), (1.6, 1.0, 0.005), mats["puddle"], parent)
# Ceiling
r_box("ceiling", (0, 0, CEIL_H), (CORRIDOR_WID, CORRIDOR_LEN, 0.05), mats["ceiling"], parent,
       vc_red=0.55, vc_var=0.25)
# Floor & ceiling trim runners
r_box("trim_l",  (-CORRIDOR_WID/2 + 0.1, 0, 0.06), (0.04, CORRIDOR_LEN, 0.02), mats["trim"], parent)
r_box("trim_r",  (CORRIDOR_WID/2 - 0.1, 0, 0.06), (0.04, CORRIDOR_LEN, 0.02), mats["trim"], parent)
r_box("ctrim_l", (-CORRIDOR_WID/2 + 0.1, 0, CEIL_H - 0.06), (0.04, CORRIDOR_LEN, 0.02), mats["trim"], parent)
r_box("ctrim_r", (CORRIDOR_WID/2 - 0.1, 0, CEIL_H - 0.06), (0.04, CORRIDOR_LEN, 0.02), mats["trim"], parent)

# ============================================================
# 8 SERVER RACKS — 4 per side
# ============================================================
def server_rack(name, loc, side):
    rx, ry, rz = loc
    rack_w = 1.6; rack_h = 3.6; rack_d = 0.7
    # Body
    r_box(f"{name}_body", (rx, ry, rz + rack_h/2 + 0.1), (rack_d, rack_w, rack_h), mats["rack"], parent,
           vc_red=0.55, vc_var=0.30)
    # Door
    door_x = rx - side * (rack_d/2 + 0.01)
    r_box(f"{name}_door", (door_x, ry, rz + rack_h/2 + 0.1), (0.04, rack_w*0.92, rack_h*0.92),
           mats["rack_door"], parent, vc_red=0.55, vc_var=0.25)
    # 6 vent slits
    for i in range(6):
        z = rz + 0.4 + i * 0.50
        r_box(f"{name}_vent_{i}", (door_x - side*0.02, ry, z), (0.005, rack_w*0.6, 0.05),
               mats["rack_door"], parent)
    # 12 LED bay lights (mix of cyan/red/green)
    for i in range(12):
        z = rz + 2.4 + (i // 4) * 0.18
        col = i % 4
        x_off = (col - 1.5) * 0.18
        led_color = mats["led_cyan"] if i % 3 != 0 else (mats["led_red"] if i % 5 == 0 else mats["led_green"])
        r_sphere(f"{name}_led_{i}", (door_x - side*0.04, ry + x_off, z), 0.025, led_color, parent, segs=14)
    # 8 cable ports
    for i in range(8):
        x_off = (i - 3.5) * 0.16
        r_cyl(f"{name}_port_{i}", (door_x - side*0.03, ry + x_off, rz + 0.55),
               0.04, 0.06, mats["rack_door"], parent, verts=10, rot=(0, math.pi/2, 0))
        r_sphere(f"{name}_pin_{i}", (door_x - side*0.06, ry + x_off, rz + 0.55), 0.020,
                  mats["led_cyan"], parent, segs=12)
    # 4 corner screws
    for cx in [-1, 1]:
        for cy in [-1, 1]:
            r_sphere(f"{name}_sc_{cx}_{cy}", (rx + cx * rack_d * 0.45, ry + cy * rack_w * 0.45, rz + 0.10),
                      0.025, mats["screw"], parent, segs=12)

RACK_POS_Y = [-4.4, -1.4, 1.6, 4.6]
for i, ry in enumerate(RACK_POS_Y):
    server_rack(f"rack_L_{i}", (-CORRIDOR_WID/2 - 0.35, ry, 0), -1)
    server_rack(f"rack_R_{i}", ( CORRIDOR_WID/2 + 0.35, ry, 0),  1)

# ============================================================
# 2 WALL SCREENS
# ============================================================
def wall_screen(name, loc, side):
    sx, sy, sz = loc
    r_box(f"{name}_frame", (sx, sy, sz), (0.08, 1.0, 0.7), mats["screen_frame"], parent)
    r_box(f"{name}_scr", (sx - side*0.05, sy, sz), (0.02, 0.92, 0.62), mats["screen"], parent)
    r_cyl(f"{name}_mt1", (sx + side*0.05, sy + 0.4, sz - 0.30), 0.03, 0.20, mats["rack"], parent,
           verts=10, rot=(math.pi/2, 0, 0))
    r_cyl(f"{name}_mt2", (sx + side*0.05, sy - 0.4, sz - 0.30), 0.03, 0.20, mats["rack"], parent,
           verts=10, rot=(math.pi/2, 0, 0))

wall_screen("scr_L", (-CORRIDOR_WID/2 - 0.10, 0, 2.0), -1)
wall_screen("scr_R", ( CORRIDOR_WID/2 + 0.10, 0, 2.0),  1)

# ============================================================
# CEILING PIPES + valves + drips
# ============================================================
for i, x in enumerate([-1.2, 0, 1.2]):
    r_cyl(f"pipe_{i}", (x, 0, CEIL_H - 0.18), 0.10, CORRIDOR_LEN, mats["pipe"], parent,
           verts=20, rot=(math.pi/2, 0, 0))
    # 3 valves per pipe
    for j, vy in enumerate([-3.5, 0.0, 3.5]):
        r_cyl(f"v_{i}_{j}_b", (x, vy, CEIL_H - 0.18), 0.13, 0.10, mats["pipe"], parent, verts=14)
        r_torus(f"v_{i}_{j}_w", (x, vy, CEIL_H - 0.05), 0.14, 0.02, mats["valve"], parent, ms=18, mn=8)
        for sp in range(4):
            ang = sp * math.pi/2
            r_box(f"v_{i}_{j}_sp_{sp}", (x + math.cos(ang)*0.10, vy + math.sin(ang)*0.10, CEIL_H - 0.05),
                   (0.18, 0.02, 0.02), mats["valve"], parent, rot=(0, 0, ang))
    # 3 drips per pipe
    for j, dy in enumerate([-2.5, 0.5, 3.0]):
        r_sphere(f"d_{i}_{j}", (x, dy, CEIL_H - 0.32), 0.04, mats["water_drop"], parent, segs=14)

# ============================================================
# 2 CABLE BUNDLES
# ============================================================
def cable_drop(name, x_top, y, x_bot):
    for i in range(5):
        offset = (i - 2) * 0.025
        mat = [mats["cable_b"], mats["cable_bl"], mats["cable_r"], mats["cable_b"], mats["cable_bl"]][i]
        # Top stub
        r_cyl(f"{name}_t{i}", (x_top + offset, y, CEIL_H - 0.36), 0.018, 0.20, mat, parent, verts=8)
        # Hanging segment
        mid_x = (x_top + x_bot)/2 + offset
        mid_z = CEIL_H/2 + 0.4
        r_cyl(f"{name}_m{i}", (mid_x, y, mid_z), 0.018, 2.0, mat, parent, verts=8,
               rot=(0, math.atan2(x_top-x_bot, CEIL_H-1.5), 0))
        # Bottom stub
        r_cyl(f"{name}_b{i}", (x_bot + offset, y, 1.5), 0.018, 0.30, mat, parent, verts=8)

cable_drop("cb_L", -1.0, -3.0, -CORRIDOR_WID/2 + 0.4)
cable_drop("cb_R",  1.0,  3.0,  CORRIDOR_WID/2 - 0.4)

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='SPOT', location=(0, 5, CEIL_H - 0.3))
sp = bpy.context.object
sp.data.energy = 4500; sp.data.color = (0.40, 0.85, 1.0)
sp.data.spot_size = math.radians(80)
sp.rotation_euler = (math.pi, 0, 0)

bpy.ops.object.light_add(type='AREA', location=(0, -5, 2.5))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.25, 0.55, 0.85); fill.data.size = 4

bpy.ops.object.light_add(type='AREA', location=(-3.2, 0, 2.0))
sl = bpy.context.object
sl.data.energy = 300; sl.data.color = (0.35, 0.85, 1.0); sl.data.size = 6
sl.rotation_euler = (0, math.pi/2, 0)

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

cam_corridor = add_cam("cam_corridor", Vector((0, -6.5, 1.7)), Vector((0, 5, 1.5)), lens=32, dof_dist=10)
cam_rack     = add_cam("cam_rack",     Vector((1.2, -2.0, 1.6)), Vector((-2.4, -1.4, 1.6)), lens=50, dof_dist=4)
cam_ceiling  = add_cam("cam_ceiling",  Vector((0, -2, 1.5)),    Vector((0, 0, CEIL_H - 0.5)), lens=24, dof_dist=4)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("corridor", cam_corridor),
    ("rack",     cam_rack),
    ("ceiling",  cam_ceiling),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_server_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
out_path = os.path.join(EXPORT_DIR, "server_room_r2_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-13 Server Room Refinement complete ===")
