require 'app/map.rb'
require 'app/entities.rb'

WIDTH = 1280
HEIGHT = 720

class SkeletonGame
  MAP_TITLE_SIZE = 32
  MAX_ENEMIES = 2

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

    #outputs.sounds  << "music/danse-macabre-op-40.wav" if state.tick_count == 0
  end

  def render_background
    outputs.solids << [grid.rect, 33, 33, 33]
    outputs.labels << [grid.left + 20, grid.top - 20, "Skeleton", 128, 128, 128]
  end

  def render
    outputs.sprites << state.walls.map { |w| w.rect.merge({ path: 'sprites/wall.png' }) } 
    state.tomb.object.render(outputs, state.tick_count)
    state.enemies.each { |enemy| enemy.object.render(outputs, state.tick_count) }
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
    puts "Walls loaded: #{walls.count}"
    walls 
  end

  def tomb_from_map
    state.new_entity(:tomb, object: Tomb.new(GameMap.tomb[0]*MAP_TITLE_SIZE + offset_x, GameMap.tomb[1]*MAP_TITLE_SIZE + offset_y, MAP_TITLE_SIZE))
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

        state.enemies << state.new_entity(:enemy, object: Spider.new(spawn_point[0]*MAP_TITLE_SIZE + offset_x, spawn_point[1]*MAP_TITLE_SIZE + offset_y, MAP_TITLE_SIZE))
      end
      state.last_spawn = state.tick_count
    end
  end

  def spawn_rate
    30
  end

  def enemies_action
    # Clean up expired enemies
    state.enemies.reject!{ |enemy| enemy.object.expired? }
    # Action each enemy
    state.enemies.each do |enemy|
      enemy.object.perform_action!(state.tomb.object, [state.walls.map(&:rect), state.tomb.object.collision_rect].flatten, state.tick_count)
    end
  end

  def check_input
    if inputs.mouse.click
      click_x = inputs.mouse.click.point.x
      click_y = inputs.mouse.click.point.y

      state.enemies.each do |enemy|
        if enemy.object.rect.intersect_rect? [click_x, click_y, 1, 1]
          enemy.object.damage!(5, click_x, click_y)
        end
      end
    end
  end

  def check_death
    if state.tomb.object.health <= 0 
      outputs.labels << [WIDTH/2, 640, "GAME OVER!", 24, 1, 180, 180, 180]
    end
  end
end

@first_render = false
def tick args
  game = SkeletonGame.new(args)
  game.init_state
  game.render_background
  game.render


  game.check_input 

  game.spawn_enemies
  game.enemies_action
  
  game.check_death

#  game.fire_traps
end