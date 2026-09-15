FILM_COUNT=18
BEHAVIOR_VALUE={sleeping=0.5,resting=0.6,closed=0.6,preening=1,grazing=1,drinking=1.2,pollinating=1.7,
  hunting=2.2,warning=1.8,lunging=2.5,stealing=1.8,feeding=1.4,dazzling=1.7,echoing=2,observing=1.8,
  folding=1.1,startled=0.7,fleeing=0.8,sheltering=0.8,investigating=1.2,listening=1.3,sniffing=1.1,pulsing=1.2}
function camera_boot()
  run_serial=0
  bind('shutter','mouse:1') bind('shutter','key:space') bind('flash','key:f')
  bind('restart','key:r') bind('next_photo','key:right') bind('prev_photo','key:left')
  run_restart()
end
function album_manifest(status)
  if #run.photos==0 then return end
  local f=assert(io.open(run.folder..'/manifest.tsv','w'))
  f:write('status\t'..status..'\nplate\tfile\tflash\tspecies\tindividual\tbehavior\texposure\n')
  for i,p in ipairs(run.photos) do for _,s in ipairs(p.subjects) do
    f:write(string.format('%d\t%s\t%s\t%s\t%d\t%s\t%.3f\n',i,p.path,tostring(p.flash),s.species,s.id,s.behavior,s.exposure))
  end end
  f:close()
end
function run_restart()
  if run then for _,p in ipairs(run.photos) do if p.image then texture_unload(p.image.handle) end end end
  run_serial=run_serial+1
  local folder
  while true do
    folder='albums/'..os.date('%Y%m%d-%H%M%S')..'-'..string.format('%03d',run_serial)
    local f=io.open(folder..'/plate-01.png','rb')
    if not f then break end f:close() run_serial=run_serial+1
  end
  run={mode='exploring',film=FILM_COUNT,hearts=3,photos={},folder=folder,entered=false,flash=false,
    cooldown=0,invulnerable=0,hurt=0,notice='',notice_until=0,selected=1,total=0,best={},pending=nil}
  player_reset() creatures_reset()
  stimuli={} projectiles={} food_left=5 lamp_on=false flash_light=0 pending_attack=false pending_film_loss=0
  player.glare=0 dialogue_until=0 clock_time=0
  pointer_locked=true mouse_set_grabbed(true)
  if voice_handle then sound_handle_stop(voice_handle) voice_handle=nil end
end
function run_notice(text) run.notice=text run.notice_until=clock_time+3 end
function photo_exposure(c,flash)
  if flash then return 1 end
  local light=0.12
  for _,p in ipairs(world.lamps) do
    local dx,dy,dz=p[1]-c.x,p[2]-(c.y+0.5),p[3]-c.z
    local d=math.sqrt(dx*dx+dy*dy+dz*dz) local t=limit(d/p[5],0,1)
    light=light+(1-t*t*(3-2*t))*math.max(0,dy/math.max(0.1,d))*0.65
  end
  if lamp_on and distance2(c,player)<7 and subject_aim_dot(c)>0.6 then light=light+0.4 end
  return limit(light,0.12,1)
