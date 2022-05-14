require_relative 'game'
require_relative 'game_object'

class LedPanel
  TRANSITION_TIME = 15
  TRANSITION_PAUSE = 12

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @leds = [
      [:red, :green, :blue],
      [:green, :blue, :red],
      [:green, :red, :blue]
    ]
    @img = Res.imgs(:sprite_led, 2, 1)
  end

  def move_col(col, up)
    transition(col) do
      if up
        color = @leds[col].shift
        @leds[col] << color
      else
        color = @leds[col].pop
        @leds[col].insert(0, color)
      end
    end
  end

  def move_row(row, left)
    transition(nil, row) do
      if left
        color = @leds[0][row]
        @leds[0][row] = @leds[1][row]
        @leds[1][row] = @leds[2][row]
        @leds[2][row] = color
      else
        color = @leds[2][row]
        @leds[2][row] = @leds[1][row]
        @leds[1][row] = @leds[0][row]
        @leds[0][row] = color
      end
    end
  end

  def transition(col = nil, row = nil, &block)
    return if col == @transition_col && !col.nil? ||
              row == @transition_row && !row.nil?

    @timer = 0
    @transition_col = col
    @transition_row = row
    @transition_leds =
      if col
        [[col, 0], [col, 1], [col, 2]]
      else
        [[0, row], [1, row], [2, row]]
      end
    @on_transition_end = block
  end

  def color_lerp(color1, color2, rate)
    r1 = (color1 & 0xff0000) >> 16
    g1 = (color1 & 0xff00) >> 8
    b1 = color1 & 0xff
    r2 = (color2 & 0xff0000) >> 16
    g2 = (color2 & 0xff00) >> 8
    b2 = color2 & 0xff
    r = (r1 + rate * (r2 - r1)).round
    g = (g1 + rate * (g2 - g1)).round
    b = (b1 + rate * (b2 - b1)).round
    (0xff << 24) | (r << 16) | (g << 8) | b
  end

  def dead
    false
  end

  def blocking?
    false
  end

  def update
    return unless @transition_leds

    @timer += 1
    if @timer == TRANSITION_TIME
      @on_transition_end.call
      @on_transition_end = nil
    elsif @timer == 2 * TRANSITION_TIME + TRANSITION_PAUSE
      @transition_leds = @transition_col = @transition_row = nil
    end
  end

  def draw(z_index)
    @leds.each_with_index do |col, i|
      col.each_with_index do |cell, j|
        color = case cell
                when :red   then 0xffff0000
                when :green then 0xff00ff00
                when :blue  then 0xff0000ff
                else             0xffcccccc
                end
        led_color = glow_color = color
        if @transition_leds&.include?([i, j])
          rate = (@timer >= TRANSITION_TIME + TRANSITION_PAUSE ?
                    2 * TRANSITION_TIME + TRANSITION_PAUSE - @timer :
                    [@timer, TRANSITION_TIME].min).to_f / TRANSITION_TIME
          led_color = color_lerp(led_color, 0xff666666, rate)
          glow_color = ((255 * (1 - rate)).round << 24) | (glow_color & 0xffffff)
        end
        @img[0].draw(@x + i * Game.tile_size, @y + j * Game.tile_size, z_index + j, Game.scale, Game.scale, led_color)
        @img[1].draw(@x + i * Game.tile_size, @y + j * Game.tile_size, z_index + j, Game.scale, Game.scale, glow_color)
      end
    end
  end
end

class LedPanelButton < MiniGL::Sprite
  def initialize(x, y, panel, line, dir)
    super(x, y, :sprite_ledPanelButton, 4, 2)
    @panel = panel
    @line = line
    @dir = dir
    @img_index = dir
  end

  def activate
    if @dir == 0 || @dir == 2
      @panel.move_col(@line, @dir == 0)
    else
      @panel.move_row(@line, @dir == 3)
    end
    @img_index = @dir + 4
  end

  def reset
    @img_index = @dir
  end

  def dead
    false
  end

  def blocking?
    false
  end

  def update; end

  def draw(z_index)
    super(nil, Game.scale, Game.scale, 255, 0xffffff, nil, nil, z_index)
  end
end
