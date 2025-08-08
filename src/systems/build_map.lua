local VoronoiGen = require("src.gen.voronoi")

local tileSize = 12
local gridW, gridH = 96, 64

local function ensure(components)
  components.position = components.position or {}
  components.velocity = components.velocity or {}
  components.radius = components.radius or {}
  components.wall = components.wall or {}
  components.map = components.map or {}
end

local function newId(components)
  components._nextId = (components._nextId or 0) + 1
  return components._nextId
end

return function(components)
  ensure(components)
  if components.map.built then return end

  local gen = VoronoiGen.generate{
    width = gridW, height = gridH, seeds = 28, relax = 1
  }

  for y=1,gen.h do
    for x=1,gen.w do
      if gen.tiles[y][x].wall then
        local id = newId(components)
        components.wall[id] = true
        components.position[id] = { x = (x-0.5)*tileSize, y = (y-0.5)*tileSize }
        components.velocity[id] = { vx = 0, vy = 0 }
        components.radius[id] = tileSize/2
      end
    end
  end

  components.map.built = true
end
