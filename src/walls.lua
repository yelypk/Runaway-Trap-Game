local walls = {}

function walls.load()
    walls.wall = {
        x = 100,
        y = 200,
        width = 600,
        height = 10,
        direction = 1,
        speed = 200    
    }
end

function walls.update(dt)
    local wall = walls.wall

    wall.y = wall.y + wall.speed * dt * wall.direction

    if wall.y < 100 then
        wall.y = 100
        wall.direction = 1
    elseif wall.y > 500 then
        wall.y = 500
        wall.direction = -1
    end
end

function walls.draw()
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill", walls.wall.x, walls.wall.y, walls.wall.width, walls.wall.height)
end

function walls.checkCollision(entity)
    local wall = walls.wall
    return entity.x < wall.x + wall.width and
           wall.x < entity.x + entity.size and
           entity.y < wall.y + wall.height and
           wall.y < entity.y + entity.size
end

return walls