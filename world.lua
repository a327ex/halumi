-- A built sanctuary reclaimed by cave rock. Layout is authored in metres.
function world_boot()
  world={solids={},hulls={},geo={masonry={},rock={},floor={},trim={}},lamps={
    {0,2.4,23,0xe8bd77ff,6,'sconce'}, {-1.9,2.7,13,0xd4aa70ff,5,'sconce'},
    {-2,7,-2,0xffefd4ff,15,'sun'}, {4,7,-6,0xfff4d8ff,13,'sun'},
    {0,2.8,6,0xcbbfa3ff,12,'bounce'}, {-7,3,-1,0x8bada8ff,10,'bounce'},
    {1,3,-10,0x8daba3ff,11,'bounce'}, {8,4,0,0x9db1a3ff,10,'bounce'},
    {-11.5,7.5,2,0xc7d4b3ff,6,'bounce'},
    {-6,2.6,17,0xa88055ff,4,'sconce'}, {-19,2.6,20.7,0xb58b57ff,5,'sconce'},
    {8,2.6,20,0x8d8b72ff,4,'sconce'}, {21,2.3,23,0x8fb3b8ff,5,'sconce'},
    {12.9,2.5,-19,0x7b9ba3ff,4.5,'sconce'}, {5.5,2.8,-31,0x82988aff,5,'sconce'}}}
  -- Entry spine: repeated door frames, broken masonry, lateral openings.
  floor_rect('entry paving',-2.5,2.5,9,25,0)
  dressed_wall('entry west near',-3,2.5,22,1,5,6)
  dressed_wall('entry west far',-3,2.5,12,1,5,6)
  dressed_wall('entry east near',3,2.5,23.5,1,5,3)
  dressed_wall('entry east far',3,2.5,13.5,1,5,9)
  world_box('entry west doorway header',-3,4.15,17,1.2,1.7,4)
  world_box('entry east doorway header',3,4.15,20,1.2,1.7,4)
  world_box('entry roof',0,5.4,17,7,0.8,16)
  world_box('exit boundary',0,2.5,25.3,6,5,0.6)
  arch_z('entry threshold',0,24.3,4.2,3.5)
  arch_z('lake portal',0,9.4,4.5,4.1)
  rock_intrusion('entry intrusion',-2.7,0,12.9,2,4.6,3,1)
  rock_intrusion('entry ceiling root',2.3,5.1,21.2,1.7,-1.8,2.2,3)
  -- Three dark branches, each reached through a built doorway.
  floor_rect('archive corridor',-13,-2.5,15,19,0)
  dressed_wall('archive passage north',-8,2,14.7,10,4,0.6)
  dressed_wall('archive passage south',-8,2,19.3,10,4,0.6)
  world_box('archive passage roof',-8,4.3,17,10,0.6,5)
  floor_rect('archive chamber',-24,-13,11,23,0)
  dressed_wall('archive back',-24.3,2.6,17,0.6,5.2,13)
  dressed_wall('archive north',-18.5,2.6,10.7,12,5.2,0.6)
  dressed_wall('archive south',-18.5,2.6,23.3,12,5.2,0.6)
  dressed_wall('archive east north',-12.7,2.6,12.8,0.6,5.2,4.4)
  dressed_wall('archive east south',-12.7,2.6,21.2,0.6,5.2,4.4)
  world_box('archive doorway header',-12.7,4.6,17,1,1.2,4)
  world_box('archive ceiling',-18.5,5.5,17,12,0.6,13)
  for i=1,3 do floor_rect('archive steps',-22.8,-20,11.5+(i-1)*0.55,13.7,0.14*i) end
  rock_intrusion('archive collapsed corner',-23,0,11.9,5.3,4.9,5.1,5)
  rock_intrusion('archive wall breach',-23.7,0,20.3,4.5,4,5,7)
  rock_intrusion('archive ceiling tongue',-17,5.3,12.2,3,-2.8,3.2,12)
  rock_intrusion('archive fallen stone',-20,0,20.8,2.4,0.75,1.7,8,0.4)
  floor_rect('cistern corridor',2.5,13.5,18,22,0)
  dressed_wall('cistern passage north',8,2.1,17.7,10.5,4.2,0.6)
  dressed_wall('cistern passage south',8,2.1,22.3,10.5,4.2,0.6)
  world_box('cistern passage roof',8,4.5,20,11,0.6,5)
  floor_rect('cistern chamber',13.5,24,14,26,0)
  dressed_wall('cistern east',24.3,2.7,20,0.6,5.4,13)
  dressed_wall('cistern north',18.8,2.7,13.7,11.5,5.4,0.6)
  dressed_wall('cistern south',18.8,2.7,26.3,11.5,5.4,0.6)
  dressed_wall('cistern west north',13.2,2.7,15.7,0.6,5.4,4)
  dressed_wall('cistern west south',13.2,2.7,24.3,0.6,5.4,4)
  world_box('cistern doorway header',13.2,4.6,20,1,1.6,4)
  world_box('cistern roof',18.8,5.7,20,11.8,0.6,13)
  arch_z('cistern inner frame',19,16,5,3.8)
  for i=1,3 do floor_rect('cistern dais steps',17,21,14+(i-1)*0.55,15.8,0.13*i) end
  rock_intrusion('cistern small intrusion',23.8,0,15.3,3,4,3.6,9)
  rock_intrusion('cistern root',23.6,5.4,23,2,-2.7,2,14)
  -- The lake retains the original walking and wall-climbing relationships.
  floor_rect('west shore',-14,-5,-16,10,0) floor_rect('east shore',6,14,-16,10,0)
  floor_rect('near shore',-5,6,4,10,0) floor_rect('far shore',-5,6,-16,-7,0)
  floor_rect('shallows west',-5,1,-7,4,-0.35) floor_rect('shallows east',5,6,-7,4,-0.35)
  floor_rect('shallows north',1,5,-7,-5,-0.35) floor_rect('shallows south',1,5,-1,4,-0.35)
  floor_rect('deep basin',1,5,-5,-1,-6)
  -- Paving meets the water at low, submerged dressed steps.
  floor_rect('lake south lip',-5,6,3.55,4,-0.11)
  floor_rect('lake west lip',-5,-4.6,-7,3.55,-0.11)
  dressed_wall('west sheer',-14.5,4.5,-3,1,11,28)
  dressed_wall('east sheer',14.5,4.5,-3,1,11,28)
  dressed_wall('north lake west',-2.25,4.5,-16.5,24.5,11,1)
  dressed_wall('north lake east',14.25,4.5,-16.5,1.5,11,1)
  world_box('north gallery header',12,6.5,-16.5,4,5,1)
  dressed_wall('south west',-8.5,4,10.5,12,8,1) dressed_wall('south east',8.5,4,10.5,12,8,1)
  -- Irregular, connected slope sections. Each visible triangle is a hull face.
  local zs={-6,-3,-0.5,1,3,6} local xs={-7.5,-8.2,-7.85,-8,-8,-7.3}
  for i=1,#zs-1 do world_hull('west ascent '..i,{
    -11,0,zs[i],xs[i],0,zs[i],-11,6,zs[i],
    -11,0,zs[i+1],xs[i+1],0,zs[i+1],-11,6,zs[i+1]}) end
  floor_rect('high vantage',-14,-11,-6,6,6)
  world_box('overhang',-12.3,8,5,4,1,2,nil,'rock')
  for _,p in ipairs({{-13.7,0,-11,4,8,5,21},{13.8,0,-5,3.8,9,5,22},
    {14,0,7,4.2,7,5,23},{-8,0,-15.6,5,8,4,24},{2,0,-16.1,4,6,3,25},
    {-13.7,6,-4.8,2.2,3.5,2.1,27}}) do rock_intrusion('lake rock',table.unpack(p)) end
  -- Ceiling fragments frame two genuinely open roof voids. No central lid.
  world_box('roof west',-11,10.5,-2,6,1,28,nil,'rock')
  world_box('roof east',11,10.5,-2,6,1,28,nil,'rock')
  world_box('roof near',0,10.5,8,16,1,4,nil,'rock')
  world_box('roof far',0,10.5,-14,16,1,4,nil,'rock')
  world_box('surviving transverse beam',0,9.8,-3.7,16,0.6,0.6)
  for _,p in ipairs({{-7.5,10,-6,3,-3.2,3,30},{7.5,10,2,3,-4,3,31},
    {-5.5,10,7,2,-2.5,2,32},{4,10,-12,2.5,-3.4,3,33},{-8,10,-11,2,-2.8,2,34}}) do rock_intrusion('stalactite',table.unpack(p)) end
  -- Half-buried colonnade, framing the bank rather than blocking the lake.
  for _,z in ipairs({-11,-3,5}) do
    arch_z('east colonnade',11,z,3.3,5.4)
  end
  -- Original alcove becomes the lower chamber of the northern branch.
  dressed_wall('alcove screen',8.5,2,-9,5,4,1)
  dressed_wall('alcove partition',6,2,-13,1,4,6)
  world_box('alcove roof',10,4.2,-13,8,0.5,6)
  rock_intrusion('broken lake pier',6.8,0,1.5,2.1,7.5,2.3,39)
  floor_rect('north gallery',10,14,-25,-16,0)
  dressed_wall('gallery west',9.7,2.3,-20.5,0.6,4.6,9)
  dressed_wall('gallery east',14.3,2.3,-20.5,0.6,4.6,9)
  world_box('gallery roof',12,4.9,-20.5,5.2,0.6,9)
  arch_z('gallery door',12,-23.6,3,3.5)
  floor_rect('north chamber',4,14,-34,-25,0)
  dressed_wall('north chamber west',3.7,2.7,-29.5,0.6,5.4,10)
  dressed_wall('north chamber east',14.3,2.7,-29.5,0.6,5.4,10)
  dressed_wall('north chamber back',9,2.7,-34.3,11,5.4,0.6)
  dressed_wall('north chamber screen',7,2.7,-24.7,6.6,5.4,0.6)
  world_box('north chamber roof',9,5.7,-29.5,11,0.6,10)
  rock_intrusion('north chamber intrusion',4.1,0,-32.2,3.5,4.5,4.3,45)
  rock_intrusion('gallery root',10.2,4.6,-20.8,1.5,-2.1,2.4,46)
  -- Deliberate small rubble clusters stay out of the verified walking lanes.
  for _,p in ipairs({{-4.8,0,8,1.4,0.55,1,50},{4.7,0,8.9,1.5,0.65,1.8,51},
    {-10,0,-10,1.9,0.9,1.6,52},{8.7,0,-6,1.3,0.6,1.8,53},
    {-20.7,0,12.7,1.1,0.6,1.2,54},{-21.8,0,20,1.5,0.5,1.2,55},
    {21.7,0,15.5,1.2,0.55,1.8,56},{5.2,0,-26,1.4,0.6,1.2,57}}) do rock_intrusion('rubble',table.unpack(p)) end
  geo_finish()
