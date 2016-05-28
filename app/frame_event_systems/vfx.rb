def spawn_vfx_id id, factor_x, game, store, x, y, color, fps, mode=:default
  game.effects << {
    type: :hit,
    vfx: id,
    parent_id: nil,
    factor_x: factor_x,
    color: color,
    time: game.time+3,
    x: x,
    y: y,
    mode: mode,
    fps: fps,
    duration: 50
  }
end

FRAME_EVENT_SYSTEMS['vfx'] =
lambda do |game, animation, store, frame_event|
  factor_x = store['factor_x']
  x = (store['x_q8']>>8)
  y = (store['y_q8']>>8)
  
  case frame_event["vfx"]
  when Hash
    factor_x = -factor_x if frame_event["vfx"]["factor_x"] == "invert"
    x += frame_event["vfx"]["offset_x"].to_i * factor_x
    y += frame_event["vfx"]["offset_y"].to_i
    color = 0xFFFFFFFF
    color = frame_event["vfx"]["color"].to_i(16) if frame_event["vfx"]["color"].kind_of? String
    fps   = (frame_event["vfx"]["fps"] || 30).to_i
    id = frame_event["vfx"]["id"]
    mode = frame_event["vfx"]["mode"] == 'additive' ? :additive : :default
    parent_id = frame_event["vfx"]["parent_id"] ? store['id'] : nil
    game.effects << {
      type: :hit,
      vfx: id,
      parent_id: parent_id,
      factor_x: factor_x,
      color: color,
      time: game.time+3,
      x: x,
      y: y,
      mode: mode,
      fps: fps,
      duration: 50
    }
  when 'air_swirl_diagonal'
    spawn_vfx_id frame_event["vfx"], factor_x, game, store, x, y-10, 0xA0FFFFFF, 50
  when 'fast_fall'
    game.effects << {
      type: :hit,
      vfx: 'fast_fall',
      parent_id: nil,
      factor_x: store['factor_x'],
      color: 0xff_FFFFFF,
      time: game.time,
      x: x-3*store['factor_x'],
      y: y-8,
      fps: 30,
      duration: 30
    }
  when 'tech'
    spawn_vfx_id frame_event["vfx"], factor_x, game, store, x, y, 0xFFBB00FF, 30, :additive
  when 'wave_bounce'
    color = 0xDD000000
    if store['velocity_x_q8'] > 0
      spawn_vfx_id frame_event["vfx"], -1, game, store, x-5, y-11, color, 20#, :additive
    elsif store['velocity_x_q8'] < 0
      spawn_vfx_id frame_event["vfx"], 1, game, store, x+5, y-11, color, 20#, :additive
    end
  when 'air_jump'
    color = case store['id']
    when 1; 0x70FF3311
    when 2; 0x701133FF
    else
      0x88FFFFFF
    end
    spawn_vfx_id frame_event["vfx"], factor_x, game, store, x, y, color, 30, :additive
  when String
    spawn_vfx_id frame_event["vfx"], factor_x, game, store, x, y, 0xFFFFFFFF, 30
  end
  
  #parent_id = store['id']
  #factor_x = store['factor_x']
  #game.spawn_effect frame_event["vfx"], pos, factor_x, nil
  
  
      
  return :ok
end