require 'json'
require_relative 'paths'
require_relative 'array2d'

SPRITE_SHEETS = {}

Dir[File.join(SPRITE_SHEETS_DIR, '*/')].each do |entity_class_dir|
  entity_class = File.basename(entity_class_dir, '/')
  SPRITE_SHEETS[entity_class] = {}
  
  Dir[File.join(entity_class_dir, '*.png')].each do |sprite_sheet_path|
    sprite_sheet_id = File.basename(sprite_sheet_path, '.png').split('@').first
    sprite_sheet_images, tile_width, tile_height, anchor_point = SpriteSheet.load entity_class, sprite_sheet_id
    
    SPRITE_SHEETS[entity_class][sprite_sheet_id] = {
      'images' => sprite_sheet_images,
      'hit_masks' => nil,
      'tile_width' => tile_width,
      'tile_height' => tile_height
    }
  end  
end

HIT_MASKS = {}
ANCHOR_POINTS = {}

SPRITE_SHEETS.each do |entity_class, sprite_sheets|
  HIT_MASKS[entity_class] = {}
  ANCHOR_POINTS[entity_class] = {}
  sprite_sheets.each do |sprite_sheet_id, data|
    HIT_MASKS[entity_class][sprite_sheet_id] = []
    ANCHOR_POINTS[entity_class][sprite_sheet_id] = []
    
    data['images'].each_with_index do |image, index|
      ANCHOR_POINTS[entity_class][sprite_sheet_id][index] = nil
      hit_mask = Array2d.new image.width, image.height
      
      #image.refresh_cache # !!! if the images don't load or get weird
      image.each do |c, x, y|
        r, g, b, a = *c
        
        if a > 0.0
          if g > 0.0
            hit_mask[x, y] = b > 0.0 ? nil : :hurt
          elsif b > 0.0
           ANCHOR_POINTS[entity_class][sprite_sheet_id][index] = [x, y]
          else
            hit_mask[x, y] = r > 0.0 ? :hit : :hurt
          end
        end
      end
      
      HIT_MASKS[entity_class][sprite_sheet_id][index] = hit_mask
    end
  end
end
