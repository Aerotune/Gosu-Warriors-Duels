FRAME_EVENT_SYSTEMS['velocity_factor_y_q8'] =
lambda do |game, animation, store, frame_event|
  factor = case frame_event['velocity_factor_y_q8']
  when Integer; frame_event['velocity_factor_y_q8']
  when 'ground_bounce'
    CHARACTER_STATS[store['entity_class']]['ground_bounce_factor_q8']
  end
  
  store['velocity_y_q8'] = ((store['velocity_y_q8'] * factor)>>8)
  :ok
end