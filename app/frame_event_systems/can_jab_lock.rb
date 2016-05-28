FRAME_EVENT_SYSTEMS['can_jab_lock'] =
lambda do |game, animation, store, frame_event|
  if frame_event["can_jab_lock"] == store["jab_lock_count"] < 3
    :ok
  else
    :skip
  end
end