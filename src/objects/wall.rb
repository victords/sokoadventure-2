require_relative 'game_object'

class Wall < GameObject
  def initialize(x, y)
    super(x, y, :sprite_wall1, Vector.new(-10, -130))
  end

  def blocking?
    true
  end
end
