local C = require("src.ecs.components")
local M = {}
function M.update(dt, W)
  local V = W.movers
  for i = 1, V.size do
    local id = V.dense[i]
    C.pos_x[id] = C.pos_x[id] + C.vel_x[id] * dt
    C.pos_y[id] = C.pos_y[id] + C.vel_y[id] * dt
  end
end
return M
