module Debug
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
end
