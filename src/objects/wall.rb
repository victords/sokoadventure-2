require_relative 'game_object'

class Wall < GameObject
  def initialize(x, y)
    super(x, y, :sprite_wall1, Vector.new(-5, -65))
  end

  def blocking?
    true
  end
end
