"""
Expansion V3 — Epic 13 — Server Room Biome Texture Pass
=======================================================
Hero server room dungeon hallway. The first dungeon biome at trailer-grade.

Layout: a 16-unit deep corridor with:
  - Tiled metal grate floor with ambient occlusion + screw bolts
  - Server rack walls flanking both sides (8 racks total)
  - Each rack: door with vent slits, 12 LED bay lights, 8 cable ports
  - Hanging cable bundles running ceiling-to-floor at 4 anchor points
  - Ceiling pipe runs (3 parallel pipes) with valves + condensation drips
  - 4 large wall-mounted glowing screens with scrolling-data shader
  - Volumetric cyan key light + accent emissive trim runners
  - Floor puddle reflecting the rack glow

Outputs:
  - 1 hero corridor render (forward depth) @ 1920x1080
  - 1 side detail render (rack close-up) @ 1280x960
  - 1 ceiling detail render @ 1280x960
  - 1 GLB export of full corridor
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(13)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_server_room.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 128
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

# Volumetric world (cyan haze)
scene.world = bpy.data.worlds.new("v3_srv_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Color"].default_value = (0.01, 0.02, 0.04, 1)
wbg.inputs["Strength"].default_value = 0.3
wnt.links.new(wbg.outputs[0], wout.inputs[0])

# Volumetric scatter
vol = wnt.nodes.new("ShaderNodeVolumeScatter")
vol.inputs["Color"].default_value = (0.30, 0.55, 0.85, 1)
vol.inputs["Density"].default_value = 0.012
wnt.links.new(vol.outputs[0], wout.inputs["Volume"])

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
        ar.color_ramp.elements[0].color = (0.05,0.05,0.05,1)
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

def make_screen_shader(name):
    """Animated scrolling-data screen shader."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.05, 0.10, 0.20, 1)
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["Emission Strength"].default_value = 4.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-700, 0)
    mp.inputs["Scale"].default_value = (12, 24, 1)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])

    # vertical scrolling brick pattern simulating data rows
    brick = nodes.new("ShaderNodeTexBrick"); brick.location = (-450, 100)
    brick.inputs["Scale"].default_value = 1.0
    brick.inputs["Color1"].default_value = (0.05, 0.40, 0.85, 1)
    brick.inputs["Color2"].default_value = (0.20, 0.85, 1.0, 1)
    brick.inputs["Mortar"].default_value = (0.02, 0.05, 0.10, 1)
    brick.inputs["Mortar Size"].default_value = 0.02
    brick.inputs["Bias"].default_value = 0.0
    links.new(mp.outputs["Vector"], brick.inputs["Vector"])

    # noise multiply
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

