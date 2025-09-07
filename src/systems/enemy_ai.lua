local C = require("src.ecs.components")
local CFG = require("config")
local M = {}
function M.update(dt, W, player_id)
  if not player_id or not C.alive[player_id] then return end
  local px, py = C.pos_x[player_id], C.pos_y[player_id]
  local V = W.enemies
  for i = 1, V.size do
    local id = V.dense[i]
    local dx, dy = (px - C.pos_x[id]), (py - C.pos_y[id])
    local d2 = dx*dx + dy*dy
    if d2 > 1e-6 then
      local inv = 1 / math.sqrt(d2)
      C.vel_x[id] = dx * inv * CFG.enemy.speed
      C.vel_y[id] = dy * inv * CFG.enemy.speed
    else
      C.vel_x[id], C.vel_y[id] = 0, 0
    end
  end
end
return M
