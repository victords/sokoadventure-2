require_relative '../game'
require_relative '../particles'

class ItemGetEffect
  attr_reader :dead

  def initialize(item_type, x, y)
    @particles = Particles.new(type: :sparkle,
                               x: x + Game.tile_size / 2,
                               y: y + Game.tile_size / 2,
                               emission_interval: 0,
                               emission_rate: 3,
                               spread: 20,
                               color: ITEM_UI_ATTRS[item_type][:color]).start
    @target = Vector.new(Game.window_size.x / 2, Game.screen_margin.x + 140 * Game.scale)
    angle = Math.atan2(@target.y - @particles.y, @target.x - @particles.x)
    @x_ratio = Math.cos(angle)
    @y_ratio = Math.sin(angle)
    @speed = 0.5
  end

  def update
    @particles.update
    if @speed < 0 && @particles.element_count == 0
      @dead = true
      return
    end

    if @speed > 0
      @particles.move(@particles.x + @speed * @x_ratio, @particles.y + @speed * @y_ratio)
      if (@x_ratio < 0 && @particles.x <= @target.x || @x_ratio >= 0 && @particles.x >= @target.x) &&
        (@y_ratio < 0 && @particles.y <= @target.y || @y_ratio >= 0 && @particles.y >= @target.y)
        @particles.stop
        @speed = -1
      end
      @speed *= 1.1
    end
  end

  def draw
    @particles.draw(UI_Z_INDEX)
  end
end
