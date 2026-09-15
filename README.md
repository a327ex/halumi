# halumi

First-person fixed-light photography in an authored cave. Current batch: M1-M3.
The entrance's pale threshold is also the exit. Only extracted plates pay;
death loses the run. The construct speaks only when consulted.

## Controls

| Input | Action |
|---|---|
| WASD + mouse | Float and look; press into a sloping wall to climb |
| Click or Space | Fix light instantly; consumes one of 18 film leaves |
| F | Toggle photographic flash |
| Q, aimed at a creature | Consult the construct |
| E | Throw a pebble; its landing draws attention |
| G | Throw food; five portions per run |
| L | Toggle steady light; keep it aimed at the Slatejaw to ward it away |
| Escape | Release/regrab the cursor |
| Left/right at results | Inspect plates and their assessments |
| R at results/death | Start a fresh run at the entrance |

Vertical faces and overhangs stop ascent. Pale water is shallow; the dark
basin cannot support levitation. There is one attacker and no combat.

## Mechanical checks

From the workspace root, with no visible game running:

```sh
anchor check halumi
anchor drive start halumi
anchor drive eval halumi --file halumi/tests/smoke.lua
anchor drive eval halumi --file halumi/tests/hazards.lua
anchor drive eval halumi --file halumi/tests/exploration.lua
anchor drive stop halumi
```

Smoke follows a keyboard route, uses food and light, shoots three plates,
climbs to the vantage and returns to the entrance. The other checks isolate
damage/theft boundaries and the alcove. M1/M2 fixtures also remain at their
milestone commits. Feel is for the owner to assess.

Every run uses a distinct `albums/<timestamp>-<serial>/` directory. PNGs exclude
the interface and construct. `manifest.tsv` records subjects, behavior, flash
and banked/lost status. Failed-run files remain as test/history evidence but
are removed from the playable album and earn nothing. Replays remain under
`replays/` and are not committed.

## Implementation

`boot.lua` creates state, assets and bodies once. Other Lua modules contain
definitions and reload on save. `controller.lua` implements the kinematic
capsule using static ray probes; `world.lua` owns the blockout. `creatures.lua`
owns state and relationships; `models.lua` builds poses from shared primitives.
`subjects.lua` is shared by the camera and construct. `camera_game.lua` owns
film, photo metadata, extraction and grading. M4 art and non-voice sound polish
are still pending. Details and verification evidence: `reference/milestones.md`.
