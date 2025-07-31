return function(components, dt)
    for id in pairs(components.wall) do
        local pos = components.position[id]
        local vel = components.velocity[id]
        pos.y = pos.y + vel.vy * dt
        if pos.y < 0 or pos.y > 600 - 10 then
            vel.vy = -vel.vy
        end
    end
end
