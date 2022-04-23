require_relative 'game_object'

class Box < GameObject
  def initialize(x, y, col, row)
    super(x, y, col, row, :sprite_box1, Vector.new(0, -80))
  end
end
