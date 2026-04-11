"""
Expansion V3 — Epic 23 — Crafting Stations Texture Pass
========================================================
5 crafting stations, each with 3 tier upgrades = 15 station meshes.

Stations:
  1. FORGE         — anvil + furnace + bellows + hammer rack
  2. ALCHEMY BENCH — cauldron + bottle rack + spice jars + book
  3. COOKING POT   — fire pit + cauldron + spit + chopping board
  4. WORKBENCH     — table + tool rack + vise + sawdust pile
  5. LOOM          — frame + spinning wheel + thread spools + fabric

Tier progression (visual upgrade):
  T0 — wood/iron base (rough utility)
  T1 — brass trim accents + glow rune bands
  T2 — crystal cores + ornate gold inlay + emissive runes

Outputs:
  - 1 grid hero shot @ 1920x1080 (5 columns × 3 rows)
  - 5 per-station tier-progression close-ups @ 1280x960
  - 15 GLB exports (one per tier per station)
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/v3_crafting_stations.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/exports"
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

scene.world = bpy.data.worlds.new("v3_cs_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.05, 0.05, 0.07, 1)
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

# ============================================================
# MATERIALS — base + tier accents
# ============================================================
mats = {}
mats["wood_dark"]  = make_pbr("v3cs_wood_d", (0.18, 0.10, 0.05), 0.85,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=12.0, bump_strength=0.20, bump_scale=18.0)
mats["wood_med"]   = make_pbr("v3cs_wood_m", (0.42, 0.26, 0.13), 0.85,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=12.0, bump_strength=0.22, bump_scale=18.0)
mats["iron"]       = make_pbr("v3cs_iron", (0.18, 0.18, 0.20), 0.45, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["iron_dark"]  = make_pbr("v3cs_iron_d", (0.10, 0.10, 0.12), 0.55, 0.80,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["brass"]      = make_pbr("v3cs_brass", (0.85, 0.65, 0.20), 0.20, 0.92,
    emission_color=(1.0, 0.85, 0.30), emission_strength=0.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["gold"]       = make_pbr("v3cs_gold", (0.95, 0.78, 0.20), 0.10, 1.0,
    emission_color=(1.0, 0.85, 0.40), emission_strength=1.5,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
mats["crystal_cyan"] = make_pbr("v3cs_crystal_c", (0.30, 0.85, 1.0), 0.10, 0,
    emission_color=(0.40, 0.95, 1.0), emission_strength=10.0,
    noise_strength=0.05, curvature_dirt=False, fresnel_rim=True)
mats["crystal_purple"] = make_pbr("v3cs_crystal_p", (0.65, 0.20, 0.95), 0.10, 0,
    emission_color=(0.85, 0.30, 1.0), emission_strength=10.0,
    noise_strength=0.05, curvature_dirt=False, fresnel_rim=True)
mats["fire"]       = make_pbr("v3cs_fire", (1.0, 0.55, 0.10), 0.10, 0,
    emission_color=(1.0, 0.55, 0.10), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["water"]      = make_pbr("v3cs_water", (0.10, 0.30, 0.50), 0.05, 0,
    emission_color=(0.20, 0.50, 0.75), emission_strength=1.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05, bump_scale=80.0)
mats["alch_purple"] = make_pbr("v3cs_alch", (0.45, 0.20, 0.80), 0.10, 0,
    emission_color=(0.65, 0.30, 1.0), emission_strength=4.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["thread"]     = make_pbr("v3cs_thread", (0.85, 0.65, 0.45), 0.85,
    noise_strength=0.20, curvature_dirt=True, bump_strength=0.20, bump_scale=80.0)
mats["fabric"]     = make_pbr("v3cs_fabric", (0.45, 0.20, 0.20), 0.85,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["floor"]      = make_pbr("v3cs_floor", (0.10, 0.10, 0.12), 0.40, 0.10,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05)

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

def cyl(name, loc, r, depth, mat, parent, verts=14, rot=(0,0,0)):
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

def cone(name, loc, r1, r2, depth, mat, parent, verts=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=24, mn=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# Tier accent helpers — choose accent material per tier
def tier_accent(tier):
    """Return (accent_mat, glow_mat) for given tier 0/1/2."""
    if tier == 0:
        return mats["iron"], None
    elif tier == 1:
        return mats["brass"], mats["brass"]
    else:
        return mats["gold"], mats["crystal_cyan"]

# ============================================================
# FORGE — anvil + furnace + bellows + hammer rack
# ============================================================
def build_forge(origin, tier):
    p = bpy.data.objects.new(f"v3_forge_t{tier}", None); scene.collection.objects.link(p); p.location = origin
    accent, glow = tier_accent(tier)
    # Furnace box
    box("fg_furn_b", (-0.6, 0, 0.50), (0.9, 0.9, 1.0), mats["iron_dark"], p)
    box("fg_furn_t", (-0.6, 0, 1.05), (0.9, 0.9, 0.10), accent, p)
    # Furnace mouth opening (front face)
    box("fg_mouth", (-0.6, 0.40, 0.50), (0.5, 0.10, 0.40), mats["fire"], p)
    # Chimney
    cyl("fg_chimney", (-0.6, 0, 1.50), 0.18, 0.80, mats["iron_dark"], p, verts=14)
    # Anvil base
    box("fg_anv_b", (0.6, 0, 0.30), (0.4, 0.4, 0.60), mats["wood_dark"], p)
    # Anvil top
    box("fg_anv_t", (0.6, 0, 0.65), (0.5, 0.20, 0.10), mats["iron"], p)
    cone("fg_anv_horn", (0.85, 0, 0.65), 0.10, 0.0, 0.20, mats["iron"], p, verts=10, rot=(0, math.pi/2, 0))
    # Bellows behind furnace
    box("fg_bell_h", (-1.2, -0.4, 0.85), (0.18, 0.50, 0.30), mats["wood_med"], p, rot=(0, 0.2, 0))
    cyl("fg_bell_n", (-0.95, -0.4, 0.85), 0.05, 0.30, mats["iron"], p, verts=8, rot=(0, math.pi/2, 0))
    # Hammer (resting on anvil)
    cyl("fg_ham_h", (0.6, 0, 0.78), 0.025, 0.45, mats["wood_med"], p, verts=8)
    box("fg_ham_b", (0.6, 0, 1.02), (0.10, 0.06, 0.08), mats["iron"], p)
    # Tier accents — brass band on anvil + glowing rune on furnace
    if tier >= 1:
        tor("fg_band1", (0.6, 0, 0.65), 0.30, 0.025, accent, p, ms=24, mn=8, rot=(math.pi/2, 0, 0))
        tor("fg_band2", (-0.6, 0, 1.0), 0.50, 0.03, accent, p, ms=32, mn=10)
    if tier >= 2 and glow:
        # Crystal core embedded in furnace top
        sph("fg_core", (-0.6, 0, 1.20), 0.12, glow, p, segs=14)
        # Gold inscription strips on anvil sides
        box("fg_insc1", (0.6, 0.20, 0.65), (0.45, 0.02, 0.04), mats["gold"], p)
        box("fg_insc2", (0.6, -0.20, 0.65), (0.45, 0.02, 0.04), mats["gold"], p)
    return p

# ============================================================
# ALCHEMY BENCH
# ============================================================
def build_alchemy(origin, tier):
    p = bpy.data.objects.new(f"v3_alchemy_t{tier}", None); scene.collection.objects.link(p); p.location = origin
    accent, glow = tier_accent(tier)
    # Table
    box("al_top", (0, 0, 0.65), (1.6, 0.7, 0.06), mats["wood_dark"], p)
    box("al_l1", (-0.7, -0.30, 0.32), (0.06, 0.06, 0.65), mats["wood_dark"], p)
    box("al_l2", (0.7, -0.30, 0.32), (0.06, 0.06, 0.65), mats["wood_dark"], p)
    box("al_l3", (-0.7, 0.30, 0.32), (0.06, 0.06, 0.65), mats["wood_dark"], p)
    box("al_l4", (0.7, 0.30, 0.32), (0.06, 0.06, 0.65), mats["wood_dark"], p)
    # Cauldron on left
    cyl("al_caul_b", (-0.5, 0, 0.72), 0.20, 0.04, mats["iron_dark"], p)
    sph("al_caul", (-0.5, 0, 0.85), 0.20, mats["iron_dark"], p, segs=18)
    cyl("al_caul_w", (-0.5, 0, 0.95), 0.18, 0.04, mats["alch_purple"], p, verts=18)
    # Bottle rack (3 bottles standing)
    for i, (bx, color) in enumerate([(0.10, mats["alch_purple"]), (0.30, mats["water"]), (0.50, mats["fire"])]):
        cyl(f"al_bot_{i}", (bx, 0.10, 0.85), 0.06, 0.30, color, p, verts=12)
        sph(f"al_bot_n_{i}", (bx, 0.10, 1.05), 0.04, mats["wood_med"], p, segs=10)
    # Open book on right
    box("al_book_b", (0.6, 0, 0.70), (0.30, 0.40, 0.04), mats["wood_med"], p)
    box("al_book_p", (0.6, 0, 0.73), (0.27, 0.36, 0.02), mats["thread"], p)
    # Tier accents
    if tier >= 1:
        tor("al_caul_band", (-0.5, 0, 0.78), 0.22, 0.02, accent, p, ms=24, mn=8)
        # Brass corner trim on table
        for cx, cy in [(-0.7,-0.3),(0.7,-0.3),(-0.7,0.3),(0.7,0.3)]:
            sph(f"al_cn_{cx}_{cy}", (cx, cy, 0.65), 0.04, accent, p, segs=10)
    if tier >= 2 and glow:
        # Crystal core mounted above cauldron
        sph("al_core", (-0.5, 0, 1.15), 0.08, glow, p, segs=14)
        cyl("al_core_post", (-0.5, 0, 1.0), 0.02, 0.30, mats["gold"], p, verts=8)
        # Gold inscription on book cover
        sph("al_book_g", (0.6, 0, 0.76), 0.025, mats["gold"], p, segs=10)
    return p

# ============================================================
# COOKING POT
# ============================================================
def build_cooking(origin, tier):
    p = bpy.data.objects.new(f"v3_cooking_t{tier}", None); scene.collection.objects.link(p); p.location = origin
    accent, glow = tier_accent(tier)
    # Stone fire pit (ring of stones)
    cyl("ck_pit", (0, 0, 0.10), 0.55, 0.20, mats["iron_dark"], p, verts=18)
    cyl("ck_pit_in", (0, 0, 0.18), 0.50, 0.05, mats["fire"], p, verts=18)
    # Tripod (3 legs forming X)
    for i in range(3):
        ang = i * (math.pi*2/3)
        lx = math.cos(ang) * 0.50
        ly = math.sin(ang) * 0.50
        cyl(f"ck_leg_{i}", (lx*0.5, ly*0.5, 0.50), 0.04, 1.10, mats["iron"], p, verts=8,
             rot=(math.cos(ang)*0.4, math.sin(ang)*0.4, ang))
    # Pot hanging at center
    sph("ck_pot", (0, 0, 0.55), 0.30, mats["iron_dark"], p, segs=20)
    cyl("ck_pot_top", (0, 0, 0.78), 0.28, 0.04, mats["water"], p, verts=20)
    # Pot handle
    tor("ck_pot_h", (0, 0, 0.85), 0.30, 0.02, mats["iron"], p, ms=20, mn=8, rot=(0, math.pi/2, 0))
    # Chopping board on the side
    box("ck_board", (0.85, 0, 0.10), (0.50, 0.40, 0.04), mats["wood_med"], p)
    # Vegetables on board
    sph("ck_veg1", (0.80, 0.10, 0.16), 0.05, mats["fire"], p, segs=10)
    sph("ck_veg2", (0.95, -0.05, 0.16), 0.05, mats["alch_purple"], p, segs=10)
    sph("ck_veg3", (0.75, -0.10, 0.16), 0.05, mats["fabric"], p, segs=10)
    # Tier accents
    if tier >= 1:
        tor("ck_pot_band", (0, 0, 0.55), 0.32, 0.025, accent, p, ms=24, mn=8)
        # Brass tripod cap
        sph("ck_tripod_cap", (0, 0, 0.95), 0.06, accent, p, segs=12)
    if tier >= 2 and glow:
        sph("ck_core", (0, 0, 1.15), 0.10, glow, p, segs=14)
        # Gold rune circle around pit
        tor("ck_rune", (0, 0, 0.06), 0.65, 0.02, mats["gold"], p, ms=48, mn=8)
    return p

# ============================================================
# WORKBENCH
# ============================================================
def build_workbench(origin, tier):
    p = bpy.data.objects.new(f"v3_workbench_t{tier}", None); scene.collection.objects.link(p); p.location = origin
    accent, glow = tier_accent(tier)
    # Table
    box("wb_top", (0, 0, 0.70), (1.6, 0.7, 0.08), mats["wood_med"], p)
    box("wb_l1", (-0.7, -0.30, 0.34), (0.10, 0.10, 0.70), mats["wood_dark"], p)
    box("wb_l2", (0.7, -0.30, 0.34), (0.10, 0.10, 0.70), mats["wood_dark"], p)
    box("wb_l3", (-0.7, 0.30, 0.34), (0.10, 0.10, 0.70), mats["wood_dark"], p)
    box("wb_l4", (0.7, 0.30, 0.34), (0.10, 0.10, 0.70), mats["wood_dark"], p)
    # Tool rack on back
    box("wb_rack", (0, 0.32, 1.20), (1.4, 0.04, 0.50), mats["wood_dark"], p)
    # 5 tools hanging
    for i, x in enumerate([-0.50, -0.25, 0.00, 0.25, 0.50]):
        cyl(f"wb_tool_h_{i}", (x, 0.30, 1.10), 0.025, 0.20, mats["wood_med"], p, verts=8)
        if i % 2 == 0:
            box(f"wb_tool_b_{i}", (x, 0.30, 1.30), (0.06, 0.06, 0.10), mats["iron"], p)
        else:
            cone(f"wb_tool_c_{i}", (x, 0.30, 1.30), 0.05, 0.0, 0.10, mats["iron"], p, verts=8)
    # Vise on table
    box("wb_vise_b", (-0.50, 0.10, 0.78), (0.20, 0.18, 0.10), mats["iron"], p)
    box("wb_vise_j1", (-0.50, 0.18, 0.85), (0.20, 0.04, 0.18), mats["iron"], p)
    box("wb_vise_j2", (-0.50, 0.02, 0.85), (0.20, 0.04, 0.18), mats["iron"], p)
    # Saw on table
    box("wb_saw_h", (0.40, 0.10, 0.76), (0.06, 0.04, 0.10), mats["wood_med"], p)
    box("wb_saw_b", (0.60, 0.10, 0.76), (0.30, 0.02, 0.06), mats["iron"], p)
    # Sawdust pile
    sph("wb_dust", (0.40, -0.20, 0.76), 0.08, mats["wood_med"], p, segs=10)
    # Tier accents
    if tier >= 1:
        # Brass corners on table
        for cx, cy in [(-0.7,-0.3),(0.7,-0.3),(-0.7,0.3),(0.7,0.3)]:
            sph(f"wb_cn_{cx}_{cy}", (cx, cy, 0.74), 0.05, accent, p, segs=10)
        tor("wb_vise_band", (-0.50, 0.10, 0.85), 0.10, 0.015, accent, p, ms=20, mn=6)
    if tier >= 2 and glow:
        sph("wb_core", (0, 0.32, 1.50), 0.10, glow, p, segs=14)
        cyl("wb_core_p", (0, 0.32, 1.35), 0.025, 0.30, mats["gold"], p, verts=8)
    return p

# ============================================================
# LOOM
# ============================================================
def build_loom(origin, tier):
    p = bpy.data.objects.new(f"v3_loom_t{tier}", None); scene.collection.objects.link(p); p.location = origin
    accent, glow = tier_accent(tier)
    # Frame (vertical loom)
    # 2 vertical posts
    box("lm_pl", (-0.6, 0, 0.85), (0.08, 0.08, 1.70), mats["wood_dark"], p)
    box("lm_pr", (0.6, 0, 0.85), (0.08, 0.08, 1.70), mats["wood_dark"], p)
    # Top bar
    box("lm_top", (0, 0, 1.65), (1.30, 0.10, 0.10), mats["wood_dark"], p)
    # Bottom bar
    box("lm_bot", (0, 0, 0.20), (1.30, 0.10, 0.10), mats["wood_dark"], p)
    # 12 vertical warp threads
    for i in range(12):
        x = -0.50 + i * 0.09
        cyl(f"lm_warp_{i}", (x, 0, 0.92), 0.005, 1.40, mats["thread"], p, verts=6)
    # Half-woven fabric panel (2/3 way down)
    box("lm_fabric", (0, 0.02, 0.55), (1.10, 0.02, 0.50), mats["fabric"], p)
    # Spinning wheel on the side
    cyl("lm_wheel", (0.95, 0.30, 0.50), 0.30, 0.04, mats["wood_med"], p, verts=24, rot=(math.pi/2, 0, 0))
    cyl("lm_wheel_hub", (0.95, 0.30, 0.50), 0.06, 0.10, mats["iron"], p, verts=10, rot=(math.pi/2, 0, 0))
    # 6 spokes
    for i in range(6):
        ang = i * (math.pi*2/6)
        sx = math.cos(ang) * 0.20
        sz = 0.50 + math.sin(ang) * 0.20
        box(f"lm_spk_{i}", (0.95, 0.30, 0.50), (0.025, 0.04, 0.40), mats["wood_med"], p, rot=(ang, 0, 0))
    # 3 thread spools at base
    for i, (sx, color) in enumerate([(-0.40, mats["thread"]), (0.0, mats["fabric"]), (0.40, mats["alch_purple"])]):
        cyl(f"lm_spool_{i}", (sx, -0.35, 0.30), 0.06, 0.18, color, p, verts=14)
    # Tier accents
    if tier >= 1:
        # Brass caps on posts
        sph("lm_pl_cap", (-0.6, 0, 1.72), 0.08, accent, p, segs=12)
        sph("lm_pr_cap", (0.6, 0, 1.72), 0.08, accent, p, segs=12)
        # Brass band on spinning wheel hub
        tor("lm_wheel_band", (0.95, 0.30, 0.50), 0.10, 0.015, accent, p, ms=20, mn=6, rot=(math.pi/2, 0, 0))
    if tier >= 2 and glow:
        sph("lm_core", (0, 0, 1.85), 0.12, glow, p, segs=14)
        # Gold trim on top bar
        box("lm_top_g", (0, 0, 1.72), (1.30, 0.04, 0.04), mats["gold"], p)
    return p

# ============================================================
# LAYOUT — 5 stations × 3 tiers in grid
# ============================================================
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "cs_floor"; fl.scale = (16, 14, 0.10)
fl.data.materials.append(mats["floor"]); add_subsurf_bevel(fl, levels=1, bevel=0.005)

STATIONS = [
    ("forge",     build_forge),
    ("alchemy",   build_alchemy),
    ("cooking",   build_cooking),
    ("workbench", build_workbench),
    ("loom",      build_loom),
]

ALL_OBJS = []
COL_SPACING = 3.0
ROW_SPACING = 4.0
for col_idx, (name, builder) in enumerate(STATIONS):
    for tier in range(3):
        x = -6 + col_idx * COL_SPACING
        y = -ROW_SPACING + tier * ROW_SPACING
        origin = Vector((x, y, 0))
        obj = builder(origin, tier)
        ALL_OBJS.append((name, tier, obj, origin))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -12, 14))
key = bpy.context.object
key.data.energy = 2200; key.data.color = (1.0, 0.92, 0.78); key.data.size = 14

bpy.ops.object.light_add(type='AREA', location=(-8, 10, 12))
fill = bpy.context.object
fill.data.energy = 800; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 12

bpy.ops.object.light_add(type='AREA', location=(0, 12, 6))
rim = bpy.context.object
rim.data.energy = 600; rim.data.color = (1.0, 0.75, 0.45); rim.data.size = 10

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 5.6
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_grid = add_cam("cam_grid", Vector((0, -16, 11)), Vector((0, 0, 0.8)), lens=32, dof_dist=18)

# Per-station tier-progression close-up cameras
STATION_CAMERAS = []
for col_idx, (name, _) in enumerate(STATIONS):
    x = -6 + col_idx * COL_SPACING
    cam = add_cam(f"cam_{name}", Vector((x + 1.5, -10, 4)), Vector((x, 0, 0.8)), lens=70, dof_dist=10)
    STATION_CAMERAS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render grid
scene.camera = cam_grid
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_crafting_grid.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Per-station progression renders
scene.render.resolution_x = 1280; scene.render.resolution_y = 960
for name, cam in STATION_CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_crafting_{name}_progression.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-station-tier GLB exports (15 total)
for name, tier, obj, _ in ALL_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"crafting_{name}_t{tier}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )
    print(f"Exported: {out_path}")

print("=== V3 Epic 23 Crafting Stations complete ===")
