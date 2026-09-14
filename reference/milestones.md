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
