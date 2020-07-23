class Monster
  CAN_MOVE_STATES         = [ :walking, :running, :jumping_up, :jumping_down ]

  GRAVITY                 = -0.4
  JUMP_STRENGTH           = 4

  GROUND_COLLISION_WIDTH  = 1

  attr_reader :x, :y, :dx, :dy

  def initialize(animation,animation_offset,start_x,start_y,width,height,fsm,children)
    @x,  @y               = start_x, start_y
    @dx, @dy              = 0, 0

    @width                = width
    @height               = height

    @facing_right         = false
    @animation            = character_animation
    @animation_offset     = animation_offset

    @machine              = fsm  

    @children             = children
  end

  def update(args)
    @children.each { |child| child.update(args) }
    @machine.update(args.inputs.keyboard)

    # --- Horizontal movement :
    @dx = 0
    if CAN_MOVE_STATES.include? @machine.current_state then
      # AI code that moves the monster, in reliation to @machine
    end

    # --- Vertical movement :
    @dy += GRAVITY

    # Ground collisions :
    collision_box             = [ @x - ( @width >> 1 ),
                                  @y,
                                  @width,
                                  @height ]

    bottom_left_new_position  = [ @x - ( @width >> 1 ) + @dx, @y + @dy ]
    bottom_right_new_position = [ @x + ( @width >> 1 ) + @dx, @y + @dy ]

    tiles_offset              = ( args.state.ground.position + @x ).div 8
    center_tile_index         = ( @x % 8 ) + tiles_offset
    collision_range           = ( center_tile_index - GROUND_COLLISION_WIDTH )..( center_tile_index + GROUND_COLLISION_WIDTH )
    collision_range.map do |x|
      ground_box_x  = x * 8 - args.state.ground.position
      ground_box_y  = args.state.ground.collision_tiles[x % args.state.ground.collision_tiles.length] * 8
      ground_box    = [ ground_box_x,
                        ground_box_y,
                        8,
                        8 ]

      Debug::draw_box ground_box, [ 255, 0, 255, 255 ] if args.state.debug_mode == 1

      # Checking collisions for the bottom left corner :
      @dx = ground_box_x + 8 - ( @x - ( @width >> 1 ) - 1)  if point_in_rect( [ @x - ( @width >> 1 ) + @dx, @y + 1   ], ground_box )
      @dy = ground_box_y + 8 - @y                           if point_in_rect( [ @x - ( @width >> 1 ),       @y + @dy ], ground_box )

      # Checking collisions for the bottom right corner :
      @dx = ground_box_x - ( @x + ( @width >> 1 ) + 1 )     if point_in_rect( [ @x + ( @width >> 1 ) + @dx, @y + 1   ], ground_box )
      @dy = ground_box_y + 8 - @y                           if point_in_rect( [ @x + ( @width >> 1 ),       @y + @dy ], ground_box )
    end
  end

  def point_in_rect(point,rect)
    point[0] >= rect[0]           &&
    point[0] <= rect[0] + rect[2] &&
    point[1] >= rect[1]           &&
    point[1] <= rect[1] + rect[3]
  end

  def render
    @children.map { |child| child.render } + @animation.frame_at( @x + @animation_offset[@facing_right][0], @y, !@facing_right )
  end

  def serialize
    {}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
