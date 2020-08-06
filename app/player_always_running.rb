class Player
  def self.always_running

    # ---=== ANIMATIONS : ===---
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


    # ---=== WEAPONS : ===---
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


    # ---=== FINITE STATE MACHINE : ===---
    fsm                   = FSM::new_machine(nil) do    # nil, because the parent object is not created yet
                              add_state(:running) do
                                define_setup do
                                  @character_animation.set_clip  :run

                                  @current_weapon               = @current_sword
                                  @weapon_animation.set_clip      :run
                                  @weapon_animation.path        = @weapons[@current_weapon][:path]
                                end

                                add_event(next_state: :jumping_up) do |args|
                                  args.inputs.keyboard.key_down.space
                                end

                                add_event(next_state: :swing) do |args|
                                  args.inputs.keyboard.key_down.x
                                end

                                add_event(next_state: :shoot) do |args|
                                  args.inputs.keyboard.key_down.c
                                end
                              end

                              add_state(:jumping_up) do
                                define_setup do
                                  @dy = JUMP_STRENGTH
                                  @character_animation.set_clip  :jump_up
                                  @weapon_animation.set_clip     :jump_up
                                end

                                add_event(next_state: :jumping_down) do |args|
                                  @dy <= 0
                                end
                              end

                              add_state(:jumping_down) do
                                define_setup do
                                  @character_animation.set_clip  :jump_down
                                  @weapon_animation.set_clip     :jump_down
                                end

                                add_event(next_state: :running) do |args|
                                  @dy == 0 && ( @y % 8 ) == 0
                                end

                                #add_event(next_state: :hit) do |args|
                                #  @hit == true
                                #end
                              end

                              add_state(:swing) do
                                define_setup do
                                  @current_weapon               = @current_sword
                                  @character_animation.set_clip   @weapons[@current_weapon][:animation]
                                  @character_animation.speed    = @weapons[@current_weapon][:speed]
                                  @weapon_animation.set_clip      @weapons[@current_weapon][:animation]
                                  @weapon_animation.speed       = @weapons[@current_weapon][:speed]
                                  @weapon_animation.path        = @weapons[@current_weapon][:path]
                                end

                                add_event(next_state: :running) do |args|
                                  @character_animation.status == :finished
                                end
                              end

                              add_state(:shoot) do
                                define_setup do
                                  @current_weapon               = @weapons.length - 1     # the gun is always the last weapon
                                  @character_animation.set_clip   @weapons[@current_weapon][:animation]
                                  @character_animation.speed    = @weapons[@current_weapon][:speed]
                                  @weapon_animation.set_clip      @weapons[@current_weapon][:animation]
                                  @weapon_animation.speed       = @weapons[@current_weapon][:speed]
                                  @weapon_animation.path        = @weapons[@current_weapon][:path]
                                end

                                add_event(next_state: :running) do |args|
                                  @character_animation.status == :finished
                                end
                              end

                              add_state(:hit) do
                                define_setup do
                                  @character_animation.set_clip :hit
                                  @weapon_animation.set_clip    :hit
                                end

                                add_event(next_state: :running) do |args|
                                  @recovery_timer <= 0
                                end
                              end

                              set_initial_state :jumping_down
                            end

    # ---=== INSTANTIATION : ===---
    Player.new  character_animation,                          # animation...
                weapon_animation,     
                { true => [ -16, 0 ], false => [ -32, 0 ] },  # animation draw offset
                16,                                           # start x position
                65,                                           # start y position
                12,                                           # collision box width
                14,                                           # collision box height
                weapons_list,
                fsm
  end
end
