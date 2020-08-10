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
require 'app/prop.rb'
require 'app/prop_hotdog.rb'
require 'app/prop_door.rb'

require 'app/debug.rb'





# ---=== CONSTANTS : ===---
MODE_COUNT        = 2

SCREEN_WIDTH      = 1280
SCREEN_HEIGHT     = 720

DISPLAY_BASE_SIZE = 64
DISPLAY_SCALE     = 6
DISPLAY_SIZE      = DISPLAY_SCALE * DISPLAY_BASE_SIZE
DISPLAY_X         = ( SCREEN_WIDTH  - DISPLAY_SIZE ) >> 1
DISPLAY_Y         = ( SCREEN_HEIGHT - DISPLAY_SIZE ) >> 1

SPAWN_DISTANCE    = 80

LEVELS            = [ { min_length:   200,
                        bitmaps:      'sprites/field_background_bitmaps.png',
                        tiles:        'sprites/field_background_tiles.png',
                        spawn_probs:  [ { range: 0...0.85,  monster: :floating_eye },
                                        { range: 0.85..1.0, monster: :rampant } ] },
                      { min_length:   200,
                        bitmaps:      'sprites/temple_background_bitmaps.png',
                        tiles:        'sprites/temple_background_tiles.png',
                        spawn_probs:  [ { range: 0...0.5,  monster: :floating_eye },
                                        { range: 0.5..1.0, monster: :rampant } ] } ]





# ---===  SETUP ===---
def setup(args)

  # --- SCENE MANAGEMENT : ---
  args.state.scene        = :start_screen
  args.state.level        = 0


  # --- MISCELLANEOUS : ---
  args.state.debug_mode   = 0

  args.state.setup_done   = true

end


def setup_level(args,level)

  # --- Backgroound : ---
  layers                  = Background::layers( level[:bitmaps] )
  args.state.back         = layers[0,3]
  args.state.front        = layers[3,1]
  args.state.ground       = TiledBackground::ground( level[:tiles], level[:min_length] )


  # --- Player : ---
  args.state.player       = Player::always_running


  # --- MONSTERS : ---
  #args.state.monsters     =  [ WalkingMonster::spawn_root_at(120) ]
  #args.state.monsters     =  [ WalkingMonster::spawn_rampant_at(120) ]
  args.state.monsters     = [ FlyingMonster::spawn_floating_eye_at(160, 8 * ( 1 + rand(4) ) ) ] 


  # --- PROPS : ---

  # We need to spawn the door on a large enough surface :
  ( args.state.ground.collision_tiles.length - 4 ).downto(0) do |i|
    if args.state.ground.collision_tiles[i] == args.state.ground.collision_tiles[i-1] then
      offset_x            = ( args.state.ground.collision_tiles.length - i ) * 8 
      offset_y            = ( args.state.ground.collision_tiles[i] + 1 ) * 8
      args.state.door     = Prop::spawn_door_at args.state.ground.width - offset_x, offset_y
      break
    end
  end

  args.state.props        = []


  # --- EFFECTS : ---
  args.state.effects      = []

end





