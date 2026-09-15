SPECIES={
  cupcap={name='Cupcap',height=1.1,radius=0.55,value=28,rarity=1,relation='grazes under Glarebells; Slatejaw prey',color=0xc89772ff},
  slatejaw={name='Slatejaw',height=1.2,radius=0.85,value=95,rarity=1.5,relation='hunts Cupcaps',color=0x777e81ff,attacker=true},
  spoolmite={name='Spoolmite',height=0.65,radius=0.36,value=42,rarity=1.1,relation='follows Cupcap feeding sites; flees Slatejaw',color=0xc68f9eff},
  glarebell={name='Glarebell',height=1.65,radius=0.6,value=58,rarity=1.2,relation='opens for Cupcap pollination; alerts Slatejaw',color=0x8e95b4ff},
  veilfin={name='Undescribed specimen',height=1.1,radius=0.6,value=280,rarity=3,relation='watches Spoolmites and echoes Glarebell pulses',color=0xc8dbcfff,unknown=true},
}
SPAWNS={
  {'cupcap',-3,0,1},{'cupcap',-1,0,0},{'cupcap',-3,0,-3},{'cupcap',0,0,-6},{'cupcap',-17,0,14},
  {'slatejaw',-9.6,3.2,1},
  {'spoolmite',18,0,20},{'spoolmite',-18,0,16},{'spoolmite',10,0,-29},
  {'glarebell',-6.8,0,1},{'glarebell',-18,0,13},{'glarebell',11,0,-30},
  {'veilfin',8.9,0,-30.5},
}
function creature_state(c,state,duration)
  if c.state~=state then c.state=state c.since=clock_time end
  c.until_time=clock_time+(duration or 0)
end
function creatures_boot()
  creatures={}
  for i,s in ipairs(SPAWNS) do
    local c={id=i,species=s[1],x=s[2],y=s[3],z=s[4],home={x=s[2],y=s[3],z=s[4]},yaw=i,phase=i*0.7,speed=0,since=0,until_time=0,state='resting',cooldown=0}
    c.body=physics3_create_body('kinematic',c.x,c.y+0.5,c.z)
    physics3_add_sphere(c.body,'creature',SPECIES[c.species].radius,{sensor=true})
    physics3_set_user_data(c.body,i)
    creatures[i]=c
  end
end
function creatures_reset()
  for _,c in ipairs(creatures) do
    c.x,c.y,c.z=c.home.x,c.home.y,c.home.z c.until_time=0 c.state='resting' c.cooldown=0 c.target=nil
    physics3_set_position(c.body,c.x,c.y+0.5,c.z)
  end
end
function creature_los(c,x,y,z)
  return not physics3_raycast(c.x,c.y+0.6,c.z,x,y,z,{'stone'})
end
function creature_move(c,x,z,speed,dt)
  local dx,dz=x-c.x,z-c.z local d=length2(dx,dz)
  c.speed=0 if d<0.1 then return end
  local step=math.min(d,speed*dt) dx,dz=dx/d*step,dz/d*step
  local hit=physics3_raycast(c.x,c.y+0.4,c.z,c.x+dx*5,c.y+0.4,c.z+dz*5,{'stone'})
  if hit and hit.normal_y<0.12 then return end
  if is_deep(c.x+dx,c.z+dz) then return end
  local ground=world_ground(c.x+dx,c.z+dz,c.y+1.2)
  if not ground or ground.point_y>c.y+0.65 then return end
  c.x,c.z=c.x+dx,c.z+dz c.y=math.max(ground.point_y, -0.1)
  c.yaw=math.atan(dx,dz) c.speed=step/dt c.phase=c.phase+c.speed*dt*2
end
function nearest_creature(c,species,range)
  local best,d=nil,range
  for _,other in ipairs(creatures) do
    local n=distance2(c,other)
    if other.species==species and n<d then best,d=other,n end
  end
  return best
