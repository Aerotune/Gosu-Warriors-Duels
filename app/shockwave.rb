class Shockwave
  attr_reader :shader

  def age; (Gosu::milliseconds - @start_time) / 300.0; end
  def dead?; age > 3.0 end

  def initialize(x, y)
    @shader = Ashton::Shader.new fragment: :shockwave, uniforms: {
        shock_params: [12.0, 0.2, 0.08], # Not entirely sure what these represent!
        center: [x, y],
    }
    @start_time = Gosu::milliseconds
  end

  def update
    @shader.time = age
  end
end