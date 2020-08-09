class Prop
  def self.spawn_hotdog_at(x,y)
    
    # Hotdog Prop ANIMATION :
    frames    = { idle:   { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0] ],
                            mode:               :loop,
                            speed:              6,
                            flip_horizontally:  false,
                            flip_vertically:    false } }

    animation = Animation.new 'sprites/hotdog.png',
                              16,
                              16,
                              frames,
                              :idle


    # Hotdog Prop FINITE STATE MACHINE :
    fsm       = FSM::new_machine(nil) do      # nil, because the parent object is not created yet
                  add_state(:idle) do
                    define_setup do
                      @animation.set_clip :idle
                    end
                  end

                  set_initial_state :idle
                end
    Prop.new( x, y,
             :hotdog,
             animation,
             [ 14, 14 ],
             [  1,  1 ],
             fsm ) { @health += 1 if @health < Player::MAX_LIFE }
  end
end
