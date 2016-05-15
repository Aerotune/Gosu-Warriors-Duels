FRAME_EVENT_SYSTEMS['ignore_unit_collision'] =
lambda do |game, animation, store, frame_event|
  store['ignore_unit_collision'] = frame_event['ignore_unit_collision']
  :ok
end