def make_grate_shader(name):
    """Floor grate with diamond-tread emboss + ambient dirt."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (0.18, 0.20, 0.24, 1)
    bsdf.inputs["Roughness"].default_value = 0.55
    bsdf.inputs["Metallic"].default_value = 0.85
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (8, 8, 8)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # checker for grate cells
    check = nodes.new("ShaderNodeTexChecker"); check.location = (-700, 200)
    check.inputs["Scale"].default_value = 24.0
    check.inputs["Color1"].default_value = (0.20, 0.22, 0.26, 1)
    check.inputs["Color2"].default_value = (0.10, 0.12, 0.16, 1)
    links.new(mp.outputs["Vector"], check.inputs["Vector"])
    links.new(check.outputs["Color"], bsdf.inputs["Base Color"])

    # voronoi rivets pattern
    vor = nodes.new("ShaderNodeTexVoronoi"); vor.location = (-700, -100)
    vor.feature = 'F1'
    vor.inputs["Scale"].default_value = 20.0
    links.new(mp.outputs["Vector"], vor.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-450, -100)
    bp.inputs["Strength"].default_value = 0.6
    links.new(vor.outputs["Distance"], bp.inputs["Height"])

    # geometry pointiness AO
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

# ============================================================
# MATERIALS
# ============================================================
mat_grate = make_grate_shader("v3sr_grate")
mat_rack = make_pbr("v3sr_rack", (0.10,0.11,0.13), 0.30, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=30.0)
mat_rack_door = make_pbr("v3sr_rack_door", (0.06,0.08,0.10), 0.40, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=30.0)
mat_led_cyan = make_pbr("v3sr_led_cyan", (0.30,0.85,1.0), 0.10, 0.0,
    emission_color=(0.40,0.95,1.0), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_led_red = make_pbr("v3sr_led_red", (1.0,0.30,0.30), 0.10, 0.0,
    emission_color=(1.0,0.30,0.30), emission_strength=10.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_led_green = make_pbr("v3sr_led_green", (0.30,1.0,0.40), 0.10, 0.0,
    emission_color=(0.30,1.0,0.40), emission_strength=10.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_cable_black = make_pbr("v3sr_cable_b", (0.04,0.04,0.04), 0.45, 0.10,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.20, bump_scale=80.0)
mat_cable_blue = make_pbr("v3sr_cable_bl", (0.10,0.20,0.55), 0.45, 0.0,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.20, bump_scale=80.0)
mat_cable_red = make_pbr("v3sr_cable_r", (0.55,0.10,0.10), 0.45, 0.0,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.20, bump_scale=80.0)
mat_pipe = make_pbr("v3sr_pipe", (0.55,0.58,0.62), 0.30, 0.95,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mat_pipe_rust = make_pbr("v3sr_pipe_rust", (0.45,0.20,0.10), 0.85, 0.40,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.20, bump_scale=30.0)
mat_valve = make_pbr("v3sr_valve", (0.85,0.55,0.18), 0.30, 0.92,
    emission_color=(1.0,0.65,0.20), emission_strength=0.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mat_water_drop = make_pbr("v3sr_drop", (0.15,0.40,0.55), 0.05, 0.0,
    emission_color=(0.30,0.65,0.85), emission_strength=2.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_screen = make_screen_shader("v3sr_screen")
mat_screen_frame = make_pbr("v3sr_scr_frame", (0.05,0.05,0.07), 0.30, 0.95,
    emission_color=(0.30,0.85,1.0), emission_strength=1.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mat_trim = make_pbr("v3sr_trim", (0.30,0.85,1.0), 0.10, 0.0,
    emission_color=(0.30,0.85,1.0), emission_strength=10.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_puddle = make_pbr("v3sr_puddle", (0.05,0.10,0.18), 0.05, 0.50,
    emission_color=(0.20,0.45,0.75), emission_strength=0.6,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05, bump_scale=80.0)
mat_ceiling = make_pbr("v3sr_ceiling", (0.06,0.07,0.09), 0.40, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=30.0)
mat_screw = make_pbr("v3sr_screw", (0.40,0.42,0.45), 0.30, 0.95,
    noise_strength=0.10, curvature_dirt=True)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def box(name, loc, scale, mat, parent, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = scale; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o)
    o.parent = parent
    return o

def cyl(name, loc, r, depth, mat, parent, verts=20, rot=(0,0,0)):
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

def tor(name, loc, R, r, mat, parent, ms=24, mn=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# CORRIDOR LAYOUT
# ============================================================
parent = bpy.data.objects.new("v3_server_room", None); scene.collection.objects.link(parent)

CORRIDOR_LEN = 16  # along Y
CORRIDOR_WID = 5   # along X
CEIL_H = 4.0

# Floor
box("floor", (0, 0, 0), (CORRIDOR_WID, CORRIDOR_LEN, 0.05), mat_grate, parent)
# subtle puddle
box("puddle", (0, 2, 0.03), (1.6, 1.0, 0.005), mat_puddle, parent)

# Ceiling
box("ceiling", (0, 0, CEIL_H), (CORRIDOR_WID, CORRIDOR_LEN, 0.05), mat_ceiling, parent)
# floor trim runners (cyan emissive)
box("trim_l", (-CORRIDOR_WID/2 + 0.1, 0, 0.06), (0.04, CORRIDOR_LEN, 0.02), mat_trim, parent)
box("trim_r", ( CORRIDOR_WID/2 - 0.1, 0, 0.06), (0.04, CORRIDOR_LEN, 0.02), mat_trim, parent)
# ceiling trim runners
box("ctrim_l", (-CORRIDOR_WID/2 + 0.1, 0, CEIL_H - 0.06), (0.04, CORRIDOR_LEN, 0.02), mat_trim, parent)
box("ctrim_r", ( CORRIDOR_WID/2 - 0.1, 0, CEIL_H - 0.06), (0.04, CORRIDOR_LEN, 0.02), mat_trim, parent)

# ============================================================
# SERVER RACKS — 4 per side, 8 total
# ============================================================
def build_server_rack(name, loc, side, parent):
    """side = -1 for left wall, +1 for right wall."""
    rx, ry, rz = loc
    rack_w = 1.6  # along Y
    rack_h = 3.6  # along Z
    rack_d = 0.7  # along X (depth into wall)

    # Body (cabinet)
    body = box(f"{name}_body", (rx, ry, rz + rack_h/2 + 0.1), (rack_d, rack_w, rack_h), mat_rack, parent)
    # Door (slightly inset, separate so we can light it)
    door_x = rx - side * (rack_d/2 + 0.01)
    door = box(f"{name}_door", (door_x, ry, rz + rack_h/2 + 0.1), (0.04, rack_w*0.92, rack_h*0.92), mat_rack_door, parent)
    # Vent slits — 6 horizontal slits across door
    for i in range(6):
        z = rz + 0.4 + i * 0.50
        box(f"{name}_vent_{i}", (door_x - side*0.02, ry, z), (0.005, rack_w*0.6, 0.05), mat_rack_door, parent)
    # 12 LED bay lights — top portion of door
    for i in range(12):
        z = rz + 2.4 + (i // 4) * 0.18
        col = i % 4
        x_off = (col - 1.5) * 0.18
        led_color = mat_led_cyan if i % 3 != 0 else (mat_led_red if i % 5 == 0 else mat_led_green)
        sph(f"{name}_led_{i}", (door_x - side*0.04, ry + x_off, z), 0.025, led_color, parent)
    # 8 cable ports — bottom portion
    for i in range(8):
        x_off = (i - 3.5) * 0.16
        cyl(f"{name}_port_{i}", (door_x - side*0.03, ry + x_off, rz + 0.55),
            0.04, 0.06, mat_rack_door, parent, verts=10, rot=(0, math.pi/2, 0))
        sph(f"{name}_pin_{i}", (door_x - side*0.06, ry + x_off, rz + 0.55), 0.020, mat_led_cyan, parent)
    # Floor screws (4 corners)
    for cx in [-1, 1]:
        for cy in [-1, 1]:
            sph(f"{name}_sc_{cx}_{cy}", (rx + cx * rack_d * 0.45, ry + cy * rack_w * 0.45, rz + 0.10), 0.025, mat_screw, parent)
    return body

# Build 4 racks per side
RACK_POS_Y = [-6.4, -2.4, 1.6, 5.6]
for i, ry in enumerate(RACK_POS_Y):
    build_server_rack(f"rack_L_{i}", (-CORRIDOR_WID/2 - 0.35, ry, 0), -1, parent)
    build_server_rack(f"rack_R_{i}", ( CORRIDOR_WID/2 + 0.35, ry, 0),  1, parent)

# ============================================================
# WALL SCREENS — 4 large screens (2 per side, between racks)
# ============================================================
def build_screen(name, loc, side, parent):
    sx, sy, sz = loc
    # Frame
    frame = box(f"{name}_frame", (sx, sy, sz), (0.08, 1.0, 0.7), mat_screen_frame, parent)
    # Screen surface
    screen = box(f"{name}_scr", (sx - side*0.05, sy, sz), (0.02, 0.92, 0.62), mat_screen, parent)
    # Mount bracket
    cyl(f"{name}_mt1", (sx + side*0.05, sy + 0.4, sz - 0.30), 0.03, 0.20, mat_rack, parent, verts=8, rot=(math.pi/2, 0, 0))
    cyl(f"{name}_mt2", (sx + side*0.05, sy - 0.4, sz - 0.30), 0.03, 0.20, mat_rack, parent, verts=8, rot=(math.pi/2, 0, 0))

build_screen("scr_L_0", (-CORRIDOR_WID/2 - 0.10, -4.4, 2.0), -1, parent)
build_screen("scr_L_1", (-CORRIDOR_WID/2 - 0.10,  3.6, 2.0), -1, parent)
build_screen("scr_R_0", ( CORRIDOR_WID/2 + 0.10, -4.4, 2.0),  1, parent)
build_screen("scr_R_1", ( CORRIDOR_WID/2 + 0.10,  3.6, 2.0),  1, parent)

# ============================================================
# CEILING PIPES — 3 parallel pipes running corridor length + valves + drips
# ============================================================
for i, x in enumerate([-1.2, 0, 1.2]):
    pipe_mat = mat_pipe if i != 1 else mat_pipe_rust
    cyl(f"pipe_{i}", (x, 0, CEIL_H - 0.18), 0.10, CORRIDOR_LEN, pipe_mat, parent, verts=20, rot=(math.pi/2, 0, 0))
    # 3 valves along each pipe
    for j, vy in enumerate([-5.0, 0.0, 5.0]):
        cyl(f"v_{i}_{j}_b", (x, vy, CEIL_H - 0.18), 0.13, 0.10, mat_pipe, parent, verts=14)
        # valve wheel
        tor(f"v_{i}_{j}_w", (x, vy, CEIL_H - 0.05), 0.14, 0.02, mat_valve, parent, ms=18, mn=8)
        for sp in range(4):
            ang = sp * math.pi/2
            box(f"v_{i}_{j}_sp_{sp}", (x + math.cos(ang)*0.10, vy + math.sin(ang)*0.10, CEIL_H - 0.05), (0.18, 0.02, 0.02), mat_valve, parent, rot=(0, 0, ang))
    # condensation drips beneath pipe
    for j, dy in enumerate([-3.5, -1.0, 2.0, 4.5]):
        sph(f"d_{i}_{j}", (x, dy, CEIL_H - 0.32), 0.04, mat_water_drop, parent, segs=12)

# ============================================================
# CABLE BUNDLES — 4 anchor bundles ceiling-to-rack
# ============================================================
def cable_drop(name, x_top, y, x_bot, parent):
    # Each bundle is 5 colored cables hanging in a rough drape
    for i in range(5):
        offset = (i - 2) * 0.025
        mat = [mat_cable_black, mat_cable_blue, mat_cable_red, mat_cable_black, mat_cable_blue][i]
        # Top stub
        cyl(f"{name}_t{i}", (x_top + offset, y, CEIL_H - 0.36), 0.018, 0.20, mat, parent, verts=8)
        # Hanging segment (slight angle)
        mid_x = (x_top + x_bot)/2 + offset
        mid_z = CEIL_H/2 + 0.4
        cyl(f"{name}_m{i}", (mid_x, y, mid_z), 0.018, 2.0, mat, parent, verts=8, rot=(0, math.atan2(x_top-x_bot, CEIL_H-1.5), 0))
        # Bottom stub into rack
        cyl(f"{name}_b{i}", (x_bot + offset, y, 1.5), 0.018, 0.30, mat, parent, verts=8)

cable_drop("cb_L0", -1.0, -5.0, -CORRIDOR_WID/2 + 0.4, parent)
cable_drop("cb_L1", -0.8,  3.5, -CORRIDOR_WID/2 + 0.4, parent)
cable_drop("cb_R0",  1.0, -5.0,  CORRIDOR_WID/2 - 0.4, parent)
cable_drop("cb_R1",  0.8,  3.5,  CORRIDOR_WID/2 - 0.4, parent)

# ============================================================
# LIGHTING
# ============================================================
# Main spot from ceiling at far end (acts as backlight bringing volumetric haze)
bpy.ops.object.light_add(type='SPOT', location=(0, 7, CEIL_H - 0.3))
sp = bpy.context.object
sp.data.energy = 4500; sp.data.color = (0.40, 0.85, 1.0)
sp.data.spot_size = math.radians(80)
sp.rotation_euler = (math.pi, 0, 0)

# Front fill
bpy.ops.object.light_add(type='AREA', location=(0, -7, 2.5))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.25, 0.55, 0.85); fill.data.size = 4

# Side accent — left rim
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

cam_main   = add_cam("cam_corridor", Vector((0, -8.5, 1.7)), Vector((0, 6, 1.5)), lens=32, dof_dist=12)
cam_rack   = add_cam("cam_rack",     Vector((1.2, -3.0, 1.6)), Vector((-2.4, -2.4, 1.6)), lens=50, dof_dist=4)
cam_ceil   = add_cam("cam_ceiling",  Vector((0, -3, 1.5)),    Vector((0, 0, CEIL_H - 0.5)), lens=24, dof_dist=4)

CAMERAS = [
    ("corridor", cam_main, (1920, 1080)),
    ("rack",     cam_rack, (1280, 960)),
    ("ceiling",  cam_ceil, (1280, 960)),
]

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam, (w, h) in CAMERAS:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_server_room_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
out_path = os.path.join(EXPORT_DIR, "server_room_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Epic 13 Server Room Biome complete ===")
