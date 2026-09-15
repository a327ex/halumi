function models_boot()
  local body={} mesh3_sphere_blob(body,0,0,0,0.5,10,6) body_mesh=mesh3_create(body)
  face_meshes={}
  for id,s in pairs(SPECIES) do
    local texture=pixel_texture(16,16,function(x,y)
      local eye=(x==4 or x==10) and y>=5 and y<=7
      local mouth=y==11 and x>=6 and x<=8
      if eye or mouth then return 24,32,39,255 end
      return 0,0,0,0
    end,'clamp')
    local out={} mesh3_quad(out,-0.5,-0.5,0,0.5,-0.5,0,0.5,0.5,0,-0.5,0.5,0,0,0,1,0,0,1,1)
    face_meshes[id]=mesh3_create(out) mesh3_set_texture(face_meshes[id],texture)
  end
  layer3_set_alpha_cutoff(scene,0.1)
end
function model_part(c,kind,x,y,z,w,h,d,col,tilt)
  local qx,qy,qz,qw=quat_from_euler(c.yaw,tilt or 0,0)
  local ox,oy,oz=quat_rotate_vec(qx,qy,qz,qw,x,y,z)
  if kind=='sphere' then
    -- A custom flat-shaded primitive gives each part independent proportions.
    layer3_mesh(scene,body_mesh,c.x+ox,c.y+oy,c.z+oz,w,h,d,qx,qy,qz,qw,col)
  elseif kind=='cone' then layer3_mesh(scene,meshes.cone,c.x+ox,c.y+oy,c.z+oz,w,h,d,qx,qy,qz,qw,col)
  else layer3_box(scene,c.x+ox,c.y+oy,c.z+oz,w,h,d,qx,qy,qz,qw,col) end
end
function creature_draw(c)
  local s=SPECIES[c.species] local t=clock_time+c.id local gait=math.sin(c.phase*5)*math.min(c.speed,1)
  local sleeping=c.state=='sleeping' or c.state=='closed' local bob=math.sin(t*2)*0.025
  local col=s.color
  if c.species=='cupcap' then
    model_part(c,'sphere',0,0.43+bob,0,0.9,sleeping and 0.4 or 0.8,0.9,col)
    model_part(c,'sphere',0,0.95+bob,0,1.18,0.3,1.1,0x985e4fff)
    for _,side in ipairs({-1,1}) do model_part(c,'box',side*0.26,0.13+math.max(0,gait*side)*0.10,0.05,0.20,0.22,0.36,0x6b5145ff) end
  elseif c.species=='slatejaw' then
    local wind=c.state=='warning' and pose_curve(clock_time-c.since,{{0,0},{0.7,0.3},{1.05,0.45}}) or 0
    model_part(c,'sphere',0,0.57,0,1.5,0.85,1.7,col)
    model_part(c,'box',0,0.4-wind*0.3,0.8,1.1,0.18,0.8,0xb7bba5ff)
    model_part(c,'box',0,0.7+wind,0.7,1.18,0.28,0.8,col,-wind)
    for _,side in ipairs({-1,1}) do for _,endz in ipairs({-0.5,0.5}) do
      model_part(c,'box',side*0.62,0.15+math.max(0,gait*side*endz)*0.15,endz,0.22,0.3,0.4,0x505e67ff)
    end end
    for i=-1,1 do model_part(c,'cone',i*0.35,0.85,-0.3,0.25,0.48,0.35,0x97a8a1ff) end
  elseif c.species=='spoolmite' then
    model_part(c,'sphere',0,0.3,0,0.65,0.5,0.72,col)
    local snout=c.state=='stealing' and 0.5 or 0.28+math.sin(t*5)*0.025
    model_part(c,'box',0,0.25,0.4+snout*0.5,0.12,0.12,snout,0xd1b3a0ff)
    for _,side in ipairs({-1,1}) do model_part(c,'box',side*0.25,0.07+math.max(0,gait*side)*0.05,0,0.13,0.12,0.25,0x78586bff) end
  elseif c.species=='glarebell' then
    local open=sleeping and 0.2 or 0.75+math.sin(t*2)*0.09
    model_part(c,'cone',0,0,0,0.35,1.1,0.35,0x859b8dff)
    model_part(c,'sphere',0,1.15+bob,0,0.75,0.6,0.75,col)
    for i=0,4 do local a=i*math.pi*2/5
      model_part(c,'sphere',math.cos(a)*open*0.45,1.05+bob,math.sin(a)*open*0.45,0.35,0.22,0.35,col)
    end
    layer3_billboard(scene,c.x,c.y+1.22,c.z,open*0.4,open*0.4,c.state=='dazzling' and WHITE or 0xb9dcacff,tex.white,'add')
  else
    local folded=c.state=='folding' and 0.2 or 1
    local y=1.1+math.sin(t*1.7)*0.14
    for i=0,3 do model_part(c,'sphere',math.sin(t*2-i)*0.13,y-i*0.12,-i*0.23,0.5-i*0.09,0.6-i*0.1,0.45,col) end
    for _,side in ipairs({-1,1}) do model_part(c,'cone',side*0.2,y-0.1,0,folded*1.1,0.08,0.65,0x719eabff,side*0.3) end
  end
  local facey=c.species=='glarebell' and 1.25 or c.species=='veilfin' and 1.2+bob or s.height*0.59
  local facez=c.species=='slatejaw' and 1.13 or s.radius*0.84
  local qx,qy,qz,qw=quat_from_euler(c.yaw,0,0)
  local x,y,z=quat_rotate_vec(qx,qy,qz,qw,0,facey,facez)
  layer3_mesh(scene,face_meshes[c.species],c.x+x,c.y+y,c.z+z,s.radius*1.1,sleeping and 0.08 or s.radius*1.1,1,qx,qy,qz,qw,WHITE)
end
function construct_draw()
  local ex,ey,ez=eye_position() local fx,fy,fz=aim_vector()
  local x=ex+math.cos(player.yaw)*0.65+fx*0.95 local z=ez+math.sin(player.yaw)*0.65+fz*0.95
  local y=ey-0.35+fy*0.95+math.sin(clock_time*2)*0.035
  local qx,qy,qz,qw=quat_from_euler(clock_time*0.6,0,0.4)
  layer3_box(scene,x,y,z,0.17,0.23,0.17,qx,qy,qz,qw,0x73a9a7ff)
  layer3_billboard(scene,x,y,z,0.065,0.065,0xf4dea5ff,tex.white,'add')
  for i=0,3 do local a=clock_time+i*math.pi/2 layer3_box(scene,x+math.cos(a)*0.18,y+math.sin(a)*0.12,z,0.08,0.03,0.06,0,0,0,1,GOLD) end
end
