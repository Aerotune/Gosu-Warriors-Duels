FRAME_EVENT_SYSTEMS['hit_stun_above'] =
lambda do |game, animation, store, frame_event|
  if store['hit_stun'] > frame_event['hit_stun_above']
    return :ok
  else
    return :skip
  end
end