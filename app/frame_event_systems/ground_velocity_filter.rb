FRAME_EVENT_SYSTEMS['ground_velocity_filter'] =
lambda do |game, animation, store, frame_event|
  store['ground_velocity_filter'] = frame_event['ground_velocity_filter']
  :ok
end