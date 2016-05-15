FRAME_EVENT_SYSTEMS['despawn'] =
lambda do |game, animation, store, frame_event|
  game.projectiles.delete store if frame_event['despawn'] == true
  :ok
end