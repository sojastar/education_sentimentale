class Background
  def initialize(path,width,height,layers)
    @path     = path

    y_offset  = 0
    @layers   = layers.map do |layer|
                  new_layer = { width:    layer[:width],
                                height:   layer[:height],
                                y_offset: y_offset,
                                speed:    layer[:speed],
                                tick:     0,
                                position: 0 }
                  y_offset += layer[:height]
                  new_layer
                end

    @width  = width
    @height = height
  end

  def update(args)
    @layers.each { |layer| update_layer(layer,args) }
  end

  def update_layer(layer,args)
    if args.inputs.keyboard.key_held.right then
      layer[:tick] += 1

      if layer[:tick] == layer[:speed] then
        layer[:tick]      = 0
        layer[:position]  = ( layer[:position] + 1 ) % layer[:width]
      end

    elsif args.inputs.keyboard.key_held.left then
      layer[:tick] += 1

      if layer[:tick] == layer[:speed] then
        layer[:tick]      = 0
        layer[:position] -= 1
        layer[:position]  = layer[:width] - 1 if layer[:position] == -1
      end

    end
  end

  def render
    @layers.map { |layer| render_layer(layer) }
  end

  def render_layer(layer)
    if layer[:width] - layer[:position] > @width then
      [ { x:      0,
          y:      0,
          w:      @width,
          h:      @height,
          path:   @path,
          tile_x: layer[:position],
          tile_y: layer[:y_offset],
          tile_w: @width,
          tile_h: @height } ]

    else
      [ { x:      0,
          y:      0,
          w:      layer[:width] - layer[:position],
          h:      @height,
          path:   @path,
          tile_x: layer[:position],
          tile_y: layer[:y_offset],
          tile_w: layer[:width] - layer[:position],
          tile_h: @height },
        { x:      layer[:width] - layer[:position],
          y:      0,
          w:      @width - layer[:width] + layer[:position],
          h:      @height,
          path:   @path,
          tile_x: 0,
          tile_y: layer[:y_offset],
          tile_w: @width - layer[:width] + layer[:position],
          tile_h: @height } ]
    end
  end

  def serialize
    { width: @width, height: @height, path: @path, layers: @layers.length }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end

