require_relative 'game_object'

class Enemy < GameObject
  SPEED = 5

  def initialize(x, y, objects, args)
    super(x, y, :sprite_enemy1, Vector.new(0, -40), 3, 3)
    @speed = SPEED * Game.scale
    @objects = objects
    @col = args[0]
    @row = args[1]
    @dir = args[2] || 2
  end

  def update
    prev_dir = dir = @dir
    if @moving == 1
      move
    else
      step = 1
      while step < 5
        col, row = case dir
                   when 0 then [@col, @row - 1]
                   when 1 then [@col + 1, @row]
                   when 2 then [@col, @row + 1]
                   else        [@col - 1, @row]
                   end
        if col < 0 || row < 0 || col >= SCREEN_COLS || row >= SCREEN_ROWS || @objects[col][row].any?(&:blocking?)
          dir = (dir + step) % 4 if step < 4
          step += 1
        else
          start_move(dir)
          @objects[@col][@row].delete(self)
          @objects[col][row] << self
          @col = col
          @row = row
          break
        end
      end
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
