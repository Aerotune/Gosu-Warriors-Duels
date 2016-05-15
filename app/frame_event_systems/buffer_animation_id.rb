FRAME_EVENT_SYSTEMS['buffer_animation_id'] =
lambda do |game, animation, store, frame_event|
  store['buffer_animation_id'] = frame_event['buffer_animation_id']
  :ok
end