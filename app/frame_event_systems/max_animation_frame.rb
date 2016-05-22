FRAME_EVENT_SYSTEMS['max_animation_frame'] =
lambda do |game, _animation, store, frame_event|
  max = frame_event["max_animation_frame"].to_i
  store['frame_index'] = max if store['frame_index'] > max
  :ok
end