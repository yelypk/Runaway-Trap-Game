return function(components, dt)
    for id, vel in pairs(components.velocity) do
        local pos = components.position[id]
        if pos then
            pos.x = pos.x + vel.vx * dt
            pos.y = pos.y + vel.vy * dt
        end
    end
end
