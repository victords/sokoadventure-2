require_relative 'game_object'

class Ball < GameObject
  def initialize(x, y, col, row, set = false)
    super(x, y, col, row, :sprite_ball1, Vector.new(0, -80), 2, 1)
    @set = set
    @glow_alpha = 0
  end

  def prepare_set
    @will_set = true
  end

  def unset
    @will_set = nil
    @set = false
  end

  def update
    super do
      if @will_set
        @set = true
        @will_set = nil
      end
    end
    return if !@set && @glow_alpha == 0

    if @set || @glow_alpha < 0
      @glow_alpha += 2
    else
      @glow_alpha -= 2
    end
    if @glow_alpha >= 130
      @glow_alpha = -130
    end
  end

  def draw(z_index = 0, flip = nil)
    super
    return if !@set && @glow_alpha == 0

    alpha = @glow_alpha.abs
    @img[1].draw(@x + @img_gap.x, @y + @img_gap.y, z_index, Game.scale, Game.scale, (alpha << 24) | 0xffffff)
  end
end
