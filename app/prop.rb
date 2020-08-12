class Prop

  # ---=== ACCESSORS : ===---
  attr_accessor :x, :y,
                :width, :height,
                :type,
                :action


  # ---=== INITIALIZATION : ===---
  def initialize(x,y,type,animation,size,offset,fsm,&action_block)
    @x, @y          = x, y
    @type           = type

    @animation      = animation

    @width, @height = size
    @offset         = offset

    @machine        = fsm
    @machine.set_parent self
    @machine.start

    @action         = action_block

    @used           = false
  end


  # ---=== UPDATE : ===---
  def update(args)
    @machine.update(args)
    @animation.update
  end


  # ---=== RENDER : ===---
  def render(args)
    @animation.frame_at( @x - args.state.ground.position, @y, false )
  end


  # ---=== STATE : ===---
  def use()   @used = true  end
  def used?() @used         end


  # ---=== UTILITIES : ===---
  def hit_box(offset)
    [ @x - offset, @y, @width, @height ]
  end


  # ---=== SERIALIZATION : ===---
  def serialize
    { x: @x, y: @y, state: @machine.current_state, clip: @animation.current_clip }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
