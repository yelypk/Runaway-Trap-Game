local trap = {}

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function trap.create(speed, player)
    local size = 250
    local centerX, centerY
    local minDistance = 200
    local tries = 0

    repeat
        centerX = math.random(300, 500)
        centerY = math.random(200, 400)
        tries = tries + 1
    until tries > 100 or not player or distance(centerX, centerY, player.x, player.y) > minDistance

    local height = math.sqrt(3) / 2 * size
    local vertices = {
        { x = centerX,           y = centerY - height / 2 },
        { x = centerX - size/2,  y = centerY + height / 2 },
        { x = centerX + size/2,  y = centerY + height / 2 }
    }

    return {
        vertices = vertices,
        current = 1,
        next = 2,
        x = vertices[1].x,
        y = vertices[1].y,
        size = 30,
        speed = speed * 80,
        t = 0
    }
end

function trap.update(self, dt)
    local a = self.vertices[self.current]
    local b = self.vertices[self.next]

    local dx = b.x - a.x
    local dy = b.y - a.y
    local length = math.sqrt(dx*dx + dy*dy)
    local move = self.speed * dt

    self.t = self.t + move / length

    while self.t >= 1 do
        self.t = self.t - 1
        self.current = self.next
        self.next = self.next % 3 + 1
        a = self.vertices[self.current]
        b = self.vertices[self.next]
        dx = b.x - a.x
        dy = b.y - a.y
        length = math.sqrt(dx*dx + dy*dy)
    end

    self.x = a.x + dx * self.t
    self.y = a.y + dy * self.t
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
