class Stats
  attr_reader :items, :on_item_added

  def initialize
    @items = {}
    @on_item_added = []
  end

  def add_item(type)
    key = type.to_sym
    @items[key] ||= 0
    @items[key] += 1

    @on_item_added.each { |c| c.call(key) }
  end
end
