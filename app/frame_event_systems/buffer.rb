FRAME_EVENT_SYSTEMS['buffer'] =
lambda do |game, animation, store, frame_event|
  store['buffer'] = frame_event['buffer']
  :ok
end