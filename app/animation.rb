module Animation
  class << self
    def draw_character character
      hit_mask, image, draw_x, draw_y, factor_x = draw_data character
      z = 0
      draw_x += 1 if factor_x < 0 # Do this instead of messing with the hit testing
      image.draw draw_x, draw_y, z, factor_x
    end
    
    def collisions character1, character2, &block
      hit_mask1, image1, draw_x1, draw_y1, factor_x1 = draw_data character1
      hit_mask2, image2, draw_x2, draw_y2, factor_x2 = draw_data character2
      
      x1, y1, x2, y2 = bounding_box_overlap? \
        draw_x1, draw_y1, image1.width*factor_x1, image1.height,
        draw_x2, draw_y2, image2.width*factor_x2, image2.height
      
      collisions = {
        clash: [],
        hit1: [],
        hit2: [],
        shield_hit1: [],
        shield_hit2: []
      }
      
      return collisions unless x1
      
      (x1..x2).each do |x|
        (y1..y2).each do |y|
          image1_x = (x - draw_x1) * factor_x1
          image1_y = y - draw_y1
          pixel1 = hit_mask1[image1_x, image1_y]
          next unless pixel1
          
          image2_x = (x - draw_x2) * factor_x2
          image2_y = y - draw_y2
          pixel2 = hit_mask2[image2_x, image2_y]
          next unless pixel2 
          
          if pixel1 == :hit && pixel2 == :hit
            collisions[:clash] << [x, y]
          end
          
          if pixel1 == :hit && pixel2 == :hurt
            if character2['shield']
              collisions[:shield_hit1] << [x, y]
            else
              collisions[:hit1] << [x, y]
            end
          end
          
          if pixel1 == :hurt && pixel2 == :hit 
            if character1['shield']
              collisions[:shield_hit2] << [x, y]
            else
              collisions[:hit2] << [x, y]
            end
          end
          
        end
      end
      
      return collisions
    end
    
    def bounding_box_overlap? x1, y1, w1, h1, x2, y2, w2, h2
      left1 = x1
      right1 = x1 + w1
      left1, right1 = right1, left1 if right1 < left1
      
      top1 = y1
      bottom1 = y1 + h1
      top1, bottom1 = bottom1, top1 if bottom1 < top1
      
      left2 = x2
      right2 = x2 + w2
      left2, right2 = right2, left2 if right2 < left2
      
      top2 = y2
      bottom2 = y2 + h2
      top2, bottom2 = bottom2, top2 if bottom2 < top2
      
      if left1 < (right2) && left2 < (right1) && top1 < (bottom2) && top2 < (bottom1)
        if right2 - left1 < right1 - left2
          left = left1
          right = right2
        else
          left = left2
          right = right1
        end
        
        if bottom2 - top1 < bottom1 - top2
          top = top1
          bottom = bottom2
        else
          top = top2
          bottom = bottom1
        end
        
        return left, top, right, bottom
      end
    end
    
    def anchor_point store
      entity_class = store['entity_class']
      animation_id = store['animation_id']
      frame_index  = store['frame_index']
      
      animations = ANIMATIONS[entity_class] || raise("No animations for entity_class: #{entity_class}")
      animation = animations[animation_id] || raise("No animation with id: #{animation_id}")
      frames = animation['frames']
      frame = frames[frame_index % frames.length]
      
      anchor_points = ANCHOR_POINTS[entity_class] || raise("No ANCHOR_POINTS for entity_class: #{entity_class}")
      anchor_points = anchor_points[animation_id] || raise("No anchor_point with for animation_id: #{animation_id}")
      anchor_point = anchor_points[frame['sprite_index']]
    end
        
    def draw_data store
      entity_class = store['entity_class']
      animation_id = store['animation_id']
      frame_index = store['frame_index']
      factor_x = store['factor_x']
      
      x = store['x_q8']>>8
      y = store['y_q8']>>8
      
      animations = ANIMATIONS[entity_class] || raise("No animations for entity_class: #{entity_class}")
      animation = animations[animation_id] || raise("No animation with id: #{animation_id}")
      frames = animation['frames']
      frame = frames[frame_index % frames.length]

      sprite_sheet_id = frame['sprite_sheet_id']
      sprite_index    = frame['sprite_index']
      sprite_sheets   = SPRITE_SHEETS[entity_class]
      sprite_sheet    = sprite_sheets[sprite_sheet_id] || raise("No spritesheet with id '#{sprite_sheet_id}' for entity class '#{entity_class}'")
      images          = sprite_sheet['images']
      image           = images[sprite_index]
      
      hit_masks       = HIT_MASKS[entity_class]
      hit_mask_frames = hit_masks[sprite_sheet_id]
      hit_mask        = hit_mask_frames[sprite_index]
      #hit_mask = SPRITE_SHEETS[entity_class][sprite_sheet_id]['hit_masks'][sprite_index]
      draw_x = x - frame['anchor_x']*factor_x
      draw_y = y - frame['anchor_y']
      
      return hit_mask, image, draw_x, draw_y, factor_x
    end
  end
end
