class HPBar
  attr_accessor :max_hp
  
  def initialize
    @x = 65 / 3 * SCALE
    @y = 450 / 3 * SCALE
    @z = 0
    @width = 344 / 3 * SCALE
    @height = 20 / 3 * SCALE
    @background_color = 0xFF222222
    @hp = 800
    @max_hp = 800
    @bar_width = 0.0
    @estimate_width = 0.0
  end
  
  def update hp, damage_estimate
    @hp = hp
    @damage_estimate = damage_estimate
  end
  
  def draw
    draw_background
    draw_bar
  end
  
  def draw_background
    $window.draw_quad \
    @x, @y, @background_color,
    @x+@width, @y, @background_color,
    @x+@width, @y+@height, @background_color,
    @x, @y+@height, @background_color,
    @z
  end
  
  def draw_bar
    factor = @hp/@max_hp.to_f
    color = Gosu::Color.argb(255, 230, 0, 0)
    
    if factor >= 1.0
      factor = 1.0
    end
    
    factor = 0.0 if factor < 0.0
    
    color.red = 155 + factor * 100
    bar_width = factor*@width
    
    ## Low pass filter the width of the bar
    @bar_width += (bar_width - @bar_width)*0.075
    
    $window.draw_quad \
    @x, @y, color,
    @x+@bar_width, @y, color,
    @x+@bar_width, @y+@height, color,
    @x, @y+@height, color,
    @z
    
    if bar_width > @bar_width
      change_color = 0xFF55FF55
    else
      change_color = 0xFFFFFFFF
    end
    
    estimate_factor = (@hp-@damage_estimate.to_f)/@max_hp.to_f
    estimate_factor = 1.0 if estimate_factor >= 1.0
    estimate_factor = 0.0 if estimate_factor < 0.0
    new_estimate_width = estimate_factor*@width
    #@estimate_width = new_estimate_width
    if new_estimate_width < @estimate_width
      @estimate_width += ((new_estimate_width)-@estimate_width)*0.63
    else
      @estimate_width = new_estimate_width
    end
  
    if @estimate_width > @bar_width
      estimate_color = 0xFF000000
    else
      estimate_color = 0xFFFFEEEE
    end
    
    ## draw the estimate
    if @estimate_width < @bar_width
      $window.draw_quad \
      @x+@estimate_width, @y, estimate_color,
      @x+@bar_width, @y, estimate_color,
      @x+@bar_width, @y+@height, estimate_color,
      @x+@estimate_width, @y+@height, estimate_color,
      @z
    end
    
    ## draw the change
    $window.draw_quad \
    @x+bar_width, @y, change_color,
    @x+@bar_width, @y, change_color,
    @x+@bar_width, @y+@height, change_color,
    @x+bar_width, @y+@height, change_color,
    @z
  end
end