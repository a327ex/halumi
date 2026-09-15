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
require('camera_game')
function update(dt)
  sync_engine_globals()
  if run.pending then return end
  if run.mode~='exploring' then
    if input_pressed('restart') then run_restart() end
    if input_pressed('next_photo') then run.selected=math.min(#run.photos,run.selected+1) end
    if input_pressed('prev_photo') then run.selected=math.max(1,run.selected-1) end
    return
  end
  clock_time=clock_time+dt
  if input_pressed('release') then pointer_locked=not pointer_locked mouse_set_grabbed(pointer_locked) end
  player_update(dt)
  tools_update(dt) creatures_update(dt)
  run_update(dt)
  process_destroy_queue()
end
function draw()
  if run.mode~='exploring' then results_draw() return end
  player_camera() world_lighting() world_draw()
  for _,c in ipairs(creatures) do creature_draw(c) end
  tools_draw()
  if not run.pending then construct_draw() end
  scene_finish()
  if run.pending then photo_capture() end
  camera_hud()
  layer_line(ui,474,270,486,270,1,CREAM) layer_line(ui,480,264,480,276,1,CREAM)
  layer_render(ui) layer_draw(ui)
end
require('boot')
