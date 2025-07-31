return function(menuState)
    if menuState.active then
        if love.keyboard.isDown("1") then
            menuState.selected = 1
        elseif love.keyboard.isDown("2") then
            menuState.selected = 2
        end
        if love.keyboard.isDown("return") and menuState.selected then
            menuState.active = false
            menuState.startGame = true
        end
    end
end
