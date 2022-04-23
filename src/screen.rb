require 'minigl'
require_relative 'man'
require_relative 'box'

include MiniGL

class Screen
  OVERLAY_TILE_INDEX = 7

  def initialize
    @tileset = Res.tileset('1', BASE_TILE_SIZE, BASE_TILE_SIZE)
    @tiles = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS)
    end
    File.open("#{Res.prefix}screen/1") do |f|
      f.each.with_index do |line, j|
        line.chomp.each_char.with_index do |c, i|
          @tiles[i][j] = c
        end
      end
    end

    @overlays = Array.new(SCREEN_COLS + 1) do
      Array.new(SCREEN_ROWS + 1)
    end
    (0..SCREEN_COLS).each do |i|
      (0..SCREEN_ROWS).each do |j|
        tl = i == 0 || j == 0 ? '' : @tiles[i - 1][j - 1]
        tr = i == SCREEN_COLS || j == 0 ? '' : @tiles[i][j - 1]
        bl = i == 0 || j == SCREEN_ROWS ? '' : @tiles[i - 1][j]
        br = i == SCREEN_COLS || j == SCREEN_ROWS ? '' : @tiles[i][j]
        top_left = i == 0 && j == 0 || i == 0 && tr == '\\' || j == 0 && bl == '\\' || /[\/\\]/ =~ tl
        top_right = i == SCREEN_COLS && j == 0 || i == SCREEN_COLS && tl == '\\' || j == 0 && br == '\\' || /[\/\\]/ =~ tr
        bottom_left = i == 0 && j == SCREEN_ROWS || i == 0 && br == '\\' || j == SCREEN_ROWS && tl == '\\' || /[\/\\]/ =~ bl
        bottom_right = i == SCREEN_COLS && j == SCREEN_ROWS || i == SCREEN_COLS && bl == '\\' || j == SCREEN_ROWS && tr == '\\' || /[\/\\]/ =~ br
        @overlays[i][j] = top_left && top_right && bottom_left && bottom_right
      end
    end

    @tile_size = Game.scale * BASE_TILE_SIZE
    @margin = Vector.new((Game.window_size.x - @tile_size * SCREEN_COLS) / 2,
                         (Game.window_size.y - @tile_size * SCREEN_ROWS) / 2)

    @man = Man.new(@margin.x, @margin.y, 0, 0)
    @objects = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS) do
        []
      end
    end
    @objects[2][1] << Box.new(@margin.x + 2 * @tile_size, @margin.y + @tile_size, 2, 1)
  end

  def get_tile(i, j)
    return 0 if @tiles[i][j] == '.'

    edge = @tiles[i][j] == '\\'
    up = j > 0 && /[\/\\]/ =~ @tiles[i][j - 1] || j == 0 && edge
    rt = i < SCREEN_COLS - 1 && /[\/\\]/ =~ @tiles[i + 1][j] || i == SCREEN_COLS - 1 && edge
    dn = j < SCREEN_ROWS - 1 && /[\/\\]/ =~ @tiles[i][j + 1] || j == SCREEN_ROWS - 1 && edge
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
    @man.update(@objects)
  end

  def draw
    (0..SCREEN_COLS).each do |i|
      (0..SCREEN_ROWS).each do |j|
        if @overlays[i][j]
          @tileset[OVERLAY_TILE_INDEX].draw(i * @tile_size + @margin.x - @tile_size / 2,
                                            j * @tile_size + @margin.y - @tile_size / 2,
                                            1, Game.scale, Game.scale)
        end

        next if i == SCREEN_COLS || j == SCREEN_ROWS
        index = get_tile(i, j)
        @tileset[index].draw(i * @tile_size + @margin.x, j * @tile_size + @margin.y, 0, Game.scale, Game.scale)
        if (i + j) % 2 == 0
          Gosu.draw_rect(i * @tile_size + @margin.x, j * @tile_size + @margin.y, @tile_size, @tile_size, 0x08000000, 2)
        end
      end
    end

    @man.draw(2 + (@man.y - @margin.y) / @tile_size)
    @objects.flatten.each do |obj|
      obj.draw(2 + (obj.y - @margin.y) / @tile_size)
    end

    if @margin.x > 0.01
      Gosu.draw_rect(0, 0, @margin.x, Game.window_size.y, 0xff000000, 100)
      Gosu.draw_rect(Game.window_size.x - @margin.x, 0, @margin.x, Game.window_size.y, 0xff000000, 100)
    end
    if @margin.y > 0.01
      Gosu.draw_rect(0, 0, Game.window_size.x, @margin.y, 0xff000000, 100)
      Gosu.draw_rect(0, Game.window_size.y - @margin.y, Game.window_size.x, @margin.y, 0xff000000, 100)
    end
  end
end
