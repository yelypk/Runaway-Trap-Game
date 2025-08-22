local major = love.getVersion and select(1, love.getVersion()) or 11

local function setRGB(r, g, b, a)
    if major >= 11 then
        love.graphics.setColor((r or 255)/255, (g or 255)/255, (b or 255)/255, (a or 255)/255)
    else
        love.graphics.setColor(r or 255, g or 255, b or 255, a or 255)
    end
end

return function(components)
    if major >= 11 then
        love.graphics.setBlendMode("alpha", "alphamultiply")
    else
        love.graphics.setBlendMode("alpha")
    end
    love.graphics.setLineWidth(1)

    local pos = components.position or {}
    local radius = components.radius or {}
    local walls = components.wall or {}
    local players = components.player or {}
    local enemies = components.enemy or {}
    local traps = components.trap or {}

    for id in pairs(walls) do
        local p, r = pos[id], radius[id]
        if p and r then
            setRGB(216, 216, 216, 255)
            love.graphics.rectangle("fill", p.x - r, p.y - r, r*2, r*2)
        end
    end

    for id, tr in pairs(traps) do
        local p = pos[id]
        if p then
            if tr.angle and tr.radius then
                local ex = p.x + math.cos(tr.angle) * tr.radius
                local ey = p.y + math.sin(tr.angle) * tr.radius
                setRGB(205, 230, 255, 140)
                love.graphics.setLineWidth(2)
                love.graphics.line(p.x, p.y, ex, ey)
            end
            if tr.path and #tr.path >= 2 then
                setRGB(255, 255, 0, 140)
                love.graphics.setLineWidth(1)
                for i = 2, #tr.path do
                    local a, b = tr.path[i - 1], tr.path[i]
                    love.graphics.line(a.x, a.y, b.x, b.y)
                end
            end
        end
    end

    love.graphics.setBlendMode("replace") 
    for id in pairs(enemies) do
        local p, r = pos[id], radius[id]
        if p and r then
            setRGB(255, 40, 40, 255)
            love.graphics.rectangle("fill", p.x - r, p.y - r, r*2, r*2)
        end
    end

    for id in pairs(players) do
        local p, r = pos[id], radius[id]
        if p and r then
            setRGB(0, 230, 100, 255)
            love.graphics.rectangle("fill", p.x - r, p.y - r, r*2, r*2)
        end
    end

    if major >= 11 then
        love.graphics.setBlendMode("alpha", "alphamultiply")
    else
        love.graphics.setBlendMode("alpha")
    end

    setRGB(255, 255, 255, 255)
    love.graphics.setLineWidth(1)
end

