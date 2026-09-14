-- Authored geometry. Only surface grain is procedural.
function world_box(name,x,y,z,w,h,d,col)
  local b=physics3_create_body('static',x,y,z) physics3_add_box(b,'stone',w,h,d)
  world.solids[#world.solids+1]={name=name,x=x,y=y,z=z,w=w,h=h,d=d,color=col or WHITE,body=b}
end
function floor_rect(name,x0,x1,z0,z1,y) world_box(name,(x0+x1)/2,y-0.5,(z0+z1)/2,x1-x0,1,z1-z0) end
function world_boot()
  world={solids={},lamps={
    {0,2,23,0xe8bd77ff,7},{-1.8,2,14,0xd4aa70ff,6},
    {-3,5,-1,0xffeed0ff,13},{4,5,-5,0xf1edcaff,13},
    {-10,5,1,0xa8ccc3ff,7},{11,1,-12,0x7fb9bdff,4}}}
  floor_rect('entrance',-2.5,2.5,9,25,0)
  world_box('passage west',-3,2.5,17,1,5,16) world_box('passage east',3,2.5,17,1,5,16)
  world_box('passage roof',0,5.2,17,7,0.8,16) world_box('exit boundary',0,2.5,25.3,6,5,0.6)
  floor_rect('west shore',-14,-5,-16,10,0) floor_rect('east shore',6,14,-16,10,0)
  floor_rect('near shore',-5,6,4,10,0) floor_rect('far shore',-5,6,-16,-7,0)
  floor_rect('shallows west',-5,1,-7,4,-0.35) floor_rect('shallows east',5,6,-7,4,-0.35)
  floor_rect('shallows north',1,5,-7,-5,-0.35) floor_rect('shallows south',1,5,-1,4,-0.35)
  floor_rect('deep basin',1,5,-5,-1,-6)
  world_box('west sheer',-14.5,5,-3,1,12,28) world_box('east sheer',14.5,5,-3,1,12,28)
  world_box('back wall',0,5,-16.5,30,12,1)
  world_box('south west',-8.5,4,10.5,12,8,1) world_box('south east',8.5,4,10.5,12,8,1)
  local b=physics3_create_body('static',0,0,0)
  physics3_add_hull(b,'stone',{-11,0,-6,-8,0,-6,-11,6,-6,-11,0,6,-8,0,6,-11,6,6})
  local out={}
  mesh3_quad(out,-8,0,6,-8,0,-6,-11,6,-6,-11,6,6,0.894427,0.447214,0,0,0,3,6)
  world.ramp=mesh3_create(out) mesh3_set_texture(world.ramp,tex.stone)
  floor_rect('high vantage',-14,-11,-6,6,6)
  world_box('overhang',-12.3,8,5,4,1,2)
  world_box('roof west',-10,11,-2,10,1,28) world_box('roof east',10,11,-2,10,1,28)
  world_box('roof near',0,11,7,10,1,6) world_box('roof far',0,11,-13,10,1,6)
  world_box('alcove screen',8.5,2,-9,5,4,1) world_box('alcove partition',6,2,-13,1,4,6)
  world_box('alcove roof',10,4.2,-13,8,0.5,6) world_box('lake pillar',6.8,4,1.5,2,8,2)
end
function is_deep(x,z) return x>1 and x<5 and z> -5 and z< -1 end
function world_ground(x,z,from_y) return physics3_raycast(x,from_y or 18,z,x,-10,z,{'stone'}) end
function world_lighting()
  layer3_set_light(scene,0,1,0,0.12) layer3_clear_lights(scene.handle)
  local lamps={} for _,v in ipairs(world.lamps) do lamps[#lamps+1]=v end
  if flash_light and flash_light>0 then
    local x,y,z=eye_position() local n=math.floor(255*limit(flash_light/0.18,0,1))
    lamps[#lamps+1]={x,y,z,rgba8(n,n,n),18}
  end
  table.sort(lamps,function(a,b)
    return (a[1]-player.x)^2+(a[2]-player.y)^2+(a[3]-player.z)^2 < (b[1]-player.x)^2+(b[2]-player.y)^2+(b[3]-player.z)^2
  end)
  for i=1,math.min(16,#lamps) do local v=lamps[i] layer3_set_point_light(scene.handle,i,v[1],v[2],v[3],v[4],v[5]) end
end
function world_draw()
  for _,s in ipairs(world.solids) do stone_box(s.x,s.y,s.z,s.w,s.h,s.d,s.color) end
  layer3_mesh(scene,world.ramp,0,0,0,1,1,1,0,0,0,1,rgba8(151,169,157))
  mesh3_set_uv_offset(meshes.water,clock_time*0.013,clock_time*0.007)
  layer3_mesh(scene,meshes.water,0.5,-0.18,-1.5,11,1,11,0,0,0,1,WHITE)
  layer3_plane(scene,3,-0.17,-3,4,4,0,0,0,1,rgba8(12,24,34))
  for i=0,7 do local a=i*math.pi/4 layer3_sphere(scene,3+math.cos(a)*2.4,0.02,-3+math.sin(a)*2.4,0.13,rgba8(111,139,129)) end
  for _,v in ipairs(world.lamps) do layer3_billboard(scene,v[1],v[2],v[3],0.14,0.24,v[4],tex.white,'add') end
  layer3_billboard(scene,-2,5,-1,3,10,WHITE,tex.shaft,'add',0,0,1,1,true)
  layer3_billboard(scene,4,5,-5,2.5,10,WHITE,tex.shaft,'add',0,0,1,1,true)
  layer3_plane(scene,0,0.015,23.4,4.5,1,0,0,0,1,GOLD)
end
