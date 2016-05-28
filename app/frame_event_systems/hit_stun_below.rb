FRAME_EVENT_SYSTEMS['hit_stun_below'] =
lambda do |game, animation, store, frame_event|
  if store['hit_stun'] < frame_event['hit_stun_below']
    return :ok
  else
    return :skip
  end
end