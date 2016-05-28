FRAME_EVENT_SYSTEMS['reset'] =
lambda do |game, animation, store, frame_event|
  case frame_event["reset"]
  when "tech"
    store['input'].reset_tech
  end
  :ok
end