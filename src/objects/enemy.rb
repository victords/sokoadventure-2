require_relative 'game_object'

class Enemy < GameObject
  SPEED = 5

  def initialize(x, y, _objects, _args)
    super(x, y, :sprite_enemy1, Vector.new(0, -40), 3, 3)
    @dir = 1
    @speed = SPEED * Game.scale
  end

  def update
    prev_dir = @dir
    if @moving == 1
      move
    else
      start_move((@dir + 1) % 4)
    end

    base = case @dir
           when 0    then 0
           when 1, 3 then 3
           else           6
           end
    set_animation(base) if @dir != prev_dir
    animate([base, base + 1, base + 2, base + 1], 10)
  end

  def draw(z_index)
    super(z_index, @dir == 3 ? :horiz : nil)
  end
end
