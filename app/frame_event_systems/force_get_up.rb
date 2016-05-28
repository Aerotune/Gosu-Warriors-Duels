FRAME_EVENT_SYSTEMS['force_get_up'] =
lambda do |game, animation, store, frame_event|
  return :ok if frame_event["force_get_up"] == store["jab_lock_count"] > 0
  return :skip
end