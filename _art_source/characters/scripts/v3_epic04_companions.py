"""
Expansion V3 — Epic 04 — Companion Texture Pass
====================================================
4 companion variants with role-themed silhouettes:
  - Tank: heavy beveled cube body + shield+axe + plate armor
  - DPS: lean elongated sphere body + rifle + sniper visor
  - Healer: cone-robed silhouette + tall staff with glowing orb
  - Utility: compact ico body + twin floating orbs (no held weapon)

Each companion gets:
  - Subdivision surface + bevel modifiers
  - Procedural PBR materials with shader graph (noise + voronoi + curvature
    dirt + fresnel rim + procedural normal)
  - Per-companion accent color for instant identification
  - Hero shot, portrait, and pet visual

Outputs:
  - 4 hero shot renders at 1920x1080
  - 4 portrait renders at 720x960
  - 4 pet renders at 256x256 transparent
  - 4 GLB exports for Godot
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_companions_hero.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/renders"
EXPORT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/exports"
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

def make_pbr_advanced(name, base_color, roughness=0.5, metallic=0.0,
                      emission_color=None, emission_strength=0.0,
                      noise_strength=0.18, voronoi_strength=0.10,
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
        noise.inputs["Detail"].default_value = 6.0
        links.new(mapping.outputs["Vector"], noise.inputs["Vector"])

        ramp = nodes.new("ShaderNodeValToRGB")
        ramp.location = (-450, 200)
        ramp.color_ramp.elements[0].position = 0.40
        ramp.color_ramp.elements[0].color = (
            base_color[0] * 0.85, base_color[1] * 0.85, base_color[2] * 0.85, 1)
        ramp.color_ramp.elements[1].position = 0.65
        ramp.color_ramp.elements[1].color = (
            min(base_color[0] * 1.15, 1), min(base_color[1] * 1.15, 1),
            min(base_color[2] * 1.15, 1), 1)
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
        v.inputs["Scale"].default_value = 22.0
        links.new(mapping.outputs["Vector"], v.inputs["Vector"])

        v_ramp = nodes.new("ShaderNodeValToRGB")
        v_ramp.location = (-450, -100)
        v_ramp.color_ramp.elements[0].position = 0.05
        v_ramp.color_ramp.elements[1].position = 0.20
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
        md.inputs["Factor"].default_value = 0.30
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
# COMPANION PALETTES
# ============================================================
COMPANIONS = {
    "tank": {
        "shell": (0.30, 0.30, 0.40),
        "accent": (0.95, 0.65, 0.20),
        "weapon": "shield_axe",
        "build": "heavy",
        "metallic_shell": 0.40,
    },
    "dps": {
        "shell": (0.20, 0.45, 0.65),
        "accent": (0.95, 0.85, 0.30),
        "weapon": "rifle",
        "build": "lean",
        "metallic_shell": 0.30,
    },
    "healer": {
        "shell": (0.85, 0.85, 0.92),
        "accent": (0.30, 0.85, 0.55),
        "weapon": "staff",
        "build": "robed",
        "metallic_shell": 0.10,
    },
    "utility": {
        "shell": (0.55, 0.30, 0.85),
        "accent": (1.0, 0.55, 0.20),
        "weapon": "twin_orbs",
        "build": "compact",
        "metallic_shell": 0.25,
    },
}

# Build per-companion materials
companion_mats = {}
for cid, c in COMPANIONS.items():
    companion_mats[cid] = {
        "shell": make_pbr_advanced(f"v3_comp_{cid}_shell",
            base_color=c["shell"], roughness=0.40, metallic=c["metallic_shell"],
            noise_strength=0.18, voronoi_strength=0.10),
        "accent": make_pbr_advanced(f"v3_comp_{cid}_accent",
            base_color=c["accent"], roughness=0.20, metallic=0.92,
            emission_color=c["accent"], emission_strength=2.5,
            voronoi_strength=0.15, fresnel_rim=True),
        "metal": make_pbr_advanced(f"v3_comp_{cid}_metal",
            base_color=(0.55, 0.55, 0.60), roughness=0.30, metallic=0.95,
            noise_strength=0.10),
        "dark": make_pbr_advanced(f"v3_comp_{cid}_dark",
            base_color=(0.05, 0.05, 0.08), roughness=0.65, metallic=0.10,
            noise_strength=0.20),
        "skin": make_pbr_advanced(f"v3_comp_{cid}_skin",
            base_color=(0.85, 0.72, 0.60), roughness=0.55, metallic=0.0,
            noise_strength=0.10, bump_strength=0.05, bump_scale=80.0),
        "aura": make_pbr_advanced(f"v3_comp_{cid}_aura",
            base_color=c["accent"], roughness=0.5, metallic=0.0,
            emission_color=c["accent"], emission_strength=3.5,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "visor": make_pbr_advanced(f"v3_comp_{cid}_visor",
            base_color=(0.05, 0.10, 0.20), roughness=0.08, metallic=0.3,
            emission_color=c["accent"], emission_strength=4.0,
            fresnel_rim=True, curvature_dirt=False, noise_strength=0),
    }

# ============================================================
# COLLECTIONS
# ============================================================

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_tank = make_coll("Comp_Tank")
col_dps = make_coll("Comp_DPS")
col_healer = make_coll("Comp_Healer")
col_utility = make_coll("Comp_Utility")
col_pets = make_coll("Comp_Pets")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

comp_colls = {"tank": col_tank, "dps": col_dps, "healer": col_healer, "utility": col_utility}

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_object(name, mesh, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1),
               subdiv_levels=2, render_levels=3, bevel_width=0.0):
    obj = bpy.data.objects.new(name, mesh)
    obj.location = loc
    obj.rotation_euler = rot
    obj.scale = scale
    if mat is not None:
        obj.data.materials.append(mat)
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    for poly in obj.data.polygons:
        poly.use_smooth = True
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

# ============================================================
# MESH BUILDERS
# ============================================================

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

def build_cylinder(name, r, h, segs=20):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_cone(name, r1, r2, h, segs=12):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_cube(name, sx, sy, sz, bevel_offset=0.0):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    if bevel_offset > 0:
        bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=bevel_offset, segments=3, profile=0.5, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_torus(name, major, minor, segs=32):
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

def build_heavy_body():
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.55, 0.55, 0.70), verts=bm.verts)
    bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=0.18, segments=4, profile=0.5, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("heavy_body"); bm.to_mesh(me); bm.free()
    return me

def build_lean_body():
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=14, radius=0.32)
    bmesh.ops.scale(bm, vec=(1, 0.7, 1.4), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("lean_body"); bm.to_mesh(me); bm.free()
    return me

def build_robed_body():
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=20, radius1=0.30, radius2=0.55, depth=1.2)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("robed_body"); bm.to_mesh(me); bm.free()
    return me

def build_compact_body():
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.45)
    bmesh.ops.scale(bm, vec=(0.9, 0.9, 1.1), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("compact_body"); bm.to_mesh(me); bm.free()
    return me

# ============================================================
# COMPANION BUILDER
# ============================================================

def build_companion(cid, x_off):
    spec = COMPANIONS[cid]
    m = companion_mats[cid]
    coll = comp_colls[cid]
    build = spec["build"]

    # === Body per build kind ===
    if build == "heavy":
        body_mesh = build_heavy_body()
        body_z = 0.7
    elif build == "lean":
        body_mesh = build_lean_body()
        body_z = 0.85
    elif build == "robed":
        body_mesh = build_robed_body()
        body_z = 0.6
    else:  # compact
        body_mesh = build_compact_body()
        body_z = 0.65

    add_object(f"{cid}_Body", body_mesh, m["shell"], coll,
               loc=(x_off, 0, body_z), subdiv_levels=2, render_levels=3,
               bevel_width=0.02 if build in ("heavy", "compact") else 0.0)

    # Head
    add_object(f"{cid}_Head", build_uvsphere(f"{cid}_head", 0.30, scale=(1, 0.95, 1.05)),
               m["shell"], coll, loc=(x_off, 0, 1.55), subdiv_levels=2, render_levels=3)

    # Visor
    add_object(f"{cid}_Visor", build_uvsphere(f"{cid}_visor", 0.22, u=24, v=14, scale=(1, 0.4, 0.5)),
               m["visor"], coll, loc=(x_off, -0.18, 1.60), subdiv_levels=1)

    # Eyes
    add_object(f"{cid}_EyeL", build_sphere(f"{cid}_eye_l", 0.04), m["accent"], coll,
               loc=(x_off-0.08, -0.22, 1.62), subdiv_levels=1)
    add_object(f"{cid}_EyeR", build_sphere(f"{cid}_eye_r", 0.04), m["accent"], coll,
               loc=(x_off+0.08, -0.22, 1.62), subdiv_levels=1)

    # Chest emblem
    add_object(f"{cid}_ChestEmblem", build_sphere(f"{cid}_chest", 0.12, subs=3), m["accent"], coll,
               loc=(x_off, -0.32, 0.95), subdiv_levels=1)

    # Arms
    for side in [-1, 1]:
        add_object(f"{cid}_Arm_{side}", build_cylinder(f"{cid}_arm_{side}", 0.13, 0.7),
                   m["shell"], coll, loc=(x_off + side*0.55, 0, 0.5), subdiv_levels=1)
        add_object(f"{cid}_Hand_{side}", build_sphere(f"{cid}_hand_{side}", 0.13, subs=2),
                   m["shell"], coll, loc=(x_off + side*0.55, 0, 0.18), subdiv_levels=1)

    # Legs
    for side in [-1, 1]:
        add_object(f"{cid}_Leg_{side}", build_cylinder(f"{cid}_leg_{side}", 0.15, 0.6),
                   m["shell"], coll, loc=(x_off + side*0.22, 0, 0.0), subdiv_levels=1)
        add_object(f"{cid}_Boot_{side}",
                   build_cube(f"{cid}_boot_{side}", 0.18, 0.26, 0.10, bevel_offset=0.02),
                   m["dark"], coll, loc=(x_off + side*0.22, 0, -0.25), subdiv_levels=1, bevel_width=0.005)

    # === Per-class weapon ===
    weapon = spec["weapon"]
    if weapon == "shield_axe":
        # Shield in left hand
        add_object(f"{cid}_Shield",
                   build_cube(f"{cid}_shield", 0.10, 0.55, 0.95, bevel_offset=0.02),
                   m["metal"], coll, loc=(x_off - 0.7, -0.20, 0.55),
                   subdiv_levels=1, bevel_width=0.005)
        add_object(f"{cid}_ShieldEmblem", build_sphere(f"{cid}_shield_emblem", 0.18, subs=2),
                   m["accent"], coll, loc=(x_off - 0.65, -0.25, 0.55), subdiv_levels=1)
        # Axe in right hand
        add_object(f"{cid}_AxeShaft", build_cylinder(f"{cid}_axe_shaft", 0.04, 0.7),
                   m["dark"], coll, loc=(x_off + 0.65, -0.05, 0.40), subdiv_levels=1)
        add_object(f"{cid}_AxeHead",
                   build_cube(f"{cid}_axe_head", 0.20, 0.05, 0.30, bevel_offset=0.01),
                   m["metal"], coll, loc=(x_off + 0.65, -0.05, 0.85),
                   subdiv_levels=1, bevel_width=0.005)
    elif weapon == "rifle":
        # Long rifle held diagonally
        add_object(f"{cid}_RifleBody",
                   build_cube(f"{cid}_rifle_body", 0.06, 0.06, 0.95, bevel_offset=0.005),
                   m["metal"], coll, loc=(x_off + 0.4, -0.1, 0.85),
                   rot=(math.radians(60), 0, 0), subdiv_levels=1)
        add_object(f"{cid}_RifleScope",
                   build_cube(f"{cid}_rifle_scope", 0.04, 0.10, 0.20, bevel_offset=0.005),
                   m["dark"], coll, loc=(x_off + 0.4, -0.18, 1.05),
                   rot=(math.radians(60), 0, 0), subdiv_levels=1)
        add_object(f"{cid}_RifleStock",
                   build_cube(f"{cid}_rifle_stock", 0.06, 0.15, 0.25, bevel_offset=0.005),
                   m["dark"], coll, loc=(x_off + 0.4, -0.05, 0.55),
                   rot=(math.radians(60), 0, 0), subdiv_levels=1)
    elif weapon == "staff":
        # Tall staff
        add_object(f"{cid}_StaffShaft", build_cylinder(f"{cid}_staff_shaft", 0.04, 1.6),
                   m["dark"], coll, loc=(x_off + 0.65, -0.05, 0.0), subdiv_levels=1)
        # Orb at top
        add_object(f"{cid}_StaffOrb", build_sphere(f"{cid}_staff_orb", 0.15, subs=3),
                   m["accent"], coll, loc=(x_off + 0.65, -0.05, 1.7), subdiv_levels=1)
        # Glow ring
        add_object(f"{cid}_StaffRing", build_torus(f"{cid}_staff_ring", 0.20, 0.025),
                   m["accent"], coll, loc=(x_off + 0.65, -0.05, 1.7),
                   rot=(math.radians(90), 0, 0), subdiv_levels=1)
    elif weapon == "twin_orbs":
        # 2 floating orbs beside hands
        add_object(f"{cid}_OrbL", build_sphere(f"{cid}_orb_l", 0.15, subs=3), m["accent"], coll,
                   loc=(x_off - 0.65, -0.10, 0.5), subdiv_levels=1)
        add_object(f"{cid}_OrbR", build_sphere(f"{cid}_orb_r", 0.15, subs=3), m["accent"], coll,
                   loc=(x_off + 0.65, -0.10, 0.5), subdiv_levels=1)

    # Aura ring at feet
    add_object(f"{cid}_AuraRing", build_torus(f"{cid}_aura", 0.85, 0.05),
               m["aura"], coll, loc=(x_off, 0, -0.32),
               rot=(math.radians(90), 0, 0), subdiv_levels=1)

# ============================================================
# BUILD ALL COMPANIONS
# ============================================================

print("=== Building 4 companion variants ===")
for i, cid in enumerate(["tank", "dps", "healer", "utility"]):
    x_off = (i - 1.5) * 3.0
    build_companion(cid, x_off)

# Pets — small floating attendants per companion
print("=== Building 4 pets ===")
for i, cid in enumerate(["tank", "dps", "healer", "utility"]):
    x_off = (i - 1.5) * 3.0 + 1.2
    m = companion_mats[cid]
    add_object(f"pet_{cid}_body", build_sphere(f"pet_body_{cid}", 0.20, subs=3), m["shell"],
               col_pets, loc=(x_off, 0.5, 0.20), subdiv_levels=1)
    add_object(f"pet_{cid}_head", build_sphere(f"pet_head_{cid}", 0.13, subs=2), m["shell"],
               col_pets, loc=(x_off, 0.5, 0.45), subdiv_levels=1)
    add_object(f"pet_{cid}_eye", build_sphere(f"pet_eye_{cid}", 0.04), m["accent"],
               col_pets, loc=(x_off, 0.40, 0.50), subdiv_levels=1)
    add_object(f"pet_{cid}_aura", build_torus(f"pet_aura_{cid}", 0.30, 0.02), m["accent"],
               col_pets, loc=(x_off, 0.5, 0.05), rot=(math.radians(90), 0, 0), subdiv_levels=1)

# ============================================================
# CAMERAS
# ============================================================

def add_camera(name, loc, rot, lens=85):
    cd = bpy.data.cameras.new(name)
    cd.lens = lens
    cd.dof.use_dof = True
    cd.dof.aperture_fstop = 1.8
    cd.dof.focus_distance = 5.5
    co = bpy.data.objects.new(name, cd)
    co.location = loc
    co.rotation_euler = rot
    scene.collection.objects.link(co)
    link_to(co, col_cam)
    return co

# Per-companion hero + portrait cameras
hero_cams = {}
portrait_cams = {}
for i, cid in enumerate(["tank", "dps", "healer", "utility"]):
    x_off = (i - 1.5) * 3.0
    hero_cams[cid] = add_camera(f"Cam_Hero_{cid}", (x_off + 1.5, -4.5, 1.6),
                                 (math.radians(80), 0, math.radians(20)), 75)
    portrait_cams[cid] = add_camera(f"Cam_Portrait_{cid}", (x_off, -3.0, 1.5),
                                     (math.radians(85), 0, 0), 85)

pet_cam = add_camera("Cam_Pet", (0, -3, 0.8), (math.radians(80), 0, 0), 60)

# ============================================================
# LIGHTS
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

add_area_light("Key", (-3, -5, 5), (1.0, 0.95, 0.85), 1500, 5,
              rot=(math.radians(45), math.radians(-25), 0))
add_area_light("Fill", (4, -3, 4), (0.65, 0.78, 1.0), 400, 6,
              rot=(math.radians(50), math.radians(20), 0))
add_area_light("Rim", (0, 4, 4), (1.0, 0.85, 0.65), 800, 4,
              rot=(math.radians(120), 0, 0))

world = bpy.data.worlds.new("World_Comp")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.02, 0.03, 0.06, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# ============================================================
# RENDERS
# ============================================================

print("=== Rendering 4 hero shots ===")
for cid, coll in comp_colls.items():
    for k2, c2 in comp_colls.items():
        for obj in c2.objects:
            obj.hide_render = (k2 != cid)
    # Hide pets initially
    for obj in col_pets.objects:
        obj.hide_render = True
    scene.camera = hero_cams[cid]
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_companion_{cid}_hero.png")
    bpy.ops.render.render(write_still=True)

print("=== Rendering 4 portraits ===")
scene.render.resolution_x = 720
scene.render.resolution_y = 960
for cid, coll in comp_colls.items():
    for k2, c2 in comp_colls.items():
        for obj in c2.objects:
            obj.hide_render = (k2 != cid)
    scene.camera = portrait_cams[cid]
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_companion_{cid}_portrait.png")
    bpy.ops.render.render(write_still=True)

print("=== Rendering 4 pets ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
# Hide all companions
for k2, c2 in comp_colls.items():
    for obj in c2.objects:
        obj.hide_render = True

pet_groups = {}
for obj in col_pets.objects:
    for cid in COMPANIONS.keys():
        if f"pet_{cid}" in obj.name:
            pet_groups.setdefault(cid, []).append(obj)
            break

for cid, objs in pet_groups.items():
    for obj in col_pets.objects:
        obj.hide_render = obj not in objs
    scene.camera = pet_cam
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    pet_cam.location = (cx, cy - 1.4, 0.7)
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_companion_pet_{cid}.png")
    bpy.ops.render.render(write_still=True)

# ============================================================
# EXPORT GLBs
# ============================================================

print("=== Exporting 4 companion GLBs ===")
for cid, coll in comp_colls.items():
    bpy.ops.object.select_all(action='DESELECT')
    for obj in coll.objects:
        obj.hide_render = False
        obj.select_set(True)
    glb_path = os.path.join(EXPORT_DIR, f"companion_{cid}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=glb_path,
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_yup=True,
    )
    print(f"Exported: {glb_path}")
    # Deselect for next round
    for obj in coll.objects:
        obj.select_set(False)

print("=== V3 Epic 04 Companion Texture Pass complete ===")
