class TileBackground < Background
  attr_reader :collision_tiles

  def initialize(render_width,render_height,description,rules)
    @path             = description[:render_target_name]
    
    @width,
    @collision_tiles  = generate_background description, rules
    @height           = description[:height]

    @render_width     = render_width
    @render_height    = render_height
    @y_offset         = 0

    @speed            = description[:speed]
    @tick             = 0
    @position         = 0
  end

  def generate_background(description,rules)
    width_in_tiles      = description[:width]   / rules[:tiles][:size]
    height_in_tiles     = description[:height]  / rules[:tiles][:size]
    min_height          = 0
    max_height          = height_in_tiles - 5
    height_range        = min_height...max_height

    target              = description[:render_target_name]

    x, y                = 0, min_height
    last_tile_group     = :horizontal
    proposed_tile_group = last_tile_group
    tile                = rules[:groups][:horizontal][:indices].sample
    offset              = [ 0, 0 ]
    place_tile_at target, rules, tile, x, y
    collision_tiles     = [y]   # at this point, x = 0, so the first collision tile is at (0;y)
    until x > width_in_tiles && y == 0
      loop do
        proposed_tile_group, tile, offset = next_tile( last_tile_group, rules )
        break if height_range === y + offset[1]
      end

      last_tile_group = proposed_tile_group

      place_tile_at target, rules, tile, x, y     # place the new tile ...
      collision_tiles[x] = y if collision_tiles[x].nil? || collision_tiles[x] < y
      if rules[:fill].include? tile then          # ... and fill the space under it
        y.times do |j|
          place_tile_at target, rules, rules[:groups][:empty][:indices].first, x, j
        end
      end

      x  += offset[0]
      y  += offset[1] 
    end

    if last_tile_group == :top_right then
      place_tile_at target, rules, rules[:groups][:bottom_left][:indices].first, x, y
    else
      place_tile_at target, rules, rules[:groups][:horizontal][:indices].sample, x, y
    end
    collision_tiles[x] = y

    place_tile_at target, rules, rules[:groups][:horizontal][:indices].sample, x + 1, y
    collision_tiles[x + 1] = y

    [ rules[:tiles][:size] * ( x + 1 ), collision_tiles ]
  end

  def next_tile(last_tile_group,rules)
    rule        = rules[:rules][last_tile_group]
    ranges      = ( [ 0.0 ] + rule.keys ).each_cons(2).map { |pair| Range.new pair[0], pair[1], true }
    sample      = rand()

    tile_group  = last_tile_group
    next_tile   = rules[:groups][tile_group][:indices].sample
    offset      = rules[:groups][tile_group][:offset]
    ranges.each do |range|
      if range === sample then
        tile_group  = rules[:rules][tile_group][range.end].sample
        next_tile   = rules[:groups][tile_group][:indices].sample
        offset      = rules[:groups][tile_group][:offset]
        break
      end
    end
    [ tile_group, next_tile, offset ]
  end

  def place_tile_at(target,rules,tile_index,x,y)
    size  = rules[:tiles][:size]
    path  = rules[:tiles][:path]

    $gtk.args.render_target(target).sprites << {  x:      x * size,
                                                                  y:      y * size,
                                                                  w:      size,
                                                                  h:      size,
                                                                  path:   path,
                                                                  tile_x: tile_index * size,
                                                                  tile_y: 0,
                                                                  tile_w: size,
                                                                  tile_h: size }
  end
end

