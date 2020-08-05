class Background
  def self.layers
    [ Background.new( 64,
                      64,
                      { path:     'sprites/background_bitmaps.png',
                        y_offset: 128,
                        width:    256,
                        height:   64,
                        speed:    16 } ),
      Background.new( 64,
                      64,
                      { path:     'sprites/background_bitmaps.png',
                        y_offset: 64,
                        width:    256,
                        height:   64,
                        speed:    8 } ),
      Background.new( 64,
                      64,
                      { path:     'sprites/background_bitmaps.png',
                        y_offset: 0,
                        width:    256,
                        height:   64,
                        speed:    4 } ) ]
  end
end
