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
require 'app/monster_mushroom.rb'
require 'app/monster_flying.rb'
require 'app/monster_floating_eye.rb'
require 'app/limb.rb'
require 'app/limb_scorpio.rb'
require 'app/limb_pimple.rb'
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

COMMANDS_DELAY    = 3     # in seconds
HINTS_DELAY       = 3     # in seconds
START_DELAY       = 60    # in frames
END_SCROLL_DELAY  = 3     # in second
END_SCROLL_HEIGHT = 261   # in pixels

INITIAL_HEALTH    = 3

LEVELS            = [ { min_length:     400,
                        bitmaps:        'sprites/field_background_bitmaps.png',
                        tiles:          'sprites/field_background_tiles.png',
                        difficulty:     0,
                        spawn_probs:    [ { range: 0.0...0.5, monsters: [ "FlyingMonster::spawn_floating_eye_at(x, 8 * ( 1 + rand(3) ))"  ] },
                                          { range: 0.5...0.8, monsters: [ "WalkingMonster::spawn_mushroom_at(x)"                          ] },
                                          { range: 0.8..1.0,  monsters: [ "WalkingMonster::spawn_rampant_at(x,0)"                         ] } ],
                        spawn_distance: 100 },
                      { min_length:     600,
                        bitmaps:        'sprites/temple_background_bitmaps.png',
                        tiles:          'sprites/temple_background_tiles.png',
                        difficulty:     1,
                        spawn_probs:    [ { range: 0.0...0.2, monsters: [ "FlyingMonster::spawn_floating_eye_at(x, 8 * ( 1 + rand(3) ))"  ] },
                                          { range: 0.2...0.4, monsters: [ "WalkingMonster::spawn_mushroom_at(x)"                          ] },
                                          { range: 0.4...0.6, monsters: [ "WalkingMonster::spawn_rampant_at(x,2)"                         ] },
                                          { range: 0.6..1.0,  monsters: [ "WalkingMonster::spawn_rampant_at(x,1)",
                                                                          "FlyingMonster::spawn_floating_eye_at(x, 8 * ( 1 + rand(3) ))"  ] } ],
                        spawn_distance: 120 },
                      { min_length:     800,
                        bitmaps:        'sprites/hell_background_bitmaps.png',
                        tiles:          'sprites/hell_background_tiles.png',
                        difficulty:     1,
                        spawn_probs:    [ { range: 0.0...0.15,  monsters: [ "FlyingMonster::spawn_floating_eye_at(x, 8 * ( 1 + rand(3) ))"  ] },
                                          { range: 0.15...0.25, monsters: [ "WalkingMonster::spawn_mushroom_at(x)"                          ] },
                                          { range: 0.25...0.4,  monsters: [ "WalkingMonster::spawn_rampant_at(x,2)"                         ] },
                                          { range: 0.4...0.55,  monsters: [ "WalkingMonster::spawn_rampant_at(x,3)"                         ] },
                                          { range: 0.55...0.7,  monsters: [ "WalkingMonster::spawn_root_at(x,3)"                            ] },
                                          { range: 0.7...85,    monsters: [ "WalkingMonster::spawn_rampant_at(x,1)",
                                                                            "FlyingMonster::spawn_floating_eye_at(x, 8 * ( 1 + rand(3) ))"  ] },
                                          { range: 0.85..1.0,   monsters: [ "WalkingMonster::spawn_root_at(x,2)",
                                                                            "FlyingMonster::spawn_floating_eye_at(x, 8 * ( 1 + rand(3) ))"  ] } ],
                        spawn_distance: 120 } ]





# ---===  SETUP ===---
def setup(args)

  # --- SCENE MANAGEMENT : ---
  args.state.scene        = :commands
  args.state.start_pushed = false


  # --- MISCELLANEOUS : ---
  args.state.debug_mode   = 0

  args.state.setup_done   = true

end


