local C = require("src.ecs.components")
local M = {}

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

local function resolve_circle_aabb(id, wx, wy, ww, wh)
  local x, y = C.pos_x[id], C.pos_y[id]
  local r = C.radius[id]
  local nx = clamp(x, wx, wx+ww)
  local ny = clamp(y, wy, wy+wh)
  local dx, dy = x - nx, y - ny
  local d2 = dx*dx + dy*dy
  if d2 >= r*r then return end
  if d2 == 0 then
    local left = x - wx
    local right = (wx + ww) - x
    local top = y - wy
    local bottom = (wy + wh) - y
    local m = math.min(left, right, top, bottom)
    if m == left then x = wx - r
    elseif m == right then x = wx + ww + r
    elseif m == top then y = wy - r
    else y = wy + wh + r end
  else
    local d = math.sqrt(d2)
    x = x + dx * ((r - d) / d)
    y = y + dy * ((r - d) / d)
  end
  local vx, vy = C.vel_x[id], C.vel_y[id]
  if math.abs(dx) > math.abs(dy) then vx = 0 else vy = 0 end
  C.vel_x[id], C.vel_y[id] = vx, vy
  C.pos_x[id], C.pos_y[id] = x, y
end

local function hit_circle_circle(a, b)
  local dx = C.pos_x[a] - C.pos_x[b]
  local dy = C.pos_y[a] - C.pos_y[b]
  local r = C.radius[a] + C.radius[b]
  return (dx*dx + dy*dy) <= (r*r)
end

function M.update(dt, W, player_id, onPlayerDeath)
  local Movers, Walls = W.circles, W.walls
  for i = 1, Movers.size do
    local id = Movers.dense[i]
    for j = 1, Walls.size do
      local wid = Walls.dense[j]
      resolve_circle_aabb(id, C.wall_x[wid], C.wall_y[wid], C.wall_w[wid], C.wall_h[wid])
    end
  end
  if player_id and C.alive[player_id] then
    local E = W.enemies
    for i = 1, E.size do
      if hit_circle_circle(player_id, E.dense[i]) then
        if onPlayerDeath then onPlayerDeath() end
        break
      end
    end
    local T = W.traps
    for i = 1, T.size do
      if hit_circle_circle(player_id, T.dense[i]) then
        if onPlayerDeath then onPlayerDeath() end
        break
      end
    end
  end
end
return M
