FRAME_EVENT_SYSTEMS['acceleration_x_q8'] =
lambda do |game, animation, store, frame_event|
  max = frame_event['max_speed_x_q8']
  acceleration_x_q8 = frame_event['acceleration_x_q8']*store['factor_x']
  if acceleration_x_q8 > 0
    if store['velocity_x_q8'] < max
      store['velocity_x_q8'] += acceleration_x_q8
      store['velocity_x_q8'] = max if store['velocity_x_q8'] > max
    end
  else
    if store['velocity_x_q8'] > -max
      store['velocity_x_q8'] += acceleration_x_q8
      store['velocity_x_q8'] = -max if store['velocity_x_q8'] < -max
    end
  end
  :ok
end