end
function photo_request()
  if run.mode~='exploring' or run.pending or run.cooldown>0 then return false end
  if run.film<=0 then run_notice('No unused film. Return to the entrance.') return false end
  local p={subjects={},flash=run.flash,frame=engine_state().frame,time=clock_time}
  for _,c in ipairs(creatures) do
    local v=subject_project(c)
    if v then
      local framing=limit(v.radius/14,0.25,1)
      p.subjects[#p.subjects+1]={id=c.id,species=c.species,behavior=c.state,exposure=photo_exposure(c,run.flash),framing=framing}
    end
  end
  p.path=run.folder..string.format('/plate-%02d.png',#run.photos+1)
  run.film=run.film-1 run.pending=p run.cooldown=0.55
  if run.flash then flash_light=0.18 end
  return true
end
function photo_capture()
  local p=run.pending
  if not p then return end
  -- Called after the scene composite and before any UI/construct. The picture
  -- and subject states precede the behavioral flash reaction, in this frame.
  engine_snapshot(p.path)
  run.photos[#run.photos+1]=p run.pending=nil
  album_manifest('unbanked')
  if p.flash then creatures_flash(eye_position()) end
  run_notice('Light fixed. Bank it at the entrance.')
end
function photo_grade(p)
  local groups={}
  for _,s in ipairs(p.subjects) do
    local g=groups[s.species] or {count=0,peak=0,behaviors={}}
    g.count=g.count+1 g.behaviors[s.behavior]=true
    g.peak=math.max(g.peak,(BEHAVIOR_VALUE[s.behavior] or 1)*s.exposure*(0.5+0.5*s.framing))
    groups[s.species]=g
  end
  p.multiplier=1+0.18*math.max(0,math.min(8,#p.subjects)-1)
  p.scores={} p.total=0
  for species,g in pairs(groups) do
    local def=SPECIES[species]
    local value=math.floor(def.value*def.rarity*g.peak*math.sqrt(g.count)*p.multiplier+0.5)
    p.scores[species]={value=value,count=g.count,behaviors=g.behaviors}
    p.total=p.total+value
  end
  p.grade=p.total>=600 and 'Exceptional' or p.total>=250 and 'Distinguished' or p.total>=90 and 'Useful' or p.total>0 and 'Modest' or 'No specimen'
end
function run_bank()
  if run.mode~='exploring' then return end
  run.mode='results' run.total=0 run.best={}
  pointer_locked=false mouse_set_grabbed(false)
  for i,p in ipairs(run.photos) do
    photo_grade(p)
    for species,s in pairs(p.scores) do
      if not run.best[species] or s.value>run.best[species].value then run.best[species]={value=s.value,plate=i} end
    end
  end
  for _,s in pairs(run.best) do run.total=run.total+s.value end
  album_manifest('banked')
end
function run_die(cause)
  if run.mode~='exploring' then return end
  album_manifest('lost')
  run.lost_count=#run.photos run.photos={} run.total=0 run.best={} run.pending=nil
  run.mode='dead' run.cause=cause
  pointer_locked=false mouse_set_grabbed(false)
end
function run_update(dt)
  run.cooldown=math.max(0,run.cooldown-dt) run.invulnerable=math.max(0,run.invulnerable-dt) run.hurt=math.max(0,run.hurt-dt)
  flash_light=math.max(0,flash_light-dt)
  if pending_attack then
    pending_attack=false
    if run.invulnerable<=0 then
      run.hearts=run.hearts-1 run.invulnerable=1.8 run.hurt=0.5
      run_notice('Slatejaw struck. Keep light on its open jaws, or move away.')
      if run.hearts<=0 then run_die('The Slatejaw reached you.') return end
    end
  end
  if pending_film_loss>0 then
    local lost=math.min(run.film,pending_film_loss) run.film=run.film-lost pending_film_loss=0
    if lost>0 then run_notice('A Spoolmite ate '..lost..' unused leaves.') end
  end
  if player.sinking>1.5 or player.y< -3 then run_die('Your lift failed over deep water.') return end
  if player.z<18 then run.entered=true end
  if run.entered and player.z>23 then run_bank() return end
  if input_pressed('flash') then run.flash=not run.flash end
  if input_pressed('shutter') then photo_request() end
end
function camera_hud()
  if player.glare>0 then layer_rectangle(ui,0,0,960,540,rgba8(222,232,213,math.floor(player.glare*160))) end
  if run.hurt>0 then layer_rectangle_line(ui,5,5,950,530,CORAL,10) end
  for _,c in ipairs(creatures) do
    local p=subject_project(c)
    if p then
      local s=limit(p.radius,9,35)
      layer_line(ui,p.x-s,p.y-s,p.x-s+7,p.y-s,2,CREAM) layer_line(ui,p.x-s,p.y-s,p.x-s,p.y-s+7,2,CREAM)
      layer_line(ui,p.x+s,p.y+s,p.x+s-7,p.y+s,2,CREAM) layer_line(ui,p.x+s,p.y+s,p.x+s,p.y+s-7,2,CREAM)
    end
    if c.species=='slatejaw' and c.state=='warning' and distance2(c,player)<6 then
      hud_text('JAWS OPENING / move away or hold your light on it',160,80,CORAL)
    end
  end
  hud_text('HALUMI',24,20)
  for i=1,3 do
    local col=i<=run.hearts and CORAL or 0x425055ff local x=26+(i-1)*25
    layer_circle(ui,x,62,6,col) layer_circle(ui,x+9,62,6,col)
    layer_triangle(ui,x-6,64,x+15,64,x+4.5,78,col)
  end
  hud_text(string.format('FILM %02d   FLASH %s',run.film,run.flash and 'ON' or 'OFF'),684,22,GOLD)
  hud_text('Q catalogue  E pebble  G food '..food_left..'  L light '..(lamp_on and 'on' or 'off'),24,484,CREAM,'small')
  hud_text('WASD move  mouse look  click / Space fix light  F flash  Esc cursor',24,510,CREAM,'small')
  if player.climbing then hud_text('Rising along the stone',24,453,GOLD,'small') end
  if player.sinking>0 then hud_text('DEEP WATER / LIFT FAILING / return to the pale shallows',150,110,CORAL) end
  if clock_time<run.notice_until then hud_text(run.notice,24,430,GOLD,'small') end
  if run.entered and player.z>19 then hud_text('The entrance / cross the pale threshold to bank your light',145,120,GOLD) end
  dialogue_draw()
end
function results_draw()
  layer_rectangle(ui,0,0,960,540,INK)
  if run.mode=='dead' then
    hud_text('THE LIGHT IS LOST',60,110,CORAL,'title')
    hud_text(run.cause,60,185)
    hud_text(string.format('%d unbanked plates lost. No payment.',run.lost_count or 0),60,232,GOLD)
    hud_text('R / return to the entrance with fresh film',60,355)
  else
    hud_text('SOCIETY / FIXED LIGHT',28,22,CREAM,'title')
    hud_text(string.format('BANKED / %d crowns',run.total),650,37,GOLD)
    hud_text('Only the best plate of each species is paid.',28,77,CREAM,'small')
    local p=run.photos[run.selected]
    if p then
      if not p.image then p.image=image_load('plate_'..run_serial..'_'..run.selected,p.path,'rough') end
      layer_push(ui,280,263,0,0.52,0.52) layer_image(ui,p.image,0,0) layer_pop(ui)
      hud_text(string.format('PLATE %d / %d   %s',run.selected,#run.photos,p.grade),30,423,GOLD)
      hud_text(string.format('%d subjects / group x%.2f / assessed %d crowns',#p.subjects,p.multiplier,p.total),30,456,CREAM,'small')
      local y=121
      for _,id in ipairs({'cupcap','slatejaw','spoolmite','glarebell','veilfin'}) do
        local s=p.scores[id]
        if s then
          hud_text(SPECIES[id].name..' x'..s.count,563,y,GOLD,'small')
          local behaviors={} for b in pairs(s.behaviors) do behaviors[#behaviors+1]=b end table.sort(behaviors)
          hud_text(table.concat(behaviors,', '),563,y+23,CREAM,'small')
          local paid=run.best[id].plate==run.selected
          hud_text(string.format('%d crowns / %s',s.value,paid and 'BEST: PAID' or 'better plate retained'),563,y+46,paid and GOLD or CREAM,'small')
          y=y+78
        end
      end
    else hud_text('No plates brought back.',50,230) end
    hud_text('Left / right: inspect plates     R: enter again',28,505,CREAM,'small')
  end
  layer_render(ui) layer_draw(ui)
end
