FRAME_EVENT_SYSTEMS['status'] =
lambda do |game, animation, store, frame_event|
  case frame_event["status"]
  when "break"; return :break
  when "skip"; return :skip
  when "ok"; return :ok
  end
end