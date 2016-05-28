FRAME_EVENT_SYSTEMS['no_friction_x'] =
lambda do |game, animation, store, frame_event|
  store['no_friction_x'] = frame_event['no_friction_x']
  :ok
end