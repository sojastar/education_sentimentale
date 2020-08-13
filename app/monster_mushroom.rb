class WalkingMonster
  MUSHROOM_JUMP_STRENGTH  = 6
  def self.spawn_mushroom_at(x)
    
    # Root Monster ANIMATION :
    frames    = { stun:         { frames:             [ [ 0,0], [ 1,0], [ 2,0], [ 1,0] ],
                                  mode:               :loop,
                                  speed:              3,
                                  flip_horizontally:  false,
                                  flip_vertically:    false },
                  jumping_up:   { frames:             [ [ 6,0], [ 7,0], [ 8,0], [ 9,0], [10,0], [11,0] ],
                                  mode:               :once,
                                  speed:              5,
                                  flip_horizontally:  false,
                                  flip_vertically:    false },
                  jumping_down: { frames:             [ [12,0], [13,0], [14,0], [15,0], [16,0], [ 0,0] ],
                                  mode:               :once,
                                  speed:              5,
                                  flip_horizontally:  false,
                                  flip_vertically:    false },
                  bounce:       { frames:             [ [ 1,0], [ 2,0], [ 3,0], [ 4,0], [ 5,0] ],
                                  mode:               :once,
                                  speed:              4,
                                  flip_horizontally:  false,
                                  flip_vertically:    false },
                  hit:          { frames:             [ [0,3] ],
                                  mode:               :once,
                                  speed:              6,
                                  flip_horizontally:  false,
                                  flip_vertically:    false },
                  dying:        { frames:             [ [0,4], [1,4], [2,4] ],
                                  mode:               :once,
                                  speed:              4,
                                  flip_horizontally:  false,
                                  flip_vertically:    false } }

    animation = Animation.new 'sprites/mushroom.png',
                              16,
                              16,
                              frames,
                              :jumping_down


    # Root Monster FINITE STATE MACHINE :
    fsm       = FSM::new_machine(nil) do      # nil, because the parent object is not created yet
                  add_state(:jumping_up) do
                    define_setup do
                      @dy = WalkingMonster::MUSHROOM_JUMP_STRENGTH
                      @animation.set_clip  :jumping_up
                    end

                    add_event(next_state: :jumping_down) do |args|
                      @dy <= 0
                    end
                  end

                  add_state(:jumping_down) do
                    define_setup do
                      @animation.set_clip :jumping_down
                    end

                    add_event(next_state: :bounce) do |args|
                      @dy == 0.0 && ( @y % 8 ) == 0.0
                    end
                  end

                  add_state(:bounce) do
                    define_setup do
                      @dy = 0
                      @animation.set_clip :bounce
                    end

                    add_event(next_state: :jumping_up) do |args|
                      @animation.status == :finished
                    end
                  end

                  add_state(:stun) do
                    define_setup do
                      @animation.set_clip :stun
                      @recovery_timer   = 10
                      @push_back_speed  = 0
                    end

                    add_event(next_state: :jumping_up) do |args|
                      @recovery_timer <= 0
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

                    add_event(next_state: :jumping_up) do |args|
                      @recovery_timer <= 0
                    end
                  end

                  add_state(:dying) do
                    define_setup do
                      @animation.set_clip :dying
                      limbs_are :dying
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
    WalkingMonster.new( animation,
                        { true => [ -8, 0 ], false => [ -8, 0 ] },  # animation draw offset
                        x, 48,                                        # start position x and y
                        [ 6, 14 ],                                    # collision box size
                        [ 0,  0 ],                                    # no need for walking monsters
                        4,                                            # running speed
                        2,                                            # push back speed
                        1,                                            # health
                        fsm,                                          # finite state machine
                        [] )                                          # limbs

  end
end
