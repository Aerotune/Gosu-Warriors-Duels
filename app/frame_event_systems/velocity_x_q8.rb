FRAME_EVENT_SYSTEMS['velocity_x_q8'] =
lambda do |game, animation, store, frame_event|
  store['velocity_x_q8'] = frame_event['velocity_x_q8']*store['factor_x']
  :ok
end