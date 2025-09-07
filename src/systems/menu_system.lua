local M = {}
-- menu = {active=true, selected=1, startGame=false}
function M.update(menu)
  if not (menu and menu.active) then return end
  if love.keyboard.isDown("1") then menu.selected = 1 end
  if love.keyboard.isDown("2") then menu.selected = 2 end
  if love.keyboard.isDown("return") or love.keyboard.isDown("space") then
    menu.startGame = true
    menu.active = false
  end
end

return M
