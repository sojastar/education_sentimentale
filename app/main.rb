require 'lib/fsm_machine.rb'
require 'lib/fsm_state.rb'
require 'lib/animation.rb'
require 'app/background.rb'
require 'app/player.rb'





SCREEN_WIDTH      = 1280
SCREEN_HEIGHT     = 720

DISPLAY_BASE_SIZE = 64
DISPLAY_SCALE     = 4
DISPLAY_SIZE      = DISPLAY_SCALE * DISPLAY_BASE_SIZE
DISPLAY_X         = ( SCREEN_WIDTH  - DISPLAY_SIZE ) >> 1
DISPLAY_Y         = ( SCREEN_HEIGHT - DISPLAY_SIZE ) >> 1





def setup(args)
  args.render_target(:bitmap_background).width  = 256
  args.render_target(:bitmap_background).height = 192
  args.render_target(:bitmap_background).sprites << { x:        0,
                                                      y:        0,
                                                      w:        256,
                                                      h:        192,
                                                      path:     'sprites/background_bitmaps.png',
                                                      source_x: 0,
                                                      source_y: 0,
                                                      source_w: 256,
                                                      source_h: 192 }

  args.state.background = Background.new  :bitmap_background,
                                          64,
                                          64,
                                          [ { width:    256,
                                              height:   64,
                                              speed:    16 },
                                            { width:    256,
                                              height:   64,
                                              speed:    8 },
                                            { width:    256,
                                              height:   64,
                                              speed:    4 } ]
  args.state.ground     = TileBackground.new  'sprites/background_tiles.png',
                                              64,
                                              64,
                                              8,
                                              [ { width:  256,
                                                  height: 64,
                                                  speed:  2 } ],
                                              { groups: { horizontal:   { indices: [ 0, 1, 2, 3 ], offset: [ 1,  0 ] },
                                                          connection:   { indices: [ 0, 1, 2, 3 ], offset: [ 1,  0 ] },
                                                          bottom_right: { indices: [ 4 ],          offset: [ 0,  1 ] },
                                                          bottom_left:  { indices: [ 5 ],          offset: [ 1,  0 ] },
                                                          top_left:     { indices: [ 6 ],          offset: [ 1,  0 ] },
                                                          top_right:    { indices: [ 7 ],          offset: [ 0, -1 ] },
                                                          empty:        { indices: [ 8 ],          offset: [ 0,  0 ] } },
                                                rules:  { horizontal:   { 0.5 => [ :horizontal ], 1.0 => [ :connection ] },
                                                          connection:   { 0.7 => [ :connection ], 1.0 => [ :bottom_right, :top_right ] },
                                                          bottom_right: { 1.0 => [ :top_left ] },
                                                          top_left:     { 1.0 => [ :horizontal ] },
                                                          top_right:    { 1.0 => [ :bottom_left ] },
                                                          bottom_left:  { 1.0 => [ :horizontal ] } },
                                                fill:   [ 0, 1, 2, 3, 4, 5 ] }

  player_animation      = Animation.new 'sprites/man_2.png',
                                        32,
                                        32,
                                        { idle:       { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0] ],
                                                        mode:               :loop,
                                                        speed:              6,
                                                        flip_horizontally:  false,
                                                        flip_vertically:    false },
                                          run:        { frames:             [ [0,1], [1,1], [2,1], [3,1], [4,1], [5,1], [6,1], [7,1] ],
                                                        mode:               :loop,
                                                        speed:              6,
                                                        flip_horizontally:  false,
                                                        flip_vertically:    false },
                                          walk:       { frames:             [ [0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2], [7,2], [8,2], [9,2], [10,2], [11,2] ],
                                                        mode:               :loop,
                                                        speed:              6,
                                                        flip_horizontally:  false,
                                                        flip_vertically:    false },
                                          jump_up:    { frames:             [ [4,3], [5,3], [6,3] ],
                                                        mode:               :once,
                                                        speed:              6,
                                                        flip_horizontally:  false,
                                                        flip_vertically:    false },
                                          jump_down:  { frames:             [ [7,3], [8,3], [9,3] ],
                                                        mode:               :once,
                                                        speed:              6,
                                                        flip_horizontally:  false,
                                                        flip_vertically:    false } },
                                          :idle_right

  args.state.player     = Player.new player_animation

  args.state.setup_done = true
end





def tick(args)
  
  # 1. Setup :
  setup(args) unless args.state.setup_done

  # 2. Actors Updates :
  args.state.background.update(args)
  args.state.ground.update(args)
  args.state.player.update(args)


  # 3. Render :
  
  # 3.1 Render to virtual 64x64 screen :
  args.render_target(:display).sprites << args.state.background.render
  args.render_target(:display).sprites << args.state.ground.render
  args.render_target(:display).sprites << args.state.player.render_at(8, 8)

  # 3.2 Render to DragonRuby window :
  args.outputs.solids   <<  [ 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0, 0, 255 ]
  args.outputs.sprites  <<  { x:      DISPLAY_X,
                              y:      DISPLAY_Y,
                              w:      DISPLAY_SIZE,
                              h:      DISPLAY_SIZE,
                              path:   :display,
                              tile_x: 0,
                              tile_y: 720 - DISPLAY_BASE_SIZE,
                              tile_w: DISPLAY_BASE_SIZE,
                              tile_h: DISPLAY_BASE_SIZE }

  ### DEBUG DEBUG DEBUG :
  #args.outputs.sprites << { x:200, y:200, w:1280, h:720, path: :procedural_background, tile_x:0, tile_y:0, tile_w:1280, tile_h:720 }
  #args.outputs.sprites << [ 100, 100, 256, 192, :bitmap_background ]

end
