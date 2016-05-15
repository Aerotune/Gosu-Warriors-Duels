FRAME_EVENT_SYSTEMS['acceleration_y_q8'] =
lambda do |game, animation, store, frame_event|
  max = frame_event['max_speed_y_q8']
  acceleration_y_q8 = frame_event['acceleration_y_q8']
  if acceleration_y_q8 > 0
    if store['velocity_y_q8'] < max
      store['velocity_y_q8'] += acceleration_y_q8
      store['velocity_y_q8'] = max if store['velocity_y_q8'] > max
    end
  else
    if store['velocity_y_q8'] > -max
      store['velocity_y_q8'] += acceleration_y_q8
      store['velocity_y_q8'] = -max if store['velocity_y_q8'] < -max
    end
  end
  :ok
end