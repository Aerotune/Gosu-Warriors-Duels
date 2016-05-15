require 'filewatcher'

module ResourceFileWatcher
  def self.watch!
    Thread.abort_on_exception = true
    Thread.new do
      FileWatcher.new('./app/**/*.rb').watch do |filename, event|
        case event
        when :new, :changed
          puts "load #{filename} at #{Time.now}..."
          load filename
        else
          warn "Don't know what to do for #{event.inspect} #{filename}"
        end
      end
    end
    
    Thread.new do
      FileWatcher.new(CHARACTER_STATS_PATHS).watch do |filename, event|
        case event
        when :new, :changed
          puts "Updating character stats #{filename} at #{Time.now}..."
          CharacterStatsLoader.load_character_stats! filename
        else
          warn "Don't know what to do for #{event.inspect} #{filename}"
        end
      end
    end
    
    Thread.new do
      FileWatcher.new(ANIMATION_CLASS_PATHS).watch do |filename, event|
        case event
        when :new, :changed
          puts "Updating animation #{filename} at #{Time.now}..."
          AnimationLoader.load_animation! filename
        else
          warn "Don't know what to do for #{event.inspect} #{filename}"
        end
      end
    end
    
    Thread.new do
      FileWatcher.new(FRAME_EVENTS_PATHS).watch do |filename, event|
        case event
        when :new, :changed
          puts "Updating frame events #{filename} at #{Time.now}..."
          AnimationLoader.load_frame_event! filename
        else
          warn "Don't know what to do for #{event.inspect} #{filename}"
        end
      end
    end
    
    Thread.new do
      FileWatcher.new(HIT_EFFECTS_PATHS).watch do |filename, event|
        case event
        when :new, :changed
          puts "Updating hit effects #{filename} at #{Time.now}..."
          AnimationLoader.load_hit_effect! filename
        else
          warn "Don't know what to do for #{event.inspect} #{filename}"
        end
      end
    end
  end
end