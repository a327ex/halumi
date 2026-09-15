assert(engine_state().agent and not engine_visible())
run_restart() engine_step(20)
agent_walk_to(0,8) agent_look_at(-2,0.7,-1)
assert(not subject_project(creatures[13]),'unknown visible through alcove screen')
agent_walk_to(10,7) agent_walk_to(12,-11) agent_walk_to(12,-27)
local unknown=creatures[13]
agent_look_at(unknown.x,unknown.y+0.65,unknown.z)
agent_tap('q')
assert(dialogue==VOICE_LINES.veilfin,'unknown consultation did not go quiet')
assert(voice_handle and voice_handle>=0,'unknown voice failed to play')
agent_tap('f') agent_tap('space')
local found=false
for _,s in ipairs(run.photos[1].subjects) do if s.species=='veilfin' then found=true end end
assert(found,'unknown could not be photographed from its approach')
engine_snapshot('replays/shots/m3-alcove.png')
local bell=creatures[12]
agent_look_at(bell.x,bell.y+0.9,bell.z) engine_step(8)
assert(player.glare>0.3,'Glarebell did not dazzle')
player.yaw=math.pi player.pitch=0 engine_step(120)
assert(player.glare<0.1,'looking away did not clear glare')
-- Frame-bound capture keeps the photographic pose/state before flash response.
assert(run.photos[1].flash and unknown.state=='folding')
run_restart() engine_step(10) run.film=1
agent_tap('space') assert(run.film==0 and #run.photos==1)
engine_step(40) agent_tap('space') assert(run.film==0 and #run.photos==1)
run_restart()
return 'EXPLORATION PASS: occluded surprise, alcove route, unknown voice/photograph, glare/look-away, film exhaustion'
