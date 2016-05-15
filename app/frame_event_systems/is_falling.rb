FRAME_EVENT_SYSTEMS['is_falling'] =
lambda do |game, animation, store, frame_event|
  case frame_event["is_falling"]
  when true, false
    is_falling = store['velocity_y_q8'] > 0
    return :ok if frame_event["is_falling"] == is_falling
  else
    raise "Unexpected argument: #{frame_event["is_falling"].inspect}, expected true or false"
  end
  
  return :skip
end