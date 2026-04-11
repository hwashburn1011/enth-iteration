"""
Expansion V3 — Epic 07 — Town District Refinement
=====================================================
6 town districts with per-district ground material variation, accent props,
and lighting identity:

  1. Town Central — marble plaza with central fountain
  2. Residential — cobblestone paths between houses
  3. Market — wooden plank floors with stalls and lanterns
  4. Commons — trimmed grass with benches and trees
  5. Workshop — dirt+gravel ground with crates and barrels
  6. Docks — wooden boardwalk at sea level with wet planks

Each district scene features:
  - Tiled ground with district-appropriate material (procedural)
  - 4-6 district-defining accent props
  - Per-district color accent on lanterns/signs
  - Surrounding low-detail building silhouettes for context
  - Hero shot render from a 3/4 cinematic angle

Outputs:
  - 6 district hero shot renders at 1920x1080
  - 1 GLB export per district
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_town_districts.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
EXPORT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080

# ============================================================
# SHADER HELPER (V3 standard)
# ============================================================

def make_pbr_advanced(name, base_color, roughness=0.65, metallic=0.0,
                      emission_color=None, emission_strength=0.0,
                      noise_strength=0.20, voronoi_strength=0.0, voronoi_scale=22.0,
                      curvature_dirt=True, fresnel_rim=False,
                      bump_strength=0.10, bump_scale=35.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes
    links = nt.links
    nodes.clear()

    output = nodes.new("ShaderNodeOutputMaterial")
    output.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission_color is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    links.new(bsdf.outputs[0], output.inputs[0])

    tex_coord = nodes.new("ShaderNodeTexCoord")
    tex_coord.location = (-1200, 0)
    mapping = nodes.new("ShaderNodeMapping")
    mapping.location = (-1000, 0)
    mapping.inputs["Scale"].default_value = (5.0, 5.0, 5.0)
    links.new(tex_coord.outputs["Generated"], mapping.inputs["Vector"])

    if noise_strength > 0:
        noise = nodes.new("ShaderNodeTexNoise")
        noise.location = (-700, 200)
        noise.inputs["Scale"].default_value = 14.0
        noise.inputs["Detail"].default_value = 8.0
        links.new(mapping.outputs["Vector"], noise.inputs["Vector"])
        ramp = nodes.new("ShaderNodeValToRGB")
        ramp.location = (-450, 200)
        ramp.color_ramp.elements[0].position = 0.35
        ramp.color_ramp.elements[0].color = (
            base_color[0] * 0.80, base_color[1] * 0.80, base_color[2] * 0.80, 1)
        ramp.color_ramp.elements[1].position = 0.70
        ramp.color_ramp.elements[1].color = (
            min(base_color[0] * 1.20, 1), min(base_color[1] * 1.20, 1),
            min(base_color[2] * 1.20, 1), 1)
        links.new(noise.outputs["Fac"], ramp.inputs["Fac"])
        mix = nodes.new("ShaderNodeMix")
        mix.data_type = 'RGBA'
        mix.location = (-200, 100)
        mix.inputs["Factor"].default_value = noise_strength
        mix.inputs[6].default_value = (*base_color, 1)
        links.new(ramp.outputs["Color"], mix.inputs[7])
        base_out = mix.outputs[2]
    else:
        rgb = nodes.new("ShaderNodeRGB")
        rgb.location = (-200, 100)
        rgb.outputs[0].default_value = (*base_color, 1)
        base_out = rgb.outputs[0]

    if voronoi_strength > 0:
        v = nodes.new("ShaderNodeTexVoronoi")
        v.location = (-700, -100)
        v.feature = 'F1'
        v.inputs["Scale"].default_value = voronoi_scale
        links.new(mapping.outputs["Vector"], v.inputs["Vector"])
        v_ramp = nodes.new("ShaderNodeValToRGB")
        v_ramp.location = (-450, -100)
        v_ramp.color_ramp.elements[0].position = 0.05
        v_ramp.color_ramp.elements[0].color = (
            base_color[0] * 0.55, base_color[1] * 0.55, base_color[2] * 0.55, 1)
        v_ramp.color_ramp.elements[1].position = 0.30
        v_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
        links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])
        mv = nodes.new("ShaderNodeMix")
        mv.data_type = 'RGBA'
        mv.location = (50, 50)
        mv.inputs["Factor"].default_value = voronoi_strength
        links.new(base_out, mv.inputs[6])
        links.new(v_ramp.outputs["Color"], mv.inputs[7])
        base_out = mv.outputs[2]

    if curvature_dirt:
        geo = nodes.new("ShaderNodeNewGeometry")
        geo.location = (-700, -350)
        ao_ramp = nodes.new("ShaderNodeValToRGB")
        ao_ramp.location = (-450, -350)
        ao_ramp.color_ramp.elements[0].position = 0.30
        ao_ramp.color_ramp.elements[0].color = (0.15, 0.10, 0.06, 1)
        ao_ramp.color_ramp.elements[1].position = 0.70
        ao_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
        links.new(geo.outputs["Pointiness"], ao_ramp.inputs["Fac"])
        md = nodes.new("ShaderNodeMix")
        md.data_type = 'RGBA'
        md.location = (300, 0)
        md.inputs["Factor"].default_value = 0.40
        links.new(base_out, md.inputs[6])
        links.new(ao_ramp.outputs["Color"], md.inputs[7])
        base_out = md.outputs[2]

    if fresnel_rim and emission_color is not None:
        fresnel = nodes.new("ShaderNodeFresnel")
        fresnel.location = (300, 300)
        fresnel.inputs["IOR"].default_value = 1.45
        rim_color = nodes.new("ShaderNodeRGB")
        rim_color.location = (300, 450)
        rim_color.outputs[0].default_value = (*emission_color, 1)
        mr = nodes.new("ShaderNodeMix")
        mr.data_type = 'RGBA'
        mr.location = (550, 350)
        mr.inputs[6].default_value = (0, 0, 0, 1)
        links.new(fresnel.outputs["Fac"], mr.inputs["Factor"])
        links.new(rim_color.outputs[0], mr.inputs[7])
        links.new(mr.outputs[2], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = max(emission_strength, 1.5)

    bn = nodes.new("ShaderNodeTexNoise")
    bn.location = (-700, -550)
    bn.inputs["Scale"].default_value = bump_scale
    bn.inputs["Detail"].default_value = 8.0
    links.new(mapping.outputs["Vector"], bn.inputs["Vector"])
    bump = nodes.new("ShaderNodeBump")
    bump.location = (-450, -550)
    bump.inputs["Strength"].default_value = bump_strength
    links.new(bn.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

    links.new(base_out, bsdf.inputs["Base Color"])
    return m

# ============================================================
# DISTRICT MATERIALS (per-district ground identity)
# ============================================================

# Ground materials
mat_marble = make_pbr_advanced("v3_dist_marble",
    base_color=(0.85, 0.83, 0.80), roughness=0.30, metallic=0.0,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=8.0,
    bump_strength=0.10, bump_scale=14.0)

mat_cobblestone = make_pbr_advanced("v3_dist_cobble",
    base_color=(0.42, 0.40, 0.36), roughness=0.85, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=14.0,
    bump_strength=0.35, bump_scale=18.0)

mat_wood_planks = make_pbr_advanced("v3_dist_wood_planks",
    base_color=(0.45, 0.28, 0.12), roughness=0.85, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=10.0,
    bump_strength=0.20, bump_scale=12.0)

mat_grass = make_pbr_advanced("v3_dist_grass",
    base_color=(0.18, 0.32, 0.12), roughness=0.92, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.20, voronoi_scale=22.0,
    bump_strength=0.25, bump_scale=14.0)

mat_dirt_gravel = make_pbr_advanced("v3_dist_dirt",
    base_color=(0.30, 0.22, 0.13), roughness=0.92, metallic=0.0,
    noise_strength=0.35, voronoi_strength=0.40, voronoi_scale=20.0,
    bump_strength=0.30, bump_scale=16.0)

mat_wet_planks = make_pbr_advanced("v3_dist_wet_planks",
    base_color=(0.22, 0.14, 0.06), roughness=0.30, metallic=0.10,
    noise_strength=0.30, voronoi_strength=0.50, voronoi_scale=10.0,
    bump_strength=0.18, bump_scale=14.0)

# Generic prop materials
mat_marble_white = make_pbr_advanced("v3_dist_marble_white",
    base_color=(0.92, 0.90, 0.85), roughness=0.30, metallic=0.0,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05)

mat_water = make_pbr_advanced("v3_dist_water",
    base_color=(0.10, 0.30, 0.50), roughness=0.10, metallic=0.0,
    emission_color=(0.20, 0.40, 0.65), emission_strength=0.4,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True,
    bump_strength=0.05, bump_scale=80.0)

mat_brass = make_pbr_advanced("v3_dist_brass",
    base_color=(0.85, 0.65, 0.20), roughness=0.30, metallic=0.92,
    emission_color=(1.0, 0.85, 0.30), emission_strength=0.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)

mat_iron = make_pbr_advanced("v3_dist_iron",
    base_color=(0.30, 0.30, 0.32), roughness=0.45, metallic=0.85,
    noise_strength=0.10, curvature_dirt=True)

mat_wood_dark = make_pbr_advanced("v3_dist_wood_dark",
    base_color=(0.22, 0.13, 0.06), roughness=0.85, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.40, voronoi_scale=12.0,
    bump_strength=0.18, bump_scale=20.0)

mat_wood_light = make_pbr_advanced("v3_dist_wood_light",
    base_color=(0.55, 0.35, 0.18), roughness=0.85, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.40, voronoi_scale=12.0,
    bump_strength=0.18, bump_scale=20.0)

mat_lantern_warm = make_pbr_advanced("v3_dist_lantern_warm",
    base_color=(1.0, 0.85, 0.45), roughness=0.20, metallic=0.0,
    emission_color=(1.0, 0.85, 0.45), emission_strength=5.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

mat_lantern_cool = make_pbr_advanced("v3_dist_lantern_cool",
    base_color=(0.40, 0.75, 1.0), roughness=0.20, metallic=0.0,
    emission_color=(0.40, 0.75, 1.0), emission_strength=4.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

mat_canvas_red = make_pbr_advanced("v3_dist_canvas_red",
    base_color=(0.65, 0.25, 0.20), roughness=0.85, metallic=0.0,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.18, bump_scale=30.0)

mat_canvas_blue = make_pbr_advanced("v3_dist_canvas_blue",
    base_color=(0.20, 0.40, 0.65), roughness=0.85, metallic=0.0,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.18, bump_scale=30.0)

mat_tree_bark = make_pbr_advanced("v3_dist_tree_bark",
    base_color=(0.20, 0.13, 0.07), roughness=0.95, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.50, voronoi_scale=14.0,
    bump_strength=0.30, bump_scale=22.0)

mat_tree_canopy = make_pbr_advanced("v3_dist_tree_canopy",
    base_color=(0.18, 0.30, 0.10), roughness=0.85, metallic=0.0,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.25, bump_scale=40.0)

mat_dock_rope = make_pbr_advanced("v3_dist_rope",
    base_color=(0.55, 0.42, 0.18), roughness=0.90, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.30, voronoi_scale=30.0,
    bump_strength=0.30, bump_scale=50.0)

# ============================================================
# COLLECTIONS
# ============================================================

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

DISTRICTS = ["central", "residential", "market", "commons", "workshop", "docks"]
district_colls = {d: make_coll(f"V3_dist_{d}") for d in DISTRICTS}
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

# ============================================================
# MESH BUILDERS
# ============================================================

def add_object(name, mesh, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1),
               subdiv_levels=0, render_levels=2, bevel_width=0.0):
    obj = bpy.data.objects.new(name, mesh)
    obj.location = loc
    obj.rotation_euler = rot
    obj.scale = scale
    if mat is not None:
        obj.data.materials.append(mat)
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    if subdiv_levels > 0:
        ss = obj.modifiers.new("Subdivision", 'SUBSURF')
        ss.levels = subdiv_levels
        ss.render_levels = render_levels
    if bevel_width > 0:
        bv = obj.modifiers.new("Bevel", 'BEVEL')
        bv.width = bevel_width
        bv.segments = 3
    return obj

def build_cube(name, sx, sy, sz, bevel_offset=0.0):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    if bevel_offset > 0:
        bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=bevel_offset, segments=3, profile=0.5, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_cylinder(name, r, h, segs=20):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_cone(name, r1, r2, h, segs=16):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_sphere(name, r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_uvsphere(name, r, u=24, v=14, scale=(1,1,1)):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=r)
    bmesh.ops.scale(bm, vec=scale, verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_torus(name, major, minor, segs=24):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=segs, radius=major, cap_ends=False)
    bm.verts.ensure_lookup_table()
    inner = bm.verts[:]
    bmesh.ops.create_circle(bm, segments=segs, radius=major - minor*2, cap_ends=False)
    bm.verts.ensure_lookup_table()
    outer = bm.verts[segs:segs*2]
    for j in range(segs):
        bm.faces.new([inner[j], inner[(j+1)%segs], outer[(j+1)%segs], outer[j]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_plane(name, sx, sy):
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=10, y_segments=10, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, 1), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

# ============================================================
# DISTRICT BUILDERS
# ============================================================

def build_central_district(x_off, y_off):
    """Marble plaza with central fountain."""
    coll = district_colls["central"]
    bx, by = x_off, y_off
    # Marble plaza floor
    add_object("CD_Floor", build_plane("cd_floor", 7, 7), mat_marble, coll, loc=(bx, by, 0))
    # Central fountain — 3-tier marble bowls
    add_object("CD_FountBase", build_cylinder("cd_fb", 1.4, 0.40, segs=24),
               mat_marble_white, coll, loc=(bx, by, 0.20), bevel_width=0.02)
    add_object("CD_FountWater1", build_cylinder("cd_fw1", 1.30, 0.06, segs=24),
               mat_water, coll, loc=(bx, by, 0.43), subdiv_levels=1)
    add_object("CD_FountTier2", build_cylinder("cd_ft2", 0.90, 0.30, segs=24),
               mat_marble_white, coll, loc=(bx, by, 0.65), bevel_width=0.015)
    add_object("CD_FountWater2", build_cylinder("cd_fw2", 0.80, 0.06, segs=24),
               mat_water, coll, loc=(bx, by, 0.83))
    add_object("CD_FountTier3", build_cylinder("cd_ft3", 0.50, 0.20, segs=24),
               mat_marble_white, coll, loc=(bx, by, 1.00))
    add_object("CD_FountTop", build_sphere("cd_ftop", 0.18, subs=3),
               mat_brass, coll, loc=(bx, by, 1.30), subdiv_levels=1)
    # 4 marble benches around the plaza
    for sx, sy in [(-2.5, -2.5), (2.5, -2.5), (-2.5, 2.5), (2.5, 2.5)]:
        add_object(f"CD_Bench_{sx}_{sy}",
                   build_cube(f"cd_b_{sx}_{sy}", 1.0, 0.30, 0.10, bevel_offset=0.02),
                   mat_marble_white, coll, loc=(bx + sx, by + sy, 0.40), bevel_width=0.005)
        add_object(f"CD_BenchLeg_{sx}_{sy}_a",
                   build_cube(f"cd_bla_{sx}_{sy}", 0.10, 0.25, 0.30, bevel_offset=0.01),
                   mat_marble_white, coll, loc=(bx + sx - 0.40, by + sy, 0.20))
        add_object(f"CD_BenchLeg_{sx}_{sy}_b",
                   build_cube(f"cd_blb_{sx}_{sy}", 0.10, 0.25, 0.30, bevel_offset=0.01),
                   mat_marble_white, coll, loc=(bx + sx + 0.40, by + sy, 0.20))
    # 4 ornate brass lampposts at the corners
    for sx, sy in [(-3.2, -3.2), (3.2, -3.2), (-3.2, 3.2), (3.2, 3.2)]:
        add_object(f"CD_LampPost_{sx}_{sy}",
                   build_cylinder(f"cd_lp_{sx}_{sy}", 0.06, 1.6),
                   mat_brass, coll, loc=(bx + sx, by + sy, 0.80))
        add_object(f"CD_LampHead_{sx}_{sy}",
                   build_sphere(f"cd_lh_{sx}_{sy}", 0.18, subs=3),
                   mat_lantern_warm, coll, loc=(bx + sx, by + sy, 1.70), subdiv_levels=1)

def build_residential_district(x_off, y_off):
    """Cobblestone path between low houses."""
    coll = district_colls["residential"]
    bx, by = x_off, y_off
    # Cobble ground
    add_object("RD_Floor", build_plane("rd_floor", 7, 7), mat_cobblestone, coll, loc=(bx, by, 0))
    # 4 small house silhouettes (low cottages)
    for i, (sx, sy) in enumerate([(-2.8, -2.8), (2.8, -2.8), (-2.8, 2.8), (2.8, 2.8)]):
        add_object(f"RD_House_{i}",
                   build_cube(f"rd_h_{i}", 1.4, 1.4, 1.0, bevel_offset=0.04),
                   mat_wood_light, coll, loc=(bx + sx, by + sy, 0.50), bevel_width=0.01)
        # Triangular roof
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 1.55
            v.co.y *= 1.55
            v.co.z *= 0.55
        # Collapse top
        for v in bm.verts:
            if v.co.z > 0:
                v.co.x = 0
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        roof_me = bpy.data.meshes.new(f"rd_roof_{i}")
        bm.to_mesh(roof_me); bm.free()
        add_object(f"RD_Roof_{i}", roof_me, mat_canvas_red, coll, loc=(bx + sx, by + sy, 1.30))
        # Door
        add_object(f"RD_Door_{i}", build_cube(f"rd_d_{i}", 0.30, 0.04, 0.55, bevel_offset=0.005),
                   mat_wood_dark, coll, loc=(bx + sx, by + sy - 0.72, 0.30))
        # Window with glow
        add_object(f"RD_Window_{i}", build_cube(f"rd_w_{i}", 0.25, 0.04, 0.25, bevel_offset=0.005),
                   mat_lantern_warm, coll, loc=(bx + sx + 0.45, by + sy - 0.72, 0.65))
    # 2 lampposts along the path
    for sx in [-1.5, 1.5]:
        add_object(f"RD_LampPost_{sx}",
                   build_cylinder(f"rd_lp_{sx}", 0.05, 1.5),
                   mat_iron, coll, loc=(bx + sx, by, 0.75))
        add_object(f"RD_LampHead_{sx}",
                   build_cube(f"rd_lh_{sx}", 0.16, 0.16, 0.20, bevel_offset=0.01),
                   mat_lantern_warm, coll, loc=(bx + sx, by, 1.65), bevel_width=0.005)
    # Flower pots near the path
    for sx in [-0.5, 0.5]:
        add_object(f"RD_Pot_{sx}",
                   build_cylinder(f"rd_pot_{sx}", 0.18, 0.25, segs=14),
                   mat_canvas_red, coll, loc=(bx + sx, by - 0.5, 0.13))
        add_object(f"RD_Plant_{sx}", build_sphere(f"rd_pl_{sx}", 0.18, subs=2),
                   mat_tree_canopy, coll, loc=(bx + sx, by - 0.5, 0.50), subdiv_levels=1)

def build_market_district(x_off, y_off):
    """Wooden plank floor with market stalls."""
    coll = district_colls["market"]
    bx, by = x_off, y_off
    # Wood plank floor
    add_object("MD_Floor", build_plane("md_floor", 7, 7), mat_wood_planks, coll, loc=(bx, by, 0))
    # 4 market stalls (cube + canvas awning)
    stall_positions = [(-2.5, -1.5), (2.5, -1.5), (-2.5, 1.5), (2.5, 1.5)]
    canvas_mats = [mat_canvas_red, mat_canvas_blue, mat_canvas_red, mat_canvas_blue]
    for i, ((sx, sy), canvas) in enumerate(zip(stall_positions, canvas_mats)):
        # Counter
        add_object(f"MD_StallCounter_{i}",
                   build_cube(f"md_sc_{i}", 1.4, 0.7, 0.9, bevel_offset=0.04),
                   mat_wood_dark, coll, loc=(bx + sx, by + sy, 0.45), bevel_width=0.01)
        # 4 corner posts
        for px, py in [(-0.65, -0.30), (0.65, -0.30), (-0.65, 0.30), (0.65, 0.30)]:
            add_object(f"MD_StallPost_{i}_{px}_{py}",
                       build_cube(f"md_sp_{i}_{px}_{py}", 0.06, 0.06, 1.6, bevel_offset=0.005),
                       mat_wood_dark, coll, loc=(bx + sx + px, by + sy + py, 0.80))
        # Awning canvas
        add_object(f"MD_StallAwning_{i}",
                   build_cube(f"md_sa_{i}", 1.5, 0.85, 0.05, bevel_offset=0.01),
                   canvas, coll, loc=(bx + sx, by + sy, 1.65), bevel_width=0.005)
        # Wares on counter (3 spheres = produce/baskets)
        for j in range(3):
            add_object(f"MD_Ware_{i}_{j}", build_sphere(f"md_w_{i}_{j}", 0.10, subs=3),
                       mat_canvas_red if j % 2 == 0 else mat_canvas_blue, coll,
                       loc=(bx + sx - 0.50 + j*0.50, by + sy, 0.95), subdiv_levels=1)
    # Center walking path lanterns
    for sy in [-1.5, 0, 1.5]:
        add_object(f"MD_LanternPost_{sy}",
                   build_cylinder(f"md_lp_{sy}", 0.04, 1.4),
                   mat_iron, coll, loc=(bx, by + sy, 0.70))
        add_object(f"MD_LanternHead_{sy}",
                   build_cube(f"md_lh_{sy}", 0.14, 0.14, 0.18, bevel_offset=0.01),
                   mat_lantern_warm, coll, loc=(bx, by + sy, 1.50), bevel_width=0.005)
    # Crates in the corners
    for sx, sy in [(-3.0, 0.5), (3.0, -0.5)]:
        add_object(f"MD_Crate_{sx}_{sy}",
                   build_cube(f"md_cr_{sx}_{sy}", 0.5, 0.5, 0.5, bevel_offset=0.02),
                   mat_wood_dark, coll, loc=(bx + sx, by + sy, 0.25), bevel_width=0.005)

def build_commons_district(x_off, y_off):
    """Trimmed grass with benches and trees."""
    coll = district_colls["commons"]
    bx, by = x_off, y_off
    # Grass ground
    add_object("CmD_Floor", build_plane("cmd_floor", 7, 7), mat_grass, coll, loc=(bx, by, 0))
    # 4 trees in corners
    for sx, sy in [(-2.5, -2.5), (2.5, -2.5), (-2.5, 2.5), (2.5, 2.5)]:
        add_object(f"CmD_Trunk_{sx}_{sy}",
                   build_cylinder(f"cmd_tr_{sx}_{sy}", 0.20, 1.4),
                   mat_tree_bark, coll, loc=(bx + sx, by + sy, 0))
        add_object(f"CmD_Canopy_{sx}_{sy}",
                   build_uvsphere(f"cmd_c_{sx}_{sy}", 0.85, scale=(1, 1, 0.85)),
                   mat_tree_canopy, coll, loc=(bx + sx, by + sy, 1.85),
                   subdiv_levels=2)
    # Central fountain (smaller than central district)
    add_object("CmD_FountBase", build_cylinder("cmd_fb", 1.0, 0.30, segs=20),
               mat_marble_white, coll, loc=(bx, by, 0.15), bevel_width=0.01)
    add_object("CmD_FountWater", build_cylinder("cmd_fw", 0.92, 0.06, segs=20),
               mat_water, coll, loc=(bx, by, 0.33))
    # 4 wooden benches
    for sx, sy in [(-1.8, 0), (1.8, 0), (0, -1.8), (0, 1.8)]:
        add_object(f"CmD_Bench_{sx}_{sy}",
                   build_cube(f"cmd_b_{sx}_{sy}", 0.9, 0.25, 0.08, bevel_offset=0.01),
                   mat_wood_light, coll, loc=(bx + sx, by + sy, 0.30))
        add_object(f"CmD_BenchBack_{sx}_{sy}",
                   build_cube(f"cmd_bb_{sx}_{sy}", 0.9, 0.04, 0.40, bevel_offset=0.01),
                   mat_wood_light, coll, loc=(bx + sx, by + sy + 0.12, 0.55))
        # Legs
        for px in [-0.40, 0.40]:
            add_object(f"CmD_BenchLeg_{sx}_{sy}_{px}",
                       build_cube(f"cmd_bl_{sx}_{sy}_{px}", 0.06, 0.20, 0.30, bevel_offset=0.005),
                       mat_iron, coll, loc=(bx + sx + px, by + sy, 0.15))

def build_workshop_district(x_off, y_off):
    """Dirt + gravel ground with crates, barrels, anvil."""
    coll = district_colls["workshop"]
    bx, by = x_off, y_off
    # Dirt ground
    add_object("WD_Floor", build_plane("wd_floor", 7, 7), mat_dirt_gravel, coll, loc=(bx, by, 0))
    # Stone tile section in front of forge
    add_object("WD_StoneTile",
               build_cube("wd_stone", 3.0, 1.5, 0.06, bevel_offset=0.01),
               mat_cobblestone, coll, loc=(bx, by - 1.5, 0.03))
    # Massive central forge anvil
    add_object("WD_AnvilBase", build_cylinder("wd_ab", 0.40, 0.60, segs=14),
               mat_iron, coll, loc=(bx, by - 1.0, 0.30))
    add_object("WD_AnvilTop",
               build_cube("wd_at", 0.85, 0.30, 0.25, bevel_offset=0.02),
               mat_iron, coll, loc=(bx, by - 1.0, 0.75), bevel_width=0.005)
    add_object("WD_AnvilHorn", build_cylinder("wd_ah", 0.12, 0.40, segs=12),
               mat_iron, coll, loc=(bx + 0.55, by - 1.0, 0.75),
               rot=(0, math.radians(90), 0))
    # 4 wooden crates stacked
    for i, (sx, sy, sz) in enumerate([(2.0, -2.5, 0.30), (2.0, -1.7, 0.30), (2.0, -2.5, 0.90), (-2.5, 0, 0.30)]):
        add_object(f"WD_Crate_{i}",
                   build_cube(f"wd_cr_{i}", 0.55, 0.55, 0.55, bevel_offset=0.025),
                   mat_wood_dark, coll, loc=(bx + sx, by + sy, sz), bevel_width=0.005)
    # 3 barrels
    for i, (sx, sy) in enumerate([(-2.5, -2.0), (-2.5, 2.0), (2.5, 2.0)]):
        add_object(f"WD_BarrelBody_{i}",
                   build_cylinder(f"wd_bb_{i}", 0.32, 0.85, segs=18),
                   mat_wood_dark, coll, loc=(bx + sx, by + sy, 0.43))
        # Iron bands (2)
        for h in [0.25, 0.65]:
            add_object(f"WD_BarrelBand_{i}_{h}",
                       build_torus(f"wd_bnd_{i}_{h}", 0.34, 0.025),
                       mat_iron, coll, loc=(bx + sx, by + sy, h),
                       rot=(math.radians(90), 0, 0))
    # Hanging worklight
    add_object("WD_LightPost", build_cylinder("wd_lp", 0.05, 2.0),
               mat_iron, coll, loc=(bx, by + 0.5, 1.0))
    add_object("WD_LightArm", build_cube("wd_la", 0.04, 0.04, 0.7, bevel_offset=0.005),
               mat_iron, coll, loc=(bx, by + 0.85, 1.95),
               rot=(math.radians(90), 0, 0))
    add_object("WD_LightBulb", build_sphere("wd_lb", 0.12, subs=3),
               mat_lantern_warm, coll, loc=(bx, by + 1.20, 1.95), subdiv_levels=1)

def build_docks_district(x_off, y_off):
    """Wooden boardwalk at sea level with wet planks."""
    coll = district_colls["docks"]
    bx, by = x_off, y_off
    # Sea water plane
    add_object("DD_Sea", build_plane("dd_sea", 7, 7),
               mat_water, coll, loc=(bx, by, -0.20))
    # Boardwalk planks (raised + wet)
    add_object("DD_Boardwalk", build_cube("dd_bw", 5.0, 2.0, 0.10, bevel_offset=0.01),
               mat_wet_planks, coll, loc=(bx, by, 0.05))
    # Side cross planks (raised slightly)
    for i in range(8):
        add_object(f"DD_Plank_{i}",
                   build_cube(f"dd_p_{i}", 5.0, 0.20, 0.08, bevel_offset=0.005),
                   mat_wet_planks, coll, loc=(bx, by - 0.85 + i*0.25, 0.10))
    # 4 dock posts (vertical pillars going into water)
    for sx in [-2.0, 0, 2.0]:
        add_object(f"DD_Post_{sx}",
                   build_cylinder(f"dd_post_{sx}", 0.15, 1.4),
                   mat_wood_dark, coll, loc=(bx + sx, by + 0.95, -0.6))
        # Rope wrapping (decorative torus)
        add_object(f"DD_PostRope_{sx}",
                   build_torus(f"dd_pr_{sx}", 0.18, 0.025),
                   mat_dock_rope, coll, loc=(bx + sx, by + 0.95, 0.30),
                   rot=(math.radians(90), 0, 0))
    # Mooring posts (taller, on opposite side)
    for sx in [-2.0, 2.0]:
        add_object(f"DD_MoorPost_{sx}",
                   build_cylinder(f"dd_mp_{sx}", 0.18, 1.6),
                   mat_wood_dark, coll, loc=(bx + sx, by - 0.95, -0.5))
        add_object(f"DD_MoorTop_{sx}", build_sphere(f"dd_mt_{sx}", 0.22, subs=3),
                   mat_brass, coll, loc=(bx + sx, by - 0.95, 0.40), subdiv_levels=1)
    # Fish basket (cylinder with rope handle)
    add_object("DD_Basket", build_cylinder("dd_basket", 0.30, 0.50, segs=14),
               mat_wood_light, coll, loc=(bx + 0.7, by - 0.40, 0.35))
    # Hanging cool blue lanterns (dock atmosphere)
    for sx in [-1.5, 1.5]:
        add_object(f"DD_LantPost_{sx}", build_cylinder(f"dd_ltp_{sx}", 0.04, 1.4),
                   mat_iron, coll, loc=(bx + sx, by - 0.5, 0.85))
        add_object(f"DD_Lantern_{sx}",
                   build_cube(f"dd_lt_{sx}", 0.16, 0.16, 0.20, bevel_offset=0.01),
                   mat_lantern_cool, coll, loc=(bx + sx, by - 0.5, 1.65), bevel_width=0.005)

# ============================================================
# BUILD ALL DISTRICTS — laid out in a 3x2 grid
# ============================================================

print("=== Building 6 town districts ===")
LAYOUT = [
    ("central", build_central_district, -16, -8),
    ("residential", build_residential_district, 0, -8),
    ("market", build_market_district, 16, -8),
    ("commons", build_commons_district, -16, 8),
    ("workshop", build_workshop_district, 0, 8),
    ("docks", build_docks_district, 16, 8),
]
for name, builder, x, y in LAYOUT:
    print(f"  Building {name} at ({x}, {y})")
    builder(x, y)

# ============================================================
# CAMERAS
# ============================================================

def add_camera(name, loc, rot, lens=50):
    cd = bpy.data.cameras.new(name)
    cd.lens = lens
    cd.dof.use_dof = True
    cd.dof.aperture_fstop = 4.0
    cd.dof.focus_distance = 9.0
    co = bpy.data.objects.new(name, cd)
    co.location = loc
    co.rotation_euler = rot
    scene.collection.objects.link(co)
    link_to(co, col_cam)
    return co

# Per-district hero cams
hero_cams = {}
for name, _, x, y in LAYOUT:
    hero_cams[name] = add_camera(f"Cam_{name}",
        (x + 5, y - 7, 5), (math.radians(72), 0, math.radians(35)), 45)

# ============================================================
# LIGHTS — warm cinematic
# ============================================================

def add_area_light(name, loc, color, energy, size, rot=(math.radians(45), 0, 0)):
    ld = bpy.data.lights.new(name, type='AREA')
    ld.energy = energy
    ld.size = size
    ld.color = color
    obj = bpy.data.objects.new(name, ld)
    obj.location = loc
    obj.rotation_euler = rot
    scene.collection.objects.link(obj)
    link_to(obj, col_lights)
    return obj

# Warm sun key
sun_data = bpy.data.lights.new("Sun", type='SUN')
sun_data.energy = 3.0
sun_data.color = (1.0, 0.92, 0.78)
sun_obj = bpy.data.objects.new("Sun", sun_data)
sun_obj.rotation_euler = (math.radians(50), math.radians(-25), 0)
scene.collection.objects.link(sun_obj)
link_to(sun_obj, col_lights)

# Cool fill area
add_area_light("Fill", (0, 0, 30), (0.65, 0.78, 1.0), 1500, 25,
              rot=(math.radians(45), 0, 0))

world = bpy.data.worlds.new("World_Districts")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.45, 0.55, 0.75, 1.0)
bg.inputs['Strength'].default_value = 1.2

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# ============================================================
# RENDERS
# ============================================================

def hide_districts_except(visible_name):
    for name, coll in district_colls.items():
        for obj in coll.objects:
            obj.hide_render = (name != visible_name)

print("=== Rendering 6 district hero shots ===")
for name, _, _, _ in LAYOUT:
    hide_districts_except(name)
    scene.camera = hero_cams[name]
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_district_{name}_hero.png")
    bpy.ops.render.render(write_still=True)

# ============================================================
# EXPORT GLBs
# ============================================================

print("=== Exporting 6 district GLBs ===")
for name, coll in district_colls.items():
    bpy.ops.object.select_all(action='DESELECT')
    for obj in coll.objects:
        obj.hide_render = False
        obj.select_set(True)
    glb_path = os.path.join(EXPORT_DIR, f"district_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=glb_path, export_format='GLB',
        use_selection=True, export_apply=True, export_yup=True,
    )
    print(f"Exported: {glb_path}")
    for obj in coll.objects:
        obj.select_set(False)

print("=== V3 Epic 07 Town District Refinement complete ===")
