require 'lib/fsm_machine.rb'
require 'lib/fsm_state.rb'
require 'lib/animation.rb'
require 'app/background.rb'
require 'app/background_layers.rb'
require 'app/tiled_background.rb'
require 'app/background_ground.rb'
require 'app/effect.rb'
require 'app/player.rb'
#require 'app/player_running_left_right.rb'
require 'app/player_always_running.rb'
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
  args.state.backgrounds  = Background::layers
  args.state.ground       = TiledBackground::ground


  # --- Player : ---
  args.state.player       = Player::always_running


  # --- MONSTERS : ---
  args.state.monsters     =  [ Monster::spawn_root_at(120) ]


  # --- EFFECTS : ---
  args.state.effects      = []


  # --- MISCELLANEOUS : ---
  args.state.debug_mode   = 0

  args.state.setup_done   = true
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

  args.state.effects.each { |effect| effect.update }
  args.state.effects  = remove_finished_effects(args.state.effects)


  # 3. Render :
  
  # 3.1 Render to the virtual 64x64 screen :
  args.state.backgrounds.each { |background| args.render_target(:display).sprites << background.render }
  args.render_target(:display).sprites << args.state.ground.render

  args.state.monsters.each { |monster| args.render_target(:display).sprites << monster.render(args) }

  args.render_target(:display).sprites << args.state.player.render

  args.state.effects.each { |effect| args.render_target(:display).sprites << effect.render(args) }

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

def remove_finished_effects(effects)
  effects.reject { |effect| effect.animation.status == :finished }
end
