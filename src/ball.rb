require_relative 'game_object'

class Ball < GameObject
  def initialize(x, y, col, row)
    super(x, y, col, row, :sprite_ball1, Vector.new(0, -80))
  end
end
