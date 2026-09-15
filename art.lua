function pixel_texture(w,h,paint,wrap)
  local out={}
  for y=0,h-1 do for x=0,w-1 do
    local r,g,b,a=paint(x,y)
    out[#out+1]=string.char(limit(math.floor(r),0,255),limit(math.floor(g),0,255),limit(math.floor(b),0,255),a or 255)
  end end
  return texture_create(w,h,table.concat(out),'rough',wrap or 'repeat')
end
function art_boot()
  tex={}
  tex.stone=pixel_texture(32,32,function(x,y)
    local strata=math.floor(y/6+math.sin(x*0.21)*1.5)%4
    local n=((math.floor(x/3)*13+math.floor(y/3)*7)%7-3)*2
    local moss=(x*3+y*5)%37<7 and 5 or 0
    return 85+n+strata*5,102+n+strata*5+moss,100+n+strata*4
  end)
  tex.rock=tex.stone
  tex.ceiling=pixel_texture(32,32,function(x,y) local n=(x*7+y*11)%9 return 28+n,37+n,39+n end)
  tex.masonry=pixel_texture(64,32,function(x,y)
    local n=((math.floor(x/3)*3+math.floor(y/3)*7)%7-3)*2
    local chip=(x<2 or y<2 or x>61 or y>29) and -22 or 0
    local scratch=y==math.floor(13+math.sin(x*0.15)*2) and x>27 and x<46 and -13 or 0
    return 166+n+chip+scratch,155+n+chip+scratch,128+n+chip+scratch
  end)
  tex.floor=pixel_texture(32,32,function(x,y)
    local joint=x==0 or y==0 local n=((math.floor(x/4)*7+math.floor(y/4)*3)%9-4)*1.5
    if joint then return 112,122,108 end
    if x==math.floor(19+y*0.25) and y>17 then n=n-16 end
    return 160+n,162+n,138+n
  end)
  tex.water=pixel_texture(32,32,function(x,y)
    local n=((x+math.floor(math.sin(y*0.48)*5))%17<2) and 34 or 0
    local wave=math.floor(math.sin(x*0.35+y*0.24)*7)
    return 47+n+wave,113+n+wave,119+n+wave
  end)
  tex.shaft=pixel_texture(32,64,function(x,y)
    local spread=0.35+0.65*y/63
    local edge=math.max(0,1-math.abs(x-15.5)/(15.5*spread))
    return 255,241,180,math.floor(edge*edge*(0.4+0.6*(1-y/64))*66)
  end,'clamp')
  tex.halo=pixel_texture(32,32,function(x,y)
    local d=math.sqrt((x-15.5)^2+(y-15.5)^2)/15.5
    return 224,235,185,math.floor(math.max(0,1-d)^2*95)
  end,'clamp')
  tex.white=texture_create(1,1,string.char(255,255,255,255),'rough')
  meshes={}
  local out={} mesh3_box_geo(out,0,0,0,1,1,1,1)
  meshes.box=mesh3_create(out) mesh3_set_texture(meshes.box,tex.stone)
  out={} mesh3_ground_tile(out,0,0,0,1,1,1)
  meshes.water=mesh3_create(out) mesh3_set_texture(meshes.water,tex.water)
  out={} mesh3_taper(out,0,0,0,0.5,0,1,7,true,1)
  meshes.cone=mesh3_create(out)
  palette_shader=shader_load_string([[
in vec2 TexCoord; out vec4 FragColor; uniform sampler2D u_texture;
void main(){vec4 c=texture(u_texture,TexCoord);float d=mod(floor(TexCoord.x*320.0)+floor(TexCoord.y*180.0),2.0);
c.rgb=floor(c.rgb*31.0+0.35+d*0.3)/31.0;FragColor=c;}
]])
  layer3_set_jitter(scene,320,180) layer3_set_affine(scene,0.65)
  layer3_set_fog(scene,rgba8(75,94,93),28,64)
  layer3_set_sky(scene,rgba8(83,112,117),rgba8(158,174,151),rgba8(29,43,48))
  layer3_set_sun(scene,-0.2,1,-0.1,rgba8(255,241,190),90)
end
function stone_box(x,y,z,w,h,d,col) layer3_mesh(scene,meshes.box,x,y,z,w,h,d,0,0,0,1,col or WHITE) end
