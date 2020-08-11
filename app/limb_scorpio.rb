class Limb
  def self.spawn_scorpion_tail_at(x,y)

    # Scorpion Tail Limb ANIMATION :
    frames    = { attack: { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0], [0,1], [1,1], [2,1], [3,1], [4,1], [5,1] ],
                            mode:               :loop,
                            speed:              8,
                            flip_horizontally:  false,
                            flip_vertically:    false },
                  dying:  { frames:             [ [0,2], [1,2], [2,2] ],
                            mode:               :once,
                            speed:              6,
                            flip_horizontally:  false,
                            flip_vertically:    false } }

    animation = Animation.new 'sprites/scorpio.png',
                              48,
                              48,
                              frames,
                              :attack


    # Scorpion Tail HITBOXES :
    hit_boxes = [ { x: 19, y: 21, size: [ 10,  7 ] },
                  { x: 22, y: 22, size: [ 10,  7 ] },
                  { x: 22, y: 25, size: [ 10,  7 ] },
                  { x: 22, y: 27, size: [ 10,  7 ] },
                  { x: 22, y: 26, size: [ 10, 10 ] },
                  { x: 22, y: 27, size: [ 10,  7 ] },
                  { x: 22, y: 22, size: [ 10,  8 ] },
                  { x: 22, y: 22, size: [ 10,  7 ] },
                  { x: 19, y: 21, size: [ 10,  7 ] },
                  { x: 22, y: 25, size: [ 10,  7 ] },
                  { x: 22, y: 27, size: [ 10,  9 ] },
                  { x: 28, y: 32, size: [ 10,  9 ] },
                  { x: 19, y: 20, size: [ 10,  8 ] },
                  { x:  2, y: 11, size: [ 10,  7 ] } ]


    # Other parameters :
    offset_x    = 32
    offset_y    = 2
    scale       = 0.5 + 0.75 * rand
    color_shift = [ 150 + ( 105 * rand ).to_i,
                    150 + ( 105 * rand ).to_i,
                    150 + ( 105 * rand ).to_i ]

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
