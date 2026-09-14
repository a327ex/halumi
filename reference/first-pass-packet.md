# halumi — first pass packet (2026-09-14)

Packet from Fable (the directing instance) to Astra (implementer). The owner
committed to this direction on 2026-09-14 after a design session; what is
fixed below is fixed, everything else is yours to decide and report.

## Preamble: the frame

- You implement. You do not make high-level decisions. On a high-level choice
  this packet did not make, on a packet claim that turns out wrong in a way
  that changes the design, or on a step that would reach outside the frame
  below, STOP and report; do not guess and continue.
- Workspace root is `C:/Users/a327e/Desktop/a327ex` (your cwd). You may write
  ONLY under `halumi/` (the game) and, for milestone 0 only, under
  `Anchor/engine/` (`engine/src/anchor.c`, `docs/3D_API.md`,
  `docs/ENGINE_API_QUICK.md`, `docs/ENGINE_API.md`, `playground/`). Nothing
  else in the root: not `a327ex-site/`, not `Anchor/workflow/`, not other
  games, not `Z:`.
- No network use except reading documentation if you must; no downloads, no
  package installs, no scrapers. Everything needed is on disk.
- Never open a visible window on the owner's desktop. Never run `run.bat`.
  Run the game only as an agent instance (`anchor drive`, below). If the
  sandbox blocks the agent instance's local socket, say so in your report
  and fall back to `anchor check` plus careful reading; Fable will drive it.
- Commit in `halumi/` at the end of every milestone (git is set up; do not
  push). Milestone 0 commits in `Anchor/` are Fable's to make: leave the
  engine changes uncommitted and list the files.
- The owner's Astra token budget bounds this run. Work in the milestone
  order below, report at each stop, and never spend tokens on polish the
  milestone did not ask for.

## Read before code

1. `Anchor/engine/docs/SURFACE.md` (whole): how a game runs, is driven,
   recorded, reloaded. The only command line is `anchor <game> [--agent]`.
2. `Anchor/engine/docs/3D_API.md` (whole) and the layer3 / mesh3 / physics3 /
   input / audio sections of `Anchor/engine/docs/ENGINE_API_QUICK.md`.
   Look every function up; never guess a signature.
3. `Anchor/engine/.claude/CLAUDE.md` (engine working agreements) and
   `Anchor/engine/reference/plan.md` (3D status; character mover is NOT
   bound, build your own on a kinematic capsule + raycasts).
