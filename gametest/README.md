# gametest — V1 demo smoke test scaffold

A minimal regression suite that exercises the autoload graph and the
save/load pipeline so the next "can't move on new game" / "save wipes
my level" / "QuestManager state lost" class of bugs trip an alarm
before playtest.

## Run from the editor

1. Open `gametest/SmokeTest.tscn` in Godot.
2. Press F6 (Play Scene).
3. Console prints `[smoke-test] PASS (N/N)` on success or
   `[smoke-test] FAIL: <reason>` on the first failure.
4. The scene quits the engine on completion (exit code matches).

## Run from CLI

```sh
godot --headless res://gametest/SmokeTest.tscn
echo $?   # 0 = pass, 1 = fail
```

This is the entry point intended for the future CI gate (Phase 6 #49 in
`_bmad-output/v1-demo-backlog.md`).

## What's covered today

- All required autoloads are present at `/root/<name>` (catches
  project.godot autoload list drift).
- `SaveManager.save_game()` round-trips through `load_game()` and the
  saved value comes back (catches schema migration bugs).
- After `save_game()` succeeds, the `pending_player_data /
  pending_inventory_data / pending_equipment_data` metas are populated.
  This is the **T68 regression guard** — without it the next scene's
  `apply_to_player` call would no-op and the player would respawn at
  default level 1 with empty equipment.
- `IterationManager.to_save_data() / from_save_data()` round-trip
  preserves `current_iteration`.
- `QuestManager.to_save_data() / from_save_data()` exists and the
  snapshot has the `active` and `completed` keys (T67 regression guard).
- `GameManager.recruited_npcs` is exposed (the save layer reads it).

## What's NOT covered yet

- No actual gameplay simulation (movement, combat, scene transitions).
  Adding that needs a way to drive the player from a script and is
  Phase 1 work.
- No assertion that a real Town/Dungeon scene loads without crashing.
  The current `play_scene` MCP check covers that manually for now.

Add new checks to `smoke_test.gd::_run_all` and they'll be picked up on
the next run.
