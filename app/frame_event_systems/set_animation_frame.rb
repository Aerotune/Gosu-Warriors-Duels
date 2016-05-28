FRAME_EVENT_SYSTEMS['set_animation_frame'] =
lambda do |game, _animation, store, frame_event|
  animation_id = store['animation_id']
  animation = ANIMATIONS[store['entity_class']][animation_id]
  raise "No animation id: #{animation_id}" unless animation
  
  store['frame_index'] = case frame_event["set_animation_frame"]
  when Integer
    frame_event["set_animation_frame"]
  when 'invert'
    -store['frame_index']
  when 'remaining'
    remaining = (store['frame_index']%animation['frames'].length)-animation['frames'].length
    remaining
  when 'hit_stun'
    frame_index = -store["hit_stun"]
    frame_index = -70 if frame_index < -70
    frame_index = -2 if frame_index >= -2
    frame_index
  end
  :ok
end