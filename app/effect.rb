class Effect
  attr_reader :x, :y,
              :width, :height,
              :animation

  def initialize(animation,x,y,width,height)
    @animation      = animation
    @x, @y          = x, y
    @width, @height = width, height
  end

  def update
    @animation.update
  end

  def render(args,flipped=false)
    @animation.frame_at( @x - args.state.ground.position, @y, flipped )
  end

  def self.player_bullet_impact(x,y)
    frames    = { impact: { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0] ],
                            mode:               :once,
                            speed:              4,
                            flip_horizontally:  false,
                            flip_vertically:    false } }

    animation = Animation.new 'sprites/impact.png',
                              16,
                              16,
                              frames,
                              :impact

    Effect::new animation, x - 16, y, 16, 16
  end
end
