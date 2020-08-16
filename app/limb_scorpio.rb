class Limb
  def self.spawn_scorpion_tail_at(x,y)

    # Scorpion Tail Limb ANIMATION :
    frames    = { attack: { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0], [0,1], [1,1], [2,1], [3,1], [4,1], [5,1] ],
                            mode:               :loop,
                            speed:              8,
                            flip_horizontally:  false,
                            flip_vertically:    false },
                  stun:   { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0] ],
                            mode:               :once,
                            speed:              1,
                            flip_horizontally:  false,
                            flip_vertically:    false },
                  hit:    { frames:             [ [0,3] ],
                            mode:               :once,
                            speed:              6,
                            flip_horizontally:  false,
                            flip_vertically:    false },
                  dying:  { frames:             [ [0,2], [1,2], [2,2] ],
                            mode:               :once,
                            speed:              6,
                            flip_horizontally:  false,
                            flip_vertically:    false } }

    animation = Animation.new 'sprites/scorpio_' + ( 1 + rand(6) ).to_s + '.png',
                              48,
                              48,
                              frames,
                              :attack


    # Scorpion Tail HITBOXES :
    hit_boxes = [ [19, 18, 10, 7],
                  [22, 19, 10, 7],
                  [22, 22, 10, 7],
                  [22, 24, 10, 7],
                  [22, 26, 10, 9],
                  [22, 24, 10, 7],
                  [22, 22, 10, 7],
                  [22, 19, 10, 7],
                  [19, 18, 10, 7],
                  [22, 22, 10, 7],
                  [22, 26, 10, 9],
                  [28, 31, 10, 8],
                  [19, 18, 10, 7],
                  [ 2,  7, 11, 7] ]


    # Other parameters :
    offset_x    = 32
    offset_y    = 2
    scale       = 0.8 + 0.4 * rand
    #scale       = 0.5 + rand
    color_shift = [ 255,#150 + ( 105 * rand ).to_i,
                    255,#150 + ( 105 * rand ).to_i,
                    255 ]#150 + ( 105 * rand ).to_i ]

    # Spawning :
    Limb.new( x, y,
              offset_x * scale,
              offset_y * scale,
              scale,
              color_shift,
              animation,
              hit_boxes )

  end
end
