FRAME_EVENT_SYSTEMS['opponent_distance_more_than'] =
lambda do |game, animation, store, frame_event|
  
  opponent = case store['id']
  when 1; game.character2
  when 2; game.character1
  else
    raise "No opponent for store with id: #{store['id'].inspect}"
  end
  
  
  
  return :ok if ((store['x_q8'] - opponent['x_q8']).abs>>8) > frame_event['opponent_distance_more_than']
  return :skip
end