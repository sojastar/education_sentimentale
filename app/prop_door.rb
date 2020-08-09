class Prop
  def self.spawn_door_at(x,y)
    
    # Door Prop ANIMATION :
    frames    = { closed:   { frames:             [ [0,0] ],
                              mode:               :once,
                              speed:              6,
                              flip_horizontally:  false,
                              flip_vertically:    false },
                  opening:  { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0] ],
                              mode:               :once,
                              speed:              6,
                              flip_horizontally:  false,
                              flip_vertically:    false }, 
                  open:     { frames:             [ [0,1], [1,1], [2,1], [3,1], [4,1], [5,1] ],
                              mode:               :loop,
                              speed:              6,
                              flip_horizontally:  false,
                              flip_vertically:    false },
                  closing:  { frames:             [ [5,0], [4,0], [3,0], [2,0], [1,0], [0,0] ],
                              mode:               :once,
                              speed:              6,
                              flip_horizontally:  false,
                              flip_vertically:    false } }

    animation = Animation.new 'sprites/door.png',
                              32,
                              32,
                              frames,
                              :closed


    # Door Prop FINITE STATE MACHINE :
    fsm       = FSM::new_machine(nil) do      # nil, because the parent object is not created yet
                  add_state(:closed) do
                    define_setup do
                      @animation.set_clip :closed
                    end

                    add_event(next_state: :opening) do |args|
                      @x - args.state.ground.position <= 48
                    end
                  end

                  add_state(:opening) do
                    define_setup do
                      @animation.set_clip :opening
                    end

                    add_event(next_state: :open) do |args|
                      @animation.status == :finished
                    end
                  end

                  add_state(:open) do
                    define_setup do
                      @animation.set_clip :open
                    end

                    add_event(next_state: :closed) do |args|
                      @x - args.state.ground.position > 48
                    end
                  end

                  set_initial_state :closed
                end
    Prop.new( x, y,
              :door,
              animation,
              [ 20, 29 ],
              [  6,  0 ],
              fsm ) {}
  end
end
