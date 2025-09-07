local C = require("src.ecs.components")
local CFG = require("config")

local M = {}
local cache = { built = false }

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
    local top  = y - wy
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

local function build_wall_grid(W, tile)
  tile = tile or CFG.level_tile
  cache.tile = tile
  cache.cells = {}  -- key = y..\":\"..x -> { wall_ids... }

  for i = 1, W.walls.size do
    local id = W.walls.dense[i]
    local gx = math.floor(C.wall_x[id] / tile) + 1
    local gy = math.floor(C.wall_y[id] / tile) + 1
    local key = gy .. ":" .. gx
    local bucket = cache.cells[key]
    if not bucket then bucket = {}; cache.cells[key] = bucket end
    bucket[#bucket+1] = id
  end

  cache.built = true
end

local function for_neighbor_walls(cx, cy, fn)
  for oy = -1, 1 do
    for ox = -1, 1 do
      local key = (cy + oy) .. ":" .. (cx + ox)
      local bucket = cache.cells[key]
      if bucket then
        for i = 1, #bucket do fn(bucket[i]) end
      end
    end
  end
end

function M.invalidate() cache.built = false end

function M.update(dt, W, tile)
  tile = tile or CFG.level_tile
  if not cache.built or cache.tile ~= tile then
    build_wall_grid(W, tile)
  end

  local Circles = W.circles
  for i = 1, Circles.size do
    local id = Circles.dense[i]
    if not C.tag_trap[id] then
      local x, y = C.pos_x[id], C.pos_y[id]
      local cx = math.floor(x / tile) + 1
      local cy = math.floor(y / tile) + 1
      for_neighbor_walls(cx, cy, function(wid)
        resolve_circle_aabb(id, C.wall_x[wid], C.wall_y[wid], C.wall_w[wid], C.wall_h[wid])
      end)
    end
  end
end

return M
