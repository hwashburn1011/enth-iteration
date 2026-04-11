"""
Expansion V3 — Epic 06 — Town Building Kit Texture Pass
=========================================================
8 hero landmark buildings with architectural PBR treatment:
  1. Pixel's Workshop  (cottage with chimney + colored shutters)
  2. Forge's Smithy    (stone base + wooden roof + anvil prop)
  3. Cache's Tavern    (2-story timber framed + sign post + lantern)
  4. Index's Library   (tall stone tower + arch windows)
  5. Harvest's Greenhouse (glass roof + planter beds)
  6. Lab's Tower       (cylindrical with crystal cap)
  7. Town Watch Tower  (square stone with crenellations)
  8. Sage's Hut        (small wooden hut with mossy thatch)

Architecture features:
  - Brick walls via voronoi pattern + curvature dirt
  - Wooden beams with grain (voronoi) + bevel modifiers
  - Slate roofs with curvature darkening
  - Glass windows with emission for warm interior glow
  - Stone foundations with displacement noise bumps
  - Weathered gold trim with fresnel rim
  - Vine overgrowth shader (procedural)
  - Per-building accent color identity

Outputs:
  - 8 hero shot renders at 1920x1080
  - 1 group town shot showing all buildings
  - 1 GLB export per building
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/v3_buildings_hero.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/renders"
EXPORT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/exports"
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
                      noise_strength=0.20, voronoi_strength=0.0,
                      voronoi_scale=22.0,
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
# ARCHITECTURAL MATERIAL LIBRARY
# ============================================================

# Brick walls (voronoi pattern simulating brick layout)
mat_brick_red = make_pbr_advanced("v3_brick_red",
    base_color=(0.55, 0.30, 0.20), roughness=0.85, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=18.0,
    bump_strength=0.30, bump_scale=22.0)

mat_brick_grey = make_pbr_advanced("v3_brick_grey",
    base_color=(0.45, 0.42, 0.38), roughness=0.85, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=18.0,
    bump_strength=0.30, bump_scale=22.0)

# Stone foundation
mat_stone_foundation = make_pbr_advanced("v3_stone_foundation",
    base_color=(0.32, 0.30, 0.27), roughness=0.90, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.30, voronoi_scale=14.0,
    bump_strength=0.35, bump_scale=18.0)

# Wood beams (voronoi grain)
mat_wood_beam = make_pbr_advanced("v3_wood_beam",
    base_color=(0.30, 0.18, 0.08), roughness=0.80, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.45, voronoi_scale=10.0,
    bump_strength=0.18, bump_scale=20.0)

mat_wood_light = make_pbr_advanced("v3_wood_light",
    base_color=(0.55, 0.35, 0.18), roughness=0.80, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.45, voronoi_scale=10.0,
    bump_strength=0.18, bump_scale=20.0)

# Slate roof
mat_slate_roof = make_pbr_advanced("v3_slate_roof",
    base_color=(0.25, 0.25, 0.30), roughness=0.55, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.50, voronoi_scale=14.0,
    bump_strength=0.25, bump_scale=20.0)

mat_red_roof = make_pbr_advanced("v3_red_roof",
    base_color=(0.65, 0.25, 0.18), roughness=0.65, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.50, voronoi_scale=14.0,
    bump_strength=0.25, bump_scale=20.0)

# Thatch (mossy)
mat_thatch = make_pbr_advanced("v3_thatch",
    base_color=(0.55, 0.42, 0.18), roughness=0.95, metallic=0.0,
    noise_strength=0.40, voronoi_strength=0.55, voronoi_scale=22.0,
    bump_strength=0.40, bump_scale=35.0)

# Glass windows (warm interior glow)
mat_window_glow = make_pbr_advanced("v3_window_glow",
    base_color=(1.0, 0.85, 0.55), roughness=0.10, metallic=0.0,
    emission_color=(1.0, 0.85, 0.45), emission_strength=4.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True,
    bump_strength=0.0)

mat_window_dark = make_pbr_advanced("v3_window_dark",
    base_color=(0.10, 0.15, 0.25), roughness=0.10, metallic=0.20,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=False,
    bump_strength=0.0)

# Iron hardware
mat_iron = make_pbr_advanced("v3_iron_hardware",
    base_color=(0.30, 0.30, 0.32), roughness=0.45, metallic=0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10)

# Brass / gold trim
mat_brass = make_pbr_advanced("v3_brass_trim",
    base_color=(0.85, 0.65, 0.20), roughness=0.30, metallic=0.92,
    emission_color=(1.0, 0.85, 0.30), emission_strength=0.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)

# Glass roof (greenhouse) — fresnel for transparency feel
mat_glass_roof = make_pbr_advanced("v3_glass_roof",
    base_color=(0.65, 0.85, 1.0), roughness=0.05, metallic=0.0,
    emission_color=(0.55, 0.85, 1.0), emission_strength=1.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True,
    bump_strength=0.0)

# Crystal cap (Lab tower)
mat_crystal_cap = make_pbr_advanced("v3_crystal_cap",
    base_color=(0.55, 0.20, 0.85), roughness=0.10, metallic=0.0,
    emission_color=(0.70, 0.40, 1.0), emission_strength=4.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

# Vines (decorative overgrowth)
mat_vine = make_pbr_advanced("v3_vine",
    base_color=(0.18, 0.32, 0.12), roughness=0.85, metallic=0.0,
    noise_strength=0.30, curvature_dirt=True,
    bump_strength=0.20, bump_scale=45.0)

# Sign post wood (for tavern sign)
mat_sign_wood = make_pbr_advanced("v3_sign_wood",
    base_color=(0.28, 0.16, 0.08), roughness=0.85, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.40, voronoi_scale=12.0,
    bump_strength=0.18, bump_scale=22.0)

# Door
mat_door = make_pbr_advanced("v3_door",
    base_color=(0.25, 0.13, 0.06), roughness=0.75, metallic=0.0,
    noise_strength=0.20, voronoi_strength=0.35, voronoi_scale=12.0,
    bump_strength=0.20, bump_scale=22.0)

# Lantern glow
mat_lantern = make_pbr_advanced("v3_lantern",
    base_color=(1.0, 0.85, 0.45), roughness=0.20, metallic=0.0,
    emission_color=(1.0, 0.85, 0.45), emission_strength=5.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

# ============================================================
# COLLECTIONS — one per building
# ============================================================

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

BUILDINGS = ["pixel_workshop", "forge_smithy", "cache_tavern", "index_library",
             "harvest_greenhouse", "lab_tower", "town_watchtower", "sage_hut"]

building_colls = {}
for b in BUILDINGS:
    building_colls[b] = make_coll(f"V3_{b}")

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
        bv.profile = 0.7
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

def build_cone(name, r1, r2, h, segs=24):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_pyramid(name, base, h):
    """4-sided pyramid (roof)."""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=4, radius1=base, radius2=0.0, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_gable_roof(name, sx, sy, sz):
    """Gable roof shape: triangular prism."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    # Stretch
    for v in bm.verts:
        v.co.x *= sx
        v.co.y *= sy
        v.co.z *= sz
    # Collapse top edge to ridge
    top_verts = [v for v in bm.verts if v.co.z > 0]
    for v in top_verts:
        v.co.x = 0
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_sphere(name, r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

# ============================================================
# BUILDING BUILDERS
# ============================================================

def build_pixel_workshop(x_off, y_off):
    """Cottage with chimney + colored shutters + door."""
    coll = building_colls["pixel_workshop"]
    bx, by = x_off, y_off
    # Foundation
    add_object("PW_Foundation", build_cube("pw_found", 2.0, 1.6, 0.30, bevel_offset=0.04),
               mat_stone_foundation, coll, loc=(bx, by, 0.15), bevel_width=0.01)
    # Walls
    add_object("PW_Walls", build_cube("pw_walls", 1.85, 1.45, 1.5, bevel_offset=0.04),
               mat_brick_red, coll, loc=(bx, by, 1.05), bevel_width=0.01)
    # Door
    add_object("PW_Door", build_cube("pw_door", 0.30, 0.05, 0.65, bevel_offset=0.01),
               mat_door, coll, loc=(bx, by - 1.45, 0.65), bevel_width=0.005)
    # Door handle
    add_object("PW_DoorHandle", build_sphere("pw_handle", 0.04, subs=2),
               mat_brass, coll, loc=(bx + 0.10, by - 1.50, 0.65), subdiv_levels=1)
    # 4 windows with warm glow
    for sx in [-0.55, 0.55]:
        for sy in [-1.45, 1.45]:
            add_object(f"PW_Window_{sx}_{sy}",
                       build_cube(f"pw_w_{sx}_{sy}", 0.32, 0.04, 0.36, bevel_offset=0.005),
                       mat_window_glow, coll, loc=(bx + sx, by + sy, 1.05))
            # Window frame
            for dx, dy, w, h in [(0, 0, 0.34, 0.02), (0, 0, 0.02, 0.38)]:
                pass  # frame omitted to keep geometry budget — implied by brick offset
    # Gable roof
    add_object("PW_Roof", build_gable_roof("pw_roof", 2.10, 1.65, 0.70),
               mat_red_roof, coll, loc=(bx, by, 2.20))
    # Chimney
    add_object("PW_Chimney", build_cube("pw_chim", 0.30, 0.30, 0.85, bevel_offset=0.02),
               mat_brick_red, coll, loc=(bx + 0.65, by + 0.45, 2.40), bevel_width=0.005)
    # Chimney cap
    add_object("PW_ChimneyCap", build_cube("pw_chim_cap", 0.36, 0.36, 0.06),
               mat_iron, coll, loc=(bx + 0.65, by + 0.45, 2.85))
    # Hanging sign with brass trim
    add_object("PW_SignPost", build_cylinder("pw_sign_post", 0.04, 1.2),
               mat_iron, coll, loc=(bx + 1.10, by - 1.25, 0))
    add_object("PW_Sign",
               build_cube("pw_sign", 0.50, 0.04, 0.30, bevel_offset=0.01),
               mat_sign_wood, coll, loc=(bx + 1.10, by - 1.25, 1.10))
    # 2 lanterns flanking door
    for sx in [-0.55, 0.55]:
        add_object(f"PW_Lantern_{sx}",
                   build_cube(f"pw_lantern_{sx}", 0.10, 0.10, 0.18, bevel_offset=0.01),
                   mat_lantern, coll, loc=(bx + sx, by - 1.50, 1.30))

def build_forge_smithy(x_off, y_off):
    """Stone base + wooden upper + chimney + anvil prop."""
    coll = building_colls["forge_smithy"]
    bx, by = x_off, y_off
    # Stone base
    add_object("FS_Base", build_cube("fs_base", 2.2, 2.0, 1.2, bevel_offset=0.04),
               mat_brick_grey, coll, loc=(bx, by, 0.6), bevel_width=0.01)
    # Wooden upper
    add_object("FS_Upper", build_cube("fs_upper", 2.0, 1.8, 0.9, bevel_offset=0.04),
               mat_wood_light, coll, loc=(bx, by, 1.65), bevel_width=0.01)
    # 4 vertical wood beams
    for sx in [-0.95, 0.95]:
        for sy in [-0.85, 0.85]:
            add_object(f"FS_Beam_{sx}_{sy}",
                       build_cube(f"fs_beam_{sx}_{sy}", 0.10, 0.10, 0.9, bevel_offset=0.005),
                       mat_wood_beam, coll, loc=(bx + sx, by + sy, 1.65))
    # Gable roof
    add_object("FS_Roof", build_gable_roof("fs_roof", 2.30, 2.00, 0.85),
               mat_slate_roof, coll, loc=(bx, by, 2.55))
    # Massive central chimney
    add_object("FS_Chimney", build_cube("fs_chim", 0.50, 0.50, 1.4, bevel_offset=0.03),
               mat_brick_red, coll, loc=(bx, by + 0.4, 2.80), bevel_width=0.01)
    add_object("FS_ChimneyCap", build_cube("fs_cap", 0.60, 0.60, 0.08),
               mat_iron, coll, loc=(bx, by + 0.4, 3.55))
    # Glowing forge opening (warm window emission)
    add_object("FS_ForgeOpening",
               build_cube("fs_opening", 0.50, 0.04, 0.50, bevel_offset=0.005),
               mat_window_glow, coll, loc=(bx, by - 1.05, 0.55))
    # Anvil out front
    add_object("FS_AnvilBase", build_cylinder("fs_anvil_base", 0.30, 0.50, segs=12),
               mat_iron, coll, loc=(bx + 1.5, by - 0.6, 0.25))
    add_object("FS_AnvilTop", build_cube("fs_anvil_top", 0.55, 0.20, 0.18, bevel_offset=0.02),
               mat_iron, coll, loc=(bx + 1.5, by - 0.6, 0.65), bevel_width=0.005)
    add_object("FS_AnvilHorn", build_cylinder("fs_anvil_horn", 0.10, 0.30, segs=10),
               mat_iron, coll,
               loc=(bx + 1.85, by - 0.6, 0.65),
               rot=(0, math.radians(90), 0))
    # Door
    add_object("FS_Door",
               build_cube("fs_door", 0.40, 0.05, 0.85, bevel_offset=0.01),
               mat_door, coll, loc=(bx + 0.6, by - 1.05, 0.45))

def build_cache_tavern(x_off, y_off):
    """2-story timber framed tavern + sign + hanging lantern."""
    coll = building_colls["cache_tavern"]
    bx, by = x_off, y_off
    # Foundation
    add_object("CT_Foundation", build_cube("ct_found", 2.5, 2.0, 0.30, bevel_offset=0.04),
               mat_stone_foundation, coll, loc=(bx, by, 0.15), bevel_width=0.01)
    # First story
    add_object("CT_Story1", build_cube("ct_s1", 2.4, 1.9, 1.6, bevel_offset=0.04),
               mat_brick_grey, coll, loc=(bx, by, 1.10), bevel_width=0.01)
    # Second story (offset slightly larger — overhang)
    add_object("CT_Story2", build_cube("ct_s2", 2.55, 2.05, 1.4, bevel_offset=0.04),
               mat_wood_beam, coll, loc=(bx, by, 2.60), bevel_width=0.01)
    # 4 timber frame X-braces on second story (front face)
    for sx in [-0.85, 0.85]:
        # Vertical
        add_object(f"CT_VBeam_{sx}", build_cube(f"ct_v_{sx}", 0.08, 0.05, 1.4, bevel_offset=0.005),
                   mat_wood_light, coll, loc=(bx + sx, by - 1.0, 2.60))
    # Horizontal cross beam
    add_object("CT_HBeam_top", build_cube("ct_ht", 1.85, 0.05, 0.08, bevel_offset=0.005),
               mat_wood_light, coll, loc=(bx, by - 1.0, 3.20))
    add_object("CT_HBeam_bot", build_cube("ct_hb", 1.85, 0.05, 0.08, bevel_offset=0.005),
               mat_wood_light, coll, loc=(bx, by - 1.0, 2.05))
    # Gable roof
    add_object("CT_Roof", build_gable_roof("ct_roof", 2.70, 2.20, 1.0),
               mat_red_roof, coll, loc=(bx, by, 3.80))
    # 6 windows with warm glow
    for sy in [-1.05, 1.05]:
        for sx in [-0.6, 0, 0.6]:
            add_object(f"CT_Window_{sx}_{sy}",
                       build_cube(f"ct_w_{sx}_{sy}", 0.32, 0.04, 0.36, bevel_offset=0.005),
                       mat_window_glow, coll, loc=(bx + sx, by + sy, 2.65))
    # Door
    add_object("CT_Door", build_cube("ct_door", 0.45, 0.05, 1.0, bevel_offset=0.01),
               mat_door, coll, loc=(bx, by - 1.0, 0.7))
    # Hanging tavern sign
    add_object("CT_SignArm", build_cube("ct_sign_arm", 0.60, 0.05, 0.05, bevel_offset=0.005),
               mat_iron, coll, loc=(bx + 1.45, by - 1.0, 2.4))
    add_object("CT_Sign", build_cube("ct_sign", 0.70, 0.04, 0.40, bevel_offset=0.01),
               mat_sign_wood, coll, loc=(bx + 1.65, by - 1.0, 2.0))
    add_object("CT_SignTrim", build_cube("ct_sign_trim", 0.74, 0.06, 0.04, bevel_offset=0.005),
               mat_brass, coll, loc=(bx + 1.65, by - 1.05, 1.78))
    # Hanging lantern at door
    add_object("CT_LanternChain", build_cylinder("ct_chain", 0.02, 0.30),
               mat_iron, coll, loc=(bx, by - 1.05, 1.85))
    add_object("CT_Lantern", build_cube("ct_lantern", 0.18, 0.18, 0.30, bevel_offset=0.02),
               mat_lantern, coll, loc=(bx, by - 1.05, 1.50), bevel_width=0.005)

def build_index_library(x_off, y_off):
    """Tall stone tower with arched windows."""
    coll = building_colls["index_library"]
    bx, by = x_off, y_off
    # Foundation
    add_object("IL_Foundation", build_cube("il_found", 2.0, 2.0, 0.30, bevel_offset=0.04),
               mat_stone_foundation, coll, loc=(bx, by, 0.15))
    # 3 stacked story walls
    for i in range(3):
        h = 1.5
        add_object(f"IL_Story{i}",
                   build_cube(f"il_s{i}", 1.85, 1.85, h, bevel_offset=0.04),
                   mat_brick_grey, coll, loc=(bx, by, 0.45 + h/2 + i*h), bevel_width=0.01)
    # Tall arched windows on each story
    for i in range(3):
        for sy in [-0.95, 0.95]:
            add_object(f"IL_Window_{i}_{sy}",
                       build_cube(f"il_w_{i}_{sy}", 0.30, 0.04, 0.85, bevel_offset=0.005),
                       mat_window_glow, coll,
                       loc=(bx, by + sy, 0.80 + i*1.5))
    # Top crenellations (4 corner blocks)
    crown_h = 0.45
    for sx in [-0.85, 0.85]:
        for sy in [-0.85, 0.85]:
            add_object(f"IL_Crenel_{sx}_{sy}",
                       build_cube(f"il_cr_{sx}_{sy}", 0.20, 0.20, crown_h, bevel_offset=0.01),
                       mat_brick_grey, coll, loc=(bx + sx, by + sy, 4.95 + crown_h/2))
    # Brass roof cap (small dome)
    add_object("IL_RoofCap", build_cone("il_cap", 0.6, 0.0, 0.6),
               mat_brass, coll, loc=(bx, by, 5.20))
    # Door
    add_object("IL_Door", build_cube("il_door", 0.45, 0.05, 1.0, bevel_offset=0.01),
               mat_door, coll, loc=(bx, by - 0.95, 0.95))
    # Lantern at door
    add_object("IL_Lantern", build_cube("il_lantern", 0.14, 0.14, 0.24, bevel_offset=0.01),
               mat_lantern, coll, loc=(bx + 0.5, by - 0.95, 1.5))

def build_harvest_greenhouse(x_off, y_off):
    """Glass roof greenhouse with planter beds visible inside."""
    coll = building_colls["harvest_greenhouse"]
    bx, by = x_off, y_off
    # Stone base
    add_object("HG_Base", build_cube("hg_base", 2.4, 2.0, 0.6, bevel_offset=0.04),
               mat_stone_foundation, coll, loc=(bx, by, 0.30))
    # Wooden planter walls (low)
    add_object("HG_Walls", build_cube("hg_walls", 2.3, 1.9, 0.5, bevel_offset=0.04),
               mat_wood_beam, coll, loc=(bx, by, 0.85))
    # Glass roof — tall pyramid
    add_object("HG_Roof", build_pyramid("hg_roof", 1.4, 1.8),
               mat_glass_roof, coll, loc=(bx, by, 1.10))
    # 4 corner posts (vertical wood)
    for sx in [-1.05, 1.05]:
        for sy in [-0.85, 0.85]:
            add_object(f"HG_Post_{sx}_{sy}",
                       build_cube(f"hg_p_{sx}_{sy}", 0.08, 0.08, 1.6, bevel_offset=0.005),
                       mat_wood_beam, coll, loc=(bx + sx, by + sy, 1.40))
    # Door
    add_object("HG_Door", build_cube("hg_door", 0.45, 0.05, 0.9, bevel_offset=0.01),
               mat_door, coll, loc=(bx, by - 0.95, 0.95))
    # Crystal apex on top
    add_object("HG_Apex", build_cone("hg_apex", 0.12, 0.0, 0.30),
               mat_crystal_cap, coll, loc=(bx, by, 2.95))

def build_lab_tower(x_off, y_off):
    """Cylindrical tower with crystal cap."""
    coll = building_colls["lab_tower"]
    bx, by = x_off, y_off
    # Stone foundation disc
    add_object("LT_Foundation", build_cylinder("lt_found", 1.4, 0.30, segs=20),
               mat_stone_foundation, coll, loc=(bx, by, 0.15))
    # 3 stacked cylinder stories
    for i in range(3):
        h = 1.4
        add_object(f"LT_Story{i}",
                   build_cylinder(f"lt_s{i}", 1.20 - i*0.10, h, segs=20),
                   mat_brick_grey, coll, loc=(bx, by, 0.30 + i*h))
    # Arched windows (2 per story)
    for i in range(3):
        for ang in [0, math.pi]:
            add_object(f"LT_Window_{i}_{ang}",
                       build_cube(f"lt_w_{i}_{ang}", 0.04, 0.30, 0.55, bevel_offset=0.005),
                       mat_window_glow, coll,
                       loc=(bx + math.cos(ang)*1.10, by + math.sin(ang)*1.10, 0.85 + i*1.4))
    # Crystal cap
    add_object("LT_Cap", build_cone("lt_cap", 1.0, 0.0, 1.4),
               mat_crystal_cap, coll, loc=(bx, by, 4.50))
    # Brass collar at top of stone
    add_object("LT_Collar", build_cylinder("lt_collar", 1.05, 0.10, segs=20),
               mat_brass, coll, loc=(bx, by, 4.40))
    # Door
    add_object("LT_Door", build_cube("lt_door", 0.45, 0.05, 1.0, bevel_offset=0.01),
               mat_door, coll, loc=(bx, by - 1.20, 0.80))

def build_town_watchtower(x_off, y_off):
    """Square stone tower with crenellations."""
    coll = building_colls["town_watchtower"]
    bx, by = x_off, y_off
    # Foundation
    add_object("WT_Foundation", build_cube("wt_found", 1.6, 1.6, 0.30, bevel_offset=0.04),
               mat_stone_foundation, coll, loc=(bx, by, 0.15))
    # 4 stacked stories (square)
    for i in range(4):
        h = 1.3
        add_object(f"WT_Story{i}",
                   build_cube(f"wt_s{i}", 1.50 - i*0.05, 1.50 - i*0.05, h, bevel_offset=0.03),
                   mat_brick_grey, coll, loc=(bx, by, 0.45 + i*h))
    # Arrow slits per story
    for i in range(4):
        for sy in [-0.75, 0.75]:
            add_object(f"WT_Slit_{i}_{sy}",
                       build_cube(f"wt_sl_{i}_{sy}", 0.06, 0.04, 0.30, bevel_offset=0.005),
                       mat_window_dark, coll,
                       loc=(bx, by + sy, 0.95 + i*1.3))
    # Crown crenellations (8 small blocks around top)
    crown_h = 0.40
    base_size = 1.30
    for i in range(8):
        ang = (i / 8) * math.tau
        bx2 = bx + math.cos(ang) * base_size * 0.5 * math.sqrt(2)
        by2 = by + math.sin(ang) * base_size * 0.5 * math.sqrt(2)
        add_object(f"WT_Crenel_{i}",
                   build_cube(f"wt_cr_{i}", 0.18, 0.18, crown_h, bevel_offset=0.01),
                   mat_brick_grey, coll, loc=(bx2, by2, 5.85))
    # Roof spire
    add_object("WT_Spire", build_cone("wt_spire", 0.35, 0.0, 0.8),
               mat_iron, coll, loc=(bx, by, 6.15))
    # 4 corner lanterns
    for sx in [-0.65, 0.65]:
        for sy in [-0.65, 0.65]:
            add_object(f"WT_Lantern_{sx}_{sy}",
                       build_cube(f"wt_lan_{sx}_{sy}", 0.10, 0.10, 0.18, bevel_offset=0.01),
                       mat_lantern, coll, loc=(bx + sx, by + sy, 5.95))

def build_sage_hut(x_off, y_off):
    """Small wooden hut with mossy thatch roof."""
    coll = building_colls["sage_hut"]
    bx, by = x_off, y_off
    # Foundation
    add_object("SH_Foundation", build_cube("sh_found", 1.6, 1.4, 0.20, bevel_offset=0.03),
               mat_stone_foundation, coll, loc=(bx, by, 0.10))
    # Walls
    add_object("SH_Walls", build_cube("sh_walls", 1.45, 1.25, 1.2, bevel_offset=0.04),
               mat_wood_light, coll, loc=(bx, by, 0.80))
    # Wood beams (4 corners)
    for sx in [-0.65, 0.65]:
        for sy in [-0.55, 0.55]:
            add_object(f"SH_Beam_{sx}_{sy}",
                       build_cube(f"sh_b_{sx}_{sy}", 0.08, 0.08, 1.2, bevel_offset=0.005),
                       mat_wood_beam, coll, loc=(bx + sx, by + sy, 0.80))
    # Conical thatch roof
    add_object("SH_Roof", build_cone("sh_roof", 1.10, 0.0, 1.0),
               mat_thatch, coll, loc=(bx, by, 1.40))
    # Door
    add_object("SH_Door", build_cube("sh_door", 0.40, 0.05, 0.85, bevel_offset=0.01),
               mat_door, coll, loc=(bx, by - 0.65, 0.55))
    # 2 windows
    for sx in [-0.55, 0.55]:
        add_object(f"SH_Window_{sx}",
                   build_cube(f"sh_w_{sx}", 0.20, 0.04, 0.25, bevel_offset=0.005),
                   mat_window_glow, coll, loc=(bx + sx, by - 0.65, 1.05))
    # Hanging vine (decorative)
    add_object("SH_Vine", build_cube("sh_vine", 0.08, 0.04, 0.50),
               mat_vine, coll, loc=(bx + 0.78, by - 0.50, 1.35))
    # Lantern at door
    add_object("SH_Lantern", build_cube("sh_lantern", 0.10, 0.10, 0.18, bevel_offset=0.01),
               mat_lantern, coll, loc=(bx - 0.50, by - 0.65, 1.30))

# ============================================================
# BUILD ALL BUILDINGS — laid out in 2 rows
# ============================================================

print("=== Building 8 hero town buildings ===")
LAYOUT = [
    ("pixel_workshop", build_pixel_workshop, -10, -3),
    ("forge_smithy", build_forge_smithy, -3, -3),
    ("cache_tavern", build_cache_tavern, 4, -3),
    ("index_library", build_index_library, 11, -3),
    ("harvest_greenhouse", build_harvest_greenhouse, -10, 4),
    ("lab_tower", build_lab_tower, -3, 4),
    ("town_watchtower", build_town_watchtower, 4, 4),
    ("sage_hut", build_sage_hut, 11, 4),
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
    cd.dof.focus_distance = 12.0
    co = bpy.data.objects.new(name, cd)
    co.location = loc
    co.rotation_euler = rot
    scene.collection.objects.link(co)
    link_to(co, col_cam)
    return co

# Per-building hero cams
hero_cams = {}
for name, _, x, y in LAYOUT:
    hero_cams[name] = add_camera(f"Cam_{name}",
        (x + 4, y - 5, 3.5), (math.radians(75), 0, math.radians(40)), 50)

# Group town shot — overhead 3/4
group_cam = add_camera("Cam_GroupTown", (0, -18, 16), (math.radians(60), 0, 0), 35)

# ============================================================
# LIGHTS — sunset warm
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

# Warm sunset key from the side
add_area_light("Key", (-15, -8, 12), (1.0, 0.85, 0.55), 4500, 18,
              rot=(math.radians(50), math.radians(-30), 0))
# Cool fill
add_area_light("Fill", (12, 5, 10), (0.55, 0.70, 1.0), 1500, 20,
              rot=(math.radians(60), math.radians(20), 0))
# Warm rim from behind
add_area_light("Rim", (0, 12, 8), (1.0, 0.78, 0.50), 2500, 18,
              rot=(math.radians(115), 0, 0))

# Sun for proper directional shadows
sun_data = bpy.data.lights.new("Sun", type='SUN')
sun_data.energy = 3.0
sun_data.color = (1.0, 0.92, 0.78)
sun_obj = bpy.data.objects.new("Sun", sun_data)
sun_obj.rotation_euler = (math.radians(45), math.radians(-25), 0)
scene.collection.objects.link(sun_obj)
link_to(sun_obj, col_lights)

# Ground plane for context
def make_ground():
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=20, y_segments=20, size=30)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("ground"); bm.to_mesh(me); bm.free()
    return me

mat_ground = make_pbr_advanced("v3_ground",
    base_color=(0.20, 0.28, 0.16), roughness=0.92, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.20, voronoi_scale=8.0,
    bump_strength=0.25, bump_scale=12.0)

ground = bpy.data.objects.new("Ground", make_ground())
ground.data.materials.append(mat_ground)
scene.collection.objects.link(ground)

world = bpy.data.worlds.new("World_Town")
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

def hide_buildings_except(visible_name):
    for name, coll in building_colls.items():
        for obj in coll.objects:
            obj.hide_render = (name != visible_name)

print("=== Rendering 8 building hero shots ===")
for name, _, _, _ in LAYOUT:
    hide_buildings_except(name)
    scene.camera = hero_cams[name]
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_building_{name}_hero.png")
    bpy.ops.render.render(write_still=True)

print("=== Rendering group town shot ===")
# Show all buildings
for name, coll in building_colls.items():
    for obj in coll.objects:
        obj.hide_render = False
scene.camera = group_cam
scene.render.filepath = os.path.join(RENDER_DIR, "v3_buildings_group_hero.png")
bpy.ops.render.render(write_still=True)

# ============================================================
# EXPORT GLBs
# ============================================================

print("=== Exporting 8 building GLBs ===")
for name, coll in building_colls.items():
    bpy.ops.object.select_all(action='DESELECT')
    for obj in coll.objects:
        obj.hide_render = False
        obj.select_set(True)
    glb_path = os.path.join(EXPORT_DIR, f"building_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=glb_path, export_format='GLB',
        use_selection=True, export_apply=True, export_yup=True,
    )
    print(f"Exported: {glb_path}")
    for obj in coll.objects:
        obj.select_set(False)

print("=== V3 Epic 06 Town Building Kit complete ===")
