class TiledBackground
  def self.ground
    TileBackground.new( 64,
                        64,
                        { render_target_name: :ground,
                          width:              256,
                          height:             64,
                          speed:              2 },
                        { tiles:  { path:         'sprites/temple_background_tiles.png',
                                    size:         8 },
                          groups: { horizontal:   { indices: [ 0, 1, 2, 3 ], offset: [ 1,  0 ] },
                                    connection:   { indices: [ 0, 1, 2, 3 ], offset: [ 1,  0 ] },
                                    bottom_right: { indices: [ 4 ],          offset: [ 0,  1 ] },
                                    bottom_left:  { indices: [ 5 ],          offset: [ 1,  0 ] },
                                    top_left:     { indices: [ 6 ],          offset: [ 1,  0 ] },
                                    top_right:    { indices: [ 7 ],          offset: [ 0, -1 ] },
                                    empty:        { indices: [ 8 ],          offset: [ 0,  0 ] } },
                          rules:  { horizontal:   { 0.85 => [ :horizontal ], 1.0 => [ :connection ] },
                                    connection:   { 0.7 => [ :connection ], 1.0 => [ :bottom_right, :top_right ] },
                                    bottom_right: { 1.0 => [ :top_left ] },
                                    top_left:     { 1.0 => [ :horizontal ] },
                                    top_right:    { 1.0 => [ :bottom_left ] },
                                    bottom_left:  { 1.0 => [ :horizontal ] } },
                          fill:   [ 0, 1, 2, 3, 4, 5 ] } )
  end
end
