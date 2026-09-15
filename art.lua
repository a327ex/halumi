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
    local n=((math.floor(x/4)*13+math.floor(y/3)*7)%9-4)*3
    if (x+math.floor(y/6)*5)%17==0 then n=n-14 end
    return 103+n,111+n,108+n
  end)
  tex.rock=tex.stone
  tex.ceiling=pixel_texture(32,32,function(x,y) local n=(x*7+y*11)%9 return 28+n,37+n,39+n end)
  tex.masonry=pixel_texture(32,32,function(x,y)
    local n=((x*3+math.floor(y/2)*7)%7-3)*2
    return 155+n,148+n,125+n
  end)
  tex.floor=pixel_texture(32,32,function(x,y)
    local joint=x==0 or y==0 local n=((x*7+y*3)%9-4)*2
    if joint then return 66,76,72 end
    return 141+n,144+n,125+n
  end)
  tex.water=pixel_texture(32,32,function(x,y)
    local n=((x+math.floor(math.sin(y*0.7)*4))%13<2) and 23 or 0
    return 44+n,102+n,111+n
  end)
  tex.shaft=pixel_texture(16,32,function(x,y)
    return 224,216,168,math.floor(math.max(0,1-math.abs(x-7.5)/7.5)*(1-y/40)*13)
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
void main(){vec4 c=texture(u_texture,TexCoord);c.rgb=floor(c.rgb*31.0+0.5)/31.0;FragColor=c;}
]])
  layer3_set_jitter(scene,320,180) layer3_set_affine(scene,0.65)
  layer3_set_fog(scene,rgba8(75,94,93),28,64)
  layer3_set_sky(scene,rgba8(83,112,117),rgba8(158,174,151),rgba8(29,43,48))
  layer3_set_sun(scene,-0.2,1,-0.1,rgba8(255,241,190),90)
end
function stone_box(x,y,z,w,h,d,col) layer3_mesh(scene,meshes.box,x,y,z,w,h,d,0,0,0,1,col or WHITE) end
