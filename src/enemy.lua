local enemy = {}

function enemy.spawn(x, y, speed)
    return {
        x = x,
        y = y,
        size = 20,
        speed = speed,
        alive = true
    }
end

function enemy.update(self, dt, player, walls)
    if not self.alive then return end
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > 0 then
        local oldX, oldY = self.x, self.y
        self.x = self.x + (dx / dist) * self.speed * dt
        self.y = self.y + (dy / dist) * self.speed * dt

        if walls.checkCollision(self) then
            self.x, self.y = oldX, oldY
        end
    end
end

function enemy.draw(self)
    if self.alive then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
    end
end

return enemy