end
function creatures_flash(x,y,z)
  for _,c in ipairs(creatures) do
    if (c.x-x)^2+(c.y-y)^2+(c.z-z)^2<144 and creature_los(c,x,y,z) then
      if c.species=='slatejaw' or c.species=='cupcap' then
        local dx,dz=c.x-x,c.z-z local d=math.max(0.2,length2(dx,dz))
        c.target={x=c.x+dx/d*3,z=c.z+dz/d*3} creature_state(c,'startled',3.2)
      elseif c.species=='spoolmite' then c.target={x=x,z=z} creature_state(c,'seeking light',5)
      elseif c.species=='glarebell' then creature_state(c,'dazzling',6) stimuli[#stimuli+1]={kind='noise',x=c.x,z=c.z,life=4}
      else c.target={x=c.home.x,z=c.home.z-0.7} creature_state(c,'folding',6) end
    end
  end
end
function creatures_update(dt)
  player.glare=math.max(0,(player.glare or 0)-dt*0.7)
  for _,c in ipairs(creatures) do
    c.cooldown=math.max(0,c.cooldown-dt) c.speed=0
    local dist=math.sqrt((c.x-player.x)^2+(c.z-player.z)^2+(c.y-player.y)^2)
    local see=dist<9 and creature_los(c,eye_position())
    if c.until_time<=clock_time then c.target=nil end
    local illuminated=lamp_on and dist<7 and see and subject_aim_dot(c)>0.6
    if illuminated and c.species=='slatejaw' then
      c.target={x=c.home.x-0.6,z=c.home.z-3} creature_state(c,'sheltering',1.8)
    elseif illuminated and c.species=='glarebell' then creature_state(c,'closed',1.2) end
    local stimulus=nil
    for _,s in ipairs(stimuli) do if s.source~=c.id and distance2(c,s)<(s.kind=='food' and 6 or 10) then stimulus=s end end
    if c.until_time>clock_time then
      if c.target then creature_move(c,c.target.x,c.target.z,c.state=='startled' and 2.5 or 1.25,dt) end
    elseif stimulus then
      c.target=nil
      if c.species=='veilfin' then
        creature_state(c,stimulus.kind=='food' and 'observing' or 'listening')
      elseif c.species=='glarebell' then creature_state(c,stimulus.kind=='food' and 'pollinating' or 'closed')
      else
        local near=distance2(c,stimulus)<0.85
        creature_state(c,near and (stimulus.kind=='food' and 'feeding' or 'listening') or 'investigating')
        if not near then creature_move(c,stimulus.x,stimulus.z,1.5,dt) end
      end
    elseif c.species=='slatejaw' then
      if see and dist<5.5 then
        if c.state=='warning' and clock_time-c.since>=1.05 then
          creature_state(c,'lunging',0.35)
          if dist<2.35 and c.cooldown<=0 then
            pending_attack=true c.cooldown=2.3
          end
        elseif dist<2.1 then
          if c.cooldown<=0 then creature_state(c,'warning') else creature_state(c,'watching') end
        else creature_state(c,'hunting') creature_move(c,player.x,player.z,2.15,dt) end
      else
        local prey=nearest_creature(c,'cupcap',5)
        if prey then creature_state(c,'hunting') creature_move(c,prey.x,prey.z,0.75,dt)
        elseif distance2(c,c.home)>0.7 then creature_state(c,'returning') creature_move(c,c.home.x,c.home.z,0.75,dt)
        else creature_state(c,clock_time%16<10 and 'sleeping' or 'watching') end
      end
    elseif c.species=='cupcap' then
      local predator=nearest_creature(c,'slatejaw',3)
      if predator or dist<1.4 then
        local threat=predator or player local dx,dz=c.x-threat.x,c.z-threat.z
        creature_state(c,'fleeing') creature_move(c,c.x+dx,c.z+dz,1.6,dt)
      else
        local bell=nearest_creature(c,'glarebell',4)
        local t=(clock_time+c.id*2)%18
        if t<5 then creature_state(c,'sleeping')
        elseif t<10 and bell then creature_state(c,'pollinating') creature_move(c,bell.x+0.9,bell.z,0.45,dt)
        elseif t<14 then creature_state(c,'drinking')
        else creature_state(c,'grazing') creature_move(c,c.home.x+math.sin(clock_time*0.3+c.id),c.home.z+math.cos(clock_time*0.2+c.id),0.5,dt) end
      end
    elseif c.species=='spoolmite' then
      local predator=nearest_creature(c,'slatejaw',3)
      if predator then creature_state(c,'hiding') creature_move(c,c.home.x,c.home.z,1.3,dt)
      elseif see and dist<3.5 then
        creature_state(c,'sniffing') creature_move(c,player.x,player.z,1.1,dt)
        if dist<1.1 and c.cooldown<=0 then pending_film_loss=pending_film_loss+2 c.cooldown=7 creature_state(c,'stealing',1.4) end
      else
        local grazer=nearest_creature(c,'cupcap',3)
        creature_state(c,grazer and 'foraging' or 'preening')
        if grazer then creature_move(c,grazer.x,grazer.z,0.45,dt) end
      end
    elseif c.species=='glarebell' then
      local grazer=nearest_creature(c,'cupcap',2.1)
      if see and dist<3.8 then creature_state(c,'dazzling')
      else creature_state(c,grazer and 'pollinating' or ((clock_time+c.id)%10<6 and 'pulsing' or 'closed')) end
    else
      creature_state(c,dist<2 and 'folding' or 'echoing')
      c.x=c.home.x+math.sin(clock_time*0.35)*0.5 c.z=c.home.z+math.cos(clock_time*0.35)*0.45
    end
    if c.species=='veilfin' then
      local mite=nearest_creature(c,'spoolmite',6)
      if mite then c.yaw=math.atan(mite.x-c.x,mite.z-c.z) end
      local bell=nearest_creature(c,'glarebell',6)
      c.pulse=bell and (bell.state=='pulsing' or bell.state=='dazzling') and 1 or 0
    end
    if c.species=='glarebell' and c.state=='dazzling' and see and dist<7 and subject_aim_dot(c)>0.78 then
      player.glare=math.max(player.glare,0.75)
      if c.cooldown<=0 then stimuli[#stimuli+1]={kind='noise',x=c.x,z=c.z,life=3,source=c.id} c.cooldown=5 end
    end
    physics3_set_position(c.body,c.x,c.y+SPECIES[c.species].height*0.5,c.z)
  end
end
