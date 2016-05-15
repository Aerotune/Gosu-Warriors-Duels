FRAME_EVENT_SYSTEMS['frame_event'] =
lambda do |game, animation, store, frame_event|
  animation_frame_events = ANIMATION_FRAME_EVENTS[store['entity_class']][frame_event['frame_event']]
  raise "No animation frame events with id: #{frame_event['frame_event']}" unless animation_frame_events
  animation_frame_events.each do |animation_frame_event|
    status = game.process_frame_event animation, store, animation_frame_event
    case status
    when :ok, :skip
      next
    when :break
      return :break
    end
  end
  :ok
end