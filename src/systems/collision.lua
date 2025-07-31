return function(components, gameState)
    for eid in pairs(components.enemy) do
        local epos = components.position[eid]
        local er = components.radius[eid]
        for pid in pairs(components.player) do
            local ppos = components.position[pid]
            local pr = components.radius[pid]
            local dx = ppos.x - epos.x
            local dy = ppos.y - epos.y
            if math.sqrt(dx*dx + dy*dy) < er + pr then
                gameState.gameOver = true
            end
        end
    end

    for tid in pairs(components.trap) do
        local t = components.trap[tid]
        local tpos = components.position[tid]
        local tx = tpos.x + t.radius * math.cos(t.angle)
        local ty = tpos.y + t.radius * math.sin(t.angle)

        for pid in pairs(components.player) do
            local ppos = components.position[pid]
            local dx = tx - ppos.x
            local dy = ty - ppos.y
            if math.sqrt(dx*dx + dy*dy) < 10 + components.radius[pid] then
                gameState.gameOver = true
            end
        end
    end
end
