class Exit
  attr_reader :x, :y, :dest_screen, :dest_entrance
  attr_writer :on_activate

  def initialize(dest_screen, dest_entrance)
    @dest_screen = dest_screen
    @dest_entrance = dest_entrance
    @x = @y = 0
  end

  def activate
    @on_activate&.call(self)
  end

  def dead; false; end

  def update; end

  def draw(z_index); end
end
