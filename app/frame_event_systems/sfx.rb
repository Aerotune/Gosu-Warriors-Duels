FRAME_EVENT_SYSTEMS['sfx'] =
lambda do |game, animation, store, frame_event|
  sfx_id = frame_event["sfx"]
  sfx_id = sfx_id[rand(sfx_id.length)] if sfx_id.kind_of? Array
  
  sfx = game.sfx[sfx_id]
  if sfx
    volume = frame_event["volume"] || 1.0
    volume *= game.volume
    speed = frame_event["speed"] || 1.0
    speed = speed*0.96+rand*speed*0.08
    sfx.play volume, speed
  end
  return :ok
end