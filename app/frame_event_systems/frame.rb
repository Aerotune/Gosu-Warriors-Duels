FRAME_EVENT_SYSTEMS['frame'] =
lambda do |game, animation, store, frame_event|
  store_frame_index = store['frame_index'] % animation['frames'].length
  
  case frame_event['frame']
  when "last"
    return :ok if store_frame_index == animation['frames'].length-1
    
  when Integer
    return :ok if store_frame_index == frame_event['frame'] % animation['frames'].length
    
  when Array
    frames = frame_event['frame'].map do |frame_index|
      frame_index % animation['frames'].length
    end
    return :ok if frames.include? store_frame_index
    
  else
    raise "Unexpected data type!"
  end
  
  return :skip
end