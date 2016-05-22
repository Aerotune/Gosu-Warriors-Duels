FRAME_EVENT_SYSTEMS['fast_fall'] =
lambda do |game, animation, store, frame_event|
  store['fast_fall'] = frame_event['fast_fall']
  :ok
end