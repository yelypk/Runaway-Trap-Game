return function(components, enemy_kills)
    if enemy_kills.count >= 3 then
        components.level.current = components.level.current + 1
        love.event.quit("restart")
    end
end
