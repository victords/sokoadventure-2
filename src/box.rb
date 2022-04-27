require_relative 'game_object'

class Box < GameObject
  attr_reader :falling, :fallen

  def initialize(x, y, col, row)
    super(x, y, col, row, :sprite_box1, Vector.new(0, -80), 7, 3)
  end

  def prepare_fall(tile_index)
    @falling = 0
    base = case tile_index
           when 26, 27, 28, 29, 30, 33, 37, 38
             1
           when 24, 39
             5
           when 25, 34
             9
           when 32, 35
             13
           else # 31, 36
             17
           end
    @indices = [base, base + 1, base + 2, base + 3]
  end

  def update
    super do
      @falling = 1 if @falling == 0
    end
    return unless @falling == 1

    animate_once(@indices, 5) do
      @fallen = true
    end
  end
end
