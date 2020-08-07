class FlyingMonster < Monster
  def update(args)
    @children.each { |child| child.update(args) } unless @children.nil?
    @machine.update(args)
    
    # --- Check for death :
    if @machine.current_state == :dying then
      @animation.update
      return
    end

    # --- Movement :
    @dx = 0
    @dy = 0
    case @machine.current_state
    when :flying
      # AI code that moves the monster, in relation to @machine
      @tick            += 1
      if @tick == @running_speed then
        @dx   = @facing_right ? 1 : -1
        @tick = 0
      end

    when :stun, :hit
      @recovery_timer  -= 1
      @dx               = @facing_right ? -@push_back_speed : @push_back_speed

    end

    # --- Player collisions :
    #player                    = args.state.player
    #player_hit_box            = [ player.x - ( player.width >> 1 ),
    #                              player.y,
    #                              player.width,
    #                              player.height ]

    ##monster_hit_box           = [ @x - ( @width >> 1 ) - args.state.ground.position,
    #monster_hit_box           = [ @x - ( @width >> 1 ) - 8 - args.state.ground.position,
    #                              @y + 12,
    #                              @width,
    #                              @height ]

    #Debug::draw_box monster_hit_box, [229, 153, 80, 255] if args.state.debug_mode == 1

    #@machine.set_current_state :stun if monster_hit_box.intersect_rect? player_hit_box
    @machine.set_current_state :stun if hit_box(args.state.ground.position).intersect_rect? args.state.player.hit_box

    @x += @dx
    @y += @dy

    @animation.update
  end

  def hit_box(offset)
    [ @x + @hit_offset[0] - offset,
      @y + @hit_offset[1],
      @width,
      @height ]
  end
end
