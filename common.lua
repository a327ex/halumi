CREAM=0xe8dfc5ff
GOLD=0xdac181ff
CORAL=0xec967fff
INK=0x10191fff
WHITE=0xffffffff
function rgba8(r,g,b,a) return color(r,g,b,a or 255)() end
function limit(x,a,b) return math.max(a,math.min(b,x)) end
function approach(a,b,k,dt) return a+(b-a)*(1-math.exp(-k*dt)) end
function length2(x,z) return math.sqrt(x*x+z*z) end
function distance2(a,b) return length2(a.x-b.x,a.z-b.z) end
function ease(t) t=limit(t,0,1) return t*t*(3-2*t) end
function pose_curve(t,keys)
  for i=2,#keys do if t<=keys[i][1] then local a,b=keys[i-1],keys[i] return a[2]+(b[2]-a[2])*ease((t-a[1])/(b[1]-a[1])) end end
  return keys[#keys][2]
end
function hud_text(text,x,y,col,font) layer_text(ui,text,fonts[font or 'main'],x,y,col or CREAM) end
function aim_vector()
  local cp=math.cos(player.pitch)
  return math.sin(player.yaw)*cp,math.sin(player.pitch),-math.cos(player.yaw)*cp
end
function eye_position() return player.x,player.y+1.05,player.z end
function scene_finish()
  layer_reset_effects(scene.layer) layer_apply_shader(scene.layer,palette_shader)
  layer3_render(scene) layer_render(scene.layer,false)
  -- Standard composite stretches the fixed-size texture to game resolution
  -- and is recorded; layer_draw_into is an immediate, unrecorded operation.
  layer_draw(scene.layer)
end
