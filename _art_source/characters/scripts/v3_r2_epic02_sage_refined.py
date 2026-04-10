"""
Expansion V3 — ROUND 2 — Epic R2-02 — AI Sage Refinement
========================================================
Round 2 of the AI Sage hero. Round 1 used procedural shaders only;
this round adds:
  - Smart UV Project unwrapping on every body part
  - Vertex color painting per-part w/ deterministic hash
  - Multi-resolution modifier (2-level Catmull-Clark)
  - Bevel with 5 segments
  - Vertex-color-aware SSS-enabled sage skin shader
  - Higher subdivision counts (32+ verts on hero parts)

3 pose variations:
  MEDITATE — seated lotus, hands on knees, eyes closed
  TEACH    — standing, staff raised in right hand pointing, left hand
              gesturing forward
  SPELL    — standing, both arms raised channeling magic orb above head

Outputs: 4 hero renders @ 1920x1080 + 1 GLB.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(102)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_r2_sage.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 128
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3r2_sage_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.05, 0.04, 0.06, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# REFINED VC-AWARE SHADERS
# ============================================================
def make_refined_skin(name, base_color, accent_color):
    """Vertex-color-aware SSS skin. SSS adds the warm sub-surface glow,
    vertex color drives micro hue variation, UV-driven noise adds
    pore texture."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.55
    bsdf.inputs["Subsurface Weight"].default_value = 0.30
    bsdf.inputs["Subsurface Radius"].default_value = (1.2, 0.5, 0.3)
    bsdf.inputs["Subsurface Scale"].default_value = 0.25
    links.new(bsdf.outputs[0], out.inputs[0])

    # Vertex color attribute
    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    # UV-based pore texture
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (8, 8, 8)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 0)
    n.inputs["Scale"].default_value = 80.0  # fine pore detail
    n.inputs["Detail"].default_value = 4.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    # VC mix → base/accent
    vc_mix = nodes.new("ShaderNodeMix"); vc_mix.data_type = 'RGBA'; vc_mix.location = (-200, 200)
    vc_mix.inputs[6].default_value = (*base_color, 1)
    vc_mix.inputs[7].default_value = (*accent_color, 1)
    links.new(sep_vc.outputs["Red"], vc_mix.inputs["Factor"])

    # Curvature dirt
    g = nodes.new("ShaderNodeNewGeometry"); g.location = (-200, -200)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -200)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.30, 0.20, 0.12, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(g.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type = 'RGBA'; md.location = (350, 0)
    md.inputs["Factor"].default_value = 0.30
    links.new(vc_mix.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])
    # Subsurface tint follows base
    links.new(md.outputs[2], bsdf.inputs["Subsurface Radius"])

    # Pore bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (350, -350)
    bp.inputs["Strength"].default_value = 0.25
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_refined_robe(name, base_color, accent_color):
    """Vertex-color-aware fabric. Heavy weave bump from voronoi."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.85
    links.new(bsdf.outputs[0], out.inputs[0])

    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (6, 6, 6)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    # Voronoi weave
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, 0)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = 60.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])

    # Noise color variation
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    n_ramp = nodes.new("ShaderNodeValToRGB"); n_ramp.location = (-450, 200)
    n_ramp.color_ramp.elements[0].position = 0.35
    n_ramp.color_ramp.elements[0].color = (base_color[0]*0.78, base_color[1]*0.78, base_color[2]*0.78, 1)
    n_ramp.color_ramp.elements[1].position = 0.70
    n_ramp.color_ramp.elements[1].color = (min(base_color[0]*1.22,1), min(base_color[1]*1.22,1), min(base_color[2]*1.22,1), 1)
    links.new(n.outputs["Fac"], n_ramp.inputs["Fac"])

    vc_mix = nodes.new("ShaderNodeMix"); vc_mix.data_type = 'RGBA'; vc_mix.location = (-200, 200)
    vc_mix.inputs[6].default_value = (*base_color, 1)
    vc_mix.inputs[7].default_value = (*accent_color, 1)
    links.new(sep_vc.outputs["Red"], vc_mix.inputs["Factor"])

    final_mix = nodes.new("ShaderNodeMix"); final_mix.data_type = 'RGBA'; final_mix.location = (50, 100)
    final_mix.inputs["Factor"].default_value = 0.55
    links.new(vc_mix.outputs[2], final_mix.inputs[6])
    links.new(n_ramp.outputs["Color"], final_mix.inputs[7])

    g = nodes.new("ShaderNodeNewGeometry"); g.location = (-200, -200)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -200)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.10, 0.07, 0.04, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(g.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type = 'RGBA'; md.location = (350, 0)
    md.inputs["Factor"].default_value = 0.40
    links.new(final_mix.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    # Weave bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (350, -300)
    bp.inputs["Strength"].default_value = 0.40
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_pbr_simple(name, color, rough, metal=0.0, em=None, em_str=0):
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
mat_skin     = make_refined_skin("v3r2_sage_skin",
                                  base_color=(0.85, 0.72, 0.55),
                                  accent_color=(0.95, 0.82, 0.65))
mat_robe     = make_refined_robe("v3r2_robe",
                                  base_color=(0.18, 0.30, 0.62),
                                  accent_color=(0.25, 0.40, 0.78))
mat_robe_inner = make_refined_robe("v3r2_robe_inner",
                                    base_color=(0.42, 0.18, 0.18),
                                    accent_color=(0.55, 0.25, 0.25))
mat_beard    = make_pbr_simple("v3r2_beard", (0.92, 0.88, 0.82), 0.85)
mat_staff    = make_pbr_simple("v3r2_staff", (0.32, 0.18, 0.08), 0.85)
mat_gem      = make_emit("v3r2_gem", (0.45, 0.85, 1.0), 12.0)
mat_gold     = make_pbr_simple("v3r2_gold", (0.95, 0.78, 0.20), 0.10, 1.0,
                                em=(1.0, 0.85, 0.40), em_str=1.0)
mat_eye      = make_emit("v3r2_eye", (0.30, 0.95, 1.0), 14.0)
mat_floor    = make_pbr_simple("v3r2_floor", (0.10, 0.10, 0.12), 0.30, 0.10)

# ============================================================
# UTIL — refined helpers (UV unwrap + vertex color + multires)
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

def add_refined_modifiers(obj, multires_level=2, bevel_segments=5):
    obj.modifiers.new("Multires", 'MULTIRES')
    bpy.context.view_layer.objects.active = obj
    for _ in range(multires_level):
        bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')
    bv = obj.modifiers.new("Bevel", 'BEVEL')
    bv.width = 0.020; bv.segments = bevel_segments; bv.profile = 0.7
    for poly in obj.data.polygons:
        poly.use_smooth = True

def refined_part(name, primitive_op, mat, parent, vc_red=0.5, vc_var=0.4, multires=2, **kwargs):
    primitive_op(**kwargs)
    o = bpy.context.object
    o.name = name
    o.data.materials.append(mat)
    o.parent = parent
    uv_unwrap(o)
    paint_vertex_color(o, base_red=vc_red, variation=vc_var)
    add_refined_modifiers(o, multires_level=multires)
    return o

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=32, multires=2):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=24, rot=(0,0,0), multires=2):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=18, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cone_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_box(name, loc, scale, mat, parent, vc_red=0.5, vc_var=0.4, rot=(0,0,0), multires=2):
    o = refined_part(name, bpy.ops.mesh.primitive_cube_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     size=1, location=loc)
    o.scale = scale
    o.rotation_euler = rot
    return o

def r_torus(name, loc, R, r, mat, parent, vc_red=0.5, vc_var=0.4, ms=48, mn=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_torus_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     major_segments=ms, minor_segments=mn,
                     major_radius=R, minor_radius=r, location=loc)
    o.rotation_euler = rot
    return o

# ============================================================
# REFINED AI SAGE BUILDER
# ============================================================
def build_sage(origin, pose="meditate"):
    p = bpy.data.objects.new(f"sage_{pose}", None); scene.collection.objects.link(p)
    p.location = origin

    # Determine seated vs standing
    if pose == "meditate":
        body_z = 0.50  # seated, lower
        # Robe is pyramid skirted out (lotus pose)
        r_cone("robe_skirt", (0, 0, 0.30), 0.95, 0.55, 0.55, mat_robe, p,
                vc_red=0.55, vc_var=0.30, verts=32, multires=2)
        # Crossed legs hint (2 small spheres)
        r_sphere("knee_l", (-0.40, 0.10, 0.40), 0.18, mat_robe, p, segs=20)
        r_sphere("knee_r", (0.40, 0.10, 0.40), 0.18, mat_robe, p, segs=20)
        body_z_offset = 0.0
    else:
        body_z = 1.05  # standing, normal
        # Robe is tall conical pyramid
        r_cone("robe", (0, 0, 0.55), 0.85, 0.50, 1.10, mat_robe, p,
                vc_red=0.55, vc_var=0.30, verts=32, multires=2)
        body_z_offset = 0.0

    # === Body / chest ===
    body = r_sphere("body", (0, 0, body_z + 0.50), 0.42, mat_robe, p,
                     vc_red=0.55, vc_var=0.30, segs=32, multires=2)
    body.scale = (1.0, 0.85, 1.2)

    # === Inner robe trim (red sash crossing chest) ===
    r_box("sash", (0, 0.32, body_z + 0.50), (0.85, 0.04, 0.30), mat_robe_inner, p,
           vc_red=0.6, vc_var=0.25, rot=(0, 0, 0.3))
    # === Belt ===
    r_torus("belt", (0, 0, body_z + 0.10), 0.50, 0.06, mat_gold, p,
             vc_red=0.7, vc_var=0.20, ms=64, mn=16)

    # === Arms — pose-specific ===
    if pose == "meditate":
        # Both arms resting on knees, palms up
        r_cyl("arm_lu", (-0.50, 0, body_z + 0.30), 0.10, 0.40, mat_robe, p,
              verts=20, rot=(0, -0.3, 0))
        r_cyl("arm_ll", (-0.55, 0.15, body_z), 0.09, 0.35, mat_robe, p, verts=20, rot=(1.0, 0, 0))
        r_sphere("hand_l", (-0.50, 0.30, body_z - 0.05), 0.10, mat_skin, p,
                  vc_red=0.55, vc_var=0.20, segs=20)
        r_cyl("arm_ru", (0.50, 0, body_z + 0.30), 0.10, 0.40, mat_robe, p,
              verts=20, rot=(0, 0.3, 0))
        r_cyl("arm_rl", (0.55, 0.15, body_z), 0.09, 0.35, mat_robe, p, verts=20, rot=(1.0, 0, 0))
        r_sphere("hand_r", (0.50, 0.30, body_z - 0.05), 0.10, mat_skin, p,
                  vc_red=0.55, vc_var=0.20, segs=20)
    elif pose == "teach":
        # Right arm raised holding staff, left arm gesturing forward
        r_cyl("arm_lu", (-0.55, 0.10, body_z + 0.50), 0.10, 0.50, mat_robe, p,
              verts=20, rot=(0.6, 0, 0))
        r_cyl("arm_ll", (-0.55, 0.55, body_z + 0.40), 0.09, 0.45, mat_robe, p,
              verts=20, rot=(1.4, 0, 0))
        r_sphere("hand_l", (-0.55, 0.85, body_z + 0.40), 0.10, mat_skin, p, segs=20)
        r_cyl("arm_ru", (0.55, 0, body_z + 0.50), 0.10, 0.50, mat_robe, p,
              verts=20, rot=(0, 0.2, 0))
        r_cyl("arm_rl", (0.65, 0, body_z + 0.05), 0.09, 0.45, mat_robe, p, verts=20)
        r_sphere("hand_r", (0.65, 0, body_z - 0.20), 0.10, mat_skin, p, segs=20)
        # Staff held in right hand (vertical)
        r_cyl("staff_shaft", (0.65, 0, body_z + 0.30), 0.04, 2.40, mat_staff, p, verts=14)
        # Staff top — gem in claw
        r_sphere("staff_gem", (0.65, 0, body_z + 1.55), 0.10, mat_gem, p, segs=18)
        # Claw cradling gem
        for j in range(4):
            ang = j * math.pi / 2
            cx = 0.65 + math.cos(ang) * 0.10
            cy = math.sin(ang) * 0.10
            r_cone(f"claw_{j}", (cx, cy, body_z + 1.45), 0.025, 0.0, 0.20, mat_gold, p,
                    verts=8, rot=(math.cos(ang)*0.8, math.sin(ang)*0.8, ang))
    else:  # spell
        # Both arms raised, channeling magic above head
        r_cyl("arm_lu", (-0.55, 0.10, body_z + 0.60), 0.10, 0.50, mat_robe, p,
              verts=20, rot=(0, -0.5, 0))
        r_cyl("arm_ll", (-0.40, 0.10, body_z + 1.00), 0.09, 0.45, mat_robe, p,
              verts=20, rot=(0, -1.0, 0))
        r_sphere("hand_l", (-0.20, 0.10, body_z + 1.20), 0.10, mat_skin, p, segs=20)
        r_cyl("arm_ru", (0.55, 0.10, body_z + 0.60), 0.10, 0.50, mat_robe, p,
              verts=20, rot=(0, 0.5, 0))
        r_cyl("arm_rl", (0.40, 0.10, body_z + 1.00), 0.09, 0.45, mat_robe, p,
              verts=20, rot=(0, 1.0, 0))
        r_sphere("hand_r", (0.20, 0.10, body_z + 1.20), 0.10, mat_skin, p, segs=20)
        # Spell orb between hands
        r_sphere("spell_orb", (0, 0.10, body_z + 1.30), 0.18, mat_gem, p, segs=24)
        # Spell rings around orb
        r_torus("spell_r1", (0, 0.10, body_z + 1.30), 0.25, 0.015, mat_gem, p,
                 ms=32, mn=8, rot=(math.pi/2, 0, 0))
        r_torus("spell_r2", (0, 0.10, body_z + 1.30), 0.25, 0.015, mat_gem, p,
                 ms=32, mn=8, rot=(0, math.pi/2, 0))

    # === Hood (sphere with front cut implied via inner darker face) ===
    hood = r_sphere("hood", (0, 0, body_z + 1.05), 0.32, mat_robe, p,
                     vc_red=0.55, vc_var=0.25, segs=24)
    hood.scale = (1.05, 1.05, 1.10)
    # === Inner face (darker recess) ===
    r_sphere("face", (0, 0.05, body_z + 1.00), 0.24, mat_skin, p,
              vc_red=0.55, vc_var=0.25, segs=24)
    # === Eyes (closed slits if meditating, open glow if teaching/spelling) ===
    if pose == "meditate":
        r_box("eye_l_closed", (-0.08, 0.20, body_z + 1.02), (0.05, 0.005, 0.005), mat_skin, p,
               vc_red=0.40, vc_var=0.10)
        r_box("eye_r_closed", (0.08, 0.20, body_z + 1.02), (0.05, 0.005, 0.005), mat_skin, p,
               vc_red=0.40, vc_var=0.10)
    else:
        r_sphere("eye_l", (-0.08, 0.22, body_z + 1.02), 0.04, mat_eye, p, segs=14)
        r_sphere("eye_r", (0.08, 0.22, body_z + 1.02), 0.04, mat_eye, p, segs=14)

    # === Long flowing beard (3-segment cone curving forward) ===
    r_cone("beard_top", (0, 0.18, body_z + 0.85), 0.08, 0.12, 0.20, mat_beard, p,
            vc_red=0.45, vc_var=0.20, verts=14, rot=(0.4, 0, 0))
    r_cone("beard_mid", (0, 0.30, body_z + 0.65), 0.12, 0.10, 0.30, mat_beard, p,
            vc_red=0.45, vc_var=0.20, verts=14, rot=(0.5, 0, 0))
    r_cone("beard_tip", (0, 0.40, body_z + 0.40), 0.10, 0.04, 0.30, mat_beard, p,
            vc_red=0.45, vc_var=0.20, verts=12, rot=(0.6, 0, 0))

    # === Hood golden trim ===
    r_torus("hood_trim", (0, 0, body_z + 0.85), 0.34, 0.02, mat_gold, p,
             vc_red=0.7, vc_var=0.15, ms=32, mn=10)

    # === Halo behind head ===
    r_torus("halo", (0, -0.30, body_z + 1.20), 0.42, 0.02, mat_gold, p,
             vc_red=0.7, vc_var=0.15, ms=48, mn=12, rot=(math.pi/2, 0, 0))

    return p

# ============================================================
# SCENE LAYOUT — 3 sage poses on plinth
# ============================================================
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "r2_floor"; fl.scale = (12, 4, 0.10)
fl.data.materials.append(mat_floor)
bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in fl.data.polygons: poly.use_smooth = True

build_sage(Vector((-3.2, 0, 0)), pose="meditate")
build_sage(Vector((0.0,  0, 0)), pose="teach")
build_sage(Vector((3.2,  0, 0)), pose="spell")

# ============================================================
# LIGHTING — V3-29 cinematic_sunset with subtle warm bias
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(6, -8, 8))
key = bpy.context.object
key.data.energy = 1900; key.data.color = (1.0, 0.78, 0.45); key.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(-6, 6, 6))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.45, 0.55, 0.95); fill.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(0, 8, 4))
rim = bpy.context.object
rim.data.energy = 950; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 6

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_group  = add_cam("cam_group",    Vector((0, -7, 3.5)), Vector((0, 0, 1.5)), lens=35, dof_dist=8)
cam_med    = add_cam("cam_meditate", Vector((-3.2, -3, 1.8)), Vector((-3.2, 0, 1.0)), lens=70, dof_dist=3.5, fstop=3.5)
cam_teach  = add_cam("cam_teach",    Vector((0, -3, 2.2)), Vector((0, 0, 1.7)), lens=70, dof_dist=3.5, fstop=3.5)
cam_spell  = add_cam("cam_spell",    Vector((3.2, -3, 2.5)), Vector((3.2, 0, 2.0)), lens=70, dof_dist=3.5, fstop=3.5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("group",    cam_group),
    ("meditate", cam_med),
    ("teach",    cam_teach),
    ("spell",    cam_spell),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_sage_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

bpy.ops.object.select_all(action='SELECT')
out_path = os.path.join(EXPORT_DIR, "sage_r2_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-02 AI Sage Refinement complete ===")
