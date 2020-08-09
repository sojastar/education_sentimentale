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
require 'app/monster_walking.rb'
require 'app/monster_root.rb'
require 'app/monster_rampant.rb'
require 'app/monster_flying.rb'
require 'app/monster_floating_eye.rb'

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
  layers                  = Background::layers
  args.state.back         = layers[0,3]
  args.state.front        = layers[3,1]
  args.state.ground       = TiledBackground::ground


  # --- Player : ---
  args.state.player       = Player::always_running


  # --- MONSTERS : ---
  #args.state.monsters     =  [ WalkingMonster::spawn_root_at(120) ]
  #args.state.monsters     =  [ WalkingMonster::spawn_rampant_at(120) ]
  args.state.monsters     = [ FlyingMonster::spawn_floating_eye_at(160, 8 * ( 1 + rand(4) ) ) ] 
  args.state.spawned_monsters = 1


  # --- EFFECTS : ---
  args.state.effects      = []


  # --- SCENE MANAGEMENT : ---
  args.state.scene        = :game


  # --- MISCELLANEOUS : ---
  args.state.debug_mode   = 0

  args.state.setup_done   = true
end





# ---=== MAIN LOOP : ==---
def tick(args)
  
  # 1. Setup :
  setup(args) unless args.state.setup_done


  case args.state.scene
  when :start_screen

  when :game

    # 2. Actors Updates :
    args.state.player.update(args)

    args.state.back.each { |layer| layer.update(args.state.player.dx) }
    args.state.front.each { |layer| layer.update(args.state.player.dx) }
    args.state.ground.update(args.state.player.dx)

    args.state.monsters.each { |monster| monster.update(args) }
    args.state.monsters = remove_dead_monsters(args.state.monsters)
    args.state.monsters = remove_passed_monsters(args.state.monsters, args.state.ground.position)
    #args.outputs.labels << [ 20, 680, "monsters: #{args.state.monsters.length}", 255, 255, 255, 255 ]

    args.state.effects.each { |effect| effect.update }
    args.state.effects  = remove_finished_effects(args.state.effects)

    args.state.scene = :game_over if args.state.player.health == 0


    # 3. Render :
    
    # 3.1 Render to the virtual 64x64 screen :
    args.state.back.each { |layer| args.render_target(:display).sprites << layer.render }
    args.render_target(:display).sprites << args.state.ground.render

    args.state.monsters.each { |monster| args.render_target(:display).sprites << monster.render(args) }

    args.render_target(:display).sprites << args.state.player.render

    args.state.effects.each { |effect| args.render_target(:display).sprites << effect.render(args) }

    args.state.front.each { |layer| args.render_target(:display).sprites << layer.render }

    args.state.player.health.times do |i|
      args.render_target(:display).sprites << { x:    9 * i,
                                                y:    54,
                                                w:    8,
                                                h:    8,
                                                path: 'sprites/life_8px.png' }
    end

    # 3.2 Render debug visual aides if necessary :
    args.state.debug_mode = ( args.state.debug_mode + 1 ) % MODE_COUNT if args.inputs.keyboard.key_down.tab
    if args.state.debug_mode == 1 then
      Debug::draw_box args.state.player.hit_box, [ 153, 229,  80, 255 ]
      Debug::draw_player_v      [  91, 110, 225, 255 ], [  95, 205, 228, 255 ]
      #Debug::draw_tiles_bounds  [ 217,  87,  99, 125 ]
      args.state.monsters.each { |monster| Debug::draw_box monster.hit_box(args.state.ground.position), [229, 153, 80, 255] }
    end


    # 4. Basic Spawning Algorithm :
    if args.state.monsters.empty? then
      args.state.spawned_monsters += 1
      spawn_x = ( args.state.ground.position + 80 ) % args.state.ground.width
      case rand(2)
      when 0
        puts "--- spawned rampant at #{spawn_x} (#{args.state.spawned_monsters}) !!!"
        args.state.monsters << WalkingMonster::spawn_rampant_at( spawn_x ) 
      when 1
        puts "--- spawned floating eye at #{spawn_x} (#{args.state.spawned_monsters}) !!!"
        args.state.monsters << FlyingMonster::spawn_floating_eye_at( spawn_x, 8 * ( 1 + rand(4) ) )
      end
    end


    # 5. Other :
    args.outputs.labels << [ 20, 700, "space: jump - c: shoot gun - x: swing sword - w: switch sword", 255, 255, 255, 255 ]

  when :game_over
    args.render_target(:display).labels << {  x: 2,
                                              y: 22,
                                              text: "Game Over",
                                              size_enum:  -8,
                                              r: 255,
                                              g: 0,
                                              b: 0,
                                              a: 255,
                                              font: "fonts/hotchili.ttf" }

    args.state.scene = :start_screen if args.inputs.keyboard.key_down.space

  end


  # 6. Render to DragonRuby window :
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





# ---=== UTILITIES : ===---
def remove_dead_monsters(monsters)
  monsters.reject { |monster| monster.current_state == :dead }
end

def remove_passed_monsters(monsters,offset)
  monsters.reject { |monster| monster.x - offset < -monster.width }
end

def remove_finished_effects(effects)
  effects.reject { |effect| effect.animation.status == :finished }
end
