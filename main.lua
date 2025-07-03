local menu = require("menu")
local levels = require("levels")

local gameState = "menu"
local currentLevel = 1
local levelPassed = false

local player = {}
local enemies = {}
local trap = {}
local enemiesKilled = 0

local function checkCollision(a, b)
    return a.x < b.x + b.size and
           b.x < a.x + a.size and
           a.y < b.y + b.size and
           b.y < a.y + a.size
end

local function spawnEnemy(x, y, speed)
    table.insert(enemies, {
        x = x,
        y = y,
        size = 20,
        speed = 200,
        alive = true
    })
end

function startGame()
 local levelData = levels.get(currentLevel)

    player = {
        x = 400,
        y = 300,
        speed = 400,
        size = 20,
        alive = true
    }

    enemies = {}
    enemiesKilled = 0

    trap = {
        centerX = math.random(100, 700),
        centerY = math.random(100, 500),
        angle = 0,
        radius = 200,
        size = 30,
        speed = levelData.trapSpeed,
        x = 0,
        y = 0
    }

    trapPathType = levelData.trajectory

    for i = 1, levelData.enemies do
        spawnEnemy(math.random(0, 780), math.random(0, 580), levelData.enemySpeed)
    end
    gameState = "playing"
end

function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle("Fast-Boom!")
    menu.load()
end

function love.update(dt)
    if gameState == "menu" then
        menu.update(dt)

    elseif gameState == "playing" then
        if not player.alive then return end

        if love.keyboard.isDown("up") then player.y = player.y - player.speed * dt end
        if love.keyboard.isDown("down") then player.y = player.y + player.speed * dt end
        if love.keyboard.isDown("left") then player.x = player.x - player.speed * dt end
        if love.keyboard.isDown("right") then player.x = player.x + player.speed * dt end
        
        --- щоб гравець не виходив за мапу 
        player.x = math.max(0, math.min(800-player.size, player.x))
        player.y = math.max(0, math.min(600-player.size, player.y))

        for _, enemy in ipairs(enemies) do
            if enemy.alive then
                local dx = player.x - enemy.x
                local dy = player.y - enemy.y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist > 0 then
                    enemy.x = enemy.x + (dx / dist) * enemy.speed * dt
                    enemy.y = enemy.y + (dy / dist) * enemy.speed * dt
                end
            end
        end

        trap.angle = trap.angle + trap.speed * dt
        trap.x = trap.centerX + math.cos(trap.angle) * trap.radius
        trap.y = trap.centerY + math.sin(trap.angle) * trap.radius

        for _, enemy in ipairs(enemies) do
            if enemy.alive and checkCollision(enemy, trap) then
                enemy.alive = false
                enemiesKilled = enemiesKilled + 1
            end
        end

        if checkCollision(player, trap) then
            player.alive = false
            gameState = "gameover"
        end
        
        local allDead = true
        for _, enemy in ipairs(enemies) do
          if enemy.alive then allDead = false
            break
          end
        end
    end
    
    if allDead then
      currentLevel = currentLevel + 1
      levelPassed = true
      gameState = "gameover"
    end
end

function love.draw()
    if gameState == "menu" then
        menu.draw()

    elseif gameState == "playing" then
        if player.alive then
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)
        end

        for _, enemy in ipairs(enemies) do
            if enemy.alive then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.size, enemy.size)
            end
        end

        love.graphics.setColor(0.6, 0.6, 0.6)
        local s = trap.size
        love.graphics.polygon("fill",
            trap.x, trap.y,
            trap.x + s, trap.y + 5,
            trap.x + s - 5, trap.y + s,
            trap.x, trap.y + s - 5
        )

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
         if not levelPassed then
         currentLevel = 1
        end
        levelPassed = false
        startGame()
      elseif key == "escape" then
        love.event.quit()
      end

    elseif gameState == "playing" then
        if key == "escape" then
            love.event.quit()
        end

    elseif key == "escape" then
            love.event.quit()
        end
    end