require_relative 'game_object'
require_relative 'particles'

class Key < GameObject
  OFFSET_SPEED = 4
  OFFSET_RANGE = 5

  attr_writer :on_take

  def initialize(x, y, col, row, arg)
    super(x, y, col, row, :sprite_key1, Vector.new(20, -60), 7, 1)
    @start_y = y
    @offset = 0
    @sparkle = Particles.new(type: :sparkle,
                             x: @x + @w / 2,
                             y: @y + @img_gap.y + @h / 2,
                             spread: 80,
                             duration: 30).start
    @type = "key_#{arg}".to_sym
    @color = case arg
             when 'k' then 0xdd0000
             when 'l' then 0x1133ff
             when 'm' then 0xf6ca13
             when 'n' then 0x009911
             end
  end

  def take
    @dead = true
    @on_take&.call(@type, @x, @y)
  end

  def update
    animate([0, 1, 2, 3, 2, 1, 0, 4, 5, 6, 5, 4], 7)
    @offset += OFFSET_SPEED
    @offset = 0 if @offset >= 360

    @sparkle.update
  end

  def draw(z_index)
    flip = @index_index >= 4 && @index_index <= 8
    shadow_x = flip ? @x + @w - @img_gap.x : @x + @img_gap.x
    @img[@img_index].draw(shadow_x, @y, z_index, flip ? -Game.scale : Game.scale, Game.scale, 0x55000000)
    prev_y = @y
    @y = @start_y + OFFSET_RANGE * Math.sin(@offset * Math::PI / 180)
    super(z_index, flip ? :horiz : nil, @color)
    @y = prev_y

    @sparkle.draw(z_index)
  end
end
