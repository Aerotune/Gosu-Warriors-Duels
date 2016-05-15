FRAME_EVENT_SYSTEMS['no_friction'] =
lambda do |game, animation, store, frame_event|
  store['no_friction'] = frame_event['no_friction']
  :ok
end