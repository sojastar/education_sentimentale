class Animation
  attr_reader :width, :height, :frame_index, :clips, :current_clip

  def initialize(path,width,height,clips,first_clip)
    @path         = path

    @width        = width
    @height       = height

    @clips        = clips
    @current_clip = @clips[first_clip]

    @frame_index  = 0
    @count_dir    = :up
    @max_frames   = @current_clip[:frames].length
    @mode         = @current_clip[:mode] 

    @tick         = 0

    @frame        = { x:                  0,
                      y:                  0,
                      w:                  @width,
                      h:                  @height,
                      path:               @path,
                      flip_horizontally:  false,
                      flip_vertically:    false,
                      tile_x:             0,
                      tile_y:             0,
                      tile_w:             @width,
                      tile_h:             @height }
  end

  def reset_clip
    @frame_index  = 0
    @tick         = 0
    @frame[:w]    = @width
    @frame[:h]    = @height
  end

  def set_clip(clip)
    @current_clip               = @clips[clip]
    @frame_index                = 0
    @max_frames                 = @current_clip[:frames].length
    @mode                       = @current_clip[:mode] 
    @frame[:flip_horizontally]  = @current_clip[:flip_horizontally]
    @frame[:flip_vertically]    = @current_clip[:flip_vertically]
  end

  def update
    @tick = ( @tick + 1 ) % @current_clip[:speed]

    if @tick == 0 then
      case @current_clip[:mode]
      when :single
        @frame_index += 1
        @frame_index  = @max_frames - 1 if @frame_index >= @max_frames

      when :loop
        @frame_index  = ( @frame_index + 1 ) % @max_frames

      when :pingpong
        if @count_dir == :up then
          @frame_index += 1
          @count_dir    = :down   if @frame_index == @max_frames - 1
        end

        if @count_dir == :down then
          @frame_index -= 1
          @count_dir    = :up   if @frame_index == 0
        end

      end 
    end

    @frame[:tile_x] = @current_clip[:frames][@frame_index][0] * @width
    @frame[:tile_y] = @current_clip[:frames][@frame_index][1] * @height
  end

  def frame_at(x,y)
    @frame[:x]      = x
    @frame[:y]      = y

    @frame
  end

  def scaled_frame_at(x,y,scale)
    @frame[:x]      = x
    @frame[:y]      = y
    @frame[:w]      = scale * @width
    @frame[:h]      = scale * @height

    @frame
  end

  def serialize
    { path: @path, width: @width, height: @height, clips: @clips.length }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
