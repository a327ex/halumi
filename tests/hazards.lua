-- Isolated checks of consequences. Main smoke.lua covers the walking route.
assert(engine_state().agent and not engine_visible())
run_restart() engine_step(30)
agent_tap('space')
assert(#run.photos==1)
local lost_folder=run.folder
-- Move the sole attacker to an unobstructed controlled distance. It must
-- visibly wind up and perform three separate attacks through the real AI.
local jaw=creatures[6]
jaw.x,jaw.y,jaw.z=0,0,20.5
local saw_warning=false local first_hit=nil
for _=1,900 do
  engine_step(1)
  if jaw.state=='warning' then saw_warning=true end
  if run.hearts==2 and not first_hit then first_hit=engine_state().frame engine_snapshot('replays/shots/m3-attack.png') end
  if run.mode=='dead' then break end
end
assert(saw_warning and first_hit and run.hearts==0 and run.mode=='dead')
assert(#run.photos==0 and run.total==0)
local f=assert(io.open(lost_folder..'/manifest.tsv','r')) assert(f:read('*a'):find('status\tlost')) f:close()
agent_tap('r') assert(run.mode=='exploring' and run.hearts==3 and run.film==18 and player.z==22)
-- Film theft uses the actual Spoolmite approach, not the damage queue.
local mite=creatures[7] mite.x,mite.y,mite.z=0,0,21.5
engine_step(30) assert(run.film<18 and run.hearts==3)
print('HAZARDS attack: windup, three hits, loss, restart; film theft does not damage hearts')
run_restart() engine_step(10)
agent_walk_to(0,7) agent_walk_to(0,-3)
player.yaw=math.pi/2 input_inject_key('w',true)
local warned=false
for _=1,240 do
  engine_step(1)
  if player.sinking>0 then
    if not warned then engine_snapshot('replays/shots/m3-deep-warning.png') end
    warned=true input_inject_key('w',false)
  end
  if run.mode=='dead' then break end
end
agent_release_movement()
assert(warned and run.mode=='dead' and run.cause=='Your lift failed over deep water.')
assert(run.hearts==3,'water incorrectly used direct attack damage')
run_restart()
return 'HAZARDS PASS: telegraphed three-hit kill, loss/restart, film theft, warned indirect drowning'
