class Effect
  attr_reader :x, :y,
              :width, :height

  def initialize(animation,x,y,width,height)
    @animation      = animation
    @x, @y          = x, y
    @width, @height = width, height
  end

  def update
    @animation.update
  end

  def render(args,flipped=false)
    @animation.frame_at( @x - args.state.ground.position - @width, @y, flipped )
  end
end
    
