FRAME_EVENT_SYSTEMS['velocity_factor_x_q8'] =
lambda do |game, animation, store, frame_event|
  store['velocity_x_q8'] = ((store['velocity_x_q8'] * frame_event['velocity_factor_x_q8'])>>8)
  :ok
end