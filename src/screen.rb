require 'minigl'

include MiniGL

class Screen
  COLS = 24
  ROWS = 13
  BASE_TILE_SIZE = 160
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
    @tile_size = Game.scale * BASE_TILE_SIZE
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

  end

  def draw
    (0...COLS).each do |i|
      (0...ROWS).each do |j|
        index = get_tile(i, j)
        @tileset[index].draw(i * @tile_size, j * @tile_size, 0, Game.scale, Game.scale)
      end
    end
    (0...COLS - 1).each do |i|
      (0...ROWS - 1).each do |j|
        if @tiles[i][j] == '/' && @tiles[i][j + 1] == '/' && @tiles[i + 1][j] == '/' && @tiles[i + 1][j + 1] == '/'
          @tileset[OVERLAY_TILE_INDEX].draw(i * @tile_size + @tile_size / 2,
                                            j * @tile_size + @tile_size / 2,
                                            0, Game.scale, Game.scale)
        end
      end
    end
  end
end
