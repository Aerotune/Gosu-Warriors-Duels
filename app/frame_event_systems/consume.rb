FRAME_EVENT_SYSTEMS['consume'] =
lambda do |game, animation, store, frame_event|
  cooldown = store["cooldown"][frame_event["consume"]].to_i
  if cooldown <= 0
    store["cooldown"][frame_event["consume"]] = frame_event["cooldown"].to_i
  end
  
  return :ok
end