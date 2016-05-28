FRAME_EVENT_SYSTEMS['jab_lock_count'] =
lambda do |game, animation, store, frame_event|
  store["jab_lock_count"] = frame_event["jab_lock_count"]
  return :ok
end