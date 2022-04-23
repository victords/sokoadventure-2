require 'minigl'
require_relative 'game'

class GameObject < MiniGL::GameObject
  attr_reader :col, :row, :moving

  def initialize(x, y, col, row, img, img_gap, sprite_cols = nil, sprite_rows = nil)
    super(x, y, Game.scale * BASE_TILE_SIZE, Game.scale * BASE_TILE_SIZE, img, img_gap * Game.scale, sprite_cols, sprite_rows)
    @col = col
    @row = row
    @moving = 0
    @speed = MOVE_SPEED * Game.scale
  end

  def start_move(dir, dest)
    return if @moving == 1

    case dir
    when 0
      @row -= 1
    when 1
      @col += 1
    when 2
      @row += 1
    else
      @col -= 1
    end

    prev_dir = @dir
    @dir = dir
    @dest = dest
    @dust.start if @moving == 0
    @moving = 1
    set_animation(animation_base) if dir != prev_dir
  end

  def move
    x, y = case @dir
           when 0 then [0, -@speed]
           when 1 then [@speed, 0]
           when 2 then [0, @speed]
           else        [-@speed, 0]
           end
    @x += x
    @y += y
    if @dir == 0 && @y <= @dest.y ||
      @dir == 1 && @x >= @dest.x ||
      @dir == 2 && @y >= @dest.y ||
      @dir == 3 && @x <= @dest.x
      @x = @dest.x
      @y = @dest.y
      @moving = 2
    end
  end

  def draw(z_index, flip = nil)
    super(nil, Game.scale, Game.scale, 255, 0xffffff, nil, flip, z_index)
  end
end
