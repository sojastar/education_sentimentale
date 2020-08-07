class Monster
  attr_reader :x, :y,
              :width, :height,
              :dx, :dy,
              :health


  # ---=== INITIALIZATION : ===---
  def initialize(animation,animation_offset,start_x,start_y,hit_box_size,hit_box_offset,running_speed,push_back_speed,health,fsm,parent,children)
    @x,  @y               = start_x, start_y
    @dx, @dy              = 0, 0

    @width, @height       = hit_box_size
    @hit_offset           = hit_box_offset

    @facing_right         = false  # monsters usually face left
    @animation            = animation
    @animation_offset     = animation_offset

    @running_speed        = running_speed
    @tick                 = 0

    @health               = health

    @recovery_timer       = 0
    @push_back_speed      = push_back_speed
    @machine              = fsm  
    @machine.set_parent self

    @parent               = parent
    @children             = children
  end


  # ---=== UPDATE : ===---
  def update(args)
    # virtual function ( is it called that in Ruby ? )
  end


  # ---=== RENDERING : ===---
  def render(args)
    if @children.nil? then
      @animation.frame_at( @x + @animation_offset[@facing_right][0] - args.state.ground.position, @y, @facing_right )
    else
      [ @animation.frame_at( @x + @animation_offset[@facing_right][0] - args.state.ground.position, @y, @facing_right ) ] + @children.map { |child| child.render }
    end
  end


  # ---=== UTILITIES : ===---
  def current_state
    @machine.current_state
  end

  def current_state=(next_state)
    @machine.set_current_state next_state
  end

  def hit(damage)
    @health -= damage
  end

  def point_in_rect?(point,rect)
    point[0] >= rect[0]           &&
    point[0] <= rect[0] + rect[2] &&
    point[1] >= rect[1]           &&
    point[1] <= rect[1] + rect[3]
  end


  # ---=== SERIALIZATION : ===---
  def serialize
    { x: @x, y: @y, state: @machine.current_state, clip: @animation.current_clip, facing_right: @facing_right }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
