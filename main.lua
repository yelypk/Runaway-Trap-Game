local menu = require("src.menu")
local levels = require("src.levels")
local walls = require("src.walls")
local Player = require("src.player")
local Enemy = require("src.enemy")
local Trap = require("src.trap")

local gameState = "menu"
local currentLevel = 1
local levelPassed = false

local player
local enemies = {}
local trap
local enemiesKilled = 0
local trapPathType = "circle"

local function checkCollision(a, b)
    return a.x < b.x + b.size and
           b.x < a.x + a.size and
           a.y < b.y + b.size and
           b.y < a.y + a.size
end

function startGame()
    local levelData = levels.get(currentLevel)
    player = Player.create()
    enemies = {}
    enemiesKilled = 0
    trap = Trap.create(levelData.trapSpeed)
    trapPathType = levelData.trajectory

    for i = 1, levelData.enemies do
        table.insert(enemies, Enemy.spawn(math.random(0, 780), math.random(0, 580), levelData.enemySpeed))
    end

    gameState = "playing"
end

function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle("Fast-Boom!")
    walls.load()
    menu.load()
end

function love.update(dt)
    if gameState == "menu" then
        menu.update(dt)
    elseif gameState == "playing" then
        if not player.alive then return end
        walls.update(dt)
        local oldX, oldY = Player.update(player, dt)
        if walls.checkCollision(player) then
            player.x, player.y = oldX, oldY
        end
        player.x = math.max(0, math.min(800 - player.size, player.x))
        player.y = math.max(0, math.min(600 - player.size, player.y))

        for _, e in ipairs(enemies) do
            Enemy.update(e, dt, player, walls)
        end

        Trap.update(trap, dt)

        for _, e in ipairs(enemies) do
            if e.alive and checkCollision(e, trap) then
                e.alive = false
                enemiesKilled = enemiesKilled + 1
            end
        end

        if checkCollision(player, trap) then
            player.alive = false
            gameState = "gameover"
        end

        local allDead = true
        for _, e in ipairs(enemies) do
            if e.alive then allDead = false break end
        end
        if allDead then
            currentLevel = currentLevel + 1
            levelPassed = true
            gameState = "gameover"
        end
    end
end

function love.draw()
    if gameState == "menu" then
        menu.draw()
    elseif gameState == "playing" then
        walls.draw()
        Player.draw(player)
        for _, e in ipairs(enemies) do Enemy.draw(e) end
        Trap.draw(trap)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Killed: " .. enemiesKilled, 600, 10)
    elseif gameState == "gameover" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Enemies killed: " .. enemiesKilled, 0, 320, 800, "center")
        love.graphics.printf("Press ENTER to restart", 0, 360, 800, "center")
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        local action = menu.keypressed(key)
        if action == "start" then
            startGame()
        end
    elseif gameState == "gameover" then
        if key == "return" or key == "kpenter" then
            if not levelPassed then currentLevel = 1 end
            levelPassed = false
            startGame()
        elseif key == "escape" then love.event.quit() end
    elseif gameState == "playing" and key == "escape" then
        love.event.quit()
    end
end
