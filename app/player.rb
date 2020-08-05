class Player
  CAN_MOVE_STATES         = [ :walking, :running, :jumping_up, :jumping_down ]

  GRAVITY                 = -0.4
  JUMP_STRENGTH           = 4

  GROUND_COLLISION_WIDTH  = 1

  RUNNING_SPEED           = 1
  RECOIL                  = -8

  RECOVERY_TIME           = 10
  PUSH_BACK_SPEED         = 2

  GUN_HEIGHT              = 8 # in pixels
  TILE_SIZE               = 8 # in pixels

  attr_reader :x, :y, :dx, :dy

  def initialize(character_animation,weapon_animation,animation_offset,start_x,start_y,width,height,weapons,fsm)
    @x,  @y               = start_x, start_y
    @dx, @dy              = 0, 0

    @width                = width
    @height               = height

    @facing_right         = true
    @character_animation  = character_animation
    @weapon_animation     = weapon_animation
    @animation_offset     = animation_offset

    @weapons              = weapons
    @current_sword        = 0
    @current_weapon       = @current_sword

    @hit                  = false
    @recovery_time        = 0
    @machine              = fsm
    @machine.set_parent self
  end

  def update(args)
    @machine.update(args)
    #puts @machine.current_state
    #puts "position: #{x};#{@y} - displacement: #{@dx};#{@dy}"

    # --- Switching weapons :
    if args.inputs.keyboard.key_down.w then
      #@current_weapon         = ( @current_weapon + 1 ) % @weapons.length
      @current_sword          = ( @current_weapon + 1 ) % ( @weapons.length - 1 ) # last weapon is the gun
      @current_weapon         = @current_sword
      @weapon_animation.path  =  @weapons[@current_weapon][:path]
    end

    # --- Horizontal movement :
    #@dx = 0
    #case @machine.current_state
    #when :walking, :running, :jumping_up, :jumping_down
    #  if args.inputs.keyboard.key_held.right then
    #    @facing_right   = true
    #    @dx             = 1
    #  elsif args.inputs.keyboard.key_held.left then
    #    @facing_right   = false
    #    @dx             = -1
    #  end

    #when :hit
    #  @recovery_timer -= 1
    #  @dx              = @facing_right ? -PUSH_BACK_SPEED : PUSH_BACK_SPEED

    #end
    case @machine.current_state
    when :hit
      @recovery_timer -= 1
      @dx              = @facing_right ? -PUSH_BACK_SPEED : PUSH_BACK_SPEED

    when :swing
      @dx = 0

    when :shoot
      @dx = RECOIL

    else
      @dx = RUNNING_SPEED

    end


    # --- Vertical movement :
    @dy += GRAVITY

    # --- Enemy collisions :
    hit_box                   = [ @x - ( @width >> 1 ),
                                  @y,
                                  @width,
                                  @height ]

    args.state.monsters.each do |monster|
      unless [ :dying, :dead ].include? monster.current_state then
        monster_hit_box = [ monster.x - ( monster.width >> 1 ) - args.state.ground.position,
                            monster.y,
                            monster.width,
                            monster.height ]

        if hit_box.intersect_rect? monster_hit_box then
          args.outputs.labels << [ 20, 660, "hit!!!!", 255, 255, 255, 255 ]
          @machine.set_current_state :hit
          @recovery_timer = RECOVERY_TIME
          break
        end
      end
    end

    #--- Ground collisions :
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

    # --- Weapons collisions :
    #if @weapons[@current_weapon][:animation] == :sword_attack && @machine.current_state == :swing then
    if @machine.current_state == :swing then
      collision_index   = @weapon_animation.frame_index
      weapon_collision  = @weapons[@current_weapon][:collisions][collision_index]
      unless weapon_collision[0].nil? then
        weapon_hit_box_x    = weapon_collision[0] - ( weapon_collision[2] >> 1 ) + @x + @animation_offset[@facing_right][0]
        weapon_hit_box_y    = weapon_collision[1] - ( weapon_collision[2] >> 1 ) + @y
        weapon_hit_box_size = weapon_collision[2]
        weapon_hit_box      = [ weapon_hit_box_x, weapon_hit_box_y, weapon_hit_box_size, weapon_hit_box_size ]
        
        Debug::draw_hit_box weapon_hit_box, [ 255, 0, 0, 255 ] if args.state.debug_mode == 1

        args.state.monsters.each do |monster|
          unless [:hit, :dying, :dead].include? monster.current_state then
           monster_hit_box = [ monster.x - ( monster.width >> 1 ) - args.state.ground.position,
                               monster.y,
                               monster.width,
                               monster.height ]
           monster.current_state = :hit if weapon_hit_box.intersect_rect? monster_hit_box
           monster.hit @weapons[@current_weapon][:damage]
          end
        end
      end

    elsif @machine.current_state == :shoot && @done_shooting == false then
      bullet_x = 2 
      while bullet_x <= 8 do
        # Testing monsters first... :
        bullet_hit_box  = [ bullet_x * 8, @y + GUN_HEIGHT, 8, 2 ]
        args.state.monsters.each do |monster|
          monster_hit_box = [ monster.x - ( monster.width >> 1 ) - args.state.ground.position,
                              monster.y,
                              monster.width,
                              monster.height ]

          if bullet_hit_box.intersect_rect? monster_hit_box then
            monster.current_state = :hit
            args.state.effects << Effect::player_bullet_impact( monster.x - ( monster.width >> 1 ), @y )
            @done_shooting = true
            break
          end
        end

        break if @done_shooting

        # ... then testing tiles :
        tile_x  = args.state.ground.position.div(8) + bullet_x
        tile_y  = args.state.ground.collision_tiles[tile_x % args.state.ground.collision_tiles.length]

        if @y == tile_y * 8 then
          args.state.effects << Effect::player_bullet_impact( bullet_x * 8 + args.state.ground.position - ( args.state.ground.position % 8 ), tile_y * 8 )
          @done_shooting = true
          break
        end

        bullet_x += 1
      end

    else
      @done_shooting = false if @machine.current_state != :shoot

    end

    # --- Updates :
    @y  += @dy
    
    @character_animation.update
    @weapon_animation.update
  end

  def point_in_rect(point,rect)
    point[0] >= rect[0]           &&
    point[0] <= rect[0] + rect[2] &&
    point[1] >= rect[1]           &&
    point[1] <= rect[1] + rect[3]
  end

  def render
    [ @character_animation.frame_at( @x + @animation_offset[@facing_right][0], @y, !@facing_right ),
      @weapon_animation.frame_at(    @x + @animation_offset[@facing_right][0], @y, !@facing_right ) ]
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
