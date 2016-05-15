FRAME_EVENT_SYSTEMS['key_down'] =
lambda do |game, animation, store, frame_event|
  case frame_event["key_down"]
  when String
    if frame_event["time_since_key_down"]
      return :ok if store['input'].key_down_time(frame_event["key_down"]) >= game.time - frame_event["time_since_key_down"]
    else
      return :ok if store['input'].key_down? frame_event["key_down"]
    end
    
  when Array
    frame_event["keys_down"].each do |key_down|
      if frame_event["time_since_key_down"]
        return :skip unless store['input'].key_down_time(key_down) >= game.time - frame_event["time_since_key_down"]
      else
        return :skip unless store['input'].key_down? key_down
      end
    end
    return :ok
    
  else
    raise "Unexpected data type!"
  end
  
  return :skip
end