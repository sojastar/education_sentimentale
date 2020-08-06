class Monster
  def self.spawn_rampant_at(x)
    
    # Rampant Monster ANIMATION :
    frames    = { idle:     { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0] ],
                              mode:               :loop,
                              speed:              6,
                              flip_horizontally:  false,
                              flip_vertically:    false },
                  running:  { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0] ],  
                              mode:               :loop,
                              speed:              4,
                              flip_horizontally:  false,
                              flip_vertically:    false },
                  hit:      { frames:             [ [0,3] ],
                              mode:               :once,
                              speed:              6,
                              flip_horizontally:  false,
                              flip_vertically:    false },
                  death:    { frames:             [ [0,4], [1,4], [2,4] ],
                              mode:               :once,
                              speed:              4,
                              flip_horizontally:  false,
                              flip_vertically:    false } }

    animation = Animation.new 'sprites/rampant.png',
                              48,
                              48,
                              frames,
                              :idle


    # Rampant Monster FINITE STATE MACHINE :
    fsm       = FSM::new_machine(nil) do      # nil, because the parent object is not created yet
                  add_state(:idle) do
                    define_setup do
                      @animation.set_clip :idle
                    end
                  end

                  add_state(:running) do
                    define_setup do
                      @animation.set_clip :running
                    end
                  end

                  add_state(:jumping_up) do
                    define_setup do
                      @animation.set_clip :idle
                    end
                  end

                  add_state(:jumping_down) do
                    define_setup do
                      @animation.set_clip :idle
                    end

                    add_event(next_state: :running) do |args|
                      @dy == 0.0 && ( @y % 8 ) == 0.0
                    end
                  end

                  add_state(:stun) do
                    define_setup do
                      @animation.set_clip :idle
                      @recovery_timer   = 10
                      @push_back_speed  = 0
                    end

                    add_event(next_state: :running) do |args|
                      @recovery_timer <= 0
                    end
                  end

                  add_state(:hit) do
                    define_setup do
                      @animation.set_clip :hit
                      @recovery_timer   = 15
                      @push_back_speed  = 2
                    end

                    add_event(next_state: :dying) do |args|
                      @health <= 0
                    end

                    add_event(next_state: :running) do |args|
                      @recovery_timer <= 0
                    end
                  end

                  add_state(:dying) do
                    define_setup do
                      @animation.set_clip :death
                    end

                    add_event(next_state: :dead) do |args|
                      @animation.status == :finished
                    end
                  end

                  add_state(:dead) do
                    define_setup {}
                  end

                  set_initial_state :jumping_down
                end


    # Spawning :
    Monster.new animation,
                { true => [ -24, 0 ], false => [ -24, 0 ] },  # animation draw offset
                x, 48,                                        # start position x and y
                24, 12,                                       # collision box width and height
                4,                                            # running speed
                1,                                            # push back speed
                3,                                            # health
                fsm,                                          # finite state machine
                nil,                                          # parent
                nil                                           # children

  end
end
