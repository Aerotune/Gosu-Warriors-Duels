module SpriteSheet
  class << self
    def load entity_class, sprite_sheet_id
      sprite_sheet_query = File.join(SPRITE_SHEETS_DIR, entity_class, "#{sprite_sheet_id}@*.png")
      dirs = Dir[sprite_sheet_query]
      if dirs.length == 0
        raise "Couldn't find sprite_sheet_id #{sprite_sheet_id} for entity_class #{entity_class}"
      elsif dirs.length > 1
        raise "Conflicting files with same sprite_sheet_id: #{dirs}"
      end
      
      sprite_sheet_path = dirs.first
      sprite_sheet_id, sprite_sheet_meta = File.basename(sprite_sheet_path, '.png').split('@')

      tile_size, anchor_point = sprite_sheet_meta.split('_')
      tile_width, tile_height = tile_size.split('x').map &:to_i
      sprite_sheet_images = Gosu::Image.load_tiles $window, sprite_sheet_path, tile_width, tile_height, true
      
      return sprite_sheet_images, tile_width, tile_height, anchor_point
    end
  end
end
