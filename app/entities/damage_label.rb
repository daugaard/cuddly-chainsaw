class DamageLabel
  SHOW_FOR_TICKS = 60

  attr_accessor :damage, :x, :y, :ticks_left

  def initialize(damage, x, y)
    @damage = damage
    @x = x 
    @y = y
    @ticks_left = SHOW_FOR_TICKS
  end

  def render(outputs)
    @ticks_left = ticks_left - 1
    outputs.labels << { x: x, y: y + (SHOW_FOR_TICKS-ticks_left)*2, text: "-#{damage}", r: 255, g: 255, b: 255, a: (ticks_left/SHOW_FOR_TICKS)*100 }
  end

  def expired?
    ticks_left < 0
  end
end
