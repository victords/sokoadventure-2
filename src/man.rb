require 'minigl'

class Man < MiniGL::Sprite
  def initialize(x, y)
    super(x, y, :sprite_man, 8, 3)
  end

  def update
    animate([16, 20, 21, 20, 16, 22, 23, 22], 7)
  end

  def draw
    super(nil, Game.scale, Game.scale, 255, 0xffffff, nil)
  end
end
