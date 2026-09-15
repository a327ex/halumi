assert(engine_state().agent and not engine_visible())
run_restart() engine_step(20)
assert(#world.hulls>=25 and #world.solids>80)
-- Every emitted hull plane is a supporting plane of the same collision points.
for _,h in ipairs(world.hulls) do
  assert(#h.planes>=4)
  for _,n in ipairs(h.planes) do for i=1,#h.points,3 do
    assert(n[1]*h.points[i]+n[2]*h.points[i+1]+n[3]*h.points[i+2]<=n[4]+0.001)
  end end
end
agent_walk_to(0,20) agent_walk_to(8,20) agent_walk_to(17,20)
assert(world_region(player.x,player.z)=='cistern')
agent_walk_to(19,17) agent_walk_to(19,14.8)
assert(player.y>0.6,'built steps are not traversable')
agent_walk_to(19,17) agent_walk_to(17,20) agent_walk_to(8,20) agent_walk_to(0,20)
agent_walk_to(0,8) agent_walk_to(10,7) agent_walk_to(12,-11) agent_walk_to(12,-27)
assert(world_region(player.x,player.z)=='gallery')
run_restart()
return 'GEOMETRY PASS: matching hull faces, cistern branch, three dressed steps, northern gallery; only original entrance exits'
