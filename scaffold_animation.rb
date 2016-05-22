require 'gosu'
$window = Gosu::Window.new(800,600,false)
require_relative File.join 'app', 'constants'
require_relative File.join 'app', 'paths'
require_relative File.join 'app', 'sprite_sheet'

entity_class     = ARGV[0] || raise("Missing ARGV[0] (entity_class)")
animation_id     = ARGV[1] || raise("Missing ARGV[1] (animation_id)")
sprite_sheet_id  = ARGV[2] || raise("Missing ARGV[2] (sprite_sheet_id)")
animation_fps    = (ARGV[3] || 15).to_i

supported_fps = [1, 2, 3, 4, 5, 6, 10, 15, 20, 30, 60]
raise "Supported FPS: #{supported_fps}" unless supported_fps.include? animation_fps.abs
frame_multiplier = GAME_FPS / animation_fps.abs

frames = []

sprite_sheet_images, tile_width, tile_height, anchor_point = SpriteSheet.load entity_class, sprite_sheet_id
case anchor_point
when /bot/
  anchor_x = tile_width / 2
  anchor_y = tile_height
when 'top_left'
  anchor_x = 0
  anchor_y = 0
when 'center'
  anchor_x = tile_width / 2
  anchor_y = tile_width / 2
else
  warn "Unknown anchor_point: #{anchor_point}. Using top_left."
  anchor_x = 0
  anchor_y = 0
end

add_frame_index = proc do |sprite_index|
  frame_multiplier.times do
    frames << {
      'sprite_sheet_id' => sprite_sheet_id,
      'sprite_index' => sprite_index,
      'anchor_x' => anchor_x,
      'anchor_y' => anchor_y
    }
  end
end

indexes = (0...sprite_sheet_images.length)
if animation_fps > 0
  indexes.each &add_frame_index
else
  indexes.reverse_each &add_frame_index
end

animations_dir = File.join(ANIMATIONS_DIR, entity_class)
animation_file_path = File.join(animations_dir, "#{animation_id}.json")

require 'json'
require 'fileutils'
animation_json = JSON.pretty_generate 'hit_id' => animation_id, 'before_frame_events' => [], 'frames' => frames
FileUtils.mkdir_p animations_dir
File.open animation_file_path, 'w+' do |f|
  f << animation_json
end
puts ""
puts "Scaffolded '#{animation_id}' animation for #{entity_class}"
puts "  Path: #{animation_file_path}"
puts ""
