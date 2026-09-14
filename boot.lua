-- One-time resources and persistent state. Never reloaded.
scene=layer3_new('cave',320,180,'rough')
screen_layer=layer_new('screen')
ui=layer_new('ui')
font_register('main','assets/monogram.ttf',24,'rough')
font_register('small','assets/monogram.ttf',20,'rough')
font_register('title','assets/monogram.ttf',44,'rough')
clock_time=0
flash_light=0
pointer_locked=true
bind('forward','key:w') bind('back','key:s') bind('left','key:a') bind('right','key:d') bind('release','key:escape')
physics3_init(0,0,0)
physics3_register_tag('stone') physics3_register_tag('player') physics3_register_tag('creature')
physics3_enable_collision('stone','player') physics3_enable_collision('stone','creature')
physics3_enable_collision('creature','player')
art_boot() world_boot() player_boot()
mouse_set_grabbed(true)
