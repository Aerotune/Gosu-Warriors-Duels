FRAME_EVENT_SYSTEMS['hit_stun'] =
lambda do |game, animation, store, frame_event|
  hit_stun = frame_event['hit_stun'].to_i
  store['hit_stun'] = hit_stun
  :ok
end