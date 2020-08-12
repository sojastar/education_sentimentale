class Player

  # ---=== CONSTANTS : ===---
  CAN_MOVE_STATES         = [ :walking, :running, :jumping_up, :jumping_down ]

  GRAVITY                 = -0.4
  JUMP_STRENGTH           = 4

  GROUND_COLLISION_WIDTH  = 1

  RUNNING_SPEED           = 1
  RECOIL                  = -8

  RECOVERY_TIME           = 10
  PUSH_BACK_SPEED         = 6

  MAX_LIFE                = 5

  GUN_HEIGHT              = 8 # in pixels
  TILE_SIZE               = 8 # in pixels


  # ---=== ACCESSORS : ===---
  attr_reader :x, :y,
              :width, :height,
              :dx, :dy,
              :health


  # ---=== INITIALIZATION : ===---
  def initialize(character_animation,weapon_animation,animation_offset,start_x,start_y,width,height,health,weapons,fsm)
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

    @health               = health
    @hit                  = false
    @recovery_time        = 0

    @machine              = fsm
    @machine.set_parent self
    @machine.start
  end


  # ---=== UPDATE : ===---
  def update(args)
    # --- State Machine :
    @machine.update(args)
    #puts @machine.current_state
    #puts "position: #{x};#{@y} - displacement: #{@dx};#{@dy}"


    # --- Switching weapons :
    if args.inputs.keyboard.key_down.w || args.inputs.controller_one.key_down.r1 then
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

    when :shifting, :dying
      @dx = 0

      @character_animation.update
      @weapon_animation.update

      return

    when :shoot
      @dx = RECOIL

    else
      @dx = RUNNING_SPEED

    end


    # --- Vertical movement :
    @dy += GRAVITY


    # --- Door collisions :
    if hit_box.intersect_rect? args.state.door.hit_box(args.state.ground.position) then
      if args.inputs.keyboard.key_held.up || args.inputs.controller_one.key_held.up then
        @machine.set_current_state :shifting
      end
    end


    # --- Enemies collisions :
    was_hit = false
    args.state.monsters.each do |monster|
      unless [ :dying, :dead ].include? monster.current_state then
        was_hit = true if hit_box.intersect_rect? monster.hit_box(args.state.ground.position)

        monster.limbs.each do |limb|
          was_hit = true if hit_box.intersect_rect? limb.hit_box(monster,args.state.ground.position)
        end
      end

      break if was_hit
    end

    if was_hit then
      @health        -= 1 if @machine.current_state != :hit
      @machine.set_current_state :hit
      @recovery_timer = RECOVERY_TIME
    end


    # --- Props collisions :
    args.state.props.each do |prop|
      if hit_box.intersect_rect? prop.hit_box(args.state.ground.position) then
        prop.use
        instance_exec nil, &prop.action
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


    #### DIRTY HACK !!! ###
    if @machine.current_state == :running then
      if @dx == 0 then
        if @was_running == true
          @character_animation.set_clip :idle
          @weapon_animation.set_clip    :idle
          @weapon_animation.path        = @weapons[@current_weapon][:path]
          @was_running = false
        end
      else
        if @was_running == false
          @character_animation.set_clip :run
          @weapon_animation.set_clip    :run
          @weapon_animation.path        = @weapons[@current_weapon][:path]
          @was_running = true
        end
      end
    end


    # --- Weapons collisions :
    if @machine.current_state == :swing then
      collision_index   = @weapon_animation.frame_index
      weapon_collision  = @weapons[@current_weapon][:collisions][collision_index]
      unless weapon_collision[0].nil? then
        weapon_hit_box_x    = weapon_collision[0] - ( weapon_collision[2] >> 1 ) + @x + @animation_offset[@facing_right][0]
        weapon_hit_box_y    = weapon_collision[1] - ( weapon_collision[2] >> 1 ) + @y
        weapon_hit_box_size = weapon_collision[2]
        weapon_hit_box      = [ weapon_hit_box_x, weapon_hit_box_y, weapon_hit_box_size, weapon_hit_box_size ]
        
        Debug::draw_box weapon_hit_box, [ 255, 0, 0, 255 ] if args.state.debug_mode == 1

        args.state.monsters.each do |monster|
          unless [:hit, :dying, :dead].include? monster.current_state then
            if weapon_hit_box.intersect_rect? monster.hit_box(args.state.ground.position) then
              monster.current_state = :hit 
              monster.hit @weapons[@current_weapon][:damage]
            end
          end
        end
      end

    elsif @machine.current_state == :shoot && @done_shooting == false then
      bullet_x = 2 
      while bullet_x <= 8 do
        # Testing monsters first... :
        #bullet_hit_box  = [ bullet_x * 8, @y + GUN_HEIGHT, 8, 2 ]
        bullet_hit_box  = [ bullet_x * 8, @y, 8, 8 ]
        args.state.monsters.each do |monster|
          if bullet_hit_box.intersect_rect? monster.hit_box(args.state.ground.position) then
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


  # ---=== RENDERING : ===---
  def render
    [ @character_animation.frame_at( @x + @animation_offset[@facing_right][0], @y, !@facing_right ),
      @weapon_animation.frame_at(    @x + @animation_offset[@facing_right][0], @y, !@facing_right ) ]
  end


  # ---=== STATE : ===---
  def current_state
    @machine.current_state
  end

  def animation_status
    @character_animation.status
  end


  # ---=== UTILITIES : ===---
  def point_in_rect(point,rect)
    point[0] >= rect[0]           &&
    point[0] <= rect[0] + rect[2] &&
    point[1] >= rect[1]           &&
    point[1] <= rect[1] + rect[3]
  end

  def hit_box
    [ @x - ( @width >> 1 ), @y, @width, @height ]
  end


  # ---=== SERIALIZATION : ===---
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
