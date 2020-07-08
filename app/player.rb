class Player

  GRAVITY                 = -0.5
  JUMP_STRENGTH           = 4

  GROUND_COLLISION_WIDTH  = 1

  attr_reader :x, :y, :dx, :dy

  def initialize(animation,animation_offset,start_x,start_y,width,height)
    @x,  @y             = start_x, start_y
    @dx, @dy            = 0, 0

    @width              = width
    @height             = height

    @facing_right       =  true
    @animation          =  animation
    @animation_offset_x = animation_offset[0]
    @animation_offset_y = animation_offset[1]

    @machine            =  FSM::new_machine(self) do
                             add_state(:idle) do
                               define_setup do 
                                 @animation.set_clip :idle
                               end

                               add_event(next_state: :running) do |args|
                                 args.key_held.right || args.key_held.left
                               end

                               add_event(next_state: :jumping_up) do |args|
                                 args.key_held.space
                               end
                             end

                             add_state(:running) do
                               define_setup do
                                 @animation.set_clip :run
                               end

                               add_event(next_state: :idle) do |args|
                                 !args.key_held.right && !args.key_held.left
                               end

                               add_event(next_state: :jumping_up) do |args|
                                 args.key_held.space
                               end
                             end

                             add_state(:jumping_up) do
                               define_setup do
                                 @dy = JUMP_STRENGTH
                                 @animation.set_clip :jump_up
                               end

                               add_event(next_state: :jumping_down) do |args|
                                 @dy <= 0
                               end
                             end

                             add_state(:jumping_down) do
                               define_setup do
                                 @animation.set_clip :jump_down
                               end

                               add_event(next_state: :idle) do |args|
                                 @y <= 8#0
                               end
                             end

                             set_initial_state :idle
                           end
  end

  def update(args)
    @machine.update(args.inputs.keyboard)

    # Horizontal movement :
    @dx = 0
    if args.inputs.keyboard.key_held.right then
      @facing_right   = true
      @dx             = 1
    elsif args.inputs.keyboard.key_held.left then
      @facing_right   = false
      @dx             = -1
    end

    # Vertical movement :
    if [:jumping_up, :jumping_down].include? @machine.current_state then
      @dy += GRAVITY
      @y  += @dy
    end
    #@dy += GRAVITY
    #@y  += @dy

    # Ground collisions :
    #collision_box   = [ @x - ( width >> 1 ),
    #                    @y,
    #                    width,
    #                    height ]
    #
    #tiles_offset      = args.state.ground.position.div 8
    #center_tile_index = ( @x % 8 ) + tile_offset
    #collision_range   = ( center_tile_index - GROUND_COLLISION_WIDTH )..( center_tile_index + GROUND_COLLISION_WIDTH )
    #collision_range.map do |x|
    #  ground_box_x  =                                    x * 8 - args.state.ground.position
    #  ground_box_y  = args.state.ground.collision_tiles[x] * 8
    #  ground_box    = [ ground_box_x,
    #                    ground_box_y,
    #                    8,
    #                    8 ]
    #  if collision_box.intersect_rect? ground_box then

    #  end
    #end
    
    @animation.update
  end

  def render
    @animation.frame_at @x + @animation_offset_x, @y, !@facing_right
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
