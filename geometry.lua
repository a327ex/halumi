-- Static geometry and physics share dimensions/vertices. Convex face extraction
-- keeps irregular intrusions honest to the Box3D hull, including sloping faces.
function geo_triangle(out,a,b,c,n)
  local axis=math.abs(n[2])>0.65 and 2 or math.abs(n[1])>math.abs(n[3]) and 1 or 3
  local function uv(p)
    if axis==2 then return p[1]/1.8,p[3]/1.8 elseif axis==1 then return p[3]/1.8,p[2]/1.8 end
    return p[1]/1.8,p[2]/1.8
  end
  local au,av=uv(a) local bu,bv=uv(b) local cu,cv=uv(c)
  mesh3_tri(out,a[1],a[2],a[3],b[1],b[2],b[3],c[1],c[2],c[3],n[1],n[2],n[3],au,av,bu,bv,cu,cv)
end
function geo_box(out,x,y,z,w,h,d)
  local v={}
  mesh3_box_geo(v,x,y,z,w,h,d)
  -- World-space UV density stays constant on floors, lintels and huge walls.
  for i=1,#v,8 do
    if math.abs(v[i+4])>0.65 then v[i+6],v[i+7]=v[i]/1.8,v[i+2]/1.8
    elseif math.abs(v[i+3])>0.65 then v[i+6],v[i+7]=v[i+2]/1.8,v[i+1]/1.8
    else v[i+6],v[i+7]=v[i]/1.8,v[i+1]/1.8 end
  end
  for _,n in ipairs(v) do out[#out+1]=n end
end
function world_box(name,x,y,z,w,h,d,col,material)
  material=material or 'masonry'
  local body=physics3_create_body('static',x,y,z) physics3_add_box(body,'stone',w,h,d)
  world.solids[#world.solids+1]={name=name,x=x,y=y,z=z,w=w,h=h,d=d,body=body}
  geo_box(world.geo[material],x,y,z,w,h,d)
end
function floor_rect(name,x0,x1,z0,z1,y)
  world_box(name,(x0+x1)/2,y-0.5,(z0+z1)/2,x1-x0,1,z1-z0,nil,'floor')
end
function world_hull(name,points,material)
  local body=physics3_create_body('static',0,0,0) physics3_add_hull(body,'stone',points)
  local ps={} local center={0,0,0}
  for i=1,#points,3 do
    ps[#ps+1]={points[i],points[i+1],points[i+2]}
    for j=1,3 do center[j]=center[j]+points[i+j-1] end
  end
  for j=1,3 do center[j]=center[j]/#ps end
  local planes={} local out=world.geo[material or 'rock']
  for i=1,#ps-2 do for j=i+1,#ps-1 do for k=j+1,#ps do
    local a,b,c=ps[i],ps[j],ps[k]
    local nx,ny,nz=vec3_cross(b[1]-a[1],b[2]-a[2],b[3]-a[3],c[1]-a[1],c[2]-a[2],c[3]-a[3])
    local length=math.sqrt(nx*nx+ny*ny+nz*nz)
    if length>0.00001 then
      nx,ny,nz=nx/length,ny/length,nz/length
      local d=nx*a[1]+ny*a[2]+nz*a[3]
      if nx*center[1]+ny*center[2]+nz*center[3]>d then nx,ny,nz,d=-nx,-ny,-nz,-d end
      local valid=true
      for _,p in ipairs(ps) do if nx*p[1]+ny*p[2]+nz*p[3]-d>0.0001 then valid=false break end end
      if valid then
        for _,p in ipairs(planes) do if nx*p[1]+ny*p[2]+nz*p[3]>0.9999 and math.abs(d-p[4])<0.001 then valid=false break end end
      end
      if valid then planes[#planes+1]={nx,ny,nz,d} end
    end
  end end end
  for _,n in ipairs(planes) do
    local face={} local fc={0,0,0}
    for _,p in ipairs(ps) do if math.abs(n[1]*p[1]+n[2]*p[2]+n[3]*p[3]-n[4])<0.0001 then
      face[#face+1]=p for j=1,3 do fc[j]=fc[j]+p[j] end
    end end
    for j=1,3 do fc[j]=fc[j]/#face end
    local ux,uy,uz=vec3_normalize(face[1][1]-fc[1],face[1][2]-fc[2],face[1][3]-fc[3])
    local vx,vy,vz=vec3_cross(n[1],n[2],n[3],ux,uy,uz)
    table.sort(face,function(a,b)
      local function angle(p) local x,y,z=p[1]-fc[1],p[2]-fc[2],p[3]-fc[3] return math.atan(x*vx+y*vy+z*vz,x*ux+y*uy+z*uz) end
      return angle(a)<angle(b)
    end)
    for i=2,#face-1 do geo_triangle(out,face[1],face[i],face[i+1],n) end
  end
  world.hulls[#world.hulls+1]={name=name,points=points,body=body,planes=planes}
end
function rock_intrusion(name,x,y,z,w,h,d,seed,yaw)
  local ps={} local cy,sy=math.cos(yaw or 0),math.sin(yaw or 0)
  local function add(px,py,pz)
    ps[#ps+1]=x+px*cy+pz*sy ps[#ps+1]=y+py ps[#ps+1]=z-px*sy+pz*cy
  end
  for level=0,1 do for i=0,5 do
    local a=i*math.pi/3 local r=1+math.sin(seed+i*1.71)*0.09
    local scale=level==0 and 0.8 or 1
    add(math.cos(a)*w*0.5*r*scale,h*(level==0 and 0 or 0.63),math.sin(a)*d*0.5*r*scale)
  end end
  if h<0 then add(w*0.12*math.sin(seed),h,d*0.12*math.cos(seed))
  else
    for i=0,3 do local a=i*math.pi/2+0.3
      add(math.cos(a)*w*0.24+w*0.08*math.sin(seed),h*(0.9+0.1*math.sin(seed+i)),math.sin(a)*d*0.24)
    end
  end
  world_hull(name,ps,'rock')
end
function dressed_wall(name,x,y,z,w,h,d)
  local body=physics3_create_body('static',x,y,z) physics3_add_box(body,'stone',w,h,d)
  world.solids[#world.solids+1]={name=name,x=x,y=y,z=z,w=w,h=h,d=d,body=body}
  geo_box(world.geo.masonry,x,y,z,math.max(0.1,w-0.1),h,math.max(0.1,d-0.1))
  local horizontal=w>d local span=horizontal and w or d local count=math.max(1,math.floor(span/1.8))
  local courses=math.max(1,math.floor(h/0.75))
  for row=0,courses-1 do for col=0,count-1 do
    local along=-span/2+(col+0.5)*span/count
    local py=y-h/2+(row+0.5)*h/courses
    local pw=span/count-0.045 local ph=h/courses-0.035
    -- Only the exposed course faces are needed. Internal top/bottom faces would
    -- produce bright single-pixel seams under vertex snapping.
    for _,side in ipairs({-1,1}) do
      local a,b,c,e,n
      if horizontal then
        a={x+along-pw/2,py-ph/2,z+side*d/2} b={x+along+pw/2,py-ph/2,z+side*d/2}
        c={x+along+pw/2,py+ph/2,z+side*d/2} e={x+along-pw/2,py+ph/2,z+side*d/2} n={0,0,side}
      else
        a={x+side*w/2,py-ph/2,z+along-pw/2} b={x+side*w/2,py-ph/2,z+along+pw/2}
        c={x+side*w/2,py+ph/2,z+along+pw/2} e={x+side*w/2,py+ph/2,z+along-pw/2} n={side,0,0}
      end
      geo_triangle(world.geo.masonry,a,b,c,n) geo_triangle(world.geo.masonry,a,c,e,n)
    end
  end end
end
function arch_z(name,x,z,width,height,base)
  base=base or 0
  dressed_wall(name..' left',x-width/2-0.35,base+height/2,z,0.7,height,0.85)
  dressed_wall(name..' right',x+width/2+0.35,base+height/2,z,0.7,height,0.85)
  world_box(name..' lintel',x,base+height+0.28,z,width+1.5,0.56,1)
  for _,side in ipairs({-1,1}) do world_box(name..' capital',x+side*(width/2+0.35),base+height-0.12,z,1,0.25,1.1) end
end
function geo_finish()
  world.meshes={}
  for _,material in ipairs({'masonry','rock','floor','trim','ceiling'}) do
    if #world.geo[material]>0 then
      local m=mesh3_create(world.geo[material]) mesh3_set_texture(m,tex[material] or tex.stone)
      world.meshes[#world.meshes+1]={mesh=m,material=material}
    end
  end
end
