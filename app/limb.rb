class Limb
  def initialize(x,y,offset_x,offset_y,scale,color_shift,animation,hit_boxes)
    @x, @y          = x, y      # as an offset to the parents position
    @offset_x       = offset_x
    @offset_y       = offset_y

    @scale          = scale

    @color_shift    = color_shift

    @animation      = animation
    @animation.random_start_frame

    @hit_boxes      = hit_boxes
    @hit_box_index  = 0
  end

  def update(args)
    @animation.update
    @hit_boxes_index = ( @hit_boxes_index + 1 ) % @hit_boxes.length
  end

  def render(args,parent_x,parent_y)
    frame     = @animation.scaled_frame_at( @x + parent_x - @offset_x, @y + parent_y - @offset_y, false, @scale )
    frame[:r] = @color_shift[0]
    frame[:g] = @color_shift[1]
    frame[:b] = @color_shift[2]

    frame
  end

  def set_clip(clip)
    @animation.set_clip clip
  end

  def hit_box
    @hit_boxes[@hit_boxes_index]
  end

  def serialize
    { x: @x, y: @y, scale: @scale, color_shift: @color_shift }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
