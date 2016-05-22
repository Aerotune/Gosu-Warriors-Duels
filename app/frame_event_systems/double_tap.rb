FRAME_EVENT_SYSTEMS['double_tap'] =
lambda do |game, animation, store, frame_event|
  case frame_event["double_tap"]
  when String
    return :ok if store['input'].double_tap?(game.time, frame_event["double_tap"])
    
  else
    raise "Unexpected data type! #{frame_event["double_tap"].inspect}"
  end
  
  return :skip
end