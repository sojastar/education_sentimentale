class Monster
  RAMPANT_SPAWN_ZONE_X  = 18
  RAMPANT_SPAWN_ZONE_Y  = 6
  RAMPANT_SPAWN_ZONE_W  = 15
  RAMPANT_SPAWN_ZONE_H  = 5

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


    # Spawning Children :
    limb_count  = 3
    limbs       = limb_count.times.map do |i|
                    child_x = RAMPANT_SPAWN_ZONE_X + ( rand * RAMPANT_SPAWN_ZONE_W ).to_i
                    child_y = RAMPANT_SPAWN_ZONE_Y + ( rand * RAMPANT_SPAWN_ZONE_H ).to_i
                    Limb::spawn_scorpion_tail_at( child_x, child_y )
                  end 


    # Spawning :
    WalkingMonster.new(  animation,
                        { true => [ -24, 0 ], false => [ -24, 0 ] },  # animation draw offset
                        x, 48,                                        # start position x and y
                        [ 24, 12 ],                                   # collision box size
                        [  0,  0 ],                                   # no need for walking monsters, but used to spawn droped items
                        4,                                            # running speed
                        4,                                            # push back speed
                        3,                                            # health
                        fsm,                                          # finite state machine
                        limbs )                                       # limbs

  end
end
