FRAME_EVENT_SYSTEMS['speed_x_q8_above'] =
lambda do |game, animation, store, frame_event|
  return :ok if store['velocity_x_q8'].abs > frame_event['speed_x_q8_above']
  return :skip
end