end
function is_deep(x,z) return x>1 and x<5 and z> -5 and z< -1 end
function world_ground(x,z,from_y) return physics3_raycast(x,from_y or 18,z,x,-10,z,{'stone'}) end
function world_region(x,z)
  if x< -12 and z>10 then return 'archive' end
  if x>13 and z>13 then return 'cistern' end
  if z< -17 then return 'gallery' end
  if z>10 then return 'entry' end
  return 'lake'
end
function world_light_list()
  local lamps={} for _,v in ipairs(world.lamps) do lamps[#lamps+1]=v end
  local x,y,z=eye_position() local dx,dy,dz=aim_vector()
  -- The forehead gem gives nearby edges a little reflected light, not a room fill.
  lamps[#lamps+1]={x,y,z,0x899eaaff,4.5,'read'}
  if lamp_on then lamps[#lamps+1]={x+dx*1.2,y+dy*1.2,z+dz*1.2,0xffe4aeff,8,'lamp'} end
  if flash_light>0 then local n=math.floor(255*limit(flash_light/0.18,0,1))
    lamps[#lamps+1]={x,y,z,rgba8(n,n,n),18,'flash'}
  end
  return lamps
end
function world_lighting()
  layer3_set_light(scene,0,1,0,0.075) layer3_clear_lights(scene.handle)
  local lamps=world_light_list()
  table.sort(lamps,function(a,b)
    return (a[1]-player.x)^2+(a[2]-player.y)^2+(a[3]-player.z)^2 < (b[1]-player.x)^2+(b[2]-player.y)^2+(b[3]-player.z)^2
  end)
  for i=1,math.min(16,#lamps) do local v=lamps[i] layer3_set_point_light(scene.handle,i,v[1],v[2],v[3],v[4],v[5]) end
end
function world_exposure(c)
  local light=0.075
  for _,p in ipairs(world_light_list()) do
    local d=math.sqrt((p[1]-c.x)^2+(p[2]-c.y-0.5)^2+(p[3]-c.z)^2)
    local t=limit(d/p[5],0,1)
    local energy=(((p[4]>>24)&255)*0.3+((p[4]>>16)&255)*0.6+((p[4]>>8)&255)*0.1)/255
    light=light+(1-t*t*(3-2*t))*energy*0.65
  end
  return limit(light,0.075,1)
end
function world_draw()
  for _,m in ipairs(world.meshes) do layer3_mesh(scene,m.mesh,0,0,0,1,1,1,0,0,0,1,WHITE) end
  mesh3_set_uv_offset(meshes.water,clock_time*0.013,clock_time*0.007)
  layer3_mesh(scene,meshes.water,0.5,-0.18,-1.5,11,1,11,0,0,0,1,WHITE)
  layer3_plane(scene,3,-0.17,-3,4,4,0,0,0,1,rgba8(12,24,34))
  for i=0,7 do local a=i*math.pi/4 layer3_sphere(scene,3+math.cos(a)*2.4,0.02,-3+math.sin(a)*2.4,0.13,rgba8(157,175,143)) end
  for _,v in ipairs(world.lamps) do if v[6]=='sconce' then
    layer3_billboard(scene,v[1],v[2],v[3],0.13,0.26,v[4],tex.white,'add')
  end end
  layer3_billboard(scene,-2,5,-1,3,10,WHITE,tex.shaft,'add',0,0,1,1,true)
  layer3_billboard(scene,4,5,-6,2.8,10,WHITE,tex.shaft,'add',0,0,1,1,true)
  layer3_plane(scene,0,0.015,23.4,4.5,1,0,0,0,1,GOLD)
end
