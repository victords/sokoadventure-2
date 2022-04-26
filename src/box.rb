require_relative 'game_object'

class Box < GameObject
  FALL_ACCEL = 0.05

  attr_reader :falling

  def initialize(x, y, col, row)
    super(x, y, col, row, :sprite_box1, Vector.new(0, -80), 2, 1)
  end

  def prepare_fall
    @falling = -1
    @start_y = y + @img_gap.y
  end

  def update
    super do
      @falling = 0 if @falling
    end
    return unless @falling && @falling >= 0

    @falling += FALL_ACCEL
    @img_gap.y += @falling
    if @img_gap.y >= 0
      @img_gap.y = 0
      @dead = true
    end
  end

  def draw(z_index = 0, flip = nil)
    super
    @img[1].draw(@x, @start_y, z_index, Game.scale, Game.scale) if @falling
  end
end
