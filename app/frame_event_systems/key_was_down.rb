FRAME_EVENT_SYSTEMS['key_was_down'] =
lambda do |game, animation, store, frame_event|
  
  key        = frame_event["key_was_down"]["key"]
  frames_ago = frame_event["key_was_down"]["frames_ago"]
  
  time_key_down = store['input'].key_down_time(key)
  
  return :ok if game.time - time_key_down == frames_ago
  return :skip
end