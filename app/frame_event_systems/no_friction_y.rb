FRAME_EVENT_SYSTEMS['no_friction_y'] =
lambda do |game, animation, store, frame_event|
  store['no_friction_y'] = frame_event['no_friction_y']
  :ok
end