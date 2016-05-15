FRAME_EVENT_SYSTEMS['parent_frame_events'] =
lambda do |game, animation, store, frame_event|
  parent = case store['parent_id']
  when 1; game.character1
  when 2; game.character2
  end
  
  parent_animation = ANIMATIONS[parent['entity_class']][parent['animation_id']]
  frame_event['parent_frame_events'].to_a.each do |frame_event|
    status = game.process_frame_event parent_animation, parent, frame_event
    break if status == :break
  end
  
  :ok
end