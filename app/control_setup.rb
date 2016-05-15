$gosu_keys = {}

Gosu.constants.each do |constant|
  value = Gosu.const_get(constant)
  $gosu_keys[constant] = value if value.kind_of? Integer
end

$gosu_keys.delete :MAJOR_VERSION
$gosu_keys.delete :MINOR_VERSION
$gosu_keys.delete :MAX_TEXTURE_SIZE
$gosu_keys.delete :POINT_VERSION

class ControlSetup
  attr_reader :character1_keys, :character2_keys
  
  def initialize
    @font = Gosu::Font.new $window, 'arial', 22
    
    @controls = [
      "up", "right", "down", "left", "jump", "attack", "special", "block"
    ]
    
    reset!
  end
  
  def reset!
    @character1_keys = {}
    @character2_keys = {}
    
    @unset_controls = @controls.dup
    @current_character_keys = @character1_keys
    
    @state = @character1_keys
  end
  
  def button_down id
    if id == Gosu::KbEscape
      reset!
      return
    end
    
    if id == Gosu::KbReturn
      @capturing = true
      return
    end
    
    return unless @capturing
    
    key = $gosu_keys.key(id)
    
    source = case key
    when /Kb/; :Kb
    when /Gp0/; :Gp0
    when /Gp1/; :Gp1
    when /Gp2/; :Gp2
    when /Gp3/; :Gp3
    end
    
    @current_character_keys[:source] ||= source
    
    if @current_character_keys[:source] == source
      @current_character_keys[id] = @unset_controls.shift
    end
        
    #puts "Keyboard" if $gosu_keys.key(id).match /Kb/
    #puts "0" if $gosu_keys.key(id).match /Gp0/
    #puts "1" if $gosu_keys.key(id).match /Gp1/
    #puts "2" if $gosu_keys.key(id).match /Gp2/
  end
  
  def button_up id; end
  
  def update
    $music.stop if $music
    update_unset_controls
    if @unset_controls.empty?
      if @current_character_keys == @character1_keys
        @current_character_keys = @character2_keys
        update_unset_controls
      else
        #$window.state = $window.character_select
        $window.state = Game.new 'swordsman', 'swordsman'
      end
    end
  end
  
  def update_unset_controls
    @unset_controls = @controls - @current_character_keys.values
  end
  
  def draw
    if @capturing
      character_number = @current_character_keys == @character1_keys ? 1 : 2
      @font.draw "Set up controls for player #{character_number}", 100, 80, 0
      @font.draw "Press: #{@unset_controls.first}", 100, 80+@font.height, 0
      @font.draw "You can press escape at any time to reset the controls.", 100, 80+@font.height*3, 0
    else
      @font.draw "Press return to start capturing controls settings.", 100, 80, 0
    end
  end
end