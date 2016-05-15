FRAME_EVENT_SYSTEMS['new_hit'] =
lambda do |game, animation, store, frame_event|
  case store['parent_id']
  when 1
    store['hit_index'][frame_event['new_hit']] = (game.character1['hit_index'][frame_event['new_hit']] += 1)
  when 2
    store['hit_index'][frame_event['new_hit']] = (game.character2['hit_index'][frame_event['new_hit']] += 1)
  else
    store['hit_index'][frame_event['new_hit']] += 1
  end
  :ok
end