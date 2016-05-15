FRAME_EVENT_SYSTEMS['velocity_y_q8'] =
lambda do |game, animation, store, frame_event|
  store['velocity_y_q8'] = frame_event['velocity_y_q8']
  :ok
end