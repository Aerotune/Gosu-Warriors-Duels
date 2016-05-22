FRAME_EVENT_SYSTEMS['set_animation_frame'] =
lambda do |game, _animation, store, frame_event|
  store['frame_index'] = case frame_event["set_animation_frame"]
  when Integer
    frame_event["set_animation_frame"]
  when 'invert'
    -store['frame_index']
  when 'remaining'
    animation_id = store['animation_id']
    animation = ANIMATIONS[store['entity_class']][animation_id]
    raise "No animation id: #{animation_id}" unless animation
    remaining = (store['frame_index']%animation['frames'].length)-animation['frames'].length
    remaining
  end
  :ok
end