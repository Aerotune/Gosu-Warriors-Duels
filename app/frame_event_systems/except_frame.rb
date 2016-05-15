FRAME_EVENT_SYSTEMS['except_frame'] =
lambda do |game, animation, store, frame_event|
  store_frame_index = store['frame_index'] % animation['frames'].length
  
  case frame_event['except_frame']
  when Integer
    unless store_frame_index == (frame_event['except_frame'] % animation['frames'].length)
      return :ok
    end
    
  when Array
    frame_event['except_frame'].each do |frame|
      if store_frame_index == (frame % animation['frames'].length)
        return :skip
      end
    end
    return :ok
    
  else
    raise "Unexpected data type!"
  end
  
  return :skip
end