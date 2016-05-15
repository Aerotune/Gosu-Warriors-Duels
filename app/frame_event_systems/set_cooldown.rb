FRAME_EVENT_SYSTEMS['set_cooldown'] =
lambda do |game, animation, store, frame_event|
  cooldown = store['cooldown'][frame_event['set_cooldown']].to_i
  store['cooldown'][frame_event['set_cooldown']] = frame_event['min_cooldown'] if cooldown < frame_event['min_cooldown']
  
  :ok
end