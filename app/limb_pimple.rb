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
                            mode:               :loop,
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

    animation = Animation.new 'sprites/pimple.png',
                              32,
                              32,
                              frames,
                              :attack


    # Pimple HITBOXES :
    hit_boxes = [ [ 22, 16, 2,  2 ],
                  [ 21, 17, 2,  2 ],
                  [ 21, 17, 2,  2 ],
                  [ 22, 16, 2,  2 ],
                  [ 15, 15, 3,  3 ],
                  [ 13, 15, 4,  4 ],
                  [ 11, 13, 4,  7 ],
                  [  9, 11, 5, 10 ],
                  [  7, 10, 6, 11 ],
                  [  6, 10, 7, 12 ],
                  [  6,  9, 7, 13 ],
                  [  5, 10, 7, 13 ],
                  [  4,  9, 8, 15 ],
                  [  5, 11, 6, 11 ],
                  [  8, 14, 3,  5 ],
                  [ 22, 16, 2,  2 ] ]


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
