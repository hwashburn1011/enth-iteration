"""
Expansion V3 — ROUND 2 — Epic R2-05 — Pet Refinement
====================================================
Round 2 of V3-05 Pets. 8 hero pets across 4 species categories,
each with bespoke species shader + Round 2 stack (UV unwrap +
vertex color paint + multires + 5-seg bevel + vertex-color-aware
shaders).

  FUR (2):     tabby_cat, fluffball
  FEATHER (2): wise_owl, songbird
  CHITIN (2):  rhino_beetle, sand_scorpion
  GLOW (2):    wisp_spirit, fox_spirit

Each pet ~15-25 mesh parts. Custom shaders per species:
  - Fur: vertex-color-aware + 80x noise bump for fine fur grain
  - Feather: 60x voronoi bump for feather texture + softer roughness
  - Chitin: voronoi cell pattern + coat layer for shine + dirt
  - Glow: SSS + transmission + emission + fresnel rim

Outputs: 5 hero renders @ 1920x1080 + 8 portraits @ 1024x1024 + 8 GLBs.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(105)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/pets/v3_r2_pets.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/pets/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/pets/exports"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
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

scene.world = bpy.data.worlds.new("v3r2_pets_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# SPECIES SHADERS — vertex-color-aware
# ============================================================
def make_vc_fur(name, base_color, accent_color):
    """Fur: high-frequency noise bump (80x scale) + VC tint mix."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.92
    bsdf.inputs["Subsurface Weight"].default_value = 0.12
    bsdf.inputs["Subsurface Radius"].default_value = (0.6, 0.4, 0.3)
    links.new(bsdf.outputs[0], out.inputs[0])

    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (8, 8, 8)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    # Coarse noise for color variation
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

    vc_mix = nodes.new("ShaderNodeMix"); vc_mix.data_type = 'RGBA'; vc_mix.location = (-200, 200)
    vc_mix.inputs[6].default_value = (*base_color, 1)
    vc_mix.inputs[7].default_value = (*accent_color, 1)
    links.new(sep_vc.outputs["Red"], vc_mix.inputs["Factor"])

    final_mix = nodes.new("ShaderNodeMix"); final_mix.data_type = 'RGBA'; final_mix.location = (50, 100)
    final_mix.inputs["Factor"].default_value = 0.55
    links.new(vc_mix.outputs[2], final_mix.inputs[6])
    links.new(n_ramp.outputs["Color"], final_mix.inputs[7])
    links.new(final_mix.outputs[2], bsdf.inputs["Base Color"])

    # FINE FUR BUMP from high-frequency noise
    bn = nodes.new("ShaderNodeTexNoise"); bn.location = (-700, -300)
    bn.inputs["Scale"].default_value = 80.0  # very fine fur grain
    bn.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], bn.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-450, -300)
    bp.inputs["Strength"].default_value = 0.55
    links.new(bn.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_vc_feather(name, base_color, accent_color):
    """Feather: voronoi bump for feather texture, softer roughness."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.78
    bsdf.inputs["Subsurface Weight"].default_value = 0.20
    bsdf.inputs["Subsurface Radius"].default_value = (0.5, 0.3, 0.2)
    bsdf.inputs["Sheen Weight"].default_value = 0.5
    bsdf.inputs["Sheen Tint"].default_value = (0.85, 0.78, 0.65, 1)
    links.new(bsdf.outputs[0], out.inputs[0])

    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (6, 6, 6)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 12.0
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
    links.new(final_mix.outputs[2], bsdf.inputs["Base Color"])

    # Voronoi feather pattern
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -300)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = 60.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-450, -300)
    bp.inputs["Strength"].default_value = 0.45
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_vc_chitin(name, base_color, accent_color):
    """Chitin: voronoi cells + coat layer + dirt."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.20
    bsdf.inputs["Metallic"].default_value = 0.30
    bsdf.inputs["Coat Weight"].default_value = 0.7
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    links.new(bsdf.outputs[0], out.inputs[0])

    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    # Cell voronoi for chitin plates
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, 200)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = 12.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    v_ramp = nodes.new("ShaderNodeValToRGB"); v_ramp.location = (-450, 200)
    v_ramp.color_ramp.elements[0].position = 0.05
    v_ramp.color_ramp.elements[0].color = (base_color[0]*0.55, base_color[1]*0.55, base_color[2]*0.55, 1)
    v_ramp.color_ramp.elements[1].position = 0.30
    v_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])

    vc_mix = nodes.new("ShaderNodeMix"); vc_mix.data_type = 'RGBA'; vc_mix.location = (-200, 200)
    vc_mix.inputs[6].default_value = (*base_color, 1)
    vc_mix.inputs[7].default_value = (*accent_color, 1)
    links.new(sep_vc.outputs["Red"], vc_mix.inputs["Factor"])

    final_mix = nodes.new("ShaderNodeMix"); final_mix.data_type = 'RGBA'; final_mix.location = (50, 100)
    final_mix.inputs["Factor"].default_value = 0.40
    links.new(vc_mix.outputs[2], final_mix.inputs[6])
    links.new(v_ramp.outputs["Color"], final_mix.inputs[7])

    # Curvature highlights brighten ridges
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-200, -200)
    cr = nodes.new("ShaderNodeValToRGB"); cr.location = (50, -200)
    cr.color_ramp.elements[0].position = 0.40
    cr.color_ramp.elements[0].color = (base_color[0]*0.5, base_color[1]*0.5, base_color[2]*0.5, 1)
    cr.color_ramp.elements[1].position = 0.75
    cr.color_ramp.elements[1].color = (min(base_color[0]*1.4, 1), min(base_color[1]*1.4, 1), min(base_color[2]*1.4, 1), 1)
    links.new(geo.outputs["Pointiness"], cr.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type = 'RGBA'; md.location = (350, 0)
    md.inputs["Factor"].default_value = 0.40
    links.new(final_mix.outputs[2], md.inputs[6])
    links.new(cr.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (350, -350)
    bp.inputs["Strength"].default_value = 0.40
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_vc_glow(name, base_color, accent_color):
    """Glow spirit: SSS + transmission + emission + fresnel rim."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1)
    bsdf.inputs["Roughness"].default_value = 0.10
    bsdf.inputs["Transmission Weight"].default_value = 0.45
    bsdf.inputs["IOR"].default_value = 1.10
    bsdf.inputs["Subsurface Weight"].default_value = 0.6
    bsdf.inputs["Subsurface Radius"].default_value = (1.5, 1.5, 1.5)
    bsdf.inputs["Subsurface Scale"].default_value = 0.4
    bsdf.inputs["Coat Weight"].default_value = 0.6
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    bsdf.inputs["Emission Color"].default_value = (*accent_color, 1)
    bsdf.inputs["Emission Strength"].default_value = 4.0
    links.new(bsdf.outputs[0], out.inputs[0])

    # Fresnel-driven extra rim glow
    fr = nodes.new("ShaderNodeFresnel"); fr.location = (-400, 0)
    fr.inputs["IOR"].default_value = 1.4
    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type='RGBA'; em_mix.location = (200, 100)
    em_mix.inputs[6].default_value = (*base_color, 1)
    em_mix.inputs[7].default_value = (1.0, 1.0, 1.0, 1)
    links.new(fr.outputs["Fac"], em_mix.inputs["Factor"])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])
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
# MATERIALS PER PET
# ============================================================
mats = {}
# Tabby cat
mats["tabby_fur"]   = make_vc_fur("v3r2p_tabby_fur", (0.55, 0.40, 0.22), (0.75, 0.55, 0.32))
mats["tabby_belly"] = make_vc_fur("v3r2p_tabby_belly", (0.92, 0.85, 0.72), (1.0, 0.95, 0.85))
# Fluffball
mats["fluff"]       = make_vc_fur("v3r2p_fluff", (0.95, 0.92, 0.88), (1.0, 0.98, 0.95))
# Owl
mats["owl_feather"] = make_vc_feather("v3r2p_owl_feather", (0.55, 0.42, 0.28), (0.75, 0.58, 0.40))
mats["owl_belly"]   = make_vc_feather("v3r2p_owl_belly", (0.92, 0.85, 0.72), (1.0, 0.95, 0.85))
# Songbird
mats["songbird_feather"] = make_vc_feather("v3r2p_song_feather", (0.20, 0.55, 0.85), (0.35, 0.75, 1.0))
mats["songbird_belly"]   = make_vc_feather("v3r2p_song_belly", (0.95, 0.85, 0.20), (1.0, 0.92, 0.40))
# Rhino beetle
mats["beetle_chitin"] = make_vc_chitin("v3r2p_beetle_chitin", (0.10, 0.20, 0.15), (0.18, 0.32, 0.22))
mats["beetle_horn"]   = make_vc_chitin("v3r2p_beetle_horn", (0.08, 0.06, 0.05), (0.18, 0.12, 0.08))
# Sand scorpion
mats["scorp_chitin"]  = make_vc_chitin("v3r2p_scorp_chitin", (0.78, 0.55, 0.20), (0.95, 0.72, 0.30))
mats["scorp_dark"]    = make_vc_chitin("v3r2p_scorp_dark", (0.55, 0.32, 0.10), (0.75, 0.45, 0.18))
# Wisp spirit
mats["wisp_glow"]     = make_vc_glow("v3r2p_wisp", (0.30, 0.85, 1.0), (0.55, 0.95, 1.0))
# Fox spirit
mats["fox_glow"]      = make_vc_glow("v3r2p_fox_glow", (1.0, 0.55, 0.20), (1.0, 0.78, 0.40))

# Common
mats["eye_yellow"]   = make_emit("v3r2p_eye_y", (1.0, 0.85, 0.30), 14.0)
mats["eye_amber"]    = make_emit("v3r2p_eye_a", (1.0, 0.65, 0.20), 14.0)
mats["eye_cyan"]     = make_emit("v3r2p_eye_c", (0.45, 0.95, 1.0), 14.0)
mats["eye_red"]      = make_emit("v3r2p_eye_r", (1.0, 0.30, 0.20), 14.0)
mats["nose_pink"]    = make_pbr_simple("v3r2p_nose", (0.85, 0.55, 0.55), 0.40)
mats["beak_dark"]    = make_pbr_simple("v3r2p_beak_d", (0.18, 0.14, 0.10), 0.40, 0.20)
mats["beak_orange"]  = make_pbr_simple("v3r2p_beak_o", (0.95, 0.55, 0.10), 0.30, 0.10)
mats["talon"]        = make_pbr_simple("v3r2p_talon", (0.15, 0.12, 0.10), 0.30, 0.20)
mats["floor"]        = make_pbr_simple("v3r2p_floor", (0.10, 0.10, 0.12), 0.30, 0.10)

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

def add_refined_modifiers(obj, multires_level=2, bevel_segments=5):
    obj.modifiers.new("Multires", 'MULTIRES')
    bpy.context.view_layer.objects.active = obj
    for _ in range(multires_level):
        bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')
    bv = obj.modifiers.new("Bevel", 'BEVEL')
    bv.width = 0.015; bv.segments = bevel_segments; bv.profile = 0.7
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

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=24, multires=2):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
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

def r_ico(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, sub=2, multires=2):
    return refined_part(name, bpy.ops.mesh.primitive_ico_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        subdivisions=sub, radius=r, location=loc)

# ============================================================
# PET BUILDERS
# ============================================================
def pet_tabby_cat(o):
    p = bpy.data.objects.new("pet_tabby_cat", None); scene.collection.objects.link(p); p.location = o
    # Body
    body = r_sphere("body", (0, 0, 0.30), 0.30, mats["tabby_fur"], p, segs=28)
    body.scale = (1.0, 1.5, 0.85)
    # Belly (lighter sphere underside)
    belly = r_sphere("belly", (0, 0.10, 0.20), 0.22, mats["tabby_belly"], p, segs=22)
    belly.scale = (0.85, 1.3, 0.6)
    # Head
    head = r_sphere("head", (0, 0.40, 0.45), 0.20, mats["tabby_fur"], p, segs=24)
    head.scale = (1.0, 1.0, 0.95)
    # Cheek tufts
    r_sphere("cheek_l", (-0.12, 0.45, 0.40), 0.08, mats["tabby_fur"], p, segs=14)
    r_sphere("cheek_r", (0.12, 0.45, 0.40), 0.08, mats["tabby_fur"], p, segs=14)
    # Ears
    r_cone("ear_l", (-0.13, 0.35, 0.62), 0.06, 0.0, 0.12, mats["tabby_fur"], p, verts=8, rot=(0, -0.3, 0))
    r_cone("ear_r", (0.13, 0.35, 0.62), 0.06, 0.0, 0.12, mats["tabby_fur"], p, verts=8, rot=(0, 0.3, 0))
    # Eyes (yellow)
    r_sphere("eye_l", (-0.07, 0.55, 0.47), 0.035, mats["eye_yellow"], p, segs=12)
    r_sphere("eye_r", (0.07, 0.55, 0.47), 0.035, mats["eye_yellow"], p, segs=12)
    # Nose
    r_sphere("nose", (0, 0.58, 0.40), 0.025, mats["nose_pink"], p, segs=10)
    # 4 legs
    for i, (lx, ly) in enumerate([(-0.15, -0.25), (0.15, -0.25), (-0.15, 0.20), (0.15, 0.20)]):
        r_cyl(f"leg_{i}", (lx, ly, 0.10), 0.05, 0.20, mats["tabby_fur"], p, verts=10)
    # Tail (curved upward)
    for i in range(4):
        tx = 0
        ty = -0.40 - i * 0.10
        tz = 0.30 + i * 0.10
        r_sphere(f"tail_{i}", (tx, ty, tz), 0.06 - i*0.008, mats["tabby_fur"], p, segs=12)
    return p

def pet_fluffball(o):
    p = bpy.data.objects.new("pet_fluffball", None); scene.collection.objects.link(p); p.location = o
    # Round body
    body = r_sphere("body", (0, 0, 0.30), 0.32, mats["fluff"], p, segs=28)
    body.scale = (1.0, 1.0, 0.95)
    # 4 fur tuft clumps for shape
    for i, (dx, dy, dz) in enumerate([(0.20, 0.10, 0.05),(-0.20, 0.10, 0.05),(0.10, -0.18, 0.10),(-0.10, -0.18, 0.10)]):
        r_sphere(f"tuft_{i}", (dx, dy, 0.30 + dz), 0.16, mats["fluff"], p, segs=16)
    # 2 small black eyes
    r_sphere("eye_l", (-0.10, 0.28, 0.36), 0.025, mats["eye_red"], p, segs=10)
    r_sphere("eye_r", (0.10, 0.28, 0.36), 0.025, mats["eye_red"], p, segs=10)
    # Tiny pink nose
    r_sphere("nose", (0, 0.32, 0.30), 0.015, mats["nose_pink"], p, segs=8)
    # 2 cone ears barely poking out
    r_cone("ear_l", (-0.13, 0.18, 0.50), 0.05, 0.0, 0.08, mats["fluff"], p, verts=8, rot=(0, -0.3, 0))
    r_cone("ear_r", (0.13, 0.18, 0.50), 0.05, 0.0, 0.08, mats["fluff"], p, verts=8, rot=(0, 0.3, 0))
    return p

def pet_wise_owl(o):
    p = bpy.data.objects.new("pet_wise_owl", None); scene.collection.objects.link(p); p.location = o
    # Body
    body = r_sphere("body", (0, 0, 0.40), 0.30, mats["owl_feather"], p, segs=28)
    body.scale = (1.0, 0.85, 1.3)
    # Belly
    belly = r_sphere("belly", (0, 0.18, 0.35), 0.22, mats["owl_belly"], p, segs=22)
    belly.scale = (0.85, 0.6, 1.2)
    # Head
    head = r_sphere("head", (0, 0.05, 0.85), 0.28, mats["owl_feather"], p, segs=26)
    head.scale = (1.05, 0.95, 1.0)
    # Face disc
    face = r_sphere("face", (0, 0.20, 0.85), 0.22, mats["owl_belly"], p, segs=22)
    face.scale = (1.0, 0.4, 1.0)
    # Big yellow eyes
    r_sphere("eye_l", (-0.10, 0.28, 0.87), 0.07, mats["eye_yellow"], p, segs=14)
    r_sphere("eye_r", (0.10, 0.28, 0.87), 0.07, mats["eye_yellow"], p, segs=14)
    # Pupils
    r_sphere("pupil_l", (-0.10, 0.34, 0.87), 0.025, mats["beak_dark"], p, segs=10)
    r_sphere("pupil_r", (0.10, 0.34, 0.87), 0.025, mats["beak_dark"], p, segs=10)
    # Beak
    r_cone("beak", (0, 0.32, 0.78), 0.04, 0.0, 0.08, mats["beak_orange"], p, verts=10, rot=(math.pi/2 - 0.2, 0, 0))
    # Tufts (ear feathers)
    r_cone("tuft_l", (-0.18, 0.05, 1.05), 0.05, 0.0, 0.12, mats["owl_feather"], p, verts=8, rot=(0, -0.4, 0))
    r_cone("tuft_r", (0.18, 0.05, 1.05), 0.05, 0.0, 0.12, mats["owl_feather"], p, verts=8, rot=(0, 0.4, 0))
    # Wings (folded — flat ovals at sides)
    r_sphere("wing_l", (-0.30, 0, 0.40), 0.18, mats["owl_feather"], p, segs=18)
    r_sphere("wing_r", (0.30, 0, 0.40), 0.18, mats["owl_feather"], p, segs=18)
    # Talons
    for i, (lx, ly) in enumerate([(-0.10, 0.05), (0.10, 0.05), (-0.10, -0.10), (0.10, -0.10)]):
        r_cyl(f"talon_{i}", (lx, ly, 0.05), 0.025, 0.10, mats["talon"], p, verts=8)
    return p

def pet_songbird(o):
    p = bpy.data.objects.new("pet_songbird", None); scene.collection.objects.link(p); p.location = o
    # Small round body
    body = r_sphere("body", (0, 0, 0.30), 0.18, mats["songbird_feather"], p, segs=24)
    body.scale = (1.0, 0.95, 1.05)
    # Belly
    r_sphere("belly", (0, 0.10, 0.27), 0.13, mats["songbird_belly"], p, segs=18)
    # Head
    head = r_sphere("head", (0, 0.05, 0.50), 0.15, mats["songbird_feather"], p, segs=22)
    head.scale = (1.0, 0.95, 1.0)
    # Eyes (small black)
    r_sphere("eye_l", (-0.05, 0.16, 0.52), 0.022, mats["beak_dark"], p, segs=10)
    r_sphere("eye_r", (0.05, 0.16, 0.52), 0.022, mats["beak_dark"], p, segs=10)
    # Beak
    r_cone("beak", (0, 0.22, 0.46), 0.025, 0.0, 0.06, mats["beak_orange"], p, verts=8, rot=(math.pi/2 - 0.3, 0, 0))
    # Wings
    w_l = r_sphere("wing_l", (-0.18, 0, 0.30), 0.10, mats["songbird_feather"], p, segs=16)
    w_l.scale = (0.4, 1.5, 1.2)
    w_r = r_sphere("wing_r", (0.18, 0, 0.30), 0.10, mats["songbird_feather"], p, segs=16)
    w_r.scale = (0.4, 1.5, 1.2)
    # Tail feathers
    t = r_cone("tail", (0, -0.20, 0.32), 0.10, 0.04, 0.18, mats["songbird_feather"], p, verts=8, rot=(math.pi/2 + 0.2, 0, 0))
    # Tiny legs
    r_cyl("leg_l", (-0.05, 0, 0.08), 0.012, 0.10, mats["talon"], p, verts=6)
    r_cyl("leg_r", (0.05, 0, 0.08), 0.012, 0.10, mats["talon"], p, verts=6)
    return p

def pet_rhino_beetle(o):
    p = bpy.data.objects.new("pet_rhino_beetle", None); scene.collection.objects.link(p); p.location = o
    # Body shell
    body = r_sphere("body", (0, 0, 0.20), 0.30, mats["beetle_chitin"], p, segs=28)
    body.scale = (1.0, 1.4, 0.6)
    # Head segment
    head = r_sphere("head", (0, 0.32, 0.20), 0.16, mats["beetle_chitin"], p, segs=20)
    head.scale = (1.0, 1.0, 0.8)
    # Big horn (rhino beetle signature)
    horn = r_cone("horn", (0, 0.45, 0.30), 0.05, 0.02, 0.30, mats["beetle_horn"], p, verts=12, rot=(-0.7, 0, 0))
    # 6 legs
    for i, (lx, ly, side) in enumerate([(-0.20, 0.20, -1),(0.20, 0.20, 1),(-0.22, 0, -1),(0.22, 0, 1),(-0.20, -0.20, -1),(0.20, -0.20, 1)]):
        r_cyl(f"leg_u_{i}", (lx, ly, 0.10), 0.025, 0.20, mats["beetle_horn"], p, verts=8,
               rot=(0, side * 0.6, 0))
        r_cyl(f"leg_l_{i}", (lx*1.5, ly, 0.04), 0.020, 0.18, mats["beetle_horn"], p, verts=8,
               rot=(0, side * 0.2, 0))
    # 2 small eyes
    r_sphere("eye_l", (-0.07, 0.42, 0.22), 0.025, mats["eye_red"], p, segs=10)
    r_sphere("eye_r", (0.07, 0.42, 0.22), 0.025, mats["eye_red"], p, segs=10)
    # Antennae
    r_cyl("ant_l", (-0.06, 0.45, 0.30), 0.008, 0.12, mats["beetle_horn"], p, verts=6, rot=(-0.5, 0, -0.3))
    r_cyl("ant_r", (0.06, 0.45, 0.30), 0.008, 0.12, mats["beetle_horn"], p, verts=6, rot=(-0.5, 0, 0.3))
    return p

def pet_sand_scorpion(o):
    p = bpy.data.objects.new("pet_sand_scorpion", None); scene.collection.objects.link(p); p.location = o
    # Body
    body = r_sphere("body", (0, 0, 0.15), 0.22, mats["scorp_chitin"], p, segs=24)
    body.scale = (1.0, 1.5, 0.7)
    # 8 legs (4 pairs)
    for i, (lx, ly, side) in enumerate([(-0.18, 0.15, -1),(0.18, 0.15, 1),(-0.20, 0.05, -1),(0.20, 0.05, 1),(-0.20, -0.05, -1),(0.20, -0.05, 1),(-0.18, -0.15, -1),(0.18, -0.15, 1)]):
        r_cyl(f"leg_u_{i}", (lx*1.3, ly, 0.10), 0.025, 0.22, mats["scorp_dark"], p, verts=8,
               rot=(0, side * 0.7, 0))
        r_cyl(f"leg_l_{i}", (lx*1.7, ly, 0.04), 0.018, 0.16, mats["scorp_dark"], p, verts=8,
               rot=(0, side * 0.3, 0))
    # Pincers (big front claws)
    for side in [-1, 1]:
        r_sphere(f"pincer_b_{side}", (side*0.18, 0.32, 0.15), 0.06, mats["scorp_chitin"], p, segs=14)
        r_sphere(f"pincer_t_{side}", (side*0.22, 0.42, 0.18), 0.05, mats["scorp_chitin"], p, segs=14)
        r_sphere(f"pincer_b2_{side}", (side*0.14, 0.42, 0.12), 0.04, mats["scorp_chitin"], p, segs=12)
    # Tail (4 segments curving up over body)
    for i in range(4):
        ty = -0.30 - i * 0.08
        tz = 0.15 + i * 0.10
        r_sphere(f"tail_{i}", (0, ty, tz), 0.07 - i*0.01, mats["scorp_chitin"], p, segs=14)
    # Stinger at tail end
    r_cone("stinger", (0, -0.55, 0.50), 0.04, 0.0, 0.12, mats["scorp_dark"], p, verts=8, rot=(-1.2, 0, 0))
    # 2 tiny eyes
    r_sphere("eye_l", (-0.05, 0.25, 0.20), 0.020, mats["eye_red"], p, segs=10)
    r_sphere("eye_r", (0.05, 0.25, 0.20), 0.020, mats["eye_red"], p, segs=10)
    return p

def pet_wisp_spirit(o):
    p = bpy.data.objects.new("pet_wisp_spirit", None); scene.collection.objects.link(p); p.location = o
    # Main glow body
    body = r_sphere("body", (0, 0, 0.50), 0.22, mats["wisp_glow"], p, segs=28)
    # 4 trailing wisps
    for i in range(4):
        z = 0.30 - i * 0.06
        r = 0.16 - i * 0.025
        r_sphere(f"trail_{i}", (0, 0, z), r, mats["wisp_glow"], p, segs=18)
    # 2 floating glow particles
    for i, (dx, dy, dz) in enumerate([(0.15, 0.10, 0.55),(-0.15, 0.10, 0.55),(0.10, -0.10, 0.65),(-0.10, -0.10, 0.65)]):
        r_sphere(f"part_{i}", (dx, dy, dz), 0.04, mats["wisp_glow"], p, segs=12)
    # Eye dots
    r_sphere("eye_l", (-0.08, 0.18, 0.55), 0.025, mats["eye_cyan"], p, segs=10)
    r_sphere("eye_r", (0.08, 0.18, 0.55), 0.025, mats["eye_cyan"], p, segs=10)
    return p

def pet_fox_spirit(o):
    p = bpy.data.objects.new("pet_fox_spirit", None); scene.collection.objects.link(p); p.location = o
    # Body
    body = r_sphere("body", (0, 0, 0.30), 0.25, mats["fox_glow"], p, segs=28)
    body.scale = (1.0, 1.4, 0.85)
    # Head
    head = r_sphere("head", (0, 0.32, 0.40), 0.18, mats["fox_glow"], p, segs=24)
    head.scale = (1.0, 1.0, 0.95)
    # Snout
    r_cone("snout", (0, 0.50, 0.35), 0.08, 0.04, 0.10, mats["fox_glow"], p, verts=10, rot=(math.pi/2, 0, 0))
    # 2 large pointed ears
    r_cone("ear_l", (-0.12, 0.28, 0.60), 0.06, 0.0, 0.18, mats["fox_glow"], p, verts=8, rot=(0, -0.3, 0))
    r_cone("ear_r", (0.12, 0.28, 0.60), 0.06, 0.0, 0.18, mats["fox_glow"], p, verts=8, rot=(0, 0.3, 0))
    # Eyes (amber)
    r_sphere("eye_l", (-0.08, 0.45, 0.42), 0.028, mats["eye_amber"], p, segs=12)
    r_sphere("eye_r", (0.08, 0.45, 0.42), 0.028, mats["eye_amber"], p, segs=12)
    # 4 legs
    for i, (lx, ly) in enumerate([(-0.12, -0.20), (0.12, -0.20), (-0.12, 0.18), (0.12, 0.18)]):
        r_cyl(f"leg_{i}", (lx, ly, 0.10), 0.04, 0.18, mats["fox_glow"], p, verts=10)
    # Multi-segment tail (curving upward — fox spirit signature)
    for i in range(5):
        ty = -0.40 - i * 0.08
        tz = 0.30 + i * 0.10
        r_sphere(f"tail_{i}", (0, ty, tz), 0.10 - i*0.013, mats["fox_glow"], p, segs=14)
    return p

# ============================================================
# SCENE LAYOUT — 8 pets in 4×2 grid
# ============================================================
parent = bpy.data.objects.new("v3_r2_pets", None); scene.collection.objects.link(parent)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "r2_floor"; fl.scale = (12, 6, 0.10)
fl.data.materials.append(mats["floor"])
bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
for poly in fl.data.polygons: poly.use_smooth = True

PETS = [
    ("tabby_cat",     pet_tabby_cat,     Vector((-4.5, 1.5, 0))),
    ("fluffball",     pet_fluffball,     Vector((-1.5, 1.5, 0))),
    ("wise_owl",      pet_wise_owl,      Vector(( 1.5, 1.5, 0))),
    ("songbird",      pet_songbird,      Vector(( 4.5, 1.5, 0))),
    ("rhino_beetle",  pet_rhino_beetle,  Vector((-4.5, -1.5, 0))),
    ("sand_scorpion", pet_sand_scorpion, Vector((-1.5, -1.5, 0))),
    ("wisp_spirit",   pet_wisp_spirit,   Vector(( 1.5, -1.5, 0))),
    ("fox_spirit",    pet_fox_spirit,    Vector(( 4.5, -1.5, 0))),
]

PET_OBJS = []
for name, builder, origin in PETS:
    obj = builder(origin)
    obj.parent = parent
    PET_OBJS.append((name, obj, origin))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 2200; key.data.color = (1.0, 0.92, 0.78); key.data.size = 12

bpy.ops.object.light_add(type='AREA', location=(-8, 10, 10))
fill = bpy.context.object
fill.data.energy = 800; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 12

bpy.ops.object.light_add(type='AREA', location=(0, 12, 5))
rim = bpy.context.object
rim.data.energy = 600; rim.data.color = (1.0, 0.85, 0.55); rim.data.size = 10

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

cam_grid = add_cam("cam_grid", Vector((0, -10, 6)), Vector((0, 0, 0.4)), lens=32, dof_dist=12)

PORTRAIT_CAMS = []
for name, _, origin in PETS:
    cam = add_cam(f"cam_{name}", Vector((origin.x, origin.y - 1.8, 1.0)),
                   Vector((origin.x, origin.y, 0.4)), lens=85, dof_dist=2)
    PORTRAIT_CAMS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render grid
scene.camera = cam_grid
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r2_pets_grid.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Render portraits
scene.render.resolution_x = 1024; scene.render.resolution_y = 1024
for name, cam in PORTRAIT_CAMS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_pet_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-pet GLB exports
for name, obj, _ in PET_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"pet_{name}_r2_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )
    print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-05 Pet Refinement complete ===")
