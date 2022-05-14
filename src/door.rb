require_relative 'game_object'

class Door < GameObject
  def initialize(x, y, col, row, arg)
    super(x, y, col, row, :sprite_door1, Vector.new(-20, -28), 3, 2)
    @color = case arg
             when 'K' then 0xdd0000
             when 'L' then 0x1133ff
             when 'M' then 0xf6ca13
             when 'N' then 0x009911
             end
  end

  def blocking?
    !@open
  end

  def update

  end

  def draw(z_index)
    @img[5].draw(@x + @img_gap.x, @y + @img_gap.y, z_index, Game.scale, Game.scale)
    super(z_index, nil, @color)
  end
end
