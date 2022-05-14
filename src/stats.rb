class Stats
  attr_reader :items, :on_add_item, :on_use_item

  def initialize
    @items = {}
    @on_add_item = []
    @on_use_item = []
  end

  def add_item(type, x, y)
    key = type
    @items[key] ||= 0
    @items[key] += 1

    @on_add_item.each { |c| c.call(type, x, y) }
  end

  def use_item(type)
    return unless @items.keys.include?(type)

    @items[type] -= 1
    @items.delete(type) if @items[type] <= 0

    @on_use_item.each { |c| c.call(type) }
  end
end