4. `halumi/.claude/CLAUDE.md` and the scaffold (`main.lua` definitions only,
   reloads on save; `boot.lua` one-time work, never reloads; `anchor/` is this
   game's own framework copy, never overwrite it wholesale).
5. Traps that have bitten every instance so far: draw origins differ
   (textures centered, text top-left); `color()` tables must be called to
   pack for raw bindings; input edge queries (`*_pressed/_released`) are
   update-only and RAISE in draw; every handle-taking binding wants
   `.handle`; `layer3_new` before any `mesh3_create`; queued
   `apply_shader`; Lua `%d` on floats errors; agent instances leak sound
   voice slots (harmless, known). `mesh3_load_obj` is framework Lua, not C.
6. Style references (read, do not modify):
   - `character-lookdev/rounds/04-motion/{models.js,motion.js}` and
     `rounds/05-motion/{model-common.js,models.js,motion.js,motion-poses.txt}`:
     the Simple Retro 3D character set you built in Three.js (Cup, Wisp,
     Ripple, Gulp, Nib, Boot, Fold, Longhead). Primitives assembled in code,
     curve-driven motion, small painted face textures, vertex snap + color
     quantization. The CONSTRUCTION APPROACH ports to Anchor; the code does not.
   - `environment-lookdev/rounds/05-overviews/` (the mushroom grotto
     especially): the PS1 Worlds environment recipe. Coarse procedural
     textures, nearest filtering, flat shading, muted terrain so silhouettes read.
   - `Z:/2025-2026/code/a327ex-linux-2026-09/lookdev/meadow-anchor/` (read-only
     archive; `main.lua, world.lua, critters.lua, textures.lua, meshes.lua`):
     the one prior PS1 look built INSIDE Anchor (jitter, affine, fog, sky, sun,
     textures painted at boot). If Z: is unreadable from the sandbox, skip it.

## Direction (fixed)

A first-person 3D game in the PS1/retro-3D style. You are a cryptozoologist
who enters a dungeon to photograph its creatures in their natural habitat and
come back out. Identity: curiosity under threat. A good place to observe a
creature is often a bad place to remain unnoticed by it; photography gives
you a reason to expose yourself where ordinary stealth would reward slipping
past. No combat. Success comes from documenting and navigating the creatures,
never from overpowering them; scaring one off with light is survival, not an
attack. Photos are worth nothing until you exit; die and they are lost.

## Fixed decisions (the owner's)

- Engine: Anchor 3. The 3D layer is extended with point lights first (M0).
- First person. No player model. Photos are instant (no exposure hold).
- The player is a paraplegic light mage who levitates a little above the
  ground: movement feels like walking with a soft float. He floats up along
  wall faces he touches at reduced speed (climbing without hands); sheer or
  overhanging faces are the designed limit. Otherwise movement is constrained
  (no jumping, no sprinting beyond what feels right).
- Photos are taken with a gem on his forehead: the viewfinder is his view.
- Flash exists. The dungeon is built so it is NOT needed everywhere: some
  places are dark (flash useful, and it disturbs creatures), the centerpiece
  is an open cave with a shallow lake and openings above through which
  sunlight falls, where flash is mostly unnecessary. Flash also affects
  creatures (wake, scare, attract: per species).
- The dungeon is AUTHORED, not procedural. One cave complex designed around
  the creatures' behaviors and the vantage points photographs want: the lake
  room has side walls the player can float up, to shoot a wide area of many
  creatures behaving naturally from above; the way up passes dangerous
  creatures that must be dealt with by altering behavior (noise elsewhere,
  thrown food, light), never by fighting.
- Film is LIMITED, no pickups in the dungeon (the owner will add pickups
  later if it feels bad). You choose the count.
- Loop: enter at the entrance, exit through the same entrance. Photos are
  banked only on exit; a results screen at exit grades them and totals the
  money. Death loses everything; the run restarts at the entrance.
- Health: discrete hearts, no regeneration. Exactly ONE creature kills by
  direct attack (two or three hits). Other dangerous creatures are dangerous
  indirectly (examples, yours to pick and shape: one that eats/steals film,
  one whose glare blinds you while others close in, one that lures you over
  deep water where levitation fails, one that calls the attacker). Death
  must be legible: the player should see the danger before it kills.
- Photo grading shown ONLY at exit. The viewfinder shows which subjects are
  in frame (a marker), no numbers while playing.
- Grading is about the creatures in their habitat: quantity in frame,
  behaviors captured (a sleeping one is worth less than a hunting one),
  rarity, and only the best shot per creature counts, with a multiplier for
  several creatures in one photo (Click! by Caranha is the reference:
  https://caranha.itch.io/click). Exact formula is yours.
- The construct: a Pokedex-like companion that floats at his side (a
  "Dross", from Cradle: a talking archive with a personality). Aim at a
  creature and press a key: if the species is catalogued it speaks its
  behavior (voice line + text). ALL species in this dungeon are catalogued
  except ONE: the uncatalogued creature is the dungeon's real goal, but it is
  a SURPRISE, never an explicit objective. The construct goes quiet on it
  (an "I don't know this one" line at most). The construct speaks only
  on demand.
- Voice: `halumi/tools/voice/lines.txt` (`id|text`), rendered by
  `tools/voice/render.sh` into `assets/voice/<id>.ogg` (offline SAPI +
  ffmpeg; the voice is the owner's pick, do not change the chain). You write
  the lines and run the script; the game plays the ogg by id.
- Desktop only. No web build. Mouse + keyboard. No music; minimal sound
  (shutter, hover hum, creature calls, the construct).
- Art: PS1/retro 3D as in the references: low-res 3D layer upscaled with
  nearest filtering, vertex jitter, affine warp, limited palette, coarse
  textures painted at boot, flat/Lambert shading with the new point lights.
  Creatures follow the Simple Retro 3D construction approach (primitives in
  code, curve-driven motion, one or two distinctive poses each), non-humanoid,
  and may take light Pokemon inspiration (readable silhouette, one idea per
  creature). Creatures need LIVES, not only reactions: an idle cycle, a
  relationship to at least one other species, and a flash/noise/food reaction.

## Lore, for naming and the construct's lines (short)

The kingdom's magic is light magic (illusion, signals, fixing light onto a
surface: that is what a photograph is here, "fixed light"). It is a low-magic
world: magic orders society, but the feats are modest. Halumi was a prodigy
fighter who pushed past the ceiling of light magic and lost the use of his
body. What came back with him is a faint telekinesis, unheard of in this
world and dangerous to be known (if such power were common, people could kill
each other at will), so it is weak, hidden, and passes as an enchanted litter:
he sits on a floating slab, legs folded to one side, and moves it with his
mind. He cannot fight anything. A natural-philosophy society pays for fixed
light of creatures nobody else can approach; a silent floating man who
threatens nothing is the only one they ignore long enough. The construct is
the society's catalogue made portable, given to him because he cannot carry
books; proud of what it knows, audibly unsettled by what it does not. Keep
all of this OFF the screen except through the construct's lines and the
results screen's vocabulary.

## Milestones

### M0: point lights in the 3D layer (engine, then STOP and report)

Approach: the 3D layer gains an array of point lights added to the existing
directional + ambient Lambert term. Each light: position, color, radius;
smooth falloff to zero at the radius. Lighting stays PER-VERTEX (PS1 did;
matches jitter and affine; per-fragment looks too modern). Cap: 16 lights per
layer; the game sets the nearest ones each frame. The flash needs nothing
special: a bright short-lived point light at the camera the game fades over a
few frames. Interfaces: two bindings on the layer, set-light-by-index
(position, color, radius) and clear-lights, plus the uniform arrays and a
count uniform in the layer's mesh shader. Billboards and lines stay unlit.
GLSL must stay ES-compatible (the web build shares it, even though we do not
ship web now). Docs: 3D_API.md and ENGINE_API_QUICK.md (signatures, the
per-vertex choice stated), ENGINE_API.md if it has a layer3 section.
Verification: `cd Anchor/engine/engine && ./build.bat` builds clean;
`Anchor/engine/replay-test/check.sh` passes; a playground scene with a few
lights exists so orientation and falloff can be seen in a snapshot (take
one through an agent instance and name the file). Then STOP: report the
files touched, the API, the build and check output, and the snapshot path.
Fable verifies, commits the engine, and refreshes the Horse Game
executable before you continue.

### M1: the body and the place

First-person hover controller (kinematic capsule + raycasts: hover height,
wall-float climbing, deep water where levitation fails, no built-in mover
exists), mouse look via `mouse_set_grabbed` + `mouse_delta`, the PS1 render
stack (low-res layer3 under a full-res UI layer, jitter, affine, fog, low
ambient with point lights), and the authored dungeon as a lit BLOCKOUT: the
entrance, dark passages, the sunlit lake room with its climbable walls and
vantage, whatever else the creatures need. Sun shafts as additive billboards.
One placeholder creature standing in. Report with snapshots from several
positions including the vantage.

### M2: the creatures and the construct

The creature roster in the Simple Retro 3D approach: you choose the count
(enough for the dungeon to feel inhabited and for group photos to exist;
not so many the behaviors go shallow). Each species: construction, idle
cycle, at least one relationship to another species, reactions to flash /
noise / food / the player's approach, danger role. Exactly one lethal
attacker; the uncatalogued surprise, placed so it is found by exploring, not
signposted; the rest dangerous indirectly or harmless. Behavior-altering
tools for the player (your pick among noise, thrown food, light). The
construct: model floating at his side, aim + key, voice lines written to
lines.txt and rendered, text on screen. Report with a per-species table and
snapshots of groups behaving.

### M3: the camera and the loop

Photo taking (instant; a marker for subjects in frame; frustum + raycast
line of sight decide who counts; `engine_snapshot` writes each photo to a
per-run album folder), film count, flash with its light and its behavioral
effect, hearts, the attacker's kill, the indirect deaths, the entrance as
exit, the results screen (each photo, who is in it, what they were doing,
grade, money; best shot per species; group multiplier), restart. A
`tests/smoke.lua` for the agent instance that boots, steps, walks a scripted
path, takes photos, checks the album, reaches the results screen, and
snapshots along the way; Fable runs the same file. Report with the smoke
output and the results-screen snapshot.

### M4: the look and the sound

Creature and dungeon art to the reference quality: textures, palette,
faces, the lake, the light shafts, the construct's look; shutter, hover,
calls, the construct's lines in place. `anchor check` clean. Final report.

## Verification you run

- `anchor check halumi` clean after every milestone.
- Agent instance, from the root: `anchor drive start halumi`,
  `anchor drive eval halumi 'engine_step(120) return <expr>'`,
  `anchor drive eval halumi --file halumi/tests/smoke.lua`,
  `anchor drive stop halumi`. Snapshots via `engine_snapshot(path)` or
  `agent_shot()`. Never a visible window.
- Feel is the owner's; do not report on feel.

## Report format (each stop)

What was built (files); the decisions you made where the packet left them
to you, one line each with the reason; verification run and its output;
snapshot paths; anything noticed but left alone; anything that needs the
owner (a high-level choice, a packet claim that was wrong). Nothing else.
