class Player
  CAN_MOVE_STATES         = [ :walking, :running, :jumping_up, :jumping_down ]

  GRAVITY                 = -0.4
  JUMP_STRENGTH           = 4

  GROUND_COLLISION_WIDTH  = 1

  RECOVERY_TIME           = 10
  PUSH_BACK_SPEED         = 2

  attr_reader :x, :y, :dx, :dy

  def initialize(character_animation,weapon_animation,animation_offset,start_x,start_y,width,height,weapons)
    @x,  @y               = start_x, start_y
    @dx, @dy              = 0, 0

    @width                = width
    @height               = height

    @facing_right         = true
    @character_animation  = character_animation
    @weapon_animation     = weapon_animation
    @animation_offset     = animation_offset

    @weapons              = weapons
    @current_weapon       = 0

    @hit                  = false
    @machine              = FSM::new_machine(self) do
                              add_state(:idle) do
                                define_setup do 
                                  @character_animation.set_clip  :idle
                                  @weapon_animation.set_clip     :idle
                                end

                                add_event(next_state: :running) do |args|
                                  args.inputs.keyboard.key_held.right || args.inputs.keyboard.key_held.left
                                end

                                add_event(next_state: :jumping_up) do |args|
                                  args.inputs.keyboard.key_down.space
                                end

                                add_event(next_state: :attack) do |args|
                                  args.inputs.keyboard.key_down.x
                                end
                              end

                              add_state(:running) do
                                define_setup do
                                  @character_animation.set_clip  :run
                                  @weapon_animation.set_clip     :run
                                end

                                add_event(next_state: :idle) do |args|
                                  !args.inputs.keyboard.key_held.right && !args.inputs.keyboard.key_held.left
                                end

                                add_event(next_state: :jumping_up) do |args|
                                  args.inputs.keyboard.key_down.space
                                end

                                add_event(next_state: :attack) do |args|
                                  args.inputs.keyboard.key_down.x
                                end
                              end

                              add_state(:jumping_up) do
                                define_setup do
                                  @dy = JUMP_STRENGTH
                                  @character_animation.set_clip  :jump_up
                                  @weapon_animation.set_clip     :jump_up
                                end

                                add_event(next_state: :jumping_down) do |args|
                                  @dy <= 0
                                end
                              end

                              add_state(:jumping_down) do
                                define_setup do
                                  @character_animation.set_clip  :jump_down
                                  @weapon_animation.set_clip     :jump_down
                                end

                                add_event(next_state: :idle) do |args|
                                  @dy == 0 && ( @y % 8 ) == 0
                                end

                                #add_event(next_state: :hit) do |args|
                                #  @hit == true
                                #end
                              end

                              add_state(:attack) do
                                define_setup do
                                  @character_animation.set_clip    @weapons[@current_weapon][:animation]
                                  @character_animation.speed     = @weapons[@current_weapon][:speed]
                                  @weapon_animation.set_clip       @weapons[@current_weapon][:animation]
                                  @weapon_animation.speed        = @weapons[@current_weapon][:speed]
                                end

                                add_event(next_state: :idle) do |args|
                                  @character_animation.status == :finished
                                end
                              end

                              add_state(:hit) do
                                define_setup do
                                  @character_animation.set_clip :hit
                                  @weapon_animation.set_clip    :hit
                                end

                                add_event(next_state: :idle) do |args|
                                  @recovery_timer <= 0
                                end
                              end

                              set_initial_state :jumping_down
                            end
  end

  def update(args)
    @machine.update(args)
    #puts @machine.current_state
    #puts "position: #{x};#{@y} - displacement: #{@dx};#{@dy}"

    # --- Switching weapons :
    if args.inputs.keyboard.key_down.w then
      @current_weapon         = ( @current_weapon + 1 ) % @weapons.length
      @weapon_animation.path  =  @weapons[@current_weapon][:path]
    end

    # --- Horizontal movement :
    @dx = 0
    case @machine.current_state
    when :walking, :running, :jumping_up, :jumping_down
      if args.inputs.keyboard.key_held.right then
        @facing_right   = true
        @dx             = 1
      elsif args.inputs.keyboard.key_held.left then
        @facing_right   = false
        @dx             = -1
      end
    #end

    when :hit
      @recovery_timer -= 1
      @dx              = @facing_right ? -PUSH_BACK_SPEED : PUSH_BACK_SPEED

    end


    # --- Vertical movement :
    @dy += GRAVITY

    # --- Enemy collisions :
    hit_box                   = [ @x - ( @width >> 1 ),
                                  @y,
                                  @width,
                                  @height ]
    args.outputs.labels << [ 20, 700, "player: #{hit_box}", 255, 255, 255, 255 ]

    args.state.monsters.each do |monster|
      monster_hit_box = [ monster.x - ( monster.width >> 1 ) - args.state.ground.position,
                          monster.y,
                          monster.width,
                          monster.height ]
      args.outputs.labels << [ 20, 680, "monster: #{monster_hit_box}", 255, 255, 255, 255 ]

      if hit_box.intersect_rect? monster_hit_box then
        args.outputs.labels << [ 20, 660, "hit!!!!", 255, 255, 255, 255 ]
        @machine.set_current_state :hit
        @recovery_timer = RECOVERY_TIME
        break
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
    if @weapons[@current_weapon][:animation] == :sword_attack && @machine.current_state == :attack then
      collision_index   = @weapon_animation.frame_index
      weapon_collision  = @weapons[@current_weapon][:collisions][collision_index]
      unless weapon_collision[0].nil? then
        weapon_box_x    = weapon_collision[0] - ( weapon_collision[2] >> 1 ) + @x + @animation_offset[@facing_right][0]
        weapon_box_y    = weapon_collision[1] - ( weapon_collision[2] >> 1 ) + @y
        weapon_box_size = weapon_collision[2]
        if args.state.debug_mode == 1
          Debug::draw_box [ weapon_box_x, weapon_box_y, weapon_box_size, weapon_box_size ], [ 255, 0, 0, 255 ]
        end
      end
    #else

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
