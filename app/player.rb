class Player

  GRAVITY                 = -0.4
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
                                 #@y <= 8#0
                                 @dy == 0 && ( @y % 8 ) == 0
                               end
                             end

                             set_initial_state :jumping_down
                           end
  end

  def update(args)
    @machine.update(args.inputs.keyboard)
    #puts @machine.current_state
    #puts "position: #{x};#{@y} - displacement: #{@dx};#{@dy}"

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
    @dy += GRAVITY

    # Ground collisions :
    collision_box             = [ @x - ( @width >> 1 ),
                                  @y,
                                  @width,
                                  @height ]

    #Debug::draw_box collision_box, [ 0, 0, 255, 255 ]
    
    bottom_left_new_position  = [ @x - ( @width >> 1 ) + @dx, @y + @dy ]
    bottom_right_new_position = [ @x + ( @width >> 1 ) + @dx, @y + @dy ]

    tiles_offset      = ( args.state.ground.position + @x ).div 8
    center_tile_index = ( @x % 8 ) + tiles_offset
    collision_range   = ( center_tile_index - GROUND_COLLISION_WIDTH )..( center_tile_index + GROUND_COLLISION_WIDTH )
    collision_range.map do |x|
      ground_box_x  = x * 8 - args.state.ground.position
      ground_box_y  = args.state.ground.collision_tiles[x % args.state.ground.collision_tiles.length] * 8
      ground_box    = [ ground_box_x,
                        ground_box_y,
                        8,
                        8 ]

      Debug::draw_box ground_box, [ 255, 0, 0, 255 ] if args.state.debug_mode == 1

      # Checking collisions for the bottom left corner :
      if point_in_rect( [ @x - ( @width >> 1 ) + @dx, @y + 1 ], ground_box ) then
        #puts "Wall collision on the LEFT!!! x: #{@x} - dx: #{@dx} - ground box x: #{ground_box_x} - new dx: #{ground_box_x + 8 - ( @x - ( @width >> 1 ) - 1)}"
        @dx = ground_box_x + 8 - ( @x - ( @width >> 1 ) - 1)
      end

      if point_in_rect( [ @x - ( @width >> 1 ), @y + @dy ], ground_box ) then
        #puts "Ground collision on the LEFT!!! y: #{@y} - dy: #{@dy} - ground box y: #{ground_box_y} - new dy: #{ground_box_y + 8 - @y}"
        @dy =  ground_box_y + 8 - @y
      #else
        #puts "left  y: #{@y} - dy: #{@dy} - ground box y: #{ground_box_y} - new dy: #{@y - ( ground_box_y + 8 )}"
      end

      # Checking collisions for the bottom right corner :
      if point_in_rect( [ @x + ( @width >> 1 ) + @dx, @y + 1 ], ground_box ) then
        #puts "Wall collision on the RIGHT!!! x: #{@x} - dx: #{@dx} - ground box x: #{ground_box_x} - new dx: #{ground_box_x - ( @x + ( @width >> 1 ) )}"
        #puts "                               y: #{@y} - dy: #{@dy} - ground box y: #{ground_box_y}"
        @dx = ground_box_x - ( @x + ( @width >> 1 ) + 1 )
      end

      if point_in_rect( [ @x + ( @width >> 1 ), @y + @dy ], ground_box ) then
        #puts "Ground collision on the RIGHT!!! y: #{@y} - dy: #{@dy} - ground box y: #{ground_box_y} - new dy: #{ground_box_y + 8 - @y}"
        @dy =  ground_box_y + 8 - @y
      #else
        #puts "right y: #{@y} - dy: #{@dy} - ground box y: #{ground_box_y} - new dy: #{@y - ( ground_box_y + 8 )}"
      end
    end
    #puts '-----------------------'
    
    @y  += @dy
    
    @animation.update
  end

  def point_in_rect(point,rect)
    point[0] >= rect[0]           &&
    point[0] <= rect[0] + rect[2] &&
    point[1] >= rect[1]           &&
    point[1] <= rect[1] + rect[3]
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
