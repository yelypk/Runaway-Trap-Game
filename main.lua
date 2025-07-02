local player = {
    x=400,
    y=300,
    speed=300,
    size=20,
    alive=true
}

local enemies={}
local enemiesKilled=0

local trap={
    centerX=0,
    centerY=0,
    angle=0,
    radius=120,
    size=30,
    speed=3.7,
    x=0,
    y=0
}

local function spawnEnemy(x,y,speed)
    table.insert(enemies,{
        x=x,
        y=y,
        size=20,
        speed=230,
        alive=true
    })
end

local function checkCollision(a,b)
    return a.x<b.x+b.size and
    b.x<a.x+a.size and
    a.y<b.y+b.size and
    b.y<a.y+a.size
end

function love.load()
    love.window.setTitle('Enemies and trap!')
    love.window.setMode(800,600)

    spawnEnemy(100,100,80)
    spawnEnemy(700,500,60)

    trap.centerX=math.random(100,700)
    trap.centerY=math.random(100,500)
end

function love.update(dt)
    if not player.alive then return end

    if love.keyboard.isDown("up") then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown("down") then player.y = player.y + player.speed * dt end
    if love.keyboard.isDown("left") then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown("right") then player.x = player.x + player.speed * dt end

    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            local dx = player.x - enemy.x
            local dy = player.y - enemy.y
            local dist = math.sqrt(dx*dx + dy*dy)
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
        if enemy.alive then
            if checkCollision(enemy, trap) then
                enemy.alive = false
                enemiesKilled = enemiesKilled + 1
            end
        end
    end

    if checkCollision(player, trap) then
        player.alive = false
    end
end

function love.draw()
    if player.alive then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("You are ka-boom!", 350, 280, 0, 2, 2)
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
end