require_relative 'game_object'

class Door < GameObject
  def initialize(x, y, col, row, arg)
    super(x, y, col, row, :sprite_door1, Vector.new(-20, -28), 3, 2)
    @key_type = "key_#{arg.downcase}".to_sym
    @color = case arg
             when 'K' then 0xdd0000
             when 'L' then 0x1133ff
             when 'M' then 0xf6ca13
             when 'N' then 0x009911
             end

    @particles = (0..3).map do |i|
      move = case i
             when 0 then [-80, -80]
             when 1 then [80, -80]
             when 2 then [-80, 80]
             else        [80, 80]
             end
      Particles.new(type: :sparkle,
                    x: @x + @w / 2,
                    y: @y + @h / 2,
                    emission_interval: 0,
                    alpha_inflection: 0.05,
                    move: move)
    end
  end

  def blocking?
    !@open
  end

  def can_open?
    Game.stats.items.keys.include?(@key_type)
  end

  def open
    return true if @open
    return false unless can_open?

    Game.stats.use_item(@key_type)
    @particles.each(&:start)
    @open = true
  end

  def update
    return unless @open

    animate_once([0, 1, 2, 3, 4], 5)
    @particles.each do |p|
      p.update
      p.stop
    end
  end

  def draw(z_index)
    @img[5].draw(@x + @img_gap.x, @y + @img_gap.y, z_index, Game.scale, Game.scale)
    super(z_index, nil, @color)

    @particles.each { |p| p.draw(UI_Z_INDEX - 1) }
  end
end
