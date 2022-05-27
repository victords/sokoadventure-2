require 'minigl'
require_relative 'exit'
require_relative 'man'
require_relative 'objects'
require_relative 'ui/item_panel'
require_relative 'ui/item_get_effect'

include MiniGL

class Screen
  GROUND_INDEX = 0
  AIM_INDEX = 5
  OVERLAY_HOLE_INDEX = 6
  OVERLAY_PATH_INDEX = 7

  attr_accessor :active

  def initialize(id)
    tile_codes = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS)
    end
    @entrances = []
    @objects = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS) do
        []
      end
    end

    File.open("#{Res.prefix}screen/#{id}") do |f|
      header = true
      j = 0
      f.each do |line|
        next header = false if line[0] == '%'

        if header
          data = line.chomp.split(':')
          args = data[1].split(',').map(&:to_i)
          case data[0]
          when 'e'
            @entrances << args
          when 'x'
            @objects[args[0]][args[1]] << (xit = Exit.new(args[2], args[3]))
            xit.on_activate = method(:on_exit)
          else
            x = Game.screen_margin.x + args[0] * Game.tile_size
            y = Game.screen_margin.y + args[1] * Game.tile_size
            type = Object.const_get(data[0])
            @objects[args[0]][args[1]] << type.new(x, y, @objects, args)
          end
          next
        end

        line.chomp.each_char.with_index do |c, i|
          tile_codes[i][j] = c
        end
        j += 1
      end
    end

    @tiles = Array.new(SCREEN_COLS) do
      Array.new(SCREEN_ROWS)
    end
    (0...SCREEN_COLS).each do |i|
      (0...SCREEN_ROWS).each do |j|
        @tiles[i][j] = get_tile(tile_codes, i, j)
        next unless tile_codes[i][j] == '#'

        @objects[i][j] << Wall.new(Game.screen_margin.x + i * Game.tile_size,
                                   Game.screen_margin.y + j * Game.tile_size)
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

    @tileset = Res.tileset('1', BASE_TILE_SIZE, BASE_TILE_SIZE)
    @effects = []

    Game.stats.on_add_item << method(:on_add_item)
    Game.stats.on_use_item << method(:on_use_item)
  end

  def reset(entrance_id)
    col, row, dir = @entrances[entrance_id]
    @man = Man.new(Game.screen_margin.x + col * Game.tile_size, Game.screen_margin.y + row * Game.tile_size, col, row)
    @man.set_dir(dir)
    @active = true

    self
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

  def on_add_item(type, x, y)
    return unless @active

    if (e = @effects.find { |e| e.is_a?(ItemPanel) && e.item_type == type })
      e.refresh
    else
      @effects << ItemPanel.new(type) unless @effects.any? { |e| e.is_a?(ItemPanel) && e.item_type == type }
    end
    @effects << ItemGetEffect.new(type, x, y)
  end

  def on_use_item(type)
    return unless @active

    if (e = @effects.find { |e| e.is_a?(ItemPanel) && e.item_type == type })
      e.refresh
    else
      @effects << ItemPanel.new(type) unless @effects.any? { |e| e.is_a?(ItemPanel) && e.item_type == type }
    end
  end

  def on_exit(xit)
    Game.load_screen(xit.dest_screen, xit.dest_entrance, true)
  end

  def clear_effects
    @effects.clear
  end

  def update
    @man.update(@objects, @tiles, @active)
    @objects.each_with_index do |col, i|
      col.each_with_index do |cell, j|
        cell.reverse_each do |obj|
          obj.update
          if obj.is_a?(Box) && @tiles[i][j][:type] == :hole
            @tiles[i][j][:type] = :ground
          end
          cell.delete(obj) if obj.dead
        end
      end
    end

    @effects.reverse_each do |e|
      e.update
      @effects.delete(e) if e.dead
    end
  end

  def draw
    margin = Game.screen_margin

    (0..SCREEN_COLS).each do |i|
      (0..SCREEN_ROWS).each do |j|
        if @overlays[i][j]
          @tileset[@overlays[i][j]].draw(i * Game.tile_size + margin.x - Game.tile_size / 2,
                                         j * Game.tile_size + margin.y - Game.tile_size / 2,
                                         1, Game.scale, Game.scale)
        end
        next if i == SCREEN_COLS || j == SCREEN_ROWS

        @tileset[@tiles[i][j][:index]].draw(i * Game.tile_size + margin.x, j * Game.tile_size + margin.y, 0, Game.scale, Game.scale)
        if (i + j) % 2 == 0
          Gosu.draw_rect(i * Game.tile_size + margin.x, j * Game.tile_size + margin.y, Game.tile_size, Game.tile_size, 0x08000000, 2)
        end
      end
    end

    @objects.flatten.each do |obj|
      obj.draw(10 * (((obj.y - margin.y) / Game.tile_size).ceil + 1))
    end
    @man.draw(10 * (((@man.y - margin.y) / Game.tile_size).ceil + 1) + 9)

    @effects.each(&:draw)

    if margin.x > 0.01
      Gosu.draw_rect(0, 0, margin.x, Game.window_size.y, 0xff000000, UI_Z_INDEX + 100)
      Gosu.draw_rect(Game.window_size.x - margin.x, 0, margin.x, Game.window_size.y, 0xff000000, UI_Z_INDEX + 100)
    end
    if margin.y > 0.01
      Gosu.draw_rect(0, 0, Game.window_size.x, margin.y, 0xff000000, UI_Z_INDEX + 100)
      Gosu.draw_rect(0, Game.window_size.y - margin.y, Game.window_size.x, margin.y, 0xff000000, UI_Z_INDEX + 100)
    end
  end
end
