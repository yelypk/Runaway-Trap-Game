return function(components)
    local player_pos = nil
    for id in pairs(components.player) do
        player_pos = components.position[id]
    end
    if not player_pos then return end

    for id in pairs(components.enemy) do
        local pos = components.position[id]
        if pos then
            local dx = player_pos.x - pos.x
            local dy = player_pos.y - pos.y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 0 then
                components.velocity[id] = {
                    vx = (dx / dist) * 60,
                    vy = (dy / dist) * 60
                }
            end
        end
    end
end
