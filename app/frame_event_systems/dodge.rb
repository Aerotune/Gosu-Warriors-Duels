FRAME_EVENT_SYSTEMS['dodge'] =
lambda do |game, animation, store, frame_event|
  case frame_event['dodge']
  when Integer
    store['dodge'] = frame_event['dodge']
  end
  
  :ok
end