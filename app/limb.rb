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

  def randomize_animation_frame
    @animation.random_start_frame
  end

  def hit_box(parent,offset)
    x = @hit_boxes[@animation.frame_index][0] + @x + parent.x + parent.animation_offset[parent.facing_right][0] - @offset_x - offset
    y = @hit_boxes[@animation.frame_index][1] + @y + parent.y - @offset_y
    w = @hit_boxes[@animation.frame_index][2]
    h = @hit_boxes[@animation.frame_index][3]

    [ x, y, w, h ]
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
