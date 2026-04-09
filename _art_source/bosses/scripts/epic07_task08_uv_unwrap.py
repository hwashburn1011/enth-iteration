"""Epic 07 task 8 — UV unwrap all 3 phase LOD0 meshes.

Smart UV Project on each phase mesh + pack islands at 0.012 margin.
The 3 phases share the original geometry positions so the unwraps
will be similar but not identical (P2/P3 have additional islands
for the overlay geometry).

Run via:
    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_task08_uv_unwrap.py
"""
import bpy

scene = bpy.context.scene


def unwrap_lod0(name):
    obj = bpy.data.objects.get(name)
    if obj is None:
        print(f"  SKIP {name}: not found")
        return False
    obj.hide_set(False)
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj

    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02, area_weight=0.0,
                             correct_aspect=True, scale_to_bounds=False)
    bpy.ops.uv.pack_islands(margin=0.012, scale=True)
    bpy.ops.object.mode_set(mode='OBJECT')

    uv_layer = obj.data.uv_layers.active
    if uv_layer is None:
        print(f"  {name}: NO uv layer after unwrap")
        return False
    us = [uv.vector.x for uv in uv_layer.uv]
    vs = [uv.vector.y for uv in uv_layer.uv]
    print(f"  {name}: U[{min(us):.3f},{max(us):.3f}] V[{min(vs):.3f},{max(vs):.3f}] {len(uv_layer.uv)} UVs")
    obj.hide_set(True)
    return True


print("UV unwrapping phase LOD0 meshes:")
unwrap_lod0("Compiler_LOD0_P1")
unwrap_lod0("Compiler_LOD0_P2")
unwrap_lod0("Compiler_LOD0_P3")

bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
print("UV unwrap complete")
