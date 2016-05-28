FRAME_EVENT_SYSTEMS['on_ground_bounce'] =
lambda do |game, animation, store, frame_event|
  character_stats = CHARACTER_STATS[store['entity_class']]
  
  if frame_event["on_ground_bounce"] == store['velocity_y_q8'] > character_stats['ground_bounce_min_speed_q8']
    return :ok
  else
    return :skip
  end
end