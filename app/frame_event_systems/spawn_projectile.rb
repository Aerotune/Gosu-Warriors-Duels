FRAME_EVENT_SYSTEMS['spawn_projectile'] =
lambda do |game, animation, store, frame_event|
  animation_id = frame_event['spawn_projectile']
  game.projectiles.push Factory::Projectile.construct store, animation_id
  :ok
end