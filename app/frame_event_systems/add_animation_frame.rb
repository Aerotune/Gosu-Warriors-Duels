FRAME_EVENT_SYSTEMS['add_animation_frame'] =
lambda do |game, _animation, store, frame_event|
  store['frame_index'] += case frame_event["add_animation_frame"]
  when Integer
    frame_event["add_animation_frame"].to_i
  else
    raise "Unexpected value: #{frame_event["add_animation_frame"]}"
  end
  :ok
end