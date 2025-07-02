local menu = {}

local titleFont
local menuFont
local selected = 1
local options = { "Start Game", "Quit" }

function menu.load()
    titleFont = love.graphics.newFont(48)
    menuFont = love.graphics.newFont(24)
end

function menu.update(dt)
end

function menu.draw()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.9, 0.9, 1)
    love.graphics.printf("Fast-Boom!", 0, 100, love.graphics.getWidth(), "center")

    love.graphics.setFont(menuFont)
    for i, option in ipairs(options) do
        if i == selected then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        love.graphics.printf(option, 0, 220 + i * 40, love.graphics.getWidth(), "center")
    end
end

function menu.keypressed(key)
    if key == "up" then
        selected = selected - 1
        if selected < 1 then selected = #options end
    elseif key == "down" then
        selected = selected + 1
        if selected > #options then selected = 1 end
    elseif key == "return" or key == "kpenter" then
        if options[selected] == "Start Game" then
            return "start"
        elseif options[selected] == "Quit" then
            love.event.quit()
        end
    end
end

return menu