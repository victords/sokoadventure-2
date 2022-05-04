require 'minigl'
require_relative 'man'
require_relative 'box'
require_relative 'wall'
require_relative 'ball'
require_relative 'key'

include MiniGL

class Screen
  GROUND_INDEX = 0
  AIM_INDEX = 5
  OVERLAY_HOLE_INDEX = 6
  OVERLAY_PATH_INDEX = 7

  def initialize
    @tileset = Res.tileset('1', BASE_TILE_SIZE, BASE_TILE_SIZE)
    tile_codes = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS)
    end
    File.open("#{Res.prefix}screen/1") do |f|
      f.each.with_index do |line, j|
        line.chomp.each_char.with_index do |c, i|
          tile_codes[i][j] = c
        end
      end
    end

    @margin = Vector.new((Game.window_size.x - Game.tile_size * SCREEN_COLS) / 2,
                         (Game.window_size.y - Game.tile_size * SCREEN_ROWS) / 2)
    @tiles = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS)
    end
    @objects = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS) do
        []
      end
    end
    (0...SCREEN_COLS).each do |i|
      (0...SCREEN_ROWS).each do |j|
        @tiles[i][j] = get_tile(tile_codes, i, j)
        code = tile_codes[i][j]
        obj_class = case code
                    when /[bB]/  then Ball
                    when 'x'     then Box
                    when '#'     then Wall
                    when /[k-n]/ then Key
                    end
        next unless obj_class

        @objects[i][j] << obj_class.new(@margin.x + i * Game.tile_size, @margin.y + j * Game.tile_size, i, j, code)
      end
    end

    @overlays = Array.new(SCREEN_COLS + 1) do
      Array.new(SCREEN_ROWS + 1)
    end
    (0..SCREEN_COLS).each do |i|
      (0..SCREEN_ROWS).each do |j|
        tl = i == 0 || j == 0 ? nil : tile_codes[i - 1][j - 1]
        tr = i == SCREEN_COLS || j == 0 ? nil : tile_codes[i][j - 1]
        bl = i == 0 || j == SCREEN_ROWS ? nil : tile_codes[i - 1][j]
        br = i == SCREEN_COLS || j == SCREEN_ROWS ? nil : tile_codes[i][j]
        next if [tl, tr, bl, br].compact.map(&:downcase).uniq.size > 1

        top_left = i == 0 && j == 0 || i == 0 && /[PH]/ =~ tr || j == 0 && /[PH]/ =~ bl || /[pPhH]/ =~ tl
        top_right = i == SCREEN_COLS && j == 0 || i == SCREEN_COLS && /[PH]/ =~ tl || j == 0 && /[PH]/ =~ br || /[pPhH]/ =~ tr
        bottom_left = i == 0 && j == SCREEN_ROWS || i == 0 && /[PH]/ =~ br || j == SCREEN_ROWS && /[PH]/ =~ tl || /[pPhH]/ =~ bl
        bottom_right = i == SCREEN_COLS && j == SCREEN_ROWS || i == SCREEN_COLS && /[PH]/ =~ bl || j == SCREEN_ROWS && /[PH]/ =~ tr || /[pPhH]/ =~ br
        if top_left && top_right && bottom_left && bottom_right
          type = (tl || tr || bl || br).downcase
          @overlays[i][j] = type == 'h' ? OVERLAY_HOLE_INDEX : OVERLAY_PATH_INDEX
        end
      end
    end

    @man = Man.new(@margin.x, @margin.y, 0, 0)
  end

  def get_tile(tile_codes, i, j)
    return { type: :ground, index: GROUND_INDEX } if /[.bx#k-n]/ =~ tile_codes[i][j]
    return { type: :aim, index: AIM_INDEX } if /[aB]/ =~ tile_codes[i][j]

    hole = /[hH]/ =~ tile_codes[i][j]
    edge = /[PH]/ =~ tile_codes[i][j]
    match = hole ? /[hH]/ : /[pP]/
    up = j > 0 && match =~ tile_codes[i][j - 1] || j == 0 && edge
    rt = i < SCREEN_COLS - 1 && match =~ tile_codes[i + 1][j] || i == SCREEN_COLS - 1 && edge
    dn = j < SCREEN_ROWS - 1 && match =~ tile_codes[i][j + 1] || j == SCREEN_ROWS - 1 && edge
    lf = i > 0 && match =~ tile_codes[i - 1][j] || i == 0 && edge

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
    hole ? { type: :hole, index: tile + 16 } : { type: :path, index: tile }
  end

  def update
    @man.update(@objects, @tiles)
    @objects.each_with_index do |col, i|
      col.each_with_index do |cell, j|
        cell.reverse_each do |obj|
          obj.update
          if obj.is_a?(Box) && @tiles[i][j][:type] == :hole
            @tiles[i][j][:type] = :ground
          end
        end
      end
    end
  end

  def draw
    (0..SCREEN_COLS).each do |i|
      (0..SCREEN_ROWS).each do |j|
        if @overlays[i][j]
          @tileset[@overlays[i][j]].draw(i * Game.tile_size + @margin.x - Game.tile_size / 2,
                                         j * Game.tile_size + @margin.y - Game.tile_size / 2,
                                         1, Game.scale, Game.scale)
        end
        next if i == SCREEN_COLS || j == SCREEN_ROWS

        @tileset[@tiles[i][j][:index]].draw(i * Game.tile_size + @margin.x, j * Game.tile_size + @margin.y, 0, Game.scale, Game.scale)
        if (i + j) % 2 == 0
          Gosu.draw_rect(i * Game.tile_size + @margin.x, j * Game.tile_size + @margin.y, Game.tile_size, Game.tile_size, 0x08000000, 2)
        end
      end
    end

    @objects.flatten.each do |obj|
      obj.draw(2 + ((obj.y - @margin.y) / Game.tile_size).ceil)
    end
    @man.draw(2 + ((@man.y - @margin.y) / Game.tile_size).ceil)

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
