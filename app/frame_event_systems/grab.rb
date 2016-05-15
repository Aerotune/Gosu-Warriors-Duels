FRAME_EVENT_SYSTEMS['grab'] =
lambda do |game, animation, store, frame_event|
  x, y = *Animation.anchor_point(store)
  p [x, y]
  :ok
end