require 'lib/fsm_machine.rb'
require 'lib/fsm_state.rb'
require 'lib/animation.rb'
require 'app/background.rb'
require 'app/player.rb'
require 'app/monster.rb'
require 'app/monster_root.rb'

require 'app/debug.rb'





# ---=== CONSTANTS : ===---
MODE_COUNT        = 2

SCREEN_WIDTH      = 1280
SCREEN_HEIGHT     = 720

DISPLAY_BASE_SIZE = 64
DISPLAY_SCALE     = 4
DISPLAY_SIZE      = DISPLAY_SCALE * DISPLAY_BASE_SIZE
DISPLAY_X         = ( SCREEN_WIDTH  - DISPLAY_SIZE ) >> 1
DISPLAY_Y         = ( SCREEN_HEIGHT - DISPLAY_SIZE ) >> 1





# ---===  SETUP ===---
def setup(args)

  # --- Backgroound : ---
  args.render_target(:bitmap_background).sprites << { x:        0,
                                                      y:        0,
                                                      w:        256,
                                                      h:        192,
                                                      path:     'sprites/background_bitmaps.png',
                                                      source_x: 0,
                                                      source_y: 720-192,
                                                      source_w: 256,
                                                      source_h: 192 }

  args.state.backgrounds  = [ Background.new( 64,
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
  args.state.ground     = TileBackground.new( 64,
                                              64,
                                              { render_target_name: :ground,
                                                width:              256,
                                                height:             64,
                                                speed:              2 },
                                              { tiles:  { path:         'sprites/background_tiles.png',
                                                          size:         8 },
                                                groups: { horizontal:   { indices: [ 0, 1, 2, 3 ], offset: [ 1,  0 ] },
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
                                                fill:   [ 0, 1, 2, 3, 4, 5 ] } )


  # --- Player : ---
  player_frames         = { idle:         { frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0] ],
                                            mode:               :loop,
                                            speed:              6,
                                            flip_horizontally:  false,
                                            flip_vertically:    false },
                            run:          { frames:             [ [0,1], [1,1], [2,1], [3,1], [4,1], [5,1], [6,1], [7,1] ],
                                            mode:               :loop,
                                            speed:              6,
                                            flip_horizontally:  false,
                                            flip_vertically:    false },
                            walk:         { frames:             [ [0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2], [7,2], [8,2], [9,2], [10,2], [11,2] ],
                                            mode:               :loop,
                                            speed:              6,
                                            flip_horizontally:  false,
                                            flip_vertically:    false },
                            jump_up:      { frames:             [ [4,3], [5,3], [6,3] ],
                                            mode:               :once,
                                            speed:              6,
                                            flip_horizontally:  false,
                                            flip_vertically:    false },
                            jump_down:    { frames:             [ [7,3], [8,3], [9,3] ],
                                            mode:               :once,
                                            speed:              6,
                                            flip_horizontally:  false,
                                            flip_vertically:    false },
                            gun_attack:   { frames:             [ [0,5], [1,5], [2,5], [3,5] ],
                                            mode:               :once,
                                            speed:              3,
                                            flip_horizontally:  false,
                                            flip_vertically:    false },
                            sword_attack: { frames:             [ [0,4], [1,4], [2,4], [3,4] ],
                                            mode:               :once,
                                            speed:              5,
                                            flip_horizontally:  false,
                                            flip_vertically:    false },
                            hit:          { frames:             [ [0,6] ],
                                            mode:               :once,
                                            speed:              5,
                                            flip_horizontally:  false,
                                            flip_vertically:    false } }

  character_animation   = Animation.new 'sprites/all_body.png',
                                        48,
                                        32,
                                        player_frames,
                                        :idle

  weapon_animation      = Animation.new 'sprites/all_sword.png',
                                        48,
                                        32,
                                        player_frames,
                                        :idle
  weapons_list          = [ { path:       'sprites/all_sword.png',
                              collisions: [ [nil,nil, 8], [nil,nil, 8], [30,20, 8], [38, 5, 8] ],
                              speed:      5,
                              animation:  :sword_attack,
                              damage:     1 },
                            { path:       'sprites/all_axe.png',
                              collisions: [ [nil,nil,14], [nil,nil,14], [27,18,14], [30, 4,14] ],
                              speed:      8,
                              animation:  :sword_attack,
                              damage:     2 },
                            { path:       'sprites/all_gun.png',
                              speed:      3,
                              animation:  :gun_attack,
                              damage:     3 } ]

  args.state.player     = Player.new  character_animation,                          # animation...
                                      weapon_animation,     
                                      { true => [ -16, 0 ], false => [ -32, 0 ] },  # animation draw offset
                                      16,                                           # start x position
                                      65,                                           # start y position
                                      12,                                           # collision box width
                                      14,                                           # collision box height
                                      weapons_list

  # --- MONSTERS : ---
  args.state.monsters   =  [ Monster::spawn_root_at(120) ]

  # --- MISCELLANEOUS : ---
  args.state.debug_mode = 0

  args.state.setup_done = true
end





def tick(args)
  
  # 1. Setup :
  setup(args) unless args.state.setup_done

  # 2. Actors Updates :
  args.state.player.update(args)

  args.state.backgrounds.each { |background| background.update(args.state.player.dx) }
  args.state.ground.update(args.state.player.dx)

  args.state.monsters.each { |monster| monster.update(args) }
  args.state.monsters = remove_dead_monsters(args.state.monsters)


  # 3. Render :
  
  # 3.1 Render to the virtual 64x64 screen :
  args.state.backgrounds.each { |background| args.render_target(:display).sprites << background.render }
  args.render_target(:display).sprites << args.state.ground.render

  args.state.monsters.each { |monster| args.render_target(:display).sprites << monster.render(args) }

  args.render_target(:display).sprites << args.state.player.render

  # 3.2 Render debug visual aides if necessary :
  args.state.debug_mode = ( args.state.debug_mode + 1 ) % MODE_COUNT if args.inputs.keyboard.key_down.tab
  if args.state.debug_mode == 1 then
    Debug::draw_player_bounds [ 153, 229,  80, 255 ]
    Debug::draw_player_v      [  91, 110, 225, 255 ], [  95, 205, 228, 255 ]
    #Debug::draw_tiles_bounds  [ 217,  87,  99, 125 ]
    Debug::draw_bounds args.state.monsters.first, args.state.ground.position, [229, 153, 80, 255]
  end

  # 3.3 Render to DragonRuby window :
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

  # 4. Other :
  args.outputs.labels << [ 20, 700, "space: jump - c: shoot gun - x: swing sword - w: switch sword", 255, 255, 255, 255 ]
end

def remove_dead_monsters(monsters)
  monsters.reject { |monster| monster.current_state == :dead }
end
