require_relative 'game_object'
require_relative '../particles'

class Box < GameObject
  attr_reader :falling, :fallen

  def initialize(x, y, _objects, _args)
    super(x, y, :sprite_box1, Vector.new(0, -80), 7, 3)
    @dust = (0..3).map do |_|
      Particles.new(type: :dust,
                    color: 0xdddddd,
                    emission_interval: 0,
                    duration: 90,
                    alpha_inflection: 0.1,
                    move: [0, -30])
    end
  end

  def blocking?
    !@fallen
  end

  def prepare_fall(tile_index)
    @falling = 0
    base = case tile_index
           when 26, 27, 28, 29, 30, 33, 37, 38
             1
           when 24, 39
             5
           when 25, 34
             9
           when 32, 35
             13
           else # 31, 36
             17
           end
    @indices = [base, base + 1, base + 2, base + 3]
  end

  def update
    @dust.each(&:update)
    @dust.each(&:stop) if @fallen

    super do
      @falling = 1 if @falling == 0
    end
    return unless @falling == 1

    animate_once(@indices, 3) do
      @fallen = true
      @dust.each_with_index do |d, i|
        x = @x + (i % 2) * Game.tile_size
        y = @y + (i / 2) * Game.tile_size
        d.move(x, y)
        d.start
      end
    end
  end

  def draw(z_index)
    super
    @dust.each { |d| d.draw(z_index) }
  end
end
