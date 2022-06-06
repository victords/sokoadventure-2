class Menu
  attr_accessor :active

  def initialize
    @active = true
    @font = TextHelper.new(Res.font(:font, 160), 0, Game.scale, Game.scale)
  end

  def clear_effects; end

  def update
    return unless @active

    Game.load_game if KB.key_pressed?(Gosu::KB_SPACE)
  end

  def draw
    G.window.clear(0xabcdef)
    @font.write_line('SokoAdventure 2', Game.window_size.x / 2, Game.window_size.y / 2 - Game.scale * 80,
                     :center, 0xffffff, 255, :border, 0, 2 * Game.scale, 255, 0, Game.scale, Game.scale)
  end
end
