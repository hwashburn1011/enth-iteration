"""Shared utilities for the Epic 08 enemy pipeline scripts.

Reusable Blender CLI helpers extracted from the Crash Daemon / Null
Pointer / Stack Overflow pipelines so future enemy scripts only need
to define geometry + rig + animations instead of duplicating the
LOD/UV/bake/albedo plumbing.

Usage from a pipeline script:
    import sys
    sys.path.insert(0, "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/scripts")
    from enemy_pipeline_utils import (
        make_pbr, create_mesh,
        build_joined_lod, build_high_poly, smart_uv_unwrap,
        bake_pbr_set, write_albedo,
    )
"""
import bpy
import bmesh
import os
import math
from mathutils import Vector, Matrix
import numpy as np


# ========== MATERIAL HELPERS ==========

def make_pbr(name, base_color, metallic=1.0, roughness=0.30,
             emission_color=None, emission_strength=0.0):
    """Create a Principled BSDF material with optional emission."""
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = nt.nodes.get("Principled BSDF")
    if bsdf is None:
        for n in list(nt.nodes):
            nt.nodes.remove(n)
        bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
        out = nt.nodes.new("ShaderNodeOutputMaterial")
        nt.links.new(bsdf.outputs[0], out.inputs[0])
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission_color is not None and "Emission Color" in bsdf.inputs:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat


