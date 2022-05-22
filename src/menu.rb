class Menu
  attr_accessor :active
  
  def initialize
    @active = true
  end
  
  def update
    return unless @active
    
    Game.load_game if KB.key_pressed?(Gosu::KB_SPACE)
  end
  
  def draw
    G.window.clear(0xabcdef)
    Game.font.write_line('SokoAdventure 2', 50, 50, :left, 0xffffff, 255, :border, 0, 4 * Game.scale, 255, 0, 4 * Game.scale, 4 * Game.scale)
  end
end
