local trap = {}

function trap.create(speed)
    local centerX = math.random(100, 700)
    local centerY = math.random(100, 500)
    return {
        centerX = centerX,
        centerY = centerY,
        angle = 0,
        radius = 200,
        size = 30,
        speed = speed,
        x = centerX,
        y = centerY
    }
end

function trap.update(self, dt)
    self.angle = self.angle + self.speed * dt
    self.x = self.centerX + math.cos(self.angle) * self.radius
    self.y = self.centerY + math.sin(self.angle) * self.radius
end

function trap.draw(self)
    love.graphics.setColor(0.6, 0.6, 0.6)
    local s = self.size
    love.graphics.polygon("fill",
        self.x, self.y,
        self.x + s, self.y + 5,
        self.x + s - 5, self.y + s,
        self.x, self.y + s - 5
    )
end

return trap
