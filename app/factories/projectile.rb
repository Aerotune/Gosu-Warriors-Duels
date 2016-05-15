module Factory::Projectile
  class << self
    def construct character, animation_id
      animation = ANIMATIONS[character['entity_class']][character['animation_id']]
      hit_id    = animation['hit_id']
      hit_index = character['hit_index'][hit_id] += 1      
      hit_mask, image, draw_x, draw_y, factor_x = Animation.draw_data character
      
      
      spawn_point = Animation.anchor_point character
      #spawn_point = [0,0]
      #hit_mask.each_with_x_y do |type, x, y|
      #  if type == :point
      #    spawn_point[0] = x
      #    spawn_point[1] = y
      #    break
      #  end
      #end
      
      x = draw_x + spawn_point[0] * character["factor_x"]
      y = draw_y + spawn_point[1]
            
      projectile = {
        'parent_id' => character['id'],
        "entity_class" => character['entity_class'],
        'animation_id' => animation_id,
        'hit_id' => hit_id,
        'hit_index' => character['hit_index'].dup,
        'hit_immunity' => Hash.new { |hit_immunity,hit_id| hit_immunity[hit_id] = -1},
        'frame_index' => 0,
        'factor_x' => character['factor_x'],
        'no_friction' => true,
        'x_q8' => x<<8,
        'y_q8' => y<<8,
        'prev_x_q8' => x<<8,
        'prev_y_q8' => y<<8,
        'z' => 0,
        'lifetime' => 17,
        'velocity_x_q8' => 0,
        'velocity_y_q8' => 0,
        'color_scheme' => character['color_scheme']
      }
      
      return projectile
    end
  end
end
