assert(engine_state().agent and not engine_visible())
run_restart()
local counts={} local attackers,unknown=0,0
for _,c in ipairs(creatures) do
  counts[c.species]=(counts[c.species] or 0)+1
  if SPECIES[c.species].attacker then attackers=attackers+1 end
  if SPECIES[c.species].unknown then unknown=unknown+1 end
  assert(SPECIES[c.species].relation)
end
assert(#creatures==13 and attackers==1 and unknown==1)
assert(counts.cupcap==5 and counts.glarebell==3)
agent_walk_to(0,7) agent_look_at(-2,0.7,-1)
engine_step(180) engine_snapshot('replays/shots/m2-lake-group.png')
local target=creatures[1]
agent_look_at(target.x,target.y+0.6,target.z)
agent_tap('q')
assert(dialogue==VOICE_LINES.cupcap,'aimed consultation failed')
engine_snapshot('replays/shots/m2-construct.png')
local before=food_left
agent_tap('g') engine_step(150)
assert(food_left==before-1 and #stimuli>0,'food did not land')
assert(stimuli[#stimuli].kind=='food')
engine_snapshot('replays/shots/m2-feeding.png')
-- Species reactions, applied through the same stimulus as the camera flash.
for _,c in ipairs(creatures) do
  creatures_flash(c.x,c.y+1,c.z)
  assert(c.until_time>clock_time,'species has no flash reaction: '..c.species)
end
run_restart()
return 'M2 PASS: 13 creatures, 5 species, 1 attacker, 1 unknown; consultation, thrown food and all flash reactions; 3 snapshots'
