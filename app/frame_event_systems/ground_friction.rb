FRAME_EVENT_SYSTEMS['ground_friction'] =
lambda do |game, animation, store, frame_event|
  store['ground_friction'] = frame_event['ground_friction']
  :ok
end