def setup_level(args,level,health)

  # --- Backgroound : ---
  layers                  = Background::layers( level[:bitmaps] )
  args.state.back         = layers[0,3]
  args.state.front        = layers[3,1]
  args.state.ground       = TiledBackground::ground( level[:tiles], level[:min_length] )


  # --- Player : ---
  args.state.player       = Player::always_running(health)


  # --- MONSTERS : ---
  args.state.monsters     = []


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


  # --- Main Loop :
  case args.state.scene
  when :commands
    args.render_target(:display).solids  << { x: 0, y: 0, w: 64, h: 64, r:0, g:0, b:0, a:255 }

    case args.state.tick_count
    when 0..63
      args.render_target(:display).sprites << { x: 0, y: 0, w: 64, h: 64, path: 'sprites/commands.png', r: 255, g: 255, b: 255, a: 4 * args.state.tick_count }

    when 64...(64 + COMMANDS_DELAY * 60)
      args.render_target(:display).sprites << { x: 0, y: 0, w: 64, h: 64, path: 'sprites/commands.png' }

    when (64 + COMMANDS_DELAY * 60)..(127 + COMMANDS_DELAY * 60)
      args.render_target(:display).sprites << { x: 0, y: 0, w: 64, h: 64, path: 'sprites/commands.png', r: 255, g: 255, b: 255, a: 255 - 4 * ( args.state.tick_count - 64 - COMMANDS_DELAY * 60 ) }

    else
      args.state.scene = :hints

    end


  when :hints
    args.render_target(:display).solids  << { x: 0, y: 0, w: 64, h: 64, r:0, g:0, b:0, a:255 }

    case args.state.tick_count
    when (127 + COMMANDS_DELAY * 60)..(127 + 63 + COMMANDS_DELAY * 60)
      args.render_target(:display).sprites << { x: 0, y: 0, w: 64, h: 64, path: 'sprites/hints.png', r: 255, g: 255, b: 255, a: 4 * ( args.state.tick_count - (127 + COMMANDS_DELAY * 60) ) }

    when (127 + 64 + COMMANDS_DELAY * 60)...(127 + 64 + ( COMMANDS_DELAY + HINTS_DELAY ) * 60)
      args.render_target(:display).sprites << { x: 0, y: 0, w: 64, h: 64, path: 'sprites/hints.png' }

    when (127 + 64 + ( COMMANDS_DELAY + HINTS_DELAY ) * 60)..(127 + 127 + ( COMMANDS_DELAY + HINTS_DELAY ) * 60)
      args.render_target(:display).sprites << { x: 0, y: 0, w: 64, h: 64, path: 'sprites/hints.png', r: 255, g: 255, b: 255, a: 255 - 4 * ( args.state.tick_count - (127 + 64 + ( COMMANDS_DELAY + HINTS_DELAY ) * 60) ) }

    else
      args.state.scene = :start_screen

    end


  when :start_screen
    $gtk.stop_music
    args.render_target(:display).sprites << {  x: 0, y:  0, w: 64, h: 64, path: 'sprites/field_background_bitmaps.png', source_x: 0, source_y: 192, source_w: 64, source_h: 64 }
    args.render_target(:display).sprites << {  x: 0, y:  0, w: 64, h: 64, path: 'sprites/field_background_bitmaps.png', source_x: 0, source_y: 128, source_w: 64, source_h: 64 }
    args.render_target(:display).sprites << {  x: 0, y:  0, w: 64, h: 64, path: 'sprites/field_background_bitmaps.png', source_x: 0, source_y:  64, source_w: 64, source_h: 64 }
    args.render_target(:display).sprites << {  x: 0, y:  0, w: 64, h:  8, path: 'sprites/field_start_tiles.png' }
    args.render_target(:display).sprites << {  x: 4, y: 41, w: 56, h: 16, path: 'sprites/title.png', source_x: ( ( args.state.tick_count >> 3 ) % 32 ) * 56, source_y: 0, source_w: 56, source_h: 16 }
    args.render_target(:display).sprites << {  x: 0, y:  0, w: 64, h: 64, path: 'sprites/field_background_bitmaps.png', source_x: 0, source_y:   0, source_w: 64, source_h: 64 }
    args.render_target(:display).sprites << {  x: 0, y:  0, w: 32, h:  7, path: 'sprites/version.png' }

    if args.state.start_pushed == false then
      args.render_target(:display).sprites << {  x: 4, y: 12, w: 56, h:  5, path: 'sprites/press_start.png' } if ( ( args.state.tick_count >> 5 ) % 2 == 0 )

      if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.start
        args.state.start_pushed = true 
        args.state.start_time   = args.state.tick_count
        args.outputs.sounds << 'sounds/start.wav'
      end

    else
      args.render_target(:display).sprites << {  x: 4, y: 12, w: 56, h:  5, path: 'sprites/press_start.png' } if ( ( args.state.tick_count >> 2 ) % 2 == 0 )

      if args.state.tick_count - args.state.start_time > START_DELAY then
        args.state.level  = 0
        setup_level( args, LEVELS[args.state.level], INITIAL_HEALTH )
        args.outputs.sounds << 'sounds/win_soft.ogg'
        args.state.scene  = :game 
      end
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
    #args.state.debug_mode = ( args.state.debug_mode + 1 ) % MODE_COUNT if args.inputs.keyboard.key_down.tab
    #if args.state.debug_mode == 1 then
    #  Debug::draw_box args.state.player.hit_box, [ 153, 229,  80, 255 ]
    #  Debug::draw_player_v      [  91, 110, 225, 255 ], [  95, 205, 228, 255 ]
    #  args.state.monsters.each do |monster|
    #    Debug::draw_box( monster.hit_box(args.state.ground.position), [229, 153, 80, 255] )
    #    monster.limbs.each do |limb|
    #      Debug::draw_box( limb.hit_box(monster,args.state.ground.position), [ 210, 80, 234, 255 ] )
    #    end
    #  end
    #end


    # 3. Spawning :
    args.state.monsters += spawn_monsters(args) if args.state.monsters.empty?


    # 4. Death or Next Level :
    if  args.state.player.current_state     == :dying     &&
        args.state.player.animation_status  == :finished  then
      args.state.scene          = :game_over
      args.state.game_over_time = args.state.tick_count
    end

    if  args.state.player.current_state     == :shifting  &&
        args.state.player.animation_status  == :finished  then
      args.state.scene          = :next_level
    end


  when :next_level
    args.state.level += 1

    if args.state.level < LEVELS.length then
      next_health               = args.state.player.health < 3 ? 3 : args.state.player.health
      setup_level( args, LEVELS[args.state.level], next_health )
      args.state.scene          = :game 

    else
      args.state.scene          = :end
      args.state.end_start_time = args.state.tick_count

    end


  when :end
    if args.state.tick_count - args.state.end_start_time < END_SCROLL_DELAY * 60 then
      y_offset  = END_SCROLL_HEIGHT - 64
    else
      y_offset  = END_SCROLL_HEIGHT - 64 - ( ( args.state.tick_count - args.state.end_start_time - END_SCROLL_DELAY * 60 ) >> 4 )
    end
    args.render_target(:display).sprites << { x: 0, y: 0, w: 64, h: 64, path: 'sprites/end.png', source_x: 0, source_y: y_offset, source_w: 64, source_h: 64 }

    if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.start || y_offset == 0 then
      args.state.scene        = :start_screen 
      args.state.start_pushed = false
    end


  when :game_over
    $gtk.stop_music
    x_index = ( args.state.tick_count - args.state.game_over_time >> 2 ) % 23
    y_index = ( args.state.tick_count - args.state.game_over_time >> 2 ) < 23 ? 1 : 0
    args.render_target(:display).sprites << { x: 0, y: 0, w: 64, h: 64, path: "sprites/game_over.png", source_x: x_index * 64, source_y: y_index * 64, source_w: 64, source_h: 64 }

    if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.start then
      args.state.scene = :start_screen 
      args.state.start_pushed = false
    end

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
def spawn_monsters(args)
  spawn_x = ( args.state.ground.position + LEVELS[args.state.level][:spawn_distance] ) % args.state.ground.width
  roll    = rand
  LEVELS[args.state.level][:spawn_probs].each do |prob|
    if prob[:range] === roll then
      return prob[:monsters].map.with_index { |monster,i| eval( monster.gsub 'x', ( spawn_x + 20 * i ).to_s ) } 
    end
  end
end

def remove_dead_monsters(args)
  args.state.monsters.reject do |monster|
    if monster.current_state == :dead then
      if rand > 0.7 then
        args.state.props << Prop.spawn_hotdog_at( monster.x + monster.hit_offset[0],
                                                  monster.y + monster.hit_offset[1] )
      end
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
