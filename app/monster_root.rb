class Monster
  def self.spawn_root_at(x)
    
    # Root Monster ANIMATION :
    frames    = { idle:   { frames:             [ [0,0] ],
                            mode:               :loop,
                            speed:              6,
                            flip_horizontally:  false,
                            flip_vertically:    false },
                  hit:    { frames:             [ [0,3] ],
                            mode:               :once,
                            speed:              6,
                            flip_horizontally:  false,
                            flip_vertically:    false },
                  death:  { frames:             [ [0,4], [1,4], [2,4] ],
                            mode:               :once,
                            speed:              4,
                            flip_horizontally:  false,
                            flip_vertically:    false } }

    animation = Animation.new 'sprites/root.png',
                              48,
                              48,
                              frames,
                              :idle


    # Root Monster FINITE STATE MACHINE :
    fsm       = FSM::new_machine(nil) do      # nil, because the parent object is not created yet
                  add_state(:idle) do
                    define_setup do
                      @animation.set_clip :idle
                    end
                  end

                  add_state(:jumping_down) do
                    define_setup do
                      @animation.set_clip :idle
                    end

                    add_event(next_state: :idle) do |args|
                      @dy == 0.0 && ( @y % 8 ) == 0.0
                    end
                  end

                  add_state(:hit) do
                    define_setup do
                      @animation.set_clip :hit
                      @recovery_timer   = 15
                      @push_back_speed  = 0
                    end

                    add_event(next_state: :dying) do |args|
                      @health <= 0
                    end

                    add_event(next_state: :idle) do |args|
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
    WalkingMonster.new  animation,
                        { true => [ -24, 0 ], false => [ -24, 0 ] },  # animation draw offset
                        x, 48,                                        # start position x and y
                        18, 32,                                       # collision box width and height
                        0,                                            # running speed
                        0,                                            # push back speed
                        3,                                            # health
                        fsm,                                          # finite state machine
                        nil,                                          # parent
                        nil                                           # children

  end
end
