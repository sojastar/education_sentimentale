class Effect
  attr_reader :x, :y,
              :width, :height

  def initialize(animation,x,y,width,height)
    @animation      = animation
    @x, @y          = x, y
    @width, @height = width, height
  end

  def update(args)
  end
end
    