# ---=== MAIN LOOP : ==---
def tick(args)

  # --- Setup :
  setup(args) unless args.state.setup_done


  case args.state.scene
  when :start_screen
    args.render_target(:display).labels << {  x: 2,
                                              y: 22,
                                              text: "Press Start",
                                              size_enum:  -8,
                                              r: 255,
                                              g: 255,
                                              b: 255,
                                              a: 255,
                                              font: "fonts/hotchili.ttf" }

    if args.inputs.keyboard.key_down.space then
      setup_level( args, LEVELS[args.state.level] )
      args.state.scene = :game 
    end

  when :game

    # 1. Actors Updates :
    args.state.player.update(args)

    args.state.back.each { |layer| layer.update(args.state.player.dx) }
    args.state.front.each { |layer| layer.update(args.state.player.dx) }
    args.state.ground.update(args.state.player.dx)

    args.state.monsters.each { |monster| monster.update(args) }
    args.state.monsters = remove_dead_monsters(args)
    args.state.monsters = remove_passed_monsters(args)
    
    args.state.door.update(args)

    args.state.props.each { |prop| prop.update(args) }
    args.state.props    = remove_used_props(args.state.props)

    args.state.effects.each { |effect| effect.update }
    args.state.effects  = remove_finished_effects(args.state.effects)

    #args.state.scene = :game_over if args.state.player.health == 0


    # 2. Render :
    
    # 2.1 Render to the virtual 64x64 screen :
    args.state.back.each { |layer| args.render_target(:display).sprites << layer.render }
    args.render_target(:display).sprites << args.state.ground.render

    args.render_target(:display).sprites << args.state.door.render(args)

    args.state.monsters.each { |monster| args.render_target(:display).sprites << monster.render(args) }

    args.state.props.each { |prop| args.render_target(:display).sprites << prop.render(args) }

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

    # 2.2 Render debug visual aides if necessary :
    args.state.debug_mode = ( args.state.debug_mode + 1 ) % MODE_COUNT if args.inputs.keyboard.key_down.tab
    if args.state.debug_mode == 1 then
      Debug::draw_box args.state.player.hit_box, [ 153, 229,  80, 255 ]
      Debug::draw_player_v      [  91, 110, 225, 255 ], [  95, 205, 228, 255 ]
      #Debug::draw_tiles_bounds  [ 217,  87,  99, 125 ]
      args.state.monsters.each { |monster| Debug::draw_box monster.hit_box(args.state.ground.position), [229, 153, 80, 255] }
    end


    # 3. Spawning :
    args.state.monsters << spawn_monster(args) if args.state.monsters.empty?


    # 4. Death or Next Level :
    if  args.state.player.current_state     == :dying     &&
        args.state.player.animation_status  == :finished  then
      args.state.scene  = :game_over
    end

    if  args.state.player.current_state     == :shifting  &&
        args.state.player.animation_status  == :finished  then
      args.state.scene  = :next_level
    end


    # 5. Other :
    args.outputs.labels << [ 20, 700, "space: jump - c: shoot gun - x: swing sword - w: switch sword", 255, 255, 255, 255 ]


  when :next_level
    args.state.level += 1

    if args.state.level < LEVELS.length then
      setup_level( args, LEVELS[args.state.level] )
      args.state.scene  = :game 

    else
      args.state.scene  = :victory

    end


  when :victory
    args.render_target(:display).labels << {  x: 2,
                                              y: 22,
                                              text: "THE END!!!",
                                              size_enum:  -8,
                                              r: 255,
                                              g: 0,
                                              b: 0,
                                              a: 255,
                                              font: "fonts/hotchili.ttf" }

    args.state.scene = :start_screen if args.inputs.keyboard.key_down.space


  when :game_over
    args.render_target(:display).labels << {  x: 2,
                                              y: 22,
                                              text: "GAME OVER",
                                              size_enum:  -8,
                                              r: 255,
                                              g: 0,
                                              b: 0,
                                              a: 255,
                                              font: "fonts/hotchili.ttf" }

    args.state.scene = :start_screen if args.inputs.keyboard.key_down.space

  end


  # --- Render to DragonRuby window :
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
def spawn_monster(args)
  spawn_x = ( args.state.ground.position + SPAWN_DISTANCE ) % args.state.ground.width
  roll    = rand
  LEVELS[args.state.level][:spawn_probs].each do |prob|
    return spawn_type( prob[:monster], spawn_x ) if prob[:range] === roll
  end
end

def spawn_type(type,x)
  case type
  when :floating_eye  then FlyingMonster::spawn_floating_eye_at( x, 8 * ( 1 + rand(4) ) )
  when :rampant       then WalkingMonster::spawn_rampant_at( x )
  end
end

def remove_dead_monsters(args)
  args.state.monsters.reject do |monster| 
    if monster.current_state == :dead then
      args.state.props << Prop.spawn_hotdog_at( monster.x + monster.hit_offset[0],
                                                monster.y + monster.hit_offset[1] )
      true
    end
  end
end

def remove_passed_monsters(args)
  args.state.monsters.reject { |monster| monster.x - args.state.ground.position < -monster.width }
end

def remove_finished_effects(effects)
  effects.reject { |effect| effect.animation.status == :finished }
end

def remove_used_props(props)
  props.reject { |prop| prop.used? }
end
