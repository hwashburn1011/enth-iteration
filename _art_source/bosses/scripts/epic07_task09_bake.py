"""Epic 07 task 9 — bake high-poly detail to game mesh.

For each phase, build a high-poly source from the original collection
geometry with subdivision surface applied, then run Cycles selected-to-
active bake against the LOD0 to capture normal/AO/curvature/cavity at
1024x1024.

Per-phase bakes:
  Compiler_P1_*  — normal/AO/curvature/cavity
  Compiler_P2_*  — normal/AO/curvature/cavity
  Compiler_P3_*  — normal/AO/curvature/cavity

Outputs:
  assets/textures/bosses/compiler_boss_p{1,2,3}_{normal,ao,curvature,cavity}.png

Run via:
    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_task09_bake.py
"""
import bpy
import bmesh
import os

scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.cycles.device = 'CPU'

TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/bosses"
os.makedirs(TEX_DIR, exist_ok=True)


def collect_visible_meshes(collection_names):
    objs = []
    for col_name in collection_names:
        col = bpy.data.collections.get(col_name)
        if col is None:
            continue
        for obj in col.objects:
            if obj.type == 'MESH':
                objs.append(obj)
    return objs


def build_high_poly(name, source_objs, subsurf_levels=2):
    """Build a high-poly version by joining source meshes with subsurf applied."""
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)

    duplicates = []
    for obj in source_objs:
        new_obj = obj.copy()
        new_obj.data = obj.data.copy()
        new_obj.name = obj.name + "_hp_src"
        new_obj.parent = None
        new_obj.matrix_world = obj.matrix_world.copy()
        bpy.context.scene.collection.objects.link(new_obj)
        duplicates.append(new_obj)

    # Apply existing modifiers + add subsurf for high-poly
    for obj in duplicates:
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                obj.modifiers.remove(mod)
        # Add subsurf for high-poly source
        ss = obj.modifiers.new("HP_Subsurf", 'SUBSURF')
        ss.levels = subsurf_levels
        ss.render_levels = subsurf_levels
        try:
            bpy.ops.object.modifier_apply(modifier="HP_Subsurf")
        except RuntimeError:
            obj.modifiers.remove(ss)

    if not duplicates:
        return None

    bpy.ops.object.select_all(action='DESELECT')
    for obj in duplicates:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = duplicates[0]
    bpy.ops.object.join()
    hp = bpy.context.view_layer.objects.active
    hp.name = name
    return hp


def make_bake_image(name, color, is_data):
    img = bpy.data.images.get(name)
    if img is None:
        img = bpy.data.images.new(name, 1024, 1024, alpha=False, float_buffer=False)
    img.generated_color = color
    img.colorspace_settings.name = 'Non-Color' if is_data else 'sRGB'
    return img


def setup_bake_target_mat(image):
    name = "Compiler_BakeTarget"
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.select = True
    nt.nodes.active = tex
    nt.links.new(bsdf.outputs[0], out.inputs[0])
    return mat


def setup_curvature_mat(image):
    name = "Compiler_CurvBake"
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    geom = nt.nodes.new("ShaderNodeNewGeometry")
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].position = 0.40
    ramp.color_ramp.elements[1].position = 0.60
    em = nt.nodes.new("ShaderNodeEmission")
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.select = True
    nt.nodes.active = tex
    nt.links.new(geom.outputs["Pointiness"], ramp.inputs[0])
    nt.links.new(ramp.outputs[0], em.inputs[0])
    nt.links.new(em.outputs[0], out.inputs[0])
    return mat


