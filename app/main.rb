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
  args.state.background = Background.new  'sprites/background.png',
                                          64,
                                          64,
                                          [ { width:    256,
                                              height:   64,
                                              speed:    32 },
                                            { width:    256,
                                              height:   64,
                                              speed:    16 },
                                            { width:    256,
                                              height:   64,
                                              speed:    8 } ]

  #player_animation      = Animation.new 'sprites/walking_man.png',
  player_animation      = Animation.new 'sprites/guy.png',
                                        16,#32,
                                        16,#32,
                                        #{ idle_right: { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0] ],
                                        { idle_right: { frames:             [ [0,2] ],
                                                        mode:               :loop,
                                                        speed:              6,
                                                        flip_horizontally:  false,
                                                        flip_vertically:    false },
                                          #idle_left:  { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0] ],
                                          idle_left:  { frames:             [ [0,2] ],
                                                        mode:               :loop,
                                                        speed:              6,
                                                        flip_horizontally:  true,
                                                        flip_vertically:    false },
                                          #walk_right: { frames:             [ [0,1], [1,1], [2,1], [3,1], [4,1], [5,1], [6,1], [7,1], [8,1], [9,1], [10,1], [11,1] ], # Walking right
                                          walk_right: { frames:             [ [0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2], [7,2], [8,2], [9,2], [10,2], [11,2] ], # Walking right
                                                        mode:               :loop,
                                                        speed:              6,
                                                        flip_horizontally:  false,
                                                        flip_vertically:    false },
                                          #walk_right: { frames:             [ [0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2], [7,2], [8,2], [9,2], [10,2], [11,2] ], # Walking right
                                          walk_left:  { frames:             [ [0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2], [7,2], [8,2], [9,2], [10,2], [11,2] ], # Walking right
                                                        mode:               :loop,
                                                        speed:              6,
                                                        flip_horizontally:  true,
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
  args.state.player.update(args)


  # 3. Render :
  
  # 3.1 Render to virtual 64x64 screen :
  args.render_target(:display).sprites << args.state.background.render
  args.render_target(:display).sprites << args.state.player.render_at(24, 4)

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

end
