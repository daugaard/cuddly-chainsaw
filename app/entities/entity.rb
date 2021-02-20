class Entity
  HEALTH_BAR_WIDTH = 50

  attr_accessor :health, :size, :x, :y, :damage_labels

  def initialize(x, y, size)
    @health = max_health
    @x = x
    @y = y
    @size = size 
    @damage_labels = []
  end

  def render(outputs, tick) 
    if health < max_health
      outputs.solids << { x: x - (HEALTH_BAR_WIDTH-size)/2, y: y + size + 5, h: 4, w: (HEALTH_BAR_WIDTH*(health/max_health)), r: 0, g: 255, b: 0, a: 70 }
    end
    outputs.sprites << rect.merge({ path: sprite_name(tick) })
    # Remove exipred labels and render the rest
    damage_labels.reject! { |l| l.expired? }
    damage_labels.each { |l| l.render(outputs) }
  end

  def rect
    { x: x, y: y, h: size, w: size }
  end

  def collision_rect
    { x: x+size/4, y: y+size/4, h: size/2, w: size/2 }
  end

  def damage(damage, x, y)
    @health = (health - damage) < 0 ? 0 : health - damage
    damage_labels << DamageLabel.new(damage, x, y) if @health > 0
  end

  def max_health
    100
  end
end
