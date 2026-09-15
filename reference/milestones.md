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

Voice limitation: invoked the unchanged render.sh. Git Bash mkdir -p could not
traverse the sandboxed profile; precreated the local temp directory and retried
with mkdir skipping existing directories. SAPI SelectVoice/SetOutputToWaveFile/
SpeakSsml then failed with NullReferenceException; no new OGGs were produced.
No voice/processing-chain substitution. Fable must render the lines in the
owner's Windows session; text and per-id sound loading are in place.

Art remains a first construction pass; M4 polish is not included. No engine
changes or high-level owner choice needed.
