
local components = require("src.components")
local moveSystem = require("src.systems.movement")
local drawSystem = require("src.systems.draw")
local trapSystem = require("src.systems.trap")
local aiSystem = require("src.systems.enemy_ai")
local collisionSystem = require("src.systems.collision")
local wallSystem = require("src.systems.wall_system")
local levelSystem = require("src.systems.level_system")
local menuSystem = require("src.systems.menu_system")

local enemy_kills = { count = 0 }
local next_entity_id = 0
local gameState = { gameOver = false }
local menuState = { active = true, selected = nil, startGame = false }

local function newEntity()
    next_entity_id = next_entity_id + 1
    return next_entity_id
end

local function spawnPlayer()
    local id = newEntity()
    components.position[id] = {x = 100, y = 100}
    components.radius[id] = 10
    components.player[id] = true
end

local function spawnEnemy(x, y)
    local id = newEntity()
    components.position[id] = {x = x, y = y}
    components.radius[id] = 10
    components.enemy[id] = true
    components.killable[id] = true
end

local function spawnTrap()
    local id = newEntity()
    components.position[id] = {x = 400, y = 300}
    components.trap[id] = {angle = 0, radius = 100, speed = 1.5}
    components.radius[id] = 5
end

local function spawnWall()
    local id = newEntity()
    components.position[id] = {x = 200, y = 0}
    components.wall[id] = true
    components.velocity[id] = {vx = 0, vy = 50}
end

local function spawnLevel(level)
    spawnPlayer()
    for i = 1, 5 do
        spawnEnemy(200 + i*60, 200 + math.random(-50, 50))
    end
    spawnTrap()
    spawnWall()
    components.level.current = level
end

function love.load()

end

function love.update(dt)
    if menuState.active then
        menuSystem(menuState)
        return
    end

    if menuState.startGame then
        spawnLevel(menuState.selected)
        menuState.startGame = false
    end

    if gameState.gameOver then
        if love.keyboard.isDown("r") then
            love.event.quit("restart")
        elseif love.keyboard.isDown("m") then
            menuState.active = true
            next_entity_id = 0
            for k in pairs(components) do
                if type(components[k]) == "table" then
                    components[k] = {}
                end
            end
            components.level = { current = 1 }
            enemy_kills.count = 0
            gameState.gameOver = false
        end
        return
    end

    for id in pairs(components.player) do
        local input = {x = 0, y = 0}
        if love.keyboard.isDown("a") then input.x = input.x - 1 end
        if love.keyboard.isDown("d") then input.x = input.x + 1 end
        if love.keyboard.isDown("w") then input.y = input.y - 1 end
        if love.keyboard.isDown("s") then input.y = input.y + 1 end
        local speed = 150
        components.velocity[id] = {vx = input.x * speed, vy = input.y * speed}
    end

    aiSystem(components)
    moveSystem(components, dt)
    wallSystem(components, dt)
    trapSystem(components, dt, enemy_kills)
    collisionSystem(components, gameState)
    levelSystem(components, enemy_kills)
end

function love.draw()
    if menuState.active then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SELECT LEVEL: 1 or 2", 0, 200, 800, "center")
        if menuState.selected then
            love.graphics.printf("Selected: " .. menuState.selected, 0, 240, 800, "center")
        end
        love.graphics.printf("Press ENTER to start", 0, 300, 800, "center")
        return
    end

    drawSystem(components)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Kills: " .. enemy_kills.count, 10, 10)
    love.graphics.print("Level: " .. components.level.current, 10, 30)
    if gameState.gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER - Press R to Restart, M for Menu", 0, 250, 800, "center")
    end
end
