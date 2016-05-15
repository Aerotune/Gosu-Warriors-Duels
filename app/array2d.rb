class Array2d
  attr_reader :width, :height
  
  include Enumerable
  
  def initialize x_length=0, y_length=0
    @array =      Array.new y_length
    @array.map! { Array.new x_length }
    @width  = x_length
    @height = y_length
  end
  
  def [] pos_x, pos_y
    y_slice = @array[pos_y] || []
    y_slice[pos_x]
  end
  alias get []
  
  def []= x, y, value
    @width  = x if x > @width
    @height = y if y > @height
    
    @array[y]    ||= []
    @array[y][x]   = value
  end
  alias set []=
  
  def to_a; @array.dup end
  alias to_ary to_a
  
  def each &block
    @array.each do |slice| next unless slice
      slice.each do |object| next unless object
        block.call object
      end
    end
  end
  
  def each_with_x_y &block
    @array.each_with_index do |slice, y| next unless slice
      slice.each_with_index do |object, x| next unless object
        block.call object, x, y
      end
    end
  end
  
  def self.create_from_array array, width=nil, height=nil
    obj = allocate
    obj.instance_variable_set '@array', array
    if width && height
      obj.instance_variable_set("@width", width)
      obj.instance_variable_set("@height", height)
    else
      obj.send :calculate_width_and_height
    end
    obj
  end
  
  
  protected
  
  
  def calculate_width_and_height
    @height = @array.length
    @width = 0
    @array.each do |slice| next unless slice and slice.length > @width
      @width = slice.length
    end
  end
  
end
