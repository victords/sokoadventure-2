require 'minigl'
require_relative 'constants'
require_relative 'particles'

class Man < MiniGL::GameObject
  attr_reader :dir, :moving

  def initialize(x, y)
    super(x, y, Game.scale * BASE_TILE_SIZE, Game.scale * BASE_TILE_SIZE, :sprite_man, Vector.new(0, -60 * Game.scale), 8, 3)

    @speed = 10 * Game.scale
    @dir = 2
    @moving = 0
    set_animation(animation_base)

    @dust = Particles.new(type: :dust,
                          color: 0xdddddd,
                          emission_interval: 10,
                          duration: 30,
                          spread: 10 * Game.scale,
                          grow: 1,
                          move: Vector.new(0, -30 * Game.scale))
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
    return if @moving == 1

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

  def update
    tile_size = BASE_TILE_SIZE * Game.scale

    base = animation_base
    if @moving == 1
      animate([base, base + 4, base + 5, base, base + 6, base + 7], 7)
      move
      @dust.move(@x + @w / 2, @y + @h + @img_gap.y)
    else
      animate([base, base + 1, base + 2, base + 3, base + 2, base + 1], 10)
    end

    @dust.update

    if KB.key_down?(Gosu::KB_UP)
      start_move(0, Vector.new(@x, @y - tile_size))
    elsif KB.key_down?(Gosu::KB_RIGHT)
      start_move(1, Vector.new(@x + tile_size, @y))
    elsif KB.key_down?(Gosu::KB_DOWN)
      start_move(2, Vector.new(@x, @y + tile_size))
    elsif KB.key_down?(Gosu::KB_LEFT)
      start_move(3, Vector.new(@x - tile_size, @y))
    elsif @moving == 2
      @moving = 0
      @dust.stop
    end
  end

  def draw
    @dust.draw(2)
    super(nil, Game.scale, Game.scale, 255, 0xffffff, nil, @dir == 3 ? :horiz : nil, 2)
  end
end
