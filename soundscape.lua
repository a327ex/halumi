-- Stable IDs, one owner-replaceable path per cue. All WAVs below are placeholders.
SOUND_DEFS={
  shutter={duration=0.16}, hover_hum={duration=2}, cupcap_call={duration=0.62},
  slatejaw_call={duration=0.95}, spoolmite_call={duration=0.48}, glarebell_call={duration=1},
  veilfin_call={duration=1.1}, construct_chime={duration=0.5}, pebble_impact={duration=0.18},food_impact={duration=0.16},
}
function soundscape_boot()
  soundscape={assets={},active={},count={},hover=nil,t=0}
  for id,def in pairs(SOUND_DEFS) do
    soundscape.assets[id]=sound_load(def.path or ('assets/sound/placeholders/'..id..'.wav'))
  end
end
function sound_emit(id,volume,pitch)
  local asset=soundscape.assets[id] if not asset then return nil end
  local handle=sound_play_handle(asset,volume or 0.3,pitch or 1)
  if handle>=0 then
    soundscape.active[#soundscape.active+1]={handle=handle,left=SOUND_DEFS[id].duration/(pitch or 1)+0.08}
    soundscape.count[id]=(soundscape.count[id] or 0)+1
  end
  return handle
end
function soundscape_update(dt)
  soundscape.t=soundscape.t+dt
  for i=#soundscape.active,1,-1 do
    local s=soundscape.active[i] s.left=s.left-dt
    if s.left<=0 then sound_handle_stop(s.handle) table.remove(soundscape.active,i) end
  end
  if not soundscape.hover then
    local h=sound_play_handle(soundscape.assets.hover_hum,0.06,1)
    if h>=0 then soundscape.hover=h sound_handle_set_looping(h,true) end
  end
  if soundscape.hover then
    sound_handle_set_volume(soundscape.hover,run.mode=='exploring' and 0.06 or 0)
    sound_handle_set_pitch(soundscape.hover,1+math.min(0.1,length2(player.vx,player.vz)*0.03))
  end
end
function sound_creature(c)
  local id=c.species..'_call'
  local d=distance2(player,c)
  local warning=c.species=='slatejaw' and c.state=='warning' and c.last_call_state~='warning'
  local natural=clock_time>(c.next_call or c.id+3) and c.state~='sleeping' and c.state~='closed'
  if (warning or natural) and d<15 and creature_los(c,eye_position()) then
    sound_emit(id,(warning and 0.7 or 0.24)*math.max(0.1,1-d/18),1)
    c.next_call=clock_time+10+c.id%4
  end
  c.last_call_state=c.state
end
