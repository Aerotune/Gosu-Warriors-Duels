FRAME_EVENT_SYSTEMS['latest_key_down'] =
lambda do |game, animation, store, frame_event|
  case frame_event["latest_key_down"]
  when String
    if store['input'].latest_key_down(frame_event["keys"]) == frame_event["latest_key_down"]
      return :ok
    end
  else
    raise "Unexpected data type!"
  end
  
  return :skip
end