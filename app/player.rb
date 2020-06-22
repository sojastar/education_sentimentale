class Player
  def initialize(animation)
    @animation = animation
  end

  def update(args)
    if args.inputs.keyboard.key_held.right then
      @animation.set_clip :walk_right if @animation.current_clip != @animation.clips[:walk_right]

    elsif args.inputs.keyboard.key_held.left then
      @animation.set_clip :walk_left  if @animation.current_clip != @animation.clips[:walk_left]

    else
      if  @animation.current_clip != @animation.clips[:idle_right]  ||
          @animation.current_clip == @animation.clips[:walk_right] then
        @animation.set_clip :idle_right 
        return
      end

      #if  @animation.current_clip != @animation.clips[:idle_left]   ||
      #    @animation.current_clip == @animation.clips[:walk_left] then
      #  @animation.set_clip :idle_left  
      #end

    end

    @animation.update
  end

  def render_at(x,y)
    @animation.frame_at x, y
  end

  def serialize
    {}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
