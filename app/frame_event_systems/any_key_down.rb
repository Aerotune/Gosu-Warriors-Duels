FRAME_EVENT_SYSTEMS['any_key_down'] =
lambda do |game, animation, store, frame_event|
  case frame_event["any_key_down"]
  when Array
    
    if frame_event['time_since_any_key_down']
      frame_event["any_key_down"].each do |key_down|
        return :ok if store['input'].key_down_time(key_down) >= game.time - frame_event["time_since_any_key_down"]
      end
    else
      frame_event["any_key_down"].each do |key_down|
        return :ok if store['input'].key_down? key_down
      end
    end
    return :skip
    
  else
    raise "Unexpected data type!"
  end
  
  return :skip
end