FRAME_EVENT_SYSTEMS['not_facing'] =
lambda do |game, animation, store, frame_event|
  case frame_event["not_facing"]
  when "wall"
    if store["x_q8"] > (game.stage_width_q8/2)
      return :ok if store["factor_x"] == -1
    else
      return :ok if store["factor_x"] == 1
    end
  when "opponent"
    opponent = case store['id']
    when 1; game.character2
    when 2; game.character1
    else
      raise "No opponent for store with id: #{store['id'].inspect}"
    end
    
    if store["factor_x"] == 1
      return :ok if store['x_q8'] > opponent['x_q8']
    elsif store["factor_x"] == -1
      return :ok if store['x_q8'] < opponent['x_q8']
    end
    
  else
    raise "Unexpected argument: #{frame_event["not_facing"].inspect}"
  end
  
  return :skip
end