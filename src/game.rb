require 'rbconfig'
require 'minigl'

require_relative 'constants'
require_relative 'screen'
require_relative 'stats'
require_relative 'menu'
require_relative 'ui/transition'

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

      @controller = Menu.new
    end
    
    def load_game
      @controller.active = false
      @transition = Transition.new(:squares, -> { load_screen(1) })
    end

    def load_screen(id, entrance_id = 0, transition = false)
      screen = @screens[id] || Screen.new(id)
      @screens[id] ||= screen
      if transition
        @controller.active = false
        @transition = Transition.new(:fade, lambda do
          @controller = screen.reset(entrance_id)
        end)
      else
        @controller = screen.reset(entrance_id)
      end
    end

    def update
      G.window.close if KB.key_pressed?(Gosu::KB_ESCAPE)

      if @transition
        @transition.update
        @transition = nil if @transition.dead?
      end
      @controller.update
    end

    def draw
      @controller.draw
      @transition&.draw
    end
  end
end
