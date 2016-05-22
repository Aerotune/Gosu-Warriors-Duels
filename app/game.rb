require_relative 'black_white_background'
require_relative 'frame_event_systems'

class Game
  attr_accessor :freeze_frames
  attr_reader :time, :stage_width_q8, :volume, :canvas
  attr_reader :character1, :character2, :projectiles
  
  def sfx
    @@sfx
  end
  
  def initialize character1_entity_class, character2_entity_class, swap=false
    $intro ||= Gosu::Song.new 'intro.ogg'
    $music ||= Gosu::Song.new 'music.ogg'
    
    @time = 0
    @swap = swap
    
    #@black_white_background = BlackWhiteBackground.new
    
    @hp1 = HPBar.new
    @hp2 = HPBar.new
    @@ground_shadow ||= Gosu::Image.new $window, './resources/vfx/ground_shadow.png'
    
    
    @background_effects = []
    @@color_shader ||= Ashton::Shader.new fragment: './hue.frag'
    @@clash_shader ||= Ashton::Shader.new fragment: './clash.frag'
    @@outline_shader ||= Ashton::Shader.new fragment: :outline
    
    #@@white_shader ||= Ashton::Shader.new fragment: './white.frag'
    #@@black_shader ||= Ashton::Shader.new fragment: './black.frag'
    #@@invert_shader ||= Ashton::Shader.new fragment: './invert.frag'
    @@color_overlay_shader ||= Ashton::Shader.new fragment: './color_overlay.frag'
    #@hq3x = Ashton::Shader.new fragment: './hq3x.frag'
    
    @@sfx ||= {}
    if @@sfx.empty?
      sfx_resources_pathname = Pathname.new  './resources/sfx/'
      Dir['./resources/sfx/**/*.ogg'].each do |sfx_path|
        sfx_pathname = Pathname.new sfx_path
        id = sfx_pathname.relative_path_from(sfx_resources_pathname).to_s.gsub('.ogg', '')
        @@sfx[id] = Gosu::Sample.new sfx_path
      end
    end
    
    @volume = 0.8
    
    #@background = Gosu::Image.new $window, './resources/stages/dojo.png'
    @@clash_sfx ||= Gosu::Sample.new './resources/sfx/clash.ogg'
    
    @effects = []
    
    
    @stage_width_q8 = 360 << 8
    @screen_width_q8 = ($window.width / SCALE).to_i << 8
    
    @@tree_trunk ||= Gosu::Image.new $window, './resources/stages/tree_trunk.png', false
    @@leaves     ||= Gosu::Image.new $window, './resources/stages/leaves.png', false
    @@raindrop   ||= Gosu::Image.new $window, './resources/stages/raindrop.png', false
    @canvas = TexPlay.create_blank_image $window, @stage_width_q8>>8, 139#Ashton::Texture.new 280, 140
    @canvas.clear
    character1_x = (@stage_width_q8>>8)/2 + 80
    character1_factor_x = -1
    character2_x = (@stage_width_q8>>8)/2 - 80
    character2_factor_x = 1
    
    if @swap
      character1_x, character2_x = character2_x, character1_x
      character1_factor_x, character2_factor_x = character2_factor_x, character1_factor_x
    end
    
    @character1 = Factory::Character.construct \
      'id' => 1,
      'animation_id' => "stand",
      'entity_class' => character1_entity_class,
      'x' => character1_x,
      'y' => (ground_y_q8>>8),
      'factor_x' => character1_factor_x,
      'keys' => $window.control_setup.character1_keys
      
    @character2 = Factory::Character.construct \
      'id' => 2,
      'animation_id' => "stand",
      'entity_class' => character2_entity_class,
      'x' => character2_x,
      'y' => (ground_y_q8>>8),
      'factor_x' => character2_factor_x,
      'keys' => $window.control_setup.character2_keys
    
    @hp1.max_hp = @character1['max_hp']
    @hp2.max_hp = @character2['max_hp']
      
    @projectiles = []
    @freeze_frames = 0 #!!! crashes when not initialized as zero
    
    #if $intro && !$music.playing?
    #  $intro.volume = 0.35
    #  $intro.play unless $music.playing?
    #end
  end
  
  def button_down id
    if id == Gosu::KbEscape
      $music.stop
      $intro.stop
      $window.control_setup.reset!
      return $window.state = $window.control_setup
    end
    @character1['input'].button_down @time, id
    @character2['input'].button_down @time, id
  end
  
  def button_up id
    @character1['input'].button_up @time, id
    @character2['input'].button_up @time, id
  end
  
  def update
    #!!!
    #$gosu_blocks.clear if defined? $gosu_blocks # Workaround for Gosu bug (0.7.45)
    #$intro.volume = 0.35
    #$music.volume = 0.35
    #if !$intro.playing?
    #  $music.play true
    #end
    #p @character1['super_armor']
    @background_effects.delete_if {|w| w.dead? }
    @background_effects.each {|w| w.update }
    
    @freeze_frames -= 1
    @freeze_frames = 0 if @freeze_frames < 0
    
    if @freeze_frames > 0
      @hp1.update @character1['hp'], @character1['damage_estimate']
      @hp2.update @character2['hp'], @character2['damage_estimate']
      return
    end
    
    if @character1['hp'] <= 0 || @character2['hp'] <= 0
      $window.state = Game.new @character1['entity_class'], @character2['entity_class'], true #!! Calls draw before update because of this
      return
    end
    
    if @character1['super_armor'].kind_of? Numeric
      @character1['super_armor'] -= 1
      @character1['super_armor'] = false if @character1['super_armor'] <= 0
    else
      @character1['super_armor'] = false
    end
    
    if @character2['super_armor'].kind_of? Numeric
      @character2['super_armor'] -= 1
      @character2['super_armor'] = false if @character2['super_armor'] <= 0
    else
      @character2['super_armor'] = false
    end
    #@character1['no_friction'] = false
    #@character2['no_friction'] = false
    
    @projectiles.each do |entity|
      entity['frame_index'] += 1
    end
    
    @character1['frame_index'] += 1
    @character2['frame_index'] += 1
    
    if @character1["buffer_animation_id"] || @character1["buffer_animation_frame"] || @character1["buffer_factor_x"]
      process_frame_event \
      ANIMATIONS[@character1['entity_class']][@character1['animation_id']],
      @character1,
      {
        "set_animation_id" => @character1["buffer_animation_id"],
        "set_animation_frame" => @character1["buffer_animation_frame"] || @character1['frame_index'],
        "factor_x" => @character1["buffer_factor_x"]
      }
      
      @character1["buffer_animation_id"] = nil
      @character1["buffer_animation_frame"] = nil
      @character1["buffer_factor_x"] = nil
    end
    
    if @character2["buffer_animation_id"] || @character2["buffer_animation_frame"] || @character2["buffer_factor_x"]
      process_frame_event \
      ANIMATIONS[@character2['entity_class']][@character2['animation_id']],
      @character2,
      {
        "set_animation_id" => @character2["buffer_animation_id"],
        "set_animation_frame" => @character2["buffer_animation_frame"] || @character2['frame_index'],
        "factor_x" => @character2["buffer_factor_x"]
      }
      
      @character2["buffer_animation_id"] = nil
      @character2["buffer_animation_frame"] = nil
      @character2["buffer_factor_x"] = nil
    end
    
    if @character1["buffer"]
      process_frame_event \
      ANIMATIONS[@character1['entity_class']][@character1['animation_id']],
      @character1,
      @character1['buffer']
      
      @character1["buffer"] = nil
    end
    
    if @character2["buffer"]
      process_frame_event \
      ANIMATIONS[@character2['entity_class']][@character2['animation_id']],
      @character2,
      @character2['buffer']
      
      @character2["buffer"] = nil
    end
    
    @projectiles.each do |store|
      animation = ANIMATIONS[store['entity_class']][store['animation_id']]
      
      if store['buffer']
        process_frame_event \
        animation,
        store,
        store['buffer']
      end
    end
    
    @character1['ignore_unit_collision'] = nil
    @character2['ignore_unit_collision'] = nil
    
    animation1 = ANIMATIONS[@character1['entity_class']][@character1['animation_id']]
    animation2 = ANIMATIONS[@character2['entity_class']][@character2['animation_id']]
    
    raise "No animation #{@character1['animation_id']} for @character1" unless animation1
    raise "No animation #{@character2['animation_id']} for @character2" unless animation2
    
    @character1["damage_estimate"] = 0
    @character2["damage_estimate"] = 0
    
    @character1['ground_velocity_filter'] = nil
    @character1['ground_friction']        = nil
    @character2['ground_velocity_filter'] = nil
    @character2['ground_friction']        = nil
    
    
    if @character1['dodge'].kind_of? Numeric
      @character1['dodge'] -= 1
      @character1['dodge'] = false if @character1['dodge'] <= 0
    else
      @character1['dodge'] = false
    end
    
    if @character2['dodge'].kind_of? Numeric
      @character2['dodge'] -= 1
      @character2['dodge'] = false if @character2['dodge'] <= 0
    else
      @character2['dodge'] = false
    end
    
    @projectiles.each do |entity|
      animation = ANIMATIONS[entity['entity_class']][entity['animation_id']]
      animation['before_frame_events'].each do |frame_event|
        status = process_frame_event animation, entity, frame_event
        break if status == :break
      end
    end
    
    @projectiles.each do |projectile|
      process_character_physics projectile
    end
    
    
    
    animation1['before_frame_events'].each do |frame_event|
      status = process_frame_event animation1, @character1, frame_event
      break if status == :break
    end
    animation2['before_frame_events'].each do |frame_event|
      status = process_frame_event animation2, @character2, frame_event
      break if status == :break
    end
    
    # Push characters apart
    # character collision
    unless @character1['ignore_unit_collision'] || @character2['ignore_unit_collision'] || @character1['dodge'] || @character2['dodge']
      character_distance_x_q8 = (@character1['x_q8']-@character2['x_q8']).abs
      character_radius_x_q8 = (8<<8)
      if on_ground?(@character1) && on_ground?(@character2) && character_distance_x_q8 < character_radius_x_q8
        character_overlap_x_q8 = character_radius_x_q8 - character_distance_x_q8
        
        if @character1['prev_x_q8'] > @character2['prev_x_q8']
          left_character = @character2
          right_character =  @character1
        elsif @character1['prev_x_q8'] < @character2['prev_x_q8']
          left_character = @character1
          right_character =  @character2
        else
          if @character1['velocity_x_q8'] > @character2['velocity_x_q8']
            left_character = @character1
            right_character =  @character2
          elsif @character1['velocity_x_q8'] < @character2['velocity_x_q8']
            left_character = @character2
            right_character =  @character1
          else
            left_character, right_character = *[@character1, @character2].shuffle
          end
        end
        
        #right_character['x_q8'] += 
        #left_character['x_q8']  -= character_overlap_x_q8 / 2
        
        left_character_velocity_x_q8 = left_character['velocity_x_q8']
        right_character_velocity_x_q8 = right_character['velocity_x_q8']
        
        case [left_character['input'].key_down?('right'), right_character['input'].key_down?('left')]
        when [true, true]
          left_character['velocity_x_q8']  = (left_character_velocity_x_q8 + right_character_velocity_x_q8) / 2
          right_character['velocity_x_q8'] = (left_character_velocity_x_q8 + right_character_velocity_x_q8) / 2
        when [true, false]
          if left_character_velocity_x_q8 > right_character_velocity_x_q8
            left_character['ground_friction'] = 5
            left_character['ground_velocity_filter'] = 50
            right_character['offset_x_q8'] = left_character_velocity_x_q8
          end
        when [false, true]
          if right_character_velocity_x_q8 < left_character_velocity_x_q8
            right_character['ground_friction'] = 5
            right_character['ground_velocity_filter'] = 50
            left_character['offset_x_q8'] = right_character_velocity_x_q8
          end
        when [false, false]
          dx_q8 = character_overlap_x_q8.abs / 2
          left_character['offset_x_q8']   += -dx_q8 * 8 / 10
          #left_character['velocity_x_q8'] += -dx_q8 * 1 / 10
          #left_character['velocity_x_q8'] = -0 if left_character_velocity_x_q8 >= 0 && left_character['velocity_x_q8'] < 0
          
          right_character['offset_x_q8']   += dx_q8 * 8 / 10
          #right_character['velocity_x_q8'] += dx_q8 * 1 / 10
          #right_character['velocity_x_q8'] = 0 if right_character_velocity_x_q8 <= 0 && right_character['velocity_x_q8'] > 0
        end
      end
    end
    
    
    
    process_character_physics @character1
    process_character_physics @character2
    
    keep_on_stage @character1
    keep_on_stage @character2
    
    
    character_distance_q8 = (@character1['x_q8']-@character2['x_q8']).abs
    if character_distance_q8 >= @screen_width_q8-(8<<8)
      
      if @character1['x_q8'] > @character2['x_q8']
        if @character1['x_q8'] > @character1['prev_x_q8']
          @character1['x_q8'] = @character1['prev_x_q8']
        end
        if @character2['x_q8'] < @character2['prev_x_q8']
          @character2['x_q8'] = @character2['prev_x_q8']
        end
      else
        if @character1['x_q8'] < @character1['prev_x_q8']
          @character1['x_q8'] = @character1['prev_x_q8']
        end
        if @character2['x_q8'] > @character2['prev_x_q8']
          @character2['x_q8'] = @character2['prev_x_q8']
        end
      end      
    end
    ##cooldowns
    proccess_cooldowns @character1
    proccess_cooldowns @character2
    
    
    
    
    
    collisions = Animation.collisions(@character1, @character2)
    
    if collisions
      hit_effect_1 = get_hit_effect(@character1)
      hit_effect_2 = get_hit_effect(@character2)
      
      if collisions[:clash].length > 0
        animation_id1    = @character1['animation_id']
        animation_id2    = @character2['animation_id']
        
        character1_animation = animation1# ANIMATIONS[@character1['entity_class']][animation_id1]
        character2_animation = animation2# ANIMATIONS[@character2['entity_class']][animation_id2]
        
        character1_frame = character1_animation['frames'][@character1['frame_index']]
        character2_frame = character2_animation['frames'][@character2['frame_index']]
        
        hit1_id = character1_animation['hit_id']
        hit2_id = character2_animation['hit_id']
        
        hit1_index = @character1['hit_index'][hit1_id]
        hit2_index = @character2['hit_index'][hit2_id]
        
        #!!!Clash!!!
        #if true#@character2['hit_immunity'][hit1_id] < hit1_index && @character1['hit_immunity'][hit2_id] < hit2_index
        
        if hit_effect_1 && hit_effect_2
          unless hit_effect_1["type"] == "counter" && hit_effect_2["type"] == "counter"
            hit_immunity_granted1 = false
            hit_immunity_granted2 = false
            freeze_frames_1 = hit_effect_1['clash_freeze_frames']
            freeze_frames_2 = hit_effect_2['clash_freeze_frames']
            
            if @character2['hit_immunity'][hit1_id] < hit1_index
              if (hit_effect_2['priority'] >= hit_effect_1['priority'])
                @character2['hit_immunity'][hit1_id] = hit1_index
                hit_immunity_granted2 = true
              end
            end
            
            if hit_effect_1['cause_clash']# && (hit_effect_2['priority'] <= hit_effect_1['priority'])
              character2_animation['clash_frame_events'].to_a.each do |frame_event|
                status = process_frame_event character2_animation, @character2, frame_event
                break if status == :break
              end
            end
            
            
            if @character1['hit_immunity'][hit2_id] < hit2_index
              if (hit_effect_1['priority'] >= hit_effect_2['priority'])
                @character1['hit_immunity'][hit2_id] = hit2_index
                hit_immunity_granted1 = true
              end
            end
            
            if hit_effect_2['cause_clash']
              character1_animation['clash_frame_events'].to_a.each do |frame_event|
                status = process_frame_event character1_animation, @character1, frame_event
                break if status == :break
              end
            end
            
          
                 
            
            if hit_immunity_granted1 || hit_immunity_granted2
              unless hit_effect_1['disable_clash_effect'] && hit_effect_2['disable_clash_effect']
                if freeze_frames_1 && freeze_frames_2
                  if freeze_frames_1 != 0 && freeze_frames_2 != 0
                    @freeze_frames += (freeze_frames_1.to_i + freeze_frames_2.to_i) * 3 / 4
                  end
                end
                
                # Average position of collision pixels
                pos = collisions[:clash].reduce {|pos1,pos2| [pos1[0]+pos2[0], pos1[1]+pos2[1]]}
                pos[0] /= collisions[:clash].length
                pos[1] /= collisions[:clash].length
                
                hurt1 = (animation2['hit_hurtable'] && @character2['hit_immunity'][hit1_id] < hit1_index)
                hurt2 = (animation1['hit_hurtable'] && @character1['hit_immunity'][hit2_id] < hit2_index)
                unless hurt1 || hurt2
                  if animation2['hit_hurtable'] || animation1['hit_hurtable']
                    @effects << {
                      type: :clash,
                      time: @time,
                      x: pos[0],
                      y: pos[1],
                      duration: 15
                    }
                  else
                    @effects << {
                      type: :hit,
                      vfx: 'sparks',
                      time: @time,
                      x: pos[0],
                      y: pos[1],
                      duration: 15
                    }
                  end
                  @@clash_sfx.play 1.0*@volume, 0.85+rand*0.2
                  
                end
              end
            end
            
            
          end
        end
      end
      
      unless @character2['dodge']
        if collisions[:hit1].length > 0
          process_hit_collision collisions[:hit1], @character1, @character2
        end
        
        if collisions[:clash].length > 0
          if animation2['hit_hurtable']
            process_hit_collision collisions[:clash], @character1, @character2
          end
        end
      end
      
      unless @character1['dodge']
        if collisions[:hit2].length > 0
          process_hit_collision collisions[:hit2], @character2, @character1
        end
        
        if collisions[:clash].length > 0
          if animation1['hit_hurtable']
            process_hit_collision collisions[:clash], @character2, @character1
          end
        end
      end
    end
    
    @projectiles.each do |projectile|
      case projectile['parent_id']
      when 1
        collisions = Animation.collisions projectile, @character2
        if collisions[:clash].length > 0
          process_projectile_clash collisions, projectile, @character2
        else
          process_projectile_hit collisions, projectile, @character2
        end
      when 2
        collisions = Animation.collisions projectile, @character1
        if collisions[:clash].length > 0
          process_projectile_clash collisions, projectile, @character1
        else
          process_projectile_hit collisions, projectile, @character1
        end
      end      
    end
    
    @projectiles.each do |projectile|
      keep_on_stage projectile
    end
    
    proccess_status_effect @character1
    proccess_status_effect @character2
    
    @hp1.update @character1['hp'], @character1['damage_estimate']
    @hp2.update @character2['hp'], @character2['damage_estimate']
    
    @time += 1
    @character1['time'] = @time
    @character2['time'] = @time
  end
  
  def spawn_effect effect_id, pos, factor_x, parent_id=nil
    @effects << {
      type: :hit,
      vfx: effect_id,
      parent_id: parent_id,
      factor_x: factor_x,
      color: 0x88FFFFFF,
      time: @time,
      x: pos[0],
      y: pos[1],
      fps: 45,
      duration: 30
    }
  end
  
  def spawn_clash_effect collisions
    @freeze_frames += 2
    @@clash_sfx.play 1.0*@volume, 0.85+rand*0.2
    
    # Average position of collision pixels
    pos = collisions[:clash].reduce {|pos1,pos2| [pos1[0]+pos2[0], pos1[1]+pos2[1]]}
    pos[0] /= collisions[:clash].length
    pos[1] /= collisions[:clash].length
    
    @effects << {
      type: :clash,
      time: @time,
      x: pos[0],
      y: pos[1],
      duration: 15
    }
  end
  
  def process_projectile_clash collisions, projectile, character
    character_animation =  ANIMATIONS[character['entity_class']][character['animation_id']]
    projectile_animation = ANIMATIONS[projectile['entity_class']][projectile['animation_id']]
    
    character_hit_id  = character_animation['hit_id']
    projectile_hit_id = projectile_animation['hit_id']
    
    character_hit_index  = character['hit_index'][character_hit_id]
    projectile_hit_index = projectile['hit_index'][projectile_hit_id]
    
    character_vulnerable = character['hit_immunity'][projectile_hit_id] < projectile_hit_index
    projectile_vulnerable = projectile['hit_immunity'][character_hit_id] < character_hit_index
    
    character_hit_data = get_hit_effect character
    projectile_hit_data = get_hit_effect projectile
    
    can_clash = character_hit_data && character_hit_data['can_clash']
    can_reflect_projectiles = character_hit_data && character_hit_data['reflects_projectiles']
    
    if can_clash && (character_vulnerable || projectile_vulnerable)
      
      if projectile['priority'].to_i >= character_hit_data['priority'].to_i
        unless projectile['hit_immunity'][character_hit_id] == character_hit_index
          projectile['hit_immunity'][character_hit_id] = character_hit_index
          @effects << {
            type: :hit,
            vfx: 'sparks',
            time: @time,
            x: projectile['x_q8']>>8,
            y: projectile['y_q8']>>8,
            duration: 15
          }
          @@clash_sfx.play 0.5*@volume, 0.85+rand*0.2
        end
        
      end
      
      character_hit_priority = character_hit_data ? character_hit_data['priority'].to_i : -1
      if projectile_hit_data && character_hit_priority >= projectile_hit_data['priority'].to_i
        unless character['hit_immunity'][projectile_hit_id] == projectile_hit_index
          spawn_clash_effect collisions
          character['hit_immunity'][projectile_hit_id] = projectile_hit_index
        
          if can_reflect_projectiles
            projectile_animation['reflected_frame_events'].to_a.each do |frame_event|
              status = process_frame_event projectile_animation, projectile, frame_event
              break if status == :break
            end
          else
            projectile_animation['clash_frame_events'].to_a.each do |frame_event|
              status = process_frame_event projectile_animation, projectile, frame_event
              break if status == :break
            end
          end
        
          character_animation['on_hit_frame_events'].to_a.each do |frame_event|
            status = process_frame_event character_animation, character, frame_event
            break if status == :break
          end
        
          return :clash
        end
      end
    end
    
    return :no_clash
  end
  
  def process_projectile_hit collisions, projectile, character
    if collisions && collisions[:hit1].length > 0
      hit_status = process_hit_collision collisions[:hit1], projectile, character
      case hit_status
      when :hit, :clash
        projectile_animation = ANIMATIONS[projectile['entity_class']][projectile['animation_id']]
        projectile_animation['on_hit_frame_events'].to_a.each do |frame_event|
          status = process_frame_event projectile_animation, projectile, frame_event
          break if status == :break
        end
        #@projectiles.delete projectile #if projectile['frame_index'] > 2 #!!! make it an on hit frame event instead
      when :immune
      end
      
    end
  end
  
  def proccess_status_effect character
    character["status_effects"].each do |status_effect|
      status_effect["startup_frames"] -= 1      
      if status_effect["startup_frames"].to_i > 0
        
      else
        case status_effect["type"]
        when "hit"
          hit_collisions = [[status_effect["x"]+(character["x_q8"]>>8), status_effect["y"]+(character["y_q8"]>>8)]]
          hit_data = status_effect
          apply_hit hit_collisions, hit_data, status_effect["hitting_character"], character
        end
        
        character["status_effects"].delete status_effect
      end
    end
    
    character["status_effects"].each do |status_effect|
      character["damage_estimate"] += status_effect["damage_estimate"].to_i
    end

    #character["status_effects"].delete_if! { |status_effect| status_effect["startup_frames"].to_i <= 0 }
  end
  
  def proccess_cooldowns character
    character['cooldown'].each do |k, v|
      next if character['cooldown'][k] == 65535
      
      character['cooldown'][k] = character['cooldown'][k].to_i - 1
      character['cooldown'][k] = 0 if character['cooldown'][k] < 0
    end
    
    if on_ground? character
      character['cooldown_reset_on_ground'].each do |id, reset_cooldown|
        character['cooldown'][id] = reset_cooldown if character['cooldown'][id].to_i > reset_cooldown
      end
    end
  end
  
  def left_wall_q8
    @left_wall_q8 ||= (7<<8)
  end
  
  def right_wall_q8
    @right_wall_q8 ||= @stage_width_q8 - (7<<8)
  end
  
  def keep_on_stage character
    # wall
    x_q8 = character["x_q8"]
    
    min_bounce_speed = 300
    
    if x_q8 < left_wall_q8
      character["x_q8"] = left_wall_q8
      
      if character['animation_id'].match(/hurt/) && character['velocity_x_q8'] < -min_bounce_speed
        character['factor_x'] = -1
        character['velocity_x_q8'] = -character['velocity_x_q8'] * 6 / 8
      else
        character['velocity_x_q8'] = 0
      end
    end
    
    if x_q8 > right_wall_q8
      character["x_q8"] = right_wall_q8
      
      if character['animation_id'].match(/hurt/) && character['velocity_x_q8'] > min_bounce_speed
        character['factor_x'] = 1
        character['velocity_x_q8'] = -character['velocity_x_q8'] * 6 / 8
      else
        character['velocity_x_q8'] = 0
      end
    end
  end
  
  def process_hit_collision hit_collisions, hitting_entity, hurting_entity
    hitting_animation = ANIMATIONS[hitting_entity['entity_class']][hitting_entity['animation_id']]
    hit_id    = hitting_animation['hit_id']
    hit_index = hitting_entity['hit_index'][hit_id]
    
    if hurting_entity['hit_immunity'][hit_id] < hit_index
      hit_data = get_hit_effect hitting_entity
      if hit_data
        hurting_entity['hit_immunity'][hit_id] = hit_index 
        apply_hit hit_collisions, hit_data, hitting_entity, hurting_entity
        return :hit
      end
    else
      return :immune
    end
  end
  
  def get_hit_effect character
    animation = ANIMATIONS[character['entity_class']][character['animation_id']]
    hit_effects = ANIMATION_HIT_EFFECTS[character['entity_class']]
    
    hit_effect_id = animation["frames"][character["frame_index"]%animation["frames"].length]["hit_effect"] || animation["default_hit_effect"]
    hit_data = hit_effects[hit_effect_id]
  end
  
  def apply_hit hit_collisions, hit_data, hitting_character, hurting_character, hitting_factor_x=hitting_character["factor_x"]
    hitting_animation = ANIMATIONS[hitting_character['entity_class']][hitting_character['animation_id']]
    hitting_frame_index = hitting_character["frame_index"]%hitting_animation['frames'].length
    hitting_frame = hitting_animation['frames'][hitting_frame_index]
    
    
    #hit_factor_x = hitting_factor_x
    if hitting_animation['disable_hit_cross_up']
      hit_factor_x = hitting_factor_x
    else
      distance = (hurting_character['x_q8']-hitting_character['x_q8'])>>8
      if distance.abs >= 7
        if hitting_character['x_q8'] > hurting_character['x_q8']
          hit_factor_x = distance < 3 ? -1 : 1
        else
          hit_factor_x = distance > -3 ? 1 : -1
        end
      else
        hit_factor_x = hitting_factor_x
      end
    end
    
    unless hurting_character['super_armor']
      hit_velocity_x_q8  = hurting_character['prev_velocity_x_q8'].to_i
      hit_velocity_x_q8  = ((hit_data['hit_keep_velocity_x_q8'].to_i * hit_velocity_x_q8)>>8) if hit_data['hit_keep_velocity_x_q8']
      acceleration_x_q8  = hit_data['hit_acceleration_x_q8'].to_i * hit_factor_x
      acceleration_x_q8 += (hit_data['hit_transfer_velocity_x_q8'].to_i * hitting_character['velocity_x_q8'])>>8
      max_speed_x_q8 = hit_data['hit_max_speed_x_q8'].to_i.abs
      if acceleration_x_q8 > 0  && (hit_velocity_x_q8 < max_speed_x_q8)
        hit_velocity_x_q8 += acceleration_x_q8
        hit_velocity_x_q8 = max_speed_x_q8 if hit_velocity_x_q8 > max_speed_x_q8
      elsif acceleration_x_q8 < 0 && (hit_velocity_x_q8 > -max_speed_x_q8)
        hit_velocity_x_q8 += acceleration_x_q8
        hit_velocity_x_q8 = -max_speed_x_q8 if hit_velocity_x_q8 < -max_speed_x_q8
      end
    
      hit_velocity_y_q8  = hurting_character['prev_velocity_y_q8'].to_i
      hit_velocity_y_q8  = ((hit_data['hit_keep_velocity_y_q8'].to_i * hit_velocity_y_q8)>>8) if hit_data['hit_keep_velocity_y_q8']      
      acceleration_y_q8  = hit_data['hit_acceleration_y_q8'].to_i
      acceleration_y_q8 += (hit_data['hit_transfer_velocity_y_q8'].to_i * hitting_character['velocity_y_q8'])>>8
      max_speed_y_q8 = hit_data['hit_max_speed_y_q8'].to_i.abs
      if (acceleration_y_q8 > 0) && (hit_velocity_y_q8 < max_speed_y_q8)
        hit_velocity_y_q8 += acceleration_y_q8
        hit_velocity_y_q8 = max_speed_y_q8 if hit_velocity_y_q8 > max_speed_y_q8
      elsif (acceleration_y_q8 < 0) && (hit_velocity_y_q8 > -max_speed_y_q8)
        hit_velocity_y_q8 += acceleration_y_q8
        hit_velocity_y_q8 = -max_speed_y_q8 if hit_velocity_y_q8 < -max_speed_y_q8
      end
    
      if hit_data["hit_stun_frames"].to_i > 0
        hitting_character['z'] = 0
        hurting_character['z'] = -1
        hurting_character['buffer'] = { 'fast_fall' => false }
        hurting_character['buffer_animation_id']    = "hurt_walk_backward"
        hurting_character['buffer_animation_frame'] = -(hitting_frame["hit_stun_frames"] || hit_data["hit_stun_frames"]).to_i
        hurting_character['buffer_factor_x']        = -hit_factor_x
      end
      hurting_character['velocity_x_q8'] = hit_velocity_x_q8
      hurting_character['velocity_y_q8'] = hit_velocity_y_q8
    end
    hurting_character['hp'] -= hit_data['damage'].to_i
    
    if hurting_character['hp'] <= 0
      @freeze_frames += 40
    end
    
    
    @freeze_frames += hit_data["hit_freeze_frames"].to_i
    
    # Average position of collision pixels
    pos = hit_collisions.reduce {|pos1,pos2| [pos1[0]+pos2[0], pos1[1]+pos2[1]]}
    pos[0] /= hit_collisions.length
    pos[1] /= hit_collisions.length      
    
    
    if hit_data['hit_sfxs']
      hit_sfx = hit_data['hit_sfxs'][rand(hit_data['hit_sfxs'].length)]
      hit_sfx = @@sfx[hit_sfx]
      volume = hit_data['volume'] || 0.8
      speed = hit_data['speed'] || 0.94+rand*0.12
      hit_sfx.play volume*@volume, speed+(rand*0.15-0.075)*speed if hit_sfx
    end
    
    if hit_data['hit_sfxs2']
      hit_sfx = hit_data['hit_sfxs2'][rand(hit_data['hit_sfxs2'].length)]
      hit_sfx = @@sfx[hit_sfx]
      volume = hit_data['volume'] || 0.8
      hit_sfx.play volume*@volume, 0.94+rand*0.12 if hit_sfx
    end
          
    if hit_data['shockwave']
      @background_effects.push Shockwave.new(pos[0]*SCALE, pos[1]*SCALE)
    end
    
    if hit_data['hit_vfxs']
      hit_data['hit_vfxs'].each do |vfx_id|
        @effects << {
          parent_id: hitting_character['parent_id'] || hitting_character['id'],
          type: :hit,
          vfx: vfx_id,
          time: @time,
          x: pos[0],
          y: pos[1],
          duration: 15,
          factor_x: -hitting_character['factor_x']
        }
      end
    end
    
    if hit_data['hit_shake']
      @effects << {
        type: :shake,
        time: @time,
        amount: hit_data['hit_shake']['amount'],
        duration: hit_data['hit_shake']['duration']
      }
    end
    
    if hit_data["hit_status_effect"]
      status_effect = hit_data["hit_status_effect"].clone
      status_effect["hitting_character"] = hitting_character
      status_effect["x"] = pos[0]-(hurting_character["x_q8"]>>8)
      status_effect["y"] = pos[1]-(hurting_character["y_q8"]>>8)
      hurting_character["status_effects"] << status_effect
    end
    
    hitting_animation['on_hit_frame_events'].to_a.each do |frame_event|
      status = process_frame_event hitting_animation, hitting_character, frame_event
      break if status == :break
    end
  end
  
  def process_character_physics character
    character_stats = CHARACTER_STATS[character['entity_class']]

    gravity                 = character_stats['gravity']
    ground_friction         = character_stats['ground_friction']
    ground_velocity_filter  = character_stats['ground_velocity_filter'] # out of 256 removed per frame
    ground_bounce_factor_q8 = character_stats['ground_bounce_factor_q8']
    ground_bounce_min_speed_q8 = character_stats['ground_bounce_min_speed_q8']
    max_fall_speed          = character_stats['max_fall_speed']
    velocity_x_filter       = character_stats['velocity_x_filter']
    velocity_y_filter       = character_stats['velocity_y_filter']
    
    character['prev_x_q8'] = character['x_q8']
    character['prev_y_q8'] = character['y_q8']
    
    character['x_q8'] += character['velocity_x_q8']
    character['y_q8'] += character['velocity_y_q8']
    
    character['x_q8'] += character['offset_x_q8'].to_i
    character['y_q8'] += character['offset_y_q8'].to_i
    
    character['offset_x_q8'] = 0
    character['offset_y_q8'] = 0
    
    character['prev_velocity_x_q8'] = character['velocity_x_q8']
    character['prev_velocity_y_q8'] = character['y_q8']-character['prev_y_q8']#character['velocity_y_q8']
    
    if on_ground? character
      character['y_q8'] = ground_y_q8
      character['fast_fall'] = false
      
      if character['velocity_y_q8'] > ground_bounce_min_speed_q8 && character['animation_id'].match(/hurt/) || character['buffer_animation_id'].to_s.match(/hurt/)
        character['velocity_y_q8'] = character['velocity_y_q8'] * ground_bounce_factor_q8 / 256
      else
        character['velocity_y_q8'] = 0
      end
      
      ground_velocity_filter = character['ground_velocity_filter'] if character['ground_velocity_filter']
      ground_friction = character['ground_friction'] if character['ground_friction']
      
      if character['velocity_x_q8'] > 0
        character['velocity_x_q8'] -= (character['velocity_x_q8'] * ground_velocity_filter) / 256
        character['velocity_x_q8'] -= ground_friction        
        character['velocity_x_q8'] = 0 if character['velocity_x_q8'] < 0
      elsif character['velocity_x_q8'] < 0
        character['velocity_x_q8'] -= (character['velocity_x_q8'] * ground_velocity_filter) / 256
        character['velocity_x_q8'] += ground_friction        
        character['velocity_x_q8'] = 0 if character['velocity_x_q8'] > 0
      end
    else
      unless character['no_friction']
        character['velocity_x_q8'] -= (character['velocity_x_q8'] * velocity_x_filter) / 256
        character['velocity_y_q8'] -= (character['velocity_y_q8'] * velocity_y_filter) / 256
      end
    end
    
    
    
    if character['fast_fall']
      character['velocity_y_q8'] = character_stats['fast_fall_speed']
    else
      if character["animation_id"].match /hurt/
        if character['velocity_y_q8'] < max_fall_speed
          character['velocity_y_q8'] += gravity if character['y_q8'] < ground_y_q8
          character['velocity_y_q8'] = max_fall_speed if character['velocity_y_q8'] > max_fall_speed
        end
      else
        character['velocity_y_q8'] += gravity if character['y_q8'] < ground_y_q8
        character['velocity_y_q8'] = max_fall_speed if character['velocity_y_q8'] > max_fall_speed
      end
    end
  end
  
  def frame_event_systems_stack
    [
      "on_ground",
      "on_wall",
      "not_facing",
      "facing",
      "is_falling",
      "is_fast_falling",
      "can_consume",
      "speed_x_q8_above",
      "frame",
      "after_frame",
      "before_frame",
      "except_frame",
      "latest_key_down",
      "key_up",
      "key_down",
      "any_key_down",
      "double_tap",
      'opponent_distance_more_than',
      ## Checks above
      ## Updates below
      "swap_with_child",
      "parent_frame_events",
      "team",
      "factor_x",
      "new_hit",
      "consume",
      "grab",
      "dodge",
      "super_armor",
      "land_frame_index",
      "fast_fall",
      "velocity_factor_x_q8",
      "velocity_factor_y_q8",
      "acceleration_x_q8",
      "acceleration_y_q8",
      "velocity_x_q8",
      "velocity_y_q8",
      "ground_friction",
      "ground_velocity_filter",
      "ignore_unit_collision",
      "spawn_projectile",
      "despawn",
      "set_cooldown",
      "vfx",
      "sfx",
      "buffer",
      "buffer_animation_id",
      "buffer_animation_frame",
      "draw_on_canvas",
      "set_animation_frame",
      "add_animation_frame",
      "min_animation_frame",
      "max_animation_frame",
      "set_animation_id",
      "frame_event",
      "status"
    ]
  end
  
  def process_frame_event animation, store, frame_event
    frame_event_systems_stack.each do |frame_event_system_id|
      next unless frame_event.has_key? frame_event_system_id
      
      system = FRAME_EVENT_SYSTEMS[frame_event_system_id] || raise("No frame_event_system with id: #{frame_event_system_id}")
      status = system.call self, animation, store, frame_event
      
      case status
      when :break
        return :break
      when :skip
        return :skip
      when :ok
        next
      end
    end
    
    return :ok
  end
  
  def on_ground? store
    (store['y_q8'] >= ground_y_q8)
  end
  
  def on_wall? store
    store['x_q8'] >= right_wall_q8 ||
    store['x_q8'] <= left_wall_q8
  end
  
  def on_left_wall? store
    store['x_q8'] <= left_wall_q8
  end
  
  def on_right_wall? store
    store['x_q8'] >= right_wall_q8
  end
  
  def ground_y_q8
    (410<<8)/3
  end
  
  def frames_left character
    animation = ANIMATIONS[character['entity_class']][character['animation_id']]
    character['frame_index'] < 0 ? character['frame_index'].abs : (animation['frames'].length-1)-character['frame_index']
  end
  
  def draw
    #$window.fill 0xFF171717
    
    #fill 0xFF8ab5ee, 0xFF7caeEE, 0xFF5662ee, 0xFF5662bf
    
    
    #scale = 3.0 - @time/120.0
    #scale = 1.0 if scale < 1.0
    
    
    offset_x = 0
    offset_y = 0
    
    @effects.delete_if { |effect| @time-effect[:time] > effect[:duration]}
    
    if shake = @effects.find {|effect| effect[:type] == :shake}
      shake_factor = 1.0 - (@time-shake[:time])/shake[:duration]
      shake_factor = 0.0 if shake_factor < 0.0
      offset_x = (rand-0.5)*shake[:amount]*shake_factor
      offset_y = (rand-0.5)*shake[:amount]*shake_factor
    end
    
    #@black_white_background.draw
    
    next_camera_x = -((@character1['x_q8']+@character2['x_q8'])/2-@screen_width_q8/2)>>8#-((@character1['x_q8'] + @character2['x_q8'])/2 - @stage_width_q8/2) >> 8
    character_y = ((@character1['y_q8']+@character2['y_q8'])/2)>>8#[@character1['y_q8'], @character2['y_q8']].max >>8
    next_camera_y = -character_y+(ground_y_q8>>8)*1/2
    
    @camera_x ||= next_camera_x
    @camera_y ||= next_camera_y
    @camera_x += (next_camera_x-@camera_x)*0.35
    @camera_y += (next_camera_y-@camera_y)*0.1
    @camera_y = 0 if @camera_y < 0
    #@camera_y += 1
    
    @camera_x = 7 if @camera_x > 7
    @camera_x = -(@stage_width_q8>>8)-7+(@screen_width_q8>>8) if @camera_x < -(@stage_width_q8>>8)-7+(@screen_width_q8>>8)
    
    $window.clip_to 0, 0, 280*SCALE, 146*SCALE do
      $window.scale SCALE do
        grass_images = SPRITE_SHEETS['plants']['grass']['images']
      
      
      
      
        #$window.post_process *@background_effects.map(&:shader) do
        #  @background.draw 0,0,0
        #end
        
        camera_x, camera_y = @camera_x+offset_x, @camera_y+offset_y
        #camera_x = 3 if camera_x > 3
      
        $window.fill 0xFF1f6225
      
        grass3_y = camera_y*0.73+(ground_y_q8>>8)-16-8
        grass2_y = camera_y*0.82+(ground_y_q8>>8)-16-6
        grass1_y = camera_y*1.25+(ground_y_q8>>8)-16+6
      
        background_ground_color = 0xFF5dc47f
      
      
        $window.draw_quad \
        -5*SCALE, grass1_y+32, 0xFF48a360,
        $window.width+5*SCALE, grass1_y+32, 0xFF48a360,
        $window.width+5*SCALE, grass2_y+9, 0xFF1f6225,
        -5*SCALE, grass2_y+9, 0xFF1f6225, 0
      
        $window.draw_quad \
        -5*SCALE, grass2_y+12, 0xFF1f6225,
        $window.width+5*SCALE, grass2_y+12, 0xFF1f6225,
        $window.width+5*SCALE, grass3_y+9, 0xFF5dc47f,
        -5*SCALE, grass3_y+9, 0xFF5dc47f, 0
        
        # Sky
        $window.draw_quad \
        -5*SCALE, grass3_y+9, 0xFF737b8a,
        $window.width+5*SCALE, grass3_y+9, 0xFF737b8a,
        $window.width+5*SCALE, @camera_y-250, 0xFF0b041a,
        -5*SCALE, @camera_y-250, 0xFF0b041a, 0
        
        # Fade from sky to grass
        $window.draw_quad \
        -5*SCALE, grass3_y+5, 0x00737b8a,
        $window.width+5*SCALE, grass3_y+5, 0x00737b8a,
        $window.width+5*SCALE, grass3_y+9, 0xFF5dc47f,
        -5*SCALE, grass3_y+9, 0xFF5dc47f, 0
      
      
      rain_color = Gosu::Color.argb(50, 130, 200, 255)
        
        30.times do |i|
          rain_color.alpha = (@time*6491+i*7883)%100
          @@raindrop.draw (8543+i*123+camera_x*0.2+@time*0.2)%(@stage_width_q8>>8), (@time*1.6+100-i*7919+grass3_y)%400-100, 0, 0.4, 0.4, rain_color
        end
      
        30.times do |i|
          grass_image = grass_images[((@time+i*4.5+4)/10.5)%grass_images.length]
          grass_image.draw i*12-12+camera_x*0.6%12, grass3_y, 0, 0.375, 0.6, 0x99FFFFFF
        end
        
        
        20.times do |i|
          rain_color.alpha = (@time*6173+i*7883)%255-50
          @@raindrop.draw (3458+i*123+camera_x*0.82+@time*0.82)%(@stage_width_q8>>8), (@time*6.4+100-i*7919+grass2_y)%400-100, 0, 0.6, 0.6, rain_color
        end
        
        13.times do |i|
          grass_image = grass_images[((@time+i*3.8)/7.8)%grass_images.length]
          grass_image.draw i*24-24+camera_x*0.82%24, grass2_y, 0, 0.75, 0.75, 0xCCFFFFFF
        end
        
        
      
        $window.translate camera_x, camera_y do
          
          @@tree_trunk.draw -10, -155, 0
          @@tree_trunk.draw (@stage_width_q8>>8)+10, -155, 0, -1
          @canvas.draw 0,0,0
          if @character1['z'] < @character2['z']
            draw_character1
            draw_character2
          else
            draw_character2
            draw_character1
          end
          
          
          10.times do |i|
            rain_color.alpha = (@time*7907+i*7883)%255-100
            @@raindrop.draw (100+i*123+@time)%(@stage_width_q8>>8), (@time*8+100-i*7919)%400-100, 0, 1, 1, rain_color
          end
          
          @@leaves.draw -10, -251, 0
          @@leaves.draw (@stage_width_q8>>8)+10, -251, 0, -1
      
          draw_projectiles
        end
      
      
      
        10.times do |i|
          grass_image = grass_images[((@time+i*7.0+8)/9.3)%grass_images.length]
          grass_image.draw i*32-32+camera_x*1.25%32, grass1_y, 0, 1, 1.1, 0xAAFFFFFF
        end
      
        $window.translate camera_x, camera_y do
          draw_effects @effects
        end
      end
    end
    
    scale_x = 1.0
    scale_x = -1.0 if @swap
    
    $window.scale scale_x, 1, $window.width/2.0, 0 do
      @@outline_shader.outline_width = 4.0
      @@outline_shader.outline_color = Gosu::Color.argb(255, 0, 40, 255)
      $window.post_process @@color_shader do
        @hp2.draw
      end
    
      @@outline_shader.outline_width = 4.0
      @@outline_shader.outline_color = Gosu::Color.argb(255, 255, 0, 0)
      
      #$window.post_process @invert_shader, @@outline_shader do
        $window.scale -1, 1, $window.width/2.0, 0 do
          @hp1.draw
        end
        #end
    end
  end
  
  def draw_effects effects
    effects.each do |effect|
      z = 0
      
      if effect[:type] == :hit
        images = SPRITE_SHEETS['hit_vfx'][effect[:vfx]]['images']
        #images = SPRITE_SHEETS['punch_man']['hit']['images']
      elsif effect[:type] == :clash
        images = SPRITE_SHEETS['hit_vfx']['nullify']['images'] #!!!
      else
        next
      end
      rate = 60.0/(effect[:fps] || 30.0)
      index = (@time-effect[:time])/rate
      image = images[index]
      factor_x = effect[:factor_x] || 1
      draw_x = effect[:x]-16*factor_x
      draw_y = effect[:y]-16
      next unless image
      
      color = effect[:color] || 0xFF_FFFFFF
      
      case effect[:parent_id]
      when 1
        image.draw draw_x, draw_y, z, factor_x, 1, color
      when 2
        $window.post_process @@color_shader do
          image.draw draw_x, draw_y, z, factor_x, 1, color
        end
      else
        if effect[:vfx] == 'air_swirl_diagonal'
          image.draw draw_x, draw_y, z, factor_x, 1, color
        else
          $window.post_process @@clash_shader do
            image.draw draw_x, draw_y, z, factor_x, 1, color
          end
        end
      end
    end
  end
  
  def update_outline character
    @@outline_shader.outline_width = 2.0
    
    alpha = 40
    case character['id']
    when 1; r, g, b = 255, 0, 0
    when 2; r, g, b = 0, 0, 255
    else
      raise "Invalid character id: #{character['id'].inspect}"
    end
    
    if character['animation_id'].match(/hurt|clash/) || character['buffer_animation_id'].to_s.match(/hurt|clash/)
      _frames_left = frames_left(character)
      alpha += 50+15*_frames_left
      r += 210
      g += 220
      b += 230
    end
    
    @@outline_shader.outline_color = Gosu::Color.argb(alpha, r, g, b)
  end
  
  def draw_character1
    shadow_alpha = 110 - (((ground_y_q8-@character1['y_q8'])*7/12)>>8)
    
    @@color_overlay_shader.r = 0
    @@color_overlay_shader.g = 0
    @@color_overlay_shader.b = 0
    
    if @character1['dodge'] && @character1['super_armor']
      v = rand*0.3+0.45
      @@color_overlay_shader.r = v+rand*0.15
      @@color_overlay_shader.g = v
      @@color_overlay_shader.b = v
    elsif @character1['dodge']
      v = rand*0.3+0.45
      @@color_overlay_shader.r = v
      @@color_overlay_shader.g = v
      @@color_overlay_shader.b = v
    elsif @character1['super_armor']
      v = rand*0.15+0.4
      @@color_overlay_shader.r = v
    elsif @character1['animation_id'].match(/hurt|clash/) || @character1['buffer_animation_id'].to_s.match(/hurt|clash/)
      _frames_left = frames_left(@character1)
      #alpha += 50+15*_frames_left
      v = 0.15*_frames_left
      v = Math.tanh(v)
      @@color_overlay_shader.r = v*0.4+v*(_frames_left%6)/30.0
      @@color_overlay_shader.g = v*0.1+v*(_frames_left%6)/30.0
      @@color_overlay_shader.b = v*0.1+v*(_frames_left%6)/30.0
    end
    #@@color_overlay_shader.alpha = (@character1['dodge'] || @character1['super_armor']) ? rand*0.2+0.55 : 0.0
    #update_outline @character1
    @@ground_shadow.draw (@character1['x_q8']>>8)-14, (ground_y_q8>>8)-4, 0, 1, 1, Gosu::Color.argb(shadow_alpha, 60, 0, 0)
    $window.post_process @@color_overlay_shader do #@@outline_shader
      #draw_effects @effects.select { |effect| !effect[:color_scheme] }
      Animation.draw_character @character1
    end
  end
  
  def draw_character2
    shadow_alpha = 110 - (((ground_y_q8-@character2['y_q8'])*7/12)>>8)
    
    #@@color_overlay_shader.alpha = (@character2['dodge'] || @character2['super_armor']) ? rand*0.2+0.55 : 0.0
    @@color_overlay_shader.r = 0
    @@color_overlay_shader.g = 0
    @@color_overlay_shader.b = 0
    
    if @character2['dodge'] && @character2['super_armor']
      v = rand*0.3+0.45
      @@color_overlay_shader.r = v
      @@color_overlay_shader.g = v
      @@color_overlay_shader.b = v
    elsif @character2['dodge']
      v = rand*0.3+0.45
      @@color_overlay_shader.r = v
      @@color_overlay_shader.g = v
      @@color_overlay_shader.b = v+rand*0.15
    elsif @character2['super_armor']
      v = rand*0.15+0.4
      @@color_overlay_shader.b = v
    elsif @character2['animation_id'].match(/hurt|clash/) || @character2['buffer_animation_id'].to_s.match(/hurt|clash/)
      _frames_left = frames_left(@character2)
      #alpha += 50+15*_frames_left
      v = 0.15*_frames_left
      v = Math.tanh(v)
      @@color_overlay_shader.b = v*0.5+v*(_frames_left%6)/30.0
      @@color_overlay_shader.g = v*0.0+v*(_frames_left%6)/30.0
      @@color_overlay_shader.r = v*0.1+v*(_frames_left%6)/30.0
    end
    #@@color_overlay_shader.alpha = @character2['dodge'] ? rand*0.2+0.55 : 0.0
    #$window.post_process @@color_overlay_shader, @invert_shader, @@outline_shader do
    #update_outline @character2
    @@ground_shadow.draw (@character2['x_q8']>>8)-14, (ground_y_q8>>8)-4, 1, 1, 1, Gosu::Color.argb(shadow_alpha, 0, 0, 60)
    $window.post_process @@color_shader, @@color_overlay_shader do #@@outline_shader
      
      #draw_effects @effects.select { |effect| effect[:color_scheme] }
      Animation.draw_character @character2
    end
  end
  
  def draw_projectiles
    @projectiles.each do |projectile|
      case projectile["parent_id"]
      when 1
        Animation.draw_character projectile
      when 2
        $window.post_process @@color_shader do
          Animation.draw_character projectile
        end
      else
        $window.post_process @@clash_shader do
          Animation.draw_character projectile
        end
      end
      
    end
  end
end