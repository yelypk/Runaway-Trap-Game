local M = {}
-- stats.enemy_kills >= threshold -> restart
function M.check_and_restart(stats, threshold)
  threshold = threshold or 3
  if stats and (stats.enemy_kills or 0) >= threshold then
    love.event.quit("restart")
  end
end

return M
