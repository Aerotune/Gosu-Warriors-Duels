class CharacterSelect
  def initialize
    @font = Gosu::Font.new $window, 'arial', 16
    @cursor = Gosu::Image.new $window, './resources/cursor.png', false
    @selections = ["swordsman", "punch_man", "gunner", "puma"]
    @character1_selection_index = 0
    @character2_selection_index = 0
    
  end
  
  def button_down id
    return
    case id
    when Gosu::KbEscape; $window.control_setup.reset!; $window.state = $window.control_setup; 
    when $window.control_setup.character1_keys.key("attack"); @p1_ready = true
    when $window.control_setup.character2_keys.key("attack"); @p2_ready = true
    when $window.control_setup.character2_keys.key("up");    @p2_ready = false; @character2_selection_index = (@character2_selection_index-1) % @selections.length
    when $window.control_setup.character2_keys.key("down");  @p2_ready = false; @character2_selection_index = (@character2_selection_index+1) % @selections.length
    when $window.control_setup.character1_keys.key("up");    @p1_ready = false; @character1_selection_index = (@character1_selection_index-1) % @selections.length
    when $window.control_setup.character1_keys.key("down");  @p1_ready = false; @character1_selection_index = (@character1_selection_index+1) % @selections.length
    end
  end
  
  def button_up id
    
  end
  
  def update
    start_game!
    return
    $music.stop if $music
    if @p1_ready && @p2_ready
      @p1_ready = false
      @p2_ready = false
      start_game! 
    end
  end
  
  def start_game!
    $window.state = Game.new character1_entity, character2_entity
  end
  
  def character1_entity
    @selections[@character1_selection_index]
  end
  def character2_entity
    @selections[@character2_selection_index]
  end
  
  def draw
    return
    @selections.each_with_index do |selection, selection_index|
      @font.draw selection.gsub('_', ' ').capitalize, 200, 10+20*selection_index, 0
    end
    
    x = 210+@font.text_width(@selections[@character1_selection_index])
    y = 10+20*@character1_selection_index
    z = 0
    color = @p1_ready ? 0xFFFFFFFF : 0xFFEE0000
    @cursor.draw x, y, z, 2.0, 2.0, color, :additive
    
    x = 190
    y = 10+20*@character2_selection_index
    z = 0
    color = @p2_ready ? 0xFFFFFFFF : 0xFF0000EE
    @cursor.draw x, y, z, -2.0, 2.0, color, :additive
    
    #draw_cursor @character1_selection_index, 0xFFFF0000
    #draw_cursor @character2_selection_index, 0xFF0000FF
  end
  
  #def draw_cursor selection_index, color
  #  x = 200+@font.text_width(@selections[selection_index])
  #  y = 10+20*selection_index
  #  z = 0
  #  @cursor.draw x, y, z, 2.0, 2.0, color, :additive
  #end
end