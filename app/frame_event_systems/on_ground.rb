FRAME_EVENT_SYSTEMS['on_ground'] =
lambda do |game, animation, store, frame_event|
  if frame_event["on_ground"] == game.on_ground?(store)
    return :ok
  else
    return :skip
  end
end