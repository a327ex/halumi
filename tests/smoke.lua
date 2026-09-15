-- Deterministic game-level smoke, using the real controller and tool inputs.
-- anchor drive start halumi
-- anchor drive eval halumi --file halumi/tests/smoke.lua
assert(engine_state().agent and not engine_visible())
run_restart() engine_step(30)
assert(run.film==18 and run.hearts==3 and run.mode=='exploring')
print('SMOKE boot: 18 film, 3 hearts, 13 creatures; hidden instance')
engine_snapshot('replays/shots/m3-entrance.png')
agent_walk_to(0,8) agent_look_at(-2,0.65,-1)
agent_tap('space')
assert(#run.photos==1 and run.film==17 and #run.photos[1].subjects>=2)
local f=assert(io.open(run.photos[1].path,'rb')) assert(f:read(8)=='\137PNG\r\n\26\n') f:close()
assert(run.total==0 and not run.photos[1].grade,'graded before extraction')
print('SMOKE first plate: '..#run.photos[1].subjects..' subjects; PNG saved, no in-run grade')
engine_step(40) agent_tap('f') agent_tap('space')
assert(#run.photos==2 and run.photos[2].flash and run.film==16)
local reacted=false for _,c in ipairs(creatures) do if c.until_time>clock_time then reacted=true end end
assert(reacted,'flash did not affect creatures')
agent_tap('f')
print('SMOKE flash: film consumed, pre-reaction subjects saved, creatures disturbed')
local jaw=creatures[6]
agent_tap('l')
agent_walk_to(-6,7,1800,jaw)
agent_look_at(-8,1,-2) local food_before=food_left agent_tap('g') engine_step(90)
assert(food_left==food_before-1 and #stimuli>0)
agent_walk_to(-7.7,2,1800,jaw)
agent_walk_to(-12,2,1800,jaw)
assert(player.y>6 and run.mode=='exploring')
agent_look_at(0,0,-2)
engine_snapshot(run.folder..'/vantage.png')
engine_step(35) agent_tap('space')
assert(#run.photos==3 and #run.photos[3].subjects>=2)
print('SMOKE vantage: climbed by keyboard; third plate '..#run.photos[3].subjects..' subjects; hearts '..run.hearts)
agent_walk_to(-7.4,2,1800,jaw) agent_walk_to(-6,7,1800,jaw)
agent_walk_to(0,8) agent_walk_to(0,22.8)
player.yaw=math.pi agent_tap('w',30)
assert(run.mode=='results' and run.total>0,'did not bank at the entrance')
local expected,sum=0,0
for _,b in pairs(run.best) do expected=expected+b.value end
for _,p in ipairs(run.photos) do sum=sum+p.total end
assert(expected==run.total and run.total<=sum)
local manifest=assert(io.open(run.folder..'/manifest.tsv','r')) assert(manifest:read('*a'):find('status\tbanked')) manifest:close()
agent_tap('right') assert(run.selected==2 and run.photos[2].image,'results gallery failed')
agent_tap('left') assert(run.selected==1)
engine_step(2) engine_snapshot(run.folder..'/results.png')
print(string.format('SMOKE extraction: %d plates; %d crowns; best per species checked; album %s',#run.photos,run.total,run.folder))
return 'SMOKE PASS: entrance > lake > flash/food > wall climb > vantage photo > same entrance > graded results'
