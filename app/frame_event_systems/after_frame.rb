FRAME_EVENT_SYSTEMS['after_frame'] =
lambda do |game, animation, store, frame_event|
  store_frame_index = store['frame_index'] % animation['frames'].length
  
  case frame_event['after_frame']
  when Integer
    after_frame = frame_event['after_frame'] % animation['frames'].length
    return :ok if store_frame_index > after_frame
  else
    raise "Unexpected data type!"
  end
  
  return :skip
end