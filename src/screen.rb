require 'minigl'
require_relative 'man'

include MiniGL

class Screen
  COLS = 24
  ROWS = 13
  OVERLAY_TILE_INDEX = 7

  def initialize
    @tileset = Res.tileset('1', BASE_TILE_SIZE, BASE_TILE_SIZE)
    @tiles = Array.new(COLS) do
      Array.new(ROWS)
    end
    File.open("#{Res.prefix}screen/1") do |f|
      f.each.with_index do |line, j|
        line.chomp.each_char.with_index do |c, i|
          @tiles[i][j] = c
        end
      end
    end

    @overlays = Array.new(COLS + 1) do
      Array.new(ROWS + 1)
    end
    (0..COLS).each do |i|
      (0..ROWS).each do |j|
        tl = i == 0 || j == 0 ? '' : @tiles[i - 1][j - 1]
        tr = i == COLS || j == 0 ? '' : @tiles[i][j - 1]
        bl = i == 0 || j == ROWS ? '' : @tiles[i - 1][j]
        br = i == COLS || j == ROWS ? '' : @tiles[i][j]
        top_left = i == 0 && j == 0 || i == 0 && tr == '\\' || j == 0 && bl == '\\' || /[\/\\]/ =~ tl
        top_right = i == COLS && j == 0 || i == COLS && tl == '\\' || j == 0 && br == '\\' || /[\/\\]/ =~ tr
        bottom_left = i == 0 && j == ROWS || i == 0 && br == '\\' || j == ROWS && tl == '\\' || /[\/\\]/ =~ bl
        bottom_right = i == COLS && j == ROWS || i == COLS && bl == '\\' || j == ROWS && tr == '\\' || /[\/\\]/ =~ br
        @overlays[i][j] = top_left && top_right && bottom_left && bottom_right
      end
    end

    @tile_size = Game.scale * BASE_TILE_SIZE
    @margin = Vector.new((Game.window_size.x - @tile_size * COLS) / 2,
                         (Game.window_size.y - @tile_size * ROWS) / 2)

    @man = Man.new(@margin.x, @margin.y)
  end

  def get_tile(i, j)
    return 0 if @tiles[i][j] == '.'

    edge = @tiles[i][j] == '\\'
    up = j > 0 && /[\/\\]/ =~ @tiles[i][j - 1] || j == 0 && edge
    rt = i < COLS - 1 && /[\/\\]/ =~ @tiles[i + 1][j] || i == COLS - 1 && edge
    dn = j < ROWS - 1 && /[\/\\]/ =~ @tiles[i][j + 1] || j == ROWS - 1 && edge
    lf = i > 0 && /[\/\\]/ =~ @tiles[i - 1][j] || i == 0 && edge

    return 14 if up && rt && dn && lf
    return 12 if up && rt && dn
    return 20 if up && rt && lf
    return 21 if up && dn && lf
    return 13 if rt && dn && lf
    return 18 if up && rt
    return 22 if up && dn
    return 19 if up && lf
    return 10 if rt && dn
    return 15 if rt && lf
    return 11 if dn && lf
    return 8 if up
    return 9 if rt
    return 17 if dn
    return 16 if lf
    23
  end

  def update
    @man.update
  end

  def draw
    (0..COLS).each do |i|
      (0..ROWS).each do |j|
        if @overlays[i][j]
          @tileset[OVERLAY_TILE_INDEX].draw(i * @tile_size + @margin.x - @tile_size / 2,
                                            j * @tile_size + @margin.y - @tile_size / 2,
                                            1, Game.scale, Game.scale)
        end

        next if i == COLS || j == ROWS
        index = get_tile(i, j)
        @tileset[index].draw(i * @tile_size + @margin.x, j * @tile_size + @margin.y, 0, Game.scale, Game.scale)
      end
    end

    @man.draw

    if @margin.x > 0.01
      Gosu.draw_rect(0, 0, @margin.x, Game.window_size.y, 0xff000000, 2)
      Gosu.draw_rect(Game.window_size.x - @margin.x, 0, @margin.x, Game.window_size.y, 0xff000000, 10)
    end
    if @margin.y > 0.01
      Gosu.draw_rect(0, 0, Game.window_size.x, @margin.y, 0xff000000, 2)
      Gosu.draw_rect(0, Game.window_size.y - @margin.y, Game.window_size.x, @margin.y, 0xff000000, 10)
    end
  end
end
