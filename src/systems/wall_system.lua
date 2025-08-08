return function(components, dt)
    local walls = components.wall or {}
    for id, isWall in pairs(walls) do
        if isWall == true then
            local pos = components.position and components.position[id]
            if pos then
                local vel = components.velocity and components.velocity[id]
                if not vel then
                    vel = { vx = 0, vy = 0 }
                    components.velocity = components.velocity or {}
                    components.velocity[id] = vel
                end

                pos.y = pos.y + (vel.vy or 0) * dt

                local screenH = love.graphics.getHeight()
                local r = (components.radius and components.radius[id]) or 5

                if pos.y - r < 0 then
                    pos.y = r
                    vel.vy = math.abs(vel.vy or 0)
                elseif pos.y + r > screenH then
                    pos.y = screenH - r
                    vel.vy = -math.abs(vel.vy or 0)
                end
            end
        end
    end
end

