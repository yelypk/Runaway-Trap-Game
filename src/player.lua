local player = {}

function player.create()
    return {
        x = 400,
        y = 300,
        speed = 400,
        size = 20,
        alive = true
    }
end

function player.update(self, dt)
    local oldX, oldY = self.x, self.y

    if love.keyboard.isDown("up") then self.y = self.y - self.speed * dt end
    if love.keyboard.isDown("down") then self.y = self.y + self.speed * dt end
    if love.keyboard.isDown("left") then self.x = self.x - self.speed * dt end
    if love.keyboard.isDown("right") then self.x = self.x + self.speed * dt end

    return oldX, oldY
end

function player.draw(self)
    if self.alive then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
    end
end

return player
