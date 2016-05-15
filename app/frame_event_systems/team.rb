FRAME_EVENT_SYSTEMS['team'] =
lambda do |game, animation, store, frame_event|
  if frame_event['team'] == 'swap'
    case store['parent_id']
    when 1
      store['parent_id'] = 2
      store['hit_index'] = game.character2['hit_index'].dup
      store['hit_immunity'].clear
    when 2
      store['parent_id'] = 1
      store['hit_index'] = game.character1['hit_index'].dup
      store['hit_immunity'].clear
    end
  end
  return :ok
end