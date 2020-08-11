class Animation
  attr_reader :width, :height,
              :frame_index,
              :status,
              :clips, :current_clip

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

    @status       = :running

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
    @status       = :running
  end

  def path=(new_path)
    @path         = new_path
    @frame[:path] = new_path
  end

  def speed=(new_speed)
    @current_clip[:speed] = new_speed
  end

  def set_clip(clip)
    @current_clip               = @clips[clip]
    @frame_index                = 0
    @max_frames                 = @current_clip[:frames].length
    @mode                       = @current_clip[:mode] 
    @frame[:flip_horizontally]  = @current_clip[:flip_horizontally]
    @frame[:flip_vertically]    = @current_clip[:flip_vertically]
    @status                     = :running
  end

  def set_current_frame(frame_index)
    @frame_index  = frame_index % @max_frames
  end

  def random_start_frame
    @frame_index  = rand(@max_frames)
  end

  def update
    @tick = ( @tick + 1 ) % @current_clip[:speed]

    if @tick == 0 then
      case @current_clip[:mode]
      when :once
        @frame_index += 1
        if @frame_index >= @max_frames then
          @frame_index  = @max_frames - 1
          @status       = :finished
        end

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

  def frame_at(x,y,flip)
    @frame[:x]                  = x
    @frame[:y]                  = y
    @frame[:flip_horizontally]  = flip

    @frame
  end

  def scaled_frame_at(x,y,flip,scale)
    @frame[:x]                  = x
    @frame[:y]                  = y
    @frame[:w]                  = scale * @width
    @frame[:h]                  = scale * @height
    @frame[:flip_horizontally]  = flip

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
