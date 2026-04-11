"""Generates 21 elite variant .tres files for Epic 08 enemies (3 of 24 already done by hand).

Each enemy gets 3 elite variants per the variant bible knobs.

Run: python C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/scripts/generate_epic08_variants.py
"""
import os

variants = [
    # Null Pointer
    ('null_pointer', 'phase', 'Phase Null Pointer', 0.95, (0.55, 0.0, 1.0), (0.30, 0.0, 0.85), 0.9, 0.9, 1.3, 1.4, 'phased', None, 0, 0, False),
    ('null_pointer', 'corrupted', 'Corrupted Null Pointer', 1.0, (1.0, 0.10, 0.85), (0.85, 0.0, 0.55), 1.2, 1.5, 1.0, 1.2, 'corrupt', None, 0, 0, False),
    ('null_pointer', 'sovereign', 'Sovereign Null Pointer', 1.20, (0.95, 0.95, 1.0), (0.55, 0.95, 1.0), 2.5, 2.0, 1.0, 1.5, 'silenced', 'plate_gold', 1.5, 4.0, True),
    # Stack Overflow
    ('stack_overflow', 'molten', 'Molten Stack Overflow', 1.0, (1.0, 0.30, 0.0), (0.85, 0.10, 0.0), 1.3, 1.4, 1.0, 1.0, 'burn', None, 0, 0, False),
    ('stack_overflow', 'shielded', 'Shielded Stack Overflow', 1.0, (0.30, 0.65, 1.0), (0.05, 0.30, 0.85), 1.6, 1.1, 1.0, 1.0, '', None, 0, 0, False),
    ('stack_overflow', 'monolith', 'Monolith Stack Overflow', 1.30, (0.95, 0.95, 1.0), (0.85, 0.85, 1.0), 3.0, 1.8, 1.0, 1.3, 'marked', 'plate_gold', 2.0, 5.0, True),
    # Race Condition
    ('race_condition', 'venomous', 'Venomous Race Condition', 1.0, (0.55, 0.95, 0.05), (0.30, 0.85, 0.0), 1.0, 1.4, 1.1, 1.0, 'poison', None, 0, 0, False),
    ('race_condition', 'cold', 'Cold Race Condition', 1.0, (0.45, 0.85, 1.0), (0.20, 0.55, 0.95), 1.2, 1.0, 0.9, 1.0, 'chill', None, 0, 0, False),
    ('race_condition', 'mother', 'Mother Race Condition', 1.40, (1.0, 0.10, 0.85), (0.85, 0.0, 0.55), 2.5, 1.6, 0.85, 1.5, 'fragmented', 'plate_gold', 1.8, 4.5, True),
    # Deadlock
    ('deadlock', 'rust', 'Rust Deadlock', 1.0, (0.85, 0.30, 0.05), (0.55, 0.10, 0.0), 1.3, 1.2, 1.0, 1.0, 'corrode', None, 0, 0, False),
    ('deadlock', 'electric', 'Electric Deadlock', 1.0, (1.0, 0.85, 0.05), (1.0, 0.55, 0.0), 1.2, 1.5, 1.0, 1.0, 'shock', None, 0, 0, False),
    ('deadlock', 'overlord', 'Overlord Deadlock', 1.30, (1.0, 0.05, 0.05), (0.85, 0.0, 0.0), 3.0, 1.7, 0.9, 1.4, 'silenced', 'plate_gold', 2.2, 5.0, True),
    # Buffer Overflow
    ('buffer_overflow', 'acidic', 'Acidic Buffer Overflow', 1.0, (0.55, 0.95, 0.05), (0.85, 0.85, 0.10), 1.2, 1.4, 1.0, 1.0, 'acid', None, 0, 0, False),
    ('buffer_overflow', 'cryo', 'Cryo Buffer Overflow', 1.0, (0.45, 0.85, 1.0), (0.20, 0.55, 0.95), 1.4, 1.2, 0.85, 1.0, 'freeze', None, 0, 0, False),
    ('buffer_overflow', 'cluster', 'Cluster Buffer Overflow', 1.40, (1.0, 0.30, 0.0), (0.85, 0.10, 0.0), 2.5, 2.0, 0.9, 1.4, 'overflow', 'plate_gold', 0, 0, False),
    # Phantom Cache
    ('phantom_cache', 'silver', 'Silver Phantom Cache', 1.0, (0.85, 0.85, 0.95), (0.55, 0.55, 0.65), 1.3, 0.0, 1.0, 1.0, '', None, 0, 0, False),
    ('phantom_cache', 'sapphire', 'Sapphire Phantom Cache', 1.0, (0.10, 0.55, 0.95), (0.05, 0.30, 0.85), 1.4, 0.0, 1.0, 1.0, '', None, 0, 0, False),
    ('phantom_cache', 'mythic', 'Mythic Phantom Cache', 1.20, (1.0, 0.85, 0.05), (0.85, 0.55, 0.0), 2.0, 0.0, 1.1, 1.5, '', 'plate_gold', 0, 0, False),
    # Iteration Echo
    ('iteration_echo', 'shadow', 'Shadow Iteration Echo', 1.0, (0.10, 0.10, 0.20), (0.05, 0.05, 0.10), 1.3, 1.1, 1.0, 1.0, 'silenced', None, 0, 0, False),
    ('iteration_echo', 'glitched', 'Glitched Iteration Echo', 1.0, (1.0, 0.10, 0.85), (0.0, 0.95, 1.0), 1.2, 1.3, 1.1, 1.2, 'glitch', None, 0, 0, False),
    ('iteration_echo', 'paragon', 'Paragon Iteration Echo', 1.15, (0.95, 0.95, 1.0), (0.0, 0.95, 1.0), 2.5, 2.0, 1.1, 1.5, 'mirror', 'plate_gold', 2.0, 5.0, True),
]

out_dir = "C:/Users/hwash/Documents/enth-iteration/data/enemies/variants/epic08"
os.makedirs(out_dir, exist_ok=True)

for v in variants:
    base, key, name, scale, ca, cb, hp, dmg, spd, agg, status, pat, ai, ar, aura = v
    fid = f"{base}_{key}"
    has_aura = "true" if aura else "false"
    pat_line = f'pattern_overlay = &"{pat}"\n' if pat else ""
    aura_line = f"aura_intensity = {ai}\naura_radius = {ar}\n" if aura else ""
    status_line = f'applies_status_effect = &"{status}"\n' if status else ""

    content = f'''[gd_resource type="Resource" script_class="EnemyVariant" load_steps=2 format=3 uid="uid://{fid}"]

[ext_resource type="Script" path="res://scripts/resources/enemy_variant.gd" id="1_variant"]

[resource]
script = ExtResource("1_variant")
variant_id = &"{fid}"
display_name = "{name}"
base_enemy_id = &"{base}"
body_scale = {scale}
crack_color_a = Color({ca[0]}, {ca[1]}, {ca[2]}, 1.0)
crack_color_b = Color({cb[0]}, {cb[1]}, {cb[2]}, 1.0)
hp_mult = {hp}
damage_mult = {dmg}
speed_mult = {spd}
aggro_radius_mult = {agg}
has_pack_leader_aura = {has_aura}
{aura_line}{pat_line}{status_line}'''

    fp = os.path.join(out_dir, f"{fid}.tres")
    with open(fp, "w") as f:
        f.write(content)

print(f"Wrote {len(variants)} variant tres files")
