local levels = {
  {
    enemies = 2,
    enemySpeed = 200,
    trapSpeed = 3.5,
    trajectory = "circle"
  },
  { enemies = 3,
    enemySpeed = 200,
    trapSpeed = 4.0,
    trajectory = "eight"
  },
  { enemies = 4,
    enemySpeed = 200,
    trapSpeed = 4.0,
    trajectory = "sine"
  },
  {
    enemies = 5,
    enemySpeed = 200,
    trapSpeed = 4.0,
    trajectory = "bounce"
  }
}

local available = {"circle", "eight", "spiral", "sine", "bounce"}

function levels.get(level)
  if type(level) ~= "number" then
    error("levels.get() requires a level number, got: " .. tostring(level))
  end
  
  local l = levels[level]
  
  if not l then
    return {
      enemies = 5+level, enemySpeed = 200+level*10,
      trapSpeed = 3+level*0.3,
      trajectory=available[love.math.random(1,#available)]
    }
  end
  
  if not l.trajectory then
    l.trajectory = available[love.math.random(1,#available)]
  end
  return l
end

return levels