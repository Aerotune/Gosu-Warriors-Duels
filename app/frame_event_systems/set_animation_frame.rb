FRAME_EVENT_SYSTEMS['set_animation_frame'] =
lambda do |game, _animation, store, frame_event|
  animation_id = store['animation_id']#store['buffer_animation_id'] || store['animation_id']
  animation = ANIMATIONS[store['entity_class']][animation_id]
  raise "No animation id: #{animation_id}" unless animation
  store['frame_index'] = case frame_event["set_animation_frame"]
  when Integer
    frame_event["set_animation_frame"] % animation['frames'].length
  when 'invert'
    -store['frame_index'] % animation['frames'].length
  end
  :ok
end