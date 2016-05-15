FRAME_EVENT_SYSTEMS['can_consume'] =
lambda do |game, animation, store, frame_event|
  cooldown = store["cooldown"][frame_event["can_consume"]].to_i
  if cooldown > 0
    :skip
  else
    :ok
  end
end