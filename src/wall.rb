require_relative 'game_object'

class Wall < GameObject
  def initialize(x, y, col, row, _arg)
    super(x, y, col, row, :sprite_wall1, Vector.new(-10, -130))
  end

  def blocking?
    true
  end
end
