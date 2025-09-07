local C = require("src.ecs.components")
local CFG = require("config")
local M = {}

function M.draw(W)
  love.graphics.clear(CFG.bg)

  local Vw = W.walls
  love.graphics.setColor(CFG.wall.color)
  for i = 1, Vw.size do
    local id = Vw.dense[i]
    love.graphics.rectangle("fill", C.wall_x[id], C.wall_y[id], C.wall_w[id], C.wall_h[id])
  end

  local Vc = W.circles
  for i = 1, Vc.size do
    local id = Vc.dense[i]
    love.graphics.setColor(C.col_r[id] or 1, C.col_g[id] or 1, C.col_b[id] or 1, C.col_a[id] or 1)
    love.graphics.circle("fill", C.pos_x[id], C.pos_y[id], C.radius[id])
  end
end
return M

