module Shield
  class << self
    def draw store
      if store['shield']        
        image, x, y = draw_data(store)
        
        image.draw x-16, y-16, 0, 1, 1, 0x88FF5555#, :additive
      end
    end
    
    def draw_data store
      shield_sprite_sheet = SPRITE_SHEETS[store['entity_class']]['shield'] #!!!
      scale = store['shield_hp'].to_f / store['shield_max_hp'].to_f
      scale = 0.0 if scale < 0.0
      image_index = (shield_sprite_sheet['images'].length - 1) * (1.0-scale)
      image       = shield_sprite_sheet['images'][image_index]
      
      x = store['x_q8'] >> 8
      y = store['y_q8'] >> 8
      z = 0
      
      body_center_x = 0
      body_center_y = 14
      
      return image, x-body_center_x, y-body_center_y
    end
  end
end