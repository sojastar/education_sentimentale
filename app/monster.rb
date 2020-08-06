class Monster
  CAN_MOVE_STATES         = [ :walking, :running, :jumping_up, :jumping_down ]

  GRAVITY                 = -0.4
  JUMP_STRENGTH           = 4

  GROUND_COLLISION_WIDTH  = 1

  attr_reader :x, :y,
              :width, :height,
              :dx, :dy,
              :health

  def initialize(animation,animation_offset,start_x,start_y,width,height,running_speed,push_back_speed,health,fsm,parent,children)
    @x,  @y               = start_x, start_y
    @dx, @dy              = 0, 0

    @width                = width
    @height               = height

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

  def update(args)
    #$gtk.args.outputs.labels << [ 20, 600, "#{@x},#{y}", 255, 255, 255, 255 ]
    @children.each { |child| child.update(args) } unless @children.nil?
    @machine.update(args)
    
    # --- Check for death :
    #if @health <= 0 then
    if @machine.current_state == :dying then
      @animation.update
      return
    end

    # --- Horizontal movement :
    @dx = 0
    case @machine.current_state
    when :walking, :running, :jumping_up, :jumping_down
      # AI code that moves the monster, in relation to @machine
      @tick            += 1
      if @tick == @running_speed then
        @dx   = @facing_right ? 1 : -1
        @tick = 0
      end

    when :hit
      @recovery_timer  -= 1
      @dx               = @facing_right ? -@push_back_speed : @push_back_speed

    end

    # Player collisions :
    player                    = args.state.player
    player_hit_box            = [ player.x - ( player.width >> 1 ),
                                  player.y,
                                  player.width,
                                  player.height ]

    monster_hit_box           = [ @x - ( @width >> 1 ),
                                  @y,
                                  @width,
                                  @height ]

    if monster_hit_box.intersect_rect? player_hit_box then
      $gtk.args.outputs.labels << [ 20, 600, 'monster hit!!!', 255, 255, 255, 255 ]
    end


    # --- Vertical movement :
    @dy += GRAVITY

    # Ground collisions :
    bottom_left_new_position  = [ @x - ( @width >> 1 ) + @dx, @y + @dy ]
    bottom_right_new_position = [ @x + ( @width >> 1 ) + @dx, @y + @dy ]

    center_tile_index         = @x.div 8
    collision_range           = ( center_tile_index - GROUND_COLLISION_WIDTH )..( center_tile_index + GROUND_COLLISION_WIDTH )
    collision_range.map do |x|
      ground_box_x  = x * 8
      ground_box_y  = args.state.ground.collision_tiles[x % args.state.ground.collision_tiles.length] * 8
      ground_box    = [ ground_box_x,
                        ground_box_y,
                        8,
                        8 ]

      Debug::draw_box ground_box, [ 0, 0, 255, 255 ] if args.state.debug_mode == 1

      # Checking collisions for the bottom left corner :
      @dx = ground_box_x + 8 - ( @x - ( @width >> 1 ) - 1)  if point_in_rect( [ @x - ( @width >> 1 ) + @dx, @y + 1   ], ground_box )
      @dy = ground_box_y + 8 - @y                           if point_in_rect( [ @x - ( @width >> 1 ),       @y + @dy ], ground_box )

      # Checking collisions for the bottom right corner :
      @dx = ground_box_x - ( @x + ( @width >> 1 ) + 1 )     if point_in_rect( [ @x + ( @width >> 1 ) + @dx, @y + 1   ], ground_box )
      @dy = ground_box_y + 8 - @y                           if point_in_rect( [ @x + ( @width >> 1 ),       @y + @dy ], ground_box )
    end

    @x += @dx
    @y += @dy

    @animation.update
  end

  def current_state
    @machine.current_state
  end

  def current_state=(next_state)
    @machine.set_current_state next_state
  end

  def hit(damage)
    @health -= damage
  end

  def point_in_rect(point,rect)
    point[0] >= rect[0]           &&
    point[0] <= rect[0] + rect[2] &&
    point[1] >= rect[1]           &&
    point[1] <= rect[1] + rect[3]
  end

  def render(args)
    if @children.nil? then
      @animation.frame_at( @x + @animation_offset[@facing_right][0] - args.state.ground.position, @y, @facing_right )
    else
      [ @animation.frame_at( @x + @animation_offset[@facing_right][0] - args.state.ground.position, @y, @facing_right ) ] + @children.map { |child| child.render }
    end
  end

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
