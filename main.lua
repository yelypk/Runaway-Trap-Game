local components = require("src.components")
local moveSystem = require("src.systems.movement")
local drawSystem = require("src.systems.draw")
local trapSystem = require("src.systems.trap")
local placement = require("src.systems.placement")
local aiSystem = require("src.systems.enemy_ai")
local collisionSystem = require("src.systems.collision")
local wallSystem = require("src.systems.wall_system")
local levelSystem = require("src.systems.level_system")
local menuSystem = require("src.systems.menu_system")
local build_map = require("src.systems.build_map")
local solidCollision = require("src.systems.solid_collision")

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
    components.player[id] = true
    components.position[id] = { x = 200, y = 200 }
    components.radius[id]   = 8
    components.velocity[id] = { vx = 0, vy = 0 }
end

local function spawnEnemy(x, y)
    local id = newEntity()
    components.enemy[id] = true
    components.killable = components.killable or {}
    components.killable[id] = true
    components.position[id] = { x = x or 300, y = y or 300 }
    components.radius[id]   = 8
    components.velocity[id] = { vx = 0, vy = 0 }
end

local function spawnTrap()
    local id = newEntity()

    components.radius[id]   = 6
    components.velocity[id] = { vx = 0, vy = 0 }

    local x, y, goodR = placement.find_trap_spot(components, {
        minR   = 12,
        maxR   = 28,
        margin = 5,
        tries  = 4000,
    })

    components.position[id] = { x = x, y = y }
    components.trap[id] = {
        -- trap.lua трактує speed як кутову швидкість (рад/с): angle += speed * dt
        speed  = 3.0, 
        angle  = 0,
        radius = goodR, -- радіус ОРБІТИ пастки trap.lua
        path   = {}
    }

    return id
end

function love.load()
    components.level = components.level or { current = 1 }
end

function love.update(dt)
    menuSystem(menuState)

    if menuState.startGame then
        package.loaded["src.components"] = nil
        components = require("src.components")
        components.level.current = menuState.selected or 1

        enemy_kills.count = 0
        gameState.gameOver = false

        build_map(components)
        spawnPlayer()
        for i = 1, 5 do
            spawnEnemy(200 + i*60, 200 + math.random(-50, 50))
        end
        spawnTrap()

        menuState.startGame = false
    end

    if menuState.active then return end
    if gameState.gameOver then
        if love.keyboard.isDown("r") then
            menuState.active = true
            menuState.selected = components.level.current
        end
        return
    end

    for id in pairs(components.player) do
        local vx, vy = 0, 0
        local speed = 150
        if love.keyboard.isDown("a") then vx = vx - speed end
        if love.keyboard.isDown("d") then vx = vx + speed end
        if love.keyboard.isDown("w") then vy = vy - speed end
        if love.keyboard.isDown("s") then vy = vy + speed end
        components.velocity[id] = components.velocity[id] or { vx = 0, vy = 0 }
        components.velocity[id].vx = vx
        components.velocity[id].vy = vy
    end

    -- systems
    aiSystem(components)
    trapSystem(components, dt, enemy_kills)
    wallSystem(components, dt)
    moveSystem(components, dt)
    solidCollision(components)
    collisionSystem(components, enemy_kills, gameState)
    levelSystem(components, enemy_kills)
end

function love.draw()
    love.graphics.clear(0.08, 0.08, 0.10)

    if menuState.active then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SELECT LEVEL: 1 or 2", 0, 200, 800, "center")
        if menuState.selected then
            love.graphics.printf("Selected: " .. tostring(menuState.selected), 0, 240, 800, "center")
        end
        love.graphics.printf("Press ENTER to start", 0, 300, 800, "center")
        return
    end

    drawSystem(components)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Kills: " .. tostring(enemy_kills.count), 10, 10)
    love.graphics.print("Level: " .. tostring(components.level.current or 1), 10, 30)

    if gameState.gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER - Press R to Restart, M for Menu", 0, 250, 800, "center")
    end
end
