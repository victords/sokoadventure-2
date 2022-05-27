require 'minigl'
require_relative '../game'

class GameObject < MiniGL::GameObject
  attr_reader :moving, :dead

  def initialize(x, y, img, img_gap, sprite_cols = nil, sprite_rows = nil)
    super(x, y, Game.tile_size, Game.tile_size, img, img_gap * Game.scale, sprite_cols, sprite_rows)
    @moving = 0
    @speed = MOVE_SPEED * Game.scale
  end

  def start_move(dir, dest)
    return if @moving == 1

    @dir = dir
    @dest = dest
    @moving = 1
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

  def blocking?
    false
  end

  def update
    if @moving == 1
      move
    elsif @moving == 2
      yield if block_given?
      @moving = 0
    end
  end

  def draw(z_index, flip = nil, color = 0xffffff)
    super(nil, Game.scale, Game.scale, 255, color, nil, flip, z_index)
  end
end
