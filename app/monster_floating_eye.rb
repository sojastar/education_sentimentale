class FlyingMonster
  def self.spawn_floating_eye_at(x,y)
    
    # Flying Eye Monster ANIMATION :
    frames    = { idle:   { frames:             [ [0,0], [1,0], [2,0], [3,0] ],
                            mode:               :loop,
                            speed:              6,
                            flip_horizontally:  false,
                            flip_vertically:    false },
                  flying: { frames:             [ [0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2] ],  
                            mode:               :loop,
                            speed:              4,
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

    animation = Animation.new 'sprites/floating_eye.png',
                              32,
                              32,
                              frames,
                              :flying


    # Flying Eye Monster FINITE STATE MACHINE :
    fsm       = FSM::new_machine(nil) do      # nil, because the parent object is not created yet
                  add_state(:flying) do
                    define_setup do
                      @animation.set_clip :flying
                    end
                  end

                  add_state(:stun) do
                    define_setup do
                      @animation.set_clip :idle
                      @recovery_timer   = 10
                      @push_back_speed  = 2
                    end

                    add_event(next_state: :flying) do |args|
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

                    add_event(next_state: :flying) do |args|
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

                  set_initial_state :flying
                end


    # Spawning :
    FlyingMonster.new animation,
                      { true => [ -24, 0 ], false => [ -24, 0 ] },  # animation draw offset
                      x, y,                                         # start position x and y
                      14, 9,                                        # collision box width and height
                      4,                                            # running speed
                      2,                                            # push back speed
                      1,                                            # health
                      fsm,                                          # finite state machine
                      nil,                                          # parent
                      nil                                           # children
  end
end
