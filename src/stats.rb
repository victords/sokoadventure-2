class Stats
  attr_reader :items

  def initialize
    @items = {}
  end

  def add_item(type)
    key = type
    @items[key] ||= 0
    @items[key] += 1
  end
end
