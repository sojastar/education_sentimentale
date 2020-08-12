class Limb
  def self.spawn_pimple_at(x,y)

    # Pimple Limb ANIMATION :
    frames    = { attack: { frames:             [ [0,0], [1,0], [2,0], [3,0],
                                                  [0,1], [1,1], [2,1], [3,1], [4,1], [5,1], [6,1], [7,1], [8,1], [9,1], [10,1], [11,1] ],
                            mode:               :loop,
                            speed:              8,
                            flip_horizontally:  false,
                            flip_vertically:    false },
                  stun:   { frames:             [ [0,0], [1,0], [2,0], [3,0] ],
                            mode:               :once,
                            speed:              6,
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

    animation = Animation.new 'sprites/pimple.png',
                              32,
                              32,
                              frames,
                              :attack


    # Pimple HITBOXES :
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
    offset_x    = 25 
    offset_y    = 16
    scale       = 0.8 + 0.4 * rand
    #scale       = 0.5 + rand
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
