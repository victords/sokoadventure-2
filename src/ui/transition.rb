require_relative '../constants'

class Transition
  def initialize(type, on_halfway = nil, on_end = nil)
    @type = type
    @on_halfway = on_halfway
    @on_end = on_end
    @timer = 0
    @half_duration, @full_duration =
      case @type
      when :squares then [60, 120]
      else               [30, 60]
      end

    if @type == :squares
      @square_size = 40 * Game.scale
      @cols = (Game.window_size.x.to_f / @square_size).ceil
      @rows = (Game.window_size.y.to_f / @square_size).ceil
      @slope = (@half_duration + @cols + @rows).to_f / @half_duration
    end
  end

  def dead?
    @timer >= @full_duration
  end

  def update
    @timer += 1
    if @timer == @half_duration
      @on_halfway&.call
    elsif @timer == @full_duration
      @on_end&.call
    end
  end

  def draw
    case @type
    when :fade
      alpha = ((@timer >= 30 ? 60 - @timer : @timer).to_f / 30 * 255).round
      Gosu.draw_rect(0, 0, Game.window_size.x, Game.window_size.y, alpha << 24, TRANSITION_Z_INDEX)
    when :squares
      (0...@cols).each do |i|
        (0...@rows).each do |j|
          size =
            if @timer >= @half_duration
              [[-@slope * (@timer - @half_duration) + @half_duration + i + j, 0].max / @half_duration, 1].min * @square_size
            else
              [[@slope * @timer - i - j, 0].max / @half_duration, 1].min * @square_size
            end
          offset = (@square_size - size) / 2
          Gosu.draw_rect(i * @square_size + offset,
                         j * @square_size + offset,
                         size, size, 0xff000000, TRANSITION_Z_INDEX)
        end
      end
    end
  end
end
