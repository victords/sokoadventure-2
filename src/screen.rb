require 'minigl'
require_relative 'man'
require_relative 'box'
require_relative 'wall'

include MiniGL

class Screen
  OVERLAY_HOLE_INDEX = 6
  OVERLAY_PATH_INDEX = 7

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
        tl = i == 0 || j == 0 ? nil : @tiles[i - 1][j - 1]
        tr = i == SCREEN_COLS || j == 0 ? nil : @tiles[i][j - 1]
        bl = i == 0 || j == SCREEN_ROWS ? nil : @tiles[i - 1][j]
        br = i == SCREEN_COLS || j == SCREEN_ROWS ? nil : @tiles[i][j]
        next if [tl, tr, bl, br].compact.map(&:downcase).uniq.size > 1

        top_left = i == 0 && j == 0 || i == 0 && /[PH]/ =~ tr || j == 0 && /[PH]/ =~ bl || /[pPhH]/ =~ tl
        top_right = i == SCREEN_COLS && j == 0 || i == SCREEN_COLS && /[PH]/ =~ tl || j == 0 && /[PH]/ =~ br || /[pPhH]/ =~ tr
        bottom_left = i == 0 && j == SCREEN_ROWS || i == 0 && /[PH]/ =~ br || j == SCREEN_ROWS && /[PH]/ =~ tl || /[pPhH]/ =~ bl
        bottom_right = i == SCREEN_COLS && j == SCREEN_ROWS || i == SCREEN_COLS && /[PH]/ =~ bl || j == SCREEN_ROWS && /[PH]/ =~ tr || /[pPhH]/ =~ br
        @overlays[i][j] = top_left && top_right && bottom_left && bottom_right && (tl || tr || bl || br)
      end
    end

    @margin = Vector.new((Game.window_size.x - Game.tile_size * SCREEN_COLS) / 2,
                         (Game.window_size.y - Game.tile_size * SCREEN_ROWS) / 2)

    @man = Man.new(@margin.x, @margin.y, 0, 0)
    @objects = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS) do
        []
      end
    end
    @objects[2][1] << Box.new(@margin.x + 2 * Game.tile_size, @margin.y + 1 * Game.tile_size, 2, 1)
    @objects[4][6] << Box.new(@margin.x + 4 * Game.tile_size, @margin.y + 6 * Game.tile_size, 4, 6)
    @objects[3][8] << Wall.new(@margin.x + 3 * Game.tile_size, @margin.y + 8 * Game.tile_size, 3, 8)
    @objects[4][8] << Wall.new(@margin.x + 4 * Game.tile_size, @margin.y + 8 * Game.tile_size, 4, 8)
    @objects[5][8] << Wall.new(@margin.x + 5 * Game.tile_size, @margin.y + 8 * Game.tile_size, 5, 8)
    @objects[6][8] << Wall.new(@margin.x + 6 * Game.tile_size, @margin.y + 8 * Game.tile_size, 6, 8)
    @objects[7][8] << Wall.new(@margin.x + 7 * Game.tile_size, @margin.y + 8 * Game.tile_size, 7, 8)
    @objects[17][2] << Wall.new(@margin.x + 17 * Game.tile_size, @margin.y + 2 * Game.tile_size, 17, 2)
    @objects[17][3] << Wall.new(@margin.x + 17 * Game.tile_size, @margin.y + 3 * Game.tile_size, 17, 3)
    @objects[17][4] << Wall.new(@margin.x + 17 * Game.tile_size, @margin.y + 4 * Game.tile_size, 17, 4)
    @objects[15][6] << Wall.new(@margin.x + 15 * Game.tile_size, @margin.y + 6 * Game.tile_size, 15, 6)
    @objects[11][10] << Wall.new(@margin.x + 11 * Game.tile_size, @margin.y + 10 * Game.tile_size, 11, 10)
  end

  def get_tile(i, j)
    return 0 if @tiles[i][j] == '.'

    hole = /[hH]/ =~ @tiles[i][j]
    edge = /[PH]/ =~ @tiles[i][j]
    match = hole ? /[hH]/ : /[pP]/
    up = j > 0 && match =~ @tiles[i][j - 1] || j == 0 && edge
    rt = i < SCREEN_COLS - 1 && match =~ @tiles[i + 1][j] || i == SCREEN_COLS - 1 && edge
    dn = j < SCREEN_ROWS - 1 && match =~ @tiles[i][j + 1] || j == SCREEN_ROWS - 1 && edge
    lf = i > 0 && match =~ @tiles[i - 1][j] || i == 0 && edge

    tile = 23
    if up && rt && dn && lf
      tile = 14
    elsif up && rt && dn
      tile = 12
    elsif up && rt && lf
      tile = 20
    elsif up && dn && lf
      tile = 21
    elsif rt && dn && lf
      tile = 13
    elsif up && rt
      tile = 18
    elsif up && dn
      tile = 22
    elsif up && lf
      tile = 19
    elsif rt && dn
      tile = 10
    elsif rt && lf
      tile = 15
    elsif dn && lf
      tile = 11
    elsif up
      tile = 8
    elsif rt
      tile = 9
    elsif dn
      tile = 17
    elsif lf
      tile = 16
    end
    hole ? tile + 16 : tile
  end

  def update
    @man.update(@objects)
    @objects.flatten.each(&:update)
  end

  def draw
    (0..SCREEN_COLS).each do |i|
      (0..SCREEN_ROWS).each do |j|
        if @overlays[i][j]
          index = @overlays[i][j].downcase == 'h' ? OVERLAY_HOLE_INDEX : OVERLAY_PATH_INDEX
          @tileset[index].draw(i * Game.tile_size + @margin.x - Game.tile_size / 2,
                               j * Game.tile_size + @margin.y - Game.tile_size / 2,
                               1, Game.scale, Game.scale)
        end

        next if i == SCREEN_COLS || j == SCREEN_ROWS
        index = get_tile(i, j)
        @tileset[index].draw(i * Game.tile_size + @margin.x, j * Game.tile_size + @margin.y, 0, Game.scale, Game.scale)
        if (i + j) % 2 == 0
          Gosu.draw_rect(i * Game.tile_size + @margin.x, j * Game.tile_size + @margin.y, Game.tile_size, Game.tile_size, 0x08000000, 2)
        end
      end
    end

    @man.draw(2 + (@man.y - @margin.y) / Game.tile_size)
    @objects.flatten.each do |obj|
      obj.draw(2 + (obj.y - @margin.y) / Game.tile_size)
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
