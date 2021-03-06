require_relative 'objects/game_object'
require_relative 'particles'

class Man < GameObject
  OFFSET = 25

  attr_reader :dir, :on_die

  def initialize(x, y, col, row)
    super(x, y, :sprite_man, Vector.new(-25, -50), 10, 3)
    @x += OFFSET * Game.scale
    @y += OFFSET * Game.scale
    @w = @h = Game.tile_size - 2 * OFFSET * Game.scale

    @col = col
    @row = row
    @dir = 2
    set_animation(animation_base)

    @dust = Particles.new(type: :dust,
                          color: 0xdddddd,
                          emission_interval: 10,
                          duration: 30,
                          spread: 10,
                          grow: 0..1,
                          move: [0, -15])
    @sweat = (0..3).map do |dir|
      angle, move_x, move_y = case dir
                              when 0 then [0, -3..3, 10..20]
                              when 1 then [120, -20..-10, -3..3]
                              when 2 then [180, -3..3, -20..-10]
                              else        [240, 10..20, -3..3]
                              end
      Particles.new(type: :drop,
                    color: 0x99ddff,
                    emission_interval: 5..20,
                    duration: 40,
                    spread: 20,
                    grow: 0.5..1,
                    angle: angle,
                    move: [move_x, move_y])
    end

    @on_die = []
  end

  def animation_base
    case @dir
    when 0 then 20
    when 1 then 10
    when 2 then 0
    else        10
    end
  end

  def set_dir(dir)
    prev_dir = @dir
    @dir = dir
    @dust.stop
    base = animation_base
    set_animation(@pushing ? base + 8 : base) if dir != prev_dir
  end

  def start_push(dir)
    set_animation(animation_base + 8)
    @pushing = true
    @sweat[dir].start
  end

  def check_move(dir, objects, tiles)
    return if @moving == 1

    col, row, n_col, n_row =
      case dir
      when 0 then [@col, @row - 1, @col, @row - 2]
      when 1 then [@col + 1, @row, @col + 2, @row]
      when 2 then [@col, @row + 1, @col, @row + 2]
      else        [@col - 1, @row, @col - 2, @row]
      end

    if (xit = objects[@col][@row].find { |o| o.is_a?(Exit) })
      if dir == 0 && @row == 0 ||
        dir == 1 && @col == SCREEN_COLS - 1 ||
        dir == 2 && @row == SCREEN_ROWS - 1 ||
        dir == 3 && @col == 0
        xit.activate
        start_move(dir)
        return
      end
    end
    return set_dir(dir) if col < 0 || row < 0 || col >= SCREEN_COLS || row >= SCREEN_ROWS
    return set_dir(dir) if tiles[col][row][:type] == :hole

    blocked = pushing = false
    objects[col][row].each do |obj|
      break blocked = true if obj.is_a?(Wall)

      case obj
      when Box
        next if obj.fallen
        break blocked = true if obj.falling

        pushing = true
        break blocked = true if n_col < 0 || n_row < 0 || n_col >= SCREEN_COLS || n_row >= SCREEN_ROWS
        break blocked = true if objects[n_col][n_row].any?(&:blocking?)

        objects[n_col][n_row] << obj
        objects[col][row].delete(obj)
        obj.prepare_fall(tiles[n_col][n_row][:index]) if tiles[n_col][n_row][:type] == :hole
        obj.start_move(dir)
      when Ball
        pushing = true
        break blocked = true if n_col < 0 || n_row < 0 || n_col >= SCREEN_COLS || n_row >= SCREEN_ROWS
        break blocked = true if tiles[n_col][n_row][:type] == :hole || objects[n_col][n_row].any?(&:blocking?)

        objects[n_col][n_row] << obj
        objects[col][row].delete(obj)
        if tiles[n_col][n_row][:type] == :aim
          obj.prepare_set
        else
          obj.unset
        end
        obj.start_move(dir)
      when Key, LedPanelButton
        @on_move_end = -> { obj.activate }
      when Door
        break blocked = true unless obj.open
      end
    end

    if pushing
      start_push(dir) unless @pushing
    else
      @pushing = false
    end
    if blocked
      set_dir(dir)
    else
      if (button = objects[@col][@row].find { |obj| obj.is_a?(LedPanelButton) })
        button.reset
      end
      start_move(dir)
    end
  end

  def start_move(dir)
    @dust.start if @moving == 0
    prev_dir = @dir
    super
    base = animation_base
    set_animation(@pushing ? base + 8 : base) if dir != prev_dir

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
  end

  def update(objects, tiles, active)
    if @moving == 0 && @col >= 0 && @col < SCREEN_COLS && @row >= 0 && @row < SCREEN_ROWS
      objs = objects[@col][@row]
      objs.each do |obj|
        case obj
        when Key, LedPanelButton
          obj.activate
        end
      end
    end

    (-1..1).each do |i|
      (-1..1).each do |j|
        col = @col + i
        row = @row + j
        next unless col >= 0 && row >= 0 && col < SCREEN_COLS && row < SCREEN_ROWS

        if objects[col][row].any? { |o| o.is_a?(Enemy) && o.bounds.intersect?(bounds) }
          @on_die.each(&:call)
          return
        end
      end
    end

    base = animation_base
    if @moving == 1
      indices = if @pushing
                  [base + 8, base + 9]
                else
                  [base, base + 4, base + 5, base, base + 6, base + 7]
                end
      animate(indices, 7)
      move
      @dust.move(@x + @w / 2, @y + @h + @img_gap.y + 2 * OFFSET * Game.scale)
      if @moving == 2 && @on_move_end
        @on_move_end.call
        @on_move_end = nil
      end
    elsif @pushing
      animate([base + 8, base + 9], 7)
    else
      animate([base, base + 1, base + 2, base + 3, base + 2, base + 1], 10)
    end

    @dust.update
    @sweat.each(&:update)
    if @pushing
      @sweat[@dir].move(@x + @w / 2, @y + @img_gap.y + 10 * Game.scale)
    end

    if active && KB.key_down?(Gosu::KB_UP)
      check_move(0, objects, tiles)
    elsif active && KB.key_down?(Gosu::KB_RIGHT)
      check_move(1, objects, tiles)
    elsif active && KB.key_down?(Gosu::KB_DOWN)
      check_move(2, objects, tiles)
    elsif active && KB.key_down?(Gosu::KB_LEFT)
      check_move(3, objects, tiles)
    elsif @moving != 1
      @moving = 0
      @pushing = false
      @dust.stop
    end

    unless @pushing
      @sweat.each(&:stop)
    end
  end

  def base_y
    (@y - OFFSET * Game.scale).round
  end

  def draw(z_index)
    @dust.draw(z_index)
    super(z_index, @dir == 3 ? :horiz : nil)
    @sweat.each { |s| s.draw(z_index) }
  end
end
