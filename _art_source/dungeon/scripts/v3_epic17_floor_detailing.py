"""
Expansion V3 — Epic 17 — Massive Floor Texture Detailing
========================================================
5 dungeon floor archetype dioramas, each with full PBR detailing
tuned to its layout type. Per-floor hero shot.

Floors:
  1. Hub & Spoke      — central rotunda with 4 radiating corridors
  2. Stair Descent    — multi-level staircase with cracked treads
  3. Maze Cells       — corridor maze cell with bricked walls + sconce
  4. Processional     — long hall with 6 torch sconces along walls
  5. Boss Approach    — wide processional w/ throne silhouette at end

Each floor:
  - Tile floor with PBR cracks and wear
  - Wall sections (brick, stone, or cracked)
  - 4-6 hero props (sconces, torches, pillars, banners)
  - Themed accent lighting

NO world volumetrics — atmosphere via emissive lights only.

Outputs: 5 hero renders @ 1600x900 + 5 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(17)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_floors.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.cycles.use_denoising = True
scene.render.resolution_x = 1600
scene.render.resolution_y = 900
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3_fl_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.02, 0.03, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# SHADER HELPER (V3 5-layer PBR)
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
        ar.color_ramp.elements[0].color = (0.12,0.08,0.04,1)
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

# ============================================================
# MATERIALS — shared between floors
# ============================================================
mats = {}
mats["floor_tile"] = make_pbr("v3fl_floor_tile", (0.42,0.38,0.32), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=8.0, bump_strength=0.30, bump_scale=10.0)
mats["floor_polished"] = make_pbr("v3fl_floor_polished", (0.30,0.28,0.25), 0.20, 0.05,
    noise_strength=0.20, voronoi_strength=0.40, voronoi_scale=6.0, bump_strength=0.10, bump_scale=12.0)
mats["wall_brick"] = make_pbr("v3fl_wall_brick", (0.55,0.45,0.32), 0.92,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=10.0, bump_strength=0.40, bump_scale=14.0)
mats["wall_stone"] = make_pbr("v3fl_wall_stone", (0.40,0.38,0.34), 0.92,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=6.0, bump_strength=0.35, bump_scale=10.0)
mats["wall_carved"] = make_pbr("v3fl_wall_carved", (0.50,0.42,0.30), 0.85,
    emission_color=(1.0,0.65,0.20), emission_strength=0.4,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=10.0,
    curvature_dirt=True, fresnel_rim=True, bump_strength=0.30, bump_scale=14.0)
mats["wood_dark"] = make_pbr("v3fl_wood", (0.18,0.10,0.05), 0.85,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=12.0, bump_strength=0.20, bump_scale=18.0)
mats["iron"] = make_pbr("v3fl_iron", (0.18,0.18,0.20), 0.45, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["brass"] = make_pbr("v3fl_brass", (0.85,0.65,0.20), 0.30, 0.92,
    emission_color=(1.0,0.85,0.30), emission_strength=0.6,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["torch_fire"] = make_pbr("v3fl_torch_fire", (1.0,0.55,0.20), 0.10, 0,
    emission_color=(1.0,0.55,0.20), emission_strength=18.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["sconce_glow"] = make_pbr("v3fl_sconce", (1.0,0.78,0.40), 0.20, 0,
    emission_color=(1.0,0.78,0.40), emission_strength=12.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["banner_red"] = make_pbr("v3fl_banner", (0.55,0.10,0.10), 0.85,
    emission_color=(0.85,0.30,0.10), emission_strength=0.4,
    noise_strength=0.30, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=40.0)
mats["banner_blue"] = make_pbr("v3fl_banner_b", (0.10,0.20,0.55), 0.85,
    emission_color=(0.30,0.55,0.95), emission_strength=0.4,
    noise_strength=0.30, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=40.0)
mats["pillar_marble"] = make_pbr("v3fl_marble", (0.78,0.74,0.65), 0.30, 0,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=8.0, bump_strength=0.10, bump_scale=14.0)
mats["rune_glow"] = make_pbr("v3fl_rune", (1.0,0.78,0.30), 0.05, 0,
    emission_color=(1.0,0.78,0.30), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["chain"] = make_pbr("v3fl_chain", (0.10,0.10,0.12), 0.55, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.20, bump_scale=40.0)

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

def cone(name, loc, r1, r2, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=24, mn=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# Reusable wall sconce
def wall_sconce(name, x, y, z, normal_dir, parent):
    """normal_dir: 'left', 'right', 'back' — direction the sconce faces."""
    nx, ny = {'left': (1, 0), 'right': (-1, 0), 'back': (0, -1), 'front': (0, 1)}[normal_dir]
    # Wall plate
    box(f"{name}_plate", (x, y, z), (0.20 if abs(ny)>0 else 0.04, 0.04 if abs(ny)>0 else 0.20, 0.30), mats["iron"], parent)
    # Bracket arm
    cyl(f"{name}_arm", (x + nx*0.10, y + ny*0.10, z), 0.025, 0.25, mats["iron"], parent, verts=8,
         rot=(0, math.pi/2 if abs(nx)>0 else 0, math.pi/2 if abs(ny)>0 else 0))
    # Bowl
    cyl(f"{name}_bowl", (x + nx*0.20, y + ny*0.20, z + 0.05), 0.10, 0.06, mats["iron"], parent, verts=14)
    # Flame
    sph(f"{name}_f", (x + nx*0.20, y + ny*0.20, z + 0.16), 0.10, mats["torch_fire"], parent, segs=12)
    sph(f"{name}_f2", (x + nx*0.20, y + ny*0.20, z + 0.28), 0.06, mats["torch_fire"], parent, segs=10)
    # Light
    bpy.ops.object.light_add(type='POINT', location=(x + nx*0.30, y + ny*0.30, z + 0.20))
    lt = bpy.context.object
    lt.data.energy = 250; lt.data.color = (1.0, 0.65, 0.30)

# ============================================================
# FLOOR 1: HUB & SPOKE — central rotunda + 4 corridors
# ============================================================
def floor_hub_spoke(origin):
    parent = bpy.data.objects.new("fl_hub_spoke", None); scene.collection.objects.link(parent)
    parent.location = origin
    HUB_R = 4.0
    # central rotunda floor
    cyl("hs_floor", (0, 0, 0), HUB_R, 0.10, mats["floor_tile"], parent, verts=32)
    # central inlay ring
    tor("hs_ring1", (0, 0, 0.05), HUB_R - 0.5, 0.04, mats["rune_glow"], parent, ms=64, mn=10)
    tor("hs_ring2", (0, 0, 0.05), HUB_R - 1.5, 0.03, mats["rune_glow"], parent, ms=48, mn=10)
    # central rune disc
    cyl("hs_disc", (0, 0, 0.06), 1.2, 0.02, mats["rune_glow"], parent, verts=32)
    # 8 pillars around hub
    for i in range(8):
        ang = i * math.pi/4
        x = math.cos(ang) * (HUB_R - 0.6)
        y = math.sin(ang) * (HUB_R - 0.6)
        box(f"hs_p_{i}_b", (x, y, 0.30), (0.6, 0.6, 0.40), mats["wall_carved"], parent)
        cyl(f"hs_p_{i}_s", (x, y, 2.5), 0.22, 4.0, mats["pillar_marble"], parent, verts=14)
        box(f"hs_p_{i}_c", (x, y, 4.65), (0.6, 0.6, 0.30), mats["wall_carved"], parent)
        # band
        tor(f"hs_p_{i}_band", (x, y, 2.5), 0.26, 0.04, mats["rune_glow"], parent, ms=20, mn=8)
    # 4 spoke openings (carved arches into walls)
    # build outer ring wall (8 wedge segments) leaving 4 gaps
    SEG = 8
    for i in range(SEG):
        if i % 2 == 0:
            continue  # leave gap for spoke
        ang = i * (math.pi*2/SEG)
        wx = math.cos(ang) * (HUB_R + 0.5)
        wy = math.sin(ang) * (HUB_R + 0.5)
        box(f"hs_w_{i}", (wx, wy, 1.5), (1.4, 0.4, 3.0), mats["wall_brick"], parent, rot=(0, 0, ang + math.pi/2))
    # spoke corridor stub on +X
    box("hs_sp_floor", (HUB_R + 1.5, 0, 0), (3.0, 1.6, 0.10), mats["floor_tile"], parent)
    box("hs_sp_w1", (HUB_R + 1.5, 0.85, 1.5), (3.0, 0.10, 3.0), mats["wall_brick"], parent)
    box("hs_sp_w2", (HUB_R + 1.5, -0.85, 1.5), (3.0, 0.10, 3.0), mats["wall_brick"], parent)
    # 2 sconces on the spoke
    wall_sconce("hs_sc1", HUB_R + 0.8, 0.78, 1.8, 'back', parent)
    wall_sconce("hs_sc2", HUB_R + 2.2, 0.78, 1.8, 'back', parent)
    # banners on opposite walls inside hub
    box("hs_b1", (-HUB_R + 0.5, -0.5, 2.6), (0.04, 0.6, 1.6), mats["banner_red"], parent)
    box("hs_b2", (-HUB_R + 0.5,  0.5, 2.6), (0.04, 0.6, 1.6), mats["banner_blue"], parent)
    return parent

# ============================================================
# FLOOR 2: STAIR DESCENT — multi-level cracked treads
# ============================================================
def floor_stairs(origin):
    parent = bpy.data.objects.new("fl_stairs", None); scene.collection.objects.link(parent)
    parent.location = origin
    # Walls flanking stairs
    box("st_wL", (-2.0, 2.5, 1.5), (0.20, 6.0, 3.0), mats["wall_stone"], parent)
    box("st_wR", ( 2.0, 2.5, 1.5), (0.20, 6.0, 3.0), mats["wall_stone"], parent)
    # 8 stair treads descending
    for i in range(8):
        z = -i * 0.20
        y = i * 0.45
        box(f"st_tread_{i}", (0, y, z + 0.05), (3.5, 0.50, 0.10), mats["floor_tile"], parent)
        # Riser
        box(f"st_riser_{i}", (0, y - 0.25, z + 0.20), (3.5, 0.04, 0.20), mats["wall_stone"], parent)
    # Top platform
    box("st_top", (0, -0.5, 0.10), (3.5, 0.50, 0.20), mats["floor_polished"], parent)
    # 4 sconces along walls
    for i, y in enumerate([0.5, 2.0, 3.5]):
        z = -i * 0.50 + 1.6
        wall_sconce(f"st_scL_{i}", -1.85, y, z, 'left', parent)
        wall_sconce(f"st_scR_{i}", 1.85, y, z, 'right', parent)
    # Bottom landing
    box("st_bottom", (0, 4.5, -1.55), (3.5, 1.5, 0.10), mats["floor_tile"], parent)
    # Iron railing posts
    for i in range(4):
        y = 0.0 + i * 1.0
        z = -i * 0.45 + 0.4
        cyl(f"st_railL_{i}", (-1.6, y, z + 0.5), 0.04, 1.0, mats["iron"], parent, verts=8)
        cyl(f"st_railR_{i}",  (1.6, y, z + 0.5), 0.04, 1.0, mats["iron"], parent, verts=8)
    return parent

# ============================================================
# FLOOR 3: MAZE CELL — corridor maze junction
# ============================================================
def floor_maze(origin):
    parent = bpy.data.objects.new("fl_maze", None); scene.collection.objects.link(parent)
    parent.location = origin
    # Floor
    box("mz_floor", (0, 0, 0), (6.0, 6.0, 0.10), mats["floor_tile"], parent)
    # T-junction walls
    # Long horizontal back wall
    box("mz_wB", (0, 2.8, 1.5), (6.0, 0.20, 3.0), mats["wall_brick"], parent)
    # Two short side walls leaving T opening
    box("mz_wL", (-1.5, 1.5, 1.5), (0.20, 2.6, 3.0), mats["wall_brick"], parent)
    box("mz_wR", ( 1.5, 1.5, 1.5), (0.20, 2.6, 3.0), mats["wall_brick"], parent)
    # Front-left and front-right walls
    box("mz_wFL", (-3.0, -1.5, 1.5), (0.20, 3.0, 3.0), mats["wall_brick"], parent)
    box("mz_wFR", ( 3.0, -1.5, 1.5), (0.20, 3.0, 3.0), mats["wall_brick"], parent)
    # Sconce on each main wall
    wall_sconce("mz_sc1", 0, 2.65, 1.8, 'front', parent)
    wall_sconce("mz_sc2", -1.35, 0, 1.8, 'left', parent)
    wall_sconce("mz_sc3", 1.35, 0, 1.8, 'right', parent)
    # Some clutter — 2 broken urns + a small chest
    sph("mz_urn1", (-2.0, 2.0, 0.30), 0.30, mats["wall_brick"], parent)
    sph("mz_urn2", (1.8, -1.0, 0.25), 0.25, mats["wall_brick"], parent)
    box("mz_chest_b", (0.8, 1.5, 0.18), (0.50, 0.30, 0.30), mats["wood_dark"], parent)
    box("mz_chest_l", (0.8, 1.5, 0.40), (0.50, 0.30, 0.10), mats["wood_dark"], parent)
    box("mz_chest_lk", (0.8, 1.32, 0.36), (0.06, 0.04, 0.10), mats["brass"], parent)
    return parent

# ============================================================
# FLOOR 4: PROCESSIONAL HALL — long corridor with torch sconces
# ============================================================
def floor_processional(origin):
    parent = bpy.data.objects.new("fl_processional", None); scene.collection.objects.link(parent)
    parent.location = origin
    LEN = 16
    # Floor (polished marble)
    box("pr_floor", (0, 0, 0), (4.0, LEN, 0.10), mats["floor_polished"], parent)
    # Carpet runner (red)
    box("pr_carpet", (0, 0, 0.06), (1.2, LEN - 0.2, 0.01), mats["banner_red"], parent)
    # Walls
    box("pr_wL", (-2.1, 0, 2.0), (0.20, LEN, 4.0), mats["wall_carved"], parent)
    box("pr_wR", ( 2.1, 0, 2.0), (0.20, LEN, 4.0), mats["wall_carved"], parent)
    # 6 sconces per side
    for i in range(6):
        y = -6.5 + i * 2.6
        wall_sconce(f"pr_scL_{i}", -1.95, y, 2.2, 'left', parent)
        wall_sconce(f"pr_scR_{i}",  1.95, y, 2.2, 'right', parent)
    # 4 banners hanging from upper wall
    for i, y in enumerate([-5, -1.5, 1.5, 5]):
        box(f"pr_bnL_{i}", (-1.95, y, 3.2), (0.04, 0.4, 1.0), mats["banner_red"], parent)
        box(f"pr_bnR_{i}", ( 1.95, y, 3.2), (0.04, 0.4, 1.0), mats["banner_red"], parent)
    # 2 statues (cylindrical pillars with sphere heads) at far end
    for i, x in enumerate([-1.2, 1.2]):
        cyl(f"pr_stat_b_{i}", (x, 7.2, 0.40), 0.40, 0.80, mats["wall_stone"], parent, verts=14)
        cyl(f"pr_stat_t_{i}", (x, 7.2, 1.6), 0.30, 1.6, mats["pillar_marble"], parent, verts=14)
        sph(f"pr_stat_h_{i}", (x, 7.2, 2.7), 0.30, mats["pillar_marble"], parent)
    return parent

# ============================================================
# FLOOR 5: BOSS APPROACH — wide hall with throne silhouette at end
# ============================================================
def floor_boss_approach(origin):
    parent = bpy.data.objects.new("fl_boss_approach", None); scene.collection.objects.link(parent)
    parent.location = origin
    LEN = 14
    WID = 7
    # Wide floor
    box("ba_floor", (0, 0, 0), (WID, LEN, 0.10), mats["floor_polished"], parent)
    # Center carved sigil strip running length
    box("ba_strip", (0, 0, 0.06), (1.5, LEN - 1, 0.01), mats["rune_glow"], parent)
    # Walls flanking
    box("ba_wL", (-WID/2, 0, 3.0), (0.20, LEN, 6.0), mats["wall_carved"], parent)
    box("ba_wR", ( WID/2, 0, 3.0), (0.20, LEN, 6.0), mats["wall_carved"], parent)
    # 4 massive pillars along corridor
    for i, y in enumerate([-5, -1.5, 1.5, 5]):
        for sx in [-WID/2 + 0.7, WID/2 - 0.7]:
            box(f"ba_pl_b_{i}_{sx}", (sx, y, 0.50), (1.0, 1.0, 1.0), mats["wall_carved"], parent)
            cyl(f"ba_pl_s_{i}_{sx}", (sx, y, 3.5), 0.40, 5.0, mats["pillar_marble"], parent, verts=20)
            tor(f"ba_pl_band_{i}_{sx}", (sx, y, 3.5), 0.45, 0.06, mats["rune_glow"], parent, ms=24, mn=10)
            box(f"ba_pl_c_{i}_{sx}", (sx, y, 6.10), (1.1, 1.1, 0.30), mats["wall_carved"], parent)
    # Throne silhouette at far end (just enough to suggest)
    box("ba_throne_b", (0, 6.5, 0.50), (3.0, 1.4, 1.0), mats["wall_stone"], parent)
    box("ba_throne_seat", (0, 6.5, 1.20), (2.4, 1.2, 0.30), mats["wall_stone"], parent)
    box("ba_throne_back", (0, 7.0, 3.5), (2.6, 0.30, 4.0), mats["wall_stone"], parent)
    # Crystal in throne
    sph("ba_throne_heart", (0, 6.85, 3.0), 0.30, mats["torch_fire"], parent, segs=20)
    bpy.ops.object.light_add(type='POINT', location=(origin[0], origin[1] + 6.85, origin[2] + 3.0))
    hp = bpy.context.object
    hp.data.energy = 1500; hp.data.color = (1.0, 0.45, 0.20)
    # 4 hanging chains from above
    for i, (cx, cy) in enumerate([(-2, -3),(2, -3),(-2, 2),(2, 2)]):
        for j in range(5):
            tor(f"ba_ch_{i}_{j}", (cx, cy, 5.5 - j*0.30), 0.10, 0.025, mats["chain"], parent, ms=12, mn=8,
                 rot=(math.pi/2 if j%2==0 else 0, 0, 0))
    # 4 sconces along walls
    for i, y in enumerate([-4, 0, 4]):
        wall_sconce(f"ba_scL_{i}", -WID/2 + 0.15, y, 2.5, 'left', parent)
        wall_sconce(f"ba_scR_{i}",  WID/2 - 0.15, y, 2.5, 'right', parent)
    return parent

# ============================================================
# LAYOUT — 5 floors widely spaced
# ============================================================
FLOORS = [
    ("hub_spoke",    floor_hub_spoke,     Vector((0, 0, 0))),
    ("stairs",       floor_stairs,        Vector((30, 0, 0))),
    ("maze",         floor_maze,          Vector((60, 0, 0))),
    ("processional", floor_processional,  Vector((0, 30, 0))),
    ("boss_approach", floor_boss_approach, Vector((30, 30, 0))),
]

CAMERAS = []
for name, builder, origin in FLOORS:
    builder(origin)
    # Per-floor key + fill lighting
    bpy.ops.object.light_add(type='AREA', location=(origin[0] + 4, origin[1] - 6, origin[2] + 6))
    k = bpy.context.object; k.data.energy = 1200; k.data.color = (1.0, 0.78, 0.45); k.data.size = 6
    bpy.ops.object.light_add(type='AREA', location=(origin[0] - 4, origin[1] + 4, origin[2] + 5))
    f = bpy.context.object; f.data.energy = 400; f.data.color = (0.45, 0.55, 0.85); f.data.size = 6
    # Camera
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

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_floor_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-floor GLB exports
for name, _, _ in FLOORS:
    bpy.ops.object.select_all(action='DESELECT')
    parent = bpy.data.objects.get(f"fl_{name}")
    if parent:
        parent.select_set(True)
        for child in parent.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"floor_{name}_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Epic 17 Massive Floor Detailing complete ===")
