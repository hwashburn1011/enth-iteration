"""
Expansion V3 — ROUND 2 — Epic R2-19 — New Enemy Refinement
==========================================================
Round 2 of V3-20 New Enemies. 4 most distinctive error daemons rebuilt
with Round 2 stack (UV unwrap + vertex color paint + multires + 5-seg
bevel + vertex-color-aware shaders).

Enemies:
  CRASH DAEMON     — horned shadow daemon w/ red glow + jagged spikes
  NULL POINTER     — void sphere w/ orbiting null arrow + dark fresnel
  BUFFER OVERFLOW  — bloated metal cube enemy bursting w/ glow seams
  EXCEPTION        — flying error glyph w/ thrown debug stack pages

Outputs: 5 hero renders @ 1920x1080 + 4 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(119)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/v3_r2_new_enemies.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/exports"
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

scene.world = bpy.data.worlds.new("v3r2ne_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.03, 0.03, 0.05, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# REFINED VC-AWARE ARCH SHADER
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
mats["daemon_skin"] = make_arch("v3r2ne_daemon", (0.10, 0.04, 0.04), (0.18, 0.08, 0.08),
                                  roughness=0.55, metallic=0.20, voronoi_scale=10.0, bump_strength=0.30,
                                  emission_color=(1.0, 0.30, 0.10), emission_strength=0.6)
mats["void"]        = make_arch("v3r2ne_void", (0.02, 0.02, 0.04), (0.06, 0.04, 0.10),
                                  roughness=0.20, metallic=0.30, voronoi_scale=22.0, bump_strength=0.10,
                                  emission_color=(0.45, 0.20, 0.85), emission_strength=0.4)
mats["buffer_metal"] = make_arch("v3r2ne_buffer", (0.30, 0.32, 0.38), (0.42, 0.45, 0.52),
                                   roughness=0.30, metallic=0.85, voronoi_scale=22.0, bump_strength=0.10,
                                   emission_color=(1.0, 0.80, 0.30), emission_strength=0.6)
mats["except_glyph"] = make_arch("v3r2ne_except", (0.45, 0.10, 0.10), (0.58, 0.18, 0.15),
                                   roughness=0.30, metallic=0.40, voronoi_scale=14.0, bump_strength=0.20,
                                   emission_color=(1.0, 0.30, 0.10), emission_strength=4.0)
mats["except_paper"] = make_simple("v3r2ne_paper", (0.92, 0.86, 0.72), 0.85, 0,
                                     em=(1.0, 0.85, 0.45), em_str=0.4)

mats["eye_red"]    = make_emit("v3r2ne_eye_r", (1.0, 0.20, 0.10), 16.0)
mats["eye_white"]  = make_emit("v3r2ne_eye_w", (0.95, 0.95, 1.0), 14.0)
mats["eye_purple"] = make_emit("v3r2ne_eye_p", (0.65, 0.20, 0.95), 14.0)
mats["eye_cyan"]   = make_emit("v3r2ne_eye_c", (0.30, 0.85, 1.0), 14.0)
mats["floor"]      = make_simple("v3r2ne_floor", (0.06, 0.06, 0.08), 0.30, 0.20)

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

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=20, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=12, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cone_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_box(name, loc, scale, mat, parent, vc_red=0.5, vc_var=0.4, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cube_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     size=1, location=loc)
    o.scale = scale
    o.rotation_euler = rot
    return o

def r_torus(name, loc, R, r, mat, parent, vc_red=0.5, vc_var=0.4, ms=20, mn=10, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_torus_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     major_segments=ms, minor_segments=mn,
                     major_radius=R, minor_radius=r, location=loc)
    o.rotation_euler = rot
    return o

# ============================================================
# 1. CRASH DAEMON
# ============================================================
def build_crash_daemon(origin):
    p = bpy.data.objects.new("v3r2_crash_daemon", None); scene.collection.objects.link(p); p.location = origin
    body = r_sphere("cd_body", (0, 0, 0.85), 0.45, mats["daemon_skin"], p,
                     vc_red=0.55, vc_var=0.30, segs=24)
    body.scale = (1.0, 0.85, 1.2)
    r_sphere("cd_sh_l", (-0.40, 0, 1.10), 0.18, mats["daemon_skin"], p,
              vc_red=0.55, vc_var=0.30)
    r_sphere("cd_sh_r", (0.40, 0, 1.10), 0.18, mats["daemon_skin"], p,
              vc_red=0.55, vc_var=0.30)
    head = r_sphere("cd_head", (0, 0.05, 1.40), 0.26, mats["daemon_skin"], p,
                     vc_red=0.55, vc_var=0.30)
    head.scale = (1.0, 0.95, 1.1)
    # Two large curved horns
    r_cone("cd_horn_l", (-0.18, 0.05, 1.65), 0.06, 0.0, 0.55, mats["daemon_skin"], p,
            vc_red=0.55, vc_var=0.30, verts=10, rot=(-0.4, -0.5, 0))
    r_cone("cd_horn_r", (0.18, 0.05, 1.65), 0.06, 0.0, 0.55, mats["daemon_skin"], p,
            vc_red=0.55, vc_var=0.30, verts=10, rot=(-0.4, 0.5, 0))
    r_sphere("cd_eye_l", (-0.12, 0.20, 1.42), 0.05, mats["eye_red"], p, segs=12)
    r_sphere("cd_eye_r", (0.12, 0.20, 1.42), 0.05, mats["eye_red"], p, segs=12)
    # Jaw spikes
    for i, ang in enumerate([-0.5, -0.15, 0.15, 0.5]):
        r_cone(f"cd_jaw_{i}", (math.sin(ang)*0.18, 0.18, 1.28), 0.025, 0.0, 0.10, mats["daemon_skin"], p,
                vc_red=0.55, vc_var=0.30, verts=6, rot=(0.6, 0, ang))
    # Arms + claws
    r_cyl("cd_arm_l", (-0.50, 0, 0.70), 0.10, 0.6, mats["daemon_skin"], p,
           vc_red=0.55, vc_var=0.30, verts=10, rot=(0, 0.2, 0))
    r_cyl("cd_arm_r", (0.50, 0, 0.70), 0.10, 0.6, mats["daemon_skin"], p,
           vc_red=0.55, vc_var=0.30, verts=10, rot=(0, -0.2, 0))
    for i, side in enumerate([-1, 1]):
        for j in range(3):
            r_cone(f"cd_claw_{i}_{j}", (side*0.55, -0.08 + j*0.08, 0.40), 0.025, 0.0, 0.18,
                    mats["daemon_skin"], p, vc_red=0.55, vc_var=0.30, verts=6, rot=(0.6, 0, 0))
    # Back spikes
    for i in range(5):
        z = 0.95 + i * 0.12
        r_cone(f"cd_bspike_{i}", (0, -0.30, z), 0.05, 0.0, 0.20, mats["daemon_skin"], p,
                vc_red=0.55, vc_var=0.30, verts=6, rot=(0.7, 0, 0))
    # Legs
    r_cyl("cd_leg_l", (-0.18, 0, 0.20), 0.12, 0.5, mats["daemon_skin"], p,
           vc_red=0.55, vc_var=0.30, verts=10)
    r_cyl("cd_leg_r", (0.18, 0, 0.20), 0.12, 0.5, mats["daemon_skin"], p,
           vc_red=0.55, vc_var=0.30, verts=10)
    # Heart core glow
    r_sphere("cd_heart", (0, 0.30, 0.85), 0.10, mats["eye_red"], p, segs=14)
    return p

# ============================================================
# 2. NULL POINTER
# ============================================================
def build_null_pointer(origin):
    p = bpy.data.objects.new("v3r2_null_pointer", None); scene.collection.objects.link(p); p.location = origin
    body = r_sphere("np_body", (0, 0, 0.85), 0.50, mats["void"], p,
                     vc_red=0.55, vc_var=0.30, segs=28)
    r_sphere("np_core", (0, 0, 0.85), 0.20, mats["eye_purple"], p, segs=16)
    # 3 perpendicular orbital rings
    r_torus("np_r1", (0, 0, 0.85), 0.65, 0.025, mats["void"], p, ms=32, mn=8)
    r_torus("np_r2", (0, 0, 0.85), 0.62, 0.025, mats["void"], p, ms=32, mn=8, rot=(math.pi/3, 0, 0))
    r_torus("np_r3", (0, 0, 0.85), 0.65, 0.025, mats["void"], p, ms=32, mn=8, rot=(0, math.pi/3, 0))
    # Floating null arrow
    r_cyl("np_arr_shaft", (0, 0.85, 0.85), 0.04, 0.30, mats["eye_purple"], p, verts=10,
           rot=(0, math.pi/2, 0))
    r_cone("np_arr_head", (0.20, 0.85, 0.85), 0.10, 0.0, 0.18, mats["eye_purple"], p, verts=10,
            rot=(0, math.pi/2, 0))
    # 4 floating shadow particles
    for i in range(4):
        ang = i * math.pi/2
        r_sphere(f"np_p_{i}", (math.cos(ang)*0.85, math.sin(ang)*0.85, 1.15), 0.05,
                  mats["void"], p, vc_red=0.55, vc_var=0.30, segs=10)
    # Anchor base
    r_cyl("np_base", (0, 0, 0.05), 0.45, 0.10, mats["void"], p,
           vc_red=0.55, vc_var=0.30, verts=24)
    return p

# ============================================================
# 3. BUFFER OVERFLOW
# ============================================================
def build_buffer_overflow(origin):
    p = bpy.data.objects.new("v3r2_buffer_overflow", None); scene.collection.objects.link(p); p.location = origin
    body = r_sphere("bo_body", (0, 0, 0.85), 0.60, mats["buffer_metal"], p,
                     vc_red=0.55, vc_var=0.30, segs=28)
    body.scale = (1.1, 1.1, 0.9)
    # 8 burst seam strips
    for i in range(8):
        ang = i * (math.pi*2/8)
        sx = math.cos(ang) * 0.62
        sy = math.sin(ang) * 0.62
        r_cyl(f"bo_seam_{i}", (sx, sy, 0.85), 0.025, 0.30, mats["buffer_metal"], p,
               verts=8, rot=(0, math.pi/2, ang))
        r_cyl(f"bo_seam_g_{i}", (sx, sy, 0.85), 0.030, 0.32, mats["eye_cyan"], p,
               verts=8, rot=(0, math.pi/2, ang))
    # 6 chunks bursting outward
    for i in range(6):
        ang = i * (math.pi*2/6)
        cx = math.cos(ang) * 0.95
        cy = math.sin(ang) * 0.95
        cz = 0.85 + math.sin(i*1.5) * 0.30
        r_box(f"bo_chunk_{i}", (cx, cy, cz), (0.18, 0.18, 0.18), mats["buffer_metal"], p,
               vc_red=0.55, vc_var=0.30, rot=(ang, ang*0.5, ang*0.3))
    # Top droplet eruption
    for i in range(5):
        z = 1.50 + i * 0.18
        sx = (i - 2) * 0.05
        r_sphere(f"bo_drop_{i}", (sx, 0, z), 0.08, mats["eye_cyan"], p, segs=12)
    # Angry red eyes
    r_sphere("bo_eye_l", (-0.15, 0.55, 1.0), 0.08, mats["eye_red"], p, segs=12)
    r_sphere("bo_eye_r", (0.15, 0.55, 1.0), 0.08, mats["eye_red"], p, segs=12)
    return p

# ============================================================
# 4. EXCEPTION
# ============================================================
def build_exception(origin):
    p = bpy.data.objects.new("v3r2_exception", None); scene.collection.objects.link(p); p.location = origin
    # Diamond glyph (rotated cube)
    glyph = r_box("ex_glyph", (0, 0, 1.30), (0.50, 0.50, 0.10), mats["except_glyph"], p,
                   vc_red=0.55, vc_var=0.20, rot=(0, 0, math.pi/4))
    # Exclamation mark inside
    r_box("ex_excl_b", (0, 0.05, 1.32), (0.06, 0.04, 0.20), mats["eye_white"], p)
    r_sphere("ex_excl_d", (0, 0.05, 1.10), 0.06, mats["eye_white"], p, segs=10)
    # 4 corner spikes radiating
    for i in range(4):
        ang = i * math.pi/2
        sx = math.cos(ang) * 0.6
        sz = 1.30 + math.sin(ang) * 0.6
        r_cone(f"ex_spike_{i}", (sx, 0, sz), 0.06, 0.0, 0.20, mats["except_glyph"], p,
                vc_red=0.55, vc_var=0.20, verts=6, rot=(0, math.pi/2 + ang, 0))
    # 8 thrown debug stack pages
    for i in range(8):
        ang = i * (math.pi*2/8)
        px = math.cos(ang) * 0.95
        py = math.sin(ang) * 0.95
        pz = 1.30 + math.sin(i*0.7) * 0.40
        r_box(f"ex_page_{i}", (px, py, pz), (0.20, 0.15, 0.01), mats["except_paper"], p,
               vc_red=0.55, vc_var=0.30,
               rot=(random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5),
                     ang + random.uniform(-0.5, 0.5)))
    # Anchor base
    r_sphere("ex_anchor", (0, 0, 0.30), 0.30, mats["except_glyph"], p,
              vc_red=0.55, vc_var=0.20, segs=18)
    r_cyl("ex_stem", (0, 0, 0.85), 0.05, 0.50, mats["except_glyph"], p,
           vc_red=0.55, vc_var=0.20, verts=10)
    return p

# ============================================================
# LAYOUT
# ============================================================
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "ne_floor"; fl.scale = (12, 4, 0.10)
fl.data.materials.append(mats["floor"])
bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in fl.data.polygons: poly.use_smooth = True

ENEMIES = [
    ("crash_daemon",     build_crash_daemon,    Vector((-4.5, 0, 0))),
    ("null_pointer",     build_null_pointer,    Vector((-1.5, 0, 0))),
    ("buffer_overflow",  build_buffer_overflow, Vector(( 1.5, 0, 0))),
    ("exception",        build_exception,       Vector(( 4.5, 0, 0))),
]

ENEMY_OBJS = []
for name, builder, origin in ENEMIES:
    obj = builder(origin)
    ENEMY_OBJS.append((name, obj, origin))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 1800; key.data.color = (1.0, 0.92, 0.78); key.data.size = 10

bpy.ops.object.light_add(type='AREA', location=(-8, 8, 10))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 10

bpy.ops.object.light_add(type='AREA', location=(0, 8, 4))
rim = bpy.context.object
rim.data.energy = 500; rim.data.color = (1.0, 0.75, 0.45); rim.data.size = 8

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.5
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_group = add_cam("cam_group", Vector((0, -8, 3.0)), Vector((0, 0, 1.0)), lens=32, dof_dist=10)
PORTRAIT_CAMS = []
for name, _, origin in ENEMIES:
    cam = add_cam(f"cam_{name}", Vector((origin.x, origin.y - 2.5, 1.3)),
                   Vector((origin.x, origin.y, 0.9)), lens=85, dof_dist=2.5)
    PORTRAIT_CAMS.append((name, cam))

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render group + portraits
scene.camera = cam_group
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r2_new_enemies_group.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

for name, cam in PORTRAIT_CAMS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_new_enemy_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-enemy GLBs
for name, obj, _ in ENEMY_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"v3r2_new_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )
    print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-19 New Enemy Refinement complete ===")
