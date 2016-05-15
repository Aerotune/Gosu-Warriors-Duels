def write_error_log e  
  log_folder = %w[. logs crash_logs]
  filename = Time.now.strftime('%y-%m-%d_%H_%M_%S') + '.txt'
  
  require 'fileutils'
  FileUtils.mkpath(File.join(*log_folder))
  
  File.open(File.join(*log_folder, filename), 'w') do |f|
    f << "#{e.class}: #{e}"
    if e.respond_to? :backtrace
      f << "\n\t#{e.backtrace.join("\n\t")}"
    end
  end
end

begin
  require 'gosu'
  require 'fileutils'
  require 'texplay'
  require 'ashton'
  require 'pathname'

  Gosu.enable_undocumented_retrofication

  SCALE = 3.0
  DEVELOPMENT = false

  require_relative File.join 'app', 'constants'
  require_relative File.join 'app', 'paths'
  require_relative File.join 'app', 'animation'

  require_relative File.join 'app', 'sprite_sheet'
  require_relative File.join 'app', 'input'

  require_relative File.join 'app', 'factories'
  require_relative File.join 'app', 'hp_bar'
  require_relative File.join 'app', 'shockwave'

  require_relative File.join 'app', 'control_setup'
  require_relative File.join 'app', 'character_select'
  require_relative File.join 'app', 'game'

  if DEVELOPMENT
    require_relative File.join 'app', 'resource_file_watcher'
  end

  class Window < Gosu::Window
    attr_reader :character_select, :control_setup
    attr_accessor :state
  
    def initialize
      $window = self
      #super 840, 480, false
      super (280*SCALE).to_i, (160*SCALE).to_i, false
      require_relative File.join 'app', 'sprite_sheets'
      require_relative File.join 'app', 'animation_loader'
      require_relative File.join 'app', 'character_stats_loader'
    
      AnimationLoader.load_all!
      CharacterStatsLoader.load_all!
    
      if DEVELOPMENT
        ResourceFileWatcher.watch!
      end
    
      @character_select = CharacterSelect.new
      @control_setup = ControlSetup.new
      @state = @control_setup
    end
  
    def button_down id
      @state.button_down id
    end
  
    def button_up id
      @state.button_up id
    end
  
    def update
      @state.update
    end
  
    def draw
      @state.draw
    end
  
    def fill c1, c2=c1, c3=c2, c4=c3
      $window.draw_quad 0, 0, c1,
      0, $window.height, c2,
      $window.width, $window.height, c3,
      $window.width, 0, c4,
      0
    end
  end

  Window.new.show
rescue Exception => e
  write_error_log e
  raise e
end
