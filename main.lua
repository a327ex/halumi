require('anchor')({width=960,height=540,scale=1,title='halumi',filter='rough',boot={'boot.lua'}})
require('common')
require('art')
require('world')
require('controller')
require('verification')
require('creatures')
require('subjects')
require('models')
require('tools_game')
function update(dt)
  sync_engine_globals()
  clock_time=clock_time+dt
  if input_pressed('release') then pointer_locked=not pointer_locked mouse_set_grabbed(pointer_locked) end
  player_update(dt)
  tools_update(dt) creatures_update(dt)
  process_destroy_queue()
end
function draw()
  player_camera() world_lighting() world_draw()
  for _,c in ipairs(creatures) do creature_draw(c) end
  tools_draw() construct_draw()
  scene_finish()
  hud_text('HALUMI',24,20)
  if player.glare>0 then layer_rectangle(ui,0,0,960,540,rgba8(222,232,213,math.floor(player.glare*160))) end
  hud_text('WASD move   Q consult   E pebble   G food   L light   Esc cursor',24,508,CREAM,'small')
  hud_text('Food '..food_left..' / light '..(lamp_on and 'on' or 'off'),24,474,GOLD,'small')
  dialogue_draw()
  if player.climbing then hud_text('Rising along the stone',24,476,GOLD) end
  if player.sinking>0 then hud_text('DEEP WATER / lift failing. Return to the pale shallows.',120,440,CORAL) end
  layer_line(ui,474,270,486,270,1,CREAM) layer_line(ui,480,264,480,276,1,CREAM)
  layer_render(ui) layer_draw(ui)
end
require('boot')
