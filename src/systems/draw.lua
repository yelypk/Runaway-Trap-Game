return function(components)
    for id, pos in pairs(components.position) do
        local r = components.radius[id]
        if r then
            if components.player[id] then
                love.graphics.setColor(0, 1, 0)
            elseif components.enemy[id] then
                love.graphics.setColor(1, 0, 0)
            elseif components.trap[id] then
                love.graphics.setColor(0, 0, 1)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.circle("fill", pos.x, pos.y, r)
        end
    end

    for id, trap in pairs(components.trap) do
        if trap.path then
            love.graphics.setColor(1, 1, 0, 0.5)
            for i = 2, #trap.path do
                local p1, p2 = trap.path[i-1], trap.path[i]
                love.graphics.line(p1.x, p1.y, p2.x, p2.y)
            end
        end
    end
end
