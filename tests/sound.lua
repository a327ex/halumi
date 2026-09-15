assert(engine_state().agent and not engine_visible())
run_restart() engine_step(3)
assert(soundscape.hover and soundscape.hover>=0)
for id in pairs(SOUND_DEFS) do
  assert(soundscape.assets[id],id..' missing')
  if id~='hover_hum' then assert(sound_emit(id,0.2,1)>=0,id..' has no playback handle') end
end
engine_step(90)
assert(#soundscape.active==0,'one-shot handles did not expire')
local before=soundscape.count.shutter or 0
agent_tap('space') assert((soundscape.count.shutter or 0)==before+1)
local pebbles=soundscape.count.pebble_impact or 0
agent_tap('e') engine_step(150) assert((soundscape.count.pebble_impact or 0)>pebbles)
local hover=soundscape.hover
run_bank() engine_step(5) run_restart() engine_step(5)
assert(soundscape.hover==hover,'hover allocated a fresh slot on restart')
return 'SOUND PASS: 10 IDs load; owned one-shots expire; shutter/pebble triggers; one reusable hover loop'
