FRAME_EVENT_SYSTEMS['vfx'] =
lambda do |game, animation, store, frame_event|
  pos = [(store['x_q8']>>8), (store['y_q8']>>8)-10]
  #parent_id = store['id']
  factor_x = store['factor_x']
  game.spawn_effect frame_event["vfx"], pos, factor_x, nil
  return :ok
end