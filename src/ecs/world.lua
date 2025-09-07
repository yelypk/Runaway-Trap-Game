local C = require("src.ecs.components")
local V = require("src.ecs.view")
local CFG = require("config")

local World = {
  next_id = 0,
  movers = V.new(),
  circles = V.new(),
  enemies = V.new(),
  traps = V.new(),
  walls = V.new(),
  draw_all = V.new(),
}

local function new_id()
  World.next_id = World.next_id + 1
  return World.next_id
end

local function set_color(id, rgba)
  C.col_r[id], C.col_g[id], C.col_b[id], C.col_a[id] = rgba[1], rgba[2], rgba[3], rgba[4] or 1
end

function World.spawn_player(x, y)
  local id = new_id()
  C.pos_x[id], C.pos_y[id] = x, y
  C.vel_x[id], C.vel_y[id] = 0, 0
  C.radius[id] = CFG.player.radius
  C.tag_player[id] = true
  C.alive[id] = true
  set_color(id, CFG.player.color)
  V.add(World.movers, id); V.add(World.circles, id); V.add(World.draw_all, id)
  return id
end

function World.spawn_enemy(x, y)
  local id = new_id()
  C.pos_x[id], C.pos_y[id] = x, y
  C.vel_x[id], C.vel_y[id] = 0, 0
  C.radius[id] = CFG.enemy.radius
  C.tag_enemy[id] = true
  C.alive[id] = true
  set_color(id, CFG.enemy.color)
  V.add(World.movers, id); V.add(World.enemies, id); V.add(World.circles, id); V.add(World.draw_all, id)
  return id
end

function World.spawn_trap(cx, cy, orbit_radius, point_radius, omega)
  local id = new_id()
  C.trap_cx[id], C.trap_cy[id] = cx, cy
  C.trap_rr[id] = orbit_radius
  C.trap_ca[id], C.trap_sa[id] = 1, 0
  C.trap_w[id] = omega or 1.7
  C.radius[id] = point_radius or CFG.trap.radius
  C.tag_trap[id] = true
  C.alive[id] = true
  set_color(id, CFG.trap.color)
  C.pos_x[id] = cx + orbit_radius * C.trap_ca[id]
  C.pos_y[id] = cy + orbit_radius * C.trap_sa[id]
  V.add(World.traps, id); V.add(World.circles, id); V.add(World.draw_all, id)
  return id
end

function World.spawn_wall(x, y, w, h)
  local id = new_id()
  C.wall_x[id], C.wall_y[id] = x, y
  C.wall_w[id], C.wall_h[id] = w, h
  C.tag_wall[id] = true
  C.alive[id] = true
  set_color(id, CFG.wall.color)
  V.add(World.walls, id); V.add(World.draw_all, id)
  return id
end

function World.spawn_walls_from_grid(grid, tile)
  tile = tile or CFG.level_tile
  for gy = 1, #grid do
    local row = grid[gy]
    for gx = 1, #row do
      if row[gx] == 1 then
        World.spawn_wall((gx-1)*tile, (gy-1)*tile, tile, tile)
      end
    end
  end
end

function World.despawn(id)
  C.alive[id] = false
end

return World
