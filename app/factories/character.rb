module Factory::Character
  class << self
    def construct options
      character_stats = CHARACTER_STATS[options['entity_class']]
      x_q8 = options['x_q8'] || (options['x']<<8)
      y_q8 = options['y_q8'] || (options['y']<<8)
      character = {
        'id' => options['id'],
        'entity_class' => options['entity_class'],
        'animation_id' => options['animation_id'] || "stand",
        'hit_index' => Hash.new { |hit_index,hit_id| hit_index[hit_id] = 0 },
        'hit_stun' => 0,
        'frame_index' => 0,
        'factor_x' => options['factor_x'],
        'x_q8' => x_q8,
        'y_q8' => y_q8,
        'prev_x_q8' => x_q8,
        'prev_y_q8' => y_q8,
        'z' => 0,
        'hp' => character_stats['max_hp'],
        'max_hp' => character_stats['max_hp'],
        'jab_lock_count' => 0,
        'offset_x_q8' => 0,
        'offset_y_q8' => 0,
        'velocity_x_q8' => 0,
        'velocity_y_q8' => 0,
        'outline_frames' => 0,
        'no_friction_x' => 0,
        'no_friction_y' => 0,
        'ignore_unit_collision' => 0,
        'dodge' => 0,
        'super_armor' => false,
        'buffer' => {},
        'cooldown' => {},
        'cooldown_reset_on_ground' => {
          'air_jump' => 3,
          'air_side_special' => 3,
          'dash' => 3,
          'wall_cling' => 3,
          'back_air_jump' => 3,
          'down_air_small_jump' => 3
        },
        'status_effects' => [],
        'hit_immunity' => Hash.new { |hit_immunity,hit_id| hit_immunity[hit_id] = -1},
        'color_scheme' => options['color_scheme']
      }
      
      character['input'] = Input.new(character, options['keys'])
      
      return character
    end
  end
end
