function subject_aim_dot(c)
  local x,y,z=eye_position() local fx,fy,fz=aim_vector()
  local dx,dy,dz=c.x-x,c.y+SPECIES[c.species].height*0.55-y,c.z-z
  return (dx*fx+dy*fy+dz*fz)/math.max(0.001,math.sqrt(dx*dx+dy*dy+dz*dz))
end
function subject_project(c)
  local x,y,z=eye_position() local fx,fy,fz=aim_vector()
  local dx,dy,dz=c.x-x,c.y+SPECIES[c.species].height*0.55-y,c.z-z
  local depth=dx*fx+dy*fy+dz*fz
  if depth<0.2 or depth>38 then return nil end
  local rx,rz=math.cos(player.yaw),math.sin(player.yaw)
  local uy=math.cos(player.pitch) local ux,uz=-math.sin(player.yaw)*math.sin(player.pitch),math.cos(player.yaw)*math.sin(player.pitch)
  local focal=270/math.tan(math.rad(32))
  local sx,sy=480+(dx*rx+dz*rz)*focal/depth,270-(dx*ux+dy*uy+dz*uz)*focal/depth
  local radius=SPECIES[c.species].radius*focal/depth
  if sx<20 or sx>940 or sy<20 or sy>520 then return nil end
  local hit=physics3_raycast(x,y,z,c.x,c.y+SPECIES[c.species].height*0.55,c.z,{'stone','creature'})
  if hit and (hit.tag=='stone' or physics3_get_user_data(hit.body)~=c.id) then return nil end
  return {c=c,x=sx,y=sy,radius=radius,depth=depth}
end
function aimed_subject()
  local best,d=nil,100000
  for _,c in ipairs(creatures) do
    local p=subject_project(c)
    if p then local n=length2(p.x-480,p.y-270)
      if n<math.max(28,p.radius) and n<d then best,d=c,n end
    end
  end
  return best
end
