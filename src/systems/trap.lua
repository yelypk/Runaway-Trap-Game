return function(components, dt, enemy_kills)
    for id, trap in pairs(components.trap) do
        local center = components.position[id]
        trap.angle = (trap.angle + trap.speed * dt) % (2 * math.pi)

        trap.path = trap.path or {}
        local px = center.x + trap.radius * math.cos(trap.angle)
        local py = center.y + trap.radius * math.sin(trap.angle)
        table.insert(trap.path, {x = px, y = py})
        if #trap.path > 100 then
            table.remove(trap.path, 1)
        end

        for eid, pos in pairs(components.position) do
            if components.enemy[eid] and components.velocity[eid] then
                local dx = pos.x - center.x
                local dy = pos.y - center.y
                local dist2 = dx*dx + dy*dy
                local inside = dist2 <= trap.radius * trap.radius
                if inside then
                    components.velocity[eid].vx = components.velocity[eid].vx * 0.5
                    components.velocity[eid].vy = components.velocity[eid].vy * 0.5
                end
            end
        end

        if trap.angle < dt * trap.speed then
            for eid, pos in pairs(components.position) do
                if components.enemy[eid] and components.killable[eid] then
                    local dx = pos.x - center.x
                    local dy = pos.y - center.y
                    local dist2 = dx*dx + dy*dy
                    if dist2 <= trap.radius * trap.radius then
                        components.position[eid] = nil
                        components.velocity[eid] = nil
                        components.radius[eid] = nil
                        components.enemy[eid] = nil
                        components.killable[eid] = nil
                        enemy_kills.count = enemy_kills.count + 1
                    end
                end
            end
            trap.path = {} 
        end
    end
end
