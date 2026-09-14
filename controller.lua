MOVE_SPEED=2.8
CLIMB_SPEED=1.45
PLAYER_RADIUS=0.3
HOVER_HEIGHT=0.42
function player_boot()
  player={x=0,y=HOVER_HEIGHT,z=22,yaw=0,pitch=0,vx=0,vz=0,vy=0,sinking=0,climbing=false}
  player.body=physics3_create_body('kinematic',0,1.1,22)
  physics3_add_capsule(player.body,'player',1.4,PLAYER_RADIUS)
end
function player_reset()
  player.x,player.y,player.z=0,HOVER_HEIGHT,22
  player.vx,player.vz,player.vy=0,0,0 player.yaw,player.pitch,player.sinking=0,0,0
  physics3_set_transform(player.body,0,player.y+0.65,22,0,0,0,1)
end
function player_camera()
  local ex,ey,ez=eye_position() local dx,dy,dz=aim_vector()
  layer3_camera(scene,ex,ey,ez,ex+dx,ey+dy,ez+dz,64,0.07,65)
end
function wall_probe(dx,dz)
  local n=length2(dx,dz) if n<0.00001 then return nil end
  local ux,uz=dx/n,dz/n local best=nil
  for _,h in ipairs({0.05,0.65,1.25}) do for _,side in ipairs({-0.75,0,0.75}) do
    local x=player.x-uz*PLAYER_RADIUS*side local z=player.z+ux*PLAYER_RADIUS*side
    local hit=physics3_raycast(x,player.y+h,z,x+ux*(n+PLAYER_RADIUS),player.y+h,z+uz*(n+PLAYER_RADIUS),{'stone'})
    if hit and (not best or hit.fraction<best.fraction) then best=hit end
  end end
  return best
end
function player_update(dt)
  if pointer_locked then local mx,my=mouse_delta() player.yaw=player.yaw+mx*0.0025 player.pitch=limit(player.pitch-my*0.0025,-1.35,1.35) end
  local f=(input_down('forward') and 1 or 0)-(input_down('back') and 1 or 0)
  local r=(input_down('right') and 1 or 0)-(input_down('left') and 1 or 0)
  local norm=math.max(1,length2(f,r)) f,r=f/norm,r/norm
  local dx=math.sin(player.yaw)*f+math.cos(player.yaw)*r local dz=-math.cos(player.yaw)*f+math.sin(player.yaw)*r
  player.vx=approach(player.vx,dx*MOVE_SPEED,11,dt) player.vz=approach(player.vz,dz*MOVE_SPEED,11,dt)
  dx,dz=player.vx*dt,player.vz*dt player.climbing=false local dy=0
  -- Sweep at three capsule heights and radial offsets; project onto contacted faces.
  for _=1,3 do
    local hit=wall_probe(dx,dz) if not hit then break end
    local nx,ny,nz=hit.normal_x,hit.normal_y,hit.normal_z local into=dx*nx+dz*nz
    if ny>0.12 and ny<0.78 and into<0 then
      local rise=-into/ny local n=math.sqrt(dx*dx+dz*dz+rise*rise)
      local scale=math.min(1,CLIMB_SPEED*dt/math.max(n,0.00001))
      dx,dz,dy=dx*scale,dz*scale,rise*scale player.climbing=true break
    elseif into<0 then
      local n2=nx*nx+nz*nz
      if n2>0.001 then dx,dz=dx-into*nx/n2,dz-into*nz/n2 else dx,dz=0,0 end
    else dx,dz=0,0 end
  end
  local ceiling=physics3_raycast(player.x,player.y+1.3,player.z,player.x+dx,player.y+1.3+dy+0.1,player.z+dz,{'stone'})
  if ceiling then dy=0 dx,dz=0,0 player.climbing=false end
  player.x,player.z=player.x+dx,player.z+dz player.y=player.y+dy
  local ground=world_ground(player.x,player.z,player.y+0.7)
  if is_deep(player.x,player.z) and player.y<1.1 then
    player.vy=player.vy-3.5*dt player.y=player.y+player.vy*dt player.sinking=player.sinking+dt
  elseif ground then
    player.sinking=0 player.vy=0
    local target=ground.point_y+HOVER_HEIGHT+math.sin(clock_time*2.4)*0.025
    if not player.climbing then player.y=approach(player.y,target,9,dt) end
    player.y=math.max(player.y,ground.point_y+0.32)
  else player.vy=player.vy-5*dt player.y=player.y+player.vy*dt end
  physics3_set_transform(player.body,player.x,player.y+0.65,player.z,0,0,0,1)
end
