class Spider < Entity
  SPEED = 2
  ATTACK_DAMAGE = 4
  ATTACK_RATE = 30 

  attr_accessor :last_damage_tick, :attack_rate, :speed, :attack_damage

  def initialize(x, y, size)
    super(x, y, size)
    @last_damage_tick = 0
    @attack_rate = ATTACK_RATE
    @speed = SPEED
    @attack_damage = ATTACK_DAMAGE
  end

  def sprite_name(tick)
    sprite_number = tick % 4
    "sprites/spider_walk_#{sprite_number}.png"
  end
  
  def move(x,y)
    @x = x 
    @y = y
  end

  def max_health
    10
  end
end
