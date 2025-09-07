local C = require("src.ecs.components")
local CFG = require("config")

local M = {}
function M.update(dt, W, player_id)
  if not player_id or not C.alive[player_id] then return end
  local vx, vy = 0, 0
  if love.keyboard.isDown("w") or love.keyboard.isDown("up") then vy = vy - 1 end
  if love.keyboard.isDown("s") or love.keyboard.isDown("down") then vy = vy + 1 end
  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then vx = vx - 1 end
  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then vx = vx + 1 end
  if vx ~= 0 or vy ~= 0 then
    local len = math.sqrt(vx*vx + vy*vy); vx, vy = vx/len, vy/len
  end
  C.vel_x[player_id] = vx * CFG.player.speed
  C.vel_y[player_id] = vy * CFG.player.speed
end
return M
