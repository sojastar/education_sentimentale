class Player

  GRAVITY       = -0.5
  JUMP_STRENGTH = 6

  def initialize(animation)
    @y  = 0
    @dy = 0
    @facing_right =  true
    @animation    =  animation
    @machine      =  FSM::new_machine(self) do
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
                           @y <= 0
                         end
                       end

                       set_initial_state :idle
                     end
  end

  def update(args)
    @machine.update(args.inputs.keyboard)

    if [:jumping_up, :jumping_down].include? @machine.current_state then
      @y  += @dy
      @dy += GRAVITY
    end

    @facing_right   = true  if args.inputs.keyboard.key_held.right
    @facing_right   = false if args.inputs.keyboard.key_held.left
    
    @animation.update
  end

  def render_at(x,y)
    @animation.frame_at x, y + @y, !@facing_right
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
