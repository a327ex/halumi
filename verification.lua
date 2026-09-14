-- Keyboard movement through the real controller; only look direction is supplied.
function agent_walk_to(x,z,limit_frames)
  assert(engine_state().agent)
  for _=1,limit_frames or 2400 do
    local dx,dz=x-player.x,z-player.z
    if length2(dx,dz)<0.13 then input_inject_key('w',false) engine_step(12) return true end
    player.yaw=math.atan(dx,-dz) input_inject_key('w',true) engine_step(1)
  end
  input_inject_key('w',false)
  error(string.format('path blocked at %.2f %.2f %.2f toward %.2f %.2f',player.x,player.y,player.z,x,z))
end
function agent_look_at(x,y,z)
  local ex,ey,ez=eye_position() player.yaw=math.atan(x-ex,-(z-ez)) player.pitch=math.atan(y-ey,length2(x-ex,z-ez)) engine_step(1)
end
