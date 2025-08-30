local function resolveCircleAABB(pos, vel, r, bx, by, bs)
    local hx, hy = bs * 0.5, bs * 0.5
    local nx = math.max(bx - hx, math.min(pos.x, bx + hx))
    local ny = math.max(by - hy, math.min(pos.y, by + hy))
    local dx, dy = pos.x - nx, pos.y - ny
    local d2 = dx*dx + dy*dy

    if d2 < r*r then
        local dist = math.sqrt(d2)
        if dist == 0 then
            local penX = math.min(math.abs((bx + hx) - pos.x), math.abs(pos.x - (bx - hx)))
            local penY = math.min(math.abs((by + hy) - pos.y), math.abs(pos.y - (by - hy)))
            if penX < penY then
                pos.x = pos.x + (pos.x < bx and -1 or 1) * (r - penX)
                if vel then vel.vx = 0 end
            else
                pos.y = pos.y + (pos.y < by and -1 or 1) * (r - penY)
                if vel then vel.vy = 0 end
            end
        else
            local nxn, nyn = dx / dist, dy / dist
            local penetration = r - dist
            pos.x = pos.x + nxn * penetration
            pos.y = pos.y + nyn * penetration
            if vel then
                local vn = vel.vx * nxn + vel.vy * nyn
                if vn < 0 then
                    vel.vx = vel.vx - vn * nxn
                    vel.vy = vel.vy - vn * nyn
                end
            end
        end
        return true
    end
    return false
end

return function(components)
    local pos = components.position or {}
    local vel = components.velocity or {}
    local rad = components.radius or {}
    local walls = components.wall or {}

    local tileSize
    for wid in pairs(walls) do
        tileSize = (rad[wid] or 6) * 2
        break
    end
    if not tileSize then return end

    local wallList = {}
    for wid in pairs(walls) do
        local p = pos[wid]
        if p then
            wallList[#wallList+1] = {x = p.x, y = p.y}
        end
    end

    local function isMover(id)
        return (components.player and components.player[id]) or
               (components.enemy  and components.enemy[id])
    end

    for id, v in pairs(vel) do
        if isMover(id) then
            local p = pos[id]
            local r = rad[id] or 6
            if p then
                local reach = r + tileSize * 0.5
                for i = 1, #wallList do
                    local w = wallList[i]
                    if math.abs(p.x - w.x) <= reach and math.abs(p.y - w.y) <= reach then
                        resolveCircleAABB(p, v, r, w.x, w.y, tileSize)
                    end
                end
            end
        end
    end
end