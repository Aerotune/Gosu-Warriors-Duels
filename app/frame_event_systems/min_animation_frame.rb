FRAME_EVENT_SYSTEMS['min_animation_frame'] =
lambda do |game, _animation, store, frame_event|
  min = frame_event["min_animation_frame"].to_i
  store['frame_index'] = min if store['frame_index'] < min
  :ok
end