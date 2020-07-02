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





class TileBackground < Background
  def initialize(tiles_path,size,layers,rules)
    @tiles_path = tiles_path
    @path       = :procedural_background
    
    @size   = size

    @layers = layers.map |layers|
                generate_layer layer, size, rules
              end
  end

  def generate_layer(layer,size,rules)
    width_in_tiles  = layer[:width]   / size
    height_in_tiles = layer[:height]  / size
    min_height      = 0
    max_height      = height_in_tiles - 4

    x, y            = 0, min_height
    last_tile_group = :horizontal
    tile            = rules[:groups][:horizontal][:indices]
    while x < width_in_tiles do
      place_tile_at tile, x, y
      last_tile_groupe, tile, offset = next_tile_at last_tile_group,
                                                    rules 
      x  += offset[0]
      y  += offset[1] 
    end
  end

  def next_tile_at(last_tile_group,x,y,rules)
    rule    = rules[last_tile]
    ranges  = ( [ 0.0 ] + rule.keys ).each_cons(2).map { |pair| Range.new pair[0], pair[0] + pair[1], true }
    sample  = rand()
    ranges.each do |range|
      if range === sample then
        tile_group  = rules[:rules][last_tile_group][range.end].sample
        next_tile   = rules[:groups][tile_group][:indices].sample
        offset      = rules[:groups][tile_group][:offset]
        
        return [ tile_group, next_tile, offset ]
      end
    end
  end

  def place_tile_at(tile_index,x,y)
    $gtk.args.render_target(render_target) << { x:      x * @size,
                                                y:      y * @size,
                                                w:      @size,
                                                h:      @size,
                                                path:   :procedural_background,
                                                tile_x: tile_index * @size,
                                                tile_y: 0 }
  end
end
