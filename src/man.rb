require_relative 'game_object'
require_relative 'particles'

class Man < GameObject
  attr_reader :dir

  def initialize(x, y, col, row)
    super(x, y, col, row, :sprite_man, Vector.new(0, -50), 8, 3)
    @dir = 2
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

  def can_move?(col, row, objects)
    return false if col < 0 || row < 0 || col >= SCREEN_COLS || row >= SCREEN_ROWS

    objects[col][row].empty?
  end

  def check_move(dir, objects)
    return if @moving == 1

    tile_size = BASE_TILE_SIZE * Game.scale
    dest, col, row = case dir
                     when 0 then [Vector.new(@x, @y - tile_size), @col, @row - 1]
                     when 1 then [Vector.new(@x + tile_size, @y), @col + 1, @row]
                     when 2 then [Vector.new(@x, @y + tile_size), @col, @row + 1]
                     else        [Vector.new(@x - tile_size, @y), @col - 1, @row]
                     end

    if can_move?(col, row, objects)
      start_move(dir, dest)
    else
      @dir = dir
      set_animation(animation_base)
    end
  end

  def update(objects)
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
      check_move(0, objects)
    elsif KB.key_down?(Gosu::KB_RIGHT)
      check_move(1, objects)
    elsif KB.key_down?(Gosu::KB_DOWN)
      check_move(2, objects)
    elsif KB.key_down?(Gosu::KB_LEFT)
      check_move(3, objects)
    elsif @moving == 2
      @moving = 0
      @dust.stop
    end
  end

  def draw(z_index)
    @dust.draw(z_index)
    super(z_index, @dir == 3 ? :horiz : nil)
  end
end
