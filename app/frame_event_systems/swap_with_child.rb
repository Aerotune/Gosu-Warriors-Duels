FRAME_EVENT_SYSTEMS['swap_with_child'] =
lambda do |game, animation, store, frame_event|
  parent_id = store['id']
  
  child = game.projectiles.find { |projectile|
    projectile['parent_id'] == parent_id &&
    projectile['animation_id'] == frame_event['swap_with_child']
  }
  
  if child
    game.projectiles.delete child
  
    store['x_q8'] = child['x_q8']
    store['y_q8'] = child['y_q8']
  end
  
  :ok
end