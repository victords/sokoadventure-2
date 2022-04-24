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

  def can_move?(dir, col, row, objects)
    return false if col < 0 || row < 0 || col >= SCREEN_COLS || row >= SCREEN_ROWS
    return true if objects[col][row].empty?

    next_col = @col + 2 * (col - @col)
    next_row = @row + 2 * (row - @row)
    objects[col][row].each do |obj|
      if obj.is_a?(Box)
        return false if next_col < 0 || next_row < 0 || next_col >= SCREEN_COLS || next_row >= SCREEN_ROWS
        if objects[next_col][next_row].empty?
          objects[next_col][next_row] << obj
          objects[col][row].delete(obj)
          obj.start_move(dir, Vector.new(obj.x + (col - @col) * Game.tile_size,
                                         obj.y + (row - @row) * Game.tile_size))
          return true
        end
      end
    end

    false
  end

  def check_move(dir, objects)
    return if @moving == 1

    dest, col, row = case dir
                     when 0 then [Vector.new(@x, @y - Game.tile_size), @col, @row - 1]
                     when 1 then [Vector.new(@x + Game.tile_size, @y), @col + 1, @row]
                     when 2 then [Vector.new(@x, @y + Game.tile_size), @col, @row + 1]
                     else        [Vector.new(@x - Game.tile_size, @y), @col - 1, @row]
                     end

    if can_move?(dir, col, row, objects)
      @dust.start if @moving == 0
      prev_dir = @dir
      start_move(dir, dest)
      set_animation(animation_base) if dir != prev_dir
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
