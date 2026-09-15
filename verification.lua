-- Keyboard movement through the real controller; only look direction is supplied.
function agent_release_movement()
  for _,key in ipairs({'w','s','a','d'}) do input_inject_key(key,false) end
end
function agent_walk_to(x,z,limit_frames,watch)
  assert(engine_state().agent)
  for _=1,limit_frames or 2400 do
    if run and run.mode~='exploring' then agent_release_movement() error('walk ended in '..run.mode) end
    local dx,dz=x-player.x,z-player.z
    if length2(dx,dz)<0.13 then agent_release_movement() engine_step(12) return true end
    if watch then
      player.yaw=math.atan(watch.x-player.x,-(watch.z-player.z))
      local _,ey=eye_position()
      player.pitch=math.atan(watch.y+0.7-ey,distance2(watch,player))
    else player.yaw=math.atan(dx,-dz) end
    local n=length2(dx,dz)
    local f=(dx*math.sin(player.yaw)-dz*math.cos(player.yaw))/n
    local r=(dx*math.cos(player.yaw)+dz*math.sin(player.yaw))/n
    input_inject_key('w',f>0.38) input_inject_key('s',f< -0.38)
    input_inject_key('d',r>0.38) input_inject_key('a',r< -0.38)
    engine_step(1)
  end
  agent_release_movement()
  error(string.format('path blocked at %.2f %.2f %.2f toward %.2f %.2f',player.x,player.y,player.z,x,z))
end
function agent_look_at(x,y,z)
  local ex,ey,ez=eye_position() player.yaw=math.atan(x-ex,-(z-ez)) player.pitch=math.atan(y-ey,length2(x-ex,z-ez)) engine_step(1)
end
