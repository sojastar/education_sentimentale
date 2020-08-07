class WalkingMonster < Monster

  # ---=== CONSTANTS : ===---
  CAN_MOVE_STATES         = [ :walking, :running, :jumping_up, :jumping_down ]
  
  GRAVITY                 = -0.4
  JUMP_STRENGTH           = 4

  GROUND_COLLISION_WIDTH  = 1


  # ---=== UPDATE : ===---
  def update(args)
    #$gtk.args.outputs.labels << [ 20, 600, "#{@x},#{y}", 255, 255, 255, 255 ]
    @children.each { |child| child.update(args) } unless @children.nil?
    @machine.update(args)
    
    # --- Check for death :
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

    when :stun, :hit
      @recovery_timer  -= 1
      @dx               = @facing_right ? -@push_back_speed : @push_back_speed

    end

    # Player collisions :
    player                    = args.state.player
    player_hit_box            = [ player.x - ( player.width >> 1 ),
                                  player.y,
                                  player.width,
                                  player.height ]

    @machine.set_current_state :stun if hit_box(args.state.ground.position).intersect_rect? player_hit_box


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
      @dx = ground_box_x + 8 - ( @x - ( @width >> 1 ) - 1)  if point_in_rect?( [ @x - ( @width >> 1 ) + @dx, @y + 1   ], ground_box )
      @dy = ground_box_y + 8 - @y                           if point_in_rect?( [ @x - ( @width >> 1 ),       @y + @dy ], ground_box )

      # Checking collisions for the bottom right corner :
      @dx = ground_box_x - ( @x + ( @width >> 1 ) + 1 )     if point_in_rect?( [ @x + ( @width >> 1 ) + @dx, @y + 1   ], ground_box )
      @dy = ground_box_y + 8 - @y                           if point_in_rect?( [ @x + ( @width >> 1 ),       @y + @dy ], ground_box )
    end

    @x += @dx
    @y += @dy

    @animation.update
  end

  def hit_box(offset)
    [ @x - ( @width >> 1 ) - offset, @y, @width, @height ]
  end
end
