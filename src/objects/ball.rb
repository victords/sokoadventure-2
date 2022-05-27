require_relative 'game_object'

class Ball < GameObject
  def initialize(x, y, _objects, args)
    super(x, y, :sprite_ball1, Vector.new(0, -80), 2, 1)
    @set = !args[2].nil?
    @glow_alpha = 0
  end

  def blocking?
    true
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
      @glow_alpha += 5
    else
      @glow_alpha -= 5
    end
    if @glow_alpha >= 255
      @glow_alpha = -255
    end
  end

  def draw(z_index)
    super
    return if !@set && @glow_alpha == 0

    alpha = @glow_alpha.abs
    @img[1].draw(@x + @img_gap.x, @y + @img_gap.y, z_index, Game.scale, Game.scale, (alpha << 24) | 0xffffff)
  end
end
