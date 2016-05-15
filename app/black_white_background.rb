class BlackWhiteBackground
  def initialize
    #@invert2_shader = Ashton::Shader.new fragment: './invert2.frag'
  end
  
  def draw
    #draw_center_beam
    #half_flip
    $window.fill 0x88FFFFFF
  end
  
  def half_flip
    v1 =( Math.tanh(Math.sin(Time.now.to_f*0.13)*6.0)+1.0)/2.0
    v2 =( Math.tanh(Math.cos(Time.now.to_f*0.13)*6.0)+1.0)/2.0
    
    v = (v1 + v2) * 0.5
    
    @invert2_shader.factor = v
    $window.post_process @invert2_shader do
      center = $window.width/2.0
      color = 0xFFFFFFFF
      x1 = center
      x2 = center+$window.width
      z = 0
      $window.fill 0xFF000000
      $window.draw_quad \
      x1, 0, color,
      x1, $window.height, color,
      x2, $window.height, color,
      x2, 0, color,
      z
    end
  end
  
  def draw_center_beam
    v1 =( Math.tanh(Math.sin(Time.now.to_f*0.13)*6.0)+1.0)/2.0
    v2 =( Math.tanh(Math.cos(Time.now.to_f*0.13)*6.0)+1.0)/2.0
    
    v = (v1 + v2) * 0.5
    #v =( Math.tanh(Math.sin(Time.now.to_f*0.8)*10.0)+1.0)/2.0
    @invert2_shader.factor = v
    $window.post_process @invert2_shader do
      center = $window.width/2.0
      color = 0xFFFFFFFF
      x1 = center-80
      x2 = center+80
      z = 0
      $window.fill 0xFF000000
      $window.draw_quad \
      x1, 0, color,
      x1, $window.height, color,
      x2, $window.height, color,
      x2, 0, color,
      z
    end
  end
  
  def draw_daycycle
    v =( Math.tanh(Math.sin(Time.now.to_f*0.8)*10.0)+1.0)/2.0
    v = 0.0 if v < 1.0/255
    v = 1.0 if v > 1.0 - 1.0/255
    
    
    $window.fill Gosu::Color.argb(255, v*255, v*255, v*255)
  end
  
  def draw_beams
    @time = Math.sin(Time.now.to_f*0.1)*900.0
    
    width = $window.width/5
    
    3.times do |offset|
      draw_beam ((@time + offset*width*2) % ($window.width+width)), width
    end
    
  end
  
  def draw_beam x, width
    x -= width
    color = 0xFFFFFFFF
    z = 0
    
    $window.fill 0xFF000000
    $window.draw_quad \
    x, 0, color,
    x, $window.height, color,
    x+width, $window.height, color,
    x+width, 0, color,
    z
  end
end