def bake_phase(phase_label, hp_obj, lod0_obj):
    """Run the 4 bakes for a single phase."""
    if hp_obj is None or lod0_obj is None:
        print(f"  SKIP {phase_label}: missing hp or lod0")
        return

    # Save original LOD0 materials and collapse to a single bake target slot
    saved_mats = [m for m in lod0_obj.data.materials]
    while len(lod0_obj.data.materials) > 1:
        lod0_obj.data.materials.pop(index=1)
    for poly in lod0_obj.data.polygons:
        poly.material_index = 0

    img_normal = make_bake_image(f"compiler_boss_{phase_label}_normal",   (0.5, 0.5, 1.0, 1.0), True)
    img_ao     = make_bake_image(f"compiler_boss_{phase_label}_ao",       (1.0, 1.0, 1.0, 1.0), False)
    img_cavity = make_bake_image(f"compiler_boss_{phase_label}_cavity",   (1.0, 1.0, 1.0, 1.0), True)
    img_curv   = make_bake_image(f"compiler_boss_{phase_label}_curvature",(0.5, 0.5, 0.5, 1.0), True)

    lod0_obj.hide_set(False)
    lod0_obj.hide_render = False
    hp_obj.hide_set(False)
    hp_obj.hide_render = False

    def bake(image, bake_type, ray_dist=0.10, custom_mat=None):
        if custom_mat is not None:
            target_mat = custom_mat
            # Apply curvature mat to HP for the curvature bake
            saved_hp_mats = [m for m in hp_obj.data.materials]
            while len(hp_obj.data.materials) > 1:
                hp_obj.data.materials.pop(index=1)
            if hp_obj.data.materials:
                hp_obj.data.materials[0] = target_mat
            else:
                hp_obj.data.materials.append(target_mat)
            for poly in hp_obj.data.polygons:
                poly.material_index = 0
        target = setup_bake_target_mat(image)
        if lod0_obj.data.materials:
            lod0_obj.data.materials[0] = target
        else:
            lod0_obj.data.materials.append(target)
        bpy.ops.object.select_all(action='DESELECT')
        hp_obj.select_set(True)
        lod0_obj.select_set(True)
        bpy.context.view_layer.objects.active = lod0_obj
        scene.cycles.bake_type = bake_type
        scene.render.bake.use_selected_to_active = True
        scene.render.bake.cage_extrusion = 0.10
        scene.render.bake.max_ray_distance = ray_dist
        scene.render.bake.margin = 8
        if bake_type == 'NORMAL':
            scene.render.bake.normal_space = 'TANGENT'
        bpy.ops.object.bake(type=bake_type)
        image.save_render(filepath=os.path.join(TEX_DIR, image.name + ".png"))
        print(f"    Saved {image.name}.png")

    # Run the 4 bakes
    bake(img_normal, 'NORMAL', 0.20)
    bake(img_ao,     'AO',     0.20)
    bake(img_cavity, 'AO',     0.025)
    curv_mat = setup_curvature_mat(img_curv)
    bake(img_curv,   'EMIT',   0.20, custom_mat=curv_mat)

    # Restore LOD0 original materials
    lod0_obj.data.materials.clear()
    for m in saved_mats:
        if m is not None:
            lod0_obj.data.materials.append(m)

    lod0_obj.hide_set(True)
    hp_obj.hide_set(True)


# === Build high-polys for each phase ===
print("Building high-poly sources...")
hp_p1 = build_high_poly("Compiler_HP_P1", collect_visible_meshes(["Compiler_Shared"]))
hp_p2 = build_high_poly("Compiler_HP_P2", collect_visible_meshes(["Compiler_Shared", "Compiler_P2_Overlay"]))
hp_p3 = build_high_poly("Compiler_HP_P3", collect_visible_meshes(["Compiler_Shared", "Compiler_P2_Overlay", "Compiler_P3_Overlay"]))

lod0_p1 = bpy.data.objects.get("Compiler_LOD0_P1")
lod0_p2 = bpy.data.objects.get("Compiler_LOD0_P2")
lod0_p3 = bpy.data.objects.get("Compiler_LOD0_P3")

print("Baking phase 1...")
bake_phase("p1", hp_p1, lod0_p1)
print("Baking phase 2...")
bake_phase("p2", hp_p2, lod0_p2)
print("Baking phase 3...")
bake_phase("p3", hp_p3, lod0_p3)

# Cleanup high-poly objects
for hp in (hp_p1, hp_p2, hp_p3):
    if hp:
        hp.hide_set(True)
        hp.hide_render = True

bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
print("All phase bakes complete")
