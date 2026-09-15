# First pass milestone record

## M1

Built: main/boot split; common.lua, art.lua, world.lua, controller.lua,
verification.lua, tests/m1.lua; local font; two point-light declarations and
corrected texture/shader annotations in the game's framework copy.

Decisions: 320x180 scene under 960x540 UI; 2.8 m/s movement, 1.45 m/s ascent,
0.42 m hover, 0.3 m capsule radius. A sloping west wall climbs 6 m to a
vantage; vertical walls and the overhang are limits. The authored lake has
pale shallows and a dark deep basin; a screened northeast alcove is reserved
for the later encounter. Muted stone, affine UVs, palette quantization, low
ambient and sunlight point lights establish the blockout render stack.

Verification: anchor check halumi: 0 errors, 0 warnings. tests/m1.lua PASS:
hover, walking entrance to lake, real-controller wall ascent, vertical limit,
deep-water loss of lift. Hidden agent only. Captures:
replays/shots/m1-entrance.png, m1-lake.png, m1-vantage.png.

Limitations: terrain is an authored blockout; art polish remains M4. Capsule
movement uses height/radius ray samples against static geometry, not Box3D's
unbound mover. No engine changes. No owner decision needed.

## M2

Built: creatures.lua, models.lua, subjects.lua, tools_game.lua; five species,
13 individuals, procedural primitive assembly/face textures, idle and reaction
poses, a side-floating construct, aim-and-Q consultation, pebbles, five food
portions and a steady light. Wrote the five requested voice lines to the
existing tools/voice/lines.txt. Main/boot/world connect the systems.

Roster: Cupcap x5 (grazer/pollinator/prey), Slatejaw x1 (telegraphed attacker,
hunts Cupcaps), Spoolmite x3 (film theft, follows grazers, flees Slatejaw),
Glarebell x3 (pollen, glare and predator alarm), Veilfin x1 (uncatalogued;
observes mites, echoes the nearby bell, folds under flash/close approach).
Flash, noise, food and proximity reactions are implemented for every species.
Health/film consequences are connected in M3. The unknown has no objective or
world label; the construct admits it has no entry only when asked.

Verification: anchor check halumi: 0 errors, 0 warnings. tests/m2.lua PASS:
population/role counts, aimed consultation, real thrown-food landing, and
every species' flash reaction. Captures: replays/shots/m2-lake-group.png,
m2-construct.png, m2-feeding.png. Hidden agent only.

Voice rendering at the M2 stop: invoked the unchanged render.sh. Git Bash mkdir -p could not
traverse the sandboxed profile; precreated the local temp directory and retried
with mkdir skipping existing directories. SAPI SelectVoice/SetOutputToWaveFile/
SpeakSsml then failed with NullReferenceException; no new OGGs were produced.
No voice/processing-chain substitution. During M3 all five requested OGGs
became available. The engine loaded all five, ffprobe validated durations
2.62-9.67 seconds, and the exploration test verified successful on-demand
playback of the unknown line. The five clips are included in the M3 commit.

Art remains a first construction pass; M4 polish is not included. No engine
changes or high-level owner choice needed.

## M3

Built: camera_game.lua, main/boot integration, tests/smoke.lua,
tests/hazards.lua, tests/exploration.lua, albums/.gitkeep, README controls;
camera frustum + physics ray subject tests, markers without grades, instant
PNG plates, flash before behavioral disturbance, hearts, film loss, death,
same-entrance banking, browsable results, restart. The verification driver
can strafe with the light aimed at a moving threat while following a route.
Changed the M1 upscale helper to standard layer_draw, which is recorded.

Decisions: 18 film, 3 hearts, 5 food portions. Three Slatejaw hits kill;
invulnerability lasts 1.8 s after a hit. Deep-water lift failure warns before
drowning at 1.5 s. Film is never replenished inside the cave. Only best per
species pays (the packet's M3 wording); each species contribution is base x
rarity x best captured behavior/exposure/framing x sqrt(quantity) x group
multiplier. Group = 1 + 0.18*(min(subject count,8)-1). Grades are calculated
only on exit. Failed-run files remain as evidence with a lost manifest;
the playable album and money are cleared. No camera/construct/UI in plate PNGs.

Verification: anchor check halumi 0 errors, 0 warnings; git diff --check
clean. Final smoke: 3 plates, first plate 7 subjects, vantage plate 8 subjects,
3 hearts left, 763 crowns at extraction. Best-per-species sum, PNG signature,
unbanked state, flash reactions, food landing, walking/climbing and results
gallery navigation asserted. Album albums/20260914-211135-002;
results screenshot albums/20260914-211135-002/results.png, vantage.png.
Hazards PASS: windup, three attacks, losing album, restart, actual mite theft,
warning before indirect drowning. Exploration PASS: unknown blocked from
lake view, real route to alcove, consultation voice, unknown photo, glare
and clearing by looking away, film exhaustion. Short live/playback comparison:
60/60 frames byte-identical (replays/m3-roundtrip-v1.apr).

Remaining: M4 art/audio polish (shutter, hover, calls) not attempted. NPC
navigation uses local steering and static ray checks rather than pathfinding;
the authored routes and test paths are verified, feel is not assessed.
All work stays in halumi; no engine, Horse Game or publishing changes.
No high-level choice or other owner action required for M1-M3.
