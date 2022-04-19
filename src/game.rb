require 'rbconfig'

require_relative 'constants'
require_relative 'screen'

class Game
  class << self
    attr_reader :window_size, :scale

    def initialize
      os = RbConfig::CONFIG['host_os']
      w, h = if /linux/ =~ os
               `xrandr`.scan(/current (\d+) x (\d+)/).flatten.map(&:to_i)
             else
               [1920, 1080]
             end
      @window_size = Vector.new(w, h)
      @scale = w.to_f / REF_SCREEN_WIDTH
    end

    def start
      @controller = Screen.new
    end

    def update
      G.window.close if KB.key_pressed?(Gosu::KB_ESCAPE)
      @controller.update
    end

    def draw
      @controller.draw
    end
  end
end
