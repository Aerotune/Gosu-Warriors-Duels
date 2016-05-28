FRAME_EVENT_SYSTEMS['freeze_frames'] =
lambda do |game, animation, store, frame_event|
  game.freeze_frames += frame_event["freeze_frames"].to_i
  :ok
end