FRAME_EVENT_SYSTEMS['is_fast_falling'] =
lambda do |game, animation, store, frame_event|
  case frame_event["is_fast_falling"]
  when true, false
    return :ok if frame_event["is_fast_falling"] == !!store['fast_fall']
  else
    raise "Unexpected argument: #{frame_event["is_fast_falling"].inspect}, expected true or false"
  end
  
  return :skip
end