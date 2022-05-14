require 'minigl'
require_relative '../game'

include MiniGL

class ItemPanel
  attr_reader :item_type, :dead

  def initialize(item_type)
    @item_type = item_type
    @img = Res.img(:ui_panel1)
    @x = (Game.window_size.x - @img.width * Game.scale) / 2
    @y = Game.screen_margin.y - @img.height * Game.scale
    @state = 0
    @timer = 0
    @alpha = 255

    @icon = Res.img("ui_icon#{ITEM_UI_ATTRS[item_type][:icon]}")
    @icon_color = ITEM_UI_ATTRS[item_type][:color]
  end

  def refresh
    return if @state == 0

    @state = 1
    @timer = 0
    @alpha = 255
  end

  def update
    case @state
    when 0
      @y += 10 * Game.scale
      if @y >= Game.screen_margin.y + 20 * Game.scale
        @y = Game.screen_margin.y + 20 * Game.scale
        @state = 1
      end
    when 1
      @timer += 1
      if @timer == 120
        @state = 2
      end
    when 2
      @alpha -= 5
      if @alpha <= 0
        @dead = true
      end
    end
  end

  def draw
    @img.draw(@x, @y, UI_Z_INDEX, Game.scale, Game.scale, (@alpha << 24) | 0xffffff)
    @icon.draw(@x + 40 * Game.scale, @y + 40 * Game.scale, UI_Z_INDEX, Game.scale, Game.scale, (@alpha << 24) | @icon_color)
    Game.font.write_line((Game.stats.items[@item_type] || 0).to_s, @x + (@img.width - 40) * Game.scale, @y + 52 * Game.scale, :right, 0xffffff, @alpha, nil, 0, 0, 0, UI_Z_INDEX)
  end
end
