FRAME_EVENT_SYSTEMS['set_animation_id'] =
lambda do |game, animation, store, frame_event|
  return :ok if frame_event["set_animation_id"].nil?
  animation_id = frame_event["set_animation_id"]
  direction    = store["factor_x"] == 1 ? "right" : "left"
  animation_id = animation_id.gsub "[direction]", direction
        
  store['animation_id'] = animation_id
  :ok
end