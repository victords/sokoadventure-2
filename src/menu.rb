class Menu
  attr_accessor :active

  def initialize
    @active = true
  end

  def clear_effects; end

  def update
    return unless @active

    Game.load_game if KB.key_pressed?(Gosu::KB_SPACE)
  end

  def draw
    G.window.clear(0xabcdef)
    Game.font.write_line('SokoAdventure 2', Game.window_size.x / 2, Game.window_size.y / 2 - 2 * Game.scale * 96,
                         :center, 0xffffff, 255, :border, 0, 4 * Game.scale, 255, 0, 4 * Game.scale, 4 * Game.scale)
  end
end
