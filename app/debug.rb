module Debug
  # ---=== DEBUG MODE PARSING: ===---
  def self.parse_debug_arg(argv)
    argv.split[1..-1].each do |arg|
      debug_flag, level  = arg.split('=')
      #return level.to_i if debug_flag == '--debug' && level != nil
      if debug_flag == '--debug' && level != nil then
        return level.to_i
      else
        return 0
      end
    end

    nil
  end


  # ---=== GRAPHIC HINTS : ===---
  def self.draw_cross(x,y,color)
    $gtk.args.render_target(:display).lines << [ x - 1, y - 1, x + 2, y + 2 ] + color
    $gtk.args.render_target(:display).lines << [ x - 1, y + 1, x + 2, y - 2 ] + color
  end

  def self.draw_box(bounds,color)
    $gtk.args.render_target(:display).borders << bounds + color
  end

  def self.draw_tiles_bounds(color)
    ground          = $gtk.args.state.ground
    ground_position = ground.instance_variable_get :@position
    ground.collision_tiles.each.with_index do |y,x|
      if (-8..72) === x * 8 - ground_position then
        $gtk.args.render_target(:display).borders << [ x * 8 - ground_position, y * 8, 8, 8 ] + color
      end
    end
  end

  def self.draw_player_bounds(color)
    player  = $gtk.args.state.player
    width   = player.instance_variable_get :@width
    height  = player.instance_variable_get :@height
    $gtk.args.render_target(:display).borders << [ player.x - ( width >> 1 ),
                                                   player.y,
                                                   width,
                                                   height ] + color
  end

  def self.draw_player_v(color1,color2)
    player  = $gtk.args.state.player
    width   = player.instance_variable_get :@width
    height  = player.instance_variable_get :@height
    dx      = player.dx
    dy      = player.dy
    $gtk.args.render_target(:display).lines << [  player.x - ( width >> 1 ),
                                                  player.y,
                                                  player.x - ( width >> 1 ) + dx,
                                                  player.y + dy ] + color1
    $gtk.args.render_target(:display).lines << [  player.x + ( width >> 1 ),
                                                  player.y,
                                                  player.x + ( width >> 1 ) + dx,
                                                  player.y + dy ] + color2
  end

  def self.draw_bounds(entity,offset,color)
    width   = entity.instance_variable_get :@width
    height  = entity.instance_variable_get :@height
    $gtk.args.render_target(:display).borders << [ entity.x - ( width >> 1 ) - offset,
                                                   entity.y,
                                                   width,
                                                   height ] + color
  end
end
