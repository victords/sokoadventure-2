require_relative 'game_object'
require_relative 'particles'

class Key < GameObject
  OFFSET_SPEED = 4
  OFFSET_RANGE = 5

  def initialize(x, y, col, row)
    super(x, y, col, row, :sprite_key1, Vector.new(0, -60), 3, 1)
    @start_y = y
    @offset = 0
    @sparkle = Particles.new(type: :sparkle,
                             x: @x + @w / 2,
                             y: @y + @img_gap.y + @h / 2,
                             emission_interval: 140,
                             spread: 80,
                             duration: 30).start
  end

  def update
    animate([0, 1, 2, 2, 1, 0, 1, 2, 2, 1], 7)
    @offset += OFFSET_SPEED
    @offset = 0 if @offset >= 360

    @sparkle.update
  end

  def draw(z_index)
    flip = @index_index >= 3 && @index_index <= 7
    @img[@img_index].draw(flip ? @x + @w : @x, @y + Game.scale * 40, z_index, flip ? -Game.scale : Game.scale, Game.scale * 0.5, 0x55000000)
    prev_y = @y
    @y = @start_y + OFFSET_RANGE * Math.sin(@offset * Math::PI / 180)
    super(z_index, flip ? :horiz : nil)
    @y = prev_y

    @sparkle.draw(z_index)
  end
end
