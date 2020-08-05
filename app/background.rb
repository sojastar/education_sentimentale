class Background
  attr_reader :position

  def initialize(render_width,render_height,description)
    description.each_pair do |key,value|
      variable_name = '@' + key.to_s
      instance_variable_set variable_name, value
    end

    @render_width   = render_width
    @render_height  = render_height

    @tick           = 0
    @position       = 0
  end

  def update(dx)
    if dx > 0 then
      @tick += dx

      if @tick >= @speed then
        @tick      = 0
        @position  = ( @position + 1 ) % @width
      end

    elsif dx < 0 then
      @tick += -dx

      if @tick >= @speed then
        @tick      = 0
        @position -= 1
        @position  = @width - 1 if @position == -1
      end

    end
  end

  def render
    if @width - @position > @render_width then
      [ { x:        0,
          y:        0,
          w:        @render_width,
          h:        @render_height,
          path:     @path,
          source_x: @position,
          source_y: @y_offset,
          source_w: @render_width,
          source_h: @render_height } ]

    else
      [ { x:        0,
          y:        0,
          w:        @width - @position,
          h:        @render_height,
          path:     @path,
          source_x: @position,
          source_y: @y_offset,
          source_w: @width - @position,
          source_h: @render_height },
        { x:        @width - @position,
          y:        0,
          w:        @render_width - @width + @position,
          h:        @render_height,
          path:     @path,
          source_x: 0,
          source_y: @y_offset,
          source_y: @y_offset,
          source_w: @render_width - @width + @position,
          source_h: @render_height } ]
    end
  end

  def serialize
    { width: @width, height: @height, path: @path, speed: @speed, tick: @tick, position: @position }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
