class Background
  def self.layers
    $gtk.args.render_target(:bitmap_background).sprites << {  x:        0,
                                                              y:        0,
                                                              w:        256,
                                                              h:        192,
                                                              path:     'sprites/background_bitmaps.png',
                                                              source_x: 0,
                                                              source_y: 720-192,
                                                              source_w: 256,
                                                              source_h: 192 }

    [ Background.new( 64,
                      64,
                      { path:     :bitmap_background,
                        y_offset: 128,
                        width:    256,
                        height:   64,
                        speed:    16 } ),
      Background.new( 64,
                      64,
                      { path:     :bitmap_background,
                        y_offset: 64,
                        width:    256,
                        height:   64,
                        speed:    8 } ),
      Background.new( 64,
                      64,
                      { path:     :bitmap_background,
                        y_offset: 0,
                        width:    256,
                        height:   64,
                        speed:    4 } ) ]
  end
end
