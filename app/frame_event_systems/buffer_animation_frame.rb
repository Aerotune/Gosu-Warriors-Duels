FRAME_EVENT_SYSTEMS['buffer_animation_frame'] =
lambda do |game, animation, store, frame_event|
  store['buffer_animation_frame'] = frame_event['buffer_animation_frame']
  :ok
end