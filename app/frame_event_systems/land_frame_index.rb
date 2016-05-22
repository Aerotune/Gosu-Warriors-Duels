FRAME_EVENT_SYSTEMS['land_frame_index'] =
lambda do |game, animation, store, frame_event|
  store['land_frame_index'] = frame_event['land_frame_index']
  :ok
end