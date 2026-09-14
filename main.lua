require('anchor')({width=960,height=540,scale=1,title='halumi',filter='rough',boot={'boot.lua'}})
require('common')
require('art')
require('world')
require('controller')
require('verification')
function update(dt)
  sync_engine_globals()
  clock_time=clock_time+dt
  if input_pressed('release') then pointer_locked=not pointer_locked mouse_set_grabbed(pointer_locked) end
  player_update(dt)
  process_destroy_queue()
end
function draw()
  player_camera() world_lighting() world_draw()
  layer3_sphere(scene,-3,0.5,1,0.5,rgba8(192,153,109))
  layer3_box(scene,-3,0.95,1,0.7,0.2,0.7,0,0,0,1,rgba8(149,108,82))
  scene_finish()
  hud_text('HALUMI',24,20)
  hud_text('WASD  float     mouse  look     Esc  release cursor',24,508)
  if player.climbing then hud_text('Rising along the stone',24,476,GOLD) end
  if player.sinking>0 then hud_text('DEEP WATER / lift failing. Return to the pale shallows.',120,440,CORAL) end
  layer_line(ui,474,270,486,270,1,CREAM) layer_line(ui,480,264,480,276,1,CREAM)
  layer_render(ui) layer_draw(ui)
end
require('boot')
