FRAME_EVENT_SYSTEMS['key_up'] =
lambda do |game, animation, store, frame_event|
  case frame_event["key_up"]
  when String
    if frame_event["time_since_key_up"]
      return :ok if store['input'].key_up_time(frame_event["key_up"]) >= game.time - frame_event["time_since_key_up"]
    else
      return :ok unless store['input'].key_down? frame_event["key_up"]
    end
    
  when Array
    frame_event["key_up"].each do |key_up|
      if frame_event["time_since_key_up"]
        return :skip unless store['input'].key_up_time(key_up) >= game.time - frame_event["time_since_key_up"]
      else
        return :skip if store['input'].key_down? key_up
      end
    end
    return :ok
    
  else
    raise "Unexpected data type!"
  end
  
  return :skip
end