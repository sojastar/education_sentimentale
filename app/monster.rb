class Monster
  attr_reader :x, :y,
              :width, :height,
              :animation_offset,
              :facing_right,
              :hit_offset,
              :dx, :dy,
              :health,
              :limbs


  # ---=== INITIALIZATION : ===---
  def initialize(animation,animation_offset,start_x,start_y,hit_box_size,hit_box_offset,running_speed,push_back_speed,health,fsm,limbs)
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
    @machine.start

    @limbs                = limbs
  end


  # ---=== RENDER : ===---
  def render(args)
    if @limbs.empty? then
      @animation.frame_at( @x + @animation_offset[@facing_right][0] - args.state.ground.position, @y, @facing_right )
    else
      render_x  = @x + @animation_offset[@facing_right][0] - args.state.ground.position
      [ @animation.frame_at( render_x, @y, @facing_right ) ] + @limbs.map { |limb| limb.render( args, render_x, @y ) }
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

  def limbs_are(status)
    @limbs.each { |limb| limb.set_clip status }
  end

  def randomize_limbs_animations
    @limbs.each { |limb| limb.randomize_animation_frame }
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
