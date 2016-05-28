class Input
  def initialize character, key_layout
    @character = character
    @key_layout = key_layout
    @prev_key_down_time = Hash.new {|h,k| h[k] = -256}
    @key_down_time = Hash.new {|h,k| h[k] = -256}
    @key_up_time   = Hash.new {|h,k| h[k] = -256}
  end
  
  def button_down time, id
    key = @key_layout[id]
    if key
      @prev_key_down_time = @key_down_time[key]
      if key == "block" && (time - @key_down_time["tech"]) >= 40
        @key_down_time["tech"] = time
      end
      @key_down_time[key] = time
    end
  end
  
  def reset_tech
    @key_down_time["tech"] = -256
  end
  
  def button_up time, id
    key = @key_layout[id]
    @key_up_time[key] = time if key
  end
  
  def double_tap? time, key
    (time-@key_down_time[key]) < 6 && (@key_down_time[key]-@prev_key_down_time) < 12
  end
  
  def key_down? key
    case key
    when "forward"
      key2 = @character['factor_x'] == 1 ? "right" : "left"
      $window.button_down? @key_layout.key(key2)
    when "backward"
      key2 = @character['factor_x'] == -1 ? "right" : "left"
      $window.button_down? @key_layout.key(key2)
    else
      $window.button_down? @key_layout.key(key)
    end
  end
  
  def key_down_time key
    case key
    when "forward"
      key2 = @character['factor_x'] == 1 ? "right" : "left"
      @key_down_time[key2]
    when "backward"
      key2 = @character['factor_x'] == -1 ? "right" : "left"
      @key_down_time[key2]
    else
      @key_down_time[key]
    end
  end
  
  def key_up_time key
    case key
    when "forward"
      key2 = @character['factor_x'] == 1 ? "right" : "left"
      @key_up_time[key2]
    when "backward"
      key2 = @character['factor_x'] == -1 ? "right" : "left"
      @key_up_time[key2]
    else
      @key_up_time[key]
    end
  end
  
  def latest_key_down keys
    forward = nil
    backward = nil
    
    keys = keys.map do |key|
      case key
      when "forward"
        forward = @character['factor_x'] == 1 ? "right" : "left"
      when "backward"
        backward = @character['factor_x'] == -1 ? "right" : "left"
      else
        key
      end
    end
    
    max = keys.select {|key| key_down? key}.max_by { |key| @key_down_time[key] }
    
    if forward && max == forward
      return "forward"
    end
    
    if backward && max == backward
      return "backward"
    end  
    
    return max
  end
end
