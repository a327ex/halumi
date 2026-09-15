function profile_mesh(profile,sides)
  local out={} sides=sides or 12
  local function pt(p,a) return {math.sin(a)*p[1],p[2],math.cos(a)*p[1]} end
  for j=1,#profile-1 do for i=0,sides-1 do
    local a=pt(profile[j],i*math.pi*2/sides) local b=pt(profile[j],(i+1)*math.pi*2/sides)
    local c=pt(profile[j+1],(i+1)*math.pi*2/sides) local d=pt(profile[j+1],i*math.pi*2/sides)
    local nx,ny,nz=vec3_cross(b[1]-a[1],b[2]-a[2],b[3]-a[3],d[1]-a[1],d[2]-a[2],d[3]-a[3])
    local l=math.sqrt(nx*nx+ny*ny+nz*nz)
    if l<0.0001 then nx,ny,nz=vec3_cross(c[1]-a[1],c[2]-a[2],c[3]-a[3],d[1]-a[1],d[2]-a[2],d[3]-a[3]) l=math.max(0.0001,math.sqrt(nx*nx+ny*ny+nz*nz)) end
    mesh3_quad(out,a[1],a[2],a[3],b[1],b[2],b[3],c[1],c[2],c[3],d[1],d[2],d[3],nx/l,ny/l,nz/l,i/sides,(j-1)/#profile,(i+1)/sides,j/#profile)
  end end
  return mesh3_create(out)
end
function face_texture(species,expression)
  local bases={cupcap={242,216,158},slatejaw={178,196,182},spoolmite={246,191,171},glarebell={249,222,133},veilfin={199,231,226}}
  return pixel_texture(32,32,function(x,y)
    local dx,dy=(x-15.5)/15,(y-15.5)/15
    if dx*dx+dy*dy>1 then return 0,0,0,0 end
    local base=bases[species]
    local left=x>=7 and x<=10 local right=x>=21 and x<=24
    local eye=(left or right) and y>=10 and y<=16
    if expression=='sleep' then eye=(x>=6 and x<=11 or x>=20 and x<=25) and y==15 end
    if expression=='alert' then eye=(left or right) and y>=8 and y<=17 end
    local mouth=(y==22 and x>=13 and x<=18) or (expression=='alert' and x>=14 and x<=17 and y>=21 and y<=25)
    if eye or mouth then
      if expression~='sleep' and y==10 and (x==8 or x==22) then return 255,252,220,255 end
      return 28,40,43,255
    end
    if (x==5 or x==26) and y>=18 and y<=20 then return 213,139,111,255 end
    local n=(x+y*3)%13==0 and -5 or 0
    return base[1]+n,base[2]+n,base[3]+n,255
  end,'clamp')
end
function models_boot()
  model_meshes={}
  local out={} mesh3_sphere_blob(out,0,0,0,0.5,12,8) body_mesh=mesh3_create(out)
  model_meshes.cap=profile_mesh({{0,0},{0.37,0},{0.61,0.06},{0.69,0.21},{0.65,0.31},{0.56,0.32},{0.49,0.18},{0,0.15}},14)
  model_meshes.spool=profile_mesh({{0,0},{0.3,0},{0.3,0.09},{0.19,0.11},{0.19,0.32},{0.3,0.34},{0.3,0.43},{0,0.43}},12)
  model_meshes.bell=profile_mesh({{0,0},{0.52,0},{0.55,0.08},{0.37,0.37},{0.18,0.52},{0,0.54}},10)
  model_meshes.petal=profile_mesh({{0,0},{0.12,0.03},{0.24,0.2},{0.19,0.43},{0,0.6}},8)
  out={}
  mesh3_tri(out,0,0,0,0.9,-0.12,-0.25,0.65,0.12,0.32,0,1,0,0,0,1,0,1,1)
  mesh3_tri(out,0,0,0,0.65,0.12,0.32,0.16,0.06,0.42,0,1,0,0,0,1,1,0,1)
  model_meshes.fin=mesh3_create(out)
  out={}
  for i=0,15 do
    local a,b=i*math.pi/8,(i+1)*math.pi/8
    mesh3_quad(out,math.cos(a)*0.5,math.sin(a)*0.5,0,math.cos(b)*0.5,math.sin(b)*0.5,0,
      math.cos(b)*0.38,math.sin(b)*0.38,0,math.cos(a)*0.38,math.sin(a)*0.38,0,0,0,1,0,0,1,1)
  end
  model_meshes.ring=mesh3_create(out)
  face_meshes={}
  for id in pairs(SPECIES) do
    face_meshes[id]={}
    for _,expression in ipairs({'awake','sleep','alert'}) do
      out={} mesh3_quad(out,-0.5,-0.5,0,0.5,-0.5,0,0.5,0.5,0,-0.5,0.5,0,0,0,1,0,0,1,1)
      local m=mesh3_create(out) mesh3_set_texture(m,face_texture(id,expression)) face_meshes[id][expression]=m
    end
  end
  layer3_set_alpha_cutoff(scene,0.1)
end
function model_part(c,kind,x,y,z,w,h,d,col,tilt,roll,turn)
  local qx,qy,qz,qw=quat_from_euler(c.visual_yaw or c.yaw,c.pose_pitch or 0,c.pose_roll or 0)
  local ox,oy,oz=quat_rotate_vec(qx,qy,qz,qw,x,y,z)
  local ax,ay,az,aw=quat_from_euler(turn or 0,tilt or 0,roll or 0)
  qx,qy,qz,qw=quat_mul(qx,qy,qz,qw,ax,ay,az,aw)
  if kind=='box' then layer3_box(scene,c.x+ox,c.y+oy,c.z+oz,w,h,d,qx,qy,qz,qw,col)
  else
    local mesh=kind=='sphere' and body_mesh or kind=='cone' and meshes.cone or model_meshes[kind] or kind
    layer3_mesh(scene,mesh,c.x+ox,c.y+oy,c.z+oz,w,h,d,qx,qy,qz,qw,col)
  end
end
function models_update(c,dt)
  local angle=math.atan(math.sin(c.yaw-(c.visual_yaw or c.yaw)),math.cos(c.yaw-(c.visual_yaw or c.yaw)))
  c.visual_yaw=(c.visual_yaw or c.yaw)+angle*math.min(1,dt*9)
  if c.species~='cupcap' and c.species~='slatejaw' and c.species~='spoolmite' then return end
  local sides=c.species=='slatejaw' and {{-1,-1},{1,1},{-1,1},{1,-1}} or {{-1,0},{1,0}}
  local width=c.species=='slatejaw' and 0.58 or c.species=='cupcap' and 0.25 or 0.22
  c.feet=c.feet or {}
  local active=0 for _,f in ipairs(c.feet) do if f.t<1 then active=active+1 end end
  for i,s in ipairs(sides) do
    local lx,lz=s[1]*width,s[2]*0.45
    local x=c.x+lx*math.cos(c.visual_yaw)+lz*math.sin(c.visual_yaw)
    local z=c.z-lx*math.sin(c.visual_yaw)+lz*math.cos(c.visual_yaw)
    local f=c.feet[i] or {x=x,z=z,t=1,y=c.y+0.06,yaw=c.visual_yaw} c.feet[i]=f
    if f.t>=1 and length2(f.x-x,f.z-z)>0.22 and active<(c.species=='slatejaw' and 2 or 1) then
      f.t=0 f.sx,f.sz=f.x,f.z
      f.tx=x+math.sin(c.yaw)*math.min(0.12,c.speed*0.07) f.tz=z+math.cos(c.yaw)*math.min(0.12,c.speed*0.07)
      active=active+1
    end
    if f.t<1 then
      f.t=math.min(1,f.t+dt/0.19) local t=ease(f.t)
      f.x,f.z=f.sx+(f.tx-f.sx)*t,f.sz+(f.tz-f.sz)*t f.yaw=c.visual_yaw
    end
    f.y=c.y+0.06+(f.t<1 and math.sin(f.t*math.pi)*0.13 or 0)
  end
end
function model_feet(c,col)
  for _,f in ipairs(c.feet or {}) do
    local qx,qy,qz,qw=quat_from_euler(f.yaw,0,0)
    layer3_box(scene,f.x,f.y,f.z,c.species=='slatejaw' and 0.25 or 0.19,0.12,0.32,qx,qy,qz,qw,col)
    local dx,dz=f.x-c.x,f.z-c.z
    layer3_cylinder(scene,f.x-dx*0.16,c.y+0.18,f.z-dz*0.16,0.25,0.07,0,0,0,1,col)
  end
end
function model_face(c,id,expression,x,y,z,size)
  model_part(c,face_meshes[id][expression],x,y,z,size,size,1,WHITE)
end
function creature_draw(c)
  local t=clock_time+c.id local moving=math.min(c.speed,1)
  local sleep=c.state=='sleeping' or c.state=='closed'
  local alert=c.state=='warning' or c.state=='startled' or c.state=='dazzling' or c.state=='stealing'
  local blink=(t%4.9)>4.72
  local expression=(sleep or blink) and 'sleep' or alert and 'alert' or 'awake'
  local p={x=c.x,y=c.y,yaw=c.visual_yaw or c.yaw,z=c.z,pose_roll=math.sin(c.phase*5)*0.045*moving}
  local bob=math.sin(t*2.2)*0.025+math.abs(math.sin(c.phase*5))*0.02*moving
  if c.species=='cupcap' then
    local drink=(c.state=='drinking' or c.state=='feeding') and pose_curve(t%2.4,{{0,0},{0.6,0.18},{1.5,0.22},{2.4,0}}) or 0
    p.pose_pitch=drink p.y=p.y+bob
    local squash=sleep and 0.67 or 1
    model_part(p,'sphere',0,0.47*squash,0,0.88,0.86*squash,0.83,0xe6bf81ff)
    model_part(p,'cap',0,0.78*squash,0,1,1,1,0xc06f54ff)
    model_part(p,'sphere',0,0.925*squash,0,0.93,0.02,0.93,0x769f9aff)
    model_face(p,'cupcap',expression,0,0.52*squash,0.426,0.57)
    for _,side in ipairs({-1,1}) do model_part(p,'sphere',side*0.39,0.32*squash,0,0.22,0.3,0.25,0xd7ab71ff) end
    model_feet(c,0x8b6a48ff)
  elseif c.species=='slatejaw' then
    local wind=c.state=='warning' and pose_curve(clock_time-c.since,{{0,0},{0.65,0.25},{1.05,0.55}}) or 0
    if c.state=='lunging' then wind=pose_curve(clock_time-c.since,{{0,0.5},{0.12,-0.06},{0.35,0}}) end
    p.y=p.y+bob*0.5
    model_part(p,'sphere',0,0.6,-0.1,1.48,0.93,1.72,0x8d9b92ff)
    for row=0,2 do
      model_part(p,'box',0,0.92-row*0.035,-0.65+row*0.4,1.25,0.23,0.48,row%2==0 and 0x677b7cff or 0x738982ff,0.1)
      model_part(p,'cone',0,1.04,-0.65+row*0.4,0.23,0.3,0.35,0xabb9a0ff)
    end
    model_part(p,'box',0,0.39,0.72,1.03,0.18,0.91,0xc3c7a4ff)
    model_part(p,'box',0,0.495,0.77,0.88,0.035,0.72,0x3c5054ff)
    local hinge_y,hinge_z=0.69,0.37
    local ox,oy,oz=0,0,0
    -- Explicit hinge offset: nose rises while the back of the jaw stays fixed.
    oy,oz=math.sin(wind)*0.38,math.cos(wind)*0.38
    model_part(p,'box',ox,hinge_y+oy,hinge_z+oz,1.16,0.28,0.93,0x84988fff,-wind)
    for _,side in ipairs({-1,1}) do
      local ey=hinge_y+0.29*math.cos(wind)+0.70*math.sin(wind)
      local ez=hinge_z-0.29*math.sin(wind)+0.70*math.cos(wind)
      model_part(p,'sphere',side*0.43,ey,ez,0.24,0.18,0.19,0xf1dc9aff)
      model_part(p,'box',side*0.43,ey,ez+0.10,0.06,0.09,0.035,0x263c40ff)
      for j=0,2 do model_part(p,'cone',side*(0.22+j*0.11),0.49,0.82,0.12,0.14,0.14,0xefdfb4ff) end
    end
    model_feet(c,0x536768ff)
  elseif c.species=='spoolmite' then
    p.y=p.y+bob*0.6
    local flick=(c.state=='stealing' or c.state=='feeding') and pose_curve(t%1.1,{{0,0},{0.2,-0.08},{0.35,0.22},{0.7,-0.04},{1.1,0}}) or 0
    model_part(p,'sphere',0,0.31,0.05,0.63,0.55,0.73,0xe4aaafff)
    model_part(p,'spool',0.22,0.34,-0.17,1,1,1,0x976b88ff,0,math.pi/2)
    model_part(p,'sphere',0,0.28+flick*0.4,0.42+flick,0.19,0.19,0.47+flick,0xf0c3a4ff,0.13)
    model_part(p,'sphere',0,0.22+flick*0.4,0.64+flick,0.14,0.14,0.12,0x6e617aff)
    for _,side in ipairs({-1,1}) do model_part(p,'cone',side*0.2,0.48,-0.02,0.15,0.32,0.2,0xba829bff,0,side*0.35) end
    model_face(p,'spoolmite',expression,0,0.38,0.375,0.35)
    if c.state=='stealing' then model_part(p,'box',0,0.18,0.76,0.13,0.02,0.27,GOLD,-0.3) end
    model_feet(c,0x8c667cff)
  elseif c.species=='glarebell' then
    local open=sleep and 0.08 or c.state=='dazzling' and 1 or 0.7+math.sin(t*2)*0.07
    local lean=c.state=='pollinating' and 0.1 or 0
    model_part(p,'cone',0,0,0,0.23,0.78,0.23,0x789684ff)
    model_part(p,'sphere',0,0.91+bob,0,0.31,0.42,0.31,0xb5c996ff)
    for i=0,5 do
      local a=i*math.pi/3 local r=open*0.44
      model_part(p,'petal',math.cos(a)*r,0.94+bob,math.sin(a)*r,0.75,1.1,0.75,i%2==0 and 0xaaa8d0ff or 0x858faeff,-math.sin(a)*open,-math.cos(a)*open)
    end
    local core_y=1.24+open*0.18+bob
    model_part(p,'sphere',0,core_y,0.06,0.54,0.49,0.48,0xf0d993ff)
    model_face(p,'glarebell',expression,0,core_y,0.31,0.43)
    for _,side in ipairs({-1,1}) do model_part(p,'petal',side*0.07,0.25,0,0.6,0.8,0.35,0x8cab7cff,lean,side*1.1) end
    layer3_billboard(scene,c.x,c.y+1.2,c.z,open*1.35,open*1.35,c.state=='dazzling' and WHITE or 0xb9dcacff,tex.halo,'add')
  else
    local folded=c.state=='folding' and 0.1 or 0.8+math.sin(t*1.8)*0.12
    local y=0.85+math.sin(t*1.7)*0.1+(c.pulse or 0)*0.10
    for i=0,3 do model_part(p,'sphere',math.sin(t*2-i)*0.065,y-i*0.1,-i*0.19,0.53-i*0.105,0.59-i*0.1,0.52-i*0.055,0xc5e3d8ff) end
    for _,side in ipairs({-1,1}) do
      model_part(p,'fin',side*0.13,y,0,side*folded,1,1,side==1 and 0x97c4ccff or 0xbedbd8ff,0,side*(1-folded)*0.6)
    end
    model_face(p,'veilfin',expression,0,y+0.04,0.26,0.36)
  end
end
function construct_draw()
  local ex,ey,ez=eye_position() local fx,fy,fz=aim_vector()
  local c={x=ex+math.cos(player.yaw)*0.71+fx*1.25,z=ez+math.sin(player.yaw)*0.71+fz*1.25,
    y=ey-0.39+fy*1.25+math.sin(clock_time*2)*0.025,yaw=-player.yaw}
  model_part(c,'sphere',0,0,0,0.19,0.26,0.16,0x8bbcb6ff)
  model_part(c,'ring',0,0,0.02,0.38,0.38,1,0xddc58dff,0,math.sin(clock_time)*0.15)
  for _,side in ipairs({-1,1}) do
    model_part(c,'box',side*0.18,-0.02,-0.02,0.10,0.22,0.035,0xb9bb94ff,0,side*0.18)
    for j=0,2 do model_part(c,'box',side*0.18,0.035-j*0.045,0.005,0.065,0.008,0.01,0x506e70ff) end
  end
  model_part(c,'cone',0,-0.19,0,0.09,-0.11,0.09,0xe6cc91ff)
  local qx,qy,qz,qw=quat_from_euler(c.yaw,0,0)
  local ox,oy,oz=quat_rotate_vec(qx,qy,qz,qw,0,0,0.14)
  -- Camera-facing luminous iris, visibly brighter during an on-demand answer.
  layer3_billboard(scene,c.x+ox,c.y+oy,c.z+oz,0.055,0.055,clock_time<dialogue_until and WHITE or GOLD,tex.white,'add')
end
