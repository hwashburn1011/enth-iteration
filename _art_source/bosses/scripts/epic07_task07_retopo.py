"""Epic 07 task 7 — retopo all forms with shared UV layout where possible.

For each phase, build a joined LOD0 mesh from the matching collection,
apply Decimate COLLAPSE to a per-phase target tri count, and verify the
counts. The 3 LOD0 meshes share the same starting topology so a UV unwrap
on shared geometry can be ported across phases.

Per-phase targets:
  Phase 1 — 8000 tris  (boss-tier baseline, ~2x normal enemy)
  Phase 2 — 9500 tris  (P1 + 12 debris chunks + 2 fragmented arms)
  Phase 3 — 11000 tris (P2 + heart core + 4 energy arms)

Run via:
    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_task07_retopo.py
"""
import bpy
import bmesh

scene = bpy.context.scene


def collect_visible_meshes(collection_names):
    """Collect all mesh objects from the named collections."""
    objs = []
    for col_name in collection_names:
        col = bpy.data.collections.get(col_name)
        if col is None:
            continue
        for obj in col.objects:
            if obj.type == 'MESH':
                objs.append(obj)
    return objs


def build_lod0(name, source_objs, target_tris):
    """Duplicate + join + decimate the source meshes into a single LOD0."""
    if bpy.data.objects.get(name):
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)

    duplicates = []
    for obj in source_objs:
        new_obj = obj.copy()
        new_obj.data = obj.data.copy()
        new_obj.name = obj.name + "_lod_src"
        new_obj.parent = None
        new_obj.matrix_world = obj.matrix_world.copy()
        bpy.context.scene.collection.objects.link(new_obj)
        duplicates.append(new_obj)

    # Apply any modifiers (subsurf etc) before joining
    for obj in duplicates:
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                obj.modifiers.remove(mod)

    if not duplicates:
        return None

    # Join into a single mesh
    bpy.ops.object.select_all(action='DESELECT')
    for obj in duplicates:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = duplicates[0]
    bpy.ops.object.join()
    joined = bpy.context.view_layer.objects.active
    joined.name = name

    # Triangulate to count
    bm = bmesh.new()
    bm.from_mesh(joined.data)
    bmesh.ops.triangulate(bm, faces=bm.faces)
    pre_tris = len(bm.faces)
    bm.to_mesh(joined.data)
    bm.free()
    print(f"{name} pre-decimate tri count: {pre_tris}")

    # Decimate to target
    if pre_tris > target_tris:
        ratio = target_tris / pre_tris
        mod = joined.modifiers.new("Decimate", 'DECIMATE')
        mod.decimate_type = 'COLLAPSE'
        mod.ratio = ratio
        mod.use_collapse_triangulate = True
        bpy.context.view_layer.objects.active = joined
        bpy.ops.object.modifier_apply(modifier="Decimate")

    bm = bmesh.new()
    bm.from_mesh(joined.data)
    post_tris = len(bm.faces)
    bm.free()
    print(f"{name} post-decimate tri count: {post_tris} (target {target_tris})")

    # Hide by default — phase controller will reveal at runtime
    joined.hide_set(True)
    joined.hide_render = True
    return joined


# Build P1 LOD0 from shared collection only
p1 = build_lod0("Compiler_LOD0_P1", collect_visible_meshes(["Compiler_Shared"]), 8000)

# Build P2 LOD0 from shared + P2 overlay
p2 = build_lod0("Compiler_LOD0_P2", collect_visible_meshes(["Compiler_Shared", "Compiler_P2_Overlay"]), 9500)

# Build P3 LOD0 from shared + P2 + P3 overlays
p3 = build_lod0("Compiler_LOD0_P3", collect_visible_meshes(["Compiler_Shared", "Compiler_P2_Overlay", "Compiler_P3_Overlay"]), 11000)

bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)

print("Phase LOD0 chain built:")
for name in ("Compiler_LOD0_P1", "Compiler_LOD0_P2", "Compiler_LOD0_P3"):
    obj = bpy.data.objects.get(name)
    if obj:
        print(f"  {name}: {len(obj.data.polygons)} polys / {len(obj.data.vertices)} verts")
