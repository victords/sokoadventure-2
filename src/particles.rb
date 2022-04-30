require 'minigl'
require_relative 'game'

class Particles
  DEFAULT_OPTIONS = {
    color: 0xffffff,
    emission_interval: 60,
    duration: 60,
    spread: 0,
    alpha_inflection: 0.5
  }.freeze

  attr_reader :playing, :x, :y

  def initialize(type:, x: 0, y: 0, **options)
    @type = type
    @sprite_cols, @sprite_rows, @indices =
      case type
      when :dust, :drop
        [1, 1, [0]]
      when :sparkle
        [3, 1, [0, 1, 2, 1, 0]]
      end
    @x = x
    @y = y

    @options = DEFAULT_OPTIONS.merge(options)

    @elements = []
    @timer = 0
    @playing = false
  end

  def move(x, y)
    @x = x; @y = y
  end

  def set_emission_time
    interval = @options[:emission_interval]
    @emission_time = interval.is_a?(Range) ? rand(interval) : interval
  end

  def start
    @playing = true
    set_emission_time if @emission_time.nil?
    self
  end

  def stop
    @playing = false
    @timer = 0
  end

  def update
    @elements.reverse_each do |e|
      e.update
      @elements.delete(e) if e.dead
    end

    return unless @playing

    @timer += 1
    if @timer >= @emission_time
      x = @options[:area] ? @x + rand * @options[:area].x * Game.scale : @x + @options[:spread] * (rand - 0.5) * Game.scale
      y = @options[:area] ? @y + rand * @options[:area].y * Game.scale : @y + @options[:spread] * (rand - 0.5) * Game.scale
      @elements << (e = Particle.new(x, y, "fx_#{@type}", @sprite_cols, @sprite_rows, @options[:duration] / @indices.size, @indices, @options[:flip]))
      if @options[:move]
        d_x = @options[:move][0].is_a?(Range) ? rand(@options[:move][0]) : @options[:move][0]
        e.speed.x = d_x.to_f / @options[:duration] * Game.scale
        d_y = @options[:move][1].is_a?(Range) ? rand(@options[:move][1]) : @options[:move][1]
        e.speed.y = d_y.to_f / @options[:duration] * Game.scale
      end
      e.angle = @options[:angle]
      @timer = 0
      set_emission_time
    end
  end

  def draw(z_index = 0)
    @elements.each do |e|
      alpha = (alternating_rate(e.elapsed_time, @options[:duration], @options[:alpha_inflection]) * 255).round
      scale = @options[:grow] ? @options[:grow].min + e.elapsed_time.to_f / @options[:duration] * (@options[:grow].max - @options[:grow].min) : 1
      scale *= Game.scale
      e.draw(scale, alpha, @options[:color], z_index)
    end
  end

  private

  def alternating_rate(timer, interval, inflection_point_at)
    inflection_point = interval * inflection_point_at
    (timer >= inflection_point ? interval - timer : timer).to_f /
      (timer >= inflection_point ? interval - inflection_point : inflection_point)
  end

  class Particle < MiniGL::Effect
    attr_reader :speed
    attr_writer :angle

    def initialize(x, y, img, sprite_cols, sprite_rows, interval, indices, flip)
      super(x, y, img, sprite_cols, sprite_rows, interval, indices)
      @speed = Vector.new
      @flip = flip
      @angle = nil
    end

    def update
      super
      @x += @speed.x
      @y += @speed.y
    end

    def draw(scale, alpha, color, z_index)
      prev_x = @x
      prev_y = @y
      @x -= @img[0].width * scale / 2
      @y -= @img[0].height * scale / 2
      super(nil, scale, scale, alpha, color, @angle, @flip, z_index)
      @x = prev_x
      @y = prev_y
    end
  end
end
