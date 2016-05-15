FRAME_EVENT_SYSTEMS['super_armor'] =
lambda do |game, animation, store, frame_event|
  store['super_armor'] = frame_event['super_armor']
  :ok
end