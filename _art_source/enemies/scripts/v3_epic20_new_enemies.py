"""
Expansion V3 — Epic 20 — New Enemy Texture Pass
================================================
8 brand-new error-themed enemies with bespoke silhouettes and shaders:

  1. CRASH DAEMON   — horned shadow daemon w/ red glow + jagged spikes
  2. NULL POINTER   — void sphere w/ orbiting null arrow + dark fresnel
  3. STACK OVERFLOW — totem of stacked debug frames overflowing the top
  4. BUFFER OVERFLOW — bloated cube enemy bursting at the seams w/ glow
  5. RACE CONDITION  — twin runner ghosts in sync, blue/red trails
  6. SEGFAULT       — fragmented broken stone golem w/ glitch shards
  7. DEADLOCK       — two skull enemies chained back-to-back, frozen
  8. EXCEPTION      — flying error glyph w/ thrown debug stack pages

Outputs: 1 group hero @ 1920x1080 + 8 portraits @ 1024x1024 + 8 GLBs.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(20)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/v3_new_enemies.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/exports"
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

scene.world = bpy.data.worlds.new("v3_ne_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.03, 0.03, 0.05, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# SHADER HELPER (V3 5-layer)
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

def make_emit(name, color, strength):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (*color, 1)
    bs.inputs["Emission Strength"].default_value = strength
    return m

# ============================================================
# MATERIALS
# ============================================================
mats = {}
mats["daemon_skin"] = make_pbr("v3ne_daemon", (0.10,0.04,0.04), 0.55, 0.20,
    emission_color=(1.0,0.30,0.10), emission_strength=0.6,
    noise_strength=0.30, voronoi_strength=0.50, voronoi_scale=10.0,
    curvature_dirt=True, fresnel_rim=True, bump_strength=0.30, bump_scale=18.0)
mats["void"] = make_pbr("v3ne_void", (0.02,0.02,0.04), 0.20, 0.30,
    emission_color=(0.45,0.20,0.85), emission_strength=0.4,
    noise_strength=0.15, curvature_dirt=True, fresnel_rim=True)
mats["debug_frame"] = make_pbr("v3ne_debug", (0.20,0.20,0.25), 0.35, 0.65,
    emission_color=(0.30,0.85,1.0), emission_strength=1.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True, bump_strength=0.10)
mats["buffer_metal"] = make_pbr("v3ne_buffer", (0.30,0.32,0.38), 0.30, 0.85,
    emission_color=(1.0,0.80,0.30), emission_strength=0.6,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["race_blue"] = make_pbr("v3ne_race_b", (0.10,0.30,0.85), 0.20, 0.50,
    emission_color=(0.30,0.55,1.0), emission_strength=2.0,
    noise_strength=0.10, curvature_dirt=False, fresnel_rim=True)
mats["race_red"] = make_pbr("v3ne_race_r", (0.85,0.10,0.30), 0.20, 0.50,
    emission_color=(1.0,0.30,0.55), emission_strength=2.0,
    noise_strength=0.10, curvature_dirt=False, fresnel_rim=True)
mats["seg_stone"] = make_pbr("v3ne_seg", (0.42,0.40,0.36), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=10.0,
    curvature_dirt=True, bump_strength=0.40, bump_scale=14.0)
mats["seg_glitch"] = make_pbr("v3ne_seg_glitch", (0.10,0.85,1.0), 0.10,
    emission_color=(0.30,1.0,0.95), emission_strength=8.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["dead_bone"] = make_pbr("v3ne_bone", (0.78,0.72,0.62), 0.85,
    noise_strength=0.20, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=80.0)
mats["dead_chain"] = make_pbr("v3ne_chain", (0.10,0.10,0.12), 0.55, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.20, bump_scale=40.0)
mats["except_glyph"] = make_pbr("v3ne_except", (0.45,0.10,0.10), 0.30, 0.40,
    emission_color=(1.0,0.30,0.10), emission_strength=4.0,
    noise_strength=0.15, curvature_dirt=True, fresnel_rim=True)
mats["except_paper"] = make_pbr("v3ne_paper", (0.92,0.86,0.72), 0.85,
    emission_color=(1.0,0.85,0.45), emission_strength=0.4,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=80.0)

mats["eye_red"]   = make_emit("v3ne_eye_r", (1.0,0.20,0.10), 16.0)
mats["eye_white"] = make_emit("v3ne_eye_w", (0.95,0.95,1.0), 14.0)
mats["eye_purple"]= make_emit("v3ne_eye_p", (0.65,0.20,0.95), 14.0)
mats["eye_cyan"]  = make_emit("v3ne_eye_c", (0.30,0.85,1.0), 14.0)
mats["floor"]     = make_pbr("v3ne_floor", (0.06,0.06,0.08), 0.30, 0.20,
                              noise_strength=0.10, curvature_dirt=True, bump_strength=0.05)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def sph(name, loc, r, mat, parent, segs=20):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cyl(name, loc, r, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def box(name, loc, scale, mat, parent, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = scale; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=20, mn=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# 1. CRASH DAEMON
# ============================================================
def build_crash_daemon(origin):
    p = bpy.data.objects.new("v3_crash_daemon", None); scene.collection.objects.link(p); p.location = origin
    # Body — torso block
    body = sph("cd_body", (0, 0, 0.85), 0.45, mats["daemon_skin"], p, segs=24)
    body.scale = (1.0, 0.85, 1.2)
    # Hunched shoulders
    sph("cd_sh_l", (-0.40, 0, 1.10), 0.18, mats["daemon_skin"], p, segs=14)
    sph("cd_sh_r", (0.40, 0, 1.10), 0.18, mats["daemon_skin"], p, segs=14)
    # Head with horns
    head = sph("cd_head", (0, 0.05, 1.40), 0.26, mats["daemon_skin"], p, segs=20)
    head.scale = (1.0, 0.95, 1.1)
    # Two large curved horns
    cone("cd_horn_l", (-0.18, 0.05, 1.65), 0.06, 0.0, 0.55, mats["daemon_skin"], p, verts=10, rot=(-0.4, -0.5, 0))
    cone("cd_horn_r", (0.18, 0.05, 1.65), 0.06, 0.0, 0.55, mats["daemon_skin"], p, verts=10, rot=(-0.4, 0.5, 0))
    # Glowing red eyes
    sph("cd_eye_l", (-0.12, 0.20, 1.42), 0.05, mats["eye_red"], p, segs=12)
    sph("cd_eye_r", (0.12, 0.20, 1.42), 0.05, mats["eye_red"], p, segs=12)
    # Jaw spikes (4)
    for i, ang in enumerate([-0.5, -0.15, 0.15, 0.5]):
        cone(f"cd_jaw_{i}", (math.sin(ang)*0.18, 0.18, 1.28), 0.025, 0.0, 0.10, mats["daemon_skin"], p, verts=6, rot=(0.6, 0, ang))
    # Arms ending in claws
    cyl("cd_arm_l", (-0.50, 0, 0.70), 0.10, 0.6, mats["daemon_skin"], p, verts=10, rot=(0, 0.2, 0))
    cyl("cd_arm_r", (0.50, 0, 0.70), 0.10, 0.6, mats["daemon_skin"], p, verts=10, rot=(0, -0.2, 0))
    for i, side in enumerate([-1, 1]):
        for j in range(3):
            cone(f"cd_claw_{i}_{j}", (side*0.55, -0.08 + j*0.08, 0.40), 0.025, 0.0, 0.18, mats["daemon_skin"], p, verts=6, rot=(0.6, 0, 0))
    # Back spikes (5 along spine)
    for i in range(5):
        z = 0.95 + i * 0.12
        cone(f"cd_bspike_{i}", (0, -0.30, z), 0.05, 0.0, 0.20, mats["daemon_skin"], p, verts=6, rot=(0.7, 0, 0))
    # Legs
    cyl("cd_leg_l", (-0.18, 0, 0.20), 0.12, 0.5, mats["daemon_skin"], p, verts=10)
    cyl("cd_leg_r", (0.18, 0, 0.20), 0.12, 0.5, mats["daemon_skin"], p, verts=10)
    # Heart core glow visible through chest
    sph("cd_heart", (0, 0.30, 0.85), 0.10, mats["eye_red"], p, segs=14)
    return p

# ============================================================
# 2. NULL POINTER
# ============================================================
def build_null_pointer(origin):
    p = bpy.data.objects.new("v3_null_pointer", None); scene.collection.objects.link(p); p.location = origin
    # Central void sphere
    body = sph("np_body", (0, 0, 0.85), 0.50, mats["void"], p, segs=28)
    # Inner darker core
    sph("np_core", (0, 0, 0.85), 0.20, mats["eye_purple"], p, segs=16)
    # Orbiting void rings (3 torus at different angles)
    tor("np_r1", (0, 0, 0.85), 0.65, 0.025, mats["void"], p, ms=32, mn=8)
    tor("np_r2", (0, 0, 0.85), 0.62, 0.025, mats["void"], p, ms=32, mn=8, rot=(math.pi/3, 0, 0))
    tor("np_r3", (0, 0, 0.85), 0.65, 0.025, mats["void"], p, ms=32, mn=8, rot=(0, math.pi/3, 0))
    # Floating null arrow (simple "→" made of cyl + cone)
    cyl("np_arr_shaft", (0, 0.85, 0.85), 0.04, 0.30, mats["eye_purple"], p, verts=10, rot=(0, math.pi/2, 0))
    cone("np_arr_head", (0.20, 0.85, 0.85), 0.10, 0.0, 0.18, mats["eye_purple"], p, verts=10, rot=(0, math.pi/2, 0))
    # 4 floating shadow particles around it
    for i in range(4):
        ang = i * math.pi/2
        sph(f"np_p_{i}", (math.cos(ang)*0.85, math.sin(ang)*0.85, 1.15), 0.05, mats["void"], p, segs=10)
    # Anchor base disc
    cyl("np_base", (0, 0, 0.05), 0.45, 0.10, mats["void"], p, verts=24)
    return p

# ============================================================
# 3. STACK OVERFLOW
# ============================================================
def build_stack_overflow(origin):
    p = bpy.data.objects.new("v3_stack_overflow", None); scene.collection.objects.link(p); p.location = origin
    # Base plate
    box("so_base", (0, 0, 0.05), (0.8, 0.8, 0.10), mats["debug_frame"], p)
    # Stacked frames (8 boxes climbing up + 4 overflowing on top)
    for i in range(12):
        z = 0.20 + i * 0.18
        # Increase shake/offset as we go higher (overflow)
        offset_x = (i * 0.04) if i > 7 else 0
        offset_y = (i * -0.03) if i > 7 else 0
        rot_z = (i * 0.18) if i > 7 else 0
        scale = 0.7 - i * 0.02
        if i > 7:
            scale = 0.55
        box(f"so_frame_{i}", (offset_x, offset_y, z), (scale, scale, 0.16), mats["debug_frame"], p, rot=(0, 0, rot_z))
    # Glowing edge trim on bottom 4 frames
    for i in range(4):
        z = 0.20 + i * 0.18 + 0.08
        tor(f"so_trim_{i}", (0, 0, z), 0.36 - i*0.02, 0.015, mats["eye_cyan"], p, ms=24, mn=6)
    # Top overflow chunks falling/leaning
    for i in range(3):
        ang = i * (math.pi*2/3)
        x = math.cos(ang) * 0.55
        y = math.sin(ang) * 0.55
        z = 2.8 + (i % 2) * 0.1
        b = box(f"so_chunk_{i}", (x, y, z), (0.30, 0.30, 0.10), mats["debug_frame"], p, rot=(ang*0.3, ang*0.2, ang))
    # Top-most error glyph
    sph("so_glyph", (0, 0, 2.65), 0.12, mats["eye_red"], p, segs=14)
    return p

# ============================================================
# 4. BUFFER OVERFLOW
# ============================================================
def build_buffer_overflow(origin):
    p = bpy.data.objects.new("v3_buffer_overflow", None); scene.collection.objects.link(p); p.location = origin
    # Bloated central body — big sphere stretched into a cube-ish shape
    body = sph("bo_body", (0, 0, 0.85), 0.60, mats["buffer_metal"], p, segs=28)
    body.scale = (1.1, 1.1, 0.9)
    # 6 burst seams (cyan-yellow glow strips around body equator)
    for i in range(8):
        ang = i * (math.pi*2/8)
        sx = math.cos(ang) * 0.62
        sy = math.sin(ang) * 0.62
        cyl(f"bo_seam_{i}", (sx, sy, 0.85), 0.025, 0.30, mats["buffer_metal"], p, verts=8, rot=(0, math.pi/2, ang))
        cyl(f"bo_seam_g_{i}", (sx, sy, 0.85), 0.030, 0.32, mats["eye_cyan"], p, verts=8, rot=(0, math.pi/2, ang))
    # 4 chunks bursting outward
    for i in range(6):
        ang = i * (math.pi*2/6)
        cx = math.cos(ang) * 0.95
        cy = math.sin(ang) * 0.95
        cz = 0.85 + math.sin(i*1.5) * 0.30
        b = box(f"bo_chunk_{i}", (cx, cy, cz), (0.18, 0.18, 0.18), mats["buffer_metal"], p, rot=(ang, ang*0.5, ang*0.3))
    # Top "memory leak" droplet eruption
    for i in range(5):
        z = 1.50 + i * 0.18
        sx = (i - 2) * 0.05
        sph(f"bo_drop_{i}", (sx, 0, z), 0.08, mats["eye_cyan"], p, segs=12)
    # 2 angry red eyes
    sph("bo_eye_l", (-0.15, 0.55, 1.0), 0.08, mats["eye_red"], p, segs=12)
    sph("bo_eye_r", (0.15, 0.55, 1.0), 0.08, mats["eye_red"], p, segs=12)
    return p

# ============================================================
# 5. RACE CONDITION
# ============================================================
def build_race_condition(origin):
    p = bpy.data.objects.new("v3_race_condition", None); scene.collection.objects.link(p); p.location = origin
    # Two ghostly runners overlapping (one slightly offset)
    def runner(prefix, x_off, mat):
        # Body
        sph(f"{prefix}_body", (x_off, 0, 0.85), 0.30, mat, p, segs=20)
        # Head
        sph(f"{prefix}_head", (x_off, 0, 1.25), 0.22, mat, p, segs=18)
        # Single eye visor
        cyl(f"{prefix}_eye", (x_off, 0.20, 1.25), 0.10, 0.04, mats["eye_white"], p, verts=14, rot=(math.pi/2, 0, 0))
        # Arms swept back (mid-run)
        cyl(f"{prefix}_arm_l", (x_off-0.18, -0.20, 0.85), 0.06, 0.45, mat, p, verts=8, rot=(0.6, 0, 0))
        cyl(f"{prefix}_arm_r", (x_off+0.18, -0.20, 0.85), 0.06, 0.45, mat, p, verts=8, rot=(0.6, 0, 0))
        # Legs (mid-stride)
        cyl(f"{prefix}_leg_f", (x_off, 0.15, 0.45), 0.08, 0.50, mat, p, verts=10, rot=(-0.3, 0, 0))
        cyl(f"{prefix}_leg_b", (x_off, -0.15, 0.45), 0.08, 0.50, mat, p, verts=10, rot=(0.3, 0, 0))
        # Trail of 3 receding ghost copies behind
        for i in range(3):
            scale = 0.8 - i*0.2
            alpha_z = 0.85
            sph(f"{prefix}_tr_{i}", (x_off, -0.4 - i*0.30, alpha_z), 0.20*scale, mat, p, segs=12)
    runner("rc_a", -0.20, mats["race_blue"])
    runner("rc_b",  0.20, mats["race_red"])
    return p

# ============================================================
# 6. SEGFAULT
# ============================================================
def build_segfault(origin):
    p = bpy.data.objects.new("v3_segfault", None); scene.collection.objects.link(p); p.location = origin
    # Broken stone golem — fragmented body
    # Main torso (broken cube)
    box("sf_torso", (0, 0, 0.85), (0.55, 0.45, 0.65), mats["seg_stone"], p)
    # Floating fragments above and beside (suspended pieces)
    box("sf_f1", (0.40, 0.10, 1.20), (0.20, 0.18, 0.18), mats["seg_stone"], p, rot=(0.3, 0.2, 0.4))
    box("sf_f2", (-0.35, -0.05, 1.10), (0.18, 0.16, 0.16), mats["seg_stone"], p, rot=(-0.2, 0.4, -0.3))
    box("sf_f3", (0.30, -0.20, 0.50), (0.16, 0.14, 0.14), mats["seg_stone"], p, rot=(0.4, -0.3, 0.2))
    # Head — broken sphere with crack visible
    head = sph("sf_head", (0, 0.05, 1.30), 0.25, mats["seg_stone"], p, segs=18)
    # Glitch crack glow strip across torso
    box("sf_crack_t", (0.25, 0.23, 0.85), (0.04, 0.04, 0.40), mats["seg_glitch"], p, rot=(0, 0, 0.3))
    box("sf_crack_h", (0, 0.30, 1.30), (0.04, 0.04, 0.30), mats["seg_glitch"], p, rot=(0, 0, 0.5))
    # Glitch eyes (mismatched height)
    sph("sf_eye_l", (-0.12, 0.27, 1.30), 0.05, mats["seg_glitch"], p, segs=10)
    sph("sf_eye_r", (0.10, 0.25, 1.34), 0.04, mats["seg_glitch"], p, segs=10)
    # Stubby legs
    cyl("sf_leg_l", (-0.18, 0, 0.25), 0.15, 0.50, mats["seg_stone"], p, verts=10)
    cyl("sf_leg_r", (0.18, 0, 0.25), 0.15, 0.50, mats["seg_stone"], p, verts=10)
    # Massive arms
    box("sf_arm_l", (-0.55, 0, 0.85), (0.20, 0.20, 0.50), mats["seg_stone"], p, rot=(0, 0, 0.2))
    box("sf_arm_r", (0.55, 0, 0.85), (0.20, 0.20, 0.50), mats["seg_stone"], p, rot=(0, 0, -0.2))
    # 6 floating glitch shards orbiting
    for i in range(6):
        ang = i * (math.pi*2/6)
        sx = math.cos(ang) * 0.85
        sy = math.sin(ang) * 0.85
        sz = 1.20 + math.sin(i) * 0.20
        b = box(f"sf_shard_{i}", (sx, sy, sz), (0.06, 0.06, 0.18), mats["seg_glitch"], p, rot=(ang, ang*0.5, ang*0.3))
    return p

# ============================================================
# 7. DEADLOCK
# ============================================================
def build_deadlock(origin):
    p = bpy.data.objects.new("v3_deadlock", None); scene.collection.objects.link(p); p.location = origin
    # Two skull bodies back-to-back (north + south)
    def skull(prefix, y_off, eye_dir):
        sph(f"{prefix}_skull", (0, y_off, 1.05), 0.30, mats["dead_bone"], p, segs=20)
        # Eye sockets — recessed orbs with red glow
        sph(f"{prefix}_eye_l", (-0.10, y_off + 0.20*eye_dir, 1.10), 0.05, mats["eye_red"], p, segs=10)
        sph(f"{prefix}_eye_r", (0.10, y_off + 0.20*eye_dir, 1.10), 0.05, mats["eye_red"], p, segs=10)
        # Lower jaw
        box(f"{prefix}_jaw", (0, y_off + 0.10*eye_dir, 0.85), (0.30, 0.20, 0.10), mats["dead_bone"], p)
        # Body (hooded torso)
        body = sph(f"{prefix}_body", (0, y_off, 0.55), 0.40, mats["dead_bone"], p, segs=18)
        body.scale = (1.0, 1.0, 1.4)
    skull("dl_n",  0.20,  1)
    skull("dl_s", -0.20, -1)
    # Chains binding them together (4 chain torus loops at different heights)
    for i, z in enumerate([0.55, 0.85, 1.15]):
        for j in range(8):
            ang = j * math.pi/4
            cx = math.cos(ang) * 0.45
            cy = math.sin(ang) * 0.10
            tor(f"dl_ch_{i}_{j}", (cx, cy, z), 0.05, 0.012, mats["dead_chain"], p, ms=12, mn=6, rot=(0, j*0.4, 0))
    # Big central shackle
    tor("dl_shack", (0, 0, 0.85), 0.50, 0.05, mats["dead_chain"], p, ms=24, mn=10, rot=(math.pi/2, 0, 0))
    # Lock at front
    box("dl_lock_b", (0, 0.55, 0.85), (0.18, 0.10, 0.20), mats["dead_chain"], p)
    cyl("dl_lock_h", (0, 0.55, 1.0), 0.06, 0.06, mats["dead_chain"], p, verts=10)
    sph("dl_lock_kh", (0, 0.62, 0.82), 0.025, mats["eye_red"], p, segs=10)
    # Stubby legs at base
    cyl("dl_leg", (0, 0, 0.10), 0.30, 0.20, mats["dead_bone"], p, verts=14)
    return p

# ============================================================
# 8. EXCEPTION
# ============================================================
def build_exception(origin):
    p = bpy.data.objects.new("v3_exception", None); scene.collection.objects.link(p); p.location = origin
    # Central error glyph — diamond shape
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.30))
    glyph = bpy.context.object; glyph.name = "ex_glyph"
    glyph.scale = (0.50, 0.50, 0.10)
    glyph.rotation_euler = (0, 0, math.pi/4)
    glyph.data.materials.append(mats["except_glyph"])
    add_subsurf_bevel(glyph)
    glyph.parent = p
    # Exclamation mark inside
    box("ex_excl_b", (0, 0.05, 1.32), (0.06, 0.04, 0.20), mats["eye_white"], p)
    sph("ex_excl_d", (0, 0.05, 1.10), 0.06, mats["eye_white"], p, segs=10)
    # 4 corner spikes radiating from glyph
    for i in range(4):
        ang = i * math.pi/2
        sx = math.cos(ang) * 0.6
        sz = 1.30 + math.sin(ang) * 0.6
        cone(f"ex_spike_{i}", (sx, 0, sz), 0.06, 0.0, 0.20, mats["except_glyph"], p, verts=6, rot=(0, math.pi/2 + ang, 0))
    # Thrown debug stack pages flying around (8 paper rectangles at angles)
    for i in range(8):
        ang = i * (math.pi*2/8)
        px = math.cos(ang) * 0.95
        py = math.sin(ang) * 0.95
        pz = 1.30 + math.sin(i*0.7) * 0.40
        b = box(f"ex_page_{i}", (px, py, pz), (0.20, 0.15, 0.01), mats["except_paper"], p,
                 rot=(random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5), ang + random.uniform(-0.5, 0.5)))
    # Anchor base sphere (small)
    sph("ex_anchor", (0, 0, 0.30), 0.30, mats["except_glyph"], p, segs=18)
    cyl("ex_stem", (0, 0, 0.85), 0.05, 0.50, mats["except_glyph"], p, verts=10)
    return p

# ============================================================
# LAYOUT — 8 enemies in 4x2 grid on long floor plinth
# ============================================================
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "ne_floor"; fl.scale = (16, 6, 0.10)
fl.data.materials.append(mats["floor"]); add_subsurf_bevel(fl, levels=1, bevel=0.005)

ENEMIES = [
    ("crash_daemon",   build_crash_daemon,    Vector((-6, 1.5, 0))),
    ("null_pointer",   build_null_pointer,    Vector((-2, 1.5, 0))),
    ("stack_overflow", build_stack_overflow,  Vector(( 2, 1.5, 0))),
    ("buffer_overflow",build_buffer_overflow, Vector(( 6, 1.5, 0))),
    ("race_condition", build_race_condition,  Vector((-6, -1.5, 0))),
    ("segfault",       build_segfault,        Vector((-2, -1.5, 0))),
    ("deadlock",       build_deadlock,        Vector(( 2, -1.5, 0))),
    ("exception",      build_exception,       Vector(( 6, -1.5, 0))),
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

cam_group = add_cam("cam_group", Vector((0, -10, 6)), Vector((0, 0, 0.8)), lens=32, dof_dist=12)

# Per-enemy portraits
PORTRAIT_CAMERAS = []
for name, _, origin in ENEMIES:
    cam = add_cam(f"cam_{name}", Vector((origin.x, origin.y - 2.5, 1.3)), Vector((origin.x, origin.y, 0.9)), lens=85, dof_dist=2.5)
    PORTRAIT_CAMERAS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render — group + 8 portraits
scene.camera = cam_group
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_new_enemies_group.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.render.resolution_x = 1024; scene.render.resolution_y = 1024
for name, cam in PORTRAIT_CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_new_enemy_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-enemy GLBs
for name, obj, _ in ENEMY_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"v3_new_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )
    print(f"Exported: {out_path}")

print("=== V3 Epic 20 New Enemy Texture Pass complete ===")
