return function(components, dt)
    if not components.wall then return end
    local pos = components.position or {}

    for id in pairs(components.wall) do
        if not pos[id] then
            components.wall[id] = nil
        end
    end
end


