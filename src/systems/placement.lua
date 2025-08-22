-- Підбір вільної точки та радіуса орбіти пастки так, щоб вона не торкалася стін.
local M = {}

local SQRT2 = 1.41421356237

local function nearestWallClearance(components, x, y)
  local minc = math.huge
  local pos  = components.position or {}
  local rad  = components.radius  or {}
  for id in pairs(components.wall or {}) do
    local p, r = pos[id], rad[id]
    if p and r then
      local wr = r * SQRT2
      local dx, dy = x - p.x, y - p.y
      local d = math.sqrt(dx*dx + dy*dy) - wr
      if d < minc then minc = d end
    end
  end
  return minc
end

local function isFreeForCircle(components, x, y, r, margin)
  margin = margin or 0
  local rr = r + margin
  local W, H = love.graphics.getWidth(), love.graphics.getHeight()
  if x - rr < 0 or y - rr < 0 or x + rr > W or y + rr > H then return false end

  local pos  = components.position or {}
  local rad  = components.radius  or {}
  for id in pairs(components.wall or {}) do
    local p, wr = pos[id], rad[id]
    if p and wr then
      wr = wr * SQRT2
      local dx, dy = x - p.x, y - p.y
      if (dx*dx + dy*dy) < (rr + wr)*(rr + wr) then
        return false
      end
    end
  end
  return true
end

function M.find_trap_spot(components, opts)
  opts = opts or {}
  local minR   = opts.minR   or 12     
  local maxR   = opts.maxR   or 28
  local margin = opts.margin or 5
  local tries  = opts.tries  or 4000

  local W, H = love.graphics.getWidth(), love.graphics.getHeight()

  for _ = 1, tries do
    local x = love.math.random(margin, W - margin)
    local y = love.math.random(margin, H - margin)
    if isFreeForCircle(components, x, y, minR, margin) then
      local clearance = nearestWallClearance(components, x, y)
      local allowed = math.floor(math.min(maxR, clearance - margin))
      if allowed >= minR then
        return x, y, allowed
      end
    end
  end

  local small = math.max(8, minR - 4)
  for _ = 1, tries do
    local x = love.math.random(margin, W - margin)
    local y = love.math.random(margin, H - margin)
    if isFreeForCircle(components, x, y, small, margin) then
      local clearance = nearestWallClearance(components, x, y)
      local allowed = math.floor(math.max(8, math.min(small, clearance - margin)))
      return x, y, allowed
    end
  end

  return W * 0.5, H * 0.5, small
end

return M
