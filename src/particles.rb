require 'minigl'
require_relative 'game'
require_relative 'utils'

include MiniGL

class Particles
  DEFAULT_OPTIONS = {
    color: 0xffffff,
    emission_interval: 60,
    duration: 60,
    spread: 0,
  }.freeze

  attr_reader :playing, :x, :y

  def initialize(type:, x: 0, y: 0, **options)
    @type = type
    @sprite_cols, @sprite_rows, @indices =
      case type
      when :dust
        [1, 1, [0]]
      end
    @x = x
    @y = y

    @options = DEFAULT_OPTIONS.merge(options)

    @elements = []
    @timer = 0
    @playing = false
  end

  def update
    @elements.reverse_each do |e|
      e.update
      if @options[:move]
        e.x += @options[:move].x.to_f / @options[:duration]
        e.y += @options[:move].y.to_f / @options[:duration]
      end
      @elements.delete(e) if e.dead
    end

    return unless @playing

    @timer += 1
    if @timer >= @options[:emission_interval]
      x = @options[:area] ? @x + rand * @options[:area].x : @x + @options[:spread] * (rand - 0.5)
      y = @options[:area] ? @y + rand * @options[:area].y : @y + @options[:spread] * (rand - 0.5)
      @elements << Effect.new(x, y, "fx_#{@type}", @sprite_cols, @sprite_rows, @options[:duration] / @indices.size, @indices)
      @timer = 0
    end
  end

  def move(x, y)
    @x = x; @y = y
  end

  def start
    @playing = true
    self
  end

  def stop
    @playing = false
    @timer = 0
  end

  def draw(z_index = 0)
    @elements.each do |e|
      alpha = (Utils.alternating_rate(e.elapsed_time, @options[:duration]) * 255).round
      scale = @options[:grow] ? e.elapsed_time.to_f / @options[:duration] * @options[:grow] : 1
      scale *= Game.scale
      prev_x = e.x
      prev_y = e.y
      e.x -= e.img[0].width * scale / 2
      e.y -= e.img[0].height * scale / 2
      e.draw(nil, scale, scale, alpha, @options[:color], nil, nil, z_index)
      e.x = prev_x
      e.y = prev_y
    end
  end
end