def create_mesh(name, bm, location, material, parent, smooth=True):
    """Bake a bmesh into a new MESH object, link to scene + parent."""
    me = bpy.data.meshes.new(name + "_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    obj.location = location
    obj.data.materials.append(material)
    bpy.context.scene.collection.objects.link(obj)
    obj.parent = parent
    if smooth:
        for p in obj.data.polygons:
            p.use_smooth = True
    return obj


def rotate_to_dir(bm, direction):
    """Rotate +Z bm verts to point along direction."""
    direction = Vector(direction).normalized()
    zdir = Vector((0, 0, 1))
    if (direction - zdir).length < 1e-4:
        return
    axis = zdir.cross(direction)
    if axis.length < 1e-5:
        axis = Vector((1, 0, 0))
    angle = math.acos(max(-1.0, min(1.0, zdir.dot(direction))))
    rot = Matrix.Rotation(angle, 4, axis.normalized())
    for v in bm.verts:
        v.co = rot @ v.co


# ========== LOD + UV ==========

def build_joined_lod(name, source_objs, target_tris, root_name_prefix):
    """Duplicate + apply modifiers + join + decimate to target tri count."""
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    duplicates = []
    for obj in source_objs:
        if obj.name.startswith(root_name_prefix):
            continue
        new_obj = obj.copy()
        new_obj.data = obj.data.copy()
        new_obj.name = obj.name + "_lod_src"
        new_obj.parent = None
        new_obj.matrix_world = obj.matrix_world.copy()
        bpy.context.scene.collection.objects.link(new_obj)
        duplicates.append(new_obj)
    for obj in duplicates:
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                obj.modifiers.remove(mod)
    if not duplicates:
        return None
    bpy.ops.object.select_all(action='DESELECT')
    for obj in duplicates:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = duplicates[0]
    bpy.ops.object.join()
    joined = bpy.context.view_layer.objects.active
    joined.name = name
    bm = bmesh.new()
    bm.from_mesh(joined.data)
    bmesh.ops.triangulate(bm, faces=bm.faces)
    pre = len(bm.faces)
    bm.to_mesh(joined.data)
    bm.free()
    if pre > target_tris:
        ratio = target_tris / pre
        mod = joined.modifiers.new("Decimate", 'DECIMATE')
        mod.decimate_type = 'COLLAPSE'
        mod.ratio = ratio
        mod.use_collapse_triangulate = True
        bpy.context.view_layer.objects.active = joined
        bpy.ops.object.modifier_apply(modifier="Decimate")
    bm = bmesh.new()
    bm.from_mesh(joined.data)
    print(f"  {name}: {len(bm.faces)} polys")
    bm.free()
    return joined


def smart_uv_unwrap(obj):
    obj.hide_set(False)
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
    bpy.ops.uv.pack_islands(margin=0.012, scale=True)
    bpy.ops.object.mode_set(mode='OBJECT')
    print(f"  {obj.name} UVs: {len(obj.data.uv_layers.active.uv)}")
    obj.hide_set(True)


def build_high_poly(name, source_objs, root_name_prefix, subsurf_levels=2):
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    duplicates = []
    for obj in source_objs:
        if obj.name.startswith(root_name_prefix):
            continue
        new_obj = obj.copy()
        new_obj.data = obj.data.copy()
        new_obj.name = obj.name + "_hp_src"
        new_obj.parent = None
        new_obj.matrix_world = obj.matrix_world.copy()
        bpy.context.scene.collection.objects.link(new_obj)
        duplicates.append(new_obj)
    for obj in duplicates:
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                obj.modifiers.remove(mod)
        ss = obj.modifiers.new("HP_Subsurf", 'SUBSURF')
        ss.levels = subsurf_levels
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


# ========== BAKE ==========

def make_bake_image(name, color, is_data, w=1024, h=1024):
    img = bpy.data.images.new(name, w, h, alpha=False, float_buffer=False)
    img.generated_color = color
    img.colorspace_settings.name = 'Non-Color' if is_data else 'sRGB'
    return img


def setup_bake_target_mat(image, mat_name="BakeTarget"):
    mat = bpy.data.materials.get(mat_name)
    if mat is None:
        mat = bpy.data.materials.new(mat_name)
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


def setup_curvature_mat(image, mat_name="CurvBake"):
    mat = bpy.data.materials.get(mat_name)
    if mat is None:
        mat = bpy.data.materials.new(mat_name)
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


def bake_pbr_set(lod0, hp, enemy_id, tex_dir, w=1024, h=1024):
    """Run the standard 4-pass bake (normal/AO/cavity/curvature) and save PNGs.
    Returns (img_normal, img_ao, img_cavity, img_curv)."""
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 32
    scene.cycles.device = 'CPU'

    saved_mats = [m for m in lod0.data.materials]
    while len(lod0.data.materials) > 1:
        lod0.data.materials.pop(index=1)
    for poly in lod0.data.polygons:
        poly.material_index = 0

    img_normal = make_bake_image(f"{enemy_id}_normal",   (0.5, 0.5, 1.0, 1.0), True, w, h)
    img_ao     = make_bake_image(f"{enemy_id}_ao",       (1.0, 1.0, 1.0, 1.0), False, w, h)
    img_cavity = make_bake_image(f"{enemy_id}_cavity",   (1.0, 1.0, 1.0, 1.0), True, w, h)
    img_curv   = make_bake_image(f"{enemy_id}_curvature",(0.5, 0.5, 0.5, 1.0), True, w, h)

    def _bake(image, bake_type, ray_dist=0.10, custom_mat=None):
        if custom_mat is not None:
            while len(hp.data.materials) > 1:
                hp.data.materials.pop(index=1)
            if hp.data.materials:
                hp.data.materials[0] = custom_mat
            else:
                hp.data.materials.append(custom_mat)
            for poly in hp.data.polygons:
                poly.material_index = 0
        target = setup_bake_target_mat(image, mat_name=f"{enemy_id}_BakeTarget")
        if lod0.data.materials:
            lod0.data.materials[0] = target
        else:
            lod0.data.materials.append(target)
        bpy.ops.object.select_all(action='DESELECT')
        lod0.hide_set(False)
        lod0.hide_render = False
        hp.hide_set(False)
        hp.hide_render = False
        hp.select_set(True)
        lod0.select_set(True)
        bpy.context.view_layer.objects.active = lod0
        scene.cycles.bake_type = bake_type
        scene.render.bake.use_selected_to_active = True
        scene.render.bake.cage_extrusion = 0.05
        scene.render.bake.max_ray_distance = ray_dist
        scene.render.bake.margin = 8
        if bake_type == 'NORMAL':
            scene.render.bake.normal_space = 'TANGENT'
        bpy.ops.object.bake(type=bake_type)
        image.save_render(filepath=os.path.join(tex_dir, image.name + ".png"))
        print(f"  Saved {image.name}.png")

    _bake(img_normal, 'NORMAL', 0.10)
    _bake(img_ao,     'AO',     0.10)
    _bake(img_cavity, 'AO',     0.020)
    _bake(img_curv,   'EMIT',   0.10, custom_mat=setup_curvature_mat(img_curv, mat_name=f"{enemy_id}_CurvBake"))

    lod0.data.materials.clear()
    for m in saved_mats:
        if m is not None:
            lod0.data.materials.append(m)
    hp.hide_set(True)
    hp.hide_render = True
    lod0.hide_set(True)
    lod0.hide_render = True

    return (img_normal, img_ao, img_cavity, img_curv)


# ========== ALBEDO HELPERS ==========

def hash_noise(x, y, freq):
    nx = np.floor(x * freq).astype(np.int32)
    ny = np.floor(y * freq).astype(np.int32)
    h = (nx * 374761393 + ny * 668265263) & 0x7fffffff
    h = (h ^ (h >> 13)) * 1274126177
    return ((h & 0x7fffffff) / 0x7fffffff).astype(np.float32)


def img_to_array(img):
    return np.array(img.pixels[:], dtype=np.float32).reshape(img.size[1], img.size[0], 4)


def write_albedo(name, arr, tex_dir):
    img = bpy.data.images.new(name, arr.shape[1], arr.shape[0], alpha=False)
    img.colorspace_settings.name = 'sRGB'
    img.pixels = arr.flatten().tolist()
    img.filepath_raw = os.path.join(tex_dir, name + ".png")
    img.file_format = 'PNG'
    img.save()
    print(f"  Saved {name}.png")
    return img
