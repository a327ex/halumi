assert(engine_state().agent and not engine_visible())
run_restart() engine_step(20)
local folder='replays/shots/m4-final-'..os.date('%Y%m%d-%H%M%S')
local function shot(name) engine_snapshot(folder..'/'..name..'.png') end
agent_look_at(0,1.6,10) shot('entrance')
agent_walk_to(0,17) agent_walk_to(-8,17) agent_walk_to(-14.8,17)
agent_look_at(-21,1.4,15) shot('dark-branch')
run.flash=true agent_tap('space')
local dark_plate=run.photos[1].path
run.flash=false
agent_walk_to(-8,17) agent_walk_to(0,17) agent_walk_to(0,8)
agent_look_at(-2,0.65,-1) shot('sunlit-lake-shore') agent_tap('space')
local jaw=creatures[6]
lamp_on=true
agent_walk_to(-6,7,2400,jaw)
agent_look_at(-8,1,-2) agent_tap('g') engine_step(90)
agent_walk_to(-7.7,2,2400,jaw) agent_walk_to(-12,2,2400,jaw)
lamp_on=false agent_look_at(0,0,-2) shot('sunlit-lake-vantage') agent_tap('space')
lamp_on=true
agent_walk_to(-7.4,2,2400,jaw) agent_walk_to(-6,7,2400,jaw) agent_walk_to(0,8) agent_walk_to(0,22.8)
player.yaw=math.pi agent_tap('w',30)
assert(run.mode=='results')
run.selected=2 engine_step(2) shot('results')
return {snapshots=folder,flash_comparison=dark_plate,album=run.folder,crowns=run.total}
