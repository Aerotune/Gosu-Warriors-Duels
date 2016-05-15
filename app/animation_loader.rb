require 'json'
require_relative 'paths'
require_relative 'sprite_sheets'

ANIMATION_CLASS_PATHS = File.join('resources', 'animations', '*', '*.json')
FRAME_EVENTS_PATHS    = File.join('resources', 'animations', '*', 'frame_events', '*.json')
HIT_EFFECTS_PATHS     = File.join('resources', 'animations', '*', 'hit_effects', '*.json')

ANIMATIONS             = Hash.new { |h,k| h[k] = {} }
ANIMATION_FRAME_EVENTS = Hash.new { |h,k| h[k] = {} }
ANIMATION_HIT_EFFECTS  = Hash.new { |h,k| h[k] = {} }

module AnimationLoader
  def self.load_all!
    Dir[ANIMATION_CLASS_PATHS].each do |animation_path|
      AnimationLoader.load_animation! animation_path
    end

    Dir[FRAME_EVENTS_PATHS].each do |frame_event_path|
      AnimationLoader.load_frame_event! frame_event_path
    end

    Dir[HIT_EFFECTS_PATHS].each do |hit_effect_path|
      AnimationLoader.load_hit_effect! hit_effect_path
    end
  end
  
  def self.load_animation! animation_path
    entity_class = File.basename File.dirname(animation_path)
    animation_id = File.basename(animation_path, '.json')
    animation_data = JSON.parse File.read(animation_path)
    
    ANIMATIONS[entity_class][animation_id] = animation_data
  end
  
  def self.load_frame_event! frame_event_path
    entity_class = File.basename File.dirname File.dirname(frame_event_path)
    frame_event_id = File.basename(frame_event_path, '.json')
    frame_event_data = JSON.parse File.read(frame_event_path)
    
    ANIMATION_FRAME_EVENTS[entity_class][frame_event_id] = frame_event_data
  end
  
  def self.load_hit_effect! hit_effect_path
    entity_class = File.basename File.dirname File.dirname(hit_effect_path)
    hit_effect_id = File.basename(hit_effect_path, '.json')
    hit_effect_data = JSON.parse File.read(hit_effect_path)
    
    ANIMATION_HIT_EFFECTS[entity_class][hit_effect_id] = hit_effect_data
  end
end
