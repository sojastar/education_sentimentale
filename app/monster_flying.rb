class FlyingMonster < Monster

  # ---=== UPDATE : ===---
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
    @machine.set_current_state :stun if hit_box(args.state.ground.position).intersect_rect? args.state.player.hit_box

    @x += @dx
    @y += @dy

    @animation.update
  end


  # ---=== UTILITIES : ===---
  def hit_box(offset)
    [ @x + @hit_offset[0] - offset,
      @y + @hit_offset[1],
      @width,
      @height ]
  end
end
