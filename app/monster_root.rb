class Monster
  def self.spawn_root_at(args,x)
    
    # Root Monster ANIMATION :
    root_frames     = { idle: { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0] ],
                                mode:               :loop,
                                speed:              6,
                                flip_horizontally:  false,
                                flip_vertically:    false } }

    root_animation  = Animation.new 'sprites/racine_static.png',
                                    48,
                                    32,
                                    player_frames,
                                    :idle_right


    # Root Monster FINIT STATE MACHINE :
    fsm       = 

    # Spawning :
    args.state.monters << Monster.new animation,
                                      animation_offset,
                                      x, 48,                #  start position x and y
                                      18, 32,               # collision box width and height
                                      fsm,
                                      nil                   # children
  end
end
