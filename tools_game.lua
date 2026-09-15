VOICE_LINES={
  cupcap='Cupcap. A solemn little grazer. It carries Glarebell pollen on its cap. The sleeping ones have not noticed the Slatejaw.',
  slatejaw='Slatejaw. It opens its jaws before it lunges. Keep a steady light on it, or give it something else to investigate. Three mistakes would be quite enough.',
  spoolmite='Spoolmite. It follows Cupcaps and eats the coating off fixed-light leaves. Your unused film also qualifies. A little food may improve its manners.',
  glarebell='Glarebell. Cupcaps spread its pollen. Its glare draws the Slatejaw. Look away, and let the light close it. Flashing it is an invitation.',
  veilfin='I... do not have an entry for this one.',
}
function tools_boot()
  stimuli={} projectiles={} food_left=5 lamp_on=false dialogue='' dialogue_until=0
  pending_attack=false pending_film_loss=0 player.glare=0 tool_cooldown=0 voices={}
  bind('consult','key:q') bind('pebble','key:e') bind('food','key:g') bind('lamp','key:l')
  for id in pairs(VOICE_LINES) do
    local path='assets/voice/'..id..'.ogg' local f=io.open(path,'rb')
    if f then f:close() voices[id]=sound_load(path) end
  end
end
function throw_lure(kind)
  if tool_cooldown>0 then return false end
  if kind=='food' and food_left<=0 then return false end
  if kind=='food' then food_left=food_left-1 end
  local x,y,z=eye_position() local dx,dy,dz=aim_vector()
  projectiles[#projectiles+1]={kind=kind,x=x,y=y-0.2,z=z,vx=dx*8,vy=dy*8+2,vz=dz*8,life=0}
  tool_cooldown=0.5 return true
end
function tools_update(dt)
  tool_cooldown=math.max(0,tool_cooldown-dt)
  if input_pressed('lamp') then lamp_on=not lamp_on end
  if input_pressed('pebble') then throw_lure('noise') end
  if input_pressed('food') then throw_lure('food') end
  if input_pressed('consult') then
    local c=aimed_subject()
    if c then
      sound_emit('construct_chime',0.22,1)
      dialogue=VOICE_LINES[c.species] dialogue_until=clock_time+11
      if voice_handle then sound_handle_stop(voice_handle) end
      if voices[c.species] then voice_handle=sound_play_handle(voices[c.species],0.8,1) end
    end
  end
  for i=#projectiles,1,-1 do
    local p=projectiles[i] p.life=p.life+dt p.vy=p.vy-7*dt
    local x,y,z=p.x+p.vx*dt,p.y+p.vy*dt,p.z+p.vz*dt
    local hit=physics3_raycast(p.x,p.y,p.z,x,y,z,{'stone'})
    if hit or p.life>2 then
      sound_emit(p.kind=='food' and 'food_impact' or 'pebble_impact',0.3,1)
      stimuli[#stimuli+1]={kind=p.kind,x=hit and hit.point_x or x,z=hit and hit.point_z or z,life=p.kind=='food' and 12 or 6}
      table.remove(projectiles,i)
    else p.x,p.y,p.z=x,y,z end
  end
  for i=#stimuli,1,-1 do local s=stimuli[i] s.life=s.life-dt if s.life<=0 then table.remove(stimuli,i) end end
end
function tools_draw()
  for _,p in ipairs(projectiles) do layer3_sphere(scene,p.x,p.y,p.z,0.07,p.kind=='food' and GOLD or CREAM) end
  for _,s in ipairs(stimuli) do
    local hit=world_ground(s.x,s.z,3)
    if hit then layer3_sphere(scene,s.x,hit.point_y+0.06,s.z,0.10,s.kind=='food' and GOLD or CREAM) end
  end
end
function dialogue_draw()
  if clock_time<dialogue_until then
    layer_rectangle(ui,110,370,740,102,rgba8(13,22,27,230))
    local words={} local line='' local y=382
    for word in dialogue:gmatch('%S+') do
      if #line+#word>67 then words[#words+1]=line line='' end
      line=line..word..' '
    end
    words[#words+1]=line
    for _,s in ipairs(words) do hud_text(s,128,y,CREAM,'small') y=y+23 end
  end
end
