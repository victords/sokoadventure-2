require 'rbconfig'
require 'minigl'

require_relative 'constants'
require_relative 'screen'
require_relative 'stats'

include MiniGL

class Game
  class << self
    attr_reader :window_size, :scale, :tile_size, :screen_margin, :stats, :font

    def initialize
      os = RbConfig::CONFIG['host_os']
      w, h = if /linux/ =~ os
               `xrandr`.scan(/current (\d+) x (\d+)/).flatten.map(&:to_i)
             else
               [1920, 1080]
             end
      @window_size = Vector.new(w, h)
      @scale = w.to_f / REF_SCREEN_WIDTH
      @tile_size = @scale * BASE_TILE_SIZE
      @screen_margin = Vector.new((@window_size.x - @tile_size * SCREEN_COLS) / 2,
                                  (@window_size.y - @tile_size * SCREEN_ROWS) / 2)

      @stats = Stats.new
      @screens = {}
    end

    def start
      @font = TextHelper.new(Res.font(:font, 96), 0, @scale, @scale)

      load_screen(1)
    end

    def load_screen(id, entrance_id = 0, transition = false)
      screen = @screens[id] || Screen.new(id)
      @screens[id] ||= screen
      if transition
        @controller.active = false
        transition_screens(screen.reset(entrance_id))
      else
        @controller = screen.reset(entrance_id)
      end
    end

    def transition_screens(next_screen)
      @transition_timer = 0
      @on_transition_end = lambda do
        @controller = next_screen
      end
    end

    def update
      G.window.close if KB.key_pressed?(Gosu::KB_ESCAPE)

      if @transition_timer
        @transition_timer += 1
        if @transition_timer == 30
          @on_transition_end.call
        elsif @transition_timer == 60
          @transition_timer = nil
        end
      end
      @controller.update
    end

    def draw
      @controller.draw
      return unless @transition_timer

      alpha = ((@transition_timer >= 30 ? 60 - @transition_timer : @transition_timer).to_f / 30 * 255).round
      Gosu.draw_rect(0, 0, @window_size.x, @window_size.y, alpha << 24, TRANSITION_Z_INDEX)
    end
  end
end
