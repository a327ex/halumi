-- Close model captures in the real sunlit room; no visible window.
assert(engine_state().agent and not engine_visible())
run_restart() engine_step(20)
local folder='replays/shots/m4-models-'..os.date('%Y%m%d-%H%M%S')
for _,i in ipairs({1,6,7,10,13}) do
  local c=creatures[i]
  c.x,c.y,c.z=0,0,0 c.yaw=0 c.visual_yaw=0 c.target=nil c.state='resting' c.until_time=clock_time+100
  c.feet=nil
  player.x,player.y,player.z=0,0.42,3.0 player.vx,player.vz=0,0
  agent_look_at(0,c.species=='glarebell' and 0.9 or 0.65,0)
  engine_snapshot(folder..'/'..c.species..'.png')
  if c.species=='slatejaw' then
    c.state='warning' c.since=clock_time-0.85
    engine_step(1) engine_snapshot(folder..'/slatejaw-warning.png')
  elseif c.species=='veilfin' then
    c.state='folding' engine_step(1) engine_snapshot(folder..'/veilfin-folded.png')
  end
  c.x,c.y,c.z=c.home.x,c.home.y,c.home.z
  c.feet=nil
end
run_restart()
return folder
