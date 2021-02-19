require 'app/map.rb'

WIDTH = 1280
HEIGHT = 720

class SkeletonGame
  MAP_TITLE_SIZE = 32
  MAX_ENEMIES = 12

  attr_accessor :outputs, :args, :grid, :state, :last_spawn, :inputs

  def initialize(args)
    @args = args
    @outputs = args.outputs
    @inputs = args.inputs
    @grid = args.grid
    @state = args.state
  end

  def init_state
    state.last_spawn ||= 0
    state.enemies ||= []
    state.walls ||= walls_from_map
    state.tomb ||= tomb_from_map

    outputs.sounds  << "music/danse-macabre-op-40.wav" if state.tick_count == 0
  end

  def render_background
    outputs.solids << [grid.rect, 33, 33, 33]
    outputs.labels << [grid.left + 20, grid.top - 20, "Skeleton", 128, 128, 128]
  end

  def render
    state.walls.each do |wall|
      outputs.sprites << wall.rect.merge({ path: 'sprites/wall.png' })
    end
    outputs.sprites << state.tomb.rect.merge({ path: 'sprites/chest.png', a: state.tomb.health })
    state.enemies.each do |enemy|
      sprite_number = state.tick_count % 4
      outputs.sprites << enemy.rect.merge({ path: "sprites/spider_walk_#{sprite_number}.png", a: 255})
    end
  end

  def walls_from_map
    walls = [] 
    GameMap.map.each_with_index do |r, row|
      r.each_with_index do |cell, column|
        if cell == 1 
          walls << state.new_entity(:wall, rect: { x: column*MAP_TITLE_SIZE + offset_x, y: row*MAP_TITLE_SIZE + offset_y, h: MAP_TITLE_SIZE, w: MAP_TITLE_SIZE})
        end
      end
    end
    walls 
  end

  def tomb_from_map
    state.new_entity(:tomb, 
      rect: { x: GameMap.tomb[0]*MAP_TITLE_SIZE + offset_x, y: GameMap.tomb[1]*MAP_TITLE_SIZE + offset_y, h: MAP_TITLE_SIZE, w: MAP_TITLE_SIZE },
      collision_rect: { x:GameMap.tomb[0]*MAP_TITLE_SIZE + offset_x + MAP_TITLE_SIZE/4, y: GameMap.tomb[1]*MAP_TITLE_SIZE + offset_y + MAP_TITLE_SIZE/4, h: MAP_TITLE_SIZE/2, w: MAP_TITLE_SIZE/2},
      health: 255
    )
  end

  def offset_x
    (WIDTH - (GameMap.map.first.size * MAP_TITLE_SIZE)) / 2
  end

  def offset_y
    (HEIGHT - (GameMap.map.size * MAP_TITLE_SIZE)) / 2
  end

  def spawn_enemies
    if state.tick_count == (state.last_spawn + spawn_rate)
      if state.enemies.count < MAX_ENEMIES
        spawn_point = GameMap.spawn_points.sample

        state.enemies << state.new_entity(:enemy, 
          rect: { x: spawn_point[0]*MAP_TITLE_SIZE + offset_x, y: spawn_point[1]*MAP_TITLE_SIZE + offset_y, h: MAP_TITLE_SIZE, w: MAP_TITLE_SIZE },
          speed: 1
        )
      end
      state.last_spawn = state.tick_count
    end
  end

  def spawn_rate
    30
  end

  def move_enemies
    state.enemies.each do |enemy|
      x_direction = enemy.rect[:x] > state.tomb.rect[:x] ? -1 : 1 
      y_direction = enemy.rect[:y] > state.tomb.rect[:y] ? -1 : 1

      # Try x-move and only move if its doesn't intersect with a wall
      new_rect = enemy.rect.clone
      new_rect[:x] = enemy.rect[:x] + (enemy.speed * x_direction)
      enemy.rect = new_rect unless state.walls.any? { |wall| new_rect.intersect_rect?(wall.rect) } || state.tomb.collision_rect.intersect_rect?(new_rect)
      
      # Try y-move and only move if its doesn't intersect with a wall
      new_rect = enemy.rect.clone
      new_rect[:y] = enemy.rect[:y] + (enemy.speed * y_direction)
      enemy.rect = new_rect unless state.walls.any? { |wall| new_rect.intersect_rect?(wall.rect) } || state.tomb.collision_rect.intersect_rect?(new_rect)
      
      if new_rect.intersect_rect?(state.tomb.rect)
        state.tomb.health -= 1
      end
    end
  end

  def check_input
    if inputs.mouse.click
      click_x = inputs.mouse.click.point.x
      click_y = inputs.mouse.click.point.y

      state.enemies.each do |enemy|
        if enemy.rect.intersect_rect? [click_x, click_y, 1, 1]
          state.enemies.delete(enemy)
        end
      end
    end
  end

  def check_death
    if state.tomb.health <= 0 
      outputs.labels << [WIDTH/2, 640, "GAME OVER!", 24, 1, 180, 180, 180]
    end
  end
end


def tick args
  game = SkeletonGame.new(args)
  game.init_state
  game.render_background
  game.render


  game.check_input 

  game.spawn_enemies
  game.move_enemies
  
  game.check_death

#  game.fire_traps
end