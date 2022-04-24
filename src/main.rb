require 'minigl'
require_relative 'game'

include MiniGL

class Window < GameWindow
  attr_reader :global_scale

  def initialize
    super(Game.window_size.x, Game.window_size.y, true)
    self.caption = 'SokoAdventure 2'
    Res.prefix = File.expand_path(__FILE__).split('/')[0..-3].join('/') + '/data'

    Game.start
  end

  def update
    KB.update
    Mouse.update
    Game.update
  end

  def draw
    Game.draw
  end
end

Game.initialize
Window.new.show
