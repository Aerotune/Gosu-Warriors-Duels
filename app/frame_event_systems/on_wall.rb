FRAME_EVENT_SYSTEMS['on_wall'] =
lambda do |game, animation, store, frame_event|
  if frame_event["on_wall"] == game.on_wall?(store)
    return :ok
  else
    return :skip
  end
end