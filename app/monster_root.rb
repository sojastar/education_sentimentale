class Monster
  def self.spawn_root_at(x)
    
    # Root Monster ANIMATION :
    frames    = { idle: { frames:             [ [0,0] ],
                          mode:               :loop,
                          speed:              6,
                          flip_horizontally:  false,
                          flip_vertically:    false } }

    animation = Animation.new 'sprites/racine_static.png',
                              48,
                              48,
                              frames,
                              :idle


    # Root Monster FINITE STATE MACHINE :
    fsm       = FSM::new_machine(self) do
                  add_state(:idle) do
                    define_setup { @animation.set_clip :idle }
                  end

                  add_state(:jumping_down) do
                    define_setup { @animation.set_clip :idle }

                    add_event(next_state: :idle) { |args| @dy == 0 && ( @y % 8 ) == 0 }
                  end

                  set_initial_state :jumping_down
                end


    # Spawning :
    Monster.new animation,
                { true => [ -24, 0 ], false => [ -24, 0 ] },  # animation draw offset
                x, 48,                                        # start position x and y
                18, 32,                                       # collision box width and height
                fsm,
                nil,                                          # parent
                nil                                           # children

  end
end
