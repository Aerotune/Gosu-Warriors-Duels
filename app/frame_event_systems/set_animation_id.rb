FRAME_EVENT_SYSTEMS['set_animation_id'] =
lambda do |game, animation, store, frame_event|
  return :ok if frame_event["set_animation_id"].nil?
  animation_id = frame_event["set_animation_id"]
  direction    = store["factor_x"] == 1 ? "right" : "left"
  animation_id = animation_id.gsub "[direction]", direction
  store['animation_id'] = animation_id
  
  if animation_id == 'land'
    if store['land_frame_index']
      store['frame_index'] = store['land_frame_index']
      store['land_frame_index'] = nil
    end
    store['frame_index'] = -28 if store['frame_index'] < -28
  end
  
  new_animation = ANIMATIONS[store['entity_class']][store['animation_id']]
  new_animation['on_set_events'].to_a.each do |on_set_event|
    game.process_frame_event new_animation, store, on_set_event
  end
  
  :ok
end