FRAME_EVENT_SYSTEMS['factor_x'] =
lambda do |game, animation, store, frame_event|
  case frame_event["factor_x"]
  when Integer
    store["factor_x"] = frame_event["factor_x"]
  when "invert"
    store["factor_x"] = -store["factor_x"]
  when "wall"
    store["factor_x"] = store["x_q8"] > (game.stage_width_q8/2) ? -1 : 1
  else
    # do nothing
  end
  :ok
end