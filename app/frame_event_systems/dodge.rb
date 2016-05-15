FRAME_EVENT_SYSTEMS['dodge'] =
lambda do |game, animation, store, frame_event|
  store['dodge'] = frame_event['dodge']
  :ok
end