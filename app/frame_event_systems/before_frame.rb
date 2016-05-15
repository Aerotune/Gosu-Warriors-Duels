FRAME_EVENT_SYSTEMS['before_frame'] =
lambda do |game, animation, store, frame_event|
  store_frame_index = store['frame_index'] % animation['frames'].length
  
  case frame_event['before_frame']
  when Integer
    before_frame = frame_event['before_frame'] % animation['frames'].length
    return :ok if store_frame_index < before_frame
  else
    raise "Unexpected data type!"
  end
  
  return :skip
end