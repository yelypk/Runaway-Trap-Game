local C = require("src.ecs.components")
local V = require("src.ecs.view")

local M = {}

function M.rebuild_view(W)
  -- view drop down
  W.walls.dense, W.walls.sparse, W.walls.size = {}, {}, 0
  for id, is_wall in pairs(C.tag_wall) do
    if is_wall and C.alive[id] then
      V.add(W.walls, id)
    end
  end
end

return M

