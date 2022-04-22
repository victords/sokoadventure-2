require 'minigl'
require_relative 'constants'

class Man < MiniGL::Sprite
  attr_reader :dir, :moving

  def initialize(x, y)
    super(x, y, :sprite_man, 8, 3)

    @speed = 10 * Game.scale
    @dir = 2
    set_animation(animation_base)
  end

  def animation_base
    case @dir
    when 0 then 16
    when 1 then 8
    when 2 then 0
    else        8
    end
  end

  def start_move(dir, dest)
    prev_dir = @dir
    @dir = dir
    @dest = dest
    @moving = true
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
      @moving = false
    end
  end

  def update
    base = animation_base
    if @moving
      animate([base, base + 4, base + 5, base, base + 6, base + 7], 7)
      move
    else
      animate([base, base + 1, base + 2, base + 3, base + 2, base + 1], 10)
    end
    return if @moving

    if KB.key_down?(Gosu::KB_UP)
      start_move(0, Vector.new(@x, @y - BASE_TILE_SIZE * Game.scale))
    elsif KB.key_down?(Gosu::KB_RIGHT)
      start_move(1, Vector.new(@x + BASE_TILE_SIZE * Game.scale, @y))
    elsif KB.key_down?(Gosu::KB_DOWN)
      start_move(2, Vector.new(@x, @y + BASE_TILE_SIZE * Game.scale))
    elsif KB.key_down?(Gosu::KB_LEFT)
      start_move(3, Vector.new(@x - BASE_TILE_SIZE * Game.scale, @y))
    end
  end

  def draw
    super(nil, Game.scale, Game.scale, 255, 0xffffff, nil, @dir == 3 ? :horiz : nil, 2)
  end
end
