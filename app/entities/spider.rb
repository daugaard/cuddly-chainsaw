class Spider < Entity
  SPEED = 1
  ATTACK_DAMAGE = 4
  ATTACK_RATE = 30 
  EXPIRATION_POST_DEATH = 20

  attr_accessor :last_damage_tick, :attack_rate, :speed, :attack_damage, :state

  def initialize(x, y, size)
    super(x, y, size)
    @last_damage_tick = 0
    @attack_rate = ATTACK_RATE
    @speed = SPEED
    @attack_damage = ATTACK_DAMAGE
    @dead_for = 0
    @state = :moving
  end

  def perform_action!(target, solid_objects_rects, tick_count)
    return if state == :dead || state == :dead_timedout

    if rect.intersect_rect?(target.rect)
      state = :attacking
      if (last_damage_tick + attack_rate) < tick_count
        target.damage!(attack_damage, x, y + size)
        @last_damage_tick = tick_count
      end
    else
      state = :moving

      x_direction = rect[:x] > target.x ? -1 : 1 
      y_direction = rect[:y] > target.y ? -1 : 1

      # Try x-move and only move if its doesn't intersect with a wall
      new_rect = rect
      new_rect[:x] = new_rect[:x] + (speed * x_direction)
      move(new_rect[:x], new_rect[:y]) unless solid_objects_rects.any? { |solid_rect| new_rect.intersect_rect?(solid_rect) } 
      
      # Try y-move and only move if its doesn't intersect with a wall
      new_rect = rect.clone
      new_rect[:y] = new_rect[:y] + (speed * y_direction)
      move(new_rect[:x], new_rect[:y]) unless solid_objects_rects.any? { |solid_rect| new_rect.intersect_rect?(solid_rect) }
    end
  end

  def sprite_name(tick)
    sprite_number = tick % 4
    if state == :moving ||  state == :attacking
      "sprites/spider_walk_#{sprite_number}.png"
    elsif state == :attacking

    elsif state == :dead 
      @dead_for = @dead_for + 1
      @state = :dead_timedout if @dead_for > 4
      "sprites/spider_dead_#{sprite_number}.png"
    elsif state == :dead_timedout
      @dead_for = @dead_for + 1
      "sprites/spider_dead_3.png"
    end
  end

  def damage!(damage, x, y)
    return if state == :dead || state == :dead_timedout
    super(damage, x, y)
    @state = :dead if health <= 0
  end
  
  def move(x,y)
    @x = x 
    @y = y
  end

  def max_health
    10
  end

  def expired?
    state == :dead_timedout && @dead_for > EXPIRATION_POST_DEATH
  end
end
